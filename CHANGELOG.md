# Changelog

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
