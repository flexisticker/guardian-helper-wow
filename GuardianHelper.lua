-- ============================================================
-- GuardianHelper v4.0 — WoW Classic Style UI
-- Guardian Druid Tank Addon — Level 1-70 (Classic & TBC)
-- Design: Dark leather/stone, gold borders, amber text
-- ============================================================

local GH_VERSION = "4.0.0"

-- ============================================================
-- SPELL-GRUPPEN
-- ============================================================
local SPELL_GROUPS = {
    MAUL           = { label="Bash",    shortLabel="Bash",   autoUpdate=true,  ranks={{id=6807,level=10},{id=8972,level=18},{id=9745,level=26},{id=9880,level=34},{id=9881,level=42},{id=26996,level=50},{id=26997,level=58},{id=48479,level=62},{id=48480,level=70}} },
    SWIPE          = { label="Swipe",   shortLabel="Swipe",  autoUpdate=true,  ranks={{id=779,level=16},{id=780,level=24},{id=769,level=34},{id=9754,level=44},{id=9908,level=54},{id=48562,level=62}} },
    BASH           = { label="Bash",    shortLabel="Bash",   autoUpdate=true,  ranks={{id=5211,level=14},{id=6798,level=22},{id=8983,level=32},{id=25515,level=42}} },
    GROWL          = { label="Growl",   shortLabel="Growl",  autoUpdate=false, ranks={{id=6795,level=10}} },
    ENRAGE         = { label="Enrage",  shortLabel="Enrg",   autoUpdate=false, ranks={{id=5229,level=14}} },
    DEMO_ROAR      = { label="D.Roar",  shortLabel="D.Roar", autoUpdate=true,  ranks={{id=99,level=8},{id=1735,level=16},{id=9490,level=24},{id=9747,level=32},{id=9898,level=42},{id=26998,level=52}} },
    FAERIE_FIRE    = { label="F.Fire",  shortLabel="F.Fire", autoUpdate=false, ranks={{id=16857,level=20},{id=17390,level=30},{id=17391,level=40},{id=17392,level=50},{id=27011,level=60}} },
    FRENZIED_REGEN = { label="F.Reg",   shortLabel="F.Reg",  autoUpdate=false, ranks={{id=22842,level=36},{id=22895,level=46},{id=22896,level=56},{id=26999,level=66}} },
    BARKSKIN       = { label="Bark",    shortLabel="Bark",   autoUpdate=false, ranks={{id=22812,level=44}} },
    MANGLE_BEAR    = { label="Mangle",  shortLabel="Mngl",   autoUpdate=true,  ranks={{id=33878,level=60},{id=33986,level=66}} },
    LACERATE       = { label="Lacer.",  shortLabel="Lac.",   autoUpdate=true,  ranks={{id=33745,level=66}} },
}
local CD_SLOTS = { "BASH","GROWL","ENRAGE","FRENZIED_REGEN","BARKSKIN","MANGLE_BEAR","LACERATE" }
local BEAR_FORM_IDS = {5487}
local DIRE_BEAR_IDS = {9634}

-- ============================================================
-- FARBEN (WoW Classic Palette)
-- ============================================================
local C = {
    gold        = {0.784, 0.659, 0.294},   -- #c8a84b
    gold_bright = {1.000, 0.843, 0.000},   -- #ffd700
    gold_dim    = {0.400, 0.330, 0.130},
    bg_dark     = {0.110, 0.082, 0.063},   -- #1c1510
    bg_med      = {0.165, 0.122, 0.063},   -- #2a1f10
    bg_light    = {0.200, 0.155, 0.100},
    red_fill    = {0.545, 0.102, 0.039},   -- #8b1a0a
    red_bright  = {0.800, 0.133, 0.000},
    green       = {0.000, 0.800, 0.267},   -- #00cc44
    green_dim   = {0.000, 0.350, 0.110},
    orange      = {1.000, 0.549, 0.000},   -- #ff8c00
    white       = {0.941, 0.910, 0.816},   -- #f0e8d0
    grey        = {0.400, 0.333, 0.267},
    grey_dim    = {0.220, 0.180, 0.140},
}

-- SavedVariables
GuardianHelperDB = GuardianHelperDB or {
    locked = false,
    scale  = 1.0,
    alpha  = 0.95,
    showOutOfCombat = true,
    showRagebar     = true,
    showCooldownText = true,
    showStatusDots  = true,
    soundOnFormLoss = false,
    maulAlert       = true,
    x = nil, y = nil,
}

-- ============================================================
-- HILFSFUNKTIONEN UI
-- ============================================================
local function MakeTex(parent, level)
    local t = parent:CreateTexture(nil, level or "BACKGROUND")
    return t
end

local function SetColor(tex, col, a)
    tex:SetColorTexture(col[1], col[2], col[3], a or 1)
end

local function MakeFont(parent, size, flags)
    local f = parent:CreateFontString(nil, "OVERLAY")
    f:SetFont("Fonts\\FRIZQT__.TTF", size or 10, flags or "OUTLINE")
    return f
end

-- WoW-Style Panel (gold border + dark bg)
local function MakePanel(parent, w, h)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(w, h)
    -- Äußerer Gold-Rahmen
    local outer = MakeTex(f, "BACKGROUND")
    outer:SetAllPoints()
    SetColor(outer, C.gold, 1)
    -- Innerer dunkler Bereich
    local inner = MakeTex(f, "BORDER")
    inner:SetPoint("TOPLEFT",     f, "TOPLEFT",      1, -1)
    inner:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1,  1)
    SetColor(inner, C.bg_dark, 0.97)
    f.inner = inner
    return f
end

-- Gold Separator
local function MakeSep(parent, yOff, xPad)
    local s = MakeTex(parent, "ARTWORK")
    s:SetHeight(1)
    s:SetPoint("TOPLEFT",  parent, "TOPLEFT",  xPad or 4, yOff)
    s:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -(xPad or 4), yOff)
    SetColor(s, C.gold_dim, 0.7)
    return s
end

-- WoW-Style Button
local function MakeButton(parent, w, h, text, onClick)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w, h)
    local bg = MakeTex(b, "BACKGROUND")
    bg:SetAllPoints()
    SetColor(bg, C.gold, 1)
    local bgInner = MakeTex(b, "BORDER")
    bgInner:SetPoint("TOPLEFT",     b, "TOPLEFT",      1, -1)
    bgInner:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -1,  1)
    SetColor(bgInner, C.bg_med, 1)
    b.bgInner = bgInner
    local lbl = MakeFont(b, 9)
    lbl:SetAllPoints()
    lbl:SetJustifyH("CENTER")
    lbl:SetText(text)
    lbl:SetTextColor(C.gold[1], C.gold[2], C.gold[3])
    b.lbl = lbl
    b:SetScript("OnEnter", function() SetColor(bgInner, C.bg_light, 1) end)
    b:SetScript("OnLeave", function() SetColor(bgInner, C.bg_med,   1) end)
    if onClick then b:SetScript("OnClick", onClick) end
    return b
end

-- Checkbox im WoW-Stil
local function MakeCheckbox(parent, label, yOff, db_key)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(160, 14)
    f:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOff)

    local box = CreateFrame("Button", nil, f)
    box:SetSize(12, 12)
    box:SetPoint("LEFT", f, "LEFT", 0, 0)

    local boxBg = MakeTex(box, "BACKGROUND")
    boxBg:SetAllPoints()
    SetColor(boxBg, C.gold, 1)
    local boxInner = MakeTex(box, "BORDER")
    boxInner:SetPoint("TOPLEFT",     box, "TOPLEFT",      1, -1)
    boxInner:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -1,  1)
    SetColor(boxInner, C.bg_dark, 1)

    local check = MakeFont(box, 8)
    check:SetAllPoints()
    check:SetJustifyH("CENTER")
    check:SetText(GuardianHelperDB[db_key] and "|cff00cc44✓|r" or "")

    local lbl = MakeFont(f, 8)
    lbl:SetPoint("LEFT", box, "RIGHT", 4, 0)
    lbl:SetText(label)
    lbl:SetTextColor(C.white[1], C.white[2], C.white[3])

    box:SetScript("OnClick", function()
        GuardianHelperDB[db_key] = not GuardianHelperDB[db_key]
        check:SetText(GuardianHelperDB[db_key] and "|cff00cc44✓|r" or "")
    end)
    return f
end

-- ============================================================
-- HAUPTFRAME
-- ============================================================
local W = 210
local Frame = MakePanel(UIParent, W, 10)
Frame:SetParent(UIParent)
Frame:SetMovable(true)
Frame:EnableMouse(true)
Frame:RegisterForDrag("LeftButton")
Frame:SetScript("OnDragStart", function(s) if not GuardianHelperDB.locked then s:StartMoving() end end)
Frame:SetScript("OnDragStop",  function(s)
    s:StopMovingOrSizing()
    local p, _, _, x, y = s:GetPoint()
    GuardianHelperDB.x = x; GuardianHelperDB.y = y
end)
Frame:SetFrameStrata("MEDIUM")
Frame:SetFrameLevel(10)
Frame:SetClampedToScreen(true)

-- === HEADER ===
local headerBg = MakeTex(Frame, "ARTWORK")
headerBg:SetHeight(18)
headerBg:SetPoint("TOPLEFT",  Frame, "TOPLEFT",   1, -1)
headerBg:SetPoint("TOPRIGHT", Frame, "TOPRIGHT",  -1, -1)
SetColor(headerBg, C.bg_med, 1)

local headerTitle = MakeFont(Frame, 10, "OUTLINE")
headerTitle:SetPoint("LEFT", Frame, "TOPLEFT", 8, -10)
headerTitle:SetText("🐻  GUARDIAN")
headerTitle:SetTextColor(C.gold[1], C.gold[2], C.gold[3])

local headerDot = MakeFont(Frame, 9, "OUTLINE")
headerDot:SetPoint("RIGHT", Frame, "TOPRIGHT", -6, -10)
headerDot:SetText("●")
headerDot:SetTextColor(C.green[1], C.green[2], C.green[3])

MakeSep(Frame, -19, 4)

-- === RAGE ===
local rageLabel = MakeFont(Frame, 7, "OUTLINE")
rageLabel:SetPoint("TOPLEFT", Frame, "TOPLEFT", 7, -26)
rageLabel:SetText("RAGE")
rageLabel:SetTextColor(C.gold_dim[1], C.gold_dim[2], C.gold_dim[3])

local rageVal = MakeFont(Frame, 8, "OUTLINE")
rageVal:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -6, -26)
rageVal:SetText("0  /  100")
rageVal:SetTextColor(C.white[1], C.white[2], C.white[3])

-- Track
local rageTrack = MakeTex(Frame, "ARTWORK")
rageTrack:SetHeight(8)
rageTrack:SetPoint("TOPLEFT",  Frame, "TOPLEFT",  6, -36)
rageTrack:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -6, -36)
SetColor(rageTrack, C.bg_dark, 1)

-- Border um Track
local rageTrackBorder = MakeTex(Frame, "BORDER")
rageTrackBorder:SetPoint("TOPLEFT",     rageTrack, "TOPLEFT",      -1,  1)
rageTrackBorder:SetPoint("BOTTOMRIGHT", rageTrack, "BOTTOMRIGHT",   1, -1)
SetColor(rageTrackBorder, C.gold_dim, 0.5)

local rageFill = MakeTex(Frame, "ARTWORK")
rageFill:SetHeight(8)
rageFill:SetPoint("TOPLEFT", rageTrack, "TOPLEFT", 0, 0)
SetColor(rageFill, C.red_fill, 1)

-- Highlight oben auf Bar
local rageHL = MakeTex(Frame, "OVERLAY")
rageHL:SetHeight(2)
rageHL:SetPoint("TOPLEFT",  rageTrack, "TOPLEFT",  0, 0)
rageHL:SetPoint("TOPRIGHT", rageTrack, "TOPRIGHT", 0, 0)
SetColor(rageHL, {1,1,1}, 0.06)

MakeSep(Frame, -46, 4)

-- === MAUL ===
local maulBg = MakeTex(Frame, "ARTWORK")
maulBg:SetHeight(16)
maulBg:SetPoint("TOPLEFT",  Frame, "TOPLEFT",  1, -48)
maulBg:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -1, -48)
SetColor(maulBg, C.bg_dark, 1)

local maulIcon = MakeFont(Frame, 8, "OUTLINE")
maulIcon:SetPoint("LEFT", Frame, "TOPLEFT", 8, -56)
maulIcon:SetText("▪")
maulIcon:SetTextColor(C.grey[1], C.grey[2], C.grey[3])

local maulText = MakeFont(Frame, 8, "OUTLINE")
maulText:SetPoint("LEFT", Frame, "TOPLEFT", 18, -56)
maulText:SetText("Maul — nicht aktiv")
maulText:SetTextColor(C.grey[1], C.grey[2], C.grey[3])

MakeSep(Frame, -64, 4)

-- === FF & DR ===
-- FF
local ffDot = MakeFont(Frame, 7, "OUTLINE")
ffDot:SetPoint("TOPLEFT", Frame, "TOPLEFT", 7, -72)
ffDot:SetText("●")
ffDot:SetTextColor(C.grey[1], C.grey[2], C.grey[3])

local ffLbl = MakeFont(Frame, 7, "OUTLINE")
ffLbl:SetPoint("TOPLEFT", Frame, "TOPLEFT", 16, -72)
ffLbl:SetText("FF")
ffLbl:SetTextColor(C.gold_dim[1], C.gold_dim[2], C.gold_dim[3])

local ffVal = MakeFont(Frame, 8, "OUTLINE")
ffVal:SetPoint("TOPLEFT", Frame, "TOPLEFT", 30, -72)
ffVal:SetText("---")
ffVal:SetTextColor(C.grey[1], C.grey[2], C.grey[3])

-- Vertikaler Trenner
local vSep = MakeTex(Frame, "ARTWORK")
vSep:SetSize(1, 10)
vSep:SetPoint("TOPLEFT", Frame, "TOPLEFT", W/2, -68)
SetColor(vSep, C.gold_dim, 0.5)

-- DR
local drDot = MakeFont(Frame, 7, "OUTLINE")
drDot:SetPoint("TOPLEFT", Frame, "TOPLEFT", W/2 + 5, -72)
drDot:SetText("●")
drDot:SetTextColor(C.grey[1], C.grey[2], C.grey[3])

local drLbl = MakeFont(Frame, 7, "OUTLINE")
drLbl:SetPoint("TOPLEFT", Frame, "TOPLEFT", W/2 + 14, -72)
drLbl:SetText("DR")
drLbl:SetTextColor(C.gold_dim[1], C.gold_dim[2], C.gold_dim[3])

local drVal = MakeFont(Frame, 8, "OUTLINE")
drVal:SetPoint("TOPLEFT", Frame, "TOPLEFT", W/2 + 28, -72)
drVal:SetText("---")
drVal:SetTextColor(C.grey[1], C.grey[2], C.grey[3])

MakeSep(Frame, -79, 4)

-- === COOLDOWNS ===
local CD_SZ  = 26
local CD_GAP = 2
local cdFrames = {}
local nCD = #CD_SLOTS
local totalCDW = nCD * CD_SZ + (nCD-1) * CD_GAP
local cdStartX = math.floor((W - totalCDW) / 2)

for i, key in ipairs(CD_SLOTS) do
    local xPos = cdStartX + (i-1) * (CD_SZ + CD_GAP)

    local f = CreateFrame("Frame", nil, Frame)
    f:SetSize(CD_SZ, CD_SZ + 9)
    f:SetPoint("TOPLEFT", Frame, "TOPLEFT", xPos, -82)

    -- Gold Rahmen
    local border = MakeTex(f, "BACKGROUND")
    border:SetAllPoints()
    SetColor(border, C.gold, 1)
    f.border = border

    -- Inneres
    local inner = MakeTex(f, "BORDER")
    inner:SetPoint("TOPLEFT",     f, "TOPLEFT",      1, -1)
    inner:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",  -1, 8)
    SetColor(inner, C.bg_dark, 1)
    f.inner = inner

    -- Timer
    local timer = MakeFont(f, 9, "OUTLINE")
    timer:SetPoint("CENTER", f, "CENTER", 0, 4)
    timer:SetText("?")
    timer:SetTextColor(C.grey[1], C.grey[2], C.grey[3])
    f.timer = timer

    -- Label
    local lbl = MakeFont(f, 6, "OUTLINE")
    lbl:SetPoint("BOTTOM", f, "BOTTOM", 0, 1)
    lbl:SetText(SPELL_GROUPS[key].shortLabel or SPELL_GROUPS[key].label)
    lbl:SetTextColor(C.gold_dim[1], C.gold_dim[2], C.gold_dim[3])
    f.lbl = lbl

    f.groupKey   = key
    f.learnLevel = SPELL_GROUPS[key].ranks[1].level
    cdFrames[i]  = f
end

-- Footer
local footerText = MakeFont(Frame, 6, "OUTLINE")
footerText:SetPoint("BOTTOM", Frame, "BOTTOM", 0, 3)
footerText:SetText("/gh lock  ·  /gh help")
footerText:SetTextColor(C.grey_dim[1], C.grey_dim[2], C.grey_dim[3])

-- Frame Höhe setzen
local FRAME_H = 82 + CD_SZ + 9 + 8
Frame:SetHeight(FRAME_H)

-- ============================================================
-- MINIMAP BUTTON
-- ============================================================
local MinimapBtn = CreateFrame("Button", "GuardianHelperMinimapBtn", Minimap)
MinimapBtn:SetSize(28, 28)
MinimapBtn:SetFrameStrata("MEDIUM")
MinimapBtn:SetFrameLevel(8)

-- Runder Hintergrund
local mmBg = MinimapBtn:CreateTexture(nil, "BACKGROUND")
mmBg:SetAllPoints()
mmBg:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
-- Goldener Kreis
local mmCircle = MinimapBtn:CreateTexture(nil, "BORDER")
mmCircle:SetSize(22, 22)
mmCircle:SetPoint("CENTER")
SetColor(mmCircle, C.gold, 1)
local mmInner = MinimapBtn:CreateTexture(nil, "ARTWORK")
mmInner:SetSize(20, 20)
mmInner:SetPoint("CENTER")
SetColor(mmInner, C.bg_dark, 1)

local mmIcon = MakeFont(MinimapBtn, 12, "OUTLINE")
mmIcon:SetAllPoints()
mmIcon:SetJustifyH("CENTER")
mmIcon:SetJustifyV("MIDDLE")
mmIcon:SetText("🐻")

-- Position auf der Minimap
local mmAngle = 220
local function UpdateMinimapPos()
    local rad = math.rad(mmAngle)
    local x = math.cos(rad) * 80
    local y = math.sin(rad) * 80
    MinimapBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end
UpdateMinimapPos()

-- Drag auf Minimap
MinimapBtn:RegisterForDrag("LeftButton")
MinimapBtn:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local scale  = UIParent:GetEffectiveScale()
        cx, cy = cx/scale, cy/scale
        mmAngle = math.deg(math.atan2(cy - my, cx - mx))
        UpdateMinimapPos()
    end)
end)
MinimapBtn:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)

MinimapBtn:SetScript("OnClick", function()
    if Frame:IsShown() then Frame:Hide()
    else Frame:Show() end
end)

MinimapBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("GuardianHelper v"..GH_VERSION, C.gold[1], C.gold[2], C.gold[3])
    GameTooltip:AddLine("Klick: Ein/Ausblenden", 1, 1, 1)
    GameTooltip:AddLine("Drag: Position ändern", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)
MinimapBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- ============================================================
-- CONFIG PANEL
-- ============================================================
local ConfigFrame = MakePanel(UIParent, 200, 220)
ConfigFrame:SetPoint("CENTER", UIParent, "CENTER", 50, 0)
ConfigFrame:SetFrameStrata("HIGH")
ConfigFrame:SetFrameLevel(50)
ConfigFrame:Hide()
ConfigFrame:EnableMouse(true)
ConfigFrame:SetMovable(true)
ConfigFrame:RegisterForDrag("LeftButton")
ConfigFrame:SetScript("OnDragStart", function(s) s:StartMoving() end)
ConfigFrame:SetScript("OnDragStop",  function(s) s:StopMovingOrSizing() end)

-- Config Header
local cfgHeader = MakeTex(ConfigFrame, "ARTWORK")
cfgHeader:SetHeight(18)
cfgHeader:SetPoint("TOPLEFT",  ConfigFrame, "TOPLEFT",  1, -1)
cfgHeader:SetPoint("TOPRIGHT", ConfigFrame, "TOPRIGHT", -1, -1)
SetColor(cfgHeader, C.bg_med, 1)

local cfgTitle = MakeFont(ConfigFrame, 9, "OUTLINE")
cfgTitle:SetPoint("CENTER", ConfigFrame, "TOP", 0, -10)
cfgTitle:SetText("⚙  GuardianHelper Config")
cfgTitle:SetTextColor(C.gold[1], C.gold[2], C.gold[3])

local cfgClose = CreateFrame("Button", nil, ConfigFrame)
cfgClose:SetSize(14, 14)
cfgClose:SetPoint("TOPRIGHT", ConfigFrame, "TOPRIGHT", -4, -3)
local cfgCloseLbl = MakeFont(cfgClose, 9, "OUTLINE")
cfgCloseLbl:SetAllPoints()
cfgCloseLbl:SetJustifyH("CENTER")
cfgCloseLbl:SetText("✕")
cfgCloseLbl:SetTextColor(C.gold[1], C.gold[2], C.gold[3])
cfgClose:SetScript("OnClick", function() ConfigFrame:Hide() end)

MakeSep(ConfigFrame, -19, 4)

-- Checkboxen
local cb1 = MakeCheckbox(ConfigFrame, "Maul Queue Alert",       -26, "maulAlert")
local cb2 = MakeCheckbox(ConfigFrame, "Sound bei Formverlust",  -42, "soundOnFormLoss")
local cb3 = MakeCheckbox(ConfigFrame, "Nur in Kampf anzeigen",  -58, "showOutOfCombat")

MakeSep(ConfigFrame, -74, 4)

-- Section Label
local dispLbl = MakeFont(ConfigFrame, 7, "OUTLINE")
dispLbl:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", 10, -80)
dispLbl:SetText("DISPLAY")
dispLbl:SetTextColor(C.gold_dim[1], C.gold_dim[2], C.gold_dim[3])

local cb4 = MakeCheckbox(ConfigFrame, "Ragebar anzeigen",   -90,  "showRagebar")
local cb5 = MakeCheckbox(ConfigFrame, "Cooldown-Text",      -106, "showCooldownText")
local cb6 = MakeCheckbox(ConfigFrame, "Status-Dots",        -122, "showStatusDots")

MakeSep(ConfigFrame, -136, 4)

-- Opacity Slider (fake, WoW-Style)
local opLbl = MakeFont(ConfigFrame, 7, "OUTLINE")
opLbl:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", 10, -142)
opLbl:SetText("Opacity")
opLbl:SetTextColor(C.gold_dim[1], C.gold_dim[2], C.gold_dim[3])

local opSlider = CreateFrame("Slider", "GHOpacitySlider", ConfigFrame, "OptionsSliderTemplate")
opSlider:SetSize(170, 14)
opSlider:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", 10, -158)
opSlider:SetMinMaxValues(0.3, 1.0)
opSlider:SetValue(GuardianHelperDB.alpha)
opSlider:SetValueStep(0.05)
_G[opSlider:GetName().."Low"]:SetText("30%")
_G[opSlider:GetName().."High"]:SetText("100%")
_G[opSlider:GetName().."Text"]:SetText(string.format("%.0f%%", GuardianHelperDB.alpha * 100))
opSlider:SetScript("OnValueChanged", function(self, val)
    GuardianHelperDB.alpha = val
    Frame:SetAlpha(val)
    _G[self:GetName().."Text"]:SetText(string.format("%.0f%%", val * 100))
end)

MakeSep(ConfigFrame, -178, 4)

-- Buttons
local btnSave = MakeButton(ConfigFrame, 80, 18, "Speichern", function()
    print("|cff" .. string.format("%02x%02x%02x", math.floor(C.gold[1]*255), math.floor(C.gold[2]*255), math.floor(C.gold[3]*255)) .. "GuardianHelper:|r Einstellungen gespeichert.")
    ConfigFrame:Hide()
end)
btnSave:SetPoint("BOTTOMLEFT", ConfigFrame, "BOTTOMLEFT", 8, 6)

local btnCancel = MakeButton(ConfigFrame, 80, 18, "Abbrechen", function()
    ConfigFrame:Hide()
end)
btnCancel:SetPoint("BOTTOMRIGHT", ConfigFrame, "BOTTOMRIGHT", -8, 6)

-- ============================================================
-- SPELL CACHE & ACTION BAR UPDATE
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
                        spellCache[groupKey] = {highestID=spellID, highestLevel=rd.level, highestSlot=i, allKnownIDs={}}
                    elseif rd.level > spellCache[groupKey].highestLevel then
                        spellCache[groupKey].highestID=spellID; spellCache[groupKey].highestLevel=rd.level; spellCache[groupKey].highestSlot=i
                    end
                    spellCache[groupKey].allKnownIDs[spellID] = true
                end
            end
        end
        i = i + 1
    end
end

local function UpdateActionBarsForGroup(groupKey)
    local group = SPELL_GROUPS[groupKey]
    if not group.autoUpdate then return end
    local cache = spellCache[groupKey]
    if not cache then return end
    local updated = 0
    for slot = 1, 120 do
        local aType, aID = GetActionInfo(slot)
        if aType == "spell" and aID ~= cache.highestID and cache.allKnownIDs[aID] then
            ClearCursor(); PickupSpellBookItem(cache.highestSlot, BOOKTYPE_SPELL); PlaceAction(slot); ClearCursor()
            updated = updated + 1
        end
    end
    if updated > 0 then
        print("|cffC8A84BGuardianHelper:|r " .. (GetSpellInfo(cache.highestID) or groupKey) .. " aktualisiert ("..updated.."x)")
    end
end

local function UpdateAllActionBars()
    for k in pairs(SPELL_GROUPS) do UpdateActionBarsForGroup(k) end
end

-- ============================================================
-- MAUL TRACKING
-- ============================================================
local State = {maulQueued=false}
local maulIDs = {}
local function RebuildMaulIDs()
    maulIDs = {}
    local c = spellCache["MAUL"]
    if c then for id in pairs(c.allKnownIDs) do maulIDs[id] = true end end
end

-- ============================================================
-- HILFSFUNKTIONEN STATUS
-- ============================================================
local function GetTargetDebuffRem(spellID)
    local n = GetSpellInfo(spellID); if not n then return nil end
    for i=1,40 do
        local name,_,_,_,_,_,exp = UnitDebuff("target",i)
        if not name then break end
        if name==n then return exp and exp>0 and (exp-GetTime()) or math.huge end
    end
    return nil
end

local function GetPlayerBuffRem(spellID)
    local n = GetSpellInfo(spellID); if not n then return nil end
    for i=1,40 do
        local name,_,_,_,_,_,exp = UnitBuff("player",i)
        if not name then break end
        if name==n then return exp and exp>0 and (exp-GetTime()) or math.huge end
    end
    return nil
end

local function IsInBearForm()
    for _,id in ipairs(BEAR_FORM_IDS) do if GetPlayerBuffRem(id) then return true,false end end
    for _,id in ipairs(DIRE_BEAR_IDS) do if GetPlayerBuffRem(id) then return true,true  end end
    return false,false
end

local function GetDebuffOnTarget(groupKey)
    local c = spellCache[groupKey]; if not c then return nil end
    for id in pairs(c.allKnownIDs) do local r=GetTargetDebuffRem(id); if r then return r end end
    return nil
end

local function GetGroupCD(groupKey)
    local c = spellCache[groupKey]; if not c then return nil end
    local s,d = GetSpellCooldown(c.highestID)
    if not s or s==0 then return 0 end
    local r=(s+d)-GetTime(); return r>0 and r or 0
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
        Frame:SetAlpha(GuardianHelperDB.alpha)
        Frame:SetScale(GuardianHelperDB.scale)
        if GuardianHelperDB.x then
            Frame:ClearAllPoints()
            Frame:SetPoint("CENTER", UIParent, "CENTER", GuardianHelperDB.x, GuardianHelperDB.y)
        else
            Frame:SetPoint("CENTER", UIParent, "CENTER", 350, 0)
        end
        print("|cffC8A84BGuardianHelper|r v"..GH_VERSION.." — Bereit. 🐻  |cffaaaaaa/gh help|r")

    elseif event == "PLAYER_LEVEL_UP" then
        local lvl = ...
        local df=CreateFrame("Frame"); local el=0
        df:SetScript("OnUpdate",function(s,e) el=el+e; if el>=0.5 then s:SetScript("OnUpdate",nil); RebuildSpellCache(); RebuildMaulIDs(); UpdateAllActionBars(); print("|cffC8A84BGuardianHelper:|r Level "..lvl.." — Aktionsleisten geprüft!") end end)

    elseif event == "SPELLS_CHANGED" then
        RebuildSpellCache(); RebuildMaulIDs()

    elseif event == "LEARNED_SPELL_IN_TAB" then
        local df=CreateFrame("Frame"); local el=0
        df:SetScript("OnUpdate",function(s,e) el=el+e; if el>=0.3 then s:SetScript("OnUpdate",nil); RebuildSpellCache(); RebuildMaulIDs(); UpdateAllActionBars() end end)

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _,subEvent,_,srcGUID,_,_,_,_,_,_,_,spellID = ...
        if srcGUID ~= UnitGUID("player") then return end
        if subEvent=="SPELL_CAST_START" and maulIDs[spellID] then State.maulQueued=true
        elseif (subEvent=="SPELL_DAMAGE" or subEvent=="SPELL_MISSED") and maulIDs[spellID] then State.maulQueued=false end
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
    local rage    = UnitPower("player",1)
    local rageMax = UnitPowerMax("player",1)
    if rageMax==0 then rageMax=100 end
    local pct = rage/rageMax
    local tw = rageTrack:GetWidth()
    if tw and tw > 0 then
        rageFill:SetWidth(math.max(tw*pct, 1))
    end
    rageVal:SetText(rage.."  /  "..rageMax)

    if pct>=0.7 then
        SetColor(rageFill, C.red_bright, 1)
    elseif pct>=0.35 then
        SetColor(rageFill, C.red_fill, 1)
    else
        SetColor(rageFill, {0.3,0.05,0.02}, 1)
    end

    -- BEAR FORM
    local inBear, isDire = IsInBearForm()
    if inBear then
        headerDot:SetTextColor(C.green[1], C.green[2], C.green[3])
        headerTitle:SetText(isDire and "🐻  DIRE BEAR" or "🐻  BEAR FORM")
        headerTitle:SetTextColor(C.gold[1], C.gold[2], C.gold[3])
    else
        headerDot:SetTextColor(C.red_bright[1] or 0.8, 0.133, 0)
        headerTitle:SetText("⚠  KEINE BÄRENFORM")
        headerTitle:SetTextColor(C.red_bright[1] or 0.8, 0.2, 0.0)
    end

    -- MAUL
    if State.maulQueued then
        SetColor(maulBg, {0.20,0.10,0.00}, 1)
        maulIcon:SetTextColor(C.orange[1], C.orange[2], C.orange[3])
        maulText:SetText("⚔  MAUL READY")
        maulText:SetTextColor(C.orange[1], C.orange[2], C.orange[3])
    else
        SetColor(maulBg, C.bg_dark, 1)
        maulIcon:SetTextColor(C.grey[1], C.grey[2], C.grey[3])
        maulText:SetText("Maul — nicht aktiv")
        maulText:SetTextColor(C.grey[1], C.grey[2], C.grey[3])
    end

    -- FAERIE FIRE
    if UnitExists("target") then
        local r = GetDebuffOnTarget("FAERIE_FIRE")
        local known = spellCache["FAERIE_FIRE"] ~= nil
        if not known then
            ffDot:SetTextColor(C.grey_dim[1],C.grey_dim[2],C.grey_dim[3])
            ffVal:SetText("--"); ffVal:SetTextColor(C.grey_dim[1],C.grey_dim[2],C.grey_dim[3])
        elseif r then
            ffDot:SetTextColor(C.green[1],C.green[2],C.green[3])
            local t = r==math.huge and "∞" or string.format("%.0fs",r)
            ffVal:SetText(t)
            ffVal:SetTextColor((r~=math.huge and r<4) and C.orange[1] or C.green[1],
                               (r~=math.huge and r<4) and C.orange[2] or C.green[2],
                               (r~=math.huge and r<4) and C.orange[3] or C.green[3])
        else
            ffDot:SetTextColor(C.red_bright[1] or 0.8,0.133,0)
            ffVal:SetText("!"); ffVal:SetTextColor(C.red_bright[1] or 0.8,0.133,0)
        end
    else
        ffDot:SetTextColor(C.grey_dim[1],C.grey_dim[2],C.grey_dim[3])
        ffVal:SetText("---"); ffVal:SetTextColor(C.grey_dim[1],C.grey_dim[2],C.grey_dim[3])
    end

    -- DEMO ROAR
    if UnitExists("target") then
        local r = GetDebuffOnTarget("DEMO_ROAR")
        if r then
            drDot:SetTextColor(C.green[1],C.green[2],C.green[3])
            local t = r==math.huge and "∞" or string.format("%.0fs",r)
            drVal:SetText(t)
            drVal:SetTextColor((r~=math.huge and r<3) and C.orange[1] or C.green[1],
                               (r~=math.huge and r<3) and C.orange[2] or C.green[2],
                               (r~=math.huge and r<3) and C.orange[3] or C.green[3])
        else
            drDot:SetTextColor(C.red_bright[1] or 0.8,0.133,0)
            drVal:SetText("!"); drVal:SetTextColor(C.red_bright[1] or 0.8,0.133,0)
        end
    else
        drDot:SetTextColor(C.grey_dim[1],C.grey_dim[2],C.grey_dim[3])
        drVal:SetText("---"); drVal:SetTextColor(C.grey_dim[1],C.grey_dim[2],C.grey_dim[3])
    end

    -- COOLDOWNS
    for _, f in ipairs(cdFrames) do
        local key   = f.groupKey
        local cache = spellCache[key]
        if not cache then
            SetColor(f.border, C.grey_dim, 0.4)
            SetColor(f.inner, {0.07,0.05,0.03}, 1)
            f.timer:SetText(f.learnLevel)
            f.timer:SetTextColor(C.grey_dim[1],C.grey_dim[2],C.grey_dim[3])
            f.lbl:SetTextColor(C.grey_dim[1],C.grey_dim[2],C.grey_dim[3])
        else
            f.lbl:SetTextColor(C.gold_dim[1],C.gold_dim[2],C.gold_dim[3])
            local cd = GetGroupCD(key) or 0
            if cd<=0 then
                SetColor(f.border, C.gold, 1)
                SetColor(f.inner, {0.05,0.15,0.05}, 1)
                f.timer:SetText("✓")
                f.timer:SetTextColor(C.green[1],C.green[2],C.green[3])
            elseif cd<5 then
                SetColor(f.border, C.orange, 0.9)
                SetColor(f.inner, {0.20,0.10,0.00}, 1)
                f.timer:SetText(string.format("%.1f",cd))
                f.timer:SetTextColor(C.orange[1],C.orange[2],C.orange[3])
            else
                SetColor(f.border, C.gold_dim, 0.6)
                SetColor(f.inner, C.bg_dark, 1)
                f.timer:SetText(string.format("%d",math.ceil(cd)))
                f.timer:SetTextColor(C.grey[1],C.grey[2],C.grey[3])
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
    if msg=="lock" then
        GuardianHelperDB.locked = not GuardianHelperDB.locked
        print("|cffC8A84BGuardianHelper:|r " .. (GuardianHelperDB.locked and "Gesperrt." or "Entsperrt."))
    elseif msg=="hide"   then Frame:Hide()
    elseif msg=="show"   then Frame:Show()
    elseif msg=="config" or msg=="cfg" then
        if ConfigFrame:IsShown() then ConfigFrame:Hide() else ConfigFrame:Show() end
    elseif msg=="reset"  then
        Frame:ClearAllPoints(); Frame:SetPoint("CENTER",UIParent,"CENTER",350,0)
        GuardianHelperDB.x,GuardianHelperDB.y=nil,nil
    elseif msg=="update" then
        RebuildSpellCache(); RebuildMaulIDs(); UpdateAllActionBars()
        print("|cffC8A84BGuardianHelper:|r Aktionsleisten aktualisiert.")
    elseif msg=="status" then
        print("|cffC8A84BGuardianHelper — Spells:|r")
        for k,g in pairs(SPELL_GROUPS) do
            local c=spellCache[k]
            if c then print("  "..g.label..": "..(GetSpellInfo(c.highestID) or "?").." (Lvl "..c.highestLevel..")")
            else print("  |cff555555"..g.label..": ab Lvl "..g.ranks[1].level.."|r") end
        end
    else
        print("|cffC8A84BGuardianHelper v"..GH_VERSION.."|r")
        print("  /gh lock · hide · show · reset · update · status")
        print("  /gh config  — Einstellungen öffnen")
    end
end
