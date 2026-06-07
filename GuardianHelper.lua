-- ============================================================
-- GuardianHelper v2.0
-- Guardian Druid Tank Addon — Level 1-70 (Classic & TBC)
-- Unterstützt automatische Aktionsleisten-Aktualisierung
-- ============================================================

local GH_VERSION = "2.0.0"

-- ============================================================
-- SPELL-GRUPPEN: Alle Ränge pro Ability (Level 1–70)
-- Enthält Classic (1-60) und TBC (61-70) Ränge
-- ============================================================
local SPELL_GROUPS = {

    MAUL = {
        label = "Maul", autoUpdate = true,
        ranks = {
            {id=6807,  level=10}, {id=8972,  level=18},
            {id=9745,  level=26}, {id=9880,  level=34},
            {id=9881,  level=42}, {id=26996, level=50},
            {id=26997, level=58},
            {id=48479, level=62}, {id=48480, level=70}, -- TBC
        },
    },

    SWIPE = {
        label = "Swipe", autoUpdate = true,
        ranks = {
            {id=779,  level=16}, {id=780,  level=24},
            {id=769,  level=34}, {id=9754, level=44},
            {id=9908, level=54},
            {id=48562,level=62}, -- TBC
        },
    },

    BASH = {
        label = "Bash", autoUpdate = true,
        ranks = {
            {id=5211, level=14}, {id=6798, level=22},
            {id=8983, level=32},
            {id=25515,level=42}, -- TBC
        },
    },

    GROWL = {
        label = "Growl", autoUpdate = false,
        ranks = {
            {id=6795, level=10}, -- nur 1 Rang
        },
    },

    ENRAGE = {
        label = "Enrage", autoUpdate = false,
        ranks = {
            {id=5229, level=14}, -- nur 1 Rang
        },
    },

    DEMO_ROAR = {
        label = "Demo Roar", autoUpdate = true,
        ranks = {
            {id=99,   level=8 }, {id=1735, level=16},
            {id=9490, level=24}, {id=9747, level=32},
            {id=9898, level=42},
            {id=26998,level=52}, -- TBC
        },
    },

    FAERIE_FIRE = {
        label = "Faerie Fire", autoUpdate = false,
        ranks = {
            {id=16857,level=20}, {id=17390,level=30},
            {id=17391,level=40}, {id=17392,level=50},
            {id=27011,level=60}, -- TBC
        },
    },

    FRENZIED_REGEN = {
        label = "F.Regen", autoUpdate = false,
        ranks = {
            {id=22842,level=36}, {id=22895,level=46},
            {id=22896,level=56},
            {id=26999,level=66}, -- TBC
        },
    },

    BARKSKIN = {
        label = "Barkskin", autoUpdate = false,
        ranks = {
            {id=22812,level=44}, -- nur 1 Rang
        },
    },

    -- TBC-Exclusive
    MANGLE_BEAR = {
        label = "Mangle", autoUpdate = true,
        ranks = {
            {id=33878,level=60}, {id=33986,level=66},
            {id=33987,level=72}, -- nur falls vorhanden
        },
    },

    LACERATE = {
        label = "Lacerate", autoUpdate = true,
        ranks = {
            {id=33745,level=66},
        },
    },
}

-- Cooldown-Slots (welche auf der UI erscheinen)
local CD_SLOTS = {
    "BASH", "GROWL", "ENRAGE", "FRENZIED_REGEN", "BARKSKIN",
    "MANGLE_BEAR", "LACERATE",
}

-- ============================================================
-- BEAR FORM IDs (für Buff-Check)
-- ============================================================
local BEAR_FORM_IDS  = {5487}   -- Bear Form
local DIRE_BEAR_IDS  = {9634}   -- Dire Bear Form (ab Level 40)

-- ============================================================
-- FARBEN
-- ============================================================
local C = {
    rage    = {0.85, 0.15, 0.10},
    ready   = {0.20, 0.90, 0.20},
    warn    = {1.00, 0.78, 0.00},
    danger  = {1.00, 0.20, 0.20},
    cd      = {0.45, 0.45, 0.45},
    locked  = {0.30, 0.30, 0.30},
    maul_on = {1.00, 0.65, 0.00},
    ff_up   = {0.40, 0.80, 1.00},
    ff_down = {0.75, 0.25, 0.65},
    bear    = {0.60, 0.35, 0.10},
}

-- ============================================================
-- SPELL-LOOKUP CACHE
-- Wird beim Login und bei SPELLS_CHANGED aufgebaut
-- ============================================================
local spellCache = {}   -- [groupKey] = {highestID, highestLevel, highestSlot, allKnownIDs={}}

local function RebuildSpellCache()
    -- Reset
    for k in pairs(spellCache) do spellCache[k] = nil end

    -- Spellbook durchsuchen
    local i = 1
    while true do
        local name = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not name then break end
        local _, spellID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)

        -- Prüfe alle Gruppen
        for groupKey, group in pairs(SPELL_GROUPS) do
            for _, rankData in ipairs(group.ranks) do
                if rankData.id == spellID then
                    if not spellCache[groupKey] then
                        spellCache[groupKey] = {
                            highestID    = spellID,
                            highestLevel = rankData.level,
                            highestSlot  = i,
                            allKnownIDs  = {},
                        }
                    else
                        -- Höherer Rang?
                        if rankData.level > spellCache[groupKey].highestLevel then
                            spellCache[groupKey].highestID    = spellID
                            spellCache[groupKey].highestLevel = rankData.level
                            spellCache[groupKey].highestSlot  = i
                        end
                    end
                    spellCache[groupKey].allKnownIDs[spellID] = true
                end
            end
        end
        i = i + 1
    end
end

-- ============================================================
-- AKTIONSLEISTE AUTO-UPDATE
-- ============================================================
local function UpdateActionBarsForGroup(groupKey)
    local group = SPELL_GROUPS[groupKey]
    if not group or not group.autoUpdate then return end

    local cache = spellCache[groupKey]
    if not cache then return end
    if not next(cache.allKnownIDs) then return end

    -- Höchster bekannter Rang
    local newID   = cache.highestID
    local newSlot = cache.highestSlot

    -- Alle Action-Slots (1-120) durchsuchen
    local updated = 0
    for slot = 1, 120 do
        local actionType, actionID = GetActionInfo(slot)
        if actionType == "spell" and actionID ~= newID then
            -- Ist das ein veralteter Rang dieses Spells?
            if cache.allKnownIDs[actionID] then
                -- Alten Rang durch neuen ersetzen
                ClearCursor()
                PickupSpellBookItem(newSlot, BOOKTYPE_SPELL)
                PlaceAction(slot)
                ClearCursor()
                updated = updated + 1
            end
        end
    end

    if updated > 0 then
        local newName = GetSpellInfo(newID)
        print(string.format("|cff00cc44GuardianHelper:|r |cffffffff%s|r → Aktionsleiste aktualisiert (%dx)", newName or groupKey, updated))
    end
end

local function UpdateAllActionBars()
    for groupKey in pairs(SPELL_GROUPS) do
        UpdateActionBarsForGroup(groupKey)
    end
end

-- ============================================================
-- HAUPTFRAME
-- ============================================================
local Frame = CreateFrame("Frame", "GuardianHelperFrame", UIParent)
Frame:SetSize(260, 210)
Frame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
Frame:SetMovable(true)
Frame:EnableMouse(true)
Frame:RegisterForDrag("LeftButton")
Frame:SetScript("OnDragStart", function(s) s:StartMoving() end)
Frame:SetScript("OnDragStop",  function(s) s:StopMovingOrSizing() end)
Frame:SetFrameStrata("MEDIUM")

-- Hintergrund & Rand
local bg = Frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0, 0, 0, 0.80)

-- Farbiger oberer Balken (Form-Status)
local headerBg = Frame:CreateTexture(nil, "ARTWORK")
headerBg:SetSize(260, 22)
headerBg:SetPoint("TOPLEFT", Frame, "TOPLEFT", 0, 0)
headerBg:SetColorTexture(C.bear[1], C.bear[2], C.bear[3], 1)

local headerText = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
headerText:SetPoint("CENTER", headerBg, "CENTER", 0, 0)
headerText:SetText("🐻 GuardianHelper")
headerText:SetTextColor(1, 1, 1)

-- ============================================================
-- RAGE BAR
-- ============================================================
local rageLabel = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
rageLabel:SetPoint("TOPLEFT", Frame, "TOPLEFT", 8, -28)
rageLabel:SetText("RAGE")
rageLabel:SetTextColor(C.rage[1], C.rage[2], C.rage[3])

local rageValText = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
rageValText:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -8, -28)
rageValText:SetText("0/100")
rageValText:SetTextColor(1, 1, 1)

local rageBG = Frame:CreateTexture(nil, "BACKGROUND")
rageBG:SetSize(244, 16)
rageBG:SetPoint("TOPLEFT", Frame, "TOPLEFT", 8, -44)
rageBG:SetColorTexture(0.12, 0.03, 0.03, 1)

local rageBarFill = Frame:CreateTexture(nil, "ARTWORK")
rageBarFill:SetSize(244, 16)
rageBarFill:SetPoint("TOPLEFT", rageBG, "TOPLEFT", 0, 0)
rageBarFill:SetColorTexture(C.rage[1], C.rage[2], C.rage[3], 1)

-- ============================================================
-- MAUL QUEUE
-- ============================================================
local maulBG = Frame:CreateTexture(nil, "BACKGROUND")
maulBG:SetSize(244, 22)
maulBG:SetPoint("TOPLEFT", Frame, "TOPLEFT", 8, -66)
maulBG:SetColorTexture(C.locked[1], C.locked[2], C.locked[3], 0.7)

local maulText = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
maulText:SetPoint("CENTER", maulBG, "CENTER", 0, 0)
maulText:SetText("MAUL — nicht aktiv")
maulText:SetTextColor(0.5, 0.5, 0.5)

-- ============================================================
-- BUFF/DEBUFF ZEILE
-- ============================================================
local function MakeRow(yOffset, labelStr)
    local lbl = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("TOPLEFT", Frame, "TOPLEFT", 8, yOffset)
    lbl:SetText(labelStr)
    lbl:SetTextColor(0.65, 0.65, 0.65)

    local val = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    val:SetPoint("TOPLEFT", Frame, "TOPLEFT", 100, yOffset)
    val:SetText("---")
    val:SetTextColor(0.5, 0.5, 0.5)
    return val
end

local ffValue   = MakeRow(-96,  "Faerie Fire:")
local demoValue = MakeRow(-112, "Demo Roar:")

-- ============================================================
-- COOLDOWN RASTER (dynamisch — zeigt nur bekannte Spells)
-- ============================================================
local cdFrames = {}
local CD_COLS = 4
local CD_SIZE = 58
local CD_GAP  = 2
local CD_START_Y = -130

for i, key in ipairs(CD_SLOTS) do
    local col = (i - 1) % CD_COLS
    local row = math.floor((i - 1) / CD_COLS)

    local f = CreateFrame("Frame", nil, Frame)
    f:SetSize(CD_SIZE, 44)
    f:SetPoint("TOPLEFT", Frame, "TOPLEFT",
        8 + col * (CD_SIZE + CD_GAP),
        CD_START_Y - row * 46)

    local fbg = f:CreateTexture(nil, "BACKGROUND")
    fbg:SetAllPoints()
    fbg:SetColorTexture(0.08, 0.08, 0.08, 0.95)
    f.bg = fbg

    local lbl = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("BOTTOM", f, "BOTTOM", 0, 3)
    lbl:SetText(SPELL_GROUPS[key].label)
    lbl:SetTextColor(0.7, 0.7, 0.7)
    f.lbl = lbl

    local timer = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    timer:SetPoint("CENTER", f, "CENTER", 0, 5)
    timer:SetText("?")
    timer:SetTextColor(0.4, 0.4, 0.4)
    f.timer = timer

    f.groupKey = key
    cdFrames[i] = f
end

-- Rahmen-Größe dynamisch an CD-Slots anpassen
local rows = math.ceil(#CD_SLOTS / CD_COLS)
Frame:SetSize(260, 140 + rows * 46 + 16)

-- ============================================================
-- FOOTER
-- ============================================================
local footerText = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
footerText:SetPoint("BOTTOM", Frame, "BOTTOM", 0, 4)
footerText:SetText("Ziehen: Drag | /gh lock  /gh help")
footerText:SetTextColor(0.28, 0.28, 0.28)

-- ============================================================
-- HILFSFUNKTIONEN
-- ============================================================
local function GetTargetDebuffRemaining(spellID)
    local spellName = GetSpellInfo(spellID)
    if not spellName then return nil end
    for i = 1, 40 do
        local name, _, _, _, _, duration, exp = UnitDebuff("target", i)
        if not name then break end
        if name == spellName then
            return exp and exp > 0 and (exp - GetTime()) or math.huge
        end
    end
    return nil
end

local function GetPlayerBuffRemaining(spellID)
    local spellName = GetSpellInfo(spellID)
    if not spellName then return nil end
    for i = 1, 40 do
        local name, _, _, _, _, duration, exp = UnitBuff("player", i)
        if not name then break end
        if name == spellName then
            return exp and exp > 0 and (exp - GetTime()) or math.huge
        end
    end
    return nil
end

local function IsInBearForm()
    for _, id in ipairs(BEAR_FORM_IDS) do
        if GetPlayerBuffRemaining(id) then return true, false end
    end
    for _, id in ipairs(DIRE_BEAR_IDS) do
        if GetPlayerBuffRemaining(id) then return true, true end
    end
    return false, false
end

local function GetGroupCooldown(groupKey)
    local cache = spellCache[groupKey]
    if not cache then return nil end
    local start, dur = GetSpellCooldown(cache.highestID)
    if not start or start == 0 then return 0 end
    local rem = (start + dur) - GetTime()
    return rem > 0 and rem or 0
end

-- Faerie Fire: prüfe alle bekannten Ränge auf dem Ziel
local function GetFaerieFireOnTarget()
    local cache = spellCache["FAERIE_FIRE"]
    if not cache then return nil end
    for id in pairs(cache.allKnownIDs) do
        local rem = GetTargetDebuffRemaining(id)
        if rem then return rem end
    end
    return nil
end

local function GetDemoRoarOnTarget()
    local cache = spellCache["DEMO_ROAR"]
    if not cache then return nil end
    for id in pairs(cache.allKnownIDs) do
        local rem = GetTargetDebuffRemaining(id)
        if rem then return rem end
    end
    return nil
end

-- ============================================================
-- MAUL TRACKING (Combat Log)
-- ============================================================
local State = { maulQueued = false }

local maulIDs = {}
local function RebuildMaulIDs()
    maulIDs = {}
    local cache = spellCache["MAUL"]
    if cache then
        for id in pairs(cache.allKnownIDs) do
            maulIDs[id] = true
        end
    end
end

-- ============================================================
-- EVENTS
-- ============================================================
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_LOGIN")
EventFrame:RegisterEvent("PLAYER_LEVEL_UP")
EventFrame:RegisterEvent("SPELLS_CHANGED")
EventFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

EventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        RebuildSpellCache()
        RebuildMaulIDs()
        print(string.format("|cff00cc44GuardianHelper|r v%s geladen — Viel Erfolg beim Tanken, Bär! 🐻", GH_VERSION))
        print("Hilfe: |cffffffff/gh help|r")

    elseif event == "PLAYER_LEVEL_UP" then
        local newLevel = ...
        -- Cache neu aufbauen nach kurzem Delay (Spellbook braucht einen Moment)
        C_Timer and C_Timer.After(0.5, function()
            RebuildSpellCache()
            RebuildMaulIDs()
            UpdateAllActionBars()
            print(string.format("|cff00cc44GuardianHelper:|r Level %d erreicht — Aktionsleisten geprüft!", newLevel))
        end) or (function()
            -- Fallback ohne C_Timer (sehr altes API)
            RebuildSpellCache()
            RebuildMaulIDs()
            UpdateAllActionBars()
        end)()

    elseif event == "SPELLS_CHANGED" then
        RebuildSpellCache()
        RebuildMaulIDs()

    elseif event == "LEARNED_SPELL_IN_TAB" then
        -- Neuer Spell gelernt → sofort Aktionsleiste updaten
        C_Timer and C_Timer.After(0.3, function()
            RebuildSpellCache()
            RebuildMaulIDs()
            UpdateAllActionBars()
        end) or (function()
            RebuildSpellCache()
            RebuildMaulIDs()
            UpdateAllActionBars()
        end)()

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, srcGUID, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if srcGUID ~= UnitGUID("player") then return end

        if subEvent == "SPELL_CAST_START" and maulIDs[spellID] then
            State.maulQueued = true
        elseif (subEvent == "SPELL_DAMAGE" or subEvent == "SPELL_MISSED") and maulIDs[spellID] then
            State.maulQueued = false
        end
    end
end)

-- ============================================================
-- UPDATE LOOP
-- ============================================================
local throttle = 0
local RATE     = 0.15

Frame:SetScript("OnUpdate", function(self, elapsed)
    throttle = throttle + elapsed
    if throttle < RATE then return end
    throttle = 0

    -- === RAGE ===
    local rage    = UnitPower("player", 1)
    local rageMax = UnitPowerMax("player", 1)
    rageValText:SetText(rage .. "/" .. rageMax)

    local pct = rageMax > 0 and (rage / rageMax) or 0
    rageBarFill:SetWidth(math.max(244 * pct, 1))
    if pct >= 0.65 then
        rageBarFill:SetColorTexture(0.2, 0.85, 0.2, 1)
    elseif pct >= 0.30 then
        rageBarFill:SetColorTexture(C.rage[1], C.rage[2], C.rage[3], 1)
    else
        rageBarFill:SetColorTexture(0.9, 0.15, 0.15, 1)
    end

    -- === BEAR FORM ===
    local inBear, isDire = IsInBearForm()
    if inBear then
        local label = isDire and "🐻 Dire Bear Form" or "🐻 Bärengestalt"
        headerBg:SetColorTexture(C.bear[1], C.bear[2], C.bear[3], 1)
        headerText:SetText(label .. " — aktiv")
        headerText:SetTextColor(1, 0.88, 0.6)
    else
        headerBg:SetColorTexture(0.7, 0.05, 0.05, 1)
        headerText:SetText("⚠  NICHT IN BÄRENFORM!  ⚠")
        headerText:SetTextColor(1, 0.9, 0.9)
    end

    -- === MAUL QUEUE ===
    if State.maulQueued then
        maulBG:SetColorTexture(C.maul_on[1], C.maul_on[2], 0, 0.88)
        maulText:SetText("⚔  MAUL — eingereiht ✓")
        maulText:SetTextColor(0, 0, 0)
    else
        maulBG:SetColorTexture(C.locked[1], C.locked[2], C.locked[3], 0.65)
        maulText:SetText("MAUL — nicht aktiv")
        maulText:SetTextColor(0.5, 0.5, 0.5)
    end

    -- === FAERIE FIRE ===
    if UnitExists("target") then
        local ffRem = GetFaerieFireOnTarget()
        local ffKnown = spellCache["FAERIE_FIRE"] ~= nil
        if not ffKnown then
            ffValue:SetText("kein Talent")
            ffValue:SetTextColor(0.4, 0.4, 0.4)
        elseif ffRem then
            if ffRem == math.huge then
                ffValue:SetText("∞ aktiv")
                ffValue:SetTextColor(C.ff_up[1], C.ff_up[2], C.ff_up[3])
            elseif ffRem < 4 then
                ffValue:SetText(string.format("%.1fs !", ffRem))
                ffValue:SetTextColor(C.warn[1], C.warn[2], 0)
            else
                ffValue:SetText(string.format("%.0fs", ffRem))
                ffValue:SetTextColor(C.ff_up[1], C.ff_up[2], C.ff_up[3])
            end
        else
            ffValue:SetText("FEHLT!")
            ffValue:SetTextColor(C.ff_down[1], C.ff_down[2], C.ff_down[3])
        end
    else
        ffValue:SetText("kein Ziel")
        ffValue:SetTextColor(0.38, 0.38, 0.38)
    end

    -- === DEMO ROAR ===
    if UnitExists("target") then
        local dRem = GetDemoRoarOnTarget()
        if dRem then
            if dRem == math.huge then
                demoValue:SetText("aktiv")
                demoValue:SetTextColor(C.ready[1], C.ready[2], C.ready[3])
            elseif dRem < 3 then
                demoValue:SetText(string.format("%.1fs !", dRem))
                demoValue:SetTextColor(C.warn[1], C.warn[2], 0)
            else
                demoValue:SetText(string.format("%.0fs", dRem))
                demoValue:SetTextColor(C.ready[1], C.ready[2], C.ready[3])
            end
        else
            demoValue:SetText("FEHLT!")
            demoValue:SetTextColor(C.warn[1], C.warn[2], 0)
        end
    else
        demoValue:SetText("kein Ziel")
        demoValue:SetTextColor(0.38, 0.38, 0.38)
    end

    -- === COOLDOWNS ===
    for _, f in ipairs(cdFrames) do
        local key   = f.groupKey
        local group = SPELL_GROUPS[key]
        local cache = spellCache[key]

        if not cache then
            -- Spell noch nicht gelernt — zeige niedrigstes Level
            local minLevel = group.ranks[1].level
            f.timer:SetText("Lvl " .. minLevel)
            f.timer:SetTextColor(0.30, 0.30, 0.30)
            f.bg:SetColorTexture(0.06, 0.06, 0.06, 0.95)
            f.lbl:SetTextColor(0.35, 0.35, 0.35)
        else
            f.lbl:SetTextColor(0.85, 0.85, 0.85)
            local cd = GetGroupCooldown(key)
            if cd == nil or cd <= 0 then
                f.timer:SetText("✓")
                f.timer:SetTextColor(C.ready[1], C.ready[2], C.ready[3])
                f.bg:SetColorTexture(0.04, 0.20, 0.04, 0.95)
            elseif cd < 5 then
                f.timer:SetText(string.format("%.1f", cd))
                f.timer:SetTextColor(C.warn[1], C.warn[2], 0)
                f.bg:SetColorTexture(0.22, 0.17, 0.02, 0.95)
            else
                f.timer:SetText(string.format("%d", math.ceil(cd)))
                f.timer:SetTextColor(C.cd[1], C.cd[2], C.cd[3])
                f.bg:SetColorTexture(0.08, 0.08, 0.08, 0.95)
            end
        end
    end
end)

-- ============================================================
-- SLASH COMMANDS
-- ============================================================
local ghLocked = false

SLASH_GH1 = "/gh"
SLASH_GH2 = "/guardianhelper"
SlashCmdList["GH"] = function(msg)
    msg = strtrim(msg:lower())

    if msg == "lock" then
        ghLocked = not ghLocked
        Frame:SetMovable(not ghLocked)
        Frame:EnableMouse(not ghLocked)
        footerText:SetText(ghLocked and "Frame gesperrt — /gh lock zum Entsperren" or "Ziehen: Drag | /gh lock  /gh help")
        print("|cff00cc44GuardianHelper:|r " .. (ghLocked and "Frame gesperrt." or "Frame entsperrt."))

    elseif msg == "hide" then
        Frame:Hide()
        print("|cff00cc44GuardianHelper:|r Versteckt. Tippe |cffffffff/gh show|r zum Anzeigen.")

    elseif msg == "show" then
        Frame:Show()

    elseif msg == "reset" then
        Frame:ClearAllPoints()
        Frame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
        print("|cff00cc44GuardianHelper:|r Position zurückgesetzt.")

    elseif msg == "update" then
        print("|cff00cc44GuardianHelper:|r Aktionsleisten werden manuell aktualisiert...")
        RebuildSpellCache()
        RebuildMaulIDs()
        UpdateAllActionBars()

    elseif msg == "spells" or msg == "status" then
        print("|cff00cc44GuardianHelper — Bekannte Spells:|r")
        for groupKey, group in pairs(SPELL_GROUPS) do
            local cache = spellCache[groupKey]
            if cache then
                local name = GetSpellInfo(cache.highestID)
                print(string.format("  |cffffffff%s|r: %s (Rang bis Lvl %d, AutoUpdate: %s)",
                    group.label,
                    name or "?",
                    cache.highestLevel,
                    group.autoUpdate and "|cff00cc44Ja|r" or "|cffaaaaaa-|r"
                ))
            else
                print(string.format("  |cff666666%s|r: noch nicht gelernt (ab Lvl %d)", group.label, group.ranks[1].level))
            end
        end

    elseif msg == "help" or msg == "" then
        print("|cff00cc44GuardianHelper v" .. GH_VERSION .. " — Befehle:|r")
        print("  |cffffffff/gh lock|r    — Frame sperren/entsperren")
        print("  |cffffffff/gh hide|r    — Addon verstecken")
        print("  |cffffffff/gh show|r    — Addon anzeigen")
        print("  |cffffffff/gh reset|r   — Position zurücksetzen")
        print("  |cffffffff/gh update|r  — Aktionsleisten jetzt aktualisieren")
        print("  |cffffffff/gh status|r  — Bekannte Spells anzeigen")
    end
end
