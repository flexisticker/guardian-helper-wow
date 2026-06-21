# GuardianHelper — Benutzerhandbuch / User Guide

> **Guardian Druid Tank Addon für WoW Classic & TBC Anniversary Edition**
> Version 4.4.0-beta | Level 1–70

---

## Installation

### Schritt 1: Dateien kopieren
Ordner `GuardianHelper` in das AddOns-Verzeichnis kopieren:

- **TBC Anniversary:** `World of Warcraft\_anniversary_\Interface\AddOns\`
- **TBC Classic:** `World of Warcraft\_classic_\Interface\AddOns\`
- **Classic Era / Hardcore:** `World of Warcraft\_classic_era_\Interface\AddOns\`

### Schritt 2: Aktivieren
1. WoW starten
2. Im Charakter-Auswahlscreen auf **„AddOns"** klicken
3. **GuardianHelper** aktivieren ✅
4. Einloggen → Im Chat erscheint: `GuardianHelper v4.4.0 bereit`

---

## Das HUD

```
┌──────────────────────────────┐
│ >> BAERENGESTALT          [o]│  ← Header: Form-Status + Statusdot
├──────────────────────────────┤
│ RAGE                   33/100│  ← Rage-Label + Wert
│ ████████░░░░░░░░░░░░░░░░░░░░│  ← Rage-Bar (rot)
├──────────────────────────────┤
│ - Krallenhieb inaktiv        │  ← Maul/Krallenhieb Queue
├──────────────────────────────┤
│ [*] FEF  12s  │  [*] Demo 8s │  ← Faerie Fire + Demo Roar Timer
├──────────────────────────────┤
│ [Hieb][Knurr][Rasen][F.Reg]  │  ← Cooldown-Slots (mit Icons)
│ [Borke][Zerr.][Aufr.]        │
└──────────────────────────────┘
```

### Header-Farben
| Anzeige | Bedeutung |
|---|---|
| Gold + grüner Dot `[o]` | In Bärengestalt ✅ |
| Rot + `!!` | Nicht in Bärenform ⚠️ |

### Rage-Bar Farben
| Farbe | Bedeutung |
|---|---|
| Grün | Rage > 70% — gut |
| Orange | Rage 30–70% |
| Rot | Rage < 30% — knapp |

### Maul / Krallenhieb Indicator
- **Orange:** Krallenhieb ist eingereiht für den nächsten Angriff
- **Grau:** Inaktiv

### Faerie Fire (FEF) & Demoralizing Roar (Demo)
- **Grün + Sekunden:** Debuff aktiv auf Ziel
- **Orange:** Läuft in < 4 Sekunden ab → erneuern!
- **Rot `!`:** Debuff fehlt → sofort anwenden!
- **`---`:** Kein Ziel ausgewählt

### Cooldown-Slots
| Anzeige | Bedeutung |
|---|---|
| Spell-Icon + goldener Rahmen + `OK` | Bereit |
| Spell-Icon + oranges Rahmen + Zeit | Läuft bald ab (< 5s) |
| Gedunkeltes Icon + Zahl | Auf Cooldown (Sekunden) |
| Dunkles Icon + Level-Zahl | Noch nicht gelernt |

---

## Click-to-Cast

Cooldown-Slots können direkt angeklickt werden:
- **Außerhalb Kampf:** Klick castet den Spell sofort
- **Im Kampf:** Tastenbelegung verwenden (siehe unten)

---

## Tastenbelegung einrichten

GuardianHelper nutzt WoW's eigenes Tastenbelegungssystem:

1. **ESC** drücken → **Tastenbelegung**
2. Tab **„Addons"** wählen
3. **GuardianHelper** Sektion suchen
4. `GHSlot1` bis `GHSlot7` entsprechende Tasten zuweisen

| Slot | Spell (DE) | Spell (EN) |
|---|---|---|
| GHSlot1 | Hieb | Bash |
| GHSlot2 | Knurren | Growl |
| GHSlot3 | Rasen | Enrage |
| GHSlot4 | Rasende Regeneration | Frenzied Regeneration |
| GHSlot5 | Baumrinde | Barkskin |
| GHSlot6 | Zerfleischen | Mangle (TBC) |
| GHSlot7 | Aufreißen | Lacerate (TBC) |

> **Tipp:** Maus über einen Slot bewegen → Tooltip zeigt aktuelle Tastenbelegung

---

## Minimap-Button

- **Klick:** HUD ein-/ausblenden
- **Drag:** Button auf der Minimap verschieben
- **Hover:** Tooltip mit Kurzanleitung

---

## Config Panel

Öffnen mit `/gh config` oder Klick auf den Minimap-Button.

| Option | Funktion |
|---|---|
| Maul Queue Alert | Krallenhieb-Anzeige aktiv/inaktiv |
| Sound bei Formverlust | Ton wenn Bärenform verloren *(geplant)* |
| Nur im Kampf zeigen | HUD nur während Kampf sichtbar |
| Opacity − / + | Transparenz des HUDs anpassen |

---

## Slash Commands

| Befehl | Funktion |
|---|---|
| `/gh help` | Alle Befehle anzeigen |
| `/gh lock` | Frame sperren / entsperren |
| `/gh hide` | HUD verstecken |
| `/gh show` | HUD anzeigen |
| `/gh reset` | Position zurücksetzen |
| `/gh config` | Config Panel öffnen |
| `/gh update` | Spell-Cache neu aufbauen |
| `/gh status` | Bekannte Spells und Ränge anzeigen |

---

## Unterstützte Spells (Level 1–70)

| Spell (DE) | Spell (EN) | Ab Level | TBC |
|---|---|---|---|
| Krallenhieb | Maul | 10 | ✅ |
| Prankenhieb | Swipe | 16 | ✅ |
| Hieb | Bash | 14 | ✅ |
| Abschreckungsbrüllen | Demoralizing Roar | 8 | ✅ |
| Knurren | Growl | 10 | — |
| Rasen | Enrage | 14 | — |
| Rasende Regeneration | Frenzied Regeneration | 36 | ✅ |
| Baumrinde | Barkskin | 44 | — |
| Feenfeuer (Feral) | Faerie Fire (Feral) | Talent | ✅ |
| Zerfleischen | Mangle (Bear) | 60 TBC | TBC |
| Aufreißen | Lacerate | 66 TBC | TBC |

---

## Bekannte Einschränkungen (Beta)

- Click-to-Cast funktioniert nur außerhalb des Kampfes direkt per Klick
- Im Kampf Tastenbelegungen via WoW-Menü nutzen
- Sound-Alert bei Formverlust noch nicht implementiert

---

## Links

- **GitHub:** https://github.com/flexisticker/guardian-helper-wow
- **CurseForge:** https://www.curseforge.com/wow/addons/guardianhelper
- **Bugs & Ideen:** https://github.com/flexisticker/guardian-helper-wow/issues

---

*GuardianHelper v4.4.0-beta — Made with love in Germany 🐻*
