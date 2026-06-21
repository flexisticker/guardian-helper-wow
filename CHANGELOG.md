# Changelog

## [4.8.0-beta] - 2026-06-21

### Neu
- **Aggro Monitor: Spieler immer sichtbar** — eigene Zeile immer an Position 1 (Teal-Farbe), zeigt eigene Mob-Anzahl oder `--`
- **Config: „Aggro: nur im Kampf"** — Monitor erscheint automatisch beim Pull und verschwindet nach Kampfende
- **Config: „Aggro Pos. reset"** — Button zum Zurücksetzen der Monitor-Position auf Standard
- **Minimap Rechtsklick** öffnet Config-Panel (Linksklick = Haupt-Panel wie bisher)

### Fix
- `CFG` Forward-Declaration vor Minimap-Button (nil value bei OnClick)
- `DebuffOnTarget` und `HasBuff` matchen jetzt per SpellID (Pos 9/10) + Name-Fallback — Feenfeuer-Erkennung robust
- Config-Panel Layout: doppeltes `Sep` entfernt, Höhe angepasst, Speichern/Abbrechen-Buttons korrekt positioniert
- `PARTY_MEMBERS_CHANGED` → `PARTY_MEMBER_ENABLE` + `PARTY_MEMBER_DISABLE` (TBC Classic API)
- Aggro-Monitor Teal-Stripe nil-chain fix (Zeile-Chaining über Zeilenumbruch)

### Geändert
- Version 4.8.0 / TOC 2.5.0

## [4.7.0-beta] - 2026-06-21

### Neu — Aggro Monitor (Gruppe/Raid Threat Tracker)
- **Neues Panel**: Separater draggbarer Aggro-Monitor (`/gh aggro` zum Ein/Ausblenden)
- **Echtzeit-Tracking**: Erkennt via Combat Log welche Gruppenmitglieder von wievielen Gegnern angegriffen werden
- **Bis zu 8 Zeilen**: Spieler mit Aggro, sortiert nach Mob-Anzahl (meiste zuerst)
- **Klassen-Farb-Streifen** links in WoW-Klassenfarbe
- **Mob-Anzahl farbkodiert**: Weiss=1, Orange=2, Rot=3+
- **Heiler-Erkennung**: 
  - Klassen-basiert (Priester/Druide/Schamane/Paladin) als Vorgabe
  - SPELL_HEAL-Events aus dem Combat Log markieren Spieler dynamisch als Heiler
  - Heiler-Zeilen: rotes Hintergrund + `[H]`-Badge + rote Namensfarbe
- **Click-to-Target**: SecureActionButtonTemplate - zielt Mob des Spielers an, auch im Kampf (kein UI-Taint)
- **Hover-Tooltip**: Zeigt Namen der angreifenden Mobs
- **Aggro-TTL 4s**: Mob gilt nach 4s ohne Angriff als disengaged
- **Auto-Reset** bei Kampfende (PLAYER_REGEN_ENABLED)
- **Roster-Tracking**: party1-4 + raid1-40, aktualisiert bei Gruppen-Aenderungen
- Position persistent in SavedVariables (DB.tx/DB.ty)

### Fix
- CLEU Dual-Format Erkennung fuer Auto-Angriff (mit/ohne hideCaster)
- Sound-Selector in Config: 6 Blizzard-Sounds je Kategorie mit Preview

### Geaendert
- Version 4.7.0 / TOC 2.4.0

## [4.6.0-beta] - 2026-06-21

### Neu — Modern Gaming UI Redesign
- **Electric-Blue Theme**: Dunkles Blau-Schwarz BG mit Electric-Blue Rahmen + Teal Akzent
- **WoW StatusBar** fuer Rage-Anzeige (natives Widget, glatter als Custom-Textur)
- **Spell-Icons fuer Buff-Checker**: Zeigt echte 22x22 Ingame-Icons fuer MotW/Dornen
  - Gruener Rahmen + kein Overlay = Buff aktiv
  - Roter Rahmen + rotes Overlay = Buff fehlt
- **Sound-Alerts** (einstellbar per /gh config):
  - `AlarmClockWarning2.ogg` wenn Auto-Angriff im Kampf einschlaeft
  - `AlarmClockWarning1.ogg` beim Pull-Start wenn ein Buff fehlt
  - Edge-Detection: Sound nur einmal wenn Zustand wechselt, nicht jeden Tick
- **Bear-Icon im Header** (GetSpellTexture des Bear Form Spells)
- **Spell-Icons fuer FF/Demo Roar** Zeile (10x10 Icons neben Labels)
- MORPHEUS.TTF fuer Header-Texte (WoW Gaming-Schrift)
- Config-Panel: 2 neue Checkboxen fuer Sound-Einstellungen
- Cooldowns auf CD zeigen Electric-Blue Rahmen statt Gold
- Version 4.6.0 / TOC 2.3.0

## [4.5.0-beta] - 2026-06-21

### Neu
- **Auto-Attack Indikator**: Zweite Statuszeile im Maul-Block zeigt ob Auto-Angriff laeuft
  - Gruen: Auto-Angriff aktiv (letzter Swing innerhalb der Angriffsgeschwindigkeit + 1.5s)
  - Rot: "!! AUTO AUS" — Auto-Angriff steht still obwohl im Kampf (Baerengestalt)
  - Grau: kein Kampf oder keine Baerengestalt
- Automatische Erkennung via `SWING_DAMAGE` / `SWING_MISSED` im Combat Log
- Angriffsgeschwindigkeit via `UnitAttackSpeed("player")` dynamisch berechnet
- Kampfstart (`PLAYER_REGEN_DISABLED`) setzt Timer zurueck — kein Sofort-Alarm beim Pull

### Geaendert
- Version 4.5.0 (war 4.2.0 im Code), TOC 2.2.0 (war 2.1.0)
- Status: Alpha → Beta

---

## [4.4.0-beta] - 2026-06-07

### Neu
- **Click-to-Cast**: Cooldown-Slots direkt anklicken zum Zaubern (in und außerhalb Kampf)
- **Tastenbelegung**: Über WoW's eigenes System (`ESC → Tastenbelegung → Addons → GHSlot1-7`)
- Tooltip auf Cooldown-Slots zeigt Spellname + aktuelle Tastenbelegung
- Lokalisierter Hinweis auf Tastenbelegungsmenü (DE/EN)

### Technisch
- `SecureActionButtonTemplate` statt `CastSpellByName` — kein UI-Taint
- Kein `SetBindingClick` mehr — verhinderte Laden des Addons in TBC Classic
- Spell-Attribute werden nur bei `PLAYER_LOGIN` gesetzt (sicher, kein Taint)

---

## [4.3.1] - 2026-06-07

### Behoben
- Minimap-Button verschwand nach erstem Hover (`GameTooltip.Hide` rief `Hide` auf dem falschen Frame auf)

---

## [4.3.0] - 2026-06-07

### Neu
- Cooldown-Slots zeigen echte Ingame Spell-Icons via `GetSpellTexture()`
- Bereit: goldener Rahmen, kein Overlay
- Auf CD: dunkles Overlay über Icon + weißer Timer
- Fast bereit (< 5s): oranges Rahmen + leichtes Overlay
- Minimap-Button: Bear Form Icon via `GetSpellTexture(5487)`

### Behoben
- Minimap-Button: Parent auf `UIParent` geändert — kein hide-on-hover
- FrameLevel über Minimap gesetzt damit Button immer sichtbar bleibt

---

## [4.2.0] - 2026-06-07

### Neu
- Vollständige DE/EN Lokalisierung via `GetLocale()`
- Automatische Sprachauswahl: `deDE` = Deutsch, alle anderen = Englisch
- Maul heißt auf DE-Client: **Krallenhieb**
- Alle sichtbaren Texte in `L{}` Tabelle ausgelagert

---

## [4.1.0] - 2026-06-07

### Neu
- Kompletter Neuschrieb — stabiler Core für TBC Classic 2.5.5
- DB-Initialisierung via `ADDON_LOADED` Event
- Minimap-Button mit Drag & Tooltip
- Config Panel (`/gh config`): Checkboxen, Opacity +/- Buttons
- SavedVariables: Frame-Position und Einstellungen persistent

### Behoben
- `CombatLogGetCurrentEventInfo()` → varargs (TBC Classic API)
- `C_Timer` → Frame-basierte Delays
- `OptionsSliderTemplate` entfernt
- `## SavedVariables: GuardianHelperDB` im TOC ergänzt
- Emojis durch ASCII-Text ersetzt

---

## [4.0.0] - 2026-06-07

### Neu
- WoW Classic Style UI (Gold-Rahmen, dunkles Leder-Look)
- Minimap-Button
- Config Panel

---

## [3.0.0] - 2026-06-07

### Neu
- Kompaktes UI-Redesign
- Smaragdgrün + Gold Farbschema

---

## [2.2.1] - 2026-06-07

### Behoben
- TBC Classic API: varargs statt `CombatLogGetCurrentEventInfo()`

---

## [2.2.0] - 2026-06-07

### Neu
- Bear Icon (64x64 TGA) für WoW Addon-Liste

---

## [2.1.0] - 2026-06-07

### Neu
- Multi-Version Support: Classic Era, TBC Classic & Anniversary Edition
- `_Vanilla.toc` (Classic Era) und `_BCC.toc` (TBC 2.5.5)

---

## [2.0.0] - 2026-06-07

### Neu
- Level 1–70 Support (Classic Era & TBC Classic)
- Automatische Aktionsleisten-Aktualisierung beim Level-Up
- TBC-Spells: Mangle (Bear), Lacerate
- Slash-Commands: `/gh status`, `/gh update`

---

## [1.0.0] - 2026-06-06

### Erstveröffentlichung
- Rage-Bar, Bärenform-Warnung, Maul-Queue Indicator
- Faerie Fire & Demoralizing Roar Debuff-Timer
- Cooldowns: Bash, Growl, Enrage, Frenzied Regen, Barkskin
- Slash-Commands: `/gh lock`, `/gh hide`, `/gh show`, `/gh reset`
