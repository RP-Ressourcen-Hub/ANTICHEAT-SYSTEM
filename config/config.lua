Config = {}

-- Allgemeine Einstellungen
Config.AntiCheatName = "Dein Server AntiCheat"
Config.Debug = false -- Aktiviere Debug-Protokollierung
Config.AdminsBypass = true -- Erlaubt Administratoren, einige Überprüfungen zu umgehen

-- Bypass-System (erweitert)
Config.BypassSystem = {
    Enabled = true, -- Aktiviere das Bypass-System
    
    -- Bypass-Methoden (alle müssen übereinstimmen für vollen Bypass)
    RequireAllChecks = true, -- Wenn true, müssen alle aktivierten Checks bestanden werden
    
    -- Erlaubte Benutzer über verschiedene Identifiers
    BypassIdentifiers = {
        Steam = {
            "steam:110000112345678", -- Beispiel (ersetzen)
        },
        License = {
            "license:1234567890abcdef1234567890abcdef12345678", -- Beispiel (ersetzen)
        },
        Discord = {
            "discord:123456789012345678", -- Beispiel (ersetzen)
        },
        XBL = {
            "xbl:12345678901234567", -- Beispiel (ersetzen)
        },
        Live = {
            "live:12345678901234567", -- Beispiel (ersetzen)
        },
        IP = {
            "ip:127.0.0.1", -- Beispiel (NUR für lokale Tests, ersetzen!)
        }
    },
    
    -- Bypass für bestimmte Ressourcen
    BypassResources = {
        "es_extended", -- Beispiel: ESX Framework kann bestimmte Aktionen ausführen
        "qb-core", -- Beispiel: QB-Core kann bestimmte Aktionen ausführen
        "vrp", -- Beispiel: vRP kann bestimmte Aktionen ausführen
        "vmenu", -- Beispiel: vMenu kann bestimmte Aktionen ausführen
        "admin_menu", -- Beliebiges Admin-Menü
    },
    
    -- Jobs mit automatischem Bypass
    BypassJobs = {
        "admin",
        "mod",
        "developer",
        "owner"
    },
    
    -- Berechtigungsstufen mit Bypass (Framework-spezifisch)
    BypassPermissionLevels = {
        -- ESX Berechtigungsstufen
        ESX = {
            "admin",
            "superadmin"
        },
        -- QBCore Berechtigungsstufen
        QBCore = {
            "admin",
            "god"
        }
    },
    
    -- ACE-Berechtigungen, die Bypass erlauben
    BypassAcePermissions = {
        "anticheatsystem.bypass",
        "admin.bypass",
        "anticheat.bypass"
    },
    
    -- Zeitlich begrenzter Bypass (für Entwicklungszwecke)
    TemporaryBypass = {
        Enabled = false, -- Aktiviere temporären Bypass
        Duration = 3600, -- Bypass-Dauer in Sekunden (1 Stunde)
        RequirePassword = true, -- Passwort erforderlich für temporären Bypass
        Password = "entwicklungsphase" -- Passwort für temporären Bypass
    }
}

-- Fehlalarm-Prävention
Config.FalsePositiveProtection = {
    Enabled = true, -- Aktiviere Fehlalarm-Schutz
    
    -- Mehrfacherkennungen erforderlich für Ban
    RequireMultipleDetections = true, -- Mehrere Erkennungen erforderlich
    DetectionThreshold = 3, -- Anzahl an Erkennungen vor Bestrafung
    DetectionTimeWindow = 600, -- Zeitfenster in Sekunden (10 Minuten)
    
    -- Server-Last-Schutz
    ServerLoadProtection = {
        Enabled = true, -- Aktiviere Serverseitigen Performance-Schutz
        HighLoadThreshold = 90, -- CPU-Auslastungs-Schwellwert in Prozent
        ReduceChecksOnHighLoad = true, -- Reduziere Überprüfungen bei hoher Serverlast
        DisableInstaBanOnHighLoad = true -- Deaktiviere Sofortbans bei hoher Serverlast
    },
    
    -- Framework-spezifische Überprüfungen
    FrameworkChecks = {
        -- Bei ESX zusätzliche Überprüfungen
        ESX = {
            CheckServerCallbacks = true, -- Überprüfe ESX Server-Callbacks
            CheckTriggerServerEvents = true, -- Überprüfe ESX Server-Events
        },
        -- Bei QBCore zusätzliche Überprüfungen
        QBCore = {
            CheckServerCallbacks = true, -- Überprüfe QBCore Server-Callbacks
            CheckTriggerServerEvents = true, -- Überprüfe QBCore Server-Events
        }
    },
    
    -- Bestimmte Events ignorieren (bekannte false positives)
    IgnoredEvents = {
        "esx:getSharedObject",
        "QBCore:GetObject",
        "esx_ambulancejob:revive",
        "esx_policejob:putInVehicle"
    },
    
    -- Verzögerung für bestimmte Checks nach dem Verbinden
    ConnectGracePeriod = 60, -- Grace period in Sekunden nach dem Verbinden
    
    -- Häufigkeitsbasierte Erkennung
    RateLimiting = {
        Enabled = true, -- Aktiviere Event-Häufigkeitsbegrenzung
        MaxEventsPerSecond = 20, -- Maximale Anzahl an Events pro Sekunde
        BurstAllowance = 50, -- Erlaubte Burst-Events für kurze Zeit
        WarningThreshold = 0.8 -- Warnschwellwert (80% des Limits)
    }
}

-- Administratoren (klassisches System, noch unterstützt für Abwärtskompatibilität)
Config.Admins = {
    "steam:110000112345678", -- Beispiel: Steam-Identifier (ersetzen)
    "license:1234567890abcdef1234567890abcdef12345678" -- Beispiel: Lizenz-Identifier (ersetzen)
}

-- Gebanntes Spieler-System
Config.BanSystem = {
    Enabled = true, -- Aktiviere das Ban-System
    BanMessage = "Du wurdest vom Server gebannt. Grund: %s", -- Ban-Nachricht (wird dem Spieler angezeigt)
    DefaultBanTime = 2592000, -- Standardmäßige Ban-Zeit in Sekunden (30 Tage)
    DefaultBanReason = "Cheat erkannt", -- Standardgrund für Bans
    MaxWarnings = 3, -- Maximale Anzahl an Warnungen vor einem Ban
    
    -- Erweiterte Ban-Funktionen
    AdvancedBanFeatures = {
        Enabled = true, -- Aktiviere erweiterte Ban-Funktionen
        
        -- Gestaffelte Bans (Erhöhung der Ban-Zeit bei wiederholtem Cheaten)
        ProgressiveBans = {
            Enabled = true, -- Aktiviere progressive Bans
            FirstBanDuration = 86400, -- Erste Ban-Dauer in Sekunden (1 Tag)
            SecondBanDuration = 604800, -- Zweite Ban-Dauer in Sekunden (7 Tage)
            ThirdBanDuration = 2592000, -- Dritte Ban-Dauer in Sekunden (30 Tage)
            FinalBanDuration = 0 -- Permanenter Ban (0 = permanent)
        },
        
        -- Hardware-Ban (HWID)
        HardwareBan = {
            Enabled = true, -- Aktiviere Hardware-Bans
            CollectHWID = true, -- Sammle Hardware-IDs für Bans
            EnforceHWIDBan = true -- Durchsetzen von Hardware-Bans
        },
        
        -- Ban-Umgehungsschutz
        BanEvasionProtection = {
            Enabled = true, -- Aktiviere Ban-Umgehungsschutz
            TrackAlternativeIdentifiers = true, -- Erfasse alternative Identifiers
            CompareIPRanges = true, -- Vergleiche IP-Bereiche (nicht nur exakte IPs)
            DetectVPNs = true -- Erkenne VPN-Nutzung (kann false positives verursachen)
        },
        
        -- Ban-Appeal-System
        BanAppeal = {
            Enabled = true, -- Aktiviere Ban-Appeal-System
            AppealURL = "https://deinserver.de/appeal", -- URL für Ban-Appeals
            IncludeAppealURLInBanMessage = true, -- Füge Appeal-URL in Ban-Nachricht ein
            MinimumAppealWait = 86400 -- Mindestwartezeit für Appeals in Sekunden (1 Tag)
        }
    }
}

-- Discord-Integration
Config.Discord = {
    Enabled = true, -- Aktiviere Discord-Integration
    LogDetections = true, -- Protokolliere Erkennungen
    WebhookURL = "", -- Discord-Webhook-URL für Benachrichtigungen
    BotName = "AntiCheat Bot", -- Name des Bots (für Embeds)
    BotAvatar = "https://deine-bot-avatar-url.png", -- Avatar des Bots (für Embeds)
    
    -- Erweiterte Discord-Integration
    AdvancedDiscordFeatures = {
        Enabled = true, -- Aktiviere erweiterte Discord-Features
        
        -- Separate Webhooks für verschiedene Ereignistypen
        Webhooks = {
            Bans = "", -- Webhook für Bans
            Warnings = "", -- Webhook für Warnungen
            Detections = "", -- Webhook für Erkennungen
            Bypasses = "", -- Webhook für Bypass-Nutzung
            Appeals = "" -- Webhook für Ban-Appeals
        },
        
        -- Zusätzliche Embed-Anpassungen
        RichEmbeds = {
            IncludePlayerInfo = true, -- Füge Spielerinfo in Embeds ein
            IncludeScreenshot = true, -- Füge Screenshot in Embeds ein (wenn verfügbar)
            IncludeLocation = true, -- Füge Spielerstandort in Embeds ein
            ColorCoding = true, -- Farbkodierung nach Schweregrad
            ThumbnailType = "player_avatar" -- Thumbnail-Typ (player_avatar, server_logo, none)
        },
        
        -- Discord-Bot-Integration (erfordert zusätzliches Setup)
        DiscordBot = {
            Enabled = false, -- Aktiviere Discord-Bot
            CommandPrefix = "!anticheat", -- Präfix für Bot-Befehle
            AllowedRoles = { -- Discord-Rollen, die Bot-Befehle nutzen dürfen
                "123456789012345678", -- Discord-Rollen-ID (ersetzen)
                "876543210987654321" -- Discord-Rollen-ID (ersetzen)
            }
        }
    }
}

-- Erkennung von unerlaubten Ressourcen
Config.ResourceDetection = {
    Enabled = true, -- Aktiviere Ressourcenerkennung
    InstaBan = true, -- Sofortiger Ban bei Erkennung
    CheckInterval = 10000, -- Überprüfungsintervall in Millisekunden
    
    -- Blacklist: Ressourcen, die nicht erlaubt sind
    BlacklistedResources = {
        "fivem-map-skater",
        "fivem-map-hipster",
        "rconlog",
        "fivem",
        "xfun",
        "Xfun",
        "XFUN",
        "redENGINE",
        "Eulen",
        "eulencheats",
        "ham",
        "HamHaxia",
        "HamMafia",
        "Lynx",
        "Absolute",
        "Falcon",
        "Luminous",
        "Tiago",
        "Dopamine",
        "Dopameme",
        "LynxRevolution",
        "Maestro",
        "WarMenu",
        "Brutan",
        "FiveM-Bypass",
        "Cheating",
        "Cheat",
        "Lumia",
        "Plane",
        "Proxy",
        "BadgerTools",
        "godmode",
        "MrBeast",
        "Nano66"
    },
    
    -- Erweiterte Ressourcenprüfung
    AdvancedResourceChecking = {
        Enabled = true, -- Aktiviere erweiterte Ressourcenprüfung
        
        -- Integrity-Checks für Server-Ressourcen
        CheckResourceIntegrity = true, -- Überprüfe Integrität der Ressourcen
        
        -- Dynamische Ressourcenerkennung
        DynamicDetection = {
            Enabled = true, -- Aktiviere dynamische Erkennung
            SuspiciousPatterns = { -- Verdächtige Muster in Ressourcennamen
                "cheat",
                "hack",
                "menu",
                "injector",
                "executor",
                "spawn",
                "troll",
                "bypass"
            },
            ExcludePatterns = { -- Ausgeschlossene Muster (keine false positives)
                "anticheat",
                "esx_menu",
                "qb-menu"
            }
        },
        
        -- Ressourcen-Signatur-Check
        SignatureChecking = {
            Enabled = true, -- Aktiviere Signatur-Check
            EnforceSignatureValidation = true, -- Erzwinge Signaturvalidierung
            AllowUnsignedEssentialResources = true -- Erlaube unsignierte essenzielle Ressourcen
        }
    }
}

-- Erkennung von unerlaubten Menüs/Executoren
Config.MenuDetection = {
    Enabled = true, -- Aktiviere Menüerkennung
    InstaBan = true, -- Sofortiger Ban bei Erkennung
    CheckInterval = 10000, -- Überprüfungsintervall in Millisekunden
    
    -- Blacklist: Menüs, die erkannt werden sollen
    Menus = {
        "Fallout",
        "Fiend",
        "ForceTeleport",
        "ForceMission",
        "ForceVehicle",
        "FreeCam",
        "GodMode",
        "Noclip",
        "PlayerBlips",
        "SpawnPed",
        "SpawnObject",
        "SpawnVehicle",
        "Teleport",
        "VehicleGun",
        "LynxMenu",
        "TiagoMenu",
        "LynxRevolution",
        "MaestroMenu",
        "HamHaxia",
        "Ham",
        "Brutan",
        "AbsoluteMenu",
        "SkidMenu",
        "AllahMenu",
        "MrBeast",
        "DopamineMenu",
        "DopamemMenu",
        "LynxSeven",
        "LynxEvo"
    },
    
    -- Erweiterte Menü-Erkennung
    AdvancedMenuDetection = {
        Enabled = true, -- Aktiviere erweiterte Menü-Erkennung
        
        -- Visuelle Menü-Erkennung
        VisualDetection = {
            Enabled = true, -- Aktiviere visuelle Erkennung
            ScreenshotOnSuspicion = true, -- Screenshot bei Verdacht (benötigt screenshot-basic)
            AnalyzeUIElements = true, -- Analysiere UI-Elemente
            DetectOverlays = true -- Erkenne Overlays
        },
        
        -- Verhaltensbasierte Menü-Erkennung
        BehavioralDetection = {
            Enabled = true, -- Aktiviere verhaltensbasierte Erkennung
            CheckSuspiciousInputs = true, -- Überprüfe verdächtige Eingaben
            CheckRapidActions = true, -- Überprüfe schnelle Aktionen
            CheckTeleportPatterns = true -- Überprüfe Teleport-Muster
        },
        
        -- Globale Variablen-Check
        GlobalVariableChecking = {
            Enabled = true, -- Aktiviere globale Variablen-Checks
            CheckTimingAttacks = true, -- Überprüfe Timing-Angriffe
            CheckProtectionBypass = true -- Überprüfe Schutz-Bypass
        }
    }
}

-- Erkennung von unerlaubten Waffen
Config.WeaponDetection = {
    Enabled = true, -- Aktiviere Waffenerkennung
    CheckPeds = true, -- Überprüfe auch Peds auf unerlaubte Waffen
    InstaBan = false, -- Sofortiger Ban bei Erkennung
    RemoveWeapon = true, -- Entferne die unerlaubte Waffe
    NotifyPlayer = true, -- Benachrichtige den Spieler
    CheckInterval = 5000, -- Überprüfungsintervall in Millisekunden
    
    -- Blacklist: Waffen, die nicht erlaubt sind
    BlacklistedWeapons = {
        "WEAPON_RAILGUN",
        "WEAPON_GRENADELAUNCHER",
        "WEAPON_RPG",
        "WEAPON_STINGER",
        "WEAPON_MINIGUN"
    },
    
    -- Erlaubte Waffen für bestimmte Jobs
    JobWeapons = {
        ["police"] = {
            "WEAPON_RAILGUN",
            "WEAPON_GRENADELAUNCHER"
        },
        ["sheriff"] = {
            "WEAPON_RAILGUN"
        }
    },
    
    -- Erweiterte Waffenerkennung
    AdvancedWeaponDetection = {
        Enabled = true, -- Aktiviere erweiterte Waffenerkennung
        
        -- Überprüfe Waffenkomponenten
        CheckWeaponComponents = true, -- Überprüfe Waffenkomponenten
        
        -- Überprüfe Munitionsmengen
        CheckAmmunitionAmounts = true, -- Überprüfe Munitionsmengen
        MaxAmmoMultiplier = 2.0, -- Maximaler Munitions-Multiplikator
        
        -- Überprüfe Waffenschaden
        CheckWeaponDamage = {
            Enabled = true, -- Aktiviere Schadensüberprüfung
            MaxDamageMultiplier = 1.2, -- Maximaler Schadens-Multiplikator
            CheckDamageModification = true -- Überprüfe Schadensmodifikation
        },
        
        -- Überprüfe Feuerrate
        CheckFireRate = {
            Enabled = true, -- Aktiviere Feuerraten-Überprüfung
            MaxFireRateMultiplier = 1.2, -- Maximaler Feuerraten-Multiplikator
            CheckRapidFire = true -- Überprüfe Schnellfeuer
        }
    }
}

-- Erkennung von unerlaubten Fahrzeugen
Config.VehicleDetection = {
    Enabled = true, -- Aktiviere Fahrzeugerkennung
    InstaBan = false, -- Sofortiger Ban bei Erkennung
    DeleteVehicle = true, -- Lösche das unerlaubte Fahrzeug
    NotifyPlayer = true, -- Benachrichtige den Spieler
    CheckInterval = 5000, -- Überprüfungsintervall in Millisekunden
    
    -- Blacklist: Fahrzeuge, die nicht erlaubt sind
    BlacklistedVehicles = {
        "khanjali",
        "rhino",
        "hydra",
        "lazer",
        "savage",
        "valkyrie",
        "cargoplane",
        "luxor",
        "jet"
    },
    
    -- Erlaubte Fahrzeuge für bestimmte Jobs
    JobVehicles = {
        ["police"] = {
            "rhino"
        },
        ["admin"] = {
            "jet",
            "luxor",
            "hydra"
        }
    },
    
    -- Erweiterte Fahrzeugerkennung
    AdvancedVehicleDetection = {
        Enabled = true, -- Aktiviere erweiterte Fahrzeugerkennung
        
        -- Fahrzeug-Modifikations-Prüfung
        CheckVehicleMods = {
            Enabled = true, -- Aktiviere Modifikationsprüfung
            CheckInvalidMods = true, -- Überprüfe ungültige Mods
            CheckModLimits = true -- Überprüfe Mod-Grenzen
        },
        
        -- Fahrzeug-Performance-Prüfung
        CheckVehiclePerformance = {
            Enabled = true, -- Aktiviere Performance-Prüfung
            MaxSpeedMultiplier = 1.5, -- Maximaler Geschwindigkeits-Multiplikator
            MaxAccelerationMultiplier = 1.5, -- Maximaler Beschleunigungs-Multiplikator
            MaxHandlingMultiplier = 1.5 -- Maximaler Handling-Multiplikator
        },
        
        -- Fahrzeug-Spawn-Prüfung
        CheckVehicleSpawning = {
            Enabled = true, -- Aktiviere Spawn-Prüfung
            TrackVehicleOrigin = true, -- Verfolge Fahrzeug-Ursprung
            MaxVehiclesOwnedByPlayer = 5, -- Maximale Anzahl an besitzten Fahrzeugen
            CheckVehicleSpawnRate = true -- Überprüfe Fahrzeug-Spawnrate
        }
    }
}

-- Erkennung von unerlaubten Objekten
Config.ObjectDetection = {
    Enabled = true, -- Aktiviere Objekterkennung
    InstaBan = false, -- Sofortiger Ban bei Erkennung
    DeleteObject = true, -- Lösche das unerlaubte Objekt
    NotifyPlayer = true, -- Benachrichtige den Spieler
    MaxObjectsPerPlayer = 15, -- Maximale Anzahl an Objekten pro Spieler
    CheckInterval = 10000, -- Überprüfungsintervall in Millisekunden
    
    -- Blacklist: Objekte, die nicht erlaubt sind
    BlacklistedObjects = {
        "prop_container_01a",
        "prop_container_02a",
        "prop_container_03a",
        "prop_container_03b",
        "prop_container_03mb",
        "prop_container_04a",
        "prop_container_04mb",
        "prop_container_05mb",
        "prop_container_door_mb_l",
        "prop_container_door_mb_r",
        "prop_container_hole",
        "prop_container_ld",
        "prop_container_ld2",
        "prop_container_old1",
        "prop_contnr_pile_01a",
        "prop_cs_dumpster_01a",
        "prop_dumpster_01a",
        "prop_dumpster_02a",
        "prop_dumpster_02b",
        "prop_dumpster_3a",
        "prop_dumpster_4a",
        "prop_dumpster_4b",
        "prop_bin_01a",
        "prop_bin_02a",
        "prop_bin_03a",
        "prop_bin_04a",
        "prop_bin_05a",
        "prop_bin_06a",
        "prop_bin_07a",
        "prop_bin_07b",
        "prop_bin_07c",
        "prop_bin_07d",
        "prop_bin_08a",
        "prop_bin_08open",
        "prop_bin_09a",
        "prop_bin_10a",
        "prop_bin_10b",
        "prop_bin_11a",
        "prop_bin_11b",
        "prop_bin_12a",
        "prop_bin_13a",
        "prop_bin_14a",
        "prop_bin_14b",
        "prop_bin_beach_01a",
        "prop_bin_beach_01d",
        "prop_bin_delpiero",
        "prop_bin_delpiero_b",
        "prop_rub_binbag_01",
        "prop_rub_binbag_01b",
        "prop_rub_binbag_03",
        "prop_rub_binbag_03b",
        "prop_rub_binbag_04",
        "prop_rub_binbag_05",
        "prop_rub_binbag_06",
        "prop_rub_binbag_08",
        "prop_rub_binbag_sd_01",
        "prop_rub_binbag_sd_02"
    },
    
    -- Erweiterte Objekterkennung
    AdvancedObjectDetection = {
        Enabled = true, -- Aktiviere erweiterte Objekterkennung
        
        -- Objekt-Spam-Schutz
        AntiObjectSpam = {
            Enabled = true, -- Aktiviere Anti-Objekt-Spam
            MaxObjectsPerSecond = 5, -- Maximale Anzahl an Objekten pro Sekunde
            MaxIdenticalObjects = 3, -- Maximale Anzahl identischer Objekte
            ObjectCooldown = 1000 -- Cooldown zwischen Objektspawns in Millisekunden
        },
        
        -- Objekt-Anhaftungs-Erkennung
        ObjectAttachmentDetection = {
            Enabled = true, -- Aktiviere Objekt-Anhaftungs-Erkennung
            CheckPlayerAttachments = true, -- Überprüfe Spieler-Anhaftungen
            CheckVehicleAttachments = true, -- Überprüfe Fahrzeug-Anhaftungen
            CheckPedAttachments = true -- Überprüfe Ped-Anhaftungen
        },
        
        -- Objekt-Manipulation-Erkennung
        ObjectManipulationDetection = {
            Enabled = true, -- Aktiviere Objekt-Manipulations-Erkennung
            CheckObjectScaling = true, -- Überprüfe Objekt-Skalierung
            CheckObjectPosition = true, -- Überprüfe Objekt-Position
            CheckObjectRotation = true -- Überprüfe Objekt-Rotation
        }
    }
}

-- Erkennung von Explosionen
Config.ExplosionDetection = {
    Enabled = true, -- Aktiviere Explosionserkennung
    InstaBan = false, -- Sofortiger Ban bei unerlaubten Explosionen
    BlockExplosion = true, -- Blockiere unerlaubte Explosionen
    NotifyPlayer = true, -- Benachrichtige den Spieler
    
    -- Erlaubte Explosionstypen (siehe https://wiki.rage.mp/index.php?title=Explosions)
    AllowedExplosions = {
        [0] = true,   -- GRENADE
        [1] = true,   -- GRENADELAUNCHER
        [2] = false,  -- STICKYBOMB
        [3] = true,   -- MOLOTOV
        [4] = true,   -- ROCKET
        [5] = true,   -- TANKSHELL
        [6] = false,  -- HI_OCTANE
        [7] = false,  -- CAR
        [8] = false,  -- PLANE
        [9] = true,   -- PETROL_PUMP
        [10] = false, -- BIKE
        [11] = false, -- STEAM
        [12] = false, -- FLAME
        [13] = false, -- WATER_HYDRANT
        [14] = false, -- GAS_CANISTER
        [15] = false, -- BOAT
        [16] = false, -- SHIP_DESTROY
        [17] = false, -- TRUCK
        [18] = false, -- BULLET
        [19] = false, -- SMOKEGRENADELAUNCHER
        [20] = false, -- SMOKEGRENADE
        [21] = false, -- BZGAS
        [22] = false, -- FLARE
        [23] = false, -- GAS_CANISTER
        [24] = false, -- EXTINGUISHER
        [25] = false, -- PROGRAMMABLEAR
        [26] = false, -- TRAIN
        [27] = false, -- BARREL
        [28] = false, -- PROPANE
        [29] = false, -- BLIMP
        [30] = false, -- FLAME
        [31] = false, -- TANKER
        [32] = false, -- PLANE_ROCKET
        [33] = false, -- VEHICLE_BULLET
        [34] = false, -- GAS_TANK
        [35] = false  -- BIRD_CRAP
    },
    
    -- Erlaubte Explosionen für bestimmte Jobs
    JobExplosions = {
        ["police"] = {
            [2] = true,   -- STICKYBOMB
            [6] = true,   -- HI_OCTANE
            [7] = true,   -- CAR
            [8] = true    -- PLANE
        }
    },
    
    -- Erweiterte Explosionserkennung
    AdvancedExplosionDetection = {
        Enabled = true, -- Aktiviere erweiterte Explosionserkennung
        
        -- Explosions-Häufigkeits-Erkennung
        ExplosionFrequencyDetection = {
            Enabled = true, -- Aktiviere Häufigkeits-Erkennung
            MaxExplosionsPerSecond = 3, -- Maximale Anzahl an Explosionen pro Sekunde
            MaxExplosionsPerMinute = 15, -- Maximale Anzahl an Explosionen pro Minute
            ExplosionCooldown = 1000 -- Cooldown zwischen Explosionen in Millisekunden
        },
        
        -- Explosions-Reichweiten-Erkennung
        ExplosionRangeDetection = {
            Enabled = true, -- Aktiviere Reichweiten-Erkennung
            MaxExplosionRange = 50.0, -- Maximale Explosions-Reichweite
            CheckExplosionVisibility = true -- Überprüfe Explosions-Sichtbarkeit
        },
        
        -- Massen-Explosionserkennung
        MassExplosionDetection = {
            Enabled = true, -- Aktiviere Massen-Explosionserkennung
            DetectChainExplosions = true, -- Erkenne Kettenexplosionen
            InstantActionThreshold = 5 -- Sofortige Aktion ab dieser Anzahl gleichzeitiger Explosionen
        }
    }
}

-- Anti-Godmode
Config.AntiGodmode = {
    Enabled = true, -- Aktiviere Anti-Godmode
    InstaBan = false, -- Sofortiger Ban bei Godmode-Erkennung
    NotifyPlayer = true, -- Benachrichtige den Spieler
    CheckInterval = 10000, -- Überprüfungsintervall in Millisekunden
    MaxHealth = 200, -- Maximale erlaubte Gesundheit
    MaxArmor = 100, -- Maximale erlaubte Rüstung
    IgnoreDead = true, -- Ignoriere tote Spieler
    
    -- Waffen, die vom Anti-Godmode ausgeschlossen sind
    ExcludedWeapons = {
        "WEAPON_STUNGUN",
        "WEAPON_SNOWBALL",
        "WEAPON_BALL"
    },
    
    -- Erweiterte Godmode-Erkennung
    AdvancedGodmodeDetection = {
        Enabled = true, -- Aktiviere erweiterte Godmode-Erkennung
        
        -- Gesundheits-Regenerations-Erkennung
        HealthRegenerationDetection = {
            Enabled = true, -- Aktiviere Regenerations-Erkennung
            MaxHealthRegenerationRate = 1.0, -- Maximale Gesundheits-Regenerationsrate pro Sekunde
            CheckInstantHealing = true -- Überprüfe sofortige Heilung
        },
        
        -- Schadensresistenz-Erkennung
        DamageResistanceDetection = {
            Enabled = true, -- Aktiviere Resistenz-Erkennung
            TestDamageApplications = true, -- Teste Schadensanwendungen
            MinDamagePercentage = 0.5 -- Minimaler Schadensprozentsatz, der angewendet werden sollte
        },
        
        -- Modifizierte Spielwert-Erkennung
        ModifiedGameValueDetection = {
            Enabled = true, -- Aktiviere modifizierte Spielwert-Erkennung
            CheckHealthMultipliers = true, -- Überprüfe Gesundheits-Multiplikatoren
            CheckDamageMultipliers = true -- Überprüfe Schadens-Multiplikatoren
        }
    }
}

-- Anti-Spectate
Config.AntiSpectate = {
    Enabled = true, -- Aktiviere Anti-Spectate
    InstaBan = false, -- Sofortiger Ban bei Spectate-Erkennung
    NotifyPlayer = true, -- Benachrichtige den Spieler
    CheckInterval = 5000, -- Überprüfungsintervall in Millisekunden
    
    -- Jobs, die Spectate verwenden dürfen
    AllowedJobs = {
        "admin",
        "mod"
    },
    
    -- Erweiterte Spectate-Erkennung
    AdvancedSpectateDetection = {
        Enabled = true, -- Aktiviere erweiterte Spectate-Erkennung
        
        -- Kamera-Positons-Analyse
        CameraPositionAnalysis = {
            Enabled = true, -- Aktiviere Kamera-Positions-Analyse
            CheckFreeCamUsage = true, -- Überprüfe FreeCam-Nutzung
            VerifyLineOfSight = true -- Überprüfe Sichtlinie
        },
        
        -- Spielerfolgungs-Analyse
        PlayerTrackingAnalysis = {
            Enabled = true, -- Aktiviere Spielerfolgungs-Analyse
            DetectPlayerFocus = true, -- Erkenne Spielerfokus
            DetectPlayerFollowing = true -- Erkenne Spielerverfolgung
        }
    }
}

-- Anti-Speedhack
Config.AntiSpeedhack = {
    Enabled = true, -- Aktiviere Anti-Speedhack
    InstaBan = false, -- Sofortiger Ban bei Speedhack-Erkennung
    NotifyPlayer = true, -- Benachrichtige den Spieler
    CheckInterval = 5000, -- Überprüfungsintervall in Millisekunden
    MaxWalkSpeed = 10.0, -- Maximale Gehgeschwindigkeit
    MaxRunSpeed = 15.0, -- Maximale Laufgeschwindigkeit
    MaxSwimSpeed = 8.0, -- Maximale Schwimmgeschwindigkeit
    MaxVehicleMultiplier = 3.0, -- Maximaler Fahrzeug-Geschwindigkeitsmultiplikator
    
    -- Fahrzeugmodelle, die ignoriert werden sollen
    IgnoreModels = {
        "adder",
        "autarch",
        "banshee2",
        "bullet",
        "cheetah",
        "cyclone",
        "deveste",
        "emerus",
        "entity2",
        "entityxf",
        "fmj",
        "gp1",
        "infernus",
        "italigtb",
        "italigtb2",
        "krieger",
        "le7b",
        "nero",
        "nero2",
        "osiris",
        "penetrator",
        "pfister811",
        "prototipo",
        "reaper",
        "s80",
        "sc1",
        "scramjet",
        "sheava",
        "sultanrs",
        "t20",
        "taipan",
        "tempesta",
        "tezeract",
        "thrax",
        "tigon",
        "turismor",
        "tyrant",
        "tyrus",
        "vacca",
        "vagner",
        "vigilante",
        "visione",
        "voltic",
        "voltic2",
        "xa21",
        "zentorno"
    },
    
    -- Erweiterte Speedhack-Erkennung
    AdvancedSpeedhackDetection = {
        Enabled = true, -- Aktiviere erweiterte Speedhack-Erkennung
        
        -- Bewegungsanalyse
        MovementAnalysis = {
            Enabled = true, -- Aktiviere Bewegungsanalyse
            CheckAcceleration = true, -- Überprüfe Beschleunigung
            CheckDeceleration = true, -- Überprüfe Verzögerung
            CheckDirectionChanges = true, -- Überprüfe Richtungsänderungen
            MaxAccelerationRate = 5.0 -- Maximale Beschleunigungsrate
        },
        
        -- Teleport-Erkennung (für Speedhack-basierte Teleports)
        TeleportDetection = {
            Enabled = true, -- Aktiviere Teleport-Erkennung
            MaxAllowedDistance = 100.0, -- Maximale erlaubte Distanz pro Check
            AllowVehicleTeleports = false, -- Erlaube Fahrzeug-Teleports
            ExcludedZones = { -- Ausgeschlossene Zonen (Koordinaten und Radius)
                {x = 0.0, y = 0.0, z = 0.0, radius = 100.0} -- Beispiel (City-Center)
            }
        },
        
        -- Fahrzeug-Boost-Erkennung
        VehicleBoostDetection = {
            Enabled = true, -- Aktiviere Fahrzeug-Boost-Erkennung
            AllowBoostForVehicles = { -- Fahrzeuge, für die Boost erlaubt ist
                "vigilante",
                "scramjet",
                "oppressor",
                "oppressor2"
            },
            MaxBoostMultiplier = 2.0 -- Maximaler Boost-Multiplikator
        }
    }
}

-- Anti-Noclip
Config.AntiNoclip = {
    Enabled = true, -- Aktiviere Anti-Noclip
    InstaBan = false, -- Sofortiger Ban bei Noclip-Erkennung
    NotifyPlayer = true, -- Benachrichtige den Spieler
    CheckInterval = 5000, -- Überprüfungsintervall in Millisekunden
    
    -- Jobs, die Noclip verwenden dürfen
    AllowedJobs = {
        "admin",
        "mod"
    },
    
    -- Erweiterte Noclip-Erkennung
    AdvancedNoclipDetection = {
        Enabled = true, -- Aktiviere erweiterte Noclip-Erkennung
        
        -- Kollisionserkennung
        CollisionDetection = {
            Enabled = true, -- Aktiviere Kollisionserkennung
            CheckBuildingCollisions = true, -- Überprüfe Gebäudekollisionen
            CheckObjectCollisions = true, -- Überprüfe Objektkollisionen
            CheckTerrainCollisions = true -- Überprüfe Terrainkollisionen
        },
        
        -- Positionserkennung
        PositionDetection = {
            Enabled = true, -- Aktiviere Positionserkennung
            CheckUnreachablePositions = true, -- Überprüfe unerreichbare Positionen
            CheckImpossibleMovement = true, -- Überprüfe unmögliche Bewegungen
            CheckWallBreaching = true -- Überprüfe Wanddurchbrüche
        },
        
        -- Noclip-Verhaltensanalyse
        NoclipBehaviorAnalysis = {
            Enabled = true, -- Aktiviere Verhaltensanalyse
            DetectSuspiciousMovementPatterns = true, -- Erkenne verdächtige Bewegungsmuster
            DetectAbnormalHeightChanges = true, -- Erkenne abnormale Höhenänderungen
            DetectClippingThroughObjects = true -- Erkenne Durchdringen von Objekten
        }
    }
}

-- Allgemeine Sicherheitseinstellungen
Config.SecurityFeatures = {
    Enabled = true, -- Aktiviere allgemeine Sicherheitsfeatures
    
    -- Event-Schutz
    EventProtection = {
        Enabled = true, -- Aktiviere Event-Schutz
        
        -- Blacklist für Events (wird blockiert)
        BlacklistedEvents = {
            "esx:getSharedObject",
            "esx_ambulancejob:revive",
            "esx_policejob:handcuff",
            "esx_policejob:drag",
            "esx_policejob:putInVehicle",
            "esx_policejob:OutVehicle",
            "esx_ambulancejob:heal",
            "esx_policejob:requestarrest",
            "esx_policejob:requestrelease",
            "esx_policejob:sethandcuffs",
            "esx_policejob:drag",
            "esx_policejob:putinvehicle",
            "esx_policejob:outvehicle",
            "esx_policejob:message",
            "esx_billing:sendBill"
        },
        
        -- Schütze kritische Events
        ProtectCriticalEvents = true, -- Aktiviere Schutz für kritische Events
        
        -- Event-Rate-Limiting
        EventRateLimit = {
            Enabled = true, -- Aktiviere Event-Rate-Limiting
            MaxEventsPerSecond = 50, -- Maximale Anzahl an Events pro Sekunde
            MaxEventsPerMinute = 500, -- Maximale Anzahl an Events pro Minute
            BlockOnExceed = true -- Blockiere bei Überschreitung
        }
    },
    
    -- Injektionsschutz
    InjectionProtection = {
        Enabled = true, -- Aktiviere Injektionsschutz
        
        -- SQL-Injektionsschutz
        SQLInjectionProtection = true, -- Aktiviere SQL-Injektionsschutz
        
        -- JavaScript-Injektionsschutz
        JavaScriptInjectionProtection = true, -- Aktiviere JavaScript-Injektionsschutz
        
        -- LUA-Injektionsschutz (natives)
        LuaInjectionProtection = true -- Aktiviere LUA-Injektionsschutz
    },
    
    -- Entitäts-Besitzschutz
    EntityOwnershipProtection = {
        Enabled = true, -- Aktiviere Entitäts-Besitzschutz
        
        -- Fahrzeugbesitz-Schutz
        VehicleOwnership = true, -- Aktiviere Fahrzeugbesitz-Schutz
        
        -- Objektbesitz-Schutz
        ObjectOwnership = true, -- Aktiviere Objektbesitz-Schutz
        
        -- Ped-Besitz-Schutz
        PedOwnership = true -- Aktiviere Ped-Besitz-Schutz
    },
    
    -- Spielersicherheit
    PlayerSecurity = {
        Enabled = true, -- Aktiviere Spielersicherheit
        
        -- Koordinaten-Schutz
        CoordinateProtection = {
            Enabled = true, -- Aktiviere Koordinaten-Schutz
            CheckTeleportRange = true, -- Überprüfe Teleport-Reichweite
            MaxTeleportDistance = 500.0 -- Maximale Teleport-Distanz
        },
        
        -- Spielerdaten-Schutz
        PlayerDataProtection = {
            Enabled = true, -- Aktiviere Spielerdaten-Schutz
            ProtectMoneyTransactions = true, -- Schütze Geldtransaktionen
            ProtectInventoryModifications = true, -- Schütze Inventar-Modifikationen
            ProtectPermissionChanges = true -- Schütze Berechtigungs-Änderungen
        }
    },
    
    -- Logging und Auditing
    LoggingAndAuditing = {
        Enabled = true, -- Aktiviere Logging und Auditing
        
        -- Aktionsprotokollierung
        ActionLogging = {
            Enabled = true, -- Aktiviere Aktionsprotokollierung
            LogAdminActions = true, -- Protokolliere Admin-Aktionen
            LogPlayerActions = true, -- Protokolliere Spieler-Aktionen
            LogResourceChanges = true -- Protokolliere Ressourcen-Änderungen
        },
        
        -- Sicherheitsprotokollierung
        SecurityLogging = {
            Enabled = true, -- Aktiviere Sicherheitsprotokollierung
            LogDetections = true, -- Protokolliere Erkennungen
            LogBans = true, -- Protokolliere Bans
            LogWarnings = true, -- Protokolliere Warnungen
            StorageDuration = 30 -- Speicherdauer in Tagen
        }
    }
}