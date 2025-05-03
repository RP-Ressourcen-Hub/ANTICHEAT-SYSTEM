# 🛡️ Advanced AntiCheat System

Ein umfassendes AntiCheat-System für FiveM-Server, das vollständig mit ESX und QBCore kompatibel ist. Dieses System bietet fortschrittlichen Schutz vor einer Vielzahl von Cheat-Methoden und stellt sicher, dass dein Server sicher und fair für alle Spieler bleibt.

## 📋 Features

### Umfassende Cheat-Erkennung
- **Ressourcenerkennung**: Blockiert unerlaubte Ressourcen und Mod-Menüs
- **Waffen-Kontrolle**: Entfernt verbotene Waffen automatisch
- **Fahrzeug-Sicherheit**: Verhindert das Spawnen von nicht autorisierten Fahrzeugen
- **Objekt-Spam-Schutz**: Schützt deinen Server vor Objektflut und crashenden Props
- **Explosions-Kontrolle**: Blockiert unerlaubte Explosionen
- **Anti-Godmode**: Erkennt Spieler mit aktivierter Unsterblichkeit
- **Anti-Speedhack**: Überwacht Bewegungs- und Fahrzeuggeschwindigkeiten
- **Anti-Noclip**: Erkennt nicht autorisiertes No-Clip durch Wände und Objekte
- **Anti-Spectate**: Verhindert unerlaubtes Beobachten anderer Spieler

### Fortschrittliches Bypass-System
- Umfangreiche Bypass-Konfiguration für Administratoren und Staff
- Multiple Identifikationsmethoden (Steam, License, Discord, IP, etc.)
- Job-basierte Berechtigungen für bestimmte Aktionen
- Temporäre Bypass-Funktionalität für Entwicklungs- und Testzwecke
- Framework-spezifische Berechtigungslevel-Integration

### Intelligente Fehlalarm-Prävention
- Mehrfacherkennungssystem, um falsche Bans zu vermeiden
- Server-Last-abhängige Anpassung der Erkennungsgenauigkeit
- Grace-Period für Spieler nach dem Verbinden
- Framework-spezifische Überprüfungen und Anpassungen
- Event-Rate-Limiting zur Erkennung von Event-Spam

### Flexibles Ban-Management
- Progressive Ban-Zeiten für wiederholte Vergehen
- Hardware-ID-Erkennung zur Verhinderung von Ban-Umgehung
- Ban-Appeal-System-Integration
- VPN-Erkennung zur Vermeidung von Ban-Umgehung
- Umfangreiche Protokollierung aller Ban-Aktivitäten

### Discord-Integration
- Detaillierte Webhook-Benachrichtigungen für alle Erkennungstypen
- Separate Webhook-URLs für verschiedene Ereignisarten
- Anpassbare Embed-Nachrichten mit umfassenden Spielerinformationen
- Farbkodierte Warnungen basierend auf dem Schweregrad
- Optional: Screenshot-Integration bei Erkennung

## ⚙️ Installation

1. Kopiere den Ordner `[anticheat]` in dein `/resources/[standalone]`-Verzeichnis
2. Füge `ensure [standalone]/[anticheat]` zu deiner `server.cfg` hinzu (nach dem Framework und vor anderen Ressourcen)
3. Konfiguriere die Einstellungen in `config/config.lua` nach deinen Bedürfnissen
4. Starte deinen Server neu

## 🔧 Konfiguration

Das System bietet umfangreiche Konfigurationsmöglichkeiten in der `config/config.lua`:

### Grundlegende Einstellungen
```lua
Config.AntiCheatName = "Dein Server AntiCheat" -- Name deines AntiCheat-Systems
Config.Debug = false -- Aktiviere für detaillierte Debug-Informationen
Config.AdminsBypass = true -- Erlaubt Administratoren, Überprüfungen zu umgehen
```

### Bypass-System
```lua
Config.BypassSystem = {
    Enabled = true, -- Aktiviere das Bypass-System
    RequireAllChecks = true, -- Wenn true, müssen alle aktivierten Checks bestanden werden
    BypassIdentifiers = {
        Steam = { "steam:1234567890" }, -- Steam-Identifikatoren
        License = { "license:1234567890" }, -- Lizenz-Identifikatoren
        Discord = { "discord:1234567890" } -- Discord-Identifikatoren
    },
    BypassJobs = { "admin", "mod" } -- Jobs mit Bypass-Rechten
}
```

### Ban-System
```lua
Config.BanSystem = {
    Enabled = true, -- Aktiviere das Ban-System
    BanMessage = "Du wurdest vom Server gebannt. Grund: %s", -- Ban-Nachricht
    DefaultBanTime = 2592000, -- Standard-Ban-Zeit in Sekunden (30 Tage)
    MaxWarnings = 3 -- Maximale Anzahl an Warnungen vor einem Ban
}
```

### Discord-Integration
```lua
Config.Discord = {
    Enabled = true, -- Aktiviere Discord-Integration
    LogDetections = true, -- Protokolliere Erkennungen
    WebhookURL = "https://discord.com/api/webhooks/...", -- Deine Discord-Webhook-URL
    BotName = "AntiCheat Bot", -- Name des Discord-Bots
    BotAvatar = "https://deine-avatar-url.png" -- Avatar des Bots
}
```

## 🔍 Erkennungssysteme

Jedes Erkennungssystem kann individuell konfiguriert werden:

### Ressourcenerkennung
Erkennt und blockiert unerlaubte Ressourcen und Skripte.
```lua
Config.ResourceDetection = {
    Enabled = true, -- Aktiviere Ressourcenerkennung
    InstaBan = true, -- Sofortiger Ban bei Erkennung
    CheckInterval = 10000, -- Überprüfungsintervall in Millisekunden
    BlacklistedResources = { "eulencheats", "Lynx", "Absolute" } -- Liste verbotener Ressourcen
}
```

### Menüerkennung
Identifiziert bekannte Cheat-Menüs.
```lua
Config.MenuDetection = {
    Enabled = true, -- Aktiviere Menüerkennung
    InstaBan = true, -- Sofortiger Ban bei Erkennung
    CheckInterval = 10000, -- Überprüfungsintervall in Millisekunden
    Menus = { "LynxMenu", "HamHaxia", "Brutan" } -- Liste verbotener Menüs
}
```

### Waffenerkennung
Überwacht und entfernt nicht autorisierte Waffen.
```lua
Config.WeaponDetection = {
    Enabled = true, -- Aktiviere Waffenerkennung
    CheckPeds = true, -- Überprüfe auch Peds auf unerlaubte Waffen
    RemoveWeapon = true, -- Entferne die unerlaubte Waffe
    BlacklistedWeapons = { "WEAPON_RAILGUN", "WEAPON_RPG" } -- Liste verbotener Waffen
}
```

## 📊 Dynamische Anpassung

Das System passt seine Erkennungsintensität automatisch an die Serverlast an:

```lua
Config.FalsePositiveProtection = {
    Enabled = true, -- Aktiviere Fehlalarm-Schutz
    RequireMultipleDetections = true, -- Mehrere Erkennungen erforderlich
    DetectionThreshold = 3, -- Anzahl an Erkennungen vor Bestrafung
    ServerLoadProtection = {
        Enabled = true, -- Aktiviere Serverseitigen Performance-Schutz
        HighLoadThreshold = 90, -- CPU-Auslastungs-Schwellwert in Prozent
        ReduceChecksOnHighLoad = true -- Reduziere Überprüfungen bei hoher Serverlast
    }
}
```

## 🔒 Sicherheitsfunktionen

Zusätzliche Sicherheitsfunktionen schützen deinen Server umfassend:

```lua
Config.SecurityFeatures = {
    Enabled = true, -- Aktiviere allgemeine Sicherheitsfeatures
    EventProtection = {
        Enabled = true, -- Aktiviere Event-Schutz
        BlacklistedEvents = { "esx:getSharedObject", "esx_ambulancejob:revive" } -- Blockierte Events
    },
    InjectionProtection = {
        Enabled = true, -- Aktiviere Injektionsschutz
        SQLInjectionProtection = true -- Aktiviere SQL-Injektionsschutz
    }
}
```

## 📄 Exports und API

Das AntiCheat-System bietet folgende Exports für andere Ressourcen:

### Server-Side Exports
```lua
-- Prüft, ob ein Spieler einen Bypass hat
exports["[anticheat]"]:IsPlayerBypassed(playerId)

-- Bannt einen Spieler
exports["[anticheat]"]:BanPlayer(playerId, reason)

-- Fügt einem Spieler eine Warnung hinzu
exports["[anticheat]"]:AddPlayerWarning(playerId, reason)

-- Gibt die Anzahl der Warnungen eines Spielers zurück
exports["[anticheat]"]:GetPlayerWarnings(playerId)
```

### Client-Side Exports
```lua
-- Prüft, ob der Client einen Bypass hat
exports["[anticheat]"]:HasBypass()
```

## 🚀 Erweiterte Konfiguration

Für eine vollständige Anpassung deines AntiCheat-Systems, überprüfe alle verfügbaren Optionen in der `config/config.lua`. Jede Einstellung ist mit ausführlichen Kommentaren dokumentiert.

## 📌 Support und Updates

Unser Team stellt regelmäßige Updates bereit, um mit den neuesten Cheat-Methoden Schritt zu halten. Bei Fragen, Problemen oder Verbesserungsvorschlägen stehen wir dir gerne zur Verfügung.

Bitte kontaktiere uns über:
- Discord: [Dein Discord-Server-Link]
- GitHub: [Dein GitHub-Repository-Link]

---

© 2025 Dein Server Name. Alle Rechte vorbehalten.