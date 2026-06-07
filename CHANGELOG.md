# Changelog

## [2.1.0] - 2026-06-07

### Neu
- Multi-Version Support: Classic Era, TBC Classic & Anniversary Edition
- Separate TOC-Dateien: `_Vanilla.toc` (Classic Era 1.15.x) und `_BCC.toc` (TBC 2.5.5)
- Interface-Nummer korrigiert auf 20505 für TBC Anniversary

---

## [2.0.0] - 2026-06-07

### Neu
- Level 1–70 Support (Classic Era & TBC Classic)
- Automatische Aktionsleisten-Aktualisierung beim Level-Up und nach Trainer-Besuch
- Dynamischer Spellbook-Scan — kein festes Spell-ID Lookup mehr
- TBC-Spells: Mangle (Bear) R1–R2, Lacerate R1
- Slash-Commands: `/gh status`, `/gh update`
- Cooldown-Panel zeigt "Lvl XX" für noch nicht gelernte Spells
- Combat Log Tracking für Maul-Queue via SPELL_CAST_START Event
- Automatischer Fallback DE/EN Spellnamen

### Geändert
- Frame-Größe passt sich dynamisch an Anzahl der Cooldown-Slots an
- Rage-Bar Farbschwellen überarbeitet (65% / 30%)
- Header zeigt "Dire Bear Form" vs "Bärengestalt" separat

### Behoben
- Falsche Maul-Rang ID (war R7 fixiert, jetzt dynamisch)
- Dire Bear Form wurde nicht erkannt wenn Bear Form Buff nicht aktiv

---

## [1.0.0] - 2026-06-06

### Erstveröffentlichung
- Rage-Bar mit Farbkodierung
- Bärenform-Warnung
- Maul-Queue Indicator
- Faerie Fire & Demoralizing Roar Debuff-Timer
- Cooldowns: Bash, Growl, Enrage, Frenzied Regen, Barkskin
- Slash-Commands: `/gh lock`, `/gh hide`, `/gh show`, `/gh reset`
