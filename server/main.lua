--[[
    Advanced AntiCheat System - Server Side
    Kompatibel mit ESX und QBCore Framework
]]

local Framework = nil
local Players = {}
local BannedPlayers = {}
local ESX, QBCore = nil, nil

-- Framework-Detection und Initialisierung
Citizen.CreateThread(function()
    if GetResourceState("es_extended") == "started" then
        Framework = "ESX"
        while not ESX do
            TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
            Citizen.Wait(100)
        end
        if Config.Debug then
            print("[AntiCheat] ESX Framework erkannt und initialisiert.")
        end
    elseif GetResourceState("qb-core") == "started" then
        Framework = "QBCore"
        QBCore = exports["qb-core"]:GetCoreObject()
        if Config.Debug then
            print("[AntiCheat] QBCore Framework erkannt und initialisiert.")
        end
    else
        Framework = "Standalone"
        if Config.Debug then
            print("[AntiCheat] Kein Framework erkannt, läuft im Standalone-Modus.")
        end
    end
end)

-- Hilfs-Tabelle für Event-Handling
local EventHandlers = {}

-- Hilfs-Funktionen
local function GetPlayerDetails(source)
    local identifiers = {}
    local playerName = GetPlayerName(source)
    
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.match(v, "steam:") then
            identifiers.steam = v
        elseif string.match(v, "license:") then
            identifiers.license = v
        elseif string.match(v, "discord:") then
            identifiers.discord = v
        elseif string.match(v, "ip:") then
            identifiers.ip = v
        elseif string.match(v, "xbl:") then
            identifiers.xbl = v
        elseif string.match(v, "live:") then
            identifiers.live = v
        end
    end
    
    return {
        source = source,
        name = playerName,
        identifiers = identifiers,
        job = GetPlayerJob(source),
        permissions = GetPlayerPermissions(source)
    }
end

local function GetPlayerJob(source)
    if not source or source == 0 then return "unemployed" end
    
    if Framework == "ESX" and ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.job.name
        end
    elseif Framework == "QBCore" and QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData.job.name
        end
    end
    
    return "unemployed"
end

local function GetPlayerPermissions(source)
    if not source or source == 0 then return {} end
    
    local permissions = {}
    
    -- Framework-spezifische Berechtigungsprüfung
    if Framework == "ESX" and ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            permissions.group = xPlayer.getGroup()
        end
    elseif Framework == "QBCore" and QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            permissions.group = QBCore.Functions.GetPermission(source)
        end
    end
    
    -- ACE-Berechtigungsprüfung
    for _, acePermission in ipairs(Config.BypassSystem.BypassAcePermissions) do
        if IsPlayerAceAllowed(source, acePermission) then
            permissions.ace = permissions.ace or {}
            table.insert(permissions.ace, acePermission)
        end
    end
    
    return permissions
end

local function IsPlayerBypassed(source)
    if not Config.BypassSystem.Enabled then return false end
    
    local playerDetails = GetPlayerDetails(source)
    
    -- Admin-Bypass (alte Methode, für Kompatibilität)
    if Config.AdminsBypass then
        for _, adminIdentifier in ipairs(Config.Admins) do
            for _, playerIdentifier in pairs(playerDetails.identifiers) do
                if playerIdentifier == adminIdentifier then
                    return true
                end
            end
        end
    end
    
    -- Bypass durch Identifikatoren
    local identifierBypass = false
    for identifierType, identifiers in pairs(Config.BypassSystem.BypassIdentifiers) do
        local playerIdentifier = playerDetails.identifiers[string.lower(identifierType)]
        if playerIdentifier then
            for _, bypasIdentifier in ipairs(identifiers) do
                if playerIdentifier == bypasIdentifier then
                    identifierBypass = true
                    break
                end
            end
        end
        
        if identifierBypass then break end
    end
    
    -- Bypass durch Job
    local jobBypass = false
    if playerDetails.job then
        for _, job in ipairs(Config.BypassSystem.BypassJobs) do
            if playerDetails.job == job then
                jobBypass = true
                break
            end
        end
    end
    
    -- Bypass durch Berechtigungen
    local permissionBypass = false
    if playerDetails.permissions.group then
        if Framework == "ESX" then
            for _, level in ipairs(Config.BypassSystem.BypassPermissionLevels.ESX) do
                if playerDetails.permissions.group == level then
                    permissionBypass = true
                    break
                end
            end
        elseif Framework == "QBCore" then
            for _, level in ipairs(Config.BypassSystem.BypassPermissionLevels.QBCore) do
                if playerDetails.permissions.group == level then
                    permissionBypass = true
                    break
                end
            end
        end
    end
    
    -- Bypass durch ACE-Berechtigungen
    local aceBypass = false
    if playerDetails.permissions.ace and #playerDetails.permissions.ace > 0 then
        aceBypass = true
    end
    
    -- Temporärer Bypass (falls aktiviert)
    local tempBypass = false
    if Config.BypassSystem.TemporaryBypass.Enabled and Players[source] and Players[source].tempBypass then
        if os.time() < Players[source].tempBypass.expiry then
            tempBypass = true
        else
            Players[source].tempBypass = nil
        end
    end
    
    -- Prüfen, ob alle oder nur ein Kriterium erfüllt sein müssen
    if Config.BypassSystem.RequireAllChecks then
        return identifierBypass or jobBypass or permissionBypass or aceBypass or tempBypass
    else
        return identifierBypass and jobBypass and permissionBypass and aceBypass or tempBypass
    end
end

local function GetPlayerWarnings(source)
    if not Players[source] then
        Players[source] = {
            warnings = 0,
            detections = {},
            lastDetection = 0
        }
    end
    
    return Players[source].warnings or 0
end

local function AddPlayerWarning(source, reason)
    if not Players[source] then
        Players[source] = {
            warnings = 0,
            detections = {},
            lastDetection = 0
        }
    end
    
    Players[source].warnings = (Players[source].warnings or 0) + 1
    
    -- Benachrichtige den Spieler
    TriggerClientEvent("chat:addMessage", source, {
        color = {255, 0, 0},
        multiline = true,
        args = {"AntiCheat", "Warnung: " .. reason}
    })
    
    -- Log die Warnung
    if Config.Discord.Enabled and Config.Discord.LogDetections then
        SendDiscordLog("WARNING", source, reason)
    end
    
    -- Prüfe auf Ban
    if Players[source].warnings >= Config.BanSystem.MaxWarnings then
        BanPlayer(source, reason)
    end
end

local function RegisterDetection(source, type, details)
    if not Players[source] then
        Players[source] = {
            warnings = 0,
            detections = {},
            lastDetection = 0
        }
    end
    
    local currentTime = os.time()
    
    -- Füge Erkennung hinzu
    Players[source].detections[type] = Players[source].detections[type] or {}
    table.insert(Players[source].detections[type], {
        time = currentTime,
        details = details
    })
    
    Players[source].lastDetection = currentTime
    
    -- Prüfe auf mehrfache Erkennungen
    if Config.FalsePositiveProtection.RequireMultipleDetections then
        local count = 0
        local timeWindow = currentTime - Config.FalsePositiveProtection.DetectionTimeWindow
        
        for _, detections in pairs(Players[source].detections) do
            for _, detection in ipairs(detections) do
                if detection.time >= timeWindow then
                    count = count + 1
                end
            end
        end
        
        if count >= Config.FalsePositiveProtection.DetectionThreshold then
            return true -- Mehrfacherkennung bestätigt
        else
            return false -- Noch nicht genug Erkennungen
        end
    else
        return true -- Mehrfacherkennung nicht erforderlich
    end
end

local function GetBanDuration(source)
    if not Config.BanSystem.AdvancedBanFeatures.Enabled or not Config.BanSystem.AdvancedBanFeatures.ProgressiveBans.Enabled then
        return Config.BanSystem.DefaultBanTime
    end
    
    -- Prüfe auf vorherige Bans
    local identifiers = GetPlayerIdentifiers(source)
    local banCount = 0
    
    for _, player in pairs(BannedPlayers) do
        for _, identifier in pairs(identifiers) do
            for _, bannedIdentifier in pairs(player.identifiers) do
                if identifier == bannedIdentifier then
                    banCount = banCount + 1
                    break
                end
            end
        end
    end
    
    -- Wähle Ban-Dauer basierend auf vorherigen Bans
    if banCount == 0 then
        return Config.BanSystem.AdvancedBanFeatures.ProgressiveBans.FirstBanDuration
    elseif banCount == 1 then
        return Config.BanSystem.AdvancedBanFeatures.ProgressiveBans.SecondBanDuration
    elseif banCount == 2 then
        return Config.BanSystem.AdvancedBanFeatures.ProgressiveBans.ThirdBanDuration
    else
        return Config.BanSystem.AdvancedBanFeatures.ProgressiveBans.FinalBanDuration
    end
end

local function BanPlayer(source, reason)
    if not Config.BanSystem.Enabled then return end
    
    local playerDetails = GetPlayerDetails(source)
    local duration = GetBanDuration(source)
    local banMessage = string.format(Config.BanSystem.BanMessage, reason)
    
    -- Füge Appeal-URL hinzu, wenn konfiguriert
    if Config.BanSystem.AdvancedBanFeatures.Enabled and 
       Config.BanSystem.AdvancedBanFeatures.BanAppeal.Enabled and 
       Config.BanSystem.AdvancedBanFeatures.BanAppeal.IncludeAppealURLInBanMessage then
        banMessage = banMessage .. "\nAppeal URL: " .. Config.BanSystem.AdvancedBanFeatures.BanAppeal.AppealURL
    end
    
    -- Speichere Ban-Daten
    local banData = {
        name = playerDetails.name,
        identifiers = playerDetails.identifiers,
        reason = reason,
        admin = "AntiCheat System",
        banTime = os.time(),
        expiry = duration > 0 and (os.time() + duration) or 0, -- 0 = permanent
        hwid = {}, -- HWID kommt vom Client, wird später hinzugefügt
    }
    
    table.insert(BannedPlayers, banData)
    
    -- Log den Ban
    if Config.Discord.Enabled then
        SendDiscordLog("BAN", source, reason)
    end
    
    -- Kicke den Spieler mit Ban-Nachricht
    DropPlayer(source, banMessage)
end

local function SendDiscordLog(type, source, reason)
    if not Config.Discord.Enabled then return end
    
    local playerDetails = GetPlayerDetails(source)
    local webhookURL = Config.Discord.WebhookURL
    
    -- Wähle entsprechende Webhook-URL basierend auf Event-Typ
    if Config.Discord.AdvancedDiscordFeatures.Enabled then
        if type == "BAN" and Config.Discord.AdvancedDiscordFeatures.Webhooks.Bans ~= "" then
            webhookURL = Config.Discord.AdvancedDiscordFeatures.Webhooks.Bans
        elseif type == "WARNING" and Config.Discord.AdvancedDiscordFeatures.Webhooks.Warnings ~= "" then
            webhookURL = Config.Discord.AdvancedDiscordFeatures.Webhooks.Warnings
        elseif type == "DETECTION" and Config.Discord.AdvancedDiscordFeatures.Webhooks.Detections ~= "" then
            webhookURL = Config.Discord.AdvancedDiscordFeatures.Webhooks.Detections
        elseif type == "BYPASS" and Config.Discord.AdvancedDiscordFeatures.Webhooks.Bypasses ~= "" then
            webhookURL = Config.Discord.AdvancedDiscordFeatures.Webhooks.Bypasses
        end
    end
    
    -- Wenn keine URL konfiguriert ist, breche ab
    if webhookURL == "" then return end
    
    -- Bestimme Farbe basierend auf Typ
    local color
    if type == "BAN" then
        color = 16711680 -- Rot
    elseif type == "WARNING" then
        color = 16761095 -- Orange
    elseif type == "DETECTION" then
        color = 16776960 -- Gelb
    elseif type == "BYPASS" then
        color = 65280 -- Grün
    else
        color = 65535 -- Cyan (Standard)
    end
    
    -- Erstelle Embed-Felder
    local fields = {
        {
            name = "Spieler",
            value = playerDetails.name,
            inline = true
        },
        {
            name = "ID",
            value = source,
            inline = true
        },
        {
            name = "Typ",
            value = type,
            inline = true
        }
    }
    
    -- Füge weitere Felder hinzu
    if reason then
        table.insert(fields, {
            name = "Grund",
            value = reason,
            inline = false
        })
    end
    
    -- Füge Identifiers hinzu
    local identifiersText = ""
    for identType, ident in pairs(playerDetails.identifiers) do
        identifiersText = identifiersText .. identType .. ": " .. ident .. "\n"
    end
    
    if identifiersText ~= "" then
        table.insert(fields, {
            name = "Identifiers",
            value = "```\n" .. identifiersText .. "```",
            inline = false
        })
    end
    
    -- Erstelle Discord-Embed
    local embed = {
        {
            ["color"] = color,
            ["title"] = Config.AntiCheatName .. " - " .. type,
            ["description"] = "Eine neue " .. type .. "-Meldung wurde registriert.",
            ["fields"] = fields,
            ["footer"] = {
                ["text"] = "Anticheat System • " .. os.date("%d.%m.%Y %H:%M:%S")
            }
        }
    }
    
    -- Sende Webhook
    PerformHttpRequest(webhookURL, function(err, text, headers) end, "POST", json.encode({
        username = Config.Discord.BotName,
        embeds = embed,
        avatar_url = Config.Discord.BotAvatar
    }), { ["Content-Type"] = "application/json" })
end

-- Event-Handlers
-- Spieler verbindet sich
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local source = source
    local identifiers = GetPlayerIdentifiers(source)
    
    deferrals.defer()
    deferrals.update("Überprüfe Anticheat-Status...")
    
    -- Prüfe, ob der Spieler gebannt ist
    for _, ban in ipairs(BannedPlayers) do
        for _, playerIdentifier in ipairs(identifiers) do
            for _, bannedIdentifier in pairs(ban.identifiers) do
                if playerIdentifier == bannedIdentifier then
                    -- Ban gefunden, prüfe ob abgelaufen
                    if ban.expiry == 0 or os.time() < ban.expiry then
                        -- Ban aktiv
                        local remainingTime = ""
                        if ban.expiry > 0 then
                            local remaining = ban.expiry - os.time()
                            local days = math.floor(remaining / 86400)
                            local hours = math.floor((remaining % 86400) / 3600)
                            remainingTime = string.format(" (Verbleibend: %d Tage, %d Stunden)", days, hours)
                        else
                            remainingTime = " (Permanent)"
                        end
                        
                        local banMessage = string.format(Config.BanSystem.BanMessage, ban.reason) .. remainingTime
                        
                        -- Füge Appeal-URL hinzu, wenn konfiguriert
                        if Config.BanSystem.AdvancedBanFeatures.Enabled and 
                           Config.BanSystem.AdvancedBanFeatures.BanAppeal.Enabled and 
                           Config.BanSystem.AdvancedBanFeatures.BanAppeal.IncludeAppealURLInBanMessage then
                            banMessage = banMessage .. "\nAppeal URL: " .. Config.BanSystem.AdvancedBanFeatures.BanAppeal.AppealURL
                        end
                        
                        deferrals.done(banMessage)
                        return
                    else
                        -- Ban abgelaufen, entferne ihn
                        table.remove(BannedPlayers, i)
                    end
                end
            end
        end
    end
    
    -- VPN-Erkennung, falls konfiguriert
    if Config.BanSystem.AdvancedBanFeatures.Enabled and 
       Config.BanSystem.AdvancedBanFeatures.BanEvasionProtection.Enabled and
       Config.BanSystem.AdvancedBanFeatures.BanEvasionProtection.DetectVPNs then
        for _, playerIdentifier in ipairs(identifiers) do
            if string.match(playerIdentifier, "ip:") then
                local ip = string.gsub(playerIdentifier, "ip:", "")
                -- Hier könnte ein VPN-Check implementiert werden (API-Anfrage)
                -- Für eine tatsächliche Implementierung wäre eine externe API erforderlich
            end
        end
    end
    
    deferrals.done()
end)

-- Spieler verbunden
AddEventHandler("playerJoining", function(oldID)
    local source = source
    if source <= 0 then return end
    
    Players[source] = {
        warnings = 0,
        detections = {},
        lastDetection = 0,
        joinTime = os.time(),
        lastCheck = os.time()
    }
    
    if Config.Debug then
        print("[AntiCheat] Spieler verbunden: " .. GetPlayerName(source) .. " (ID: " .. source .. ")")
    end
end)

-- Spieler getrennt
AddEventHandler("playerDropped", function(reason)
    local source = source
    if source <= 0 then return end
    
    Players[source] = nil
    
    if Config.Debug then
        print("[AntiCheat] Spieler getrennt: " .. GetPlayerName(source) .. " (ID: " .. source .. ")")
    end
end)

-- Ressourcenprüfung
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000) -- Überprüfe alle 10 Sekunden
        
        -- Aktualisiere Server-Performance-Daten
        local serverPerformance = {
            cpu = 0, -- In einer echten Implementierung: tatsächliche CPU-Auslastung
            memory = 0, -- In einer echten Implementierung: tatsächliche RAM-Auslastung
            players = #GetPlayers()
        }
        
        -- Hohe Serverlast erkennen
        local highLoad = false
        if Config.FalsePositiveProtection.Enabled and 
           Config.FalsePositiveProtection.ServerLoadProtection.Enabled and
           serverPerformance.cpu >= Config.FalsePositiveProtection.ServerLoadProtection.HighLoadThreshold then
            highLoad = true
        end
        
        TriggerClientEvent("anticheat:syncData", -1, {
            highLoad = highLoad
        })
    end
end)

-- Client-Event-Handler für Erkennungen
RegisterNetEvent("anticheat:detection")
AddEventHandler("anticheat:detection", function(type, details)
    local source = source
    if source <= 0 then return end
    
    -- Ignoriere, wenn Bypass aktiv ist
    if IsPlayerBypassed(source) then
        if Config.Debug then
            print("[AntiCheat] Erkennung ignoriert (Bypass aktiv): " .. GetPlayerName(source) .. " - " .. type)
        end
        return
    end
    
    -- Grace-Periode nach Verbindung
    if os.time() - (Players[source] and Players[source].joinTime or 0) < Config.FalsePositiveProtection.ConnectGracePeriod then
        if Config.Debug then
            print("[AntiCheat] Erkennung ignoriert (Grace-Periode): " .. GetPlayerName(source) .. " - " .. type)
        end
        return
    end
    
    -- Registriere Erkennung und prüfe auf Mehrfacherkennung
    local confirmed = RegisterDetection(source, type, details)
    
    if confirmed then
        -- Log zur Konsole
        print("[AntiCheat] Erkennung: " .. GetPlayerName(source) .. " - " .. type .. " - Details: " .. (details or "keine"))
        
        -- Log zu Discord
        if Config.Discord.Enabled and Config.Discord.LogDetections then
            SendDiscordLog("DETECTION", source, type .. ": " .. (details or "keine Details"))
        end
        
        -- Prüfe auf Instaban
        local instaBan = false
        
        if type == "resource" and Config.ResourceDetection.InstaBan then
            instaBan = true
        elseif type == "menu" and Config.MenuDetection.InstaBan then
            instaBan = true
        elseif type == "weapon" and Config.WeaponDetection.InstaBan then
            instaBan = true
        elseif type == "vehicle" and Config.VehicleDetection.InstaBan then
            instaBan = true
        elseif type == "object" and Config.ObjectDetection.InstaBan then
            instaBan = true
        elseif type == "explosion" and Config.ExplosionDetection.InstaBan then
            instaBan = true
        elseif type == "godmode" and Config.AntiGodmode.InstaBan then
            instaBan = true
        elseif type == "spectate" and Config.AntiSpectate.InstaBan then
            instaBan = true
        elseif type == "speedhack" and Config.AntiSpeedhack.InstaBan then
            instaBan = true
        elseif type == "noclip" and Config.AntiNoclip.InstaBan then
            instaBan = true
        end
        
        -- Deaktiviere Instaban bei hoher Serverlast, wenn konfiguriert
        if instaBan and Config.FalsePositiveProtection.Enabled and 
           Config.FalsePositiveProtection.ServerLoadProtection.Enabled and
           Config.FalsePositiveProtection.ServerLoadProtection.DisableInstaBanOnHighLoad then
            
            local serverPerformance = {
                cpu = 0, -- In einer echten Implementierung: tatsächliche CPU-Auslastung
                memory = 0, -- In einer echten Implementierung: tatsächliche RAM-Auslastung
                players = #GetPlayers()
            }
            
            if serverPerformance.cpu >= Config.FalsePositiveProtection.ServerLoadProtection.HighLoadThreshold then
                instaBan = false
                if Config.Debug then
                    print("[AntiCheat] Instaban deaktiviert aufgrund hoher Serverlast")
                end
            end
        end
        
        if instaBan then
            BanPlayer(source, "AntiCheat: " .. type .. " erkannt - " .. (details or "keine Details"))
        else
            AddPlayerWarning(source, "AntiCheat: " .. type .. " erkannt - " .. (details or "keine Details"))
        end
    else
        if Config.Debug then
            print("[AntiCheat] Verdächtige Aktivität registriert (benötigt mehr Erkennungen): " .. GetPlayerName(source) .. " - " .. type)
        end
    end
end)

-- Resourcenstart
AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Lade gespeicherte Bans (für eine echte Implementierung)
        -- In einer tatsächlichen Implementierung würden Bans in einer Datenbank gespeichert
        BannedPlayers = {}
        
        print("[AntiCheat] System gestartet. Version: 1.0.0")
    end
end)

-- Explosions-Event
AddEventHandler("explosionEvent", function(source, ev)
    -- Ignoriere, wenn Bypass aktiv ist
    if IsPlayerBypassed(source) then return end
    
    -- Prüfe, ob Explosion erlaubt ist
    local allowed = Config.ExplosionDetection.AllowedExplosions[ev.explosionType] or false
    
    -- Prüfe job-spezifische Erlaubnis
    local playerJob = GetPlayerJob(source)
    if not allowed and playerJob and Config.ExplosionDetection.JobExplosions[playerJob] then
        allowed = Config.ExplosionDetection.JobExplosions[playerJob][ev.explosionType] or false
    end
    
    -- Wenn die Explosion nicht erlaubt ist
    if not allowed then
        -- Blockiere Explosion, wenn konfiguriert
        if Config.ExplosionDetection.BlockExplosion then
            CancelEvent()
        end
        
        -- Erkenne und behandle
        local details = "Typ: " .. ev.explosionType .. ", Position: " .. ev.posX .. "," .. ev.posY .. "," .. ev.posZ
        TriggerEvent("anticheat:detection", source, "explosion", details)
    end
end)

-- Chat-Befehl für temporären Bypass
RegisterCommand("ac_bypass", function(source, args, rawCommand)
    if source <= 0 then
        -- Konsolen-Befehl
        if #args >= 2 then
            local targetId = tonumber(args[1])
            local password = args[2]
            
            if targetId and GetPlayerName(targetId) then
                if Config.BypassSystem.TemporaryBypass.Enabled and password == Config.BypassSystem.TemporaryBypass.Password then
                    Players[targetId] = Players[targetId] or {}
                    Players[targetId].tempBypass = {
                        granted = os.time(),
                        expiry = os.time() + Config.BypassSystem.TemporaryBypass.Duration
                    }
                    
                    print("[AntiCheat] Temporärer Bypass gewährt für: " .. GetPlayerName(targetId) .. " (ID: " .. targetId .. ")")
                    TriggerClientEvent("chat:addMessage", targetId, {
                        color = {0, 255, 0},
                        multiline = true,
                        args = {"AntiCheat", "Temporärer Bypass gewährt für " .. Config.BypassSystem.TemporaryBypass.Duration .. " Sekunden."}
                    })
                    
                    -- Log zu Discord
                    if Config.Discord.Enabled then
                        SendDiscordLog("BYPASS", targetId, "Temporärer Bypass gewährt für " .. Config.BypassSystem.TemporaryBypass.Duration .. " Sekunden.")
                    end
                else
                    print("[AntiCheat] Ungültiges Passwort für temporären Bypass.")
                end
            else
                print("[AntiCheat] Ungültige Spieler-ID.")
            end
        else
            print("[AntiCheat] Verwendung: ac_bypass [spieler_id] [passwort]")
        end
    else
        -- Spieler-Befehl
        if IsPlayerBypassed(source) and #args >= 1 then
            local targetId = tonumber(args[1])
            
            if targetId and GetPlayerName(targetId) then
                if Config.BypassSystem.TemporaryBypass.Enabled then
                    Players[targetId] = Players[targetId] or {}
                    Players[targetId].tempBypass = {
                        granted = os.time(),
                        expiry = os.time() + Config.BypassSystem.TemporaryBypass.Duration
                    }
                    
                    TriggerClientEvent("chat:addMessage", source, {
                        color = {0, 255, 0},
                        multiline = true,
                        args = {"AntiCheat", "Temporärer Bypass gewährt für " .. GetPlayerName(targetId) .. " für " .. Config.BypassSystem.TemporaryBypass.Duration .. " Sekunden."}
                    })
                    
                    TriggerClientEvent("chat:addMessage", targetId, {
                        color = {0, 255, 0},
                        multiline = true,
                        args = {"AntiCheat", "Temporärer Bypass gewährt für " .. Config.BypassSystem.TemporaryBypass.Duration .. " Sekunden."}
                    })
                    
                    -- Log zu Discord
                    if Config.Discord.Enabled then
                        SendDiscordLog("BYPASS", targetId, "Temporärer Bypass gewährt durch " .. GetPlayerName(source) .. " für " .. Config.BypassSystem.TemporaryBypass.Duration .. " Sekunden.")
                    end
                end
            else
                TriggerClientEvent("chat:addMessage", source, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"AntiCheat", "Ungültige Spieler-ID."}
                })
            end
        else
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"AntiCheat", "Du hast keine Berechtigung oder die Syntax ist falsch. Verwendung: /ac_bypass [spieler_id]"}
            })
        end
    end
end, true)

-- Exports
exports("IsPlayerBypassed", IsPlayerBypassed)
exports("BanPlayer", BanPlayer)
exports("AddPlayerWarning", AddPlayerWarning)
exports("GetPlayerWarnings", GetPlayerWarnings)