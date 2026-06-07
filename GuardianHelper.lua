-- ============================================================
-- GuardianHelper v3.0 — Redesign
-- Guardian Druid Tank Addon — Level 1-70 (Classic & TBC)
-- Design: Dark / Emerald Green / Gold — inspired by the logo
-- ============================================================

local GH_VERSION = "3.0.0"

-- ============================================================
-- SPELL-GRUPPEN
-- ============================================================
local SPELL_GROUPS = {
    MAUL           = { label="Maul",    autoUpdate=true,  ranks={{id=6807,level=10},{id=8972,level=18},{id=9745,level=26},{id=9880,level=34},{id=9881,level=42},{id=26996,level=50},{id=26997,level=58},{id=48479,level=62},{id=48480,level=70}} },
    SWIPE          = { label="Swipe",   autoUpdate=true,  ranks={{id=779,level=16},{id=780,level=24},{id=769,level=34},{id=9754,level=44},{id=9908,level=54},{id=48562,level=62}} },
    BASH           = { label="Bash",    autoUpdate=true,  ranks={{id=5211,level=14},{id=6798,level=22},{id=8983,level=32},{id=25515,level=42}} },
    GROWL          = { label="Growl",   autoUpdate=false, ranks={{id=6795,level=10}} },
    ENRAGE         = { label="Enrage",  autoUpdate=false, ranks={{id=5229,level=14}} },
    DEMO_ROAR      = { label="D.Roar",  autoUpdate=true,  ranks={{id=99,level=8},{id=1735,level=16},{id=9490,level=24},{id=9747,level=32},{id=9898,level=42},{id=26998,level=52}} },
    FAERIE_FIRE    = { label="F.Fire",  autoUpdate=false, ranks={{id=16857,level=20},{id=17390,level=30},{id=17391,level=40},{id=17392,level=50},{id=27011,level=60}} },
    FRENZIED_REGEN = { label="F.Reg",   autoUpdate=false, ranks={{id=22842,level=36},{id=22895,level=46},{id=22896,level=56},{id=26999,level=66}} },
    BARKSKIN       = { label="Bark",    autoUpdate=false, ranks={{id=22812,level=44}} },
    MANGLE_BEAR    = { label="Mangle",  autoUpdate=true,  ranks={{id=33878,level=60},{id=33986,level=66}} },
    LACERATE       = { label="Lacer.",  autoUpdate=true,  ranks={{id=33745,level=66}} },
}

local CD_SLOTS = { "BASH","GROWL","ENRAGE","FRENZIED_REGEN","BARKSKIN","MANGLE_BEAR","LACERATE" }

local BEAR_FORM_IDS = {5487}
local DIRE_BEAR_IDS = {9634}

-- ============================================================
-- DESIGN FARBEN (Logo: schwarz, smaragdgrün, gold)
-- ============================================================
local D = {
    bg          = {0.04, 0.05, 0.04, 0.94},
    bg2         = {0.07, 0.09, 0.07, 1.00},
    green       = {0.10, 0.90, 0.25},
    green_dim   = {0.05, 0.45, 0.12},
    gold        = {0.85, 0.70, 0.15},
    gold_dim    = {0.45, 0.37, 0.08},
    red         = {0.90, 0.12, 0.08},
    red_dim     = {0.30, 0.04, 0.02},
    orange      = {0.95, 0.55, 0.05},
    white       = {0.92, 0.92, 0.88},
    grey        = {0.35, 0.38, 0.35},
    dark        = {0.12, 0.14, 0.12, 1.00},
    border_on   = {0.10, 0.85, 0.25, 0.90},
    border_off  = {0.08, 0.28, 0.10, 0.80},
    border_warn = {0.90, 0.12, 0.08, 0.90},
}

-- ============================================================
-- HILFSFUNKTIONEN
-- ============================================================
local function Tex(parent, r, g, b, a)
    local t = parent:CreateTexture(nil, "BACKGROUND")
    t:SetColorTexture(r, g, b, a or 1)
    return t
end

local function Label(parent, text, size, r, g, b)
    local f = parent:CreateFontString(nil, "OVERLAY")
    f:SetFont("Fonts\\FRIZQT__.TTF", size or 9, "OUTLINE")
    f:SetText(text or "")
    f:SetTextColor(r or 1, g or 1, b or 1)
    return f
end

local function MakeSeparator(parent, yOff)
    local s = parent:CreateTexture(nil, "ARTWORK")
    s:SetSize(174, 1)
    s:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, yOff)
    s:SetColorTexture(D.green_dim[1], D.green_dim[2], D.green_dim[3], 0.6)
    return s
end

-- ============================================================
-- HAUPTFRAME — kompakt, 184px breit
-- ============================================================
local W = 184
local Frame = CreateFrame("Frame", "GuardianHelperFrame", UIParent)
Frame:SetSize(W, 10) -- Höhe dynamisch
Frame:SetPoint("CENTER", UIParent, "CENTER", 350, 0)
Frame:SetMovable(true)
Frame:EnableMouse(true)
Frame:RegisterForDrag("LeftButton")
Frame:SetScript("OnDragStart", function(s) s:StartMoving() end)
Frame:SetScript("OnDragStop",  function(s) s:StopMovingOrSizing() end)
Frame:SetFrameStrata("MEDIUM")
Frame:SetFrameLevel(20)

-- Hintergrund
local mainBg = Tex(Frame, D.bg[1], D.bg[2], D.bg[3], D.bg[4])
mainBg:SetAllPoints()

-- Äußerer Rahmen (grüne Linie)
local outerBorder = Frame:CreateTexture(nil, "BORDER")
outerBorder:SetAllPoints()
outerBorder:SetColorTexture(D.border_on[1], D.border_on[2], D.border_on[3], D.border_on[4])

-- Innerer Hintergrund (überdeckt Border bis auf 1px Rand)
local innerBg = Frame:CreateTexture(nil, "BACKGROUND")
innerBg:SetPoint("TOPLEFT", Frame, "TOPLEFT", 1, -1)
innerBg:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", -1, 1)
innerBg:SetColorTexture(D.bg[1], D.bg[2], D.bg[3], D.bg[4])

-- ============================================================
-- HEADER — "GUARDIAN HELPER"
-- ============================================================
local headerBg = Tex(Frame, D.bg2[1], D.bg2[2], D.bg2[3], 1)
headerBg:SetSize(W - 2, 18)
headerBg:SetPoint("TOPLEFT", Frame, "TOPLEFT", 1, -1)

-- Grüner Akzentbalken links im Header
local headerAccent = Tex(Frame, D.green[1], D.green[2], D.green[3], 0.9)
headerAccent:SetSize(3, 18)
headerAccent:SetPoint("TOPLEFT", Frame, "TOPLEFT", 1, -1)

local headerTitle = Label(Frame, "🐻  GUARDIAN HELPER", 8, D.gold[1], D.gold[2], D.gold[3])
headerTitle:SetPoint("LEFT", Frame, "TOPLEFT", 14, -10)

local headerStatus = Label(Frame, "●", 8, D.green[1], D.green[2], D.green[3])
headerStatus:SetPoint("RIGHT", Frame, "TOPRIGHT", -6, -10)

MakeSeparator(Frame, -19)

-- ============================================================
-- RAGE BAR — schlank & elegant
-- ============================================================
local rageLabel = Label(Frame, "RAGE", 7, D.gold[1], D.gold[2], D.gold[3])
rageLabel:SetPoint("TOPLEFT", Frame, "TOPLEFT", 7, -27)

local rageVal = Label(Frame, "0", 7, D.white[1], D.white[2], D.white[3])
rageVal:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -6, -27)

-- Bar Track
local rageTrack = Tex(Frame, D.dark[1], D.dark[2], D.dark[3], 1)
rageTrack:SetSize(W - 12, 6)
rageTrack:SetPoint("TOPLEFT", Frame, "TOPLEFT", 6, -37)

-- Bar Fill
local rageFill = Tex(Frame, D.red[1], D.red[2], D.red[3], 1)
rageFill:SetSize(W - 12, 6)
rageFill:SetPoint("TOPLEFT", rageTrack, "TOPLEFT", 0, 0)

MakeSeparator(Frame, -45)

-- ============================================================
-- MAUL INDICATOR — kompakt, ein Balken
-- ============================================================
local maulBg = Tex(Frame, D.dark[1], D.dark[2], D.dark[3], 1)
maulBg:SetSize(W - 2, 14)
maulBg:SetPoint("TOPLEFT", Frame, "TOPLEFT", 1, -47)

local maulDot = Tex(Frame, D.grey[1], D.grey[2], D.grey[3], 1)
maulDot:SetSize(4, 10)
maulDot:SetPoint("LEFT", Frame, "TOPLEFT", 6, -54)

local maulText = Label(Frame, "Maul — nicht aktiv", 8, D.grey[1], D.grey[2], D.grey[3])
maulText:SetPoint("LEFT", Frame, "TOPLEFT", 14, -54)

MakeSeparator(Frame, -62)

-- ============================================================
-- DEBUFF ZEILE — Faerie Fire & Demo Roar nebeneinander
-- ============================================================
-- FF
local ffDot = Tex(Frame, D.grey[1], D.grey[2], D.grey[3], 1)
ffDot:SetSize(4, 4)
ffDot:SetPoint("TOPLEFT", Frame, "TOPLEFT", 7, -70)

local ffLabel = Label(Frame, "FF", 7, D.gold_dim[1], D.gold_dim[2], D.gold_dim[3])
ffLabel:SetPoint("TOPLEFT", Frame, "TOPLEFT", 14, -68)

local ffVal = Label(Frame, "---", 8, D.grey[1], D.grey[2], D.grey[3])
ffVal:SetPoint("TOPLEFT", Frame, "TOPLEFT", 28, -68)

-- Trennlinie vertikal
local vSep = Frame:CreateTexture(nil, "ARTWORK")
vSep:SetSize(1, 10)
vSep:SetPoint("TOPLEFT", Frame, "TOPLEFT", (W/2), -65)
vSep:SetColorTexture(D.green_dim[1], D.green_dim[2], D.green_dim[3], 0.5)

-- Demo Roar
local drDot = Tex(Frame, D.grey[1], D.grey[2], D.grey[3], 1)
drDot:SetSize(4, 4)
drDot:SetPoint("TOPLEFT", Frame, "TOPLEFT", (W/2)+4, -70)

local drLabel = Label(Frame, "DR", 7, D.gold_dim[1], D.gold_dim[2], D.gold_dim[3])
drLabel:SetPoint("TOPLEFT", Frame, "TOPLEFT", (W/2)+11, -68)

local drVal = Label(Frame, "---", 8, D.grey[1], D.grey[2], D.grey[3])
drVal:SetPoint("TOPLEFT", Frame, "TOPLEFT", (W/2)+25, -68)

MakeSeparator(Frame, -77)

-- ============================================================
-- COOLDOWN RASTER — kompakte Quadrate
-- ============================================================
local CD_SIZE = 22
local CD_GAP  = 2
local CD_START_X = 6
local CD_START_Y = -80
local CD_PER_ROW = 7

local cdFrames = {}
for i, key in ipairs(CD_SLOTS) do
    local col = (i-1) % CD_PER_ROW
    local row = math.floor((i-1) / CD_PER_ROW)

    local f = CreateFrame("Frame", nil, Frame)
    f:SetSize(CD_SIZE, CD_SIZE + 8)
    f:SetPoint("TOPLEFT", Frame, "TOPLEFT",
        CD_START_X + col * (CD_SIZE + CD_GAP),
        CD_START_Y - row * (CD_SIZE + CD_GAP + 8))

    -- Hintergrund
    local fbg = f:CreateTexture(nil, "BACKGROUND")
    fbg:SetAllPoints()
    fbg:SetColorTexture(D.dark[1], D.dark[2], D.dark[3], 1)
    f.bg = fbg

    -- Rand
    local fBorder = f:CreateTexture(nil, "BORDER")
    fBorder:SetAllPoints()
    fBorder:SetColorTexture(D.green_dim[1], D.green_dim[2], D.green_dim[3], 0.4)
    f.border = fBorder

    -- Inner bg
    local fInner = f:CreateTexture(nil, "BACKGROUND")
    fInner:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
    fInner:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)
    fInner:SetColorTexture(D.dark[1], D.dark[2], D.dark[3], 1)

    -- Label unten
    local lbl = f:CreateFontString(nil, "OVERLAY")
    lbl:SetFont("Fonts\\FRIZQT__.TTF", 6, "OUTLINE")
    lbl:SetPoint("BOTTOM", f, "BOTTOM", 0, 1)
    lbl:SetText(SPELL_GROUPS[key].label)
    lbl:SetTextColor(D.gold_dim[1], D.gold_dim[2], D.gold_dim[3])
    f.lbl = lbl

    -- Timer
    local timer = f:CreateFontString(nil, "OVERLAY")
    timer:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
    timer:SetPoint("CENTER", f, "CENTER", 0, 4)
    timer:SetText("?")
    timer:SetTextColor(D.grey[1], D.grey[2], D.grey[3])
    f.timer = timer

    f.groupKey = key
    f.learnLevel = SPELL_GROUPS[key].ranks[1].level
    cdFrames[i] = f
end

-- Dynamische Framehöhe
local cdRows = math.ceil(#CD_SLOTS / CD_PER_ROW)
local totalH = 80 + cdRows * (CD_SIZE + CD_GAP + 8) + 10
Frame:SetHeight(totalH)

-- Footer
local footer = Label(Frame, "/gh lock  ·  /gh help", 6, D.green_dim[1], D.green_dim[2], D.green_dim[3])
footer:SetPoint("BOTTOM", Frame, "BOTTOM", 0, 3)

-- ============================================================
-- SPELL CACHE
-- ============================================================
local spellCache = {}

local function RebuildSpellCache()
    for k in pairs(spellCache) do spellCache[k] = nil end
    local i = 1
    while true do
        local name = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not name then break end
        local _, spellID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
        for groupKey, group in pairs(SPELL_GROUPS) do
            for _, rd in ipairs(group.ranks) do
                if rd.id == spellID then
                    if not spellCache[groupKey] then
                        spellCache[groupKey] = { highestID=spellID, highestLevel=rd.level, highestSlot=i, allKnownIDs={} }
                    elseif rd.level > spellCache[groupKey].highestLevel then
                        spellCache[groupKey].highestID = spellID
                        spellCache[groupKey].highestLevel = rd.level
                        spellCache[groupKey].highestSlot = i
                    end
                    spellCache[groupKey].allKnownIDs[spellID] = true
                end
            end
        end
        i = i + 1
    end
end

-- ============================================================
-- ACTION BAR UPDATE
-- ============================================================
local function UpdateActionBarsForGroup(groupKey)
    local group = SPELL_GROUPS[groupKey]
    if not group.autoUpdate then return end
    local cache = spellCache[groupKey]
    if not cache then return end
    local newID, newSlot = cache.highestID, cache.highestSlot
    local updated = 0
    for slot = 1, 120 do
        local aType, aID = GetActionInfo(slot)
        if aType == "spell" and aID ~= newID and cache.allKnownIDs[aID] then
            ClearCursor()
            PickupSpellBookItem(newSlot, BOOKTYPE_SPELL)
            PlaceAction(slot)
            ClearCursor()
            updated = updated + 1
        end
    end
    if updated > 0 then
        local n = GetSpellInfo(newID)
        print("|cff1aee3aGuardianHelper:|r " .. (n or groupKey) .. " aktualisiert (" .. updated .. "x)")
    end
end

local function UpdateAllActionBars()
    for k in pairs(SPELL_GROUPS) do UpdateActionBarsForGroup(k) end
end

-- ============================================================
-- MAUL TRACKING
-- ============================================================
local State = { maulQueued=false }
local maulIDs = {}

local function RebuildMaulIDs()
    maulIDs = {}
    local c = spellCache["MAUL"]
    if c then for id in pairs(c.allKnownIDs) do maulIDs[id] = true end end
end

-- ============================================================
-- HILFSFUNKTIONEN UPDATE
-- ============================================================
local function GetTargetDebuffRemaining(spellID)
    local spellName = GetSpellInfo(spellID)
    if not spellName then return nil end
    for i = 1, 40 do
        local name, _, _, _, _, dur, exp = UnitDebuff("target", i)
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
        local name, _, _, _, _, dur, exp = UnitBuff("player", i)
        if not name then break end
        if name == spellName then
            return exp and exp > 0 and (exp - GetTime()) or math.huge
        end
    end
    return nil
end

local function IsInBearForm()
    for _, id in ipairs(BEAR_FORM_IDS) do if GetPlayerBuffRemaining(id) then return true, false end end
    for _, id in ipairs(DIRE_BEAR_IDS) do if GetPlayerBuffRemaining(id) then return true, true  end end
    return false, false
end

local function GetDebuffOnTarget(groupKey)
    local c = spellCache[groupKey]
    if not c then return nil end
    for id in pairs(c.allKnownIDs) do
        local r = GetTargetDebuffRemaining(id)
        if r then return r end
    end
    return nil
end

local function GetGroupCD(groupKey)
    local c = spellCache[groupKey]
    if not c then return nil end
    local start, dur = GetSpellCooldown(c.highestID)
    if not start or start == 0 then return 0 end
    local rem = (start + dur) - GetTime()
    return rem > 0 and rem or 0
end

-- ============================================================
-- EVENTS
-- ============================================================
local EF = CreateFrame("Frame")
EF:RegisterEvent("PLAYER_LOGIN")
EF:RegisterEvent("PLAYER_LEVEL_UP")
EF:RegisterEvent("SPELLS_CHANGED")
EF:RegisterEvent("LEARNED_SPELL_IN_TAB")
EF:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

EF:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        RebuildSpellCache(); RebuildMaulIDs()
        print("|cff1aee3aGuardianHelper|r v"..GH_VERSION.." — Viel Erfolg Bär! 🐻  |cffaaaaaa/gh help|r")

    elseif event == "PLAYER_LEVEL_UP" then
        local lvl = ...
        local df = CreateFrame("Frame"); local el = 0
        df:SetScript("OnUpdate", function(s,e) el=el+e; if el>=0.5 then s:SetScript("OnUpdate",nil); RebuildSpellCache(); RebuildMaulIDs(); UpdateAllActionBars(); print("|cff1aee3aGuardianHelper:|r Level "..lvl.." — Bars aktualisiert!") end end)

    elseif event == "SPELLS_CHANGED" then
        RebuildSpellCache(); RebuildMaulIDs()

    elseif event == "LEARNED_SPELL_IN_TAB" then
        local df = CreateFrame("Frame"); local el = 0
        df:SetScript("OnUpdate", function(s,e) el=el+e; if el>=0.3 then s:SetScript("OnUpdate",nil); RebuildSpellCache(); RebuildMaulIDs(); UpdateAllActionBars() end end)

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, srcGUID, _, _, _, _, _, _, _, spellID = ...
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
Frame:SetScript("OnUpdate", function(self, elapsed)
    throttle = throttle + elapsed
    if throttle < 0.12 then return end
    throttle = 0

    -- RAGE
    local rage    = UnitPower("player", 1)
    local rageMax = UnitPowerMax("player", 1)
    if rageMax == 0 then rageMax = 100 end
    local pct = rage / rageMax

    rageVal:SetText(rage)
    rageFill:SetWidth(math.max((W - 12) * pct, 1))

    if pct >= 0.65 then
        rageFill:SetColorTexture(D.green[1], D.green[2], D.green[3], 1)
        rageVal:SetTextColor(D.green[1], D.green[2], D.green[3])
    elseif pct >= 0.30 then
        rageFill:SetColorTexture(D.orange[1], D.orange[2], D.orange[3], 1)
        rageVal:SetTextColor(D.orange[1], D.orange[2], D.orange[3])
    else
        rageFill:SetColorTexture(D.red[1], D.red[2], D.red[3], 1)
        rageVal:SetTextColor(D.red[1], D.red[2], D.red[3])
    end

    -- BEAR FORM
    local inBear, isDire = IsInBearForm()
    if inBear then
        outerBorder:SetColorTexture(D.border_on[1], D.border_on[2], D.border_on[3], D.border_on[4])
        headerStatus:SetText("●")
        headerStatus:SetTextColor(D.green[1], D.green[2], D.green[3])
        headerAccent:SetColorTexture(D.green[1], D.green[2], D.green[3], 1)
        headerTitle:SetText(isDire and "🐻  DIRE BEAR" or "🐻  BEAR FORM")
        headerTitle:SetTextColor(D.gold[1], D.gold[2], D.gold[3])
    else
        outerBorder:SetColorTexture(D.border_warn[1], D.border_warn[2], D.border_warn[3], D.border_warn[4])
        headerStatus:SetText("⚠")
        headerStatus:SetTextColor(D.red[1], D.red[2], D.red[3])
        headerAccent:SetColorTexture(D.red[1], D.red[2], D.red[3], 1)
        headerTitle:SetText("  KEINE BÄRENFORM")
        headerTitle:SetTextColor(D.red[1], D.red[2], D.red[3])
    end

    -- MAUL
    if State.maulQueued then
        maulBg:SetColorTexture(D.orange[1]*0.3, D.orange[2]*0.15, 0, 1)
        maulDot:SetColorTexture(D.orange[1], D.orange[2], D.orange[3], 1)
        maulText:SetText("⚔  MAUL — eingereiht")
        maulText:SetTextColor(D.orange[1], D.orange[2], D.orange[3])
    else
        maulBg:SetColorTexture(D.dark[1], D.dark[2], D.dark[3], 1)
        maulDot:SetColorTexture(D.grey[1], D.grey[2], D.grey[3], 0.5)
        maulText:SetText("Maul — nicht aktiv")
        maulText:SetTextColor(D.grey[1], D.grey[2], D.grey[3])
    end

    -- FAERIE FIRE
    if UnitExists("target") then
        local ffR = GetDebuffOnTarget("FAERIE_FIRE")
        local ffKnown = spellCache["FAERIE_FIRE"] ~= nil
        if not ffKnown then
            ffDot:SetColorTexture(D.grey[1], D.grey[2], D.grey[3], 0.3)
            ffVal:SetText("--")
            ffVal:SetTextColor(D.grey[1], D.grey[2], D.grey[3])
        elseif ffR then
            ffDot:SetColorTexture(D.green[1], D.green[2], D.green[3], 1)
            local txt = ffR == math.huge and "∞" or string.format("%.0fs", ffR)
            ffVal:SetText(txt)
            local col = (ffR ~= math.huge and ffR < 4) and D.orange or D.green
            ffVal:SetTextColor(col[1], col[2], col[3])
        else
            ffDot:SetColorTexture(D.red[1], D.red[2], D.red[3], 1)
            ffVal:SetText("!")
            ffVal:SetTextColor(D.red[1], D.red[2], D.red[3])
        end
    else
        ffDot:SetColorTexture(D.grey[1], D.grey[2], D.grey[3], 0.3)
        ffVal:SetText("---")
        ffVal:SetTextColor(D.grey[1], D.grey[2], D.grey[3])
    end

    -- DEMO ROAR
    if UnitExists("target") then
        local drR = GetDebuffOnTarget("DEMO_ROAR")
        if drR then
            drDot:SetColorTexture(D.green[1], D.green[2], D.green[3], 1)
            local txt = drR == math.huge and "∞" or string.format("%.0fs", drR)
            drVal:SetText(txt)
            local col = (drR ~= math.huge and drR < 3) and D.orange or D.green
            drVal:SetTextColor(col[1], col[2], col[3])
        else
            drDot:SetColorTexture(D.red[1], D.red[2], D.red[3], 1)
            drVal:SetText("!")
            drVal:SetTextColor(D.red[1], D.red[2], D.red[3])
        end
    else
        drDot:SetColorTexture(D.grey[1], D.grey[2], D.grey[3], 0.3)
        drVal:SetText("---")
        drVal:SetTextColor(D.grey[1], D.grey[2], D.grey[3])
    end

    -- COOLDOWNS
    for _, f in ipairs(cdFrames) do
        local key   = f.groupKey
        local cache = spellCache[key]
        if not cache then
            f.border:SetColorTexture(D.grey[1]*0.3, D.grey[2]*0.3, D.grey[3]*0.3, 0.3)
            f.timer:SetText(f.learnLevel)
            f.timer:SetTextColor(D.grey[1]*0.5, D.grey[2]*0.5, D.grey[3]*0.5)
            f.lbl:SetTextColor(D.grey[1]*0.5, D.grey[2]*0.5, D.grey[3]*0.5)
        else
            f.lbl:SetTextColor(D.gold_dim[1], D.gold_dim[2], D.gold_dim[3])
            local cd = GetGroupCD(key) or 0
            if cd <= 0 then
                f.border:SetColorTexture(D.green[1], D.green[2], D.green[3], 0.7)
                f.timer:SetText("✓")
                f.timer:SetTextColor(D.green[1], D.green[2], D.green[3])
            elseif cd < 5 then
                f.border:SetColorTexture(D.orange[1], D.orange[2], D.orange[3], 0.7)
                f.timer:SetText(string.format("%.1f", cd))
                f.timer:SetTextColor(D.orange[1], D.orange[2], D.orange[3])
            else
                f.border:SetColorTexture(D.green_dim[1], D.green_dim[2], D.green_dim[3], 0.4)
                f.timer:SetText(string.format("%d", math.ceil(cd)))
                f.timer:SetTextColor(D.grey[1], D.grey[2], D.grey[3])
            end
        end
    end
end)

-- ============================================================
-- SLASH COMMANDS
-- ============================================================
local ghLocked = false
SLASH_GH1, SLASH_GH2 = "/gh", "/guardianhelper"
SlashCmdList["GH"] = function(msg)
    msg = strtrim(msg:lower())
    if msg == "lock" then
        ghLocked = not ghLocked
        Frame:SetMovable(not ghLocked)
        Frame:EnableMouse(not ghLocked)
        footer:SetText(ghLocked and "● gesperrt" or "/gh lock  ·  /gh help")
        print("|cff1aee3aGuardianHelper:|r " .. (ghLocked and "Gesperrt." or "Entsperrt."))
    elseif msg == "hide" then Frame:Hide()
    elseif msg == "show" then Frame:Show()
    elseif msg == "reset" then Frame:ClearAllPoints(); Frame:SetPoint("CENTER", UIParent, "CENTER", 350, 0)
    elseif msg == "update" then RebuildSpellCache(); RebuildMaulIDs(); UpdateAllActionBars(); print("|cff1aee3aGuardianHelper:|r Bars aktualisiert.")
    elseif msg == "status" then
        print("|cff1aee3aGuardianHelper — Spells:|r")
        for k, g in pairs(SPELL_GROUPS) do
            local c = spellCache[k]
            if c then print("  "..g.label..": ".. (GetSpellInfo(c.highestID) or "?") .." (Lvl "..c.highestLevel..")")
            else print("  |cff555555"..g.label..": ab Lvl "..g.ranks[1].level.."|r") end
        end
    else
        print("|cff1aee3aGuardianHelper v"..GH_VERSION.."|r  /gh lock · hide · show · reset · update · status")
    end
end
