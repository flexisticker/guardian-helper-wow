# Changelog

## [4.3.1] - 2026-06-07 — Hotfix

### Behoben
- Minimap-Button verschwand nach erstem Hover (GameTooltip.Hide rief Hide auf dem falschen Frame auf)

---

## [4.3.0] - 2026-06-07

### Neu
- Cooldown-Slots zeigen echte Ingame Spell-Icons via `GetSpellTexture()`
- Bereit: goldener Rahmen, kein Overlay
- Auf CD: dunkles Overlay über Icon + weißer Timer
- Fast bereit (< 5s): oranges Rahmen + leichtes Overlay
- Minimap-Button: Bear Form Icon via `GetSpellTexture(5487)`

### Behoben
- Minimap-Button: Parent auf UIParent geändert (nicht mehr Minimap) — kein hide-on-hover durch WoW-interne Scripts
- FrameLevel über Minimap gesetzt damit Button immer sichtbar bleibt

---

## [4.2.0] - 2026-06-07

### Neu
- Vollständige DE/EN Lokalisierung via `GetLocale()`
- Automatische Sprachauswahl: `deDE` = Deutsch, alle anderen = Englisch
- Maul heißt auf DE-Client: **Krallenhieb** (Bereit / inaktiv)
- Bärenform → Bärengestalt / Wilde Bärengestalt
- Alle sichtbaren Texte in `L{}` Tabelle ausgelagert (Header, Maul, Cooldowns, Config, Chat-Nachrichten)

---

## [4.1.0] - 2026-06-07

### Neu
- Kompletter Neuschrieb — stabiler Core für TBC Classic 2.5.5
- DB-Initialisierung via `ADDON_LOADED` Event (korrekte SavedVariables Reihenfolge)
- Minimap-Button mit Drag & Tooltip
- Config Panel (`/gh config`): Checkboxen, Opacity +/- Buttons
- SavedVariables: Frame-Position und Einstellungen bleiben nach Logout gespeichert

### Behoben
- `CombatLogGetCurrentEventInfo()` → varargs `...` (TBC Classic API)
- `C_Timer` → Frame-basierte Delays (TBC kompatibel)
- `OptionsSliderTemplate` entfernt (nicht in TBC Classic verfügbar)
- `## SavedVariables: GuardianHelperDB` im TOC ergänzt (Befehle funktionierten nicht)
- Emojis durch ASCII-Text ersetzt (WoW Classic rendert Emojis als Rechtecke)

---

## [4.0.0] - 2026-06-07

### Neu
- WoW Classic Style UI (Gold-Rahmen, dunkles Leder-Look)
- Minimap-Button (Klick: Ein/Ausblenden)
- Config Panel mit Einstellungen

---

## [3.0.0] - 2026-06-07

### Neu
- Kompaktes UI-Redesign (184px breit)
- Smaragdgrün + Gold Farbschema
- Grüner Glow-Rahmen aktiv / Rot bei fehlendem Bear Form

---

## [2.2.1] - 2026-06-07

### Behoben
- TBC Classic API Kompatibilität: varargs statt `CombatLogGetCurrentEventInfo()`

---

## [2.2.0] - 2026-06-07

### Neu
- Bear Icon (64×64 TGA) für WoW Addon-Liste
- `## IconTexture` in allen TOC-Dateien

---

## [2.1.0] - 2026-06-07

### Neu
- Multi-Version Support: Classic Era, TBC Classic & Anniversary Edition
- Separate TOC-Dateien: `_Vanilla.toc` (Classic Era 1.15.x) und `_BCC.toc` (TBC 2.5.5)
- Interface-Nummer korrigiert auf 20505 für TBC Anniversary

---

## [2.0.0] - 2026-06-07

### Neu
- Level 1–70 Support (Classic Era & TBC Classic)
- Automatische Aktionsleisten-Aktualisierung beim Level-Up
- Dynamischer Spellbook-Scan
- TBC-Spells: Mangle (Bear) R1–R2, Lacerate R1
- Slash-Commands: `/gh status`, `/gh update`
- Cooldown-Panel zeigt Mindest-Level für unbekannte Spells
- Combat Log Tracking für Maul-Queue

---

## [1.0.0] - 2026-06-06

### Erstveröffentlichung
- Rage-Bar mit Farbkodierung
- Bärenform-Warnung
- Maul-Queue Indicator
- Faerie Fire & Demoralizing Roar Debuff-Timer
- Cooldowns: Bash, Growl, Enrage, Frenzied Regen, Barkskin
- Slash-Commands: `/gh lock`, `/gh hide`, `/gh show`, `/gh reset`
