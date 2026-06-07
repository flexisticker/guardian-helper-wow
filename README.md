# 🐻 GuardianHelper

> **World of Warcraft Classic & TBC — Guardian Druid Tank Addon**  
> Unterstützt Level 1–70 | Classic Era & TBC Classic

---

## Features

- **Rage-Bar** — Farbkodiert: Grün (>65%), Orange (30–65%), Rot (<30%)
- **Bärenform-Anzeige** — Warnt sofort wenn du aus der Form fällst
- **Maul-Queue Indicator** — Zeigt ob Maul für den nächsten Angriff eingereiht ist
- **Faerie Fire Timer** — Uptime-Tracking auf dem aktuellen Ziel
- **Demoralizing Roar Timer** — Warnung wenn Debuff abläuft
- **Cooldown-Panel** — Bash, Growl, Enrage, Frenzied Regen, Barkskin, Mangle, Lacerate
- **Automatische Aktionsleisten-Aktualisierung** — Ersetzt alte Spell-Ränge beim Level-Up automatisch
- **Dynamische Spell-Erkennung** — Zeigt "Lvl XX" für noch nicht gelernte Spells

## Installation

1. Ordner `GuardianHelper` herunterladen
2. In WoW AddOns-Verzeichnis kopieren:
   - **Classic Era:** `World of Warcraft\_classic_era_\Interface\AddOns\`
   - **TBC Classic:** `World of Warcraft\_classic_\Interface\AddOns\`
3. WoW starten → AddOns-Button im Char-Auswahlscreen → **GuardianHelper** aktivieren

## Slash Commands

| Befehl | Funktion |
|---|---|
| `/gh help` | Alle Befehle anzeigen |
| `/gh lock` | Frame sperren/entsperren |
| `/gh hide` | Addon verstecken |
| `/gh show` | Addon anzeigen |
| `/gh reset` | Position zurücksetzen |
| `/gh update` | Aktionsleisten manuell aktualisieren |
| `/gh status` | Alle bekannten Spells mit Rang anzeigen |

## Spell-Ränge (Level 1–70)

| Spell | Classic Ränge | TBC Ränge | Ab Level |
|---|---|---|---|
| Maul | R1–R7 | R8–R9 | 10 |
| Swipe | R1–R5 | R6 | 16 |
| Bash | R1–R3 | R4 | 14 |
| Demoralizing Roar | R1–R5 | R6 | 8 |
| Frenzied Regeneration | R1–R3 | R4 | 36 |
| Barkskin | R1 | — | 44 |
| Mangle (Bear) | — | R1–R2 | 60 (TBC) |
| Lacerate | — | R1 | 66 (TBC) |

## Versionen

### v2.0.0 (aktuell)
- Vollständige Überarbeitung
- Level 1–70 Support (Classic + TBC)
- Automatische Aktionsleisten-Aktualisierung beim Level-Up
- Dynamischer Spellbook-Scan statt fester Spell-IDs
- Neue Slash-Commands: `/gh status`, `/gh update`
- TBC-Spells: Mangle (Bear), Lacerate
- Faerie Fire & Demo Roar Tracking

### v1.0.0
- Erstveröffentlichung
- Basic Rage, Form, Maul, Cooldowns
- Feste Spell-IDs (Level 60 only)

## Bekannte Einschränkungen

- Spell-Namen müssen mit dem WoW-Client übereinstimmen (DE/EN wird automatisch erkannt)
- Faerie Fire (Feral) nur verfügbar wenn Talent gesetzt
- Mangle (Bear) benötigt TBC-Feral-Talent

## Lizenz

MIT License — Free to use, modify and share.

---

*Erstellt mit ❤️ für Hardcore Druid Tanks*
