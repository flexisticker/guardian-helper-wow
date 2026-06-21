-- ============================================================
-- GuardianHelper v4.9.1 — Aggro Monitor + Config
-- Guardian Druid Tank — TBC Classic 2.5.5
-- ============================================================
local VERSION = "4.9.2"

local DB
local LOCALE = GetLocale()
local IS_DE  = (LOCALE == "deDE")

-- ============================================================
-- LOKALISIERUNG
-- ============================================================
local L = {
    BEAR_FORM      = IS_DE and "BAERENGESTALT"    or "BEAR FORM",
    DIRE_BEAR      = IS_DE and "WILDE BAER"       or "DIRE BEAR",
    NO_BEAR        = IS_DE and "KEINE BAERENFORM" or "NO BEAR FORM",
    MAUL_READY     = IS_DE and "KRALLENHIEB"      or "MAUL QUEUED",
    MAUL_INACTIVE  = IS_DE and "kein Maul"        or "Maul idle",
    CD_BASH        = IS_DE and "Hieb"    or "Bash",
    CD_GROWL       = IS_DE and "Knurr"   or "Growl",
    CD_ENRAGE      = IS_DE and "Rasen"   or "Enrage",
    CD_FREG        = IS_DE and "F.Reg"   or "F.Reg",
    CD_BARK        = IS_DE and "Borke"   or "Bark",
    CD_MANGLE      = IS_DE and "Zerr"    or "Mangle",
    CD_LACERATE    = IS_DE and "Aufr"    or "Lacerate",
    FF_LABEL       = IS_DE and "FEF"     or "FF",
    DR_LABEL       = IS_DE and "Demo"    or "DR",
    READY          = IS_DE and "OK"      or "OK",
    AA_ACTIVE      = IS_DE and "Auto aktiv"  or "Auto active",
    AA_OFF         = IS_DE and "AUTO AUS"    or "AUTO OFF",
    AA_IDLE        = IS_DE and "kein Kampf"  or "no combat",
    BUFFS_HDR      = IS_DE and "BUFFS"   or "BUFFS",
    FOOTER         = "/gh lock  |  /gh config  |  /gh help",
    CFG_TITLE      = IS_DE and "[ GuardianHelper Konfig ]" or "[ GuardianHelper Config ]",
    CFG_SAVE       = IS_DE and "Speichern" or "Save",
    CFG_CANCEL     = IS_DE and "Abbrechen" or "Cancel",
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
    BASH           = { label=L.CD_BASH,     ranks={{id=5211,lv=14},{id=6798,lv=22},{id=8983,lv=32},{id=25515,lv=42}} },
    GROWL          = { label=L.CD_GROWL,    ranks={{id=6795,lv=10}} },
    ENRAGE         = { label=L.CD_ENRAGE,   ranks={{id=5229,lv=14}} },
    FRENZIED_REGEN = { label=L.CD_FREG,     ranks={{id=22842,lv=36},{id=22895,lv=46},{id=22896,lv=56},{id=26999,lv=66}} },
    BARKSKIN       = { label=L.CD_BARK,     ranks={{id=22812,lv=44}} },
    MANGLE_BEAR    = { label=L.CD_MANGLE,   ranks={{id=33878,lv=60},{id=33986,lv=66}} },
    LACERATE       = { label=L.CD_LACERATE, ranks={{id=33745,lv=66}} },
}
local CD_ORDER  = { "BASH","GROWL","ENRAGE","FRENZIED_REGEN","BARKSKIN","MANGLE_BEAR","LACERATE" }
local MAUL_IDS  = {[6807]=true,[8972]=true,[9745]=true,[9880]=true,[9881]=true,[26996]=true,[26997]=true}
local BEAR_IDS  = {5487, 9634}
local FF_IDS    = {16857,17390,17391,17392,27011}
local DR_IDS    = {99,1735,9490,9747,9898,26998}

local BUFF_DEFS = {
    { key="MOTW",   label=IS_DE and "MotW"   or "MotW",   minLevel=1,
      ids={1126,5232,6756,5234,8907,9884,9885,26990} },
    { key="THORNS", label=IS_DE and "Dornen" or "Thorns", minLevel=6,
      ids={467,782,1075,8914,9756,9910,26992} },
}

-- Kuratierte Blizzard-Sounds (mit Preview-Funktion)
local SOUNDS = {
    { name="Alarm Kurz",   file="Sound\\Interface\\AlarmClockWarning1.ogg" },
    { name="Alarm Mittel", file="Sound\\Interface\\AlarmClockWarning2.ogg" },
    { name="Alarm Lang",   file="Sound\\Interface\\AlarmClockWarning3.ogg" },
    { name="PvP Flagge",   file="Sound\\Spells\\PVPFlagTaken.ogg" },
    { name="Murloc",       file="Sound\\Creature\\Murloc\\MurlocAggro.ogg" },
    { name="Kampfschrei",  file="Sound\\Character\\Human\\Male\\HumanMaleBattleCry1.ogg" },
}
local function PlaySnd(idx)
    local s = SOUNDS[idx or 1]
    if s then PlaySoundFile(s.file, "SFX") end
end

-- ============================================================
-- FARBEN — Modern Dark Gaming (Electric Blue + Teal)
-- ============================================================
local BG     = {0.03, 0.03, 0.08, 0.94}   -- Haupt-BG (dunkles Blau-Schwarz)
local BG2    = {0.07, 0.07, 0.14, 1.00}   -- Sektion-BG (etwas heller)
local BGBAR  = {0.04, 0.04, 0.10, 1.00}   -- Balken-BG
local BDR    = {0.10, 0.65, 1.00, 1.00}   -- Electric-Blue Rahmen
local ACCENT = {0.00, 0.82, 0.68, 1.00}   -- Teal Akzent (Druiden-Gruen)
local SEP    = {0.12, 0.55, 0.90, 0.22}   -- Gedimmte blaue Trennlinie
local GREEN  = {0.20, 1.00, 0.42, 1.00}   -- Leuchtendes Gruen
local ORANGE = {1.00, 0.62, 0.05, 1.00}   -- Orange Warnung
local RED    = {1.00, 0.22, 0.08, 1.00}   -- Rot Gefahr
local REDBR  = {1.00, 0.32, 0.12, 1.00}   -- Helles Rot
local WHITE  = {0.88, 0.88, 0.95, 1.00}   -- Fast-Weiss Text
local DIM    = {0.40, 0.44, 0.58, 1.00}   -- Gedimmtes Blau-Grau
local GOLD   = {1.00, 0.82, 0.00, 1.00}   -- WoW-Gold (CD-Slots)
local DGOLD  = {0.75, 0.58, 0.00, 1.00}   -- Dunkles Gold
local DKBG   = {0.02, 0.02, 0.06, 1.00}   -- Sehr dunkler Hintergrund

-- ============================================================
-- HILFSFUNKTIONEN
-- ============================================================
local function CT(parent, level, r, g, b, a)
    local t = parent:CreateTexture(nil, level or "BACKGROUND")
    t:SetColorTexture(r, g, b, a or 1)
    return t
end

local function CF(parent, size, r, g, b, bold)
    local f = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local font = bold and "Fonts\\MORPHEUS.TTF" or "Fonts\\FRIZQT__.TTF"
    f:SetFont(font, size or 9, "OUTLINE")
    f:SetTextColor(r or 1, g or 1, b or 1)
    return f
end

local function Sep(parent, y)
    local s = CT(parent, "ARTWORK", SEP[1], SEP[2], SEP[3], SEP[4])
    s:SetHeight(1)
    s:SetPoint("TOPLEFT",  parent, "TOPLEFT",  3, y)
    s:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -3, y)
    return s
end

-- Erzeugt einen dünnen farbigen Rahmen um ein Frame
local function AddBorder(f, r, g, b, a, sz)
    sz = sz or 1
    a  = a  or 1
    local sides = {
        CT(f,"OVERLAY",r,g,b,a), CT(f,"OVERLAY",r,g,b,a),
        CT(f,"OVERLAY",r,g,b,a), CT(f,"OVERLAY",r,g,b,a),
    }
    sides[1]:SetPoint("TOPLEFT",     f,"TOPLEFT",     0,  0); sides[1]:SetPoint("TOPRIGHT",    f,"TOPRIGHT",    0, -sz+1); sides[1]:SetHeight(sz)
    sides[2]:SetPoint("BOTTOMLEFT",  f,"BOTTOMLEFT",  0, sz-1); sides[2]:SetPoint("BOTTOMRIGHT", f,"BOTTOMRIGHT",  0,  0); sides[2]:SetHeight(sz)
    sides[3]:SetPoint("TOPLEFT",     f,"TOPLEFT",     0,  0); sides[3]:SetPoint("BOTTOMLEFT",  f,"BOTTOMLEFT",  sz-1,  0); sides[3]:SetWidth(sz)
    sides[4]:SetPoint("TOPRIGHT",    f,"TOPRIGHT",    0,  0); sides[4]:SetPoint("BOTTOMRIGHT", f,"BOTTOMRIGHT", -sz+1, 0); sides[4]:SetWidth(sz)
    return sides
end

-- ============================================================
-- DIMENSIONEN
-- ============================================================
local W = 218

-- ============================================================
-- HAUPTRAHMEN
-- ============================================================
local Frame = CreateFrame("Frame", "GuardianHelperFrame", UIParent)
Frame:SetWidth(W)
Frame:SetHeight(160)
Frame:SetPoint("CENTER", UIParent, "CENTER", 350, 0)
Frame:SetMovable(true)
Frame:EnableMouse(true)
Frame:RegisterForDrag("LeftButton")
Frame:SetScript("OnDragStart", function(s)
    if not (DB and DB.locked) then s:StartMoving() end
end)
Frame:SetScript("OnDragStop", function(s)
    s:StopMovingOrSizing()
    if DB then local _,_,_,x,y = s:GetPoint(); DB.x=x; DB.y=y end
end)
Frame:SetFrameStrata("MEDIUM")
Frame:SetClampedToScreen(true)

-- Haupt-Hintergrund
local fBG = CT(Frame, "BACKGROUND", BG[1], BG[2], BG[3], BG[4])
fBG:SetAllPoints()

-- Electric-Blue Rahmen (1px aussen)
AddBorder(Frame, BDR[1], BDR[2], BDR[3], 0.85, 1)

-- ============================================================
-- HEADER (20px)
-- ============================================================
local hBG = CT(Frame, "BORDER", BG2[1], BG2[2], BG2[3], 1)
hBG:SetHeight(20)
hBG:SetPoint("TOPLEFT",  Frame, "TOPLEFT",  1, -1)
hBG:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -1, -1)

-- Teal Akzent-Linie links im Header
local hAccent = CT(Frame, "ARTWORK", ACCENT[1], ACCENT[2], ACCENT[3], 1)
hAccent:SetSize(2, 20)
hAccent:SetPoint("TOPLEFT", Frame, "TOPLEFT", 1, -1)

-- Bear Form Icon (klein, 14x14) im Header
local hIcon = Frame:CreateTexture(nil, "ARTWORK")
hIcon:SetSize(14, 14)
hIcon:SetPoint("LEFT", Frame, "TOPLEFT", 8, -11)
local bearTex = GetSpellTexture(5487) or GetSpellTexture(9634)
if bearTex then hIcon:SetTexture(bearTex) end

-- Header Title
local hTitle = CF(Frame, 9, ACCENT[1], ACCENT[2], ACCENT[3], true)
hTitle:SetPoint("LEFT", Frame, "TOPLEFT", 26, -11)
hTitle:SetText(L.BEAR_FORM)

-- Version rechts
local hVer = CF(Frame, 7, DIM[1], DIM[2], DIM[3])
hVer:SetPoint("RIGHT", Frame, "TOPRIGHT", -20, -11)
hVer:SetText("v"..VERSION)

-- Status Dot rechts
local hDot = CF(Frame, 8, GREEN[1], GREEN[2], GREEN[3])
hDot:SetPoint("RIGHT", Frame, "TOPRIGHT", -6, -11)
hDot:SetText("o")

Sep(Frame, -21)

-- ============================================================
-- RAGE — StatusBar (WoW native Widget, 22px Sektion)
-- ============================================================
local rSect = CT(Frame, "BORDER", BG2[1], BG2[2], BG2[3], 0.6)
rSect:SetHeight(22)
rSect:SetPoint("TOPLEFT",  Frame, "TOPLEFT",  1, -22)
rSect:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -1, -22)

local rLbl = CF(Frame, 7, DIM[1], DIM[2], DIM[3])
rLbl:SetPoint("LEFT", Frame, "TOPLEFT", 7, -28)
rLbl:SetText(IS_DE and "WUT" or "RAGE")

local rVal = CF(Frame, 8, WHITE[1], WHITE[2], WHITE[3])
rVal:SetPoint("RIGHT", Frame, "TOPRIGHT", -6, -28)
rVal:SetText("0 / 100")

-- StatusBar als WoW-natives Widget
local rBar = CreateFrame("StatusBar", nil, Frame)
rBar:SetPoint("TOPLEFT",  Frame, "TOPLEFT",  6, -35)
rBar:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -6, -35)
rBar:SetHeight(7)
rBar:SetMinMaxValues(0, 100)
rBar:SetValue(0)
rBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
rBar:SetStatusBarColor(RED[1], RED[2], RED[3])

-- Bar-Hintergrund
local rBarBG = CT(rBar, "BACKGROUND", DKBG[1], DKBG[2], DKBG[3], 1)
rBarBG:SetAllPoints()

-- Highlight-Linie oben auf Bar
local rHL = CT(rBar, "OVERLAY", 1, 1, 1, 0.06)
rHL:SetHeight(2)
rHL:SetPoint("TOPLEFT",  rBar, "TOPLEFT",  0, 0)
rHL:SetPoint("TOPRIGHT", rBar, "TOPRIGHT", 0, 0)

Sep(Frame, -44)

-- ============================================================
-- MAUL + AUTO-ATTACK (2x 13px Zeilen)
-- ============================================================
local mSect = CT(Frame, "BORDER", BG2[1], BG2[2], BG2[3], 0.5)
mSect:SetHeight(26)
mSect:SetPoint("TOPLEFT",  Frame, "TOPLEFT",  1, -45)
mSect:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -1, -45)

-- Maul Icon
local mIcon = Frame:CreateTexture(nil, "ARTWORK")
mIcon:SetSize(11, 11)
mIcon:SetPoint("LEFT", Frame, "TOPLEFT", 7, -52)
local maulTex = GetSpellTexture(6807)
if maulTex then mIcon:SetTexture(maulTex) else mIcon:SetColorTexture(DIM[1],DIM[2],DIM[3],0.6) end

local mDot = CF(Frame, 7, DIM[1], DIM[2], DIM[3])
mDot:SetPoint("LEFT", Frame, "TOPLEFT", 7, -52)
mDot:SetText("")  -- wird als Icon-Fallback genutzt falls kein Icon

local mTxt = CF(Frame, 8, DIM[1], DIM[2], DIM[3])
mTxt:SetPoint("LEFT", Frame, "TOPLEFT", 22, -52)
mTxt:SetText(L.MAUL_INACTIVE)

local mState = CF(Frame, 7, DIM[1], DIM[2], DIM[3])
mState:SetPoint("RIGHT", Frame, "TOPRIGHT", -6, -52)
mState:SetText("")

-- Auto-Attack Icon (Sword)
local aaIcon = Frame:CreateTexture(nil, "ARTWORK")
aaIcon:SetSize(11, 11)
aaIcon:SetPoint("LEFT", Frame, "TOPLEFT", 7, -64)
local aaTex = GetSpellTexture(6807) -- Fallback; wird nil sein wenn Maul auch nil
-- Verwende generisches Attack-Icon
local attackTex = GetSpellTexture(6603)  -- Auto Attack spell ID (melee)
if attackTex then aaIcon:SetTexture(attackTex) else aaIcon:SetColorTexture(DIM[1],DIM[2],DIM[3],0.6) end

local aaTxt = CF(Frame, 8, DIM[1], DIM[2], DIM[3])
aaTxt:SetPoint("LEFT", Frame, "TOPLEFT", 22, -64)
aaTxt:SetText(L.AA_IDLE)

local aaState = CF(Frame, 7, DIM[1], DIM[2], DIM[3])
aaState:SetPoint("RIGHT", Frame, "TOPRIGHT", -6, -64)
aaState:SetText("")

Sep(Frame, -72)

-- ============================================================
-- BUFF-CHECKER mit echten Spell-Icons (30px Sektion)
-- ============================================================
local bSect = CT(Frame, "BORDER", BG2[1], BG2[2], BG2[3], 0.5)
bSect:SetHeight(30)
bSect:SetPoint("TOPLEFT",  Frame, "TOPLEFT",  1, -73)
bSect:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -1, -73)

local bHdr = CF(Frame, 6, DIM[1], DIM[2], DIM[3])
bHdr:SetPoint("LEFT", Frame, "TOPLEFT", 7, -79)
bHdr:SetText(L.BUFFS_HDR)

-- Buff-Icon Slots (je 22x22 Icon + Label darunter)
local ICON_SZ = 22
local ICON_PAD = 6
local buffSlots = {}
local bxStart = 40

for i, def in ipairs(BUFF_DEFS) do
    local bx = bxStart + (i-1) * (ICON_SZ + ICON_PAD)

    -- Icon-Rahmen (1px farbiger Rand)
    local iconFrame = CreateFrame("Frame", nil, Frame)
    iconFrame:SetSize(ICON_SZ, ICON_SZ)
    iconFrame:SetPoint("TOPLEFT", Frame, "TOPLEFT", bx, -74)

    local iconBorder = CT(iconFrame, "BACKGROUND", DIM[1], DIM[2], DIM[3], 0.8)
    iconBorder:SetAllPoints()
    iconFrame.border = iconBorder

    -- Icon Textur
    local iconTex = iconFrame:CreateTexture(nil, "ARTWORK")
    iconTex:SetPoint("TOPLEFT",     iconFrame, "TOPLEFT",     1, -1)
    iconTex:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", -1,  1)
    iconTex:SetColorTexture(DKBG[1], DKBG[2], DKBG[3], 1)

    -- Fehlend-Overlay (rotes X wenn Buff fehlt)
    local missingOverlay = CT(iconFrame, "OVERLAY", 1, 0, 0, 0)
    missingOverlay:SetAllPoints()
    iconFrame.overlay = missingOverlay

    -- Status-Text unter Icon
    local statusLbl = CF(Frame, 6, DIM[1], DIM[2], DIM[3])
    statusLbl:SetPoint("TOP", iconFrame, "BOTTOM", 0, -1)
    statusLbl:SetText(def.label)

    iconFrame.iconTex   = iconTex
    iconFrame.statusLbl = statusLbl
    iconFrame.iconSet   = false
    buffSlots[i] = { frame=iconFrame, def=def }
end

Sep(Frame, -104)

-- ============================================================
-- FF / DR DEBUFF-TIMER (14px Zeile)
-- ============================================================
local dSect = CT(Frame, "BORDER", BG2[1], BG2[2], BG2[3], 0.4)
dSect:SetHeight(14)
dSect:SetPoint("TOPLEFT",  Frame, "TOPLEFT",  1, -105)
dSect:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -1, -105)

-- Faerie Fire
local fIcon = Frame:CreateTexture(nil, "ARTWORK")
fIcon:SetSize(10, 10)
fIcon:SetPoint("LEFT", Frame, "TOPLEFT", 7, -112)
local ffTex = GetSpellTexture(16857)
if ffTex then fIcon:SetTexture(ffTex) else fIcon:SetColorTexture(DIM[1],DIM[2],DIM[3],0.5) end

local fLbl = CF(Frame, 7, DIM[1], DIM[2], DIM[3])
fLbl:SetPoint("LEFT", Frame, "TOPLEFT", 20, -112)
fLbl:SetText(L.FF_LABEL)

local fVal = CF(Frame, 8, DIM[1], DIM[2], DIM[3])
fVal:SetPoint("LEFT", Frame, "TOPLEFT", 35, -112)
fVal:SetText("---")

-- Vertikale Trennlinie
local vSep = CT(Frame, "ARTWORK", SEP[1], SEP[2], SEP[3], 0.4)
vSep:SetSize(1, 10)
vSep:SetPoint("TOPLEFT", Frame, "TOPLEFT", W/2, -107)

-- Demo Roar
local dIcon = Frame:CreateTexture(nil, "ARTWORK")
dIcon:SetSize(10, 10)
dIcon:SetPoint("LEFT", Frame, "TOPLEFT", W/2+6, -112)
local drTex = GetSpellTexture(99)
if drTex then dIcon:SetTexture(drTex) else dIcon:SetColorTexture(DIM[1],DIM[2],DIM[3],0.5) end

local dLbl = CF(Frame, 7, DIM[1], DIM[2], DIM[3])
dLbl:SetPoint("LEFT", Frame, "TOPLEFT", W/2+19, -112)
dLbl:SetText(L.DR_LABEL)

local dVal = CF(Frame, 8, DIM[1], DIM[2], DIM[3])
dVal:SetPoint("LEFT", Frame, "TOPLEFT", W/2+34, -112)
dVal:SetText("---")

Sep(Frame, -120)

-- ============================================================
-- COOLDOWN SLOTS (7 Slots)
-- ============================================================
local CD_SZ  = 26
local CD_GAP = 2
local nCD    = #CD_ORDER
local totW   = nCD * CD_SZ + (nCD - 1) * CD_GAP
local cdX0   = math.floor((W - totW) / 2)

local cdSlots = {}
for i, key in ipairs(CD_ORDER) do
    local xp = cdX0 + (i-1) * (CD_SZ + CD_GAP)
    local cf = CreateFrame("Button", "GHSlot"..i, Frame, "SecureActionButtonTemplate")
    cf:SetSize(CD_SZ, CD_SZ + 10)
    cf:SetPoint("TOPLEFT", Frame, "TOPLEFT", xp, -122)
    cf:RegisterForClicks("AnyUp")
    cf:SetAttribute("type1", "spell")
    cf:SetAttribute("spell", "")

    -- Hintergrund (dunkles Segment)
    local cbg = CT(cf, "BACKGROUND", DKBG[1], DKBG[2], DKBG[3], 1)
    cbg:SetAllPoints()

    -- Rahmen (wird je nach Status eingefärbt)
    local cborder = CT(cf, "BORDER", DGOLD[1], DGOLD[2], DGOLD[3], 0.5)
    cborder:SetAllPoints()
    cf.border = cborder

    -- Spell Icon
    local cicon = cf:CreateTexture(nil, "ARTWORK")
    cicon:SetPoint("TOPLEFT",     cf, "TOPLEFT",      1, -1)
    cicon:SetPoint("BOTTOMRIGHT", cf, "BOTTOMRIGHT",  -1, 10)
    cicon:SetColorTexture(DKBG[1], DKBG[2], DKBG[3], 1)
    cf.icon = cicon

    -- CD-Overlay (dunkelt Icon ein)
    local coverlay = CT(cf, "ARTWORK", 0, 0, 0, 0)
    coverlay:SetPoint("TOPLEFT",     cf, "TOPLEFT",      1, -1)
    coverlay:SetPoint("BOTTOMRIGHT", cf, "BOTTOMRIGHT",  -1, 10)
    cf.overlay = coverlay

    -- Timer Text
    local ctimer = CF(cf, 8, WHITE[1], WHITE[2], WHITE[3])
    ctimer:SetPoint("CENTER", cf, "CENTER", 0, 4)
    ctimer:SetText("")
    cf.timer = ctimer

    -- Label unter Icon
    local clbl = CF(cf, 6, DGOLD[1], DGOLD[2], DGOLD[3])
    clbl:SetPoint("BOTTOM", cf, "BOTTOM", 0, 1)
    clbl:SetText(SPELL_GROUPS[key].label)
    cf.lbl = clbl

    -- Tooltip
    cf:SetScript("OnEnter", function(self)
        if self.spellName then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(self.spellName, 1, 1, 1)
            local bind = GetBindingKey("CLICK GHSlot"..self.slotIdx..":LeftButton")
            if bind then
                GameTooltip:AddLine((IS_DE and "Taste: " or "Key: ").."|cffFFD700"..bind.."|r", 1,1,1)
            else
                GameTooltip:AddLine(IS_DE and "|cff555555ESC -> Tastenbel. -> Addons|r"
                                           or "|cff555555ESC -> Bindings -> AddOns|r", 1,1,1)
            end
            GameTooltip:Show()
        end
    end)
    cf:SetScript("OnLeave", function() GameTooltip:Hide() end)

    cf.key      = key
    cf.slotIdx  = i
    cf.minLevel = SPELL_GROUPS[key].ranks[1].lv
    cf.iconSet  = false
    cf.spellName = nil
    cdSlots[i]  = cf
end

-- Footer
local footer = CF(Frame, 6, DIM[1]*0.7, DIM[2]*0.7, DIM[3]*0.7)
footer:SetPoint("BOTTOM", Frame, "BOTTOM", 0, 3)
footer:SetText(L.FOOTER)

-- Frame Höhe final
Frame:SetHeight(122 + CD_SZ + 10 + 9)

local CFG  -- forward declaration (wird weiter unten definiert)
local TF   -- forward declaration (wird weiter unten definiert)

-- ============================================================
-- MINIMAP BUTTON
-- ============================================================
local MM = CreateFrame("Button", "GHMinimapButton", UIParent)
MM:SetSize(28, 28)
MM:SetFrameStrata("MEDIUM")
MM:SetFrameLevel(Minimap:GetFrameLevel() + 20)
MM:SetMovable(true)
MM:RegisterForDrag("LeftButton")
MM:RegisterForClicks("LeftButtonUp", "RightButtonUp")
MM:EnableMouse(true)

-- Dunkler BG
local mmBG = CT(MM, "BACKGROUND", BG[1], BG[2], BG[3], 0.95)
mmBG:SetAllPoints()
-- Electric-Blue Ring
AddBorder(MM, BDR[1], BDR[2], BDR[3], 0.9, 1)

-- Bear Icon
local mmTex = MM:CreateTexture(nil, "ARTWORK")
mmTex:SetPoint("TOPLEFT",     MM, "TOPLEFT",      3, -3)
mmTex:SetPoint("BOTTOMRIGHT", MM, "BOTTOMRIGHT",  -3,  3)
if bearTex then mmTex:SetTexture(bearTex)
else
    local mmF = CF(MM, 9, ACCENT[1], ACCENT[2], ACCENT[3])
    mmF:SetAllPoints(); mmF:SetJustifyH("CENTER"); mmF:SetJustifyV("MIDDLE"); mmF:SetText("GH")
end

local mmAngle = 220
local function SetMMPos()
    local r = math.rad(mmAngle)
    MM:SetPoint("CENTER", Minimap, "CENTER", math.cos(r)*80, math.sin(r)*80)
end
SetMMPos()

MM:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
        local mx,my = Minimap:GetCenter()
        local cx,cy = GetCursorPosition()
        local s = UIParent:GetEffectiveScale()
        mmAngle = math.deg(math.atan2(cy/s-my, cx/s-mx))
        SetMMPos()
    end)
end)
MM:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
MM:SetScript("OnClick", function(self, btn)
    if btn == "RightButton" then
        if CFG:IsShown() then CFG:Hide() else CFG:Show() end
    else
        if Frame:IsShown() then Frame:Hide() else Frame:Show() end
    end
end)
MM:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("|cff14CCADGH|r |cff1AA8FFv"..VERSION.."|r")
    GameTooltip:AddLine(IS_DE and "Linksklick: Panel"     or "Left: Toggle Panel",    1,1,1)
    GameTooltip:AddLine(IS_DE and "Rechtsklick: Konfig"   or "Right: Config",         1,0.82,0)
    GameTooltip:AddLine(IS_DE and "Drag: Verschieben"     or "Drag: Move",            0.6,0.6,0.7)
    GameTooltip:Show()
end)
MM:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- ============================================================
-- CONFIG PANEL
-- ============================================================
CFG = CreateFrame("Frame", "GHConfigFrame", UIParent)
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

CT(CFG, "BACKGROUND", BG[1], BG[2], BG[3], BG[4]):SetAllPoints()
AddBorder(CFG, BDR[1], BDR[2], BDR[3], 0.8, 1)

local cfgHdrBG = CT(CFG, "BORDER", BG2[1], BG2[2], BG2[3], 1)
cfgHdrBG:SetHeight(20)
cfgHdrBG:SetPoint("TOPLEFT",  CFG, "TOPLEFT",  1, -1)
cfgHdrBG:SetPoint("TOPRIGHT", CFG, "TOPRIGHT", -1, -1)

local cfgAccent = CT(CFG, "ARTWORK", ACCENT[1], ACCENT[2], ACCENT[3], 1)
cfgAccent:SetSize(2, 20)
cfgAccent:SetPoint("TOPLEFT", CFG, "TOPLEFT", 1, -1)

local cfgTitle = CF(CFG, 9, ACCENT[1], ACCENT[2], ACCENT[3], true)
cfgTitle:SetPoint("CENTER", CFG, "TOP", 0, -11)
cfgTitle:SetText(L.CFG_TITLE)

local cfgX = CreateFrame("Button", nil, CFG)
cfgX:SetSize(16, 16)
cfgX:SetPoint("TOPRIGHT", CFG, "TOPRIGHT", -4, -3)
local cfgXL = CF(cfgX, 10, REDBR[1], REDBR[2], REDBR[3])
cfgXL:SetAllPoints(); cfgXL:SetJustifyH("CENTER"); cfgXL:SetText("X")
cfgX:SetScript("OnClick", function() CFG:Hide() end)

Sep(CFG, -21)

local cfgChecks = {}
local function AddCheck(label, key, yOff)
    local btn = CreateFrame("Button", nil, CFG)
    btn:SetSize(180, 14)
    btn:SetPoint("TOPLEFT", CFG, "TOPLEFT", 8, yOff)
    local box = CT(btn, "BACKGROUND", BDR[1], BDR[2], BDR[3], 0.6)
    box:SetSize(10, 10); box:SetPoint("LEFT", btn, "LEFT", 0, 0)
    local check = CF(btn, 8, GREEN[1], GREEN[2], GREEN[3])
    check:SetSize(10, 10); check:SetPoint("LEFT", btn, "LEFT", 1, 0)
    check:SetJustifyH("CENTER"); check:SetText(DB and DB[key] and "v" or "")
    btn.check = check
    local lbl = CF(btn, 8, WHITE[1], WHITE[2], WHITE[3])
    lbl:SetPoint("LEFT", btn, "LEFT", 14, 0); lbl:SetText(label)
    btn:SetScript("OnClick", function()
        if DB then DB[key] = not DB[key]; check:SetText(DB[key] and "v" or "") end
    end)
    cfgChecks[key] = btn
end

AddCheck(IS_DE and "Maul-Alert"              or "Maul Queue Alert",    "maulAlert",          -32)
AddCheck(IS_DE and "Sound: Formverlust"      or "Sound: Form Loss",    "soundFormLoss",       -48)
AddCheck(IS_DE and "Sound: Auto-Aus"         or "Sound: Auto-Off",     "soundAutoOff",        -64)
AddCheck(IS_DE and "Nur in Kampf zeigen"     or "Show in Combat only", "combatOnly",          -80)
AddCheck(IS_DE and "Aggro: nur im Kampf"     or "Aggro: combat only",  "aggroOnlyInCombat",   -96)
Sep(CFG, -112)

local function MakeBtn(label, xOff, yOff, w2, onClick)
    local b = CreateFrame("Button", nil, CFG)
    b:SetSize(w2 or 32, 16)
    b:SetPoint("TOPLEFT", CFG, "TOPLEFT", xOff, yOff)
    CT(b,"BACKGROUND",BG2[1],BG2[2],BG2[3],1):SetAllPoints()
    AddBorder(b, BDR[1], BDR[2], BDR[3], 0.6, 1)
    local l = CF(b, 8, WHITE[1], WHITE[2], WHITE[3])
    l:SetAllPoints(); l:SetJustifyH("CENTER"); l:SetText(label)
    b:SetScript("OnClick", onClick)
    return b
end


-- ============================================================
-- SOUND SELEKTOR (eingebettet in CFG)
-- ============================================================
-- Jeder Sound: kleiner nummerierter Button [1..6], Auswahl wird hervorgehoben.
-- Hover = Tooltip mit Sound-Name. Klick = auswählen + sofort vorspielen.
local SND_BTN_W = 26
local SND_BTN_H = 14
local SND_GAP   = 2
local sndBtns_ao   = {}  -- Auto-Off Sound Buttons
local sndBtns_buff = {}  -- Buff-Sound Buttons

local function MakeSndBtn(parent, idx, x, y, tbl, dbKey)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(SND_BTN_W, SND_BTN_H)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    local bg = CT(b, "BACKGROUND", DKBG[1], DKBG[2], DKBG[3], 1)
    bg:SetAllPoints()
    b.borderTex = CT(b, "BORDER", DIM[1], DIM[2], DIM[3], 0.5)
    b.borderTex:SetAllPoints()
    local lbl = CF(b, 7, DIM[1], DIM[2], DIM[3])
    lbl:SetAllPoints(); lbl:SetJustifyH("CENTER"); lbl:SetText(tostring(idx))
    b.numLbl = lbl
    b:SetScript("OnClick", function()
        if DB then DB[dbKey] = idx end
        PlaySnd(idx)
        -- Refresh aller Buttons in dieser Gruppe
        for _, btn in ipairs(tbl) do
            local sel = DB and DB[dbKey] == btn.idx
            btn.borderTex:SetColorTexture(sel and BDR[1] or DIM[1], sel and BDR[2] or DIM[2], sel and BDR[3] or DIM[3], sel and 0.9 or 0.4)
            btn.numLbl:SetTextColor(sel and WHITE[1] or DIM[1], sel and WHITE[2] or DIM[2], sel and WHITE[3] or DIM[3])
        end
    end)
    b:SetScript("OnEnter", function(self)
        local s = SOUNDS[idx]
        if s then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(s.name, 1, 1, 1)
            GameTooltip:AddLine(IS_DE and "Klick: Auswählen + Vorspielen" or "Click: Select + Preview", 0.6,0.6,0.7)
            GameTooltip:Show()
        end
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    b.idx = idx
    tbl[idx] = b
    return b
end

-- Label + 6 Sound-Buttons für Auto-Off
local aoLbl = CF(CFG, 7, DIM[1], DIM[2], DIM[3])
aoLbl:SetPoint("TOPLEFT", CFG, "TOPLEFT", 8, -120)
aoLbl:SetText(IS_DE and "Auto-Off Sound:" or "Auto-Off Sound:")

for i = 1, #SOUNDS do
    local bx = 8 + (i-1) * (SND_BTN_W + SND_GAP)
    MakeSndBtn(CFG, i, bx, -132, sndBtns_ao, "soundAutoOffIdx")
end

Sep(CFG, -149)

-- Label + 6 Sound-Buttons für Buff-Warnung
local buffLbl = CF(CFG, 7, DIM[1], DIM[2], DIM[3])
buffLbl:SetPoint("TOPLEFT", CFG, "TOPLEFT", 8, -157)
buffLbl:SetText(IS_DE and "Buff-Warnung Sound:" or "Buff Warning Sound:")

for i = 1, #SOUNDS do
    local bx = 8 + (i-1) * (SND_BTN_W + SND_GAP)
    MakeSndBtn(CFG, i, bx, -169, sndBtns_buff, "soundBuffIdx")
end

Sep(CFG, -186)

-- Opacity
local opLbl = CF(CFG, 7, DIM[1], DIM[2], DIM[3])
opLbl:SetPoint("TOPLEFT", CFG, "TOPLEFT", 8, -194)
opLbl:SetText(IS_DE and "Deckkraft:" or "Opacity:")
local opVal = CF(CFG, 8, WHITE[1], WHITE[2], WHITE[3])
opVal:SetPoint("TOPLEFT", CFG, "TOPLEFT", 68, -194)
opVal:SetText("94%")

MakeBtn(" - ", 100, -190, 24, function()
    if not DB then return end
    DB.alpha = math.max(0.3, DB.alpha - 0.05)
    Frame:SetAlpha(DB.alpha)
    opVal:SetText(string.format("%d%%", DB.alpha * 100))
end)
MakeBtn(" + ", 128, -190, 24, function()
    if not DB then return end
    DB.alpha = math.min(1.0, DB.alpha + 0.05)
    Frame:SetAlpha(DB.alpha)
    opVal:SetText(string.format("%d%%", DB.alpha * 100))
end)

-- Aggro Monitor Reset-Position Button
MakeBtn(IS_DE and "Aggro Pos. reset" or "Aggro Pos. reset", 8, -207, 130, function()
    TF:ClearAllPoints()
    TF:SetPoint("CENTER", UIParent, "CENTER", 560, 0)
    if DB then DB.tx = nil; DB.ty = nil end
end)

Sep(CFG, -224)
local bindHint = CF(CFG, 6, DIM[1], DIM[2], DIM[3])
bindHint:SetPoint("TOPLEFT", CFG, "TOPLEFT", 8, -232)
bindHint:SetText(IS_DE and "Tasten: ESC -> Tastenbel. -> Addons" or "Keys: ESC -> Bindings -> AddOns")

CFG:SetHeight(282)
local btnSave = MakeBtn(L.CFG_SAVE, 8, -246, 86, function()
    print("|cff14CCADGuardianHelper:|r " .. L.MSG_SAVED)
    CFG:Hide()
end)
local btnCancel = MakeBtn(L.CFG_CANCEL, 106, -246, 86, function() CFG:Hide() end)

-- Refresh-Funktion für Sound-Button-Highlighting (wird nach DB-Load aufgerufen)
function RefreshSoundBtns()
    if not DB then return end
    for _, tbl in ipairs({sndBtns_ao, sndBtns_buff}) do
        local dbKey = tbl == sndBtns_ao and "soundAutoOffIdx" or "soundBuffIdx"
        for _, btn in ipairs(tbl) do
            local sel = DB[dbKey] == btn.idx
            btn.borderTex:SetColorTexture(sel and BDR[1] or DIM[1], sel and BDR[2] or DIM[2], sel and BDR[3] or DIM[3], sel and 0.9 or 0.4)
            btn.numLbl:SetTextColor(sel and WHITE[1] or DIM[1], sel and WHITE[2] or DIM[2], sel and WHITE[3] or DIM[3])
        end
    end
end

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
                            cache[key] = {id=sid, lv=rd.lv, slot=i, icon=GetSpellTexture(sid)}
                        end
                    end
                end
            end
        end
        i = i + 1
    end
    -- Buff-Icons laden
    for _, bs in ipairs(buffSlots) do
        if not bs.frame.iconSet then
            for _, id in ipairs(bs.def.ids) do
                local tex = GetSpellTexture(id)
                if tex then
                    bs.frame.iconTex:SetTexture(tex)
                    bs.frame.iconSet = true
                    break
                end
            end
        end
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
    local idSet, nameSet = {}, {}
    for _, id in ipairs(idList) do
        idSet[id] = true
        local n = GetSpellInfo(id)
        if n then nameSet[n] = true end
    end
    for i = 1, 40 do
        local dn, _, _, _, _, exp, _, _, _, sid = UnitDebuff("target", i)
        if not dn then break end
        if (sid and idSet[sid]) or nameSet[dn] then
            return exp and exp > 0 and (exp - GetTime()) or 999
        end
    end
    return nil
end

local function HasBuff(idList)
    local idSet, nameSet = {}, {}
    for _, id in ipairs(idList) do
        idSet[id] = true
        local n = GetSpellInfo(id)
        if n then nameSet[n] = true end
    end
    for i = 1, 40 do
        local bn, _, _, _, _, _, _, _, sid = UnitBuff("player", i)
        if not bn then break end
        if (sid and idSet[sid]) or nameSet[bn] then return true end
    end
    return false
end

local function GetCD(key)
    local c = cache[key]; if not c then return nil end
    local s, d = GetSpellCooldown(c.id)
    if not s or s == 0 then return 0 end
    local r = (s + d) - GetTime()
    return r > 0 and r or 0
end

-- ============================================================
-- AGGRO MONITOR — Daten & Roster
-- ============================================================
local CLASS_COLOR = {
    WARRIOR={0.78,0.61,0.43}, PALADIN={0.96,0.55,0.73},
    HUNTER ={0.67,0.83,0.45}, ROGUE  ={1.00,0.96,0.41},
    PRIEST ={1.00,1.00,1.00}, SHAMAN ={0.00,0.44,0.87},
    MAGE   ={0.25,0.78,0.92}, WARLOCK={0.53,0.53,0.93},
    DRUID  ={1.00,0.49,0.04},
}
local HEALER_CLASSES = { PRIEST=true, DRUID=true, SHAMAN=true, PALADIN=true }
local AGGRO_TTL      = 4.0   -- Sekunden bis Mob als disengaged gilt

local roster      = {}  -- {[guid]={name,class,unitId}}
local aggroData   = {}  -- {[pguid]={attackers={[mguid]={name,t}}, count=0}}
local healerCache = {}  -- {[guid]=true} wenn Heilzauber gesehen

local function RebuildRoster()
    roster = {}
    local function Add(uid)
        if UnitExists(uid) then
            local g = UnitGUID(uid)
            if g then
                local _, cls = UnitClass(uid)
                roster[g] = { name=UnitName(uid) or "?", class=cls or "WARRIOR", unitId=uid }
            end
        end
    end
    Add("player")
    for i=1,4  do Add("party"..i) end
    for i=1,40 do Add("raid"..i)  end
end

local function RecordAttack(mobGUID, mobName, playerGUID)
    if not roster[playerGUID] and playerGUID ~= UnitGUID("player") then return end
    -- Spieler sicherstellen dass er im Roster ist (Fallback)
    if not roster[playerGUID] then
        local _, cls = UnitClass("player")
        roster[playerGUID] = { name=UnitName("player") or "?", class=cls or "DRUID", unitId="player" }
    end
    if not aggroData[playerGUID] then
        aggroData[playerGUID] = { attackers={}, count=0 }
    end
    local e = aggroData[playerGUID]
    if not e.attackers[mobGUID] then e.count = e.count + 1 end
    e.attackers[mobGUID] = { name=mobName, t=GetTime() }
end

local function CleanAggro()
    local now = GetTime()
    for pguid, e in pairs(aggroData) do
        for mguid, mob in pairs(e.attackers) do
            if (now - mob.t) > AGGRO_TTL then
                e.attackers[mguid] = nil
                e.count = math.max(0, e.count - 1)
            end
        end
        if e.count == 0 then aggroData[pguid] = nil end
    end
end

-- ============================================================
-- AGGRO MONITOR — Frame (TF)
-- ============================================================
local TW     = 178
local TR_H   = 15
local MAX_TR = 8

TF = CreateFrame("Frame", "GHThreatFrame", UIParent)
TF:SetWidth(TW)
TF:SetHeight(22 + MAX_TR * TR_H + 8)
TF:SetPoint("CENTER", UIParent, "CENTER", 560, 0)
TF:SetMovable(true); TF:EnableMouse(true); TF:RegisterForDrag("LeftButton")
TF:SetScript("OnDragStart", function(s)
    if not (DB and DB.locked) then s:StartMoving() end
end)
TF:SetScript("OnDragStop", function(s)
    s:StopMovingOrSizing()
    if DB then local _,_,_,x,y=s:GetPoint(); DB.tx=x; DB.ty=y end
end)
TF:SetFrameStrata("MEDIUM"); TF:SetClampedToScreen(true)

CT(TF,"BACKGROUND",BG[1],BG[2],BG[3],BG[4]):SetAllPoints()
AddBorder(TF, BDR[1], BDR[2], BDR[3], 0.8, 1)

local thBG = CT(TF,"BORDER",BG2[1],BG2[2],BG2[3],1)
thBG:SetHeight(20); thBG:SetPoint("TOPLEFT",TF,"TOPLEFT",1,-1)
thBG:SetPoint("TOPRIGHT",TF,"TOPRIGHT",-1,-1)

local thAccent = CT(TF,"ARTWORK",ACCENT[1],ACCENT[2],ACCENT[3],1)
thAccent:SetSize(2,20)
thAccent:SetPoint("TOPLEFT",TF,"TOPLEFT",1,-1)

local thTitle = CF(TF,9,ACCENT[1],ACCENT[2],ACCENT[3],true)
thTitle:SetPoint("LEFT",TF,"TOPLEFT",8,-11)
thTitle:SetText(IS_DE and "AGGRO MONITOR" or "AGGRO MONITOR")

local thInfo = CF(TF,7,DIM[1],DIM[2],DIM[3])
thInfo:SetPoint("RIGHT",TF,"TOPRIGHT",-6,-11)
thInfo:SetText("")

Sep(TF, -21)

-- Zeilenspalten-Header
local colHdr = CF(TF,6,DIM[1],DIM[2],DIM[3])
colHdr:SetPoint("TOPLEFT",TF,"TOPLEFT",20,-20)
colHdr:SetText(IS_DE and "Spieler" or "Player")
local colHdr2 = CF(TF,6,DIM[1],DIM[2],DIM[3])
colHdr2:SetPoint("TOPRIGHT",TF,"TOPRIGHT",-5,-20)
colHdr2:SetText(IS_DE and "Mobs" or "Mobs")

-- Dynamische Zeilen (SecureActionButtonTemplate für Click-to-Target im Kampf)
local tRows = {}
for i = 1, MAX_TR do
    local y = -23 - (i-1) * TR_H
    local row = CreateFrame("Button","GHTRow"..i,TF,"SecureActionButtonTemplate")
    row:SetSize(TW-2, TR_H)
    row:SetPoint("TOPLEFT",TF,"TOPLEFT",1,y)
    row:RegisterForClicks("AnyUp")
    row:SetAttribute("type","target")
    row:SetAttribute("unit","")

    -- Zeilen-BG (wird je nach Status gefärbt)
    local rbg = CT(row,"BACKGROUND",0,0,0,0); rbg:SetAllPoints(); row.bg=rbg

    -- Klassen-Farb-Streifen (3px links)
    local rclr = CT(row,"ARTWORK",0.5,0.5,0.5,0)
    rclr:SetWidth(3)
    rclr:SetPoint("TOPLEFT",row,"TOPLEFT",0,0)
    rclr:SetPoint("BOTTOMLEFT",row,"BOTTOMLEFT",0,0)
    row.clr = rclr

    -- Heiler-Badge
    local rh = CF(row,6,RED[1],0.3,0.3)
    rh:SetPoint("LEFT",row,"LEFT",5,0); rh:SetText(""); row.hbadge=rh

    -- Spieler-Name
    local rname = CF(row,8,WHITE[1],WHITE[2],WHITE[3])
    rname:SetPoint("LEFT",row,"LEFT",16,0); rname:SetText(""); row.nameL=rname

    -- Mob-Anzahl (rechts)
    local rcnt = CF(row,9,ORANGE[1],ORANGE[2],ORANGE[3])
    rcnt:SetPoint("RIGHT",row,"RIGHT",-5,0); rcnt:SetText(""); row.cntL=rcnt

    row:SetScript("OnEnter",function(self)
        if self.mobs and #self.mobs > 0 then
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
            GameTooltip:SetText(self.nameL:GetText(),1,1,1)
            for _,mn in ipairs(self.mobs) do
                GameTooltip:AddLine("  "..mn, ORANGE[1],ORANGE[2],ORANGE[3])
            end
            GameTooltip:AddLine(
                IS_DE and "\nKlick: Ziel anwählen" or "\nClick: Target their mob",
                0.5,0.5,0.6)
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave",function() GameTooltip:Hide() end)
    row:Hide(); row.mobs={}
    tRows[i]=row
end

-- Leer-Hinweis
local tEmpty = CF(TF,7,DIM[1],DIM[2],DIM[3])
tEmpty:SetPoint("CENTER",TF,"CENTER",0,-10)
tEmpty:SetText(IS_DE and "keine Aggro erkannt" or "no aggro detected")

TF:Hide()

-- Update-Funktion für den Aggro-Monitor
local function UpdateThreatUI()
    CleanAggro()
    local pGUID = UnitGUID("player")

    -- Spieler-Eintrag immer als erste Zeile
    local pData  = aggroData[pGUID]
    local pCount = pData and pData.count or 0
    local pMobs  = {}
    if pData then
        for _, mob in pairs(pData.attackers) do table.insert(pMobs, mob.name) end
    end
    local list = {{
        name=">> "..(UnitName("player") or "Du"),
        class="DRUID", unitId="player",
        count=pCount, mobs=pMobs,
        isHealer=false, isSelf=true,
    }}

    -- Andere Gruppenmitglieder mit Aggro
    for pguid, e in pairs(aggroData) do
        if pguid ~= pGUID then
            local p = roster[pguid]
            if p and e.count > 0 then
                local mbs = {}
                for _, mob in pairs(e.attackers) do table.insert(mbs, mob.name) end
                table.insert(list, {
                    name=p.name, class=p.class, unitId=p.unitId,
                    count=e.count, mobs=mbs,
                    isHealer=HEALER_CLASSES[p.class] or healerCache[pguid] or false,
                    isSelf=false,
                })
            end
        end
    end
    -- Alle außer Spieler nach Mob-Anzahl sortieren (Spieler bleibt Index 1)
    if #list > 2 then
        local others = {}
        for i = 2, #list do others[#others+1] = list[i] end
        table.sort(others, function(a,b) return a.count > b.count end)
        for i, v in ipairs(others) do list[i+1] = v end
    end

    local n = #list
    local othersWithAggro = n - 1  -- ohne Spieler
    thInfo:SetText(othersWithAggro > 0 and othersWithAggro.." "..(IS_DE and "Spieler" or "player") or "")
    tEmpty:SetShown(false)  -- Spieler-Zeile ist immer da

    for i = 1, MAX_TR do
        local row = tRows[i]
        local d   = list[i]
        if d then
            row:Show()
            if d.isSelf then
                -- Spieler-Zeile: Teal Akzent statt Klassenfarbe
                row.clr:SetColorTexture(ACCENT[1],ACCENT[2],ACCENT[3],1)
                if pCount >= 1 then
                    row.bg:SetColorTexture(0.02,0.10,0.12,0.85)
                else
                    row.bg:SetColorTexture(BG2[1],BG2[2],BG2[3],0.4)
                end
                row.hbadge:SetText("")
                row.nameL:SetTextColor(ACCENT[1],ACCENT[2],ACCENT[3])
                local nm = d.name; if #nm>16 then nm=nm:sub(1,15)..".." end
                row.nameL:SetText(nm)
                if pCount >= 1 then
                    local cc2 = pCount>=3 and RED or (pCount==2 and ORANGE or GREEN)
                    row.cntL:SetText(pCount.."x")
                    row.cntL:SetTextColor(cc2[1],cc2[2],cc2[3])
                else
                    row.cntL:SetText("--")
                    row.cntL:SetTextColor(DIM[1],DIM[2],DIM[3])
                end
            else
                local cc = CLASS_COLOR[d.class] or {0.7,0.7,0.7}
                row.clr:SetColorTexture(cc[1],cc[2],cc[3],1)
                if d.isHealer then
                    row.bg:SetColorTexture(0.25,0.03,0.03,0.75)
                    row.hbadge:SetText("[H]")
                    row.nameL:SetTextColor(1.0,0.45,0.45)
                else
                    row.bg:SetColorTexture(BG2[1],BG2[2],BG2[3],0.5)
                    row.hbadge:SetText("")
                    row.nameL:SetTextColor(WHITE[1],WHITE[2],WHITE[3])
                end
                local nm = d.name; if #nm>12 then nm=nm:sub(1,11)..".." end
                row.nameL:SetText(nm)
                local cc2 = d.count>=3 and RED or (d.count==2 and ORANGE or WHITE)
                row.cntL:SetText(d.count.."x")
                row.cntL:SetTextColor(cc2[1],cc2[2],cc2[3])
            end
            row.mobs = d.mobs
            if not InCombatLockdown() then
                local uid = d.unitId
                row:SetAttribute("unit", uid == "player" and "target" or uid.."target")
            end
        else
            row:Hide()
        end
    end
    local rows = math.max(1, math.min(n, MAX_TR))
    TF:SetHeight(22 + rows * TR_H + 8)
end

-- ============================================================
-- STATE
-- ============================================================
local maulQueued    = false
local lastSwingTime = 0
local aaWasOff      = false   -- Sound-Edge-Detection für Auto-Attack

-- ============================================================
-- SOUND HELPERS
-- ============================================================
local function PlayWarn()   -- Auto-Angriff verloren
    if DB and DB.soundAutoOff then PlaySnd(DB.soundAutoOffIdx or 2) end
end
local function PlayAlert()  -- Buff fehlt beim Pull
    if DB and DB.soundFormLoss then PlaySnd(DB.soundBuffIdx or 1) end
end

-- ============================================================
-- EVENTS
-- ============================================================
local EF = CreateFrame("Frame")
EF:RegisterEvent("ADDON_LOADED")
EF:RegisterEvent("PLAYER_LOGIN")
EF:RegisterEvent("PLAYER_LEVEL_UP")
EF:RegisterEvent("SPELLS_CHANGED")
EF:RegisterEvent("PLAYER_REGEN_DISABLED")
EF:RegisterEvent("PLAYER_REGEN_ENABLED")
EF:RegisterEvent("PARTY_MEMBER_ENABLE")
EF:RegisterEvent("PARTY_MEMBER_DISABLE")
EF:RegisterEvent("RAID_ROSTER_UPDATE")
EF:RegisterEvent("PLAYER_ENTERING_WORLD")
EF:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

EF:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == "GuardianHelper" then
        GuardianHelperDB = GuardianHelperDB or {}
        DB = GuardianHelperDB
        DB.alpha        = DB.alpha or 0.94
        DB.locked       = DB.locked or false
        DB.maulAlert       = DB.maulAlert       == nil and true or DB.maulAlert
        DB.soundFormLoss   = DB.soundFormLoss   == nil and true or DB.soundFormLoss
        DB.soundAutoOff    = DB.soundAutoOff    == nil and true or DB.soundAutoOff
        DB.soundAutoOffIdx = DB.soundAutoOffIdx or 2
        DB.soundBuffIdx    = DB.soundBuffIdx    or 1
        DB.showAggro          = DB.showAggro          == nil and true  or DB.showAggro
        DB.aggroOnlyInCombat  = DB.aggroOnlyInCombat  == nil and false or DB.aggroOnlyInCombat
        Frame:SetAlpha(DB.alpha)
        if DB.x and DB.y then
            Frame:ClearAllPoints()
            Frame:SetPoint("CENTER", UIParent, "CENTER", DB.x, DB.y)
        end
        if DB.tx and DB.ty then
            TF:ClearAllPoints()
            TF:SetPoint("CENTER", UIParent, "CENTER", DB.tx, DB.ty)
        end
        if DB.showAggro and not DB.aggroOnlyInCombat then TF:Show() else TF:Hide() end
        opVal:SetText(string.format("%d%%", DB.alpha * 100))
        for key, btn in pairs(cfgChecks) do
            btn.check:SetText(DB[key] and "v" or "")
        end
        RefreshSoundBtns()

    elseif event == "PLAYER_ENTERING_WORLD" then
        RebuildRoster()

    elseif event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" or event == "RAID_ROSTER_UPDATE" then
        RebuildRoster()
        aggroData   = {}  -- Alte Daten löschen nach Roster-Änderung
        healerCache = {}

    elseif event == "PLAYER_REGEN_ENABLED" then
        aggroData   = {}
        healerCache = {}
        UpdateThreatUI()
        if DB and DB.showAggro and DB.aggroOnlyInCombat then TF:Hide() end

    elseif event == "PLAYER_LOGIN" then
        BuildCache()
        RebuildRoster()
        for _, f in ipairs(cdSlots) do
            local c = cache[f.key]
            if c and c.name then f:SetAttribute("spell", c.name); f.spellName = c.name end
        end
        print("|cff14CCADGuardianHelper|r |cff1AA8FFv"..VERSION.."|r "..L.MSG_LOADED.."  |cff555555/gh help|r")

    elseif event == "PLAYER_LEVEL_UP" then
        local df = CreateFrame("Frame"); local el = 0
        df:SetScript("OnUpdate", function(s, e)
            el = el + e
            if el >= 0.5 then
                s:SetScript("OnUpdate", nil)
                BuildCache()
                if not InCombatLockdown() then
                    for _, f in ipairs(cdSlots) do
                        local c = cache[f.key]
                        if c and c.name then f:SetAttribute("spell", c.name); f.spellName = c.name end
                    end
                end
            end
        end)

    elseif event == "SPELLS_CHANGED" then
        BuildCache()

    elseif event == "PLAYER_REGEN_DISABLED" then
        if DB and DB.showAggro and DB.aggroOnlyInCombat then TF:Show() end
        lastSwingTime = GetTime()
        if DB and DB.soundFormLoss then
            local pLevel = UnitLevel("player")
            for _, def in ipairs(BUFF_DEFS) do
                if pLevel >= def.minLevel and not HasBuff(def.ids) then
                    PlayAlert()
                    break
                end
            end
        end

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local a = {...}
        local sub = a[2]
        if not sub then return end

        -- Dual-Format GUID-Erkennung (mit/ohne hideCaster)
        local pGUID    = UnitGUID("player")
        local spellPos = 12
        local srcGUID  = a[4]
        local srcName  = a[5]
        local dstGUID, dstName
        -- Hilfsfunktion: ist ein GUID ein bekannter Spieler (Roster oder eigener Char)?
        local function isPlayer(g) return g and (g == pGUID or roster[g]) end
        local function isNPC(g)    return g and g ~= "" and not isPlayer(g) end

        -- Format A (mit hideCaster): a[3]=bool, a[4]=srcGUID, a[8]=dstGUID
        -- Format B (ohne hideCaster): a[3]=srcGUID, a[4]=srcName, a[7]=dstGUID
        -- Strategie: probiere Format A zuerst (srcGUID an Pos 4 erkennbar als GUID-String)
        local function looksLikeGUID(s) return type(s)=="string" and s:find("-",1,true) end

        if looksLikeGUID(a[4]) then
            -- Format A: a[4]=srcGUID, a[8]=dstGUID
            srcGUID=a[4]; srcName=a[5]; dstGUID=a[8]; dstName=a[9]
        elseif looksLikeGUID(a[3]) then
            -- Format B: a[3]=srcGUID, a[7]=dstGUID
            srcGUID=a[3]; srcName=a[4]; dstGUID=a[7]; dstName=a[8]; spellPos=10
        else
            return
        end

        -- Nur Events verarbeiten die uns oder unsere Gruppe betreffen
        if not isPlayer(srcGUID) and not isPlayer(dstGUID) then return end

        -- ① Auto-Angriff + Maul Tracking (eigener Spieler als Angreifer)
        if srcGUID == pGUID then
            if sub == "SWING_DAMAGE" or sub == "SWING_MISSED" then
                lastSwingTime = GetTime()
            elseif sub == "SPELL_CAST_START" and MAUL_IDS[a[spellPos]] then
                maulQueued = true
            elseif (sub == "SPELL_DAMAGE" or sub == "SPELL_MISSED") and MAUL_IDS[a[spellPos]] then
                maulQueued = false
            end
        end

        -- ② NPC greift Spieler/Gruppe an → Aggro-Tracking
        if isNPC(srcGUID) and isPlayer(dstGUID) then
            if sub=="SWING_DAMAGE" or sub=="SWING_MISSED"
            or sub=="SPELL_DAMAGE" or sub=="SPELL_MISSED"
            or sub=="RANGE_DAMAGE" or sub=="RANGE_MISSED" then
                RecordAttack(srcGUID, srcName or "?", dstGUID)
            end
        end

        -- ③ Heiler erkennen: Spieler aus Gruppe castet Heilzauber
        if sub == "SPELL_HEAL" and srcGUID and roster[srcGUID] then
            healerCache[srcGUID] = true
        end
    end
end)

-- ============================================================
-- UPDATE LOOP
-- ============================================================
local tick      = 0
local threatTick = 0
Frame:SetScript("OnUpdate", function(self, dt)
    tick = tick + dt
    if tick < 0.15 then return end
    tick = 0

    -- Aggro-Monitor (alle 0.5s, nur wenn Frame sichtbar)
    threatTick = threatTick + 0.15
    if threatTick >= 0.5 and TF:IsShown() then
        threatTick = 0
        UpdateThreatUI()
    end

    -- === Rage ===
    local rage    = UnitPower("player", 1)
    local rageMax = UnitPowerMax("player", 1)
    if rageMax < 1 then rageMax = 100 end
    local pct = rage / rageMax
    rBar:SetMinMaxValues(0, rageMax)
    rBar:SetValue(rage)
    rVal:SetText(rage .. " / " .. rageMax)
    if pct >= 0.7 then
        rBar:SetStatusBarColor(1.0, 0.40, 0.05)   -- Orange-Rot bei hoher Wut
    elseif pct >= 0.35 then
        rBar:SetStatusBarColor(RED[1], RED[2], RED[3])
    else
        rBar:SetStatusBarColor(0.55, 0.10, 0.04)  -- Dunkles Rot bei wenig Wut
    end

    -- === Bear Form ===
    local inBear, isDire = InBearForm()
    if inBear then
        hAccent:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 1)
        hDot:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
        hDot:SetText("o")
        hTitle:SetText(isDire and L.DIRE_BEAR or L.BEAR_FORM)
        hTitle:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
    else
        hAccent:SetColorTexture(RED[1], RED[2], RED[3], 1)
        hDot:SetTextColor(RED[1], RED[2], RED[3])
        hDot:SetText("!")
        hTitle:SetText(L.NO_BEAR)
        hTitle:SetTextColor(RED[1], RED[2], RED[3])
    end

    -- === Maul ===
    if maulQueued then
        mTxt:SetText(L.MAUL_READY)
        mTxt:SetTextColor(ORANGE[1], ORANGE[2], ORANGE[3])
        mState:SetText(">")
        mState:SetTextColor(ORANGE[1], ORANGE[2], ORANGE[3])
        mSect:SetColorTexture(0.14, 0.08, 0.01, 0.7)
    else
        mTxt:SetText(L.MAUL_INACTIVE)
        mTxt:SetTextColor(DIM[1], DIM[2], DIM[3])
        mState:SetText("")
        mSect:SetColorTexture(BG2[1], BG2[2], BG2[3], 0.5)
    end

    -- === Auto-Attack ===
    local inCombat = UnitAffectingCombat("player")
    if not inBear or not inCombat then
        aaTxt:SetText(L.AA_IDLE)
        aaTxt:SetTextColor(DIM[1], DIM[2], DIM[3])
        aaState:SetText("")
        aaWasOff = false
    else
        local aaSpeed = UnitAttackSpeed("player") or 2.0
        local aaOff   = (GetTime() - lastSwingTime) > (aaSpeed + 1.5)
        if aaOff then
            aaTxt:SetText(L.AA_OFF)
            aaTxt:SetTextColor(REDBR[1], REDBR[2], REDBR[3])
            aaState:SetText("!")
            aaState:SetTextColor(REDBR[1], REDBR[2], REDBR[3])
            -- Sound nur wenn Zustand wechselt (Edge-Detection)
            if not aaWasOff and DB and DB.soundAutoOff then
                PlayWarn()
            end
        else
            aaTxt:SetText(L.AA_ACTIVE)
            aaTxt:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
            aaState:SetText("o")
            aaState:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
        end
        aaWasOff = aaOff
    end

    -- === Buff-Checker mit Icons ===
    local playerLevel = UnitLevel("player")
    for _, bs in ipairs(buffSlots) do
        local bf = bs.frame
        if playerLevel >= bs.def.minLevel then
            bf:Show()
            if HasBuff(bs.def.ids) then
                bf.border:SetColorTexture(GREEN[1], GREEN[2], GREEN[3], 0.9)
                bf.overlay:SetColorTexture(0, 0, 0, 0)
                bf.statusLbl:SetText(bs.def.label)
                bf.statusLbl:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
            else
                bf.border:SetColorTexture(RED[1], RED[2], RED[3], 0.9)
                bf.overlay:SetColorTexture(1, 0, 0, 0.25)
                bf.statusLbl:SetText(bs.def.label)
                bf.statusLbl:SetTextColor(RED[1], RED[2], RED[3])
            end
        else
            bf:Hide()
        end
    end

    -- === Faerie Fire ===
    if UnitExists("target") then
        local r = DebuffOnTarget(FF_IDS)
        if r then
            local t  = r >= 999 and "~" or string.format("%ds", math.floor(r))
            local cl = r < 4 and ORANGE or GREEN
            fVal:SetText(t); fVal:SetTextColor(cl[1], cl[2], cl[3])
            fLbl:SetTextColor(cl[1], cl[2], cl[3])
        else
            fVal:SetText("!"); fVal:SetTextColor(RED[1], RED[2], RED[3])
            fLbl:SetTextColor(RED[1], RED[2], RED[3])
        end
    else
        fVal:SetText("---"); fVal:SetTextColor(DIM[1], DIM[2], DIM[3])
        fLbl:SetTextColor(DIM[1], DIM[2], DIM[3])
    end

    -- === Demo Roar ===
    if UnitExists("target") then
        local r = DebuffOnTarget(DR_IDS)
        if r then
            local t  = r >= 999 and "~" or string.format("%ds", math.floor(r))
            local cl = r < 3 and ORANGE or GREEN
            dVal:SetText(t); dVal:SetTextColor(cl[1], cl[2], cl[3])
            dLbl:SetTextColor(cl[1], cl[2], cl[3])
        else
            dVal:SetText("!"); dVal:SetTextColor(RED[1], RED[2], RED[3])
            dLbl:SetTextColor(RED[1], RED[2], RED[3])
        end
    else
        dVal:SetText("---"); dVal:SetTextColor(DIM[1], DIM[2], DIM[3])
        dLbl:SetTextColor(DIM[1], DIM[2], DIM[3])
    end

    -- === Cooldowns ===
    for _, f in ipairs(cdSlots) do
        local c = cache[f.key]
        if not c then
            f.border:SetColorTexture(DKBG[1], DKBG[2], DKBG[3], 0.3)
            f.icon:SetColorTexture(0.04, 0.04, 0.08, 1)
            f.overlay:SetColorTexture(0, 0, 0, 0)
            f.timer:SetText(f.minLevel)
            f.timer:SetTextColor(DIM[1]*0.5, DIM[2]*0.5, DIM[3]*0.5)
            f.lbl:SetTextColor(DIM[1]*0.4, DIM[2]*0.4, DIM[3]*0.4)
        else
            if not f.iconSet and c.icon then
                f.icon:SetTexture(c.icon); f.iconSet = true
            end
            f.lbl:SetTextColor(DGOLD[1], DGOLD[2], DGOLD[3])
            local cd = GetCD(f.key) or 0
            if cd <= 0 then
                f.border:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.9)
                f.overlay:SetColorTexture(0, 0, 0, 0)
                f.timer:SetText(L.READY)
                f.timer:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
            elseif cd < 5 then
                f.border:SetColorTexture(ORANGE[1], ORANGE[2], ORANGE[3], 0.9)
                f.overlay:SetColorTexture(0, 0, 0, 0.30)
                f.timer:SetText(string.format("%.1f", cd))
                f.timer:SetTextColor(ORANGE[1], ORANGE[2], ORANGE[3])
            else
                f.border:SetColorTexture(BDR[1]*0.4, BDR[2]*0.4, BDR[3]*0.4, 0.6)
                f.overlay:SetColorTexture(0, 0, 0, 0.65)
                f.timer:SetText(math.ceil(cd))
                f.timer:SetTextColor(WHITE[1], WHITE[2], WHITE[3])
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
        print("|cff14CCADGuardianHelper:|r " .. (DB and DB.locked and L.MSG_LOCKED or L.MSG_UNLOCKED))
    elseif msg == "hide"  then Frame:Hide()
    elseif msg == "show"  then Frame:Show()
    elseif msg == "aggro" then
        if TF:IsShown() then TF:Hide(); if DB then DB.showAggro=false end
        else TF:Show(); if DB then DB.showAggro=true end end
    elseif msg == "config" or msg == "cfg" then
        if CFG:IsShown() then CFG:Hide() else CFG:Show() end
    elseif msg == "reset" then
        Frame:ClearAllPoints()
        Frame:SetPoint("CENTER", UIParent, "CENTER", 350, 0)
        if DB then DB.x, DB.y = nil, nil end
    elseif msg == "update" then
        BuildCache()
        print("|cff14CCADGuardianHelper:|r " .. L.MSG_UPDATED)
    elseif msg == "status" then
        print("|cff14CCADGuardianHelper — Spells:|r")
        for k, g in pairs(SPELL_GROUPS) do
            local c = cache[k]
            if c then
                print("  " .. g.label .. ": " .. (GetSpellInfo(c.id) or "?") .. " (Lvl "..c.lv..")")
            else
                print("  |cff333355" .. g.label .. ": ab Lvl "..g.ranks[1].lv.."|r")
            end
        end
    else
        print("|cff14CCADGuardianHelper|r |cff1AA8FFv"..VERSION.."|r")
        print("  /gh lock  hide  show  reset  update  status  config  aggro")
    end
end
