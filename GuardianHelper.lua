-- ============================================================
-- GuardianHelper v4.2 — Lokalisierung DE/EN
-- Guardian Druid Tank — TBC Classic 2.5.5
-- ============================================================
local VERSION = "4.2.0"

-- SavedVariables werden nach ADDON_LOADED initialisiert
local DB

-- ============================================================
-- LOKALISIERUNG (automatisch per GetLocale())
-- ============================================================
local LOCALE = GetLocale()  -- z.B. "deDE", "enUS", "enGB"
local IS_DE  = (LOCALE == "deDE")

-- Alle sichtbaren Texte im Addon
local L = {
    -- Header
    BEAR_FORM      = IS_DE and ">> BAERENGESTALT"  or ">> BEAR FORM",
    DIRE_BEAR      = IS_DE and ">> WILDE BAER"     or ">> DIRE BEAR",
    NO_BEAR        = IS_DE and "!! KEINE BAERENFORM" or "!! NO BEAR FORM",
    -- Maul
    MAUL_READY     = IS_DE and ">> KRALLENHIEB BEREIT" or ">> MAUL READY",
    MAUL_INACTIVE  = IS_DE and "-- Krallenhieb inaktiv" or "-- Maul not active",
    -- Cooldown Labels
    CD_BASH        = IS_DE and "Hieb"    or "Bash",
    CD_GROWL       = IS_DE and "Knurr."  or "Growl",
    CD_ENRAGE      = IS_DE and "Rasen"   or "Enrage",
    CD_FREG        = IS_DE and "F.Reg"   or "F.Reg",
    CD_BARK        = IS_DE and "Borke"   or "Bark",
    CD_MANGLE      = IS_DE and "Zerr."   or "Mangle",
    CD_LACERATE    = IS_DE and "Aufr."   or "Lacerate",
    -- Debuffs
    FF_LABEL       = IS_DE and "FEF"     or "FF",
    DR_LABEL       = IS_DE and "Demo"    or "DR",
    -- Status
    READY          = IS_DE and "OK"      or "RDY",
    -- Footer
    FOOTER         = "/gh lock  .  /gh help  .  /gh config",
    -- Config
    CFG_TITLE      = IS_DE and "[ GuardianHelper Konfig ]" or "[ GuardianHelper Config ]",
    CFG_MAUL       = IS_DE and "Krallenhieb-Alert"   or "Maul Queue Alert",
    CFG_SOUND      = IS_DE and "Sound bei Formverlust" or "Sound on Form Loss",
    CFG_COMBAT     = IS_DE and "Nur im Kampf zeigen"  or "Show in Combat only",
    CFG_RAGE       = IS_DE and "Wut-Leiste anzeigen"  or "Show Rage Bar",
    CFG_CDTEXT     = IS_DE and "Cooldown-Text"         or "Cooldown Text",
    CFG_DOTS       = IS_DE and "Status-Punkte"         or "Status Dots",
    CFG_SAVE       = IS_DE and "Speichern"             or "Save",
    CFG_CANCEL     = IS_DE and "Abbrechen"             or "Cancel",
    -- Chat
    MSG_LOADED     = IS_DE and "bereit" or "ready",
    MSG_LOCKED     = IS_DE and "Gesperrt."    or "Locked.",
    MSG_UNLOCKED   = IS_DE and "Entsperrt."   or "Unlocked.",
    MSG_SAVED      = IS_DE and "Gespeichert." or "Saved.",
    MSG_UPDATED    = IS_DE and "Cache aktualisiert." or "Cache updated.",
}

-- ============================================================
-- SPELL DATEN
-- ============================================================
local SPELL_GROUPS = {
    BASH           = { label=L.CD_BASH,   ranks={{id=5211,lv=14},{id=6798,lv=22},{id=8983,lv=32},{id=25515,lv=42}} },
    GROWL          = { label=L.CD_GROWL,  ranks={{id=6795,lv=10}} },
    ENRAGE         = { label=L.CD_ENRAGE, ranks={{id=5229,lv=14}} },
    FRENZIED_REGEN = { label=L.CD_FREG,   ranks={{id=22842,lv=36},{id=22895,lv=46},{id=22896,lv=56},{id=26999,lv=66}} },
    BARKSKIN       = { label=L.CD_BARK,   ranks={{id=22812,lv=44}} },
    MANGLE_BEAR    = { label=L.CD_MANGLE, ranks={{id=33878,lv=60},{id=33986,lv=66}} },
    LACERATE       = { label=L.CD_LACERATE, ranks={{id=33745,lv=66}} },
}
local CD_ORDER  = { "BASH","GROWL","ENRAGE","FRENZIED_REGEN","BARKSKIN","MANGLE_BEAR","LACERATE" }
local MAUL_IDS  = {[6807]=true,[8972]=true,[9745]=true,[9880]=true,[9881]=true,[26996]=true,[26997]=true}
local BEAR_IDS  = {5487, 9634}   -- Bear Form, Dire Bear Form
local FF_IDS    = {16857,17390,17391,17392,27011}
local DR_IDS    = {99,1735,9490,9747,9898,26998}

-- ============================================================
-- FARBEN
-- ============================================================
local GOLD   = {1.000, 0.820, 0.000}
local DGOLD  = {0.800, 0.620, 0.100}
local BG1    = {0.050, 0.037, 0.028, 0.97}
local BG2    = {0.090, 0.068, 0.035, 1.00}
local RED    = {0.900, 0.120, 0.040}
local REDBR  = {1.000, 0.250, 0.060}
local GREEN  = {0.200, 1.000, 0.350}
local ORANGE = {1.000, 0.620, 0.050}
local WHITE  = {1.000, 1.000, 1.000}
local GREY   = {0.720, 0.660, 0.560}
local DKGREY = {0.100, 0.078, 0.055}

-- ============================================================
-- HILFSFUNKTIONEN
-- ============================================================
local function CT(parent, level, r, g, b, a)
    local t = parent:CreateTexture(nil, level or "BACKGROUND")
    t:SetColorTexture(r, g, b, a or 1)
    return t
end

local function CF(parent, size, r, g, b)
    local f = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f:SetFont("Fonts\\FRIZQT__.TTF", size or 9, "OUTLINE")
    f:SetTextColor(r or 1, g or 1, b or 1)
    return f
end

local function Sep(parent, y)
    local s = CT(parent, "ARTWORK", DGOLD[1], DGOLD[2], DGOLD[3], 0.6)
    s:SetHeight(1)
    s:SetPoint("TOPLEFT",  parent, "TOPLEFT",  4, y)
    s:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, y)
    return s
end

-- ============================================================
-- HAUPTRAHMEN (W=210, H wird unten gesetzt)
-- ============================================================
local W = 210
local Frame = CreateFrame("Frame", "GuardianHelperFrame", UIParent)
Frame:SetWidth(W)
Frame:SetHeight(130)
Frame:SetPoint("CENTER", UIParent, "CENTER", 350, 0)
Frame:SetMovable(true)
Frame:EnableMouse(true)
Frame:RegisterForDrag("LeftButton")
Frame:SetScript("OnDragStart", function(s)
    if not (DB and DB.locked) then s:StartMoving() end
end)
Frame:SetScript("OnDragStop", function(s)
    s:StopMovingOrSizing()
    if DB then
        local _, _, _, x, y = s:GetPoint()
        DB.x = x; DB.y = y
    end
end)
Frame:SetFrameStrata("MEDIUM")
Frame:SetClampedToScreen(true)

-- Gold-Rahmen
local fBorder = CT(Frame, "BACKGROUND", GOLD[1], GOLD[2], GOLD[3], 1)
fBorder:SetAllPoints()

-- Dark BG
local fBG = CT(Frame, "BORDER", BG1[1], BG1[2], BG1[3], BG1[4])
fBG:SetPoint("TOPLEFT",     Frame, "TOPLEFT",      1, -1)
fBG:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT",  -1,  1)

-- Header BG
local hBG = CT(Frame, "ARTWORK", BG2[1], BG2[2], BG2[3], 1)
hBG:SetHeight(18)
hBG:SetPoint("TOPLEFT",  Frame, "TOPLEFT",  1, -1)
hBG:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -1, -1)

-- Header: Akzentlinie links
local hLine = CT(Frame, "OVERLAY", GREEN[1], GREEN[2], GREEN[3], 1)
hLine:SetSize(2, 18)
hLine:SetPoint("TOPLEFT", Frame, "TOPLEFT", 1, -1)

-- Header Texte
local hTitle = CF(Frame, 9, GOLD[1], GOLD[2], GOLD[3])
hTitle:SetPoint("LEFT", Frame, "TOPLEFT", 8, -10)
hTitle:SetText(L.BEAR_FORM)

local hDot = CF(Frame, 8, GREEN[1], GREEN[2], GREEN[3])
hDot:SetPoint("RIGHT", Frame, "TOPRIGHT", -6, -10)
hDot:SetText("[o]")

Sep(Frame, -19)

-- ============================================================
-- RAGE BAR
-- ============================================================
local rLbl = CF(Frame, 7, DGOLD[1], DGOLD[2], DGOLD[3])
rLbl:SetPoint("TOPLEFT", Frame, "TOPLEFT", 7, -26)
rLbl:SetText("RAGE")

local rVal = CF(Frame, 8, WHITE[1], WHITE[2], WHITE[3])
rVal:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -6, -26)
rVal:SetText("0 / 100")

local rTrackBG = CT(Frame, "ARTWORK", DKGREY[1], DKGREY[2], DKGREY[3], 1)
rTrackBG:SetHeight(8)
rTrackBG:SetPoint("TOPLEFT",  Frame, "TOPLEFT",  6, -36)
rTrackBG:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -6, -36)

local rBorder = CT(Frame, "BACKGROUND", DGOLD[1], DGOLD[2], DGOLD[3], 0.5)
rBorder:SetPoint("TOPLEFT",     rTrackBG, "TOPLEFT",     -1,  1)
rBorder:SetPoint("BOTTOMRIGHT", rTrackBG, "BOTTOMRIGHT",  1, -1)

local rFill = CT(Frame, "OVERLAY", RED[1], RED[2], RED[3], 1)
rFill:SetHeight(8)
rFill:SetPoint("TOPLEFT", rTrackBG, "TOPLEFT", 0, 0)
rFill:SetWidth(1)

local rHL = CT(Frame, "OVERLAY", 1, 1, 1, 0.07)
rHL:SetHeight(2)
rHL:SetPoint("TOPLEFT",  rTrackBG, "TOPLEFT",  0, 0)
rHL:SetPoint("TOPRIGHT", rTrackBG, "TOPRIGHT", 0, 0)

Sep(Frame, -46)

-- ============================================================
-- MAUL INDICATOR
-- ============================================================
local mBG = CT(Frame, "ARTWORK", DKGREY[1], DKGREY[2], DKGREY[3], 1)
mBG:SetHeight(15)
mBG:SetPoint("TOPLEFT",  Frame, "TOPLEFT",  1, -48)
mBG:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -1, -48)

local mDot = CF(Frame, 7, GREY[1], GREY[2], GREY[3])
mDot:SetPoint("LEFT", Frame, "TOPLEFT", 7, -56)
mDot:SetText("-")

local mTxt = CF(Frame, 8, GREY[1], GREY[2], GREY[3])
mTxt:SetPoint("LEFT", Frame, "TOPLEFT", 16, -56)
mTxt:SetText(L.MAUL_INACTIVE)

Sep(Frame, -64)

-- ============================================================
-- FF / DR ZEILE
-- ============================================================
local fDot = CF(Frame, 7, GREY[1], GREY[2], GREY[3])
fDot:SetPoint("TOPLEFT", Frame, "TOPLEFT", 7, -72)
fDot:SetText("[*]")

local fLbl = CF(Frame, 7, DGOLD[1], DGOLD[2], DGOLD[3])
fLbl:SetPoint("TOPLEFT", Frame, "TOPLEFT", 16, -72)
fLbl:SetText(L.FF_LABEL)

local fVal = CF(Frame, 8, GREY[1], GREY[2], GREY[3])
fVal:SetPoint("TOPLEFT", Frame, "TOPLEFT", 30, -72)
fVal:SetText("---")

local vSep = CT(Frame, "ARTWORK", DGOLD[1], DGOLD[2], DGOLD[3], 0.4)
vSep:SetSize(1, 10)
vSep:SetPoint("TOPLEFT", Frame, "TOPLEFT", W/2, -68)

local dDot = CF(Frame, 7, GREY[1], GREY[2], GREY[3])
dDot:SetPoint("TOPLEFT", Frame, "TOPLEFT", W/2+5, -72)
dDot:SetText("[*]")

local dLbl = CF(Frame, 7, DGOLD[1], DGOLD[2], DGOLD[3])
dLbl:SetPoint("TOPLEFT", Frame, "TOPLEFT", W/2+14, -72)
dLbl:SetText(L.DR_LABEL)

local dVal = CF(Frame, 8, GREY[1], GREY[2], GREY[3])
dVal:SetPoint("TOPLEFT", Frame, "TOPLEFT", W/2+28, -72)
dVal:SetText("---")

Sep(Frame, -79)

-- ============================================================
-- COOLDOWN SLOTS
-- ============================================================
local CD_SZ  = 26
local CD_GAP = 2
local nCD    = #CD_ORDER
local totW   = nCD * CD_SZ + (nCD - 1) * CD_GAP
local cdX0   = math.floor((W - totW) / 2)

local cdSlots = {}
for i, key in ipairs(CD_ORDER) do
    local xp = cdX0 + (i-1) * (CD_SZ + CD_GAP)
    local cf = CreateFrame("Frame", nil, Frame)
    cf:SetSize(CD_SZ, CD_SZ + 9)
    cf:SetPoint("TOPLEFT", Frame, "TOPLEFT", xp, -82)

    local cborder = CT(cf, "BACKGROUND", DGOLD[1], DGOLD[2], DGOLD[3], 0.5)
    cborder:SetAllPoints()
    cf.border = cborder

    local cinner = CT(cf, "BORDER", DKGREY[1], DKGREY[2], DKGREY[3], 1)
    cinner:SetPoint("TOPLEFT",     cf, "TOPLEFT",      1, -1)
    cinner:SetPoint("BOTTOMRIGHT", cf, "BOTTOMRIGHT",  -1, 8)
    cf.inner = cinner

    local ctimer = CF(cf, 9, GREY[1], GREY[2], GREY[3])
    ctimer:SetPoint("CENTER", cf, "CENTER", 0, 4)
    ctimer:SetText("?")
    cf.timer = ctimer

    local clbl = CF(cf, 6, DGOLD[1], DGOLD[2], DGOLD[3])
    clbl:SetPoint("BOTTOM", cf, "BOTTOM", 0, 1)
    clbl:SetText(SPELL_GROUPS[key].label)
    cf.lbl = clbl

    cf.key      = key
    cf.minLevel = SPELL_GROUPS[key].ranks[1].lv
    cdSlots[i]  = cf
end

-- Footer
local footer = CF(Frame, 6, 0.22, 0.18, 0.14)
footer:SetPoint("BOTTOM", Frame, "BOTTOM", 0, 3)
footer:SetText(L.FOOTER)

-- Frame Höhe final
Frame:SetHeight(82 + CD_SZ + 9 + 8)

-- ============================================================
-- MINIMAP BUTTON
-- ============================================================
local MM = CreateFrame("Button", "GHMinimapButton", Minimap)
MM:SetSize(24, 24)
MM:SetFrameStrata("MEDIUM")
MM:SetFrameLevel(8)
MM:SetMovable(true)
MM:RegisterForDrag("LeftButton")

local mmRing = CT(MM, "BACKGROUND", GOLD[1], GOLD[2], GOLD[3], 1)
mmRing:SetAllPoints()
local mmBG   = CT(MM, "BORDER", BG1[1], BG1[2], BG1[3], 1)
mmBG:SetPoint("TOPLEFT",     MM, "TOPLEFT",      2, -2)
mmBG:SetPoint("BOTTOMRIGHT", MM, "BOTTOMRIGHT",  -2,  2)
local mmIcon = CF(MM, 11, 1, 1, 1)
mmIcon:SetAllPoints()
mmIcon:SetJustifyH("CENTER")
mmIcon:SetJustifyV("MIDDLE")
mmIcon:SetText("GH")

local mmAngle = 220
local function SetMMPos()
    local r = math.rad(mmAngle)
    MM:SetPoint("CENTER", Minimap, "CENTER", math.cos(r)*80, math.sin(r)*80)
end
SetMMPos()

MM:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local s = UIParent:GetEffectiveScale()
        mmAngle = math.deg(math.atan2(cy/s - my, cx/s - mx))
        SetMMPos()
    end)
end)
MM:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)
MM:SetScript("OnClick", function()
    if Frame:IsShown() then Frame:Hide() else Frame:Show() end
end)
MM:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("|cffC8A84BGuardianHelper|r v"..VERSION)
    GameTooltip:AddLine("Klick: Ein/Ausblenden", 1, 1, 1)
    GameTooltip:AddLine("Drag: Verschieben", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)
MM:SetScript("OnLeave", GameTooltip.Hide)

-- ============================================================
-- CONFIG PANEL (einfach & robust)
-- ============================================================
local CFG = CreateFrame("Frame", "GHConfigFrame", UIParent)
CFG:SetSize(200, 160)
CFG:SetPoint("CENTER", UIParent, "CENTER", 50, 50)
CFG:SetFrameStrata("HIGH")
CFG:SetFrameLevel(50)
CFG:SetMovable(true)
CFG:EnableMouse(true)
CFG:RegisterForDrag("LeftButton")
CFG:SetScript("OnDragStart", function(s) s:StartMoving() end)
CFG:SetScript("OnDragStop",  function(s) s:StopMovingOrSizing() end)
CFG:Hide()

CT(CFG, "BACKGROUND", GOLD[1], GOLD[2], GOLD[3], 1):SetAllPoints()
local cfgBG = CT(CFG, "BORDER", BG1[1], BG1[2], BG1[3], BG1[4])
cfgBG:SetPoint("TOPLEFT", CFG, "TOPLEFT", 1, -1)
cfgBG:SetPoint("BOTTOMRIGHT", CFG, "BOTTOMRIGHT", -1, 1)

local cfgHdr = CT(CFG, "ARTWORK", BG2[1], BG2[2], BG2[3], 1)
cfgHdr:SetHeight(18)
cfgHdr:SetPoint("TOPLEFT",  CFG, "TOPLEFT",  1, -1)
cfgHdr:SetPoint("TOPRIGHT", CFG, "TOPRIGHT", -1, -1)

local cfgTitle = CF(CFG, 9, GOLD[1], GOLD[2], GOLD[3])
cfgTitle:SetPoint("CENTER", CFG, "TOP", 0, -10)
cfgTitle:SetText(L.CFG_TITLE)

local cfgX = CreateFrame("Button", nil, CFG)
cfgX:SetSize(16, 16)
cfgX:SetPoint("TOPRIGHT", CFG, "TOPRIGHT", -4, -2)
local cfgXL = CF(cfgX, 10, GOLD[1], GOLD[2], GOLD[3])
cfgXL:SetAllPoints(); cfgXL:SetJustifyH("CENTER"); cfgXL:SetText("X")
cfgX:SetScript("OnClick", function() CFG:Hide() end)

Sep(CFG, -19)

-- Einfache Checkbox-Funktion
local cfgChecks = {}
local function AddCheck(label, key, yOff)
    local btn = CreateFrame("Button", nil, CFG)
    btn:SetSize(180, 14)
    btn:SetPoint("TOPLEFT", CFG, "TOPLEFT", 8, yOff)

    local box = CT(btn, "BACKGROUND", GOLD[1], GOLD[2], GOLD[3], 0.7)
    box:SetSize(10, 10)
    box:SetPoint("LEFT", btn, "LEFT", 0, 0)

    local check = CF(btn, 8, GREEN[1], GREEN[2], GREEN[3])
    check:SetSize(10, 10)
    check:SetPoint("LEFT", btn, "LEFT", 1, 0)
    check:SetJustifyH("CENTER")
    check:SetText(DB and DB[key] and "OK" or "")
    btn.check = check

    local lbl = CF(btn, 8, WHITE[1], WHITE[2], WHITE[3])
    lbl:SetPoint("LEFT", btn, "LEFT", 14, 0)
    lbl:SetText(label)

    btn:SetScript("OnClick", function()
        if DB then
            DB[key] = not DB[key]
            check:SetText(DB[key] and "OK" or "")
        end
    end)
    cfgChecks[key] = btn
end

Sep(CFG, -19)
AddCheck("Maul Queue Alert",      "maulAlert",       -28)
AddCheck("Sound bei Formverlust", "soundFormLoss",   -44)
AddCheck("Nur in Kampf zeigen",   "combatOnly",      -60)
Sep(CFG, -74)

local opLbl = CF(CFG, 7, DGOLD[1], DGOLD[2], DGOLD[3])
opLbl:SetPoint("TOPLEFT", CFG, "TOPLEFT", 8, -80)
opLbl:SetText("Opacity:")

local opVal = CF(CFG, 8, WHITE[1], WHITE[2], WHITE[3])
opVal:SetPoint("TOPLEFT", CFG, "TOPLEFT", 58, -80)
opVal:SetText("95%")

local function MakeBtn(label, xOff, yOff, onClick)
    local b = CreateFrame("Button", nil, CFG)
    b:SetSize(28, 16)
    b:SetPoint("TOPLEFT", CFG, "TOPLEFT", xOff, yOff)
    CT(b, "BACKGROUND", GOLD[1], GOLD[2], GOLD[3], 0.8):SetAllPoints()
    CT(b, "BORDER", BG2[1], BG2[2], BG2[3], 1):SetPoint("TOPLEFT",b,"TOPLEFT",1,-1)
    CT(b, "BORDER", BG2[1], BG2[2], BG2[3], 1):SetPoint("BOTTOMRIGHT",b,"BOTTOMRIGHT",-1,1)
    local l = CF(b, 8, GOLD[1], GOLD[2], GOLD[3])
    l:SetAllPoints(); l:SetJustifyH("CENTER"); l:SetText(label)
    b:SetScript("OnClick", onClick)
    return b
end

MakeBtn("  −  ", 100, -76, function()
    if not DB then return end
    DB.alpha = math.max(0.3, DB.alpha - 0.05)
    Frame:SetAlpha(DB.alpha)
    opVal:SetText(string.format("%d%%", DB.alpha * 100))
end)
MakeBtn("  +  ", 132, -76, function()
    if not DB then return end
    DB.alpha = math.min(1.0, DB.alpha + 0.05)
    Frame:SetAlpha(DB.alpha)
    opVal:SetText(string.format("%d%%", DB.alpha * 100))
end)

Sep(CFG, -100)

local btnSave = MakeBtn(L.CFG_SAVE, 15, -108, function()
    print("|cffC8A84BGuardianHelper:|r " .. L.MSG_SAVED)
    CFG:Hide()
end)
btnSave:SetSize(80, 18)
btnSave:SetPoint("BOTTOMLEFT", CFG, "BOTTOMLEFT", 8, 6)

local btnCancel = MakeBtn(L.CFG_CANCEL, 110, -108, function() CFG:Hide() end)
btnCancel:SetSize(80, 18)
btnCancel:SetPoint("BOTTOMRIGHT", CFG, "BOTTOMRIGHT", -8, 6)

-- ============================================================
-- SPELL CACHE
-- ============================================================
local cache = {}

local function BuildCache()
    cache = {}
    local i = 1
    while true do
        local name = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not name then break end
        local _, sid = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
        if sid then
            for key, grp in pairs(SPELL_GROUPS) do
                for _, rd in ipairs(grp.ranks) do
                    if rd.id == sid then
                        local c = cache[key]
                        if not c or rd.lv > c.lv then
                            cache[key] = {id=sid, lv=rd.lv, slot=i}
                        end
                    end
                end
            end
        end
        i = i + 1
    end
end

-- ============================================================
-- STATUS HILFSFUNKTIONEN
-- ============================================================
local function InBearForm()
    for _, id in ipairs(BEAR_IDS) do
        local n = GetSpellInfo(id)
        if n then
            for i = 1, 40 do
                local bn = UnitBuff("player", i)
                if not bn then break end
                if bn == n then return true, id == 9634 end
            end
        end
    end
    return false, false
end

local function DebuffOnTarget(idList)
    for _, id in ipairs(idList) do
        local n = GetSpellInfo(id)
        if n then
            for i = 1, 40 do
                local dn, _, _, _, _, _, exp = UnitDebuff("target", i)
                if not dn then break end
                if dn == n then
                    return exp and exp > 0 and (exp - GetTime()) or 999
                end
            end
        end
    end
    return nil
end

local function GetCD(key)
    local c = cache[key]; if not c then return nil end
    local s, d = GetSpellCooldown(c.id)
    if not s or s == 0 then return 0 end
    local r = (s + d) - GetTime()
    return r > 0 and r or 0
end

-- ============================================================
-- STATE
-- ============================================================
local maulQueued = false

-- ============================================================
-- EVENTS
-- ============================================================
local EF = CreateFrame("Frame")
EF:RegisterEvent("ADDON_LOADED")
EF:RegisterEvent("PLAYER_LOGIN")
EF:RegisterEvent("PLAYER_LEVEL_UP")
EF:RegisterEvent("SPELLS_CHANGED")
EF:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

EF:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == "GuardianHelper" then
        -- DB nach SavedVariables-Laden initialisieren
        GuardianHelperDB = GuardianHelperDB or {}
        DB = GuardianHelperDB
        DB.alpha      = DB.alpha or 0.95
        DB.locked     = DB.locked or false
        DB.maulAlert  = DB.maulAlert == nil and true or DB.maulAlert
        Frame:SetAlpha(DB.alpha)
        if DB.x and DB.y then
            Frame:ClearAllPoints()
            Frame:SetPoint("CENTER", UIParent, "CENTER", DB.x, DB.y)
        end
        opVal:SetText(string.format("%d%%", DB.alpha * 100))

    elseif event == "PLAYER_LOGIN" then
        BuildCache()
        print("|cffC8A84BGuardianHelper|r v"..VERSION.." "..L.MSG_LOADED.."  |cffaaaaaa/gh help|r")

    elseif event == "PLAYER_LEVEL_UP" then
        local df = CreateFrame("Frame"); local el = 0
        df:SetScript("OnUpdate", function(s,e)
            el = el + e
            if el >= 0.5 then s:SetScript("OnUpdate",nil); BuildCache() end
        end)

    elseif event == "SPELLS_CHANGED" then
        BuildCache()

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, sub, _, guid, _, _, _, _, _, _, _, sid = ...
        if guid ~= UnitGUID("player") then return end
        if sub == "SPELL_CAST_START" and MAUL_IDS[sid] then
            maulQueued = true
        elseif (sub == "SPELL_DAMAGE" or sub == "SPELL_MISSED") and MAUL_IDS[sid] then
            maulQueued = false
        end
    end
end)

-- ============================================================
-- UPDATE LOOP
-- ============================================================
local tick = 0
Frame:SetScript("OnUpdate", function(self, dt)
    tick = tick + dt
    if tick < 0.15 then return end
    tick = 0

    -- Rage
    local rage    = UnitPower("player", 1)
    local rageMax = UnitPowerMax("player", 1)
    if rageMax < 1 then rageMax = 100 end
    local pct = rage / rageMax
    local tw  = rTrackBG:GetWidth()
    if tw and tw > 2 then rFill:SetWidth(math.max(tw * pct, 1)) end
    rVal:SetText(rage .. " / " .. rageMax)
    if pct >= 0.7 then
        rFill:SetColorTexture(REDBR[1], REDBR[2], REDBR[3], 1)
    else
        rFill:SetColorTexture(RED[1], RED[2], RED[3], 1)
    end

    -- Bear Form
    local inBear, isDire = InBearForm()
    if inBear then
        hLine:SetColorTexture(GREEN[1], GREEN[2], GREEN[3], 1)
        hDot:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
        hDot:SetText("[o]")
        hTitle:SetText(isDire and L.DIRE_BEAR or L.BEAR_FORM)
        hTitle:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
    else
        hLine:SetColorTexture(REDBR[1], REDBR[2], REDBR[3], 1)
        hDot:SetTextColor(REDBR[1], REDBR[2], REDBR[3])
        hDot:SetText("[!]")
        hTitle:SetText(L.NO_BEAR)
        hTitle:SetTextColor(REDBR[1], REDBR[2], REDBR[3])
    end

    -- Maul
    if maulQueued then
        mBG:SetColorTexture(0.18, 0.09, 0, 1)
        mDot:SetTextColor(ORANGE[1], ORANGE[2], ORANGE[3])
        mTxt:SetText(L.MAUL_READY)
        mTxt:SetTextColor(ORANGE[1], ORANGE[2], ORANGE[3])
    else
        mBG:SetColorTexture(DKGREY[1], DKGREY[2], DKGREY[3], 1)
        mDot:SetTextColor(GREY[1], GREY[2], GREY[3])
        mTxt:SetText(L.MAUL_INACTIVE)
        mTxt:SetTextColor(GREY[1], GREY[2], GREY[3])
    end

    -- Faerie Fire
    if UnitExists("target") then
        local r = DebuffOnTarget(FF_IDS)
        if r then
            fDot:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
            local t = r >= 999 and "∞" or string.format("%ds", math.floor(r))
            fVal:SetText(t)
            fVal:SetTextColor(r < 4 and ORANGE[1] or GREEN[1], r < 4 and ORANGE[2] or GREEN[2], r < 4 and ORANGE[3] or GREEN[3])
        else
            fDot:SetTextColor(REDBR[1], REDBR[2], REDBR[3])
            fVal:SetText("!")
            fVal:SetTextColor(REDBR[1], REDBR[2], REDBR[3])
        end
    else
        fDot:SetTextColor(GREY[1], GREY[2], GREY[3])
        fVal:SetText("---"); fVal:SetTextColor(GREY[1], GREY[2], GREY[3])
    end

    -- Demo Roar
    if UnitExists("target") then
        local r = DebuffOnTarget(DR_IDS)
        if r then
            dDot:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
            local t = r >= 999 and "∞" or string.format("%ds", math.floor(r))
            dVal:SetText(t)
            dVal:SetTextColor(r < 3 and ORANGE[1] or GREEN[1], r < 3 and ORANGE[2] or GREEN[2], r < 3 and ORANGE[3] or GREEN[3])
        else
            dDot:SetTextColor(REDBR[1], REDBR[2], REDBR[3])
            dVal:SetText("!")
            dVal:SetTextColor(REDBR[1], REDBR[2], REDBR[3])
        end
    else
        dDot:SetTextColor(GREY[1], GREY[2], GREY[3])
        dVal:SetText("---"); dVal:SetTextColor(GREY[1], GREY[2], GREY[3])
    end

    -- Cooldowns
    for _, f in ipairs(cdSlots) do
        local c = cache[f.key]
        if not c then
            f.border:SetColorTexture(DGOLD[1]*0.4, DGOLD[2]*0.4, DGOLD[3]*0.4, 0.3)
            f.inner:SetColorTexture(0.07, 0.05, 0.03, 1)
            f.timer:SetText(f.minLevel)
            f.timer:SetTextColor(GREY[1]*0.6, GREY[2]*0.6, GREY[3]*0.6)
            f.lbl:SetTextColor(GREY[1]*0.5, GREY[2]*0.5, GREY[3]*0.5)
        else
            f.lbl:SetTextColor(DGOLD[1], DGOLD[2], DGOLD[3])
            local cd = GetCD(f.key) or 0
            if cd <= 0 then
                f.border:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.9)
                f.inner:SetColorTexture(0.04, 0.14, 0.04, 1)
                f.timer:SetText("RDY")
                f.timer:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
            elseif cd < 5 then
                f.border:SetColorTexture(ORANGE[1], ORANGE[2], ORANGE[3], 0.9)
                f.inner:SetColorTexture(0.18, 0.09, 0, 1)
                f.timer:SetText(string.format("%.1f", cd))
                f.timer:SetTextColor(ORANGE[1], ORANGE[2], ORANGE[3])
            else
                f.border:SetColorTexture(DGOLD[1], DGOLD[2], DGOLD[3], 0.5)
                f.inner:SetColorTexture(DKGREY[1], DKGREY[2], DKGREY[3], 1)
                f.timer:SetText(math.ceil(cd))
                f.timer:SetTextColor(GREY[1], GREY[2], GREY[3])
            end
        end
    end
end)

-- ============================================================
-- SLASH COMMANDS
-- ============================================================
SLASH_GH1, SLASH_GH2 = "/gh", "/guardianhelper"
SlashCmdList["GH"] = function(msg)
    msg = strtrim(msg:lower())
    if msg == "lock" then
        if DB then DB.locked = not DB.locked end
        print("|cffC8A84BGuardianHelper:|r " .. (DB and DB.locked and L.MSG_LOCKED or L.MSG_UNLOCKED))
    elseif msg == "hide"           then Frame:Hide()
    elseif msg == "show"           then Frame:Show()
    elseif msg == "config" or msg == "cfg" then
        if CFG:IsShown() then CFG:Hide() else CFG:Show() end
    elseif msg == "reset"          then
        Frame:ClearAllPoints()
        Frame:SetPoint("CENTER", UIParent, "CENTER", 350, 0)
        if DB then DB.x, DB.y = nil, nil end
    elseif msg == "update"         then
        BuildCache()
        print("|cffC8A84BGuardianHelper:|r " .. L.MSG_UPDATED)
    elseif msg == "status"         then
        print("|cffC8A84BGuardianHelper — Spells:|r")
        for k, g in pairs(SPELL_GROUPS) do
            local c = cache[k]
            if c then
                print("  " .. g.label .. ": " .. (GetSpellInfo(c.id) or "?") .. " (Lvl " .. c.lv .. ")")
            else
                print("  |cff555555" .. g.label .. ": ab Lvl " .. g.ranks[1].lv .. "|r")
            end
        end
    else
        print("|cffC8A84BGuardianHelper v" .. VERSION .. "|r")
        print("  /gh lock · hide · show · reset · update · status · config")
    end
end
