--[[
    Advanced AntiCheat System - Client Side
    Kompatibel mit ESX und QBCore Framework
]]

local Framework = nil
local ESX, QBCore = nil, nil
local PlayerData = {}
local ServerData = {
    highLoad = false
}

local isSpawned = false
local bypassActive = false
local checkTimers = {}

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
    
    -- Initialisiere Spielerdaten
    RefreshPlayerData()
    
    -- Event-Handler für Framework-spezifische Events
    if Framework == "ESX" then
        RegisterNetEvent("esx:playerLoaded")
        AddEventHandler("esx:playerLoaded", function(xPlayer)
            PlayerData = xPlayer
            isSpawned = true
        end)
        
        RegisterNetEvent("esx:setJob")
        AddEventHandler("esx:setJob", function(job)
            PlayerData.job = job
        end)
    elseif Framework == "QBCore" then
        RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
        AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
            PlayerData = QBCore.Functions.GetPlayerData()
            isSpawned = true
        end)
        
        RegisterNetEvent("QBCore:Client:OnJobUpdate")
        AddEventHandler("QBCore:Client:OnJobUpdate", function(job)
            PlayerData.job = job
        end)
    end
end)

-- Server-Daten-Synchronisation
RegisterNetEvent("anticheat:syncData")
AddEventHandler("anticheat:syncData", function(data)
    ServerData = data
end)

-- Überprüfe, ob Bypass aktiv ist
local function HasBypass()
    return bypassActive
end

-- Aktualisiere Spielerdaten
function RefreshPlayerData()
    if Framework == "ESX" and ESX then
        ESX.TriggerServerCallback("esx:getPlayerData", function(data)
            PlayerData = data
        end)
    elseif Framework == "QBCore" and QBCore then
        PlayerData = QBCore.Functions.GetPlayerData()
    end
end

-- Funktion zum Senden von Erkennungen an den Server
local function SendDetection(type, details)
    -- Prüfe, ob der Check deaktiviert werden soll bei hoher Serverlast
    if ServerData.highLoad and Config.FalsePositiveProtection.Enabled and 
       Config.FalsePositiveProtection.ServerLoadProtection.Enabled and
       Config.FalsePositiveProtection.ServerLoadProtection.ReduceChecksOnHighLoad then
        if Config.Debug then
            print("[AntiCheat] Check übersprungen wegen hoher Serverlast: " .. type)
        end
        return
    end
    
    -- Sende Erkennung an Server
    TriggerServerEvent("anticheat:detection", type, details)
end

-- Check-Timer-Funktionen
local function StartCheckTimer(check, interval, func)
    if checkTimers[check] then
        return -- Timer läuft bereits
    end
    
    checkTimers[check] = {
        interval = interval,
        lastRun = GetGameTimer(),
        func = func
    }
end

local function StopCheckTimer(check)
    checkTimers[check] = nil
end

local function ProcessCheckTimers()
    local currentTime = GetGameTimer()
    
    for check, data in pairs(checkTimers) do
        if currentTime - data.lastRun >= data.interval then
            data.func()
            data.lastRun = currentTime
        end
    end
end

-- Check-Funktionen
local function CheckBlacklistedResources()
    if not Config.ResourceDetection.Enabled then return end
    
    for _, resourceName in ipairs(Config.ResourceDetection.BlacklistedResources) do
        if GetResourceState(resourceName) == "started" then
            SendDetection("resource", "Verbotene Ressource erkannt: " .. resourceName)
        end
    end
    
    -- Dynamische Ressourcenerkennung
    if Config.ResourceDetection.AdvancedResourceChecking.Enabled and
       Config.ResourceDetection.AdvancedResourceChecking.DynamicDetection.Enabled then
        
        local allResources = GetNumResources()
        for i = 0, allResources - 1 do
            local resourceName = GetResourceByFindIndex(i)
            
            -- Prüfe auf verdächtige Muster
            for _, pattern in ipairs(Config.ResourceDetection.AdvancedResourceChecking.DynamicDetection.SuspiciousPatterns) do
                if string.find(string.lower(resourceName), string.lower(pattern)) then
                    -- Prüfe Ausnahmen
                    local isExcluded = false
                    for _, excludePattern in ipairs(Config.ResourceDetection.AdvancedResourceChecking.DynamicDetection.ExcludePatterns) do
                        if string.find(string.lower(resourceName), string.lower(excludePattern)) then
                            isExcluded = true
                            break
                        end
                    end
                    
                    if not isExcluded then
                        SendDetection("resource", "Verdächtige Ressource erkannt: " .. resourceName)
                    end
                end
            end
        end
    end
end

local function CheckBlacklistedMenus()
    if not Config.MenuDetection.Enabled then return end
    
    for _, menuName in ipairs(Config.MenuDetection.Menus) do
        -- Grundlegende Menü-Erkennung durch globale Variablen
        if _G[menuName] ~= nil then
            SendDetection("menu", "Verbotenes Menü erkannt: " .. menuName)
        end
    end
    
    -- Erweiterte Menü-Erkennung
    if Config.MenuDetection.AdvancedMenuDetection.Enabled then
        -- Verhaltensbasierte Erkennung (vereinfacht)
        if Config.MenuDetection.AdvancedMenuDetection.BehavioralDetection.Enabled then
            -- Beispiel: Prüfe auf unnatürliche Kamera-Manipulation
            local camRot = GetGameplayCamRot(0)
            if math.abs(camRot.x) > 85.0 then -- Unnormal hoher oder niedriger Kamerawinkel
                SendDetection("menu", "Verdächtige Kamera-Manipulation")
            end
        end
        
        -- Hier könnten weitere fortgeschrittene Prüfungen implementiert werden
    end
end

local function CheckBlacklistedWeapons()
    if not Config.WeaponDetection.Enabled then return end
    
    local playerPed = PlayerPedId()
    
    -- Spieler-Waffen prüfen
    for _, weaponName in ipairs(Config.WeaponDetection.BlacklistedWeapons) do
        if HasPedGotWeapon(playerPed, GetHashKey(weaponName), false) then
            local allowed = false
            
            -- Prüfe job-spezifische Erlaubnis
            if PlayerData.job and Config.WeaponDetection.JobWeapons[PlayerData.job.name] then
                for _, allowedWeapon in ipairs(Config.WeaponDetection.JobWeapons[PlayerData.job.name]) do
                    if weaponName == allowedWeapon then
                        allowed = true
                        break
                    end
                end
            end
            
            if not allowed then
                if Config.WeaponDetection.RemoveWeapon then
                    RemoveWeaponFromPed(playerPed, GetHashKey(weaponName))
                    
                    if Config.WeaponDetection.NotifyPlayer then
                        Notify("Verbotene Waffe entfernt: " .. weaponName)
                    end
                end
                
                SendDetection("weapon", "Verbotene Waffe erkannt: " .. weaponName)
            end
        end
    end
    
    -- Ped-Waffen prüfen, falls konfiguriert
    if Config.WeaponDetection.CheckPeds then
        local peds = GetGamePool("CPed")
        for _, ped in ipairs(peds) do
            if ped ~= playerPed and not IsPedAPlayer(ped) and DoesEntityExist(ped) then
                for _, weaponName in ipairs(Config.WeaponDetection.BlacklistedWeapons) do
                    if HasPedGotWeapon(ped, GetHashKey(weaponName), false) then
                        if Config.WeaponDetection.RemoveWeapon then
                            RemoveWeaponFromPed(ped, GetHashKey(weaponName))
                        end
                        
                        SendDetection("weapon", "Verbotene Waffe bei Ped erkannt: " .. weaponName)
                    end
                end
            end
        end
    end
    
    -- Erweiterte Waffenerkennung
    if Config.WeaponDetection.AdvancedWeaponDetection.Enabled then
        -- Prüfe Munitionsmenge
        if Config.WeaponDetection.AdvancedWeaponDetection.CheckAmmunitionAmounts then
            local playerWeapons = {}
            for i = 1, #Config.WeaponDetection.BlacklistedWeapons do
                local weaponHash = GetHashKey(Config.WeaponDetection.BlacklistedWeapons[i])
                if HasPedGotWeapon(playerPed, weaponHash, false) then
                    table.insert(playerWeapons, {
                        name = Config.WeaponDetection.BlacklistedWeapons[i],
                        hash = weaponHash,
                        ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
                    })
                end
            end
            
            -- Überprüfe jede Waffe auf übermäßige Munition
            for _, weapon in ipairs(playerWeapons) do
                -- In einer vollständigen Implementierung: Vergleiche mit maximaler erwarteter Munition
                -- Vereinfacht: Feste Grenze, z.B. 1000 Schuss
                if weapon.ammo > 1000 then
                    SendDetection("weapon", "Übermäßige Munitionsmenge erkannt: " .. weapon.name .. " (" .. weapon.ammo .. " Schuss)")
                end
            end
        end
    end
end

local function CheckBlacklistedVehicles()
    if not Config.VehicleDetection.Enabled then return end
    
    local playerPed = PlayerPedId()
    
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        
        if DoesEntityExist(vehicle) then
            local vehicleModel = GetEntityModel(vehicle)
            
            for _, vehicleName in ipairs(Config.VehicleDetection.BlacklistedVehicles) do
                if vehicleModel == GetHashKey(vehicleName) then
                    local allowed = false
                    
                    -- Prüfe job-spezifische Erlaubnis
                    if PlayerData.job and Config.VehicleDetection.JobVehicles[PlayerData.job.name] then
                        for _, allowedVehicle in ipairs(Config.VehicleDetection.JobVehicles[PlayerData.job.name]) do
                            if vehicleName == allowedVehicle then
                                allowed = true
                                break
                            end
                        end
                    end
                    
                    if not allowed then
                        if Config.VehicleDetection.DeleteVehicle then
                            DeleteEntity(vehicle)
                            
                            if Config.VehicleDetection.NotifyPlayer then
                                Notify("Verbotenes Fahrzeug entfernt: " .. vehicleName)
                            end
                        end
                        
                        SendDetection("vehicle", "Verbotenes Fahrzeug erkannt: " .. vehicleName)
                    end
                end
            end
            
            -- Erweiterte Fahrzeugerkennung
            if Config.VehicleDetection.AdvancedVehicleDetection.Enabled then
                -- Überprüfe Fahrzeug-Modifikationen
                if Config.VehicleDetection.AdvancedVehicleDetection.CheckVehicleMods.Enabled then
                    -- Überprüfe auf ungültige Mods
                    if Config.VehicleDetection.AdvancedVehicleDetection.CheckVehicleMods.CheckInvalidMods then
                        for i = 0, 49 do -- Alle standardmäßigen Mod-Slots
                            local modCount = GetNumVehicleMods(vehicle, i)
                            local currentMod = GetVehicleMod(vehicle, i)
                            
                            -- Erkennung von ungültigen Mods (außerhalb der gültigen Grenzen)
                            if currentMod > modCount and modCount > 0 then
                                SendDetection("vehicle", "Ungültige Fahrzeugmodifikation erkannt: Slot " .. i .. ", Mod " .. currentMod .. " (max: " .. modCount .. ")")
                            end
                        end
                    end
                end
                
                -- Überprüfe Fahrzeug-Performance
                if Config.VehicleDetection.AdvancedVehicleDetection.CheckVehiclePerformance.Enabled then
                    local maxSpeed = GetVehicleEstimatedMaxSpeed(vehicle)
                    local modelMaxSpeed = GetVehicleModelEstimatedMaxSpeed(vehicleModel)
                    
                    -- Erkennung von übermäßiger Geschwindigkeit
                    if maxSpeed > modelMaxSpeed * Config.VehicleDetection.AdvancedVehicleDetection.CheckVehiclePerformance.MaxSpeedMultiplier then
                        SendDetection("vehicle", "Übermäßige Fahrzeuggeschwindigkeit erkannt: " .. maxSpeed .. " (normal: " .. modelMaxSpeed .. ")")
                    end
                end
            end
        end
    end
end

local function CheckBlacklistedObjects()
    if not Config.ObjectDetection.Enabled then return end
    
    local playerPed = PlayerPedId()
    local objects = GetGamePool("CObject")
    local playerObjects = 0
    
    for _, object in ipairs(objects) do
        if DoesEntityExist(object) then
            local objectModel = GetEntityModel(object)
            
            -- Prüfe, ob Objekt zum Spieler gehört
            if NetworkGetEntityOwner(object) == PlayerId() then
                playerObjects = playerObjects + 1
                
                -- Überprüfe maximale Anzahl von Objekten pro Spieler
                if playerObjects > Config.ObjectDetection.MaxObjectsPerPlayer then
                    if Config.ObjectDetection.DeleteObject then
                        DeleteEntity(object)
                    end
                    
                    SendDetection("object", "Zu viele Objekte gespawnt: " .. playerObjects)
                    break
                end
            end
            
            -- Überprüfe auf verbotene Objekte
            for _, blacklistedObject in ipairs(Config.ObjectDetection.BlacklistedObjects) do
                if objectModel == GetHashKey(blacklistedObject) then
                    if Config.ObjectDetection.DeleteObject then
                        DeleteEntity(object)
                        
                        if Config.ObjectDetection.NotifyPlayer then
                            Notify("Verbotenes Objekt entfernt: " .. blacklistedObject)
                        end
                    end
                    
                    SendDetection("object", "Verbotenes Objekt erkannt: " .. blacklistedObject)
                end
            end
        end
    end
    
    -- Erweiterte Objekterkennung
    if Config.ObjectDetection.AdvancedObjectDetection.Enabled then
        -- Objekt-Anhaftungs-Erkennung
        if Config.ObjectDetection.AdvancedObjectDetection.ObjectAttachmentDetection.Enabled then
            -- Spieler-Anhaftungen überprüfen
            if Config.ObjectDetection.AdvancedObjectDetection.ObjectAttachmentDetection.CheckPlayerAttachments then
                for _, object in ipairs(objects) do
                    if DoesEntityExist(object) and IsEntityAttachedToEntity(object, playerPed) then
                        local objectModel = GetEntityModel(object)
                        -- Hier könnte eine Liste erlaubter Anhaftungen geprüft werden
                        -- Vereinfacht: Alle Anhaftungen melden
                        SendDetection("object", "Objekt am Spieler befestigt: " .. objectModel)
                    end
                end
            end
        end
    end
end

local function CheckGodmode()
    if not Config.AntiGodmode.Enabled then return end
    
    local playerPed = PlayerPedId()
    
    -- Ignoriere tote Spieler
    if Config.AntiGodmode.IgnoreDead and IsEntityDead(playerPed) then
        return
    end
    
    -- Grundlegende Godmode-Erkennung
    if GetPlayerInvincible(PlayerId()) then
        SendDetection("godmode", "Unverwundbarkeit erkannt")
    end
    
    -- Gesundheits-Check
    local health = GetEntityHealth(playerPed)
    if health > Config.AntiGodmode.MaxHealth then
        SendDetection("godmode", "Übermäßige Gesundheit erkannt: " .. health)
    end
    
    -- Rüstungs-Check
    local armor = GetPedArmour(playerPed)
    if armor > Config.AntiGodmode.MaxArmor then
        SendDetection("godmode", "Übermäßige Rüstung erkannt: " .. armor)
    end
    
    -- Erweiterte Godmode-Erkennung
    if Config.AntiGodmode.AdvancedGodmodeDetection.Enabled then
        -- Gesundheits-Regenerations-Erkennung
        if Config.AntiGodmode.AdvancedGodmodeDetection.HealthRegenerationDetection.Enabled then
            -- Diese Überprüfung erfordert eine Statusverfolgung über Zeit
            -- In einer vollständigen Implementierung: Vergleiche Gesundheitswerte über mehrere Frames
        end
        
        -- Schadensresistenz-Erkennung (vereinfacht)
        if Config.AntiGodmode.AdvancedGodmodeDetection.DamageResistanceDetection.Enabled and
           Config.AntiGodmode.AdvancedGodmodeDetection.DamageResistanceDetection.TestDamageApplications then
            
            -- In einer vollständigen Implementierung: Führe tatsächliche Schadensprüfungen durch
            -- Hinweis: Dies kann Spielereinfluss haben und sollte mit Vorsicht implementiert werden
        end
    end
end

local function CheckSpectate()
    if not Config.AntiSpectate.Enabled then return end
    
    -- Prüfe, ob Spieler im Spectator-Modus ist
    if NetworkIsInSpectatorMode() then
        local allowed = false
        
        -- Prüfe job-spezifische Erlaubnis
        if PlayerData.job then
            for _, allowedJob in ipairs(Config.AntiSpectate.AllowedJobs) do
                if PlayerData.job.name == allowedJob then
                    allowed = true
                    break
                end
            end
        end
        
        if not allowed then
            if Config.AntiSpectate.NotifyPlayer then
                Notify("Unerlaubter Spectator-Modus erkannt!")
            end
            
            SendDetection("spectate", "Spectator-Modus erkannt")
        end
    end
    
    -- Erweiterte Spectate-Erkennung
    if Config.AntiSpectate.AdvancedSpectateDetection.Enabled then
        -- In einer vollständigen Implementierung: Zusätzliche Prüfungen für versteckte Spectate-Modi
    end
end

local function CheckSpeedhack()
    if not Config.AntiSpeedhack.Enabled then return end
    
    local playerPed = PlayerPedId()
    
    -- Prüfe Spielergeschwindigkeit
    if not IsPedInAnyVehicle(playerPed, true) then
        local speed = GetEntitySpeed(playerPed)
        
        -- Prüfe verschiedene Bewegungszustände
        if IsPedWalking(playerPed) and speed > Config.AntiSpeedhack.MaxWalkSpeed then
            SendDetection("speedhack", "Übermäßige Gehgeschwindigkeit: " .. speed)
        elseif IsPedRunning(playerPed) and speed > Config.AntiSpeedhack.MaxRunSpeed then
            SendDetection("speedhack", "Übermäßige Laufgeschwindigkeit: " .. speed)
        elseif IsPedSwimming(playerPed) and speed > Config.AntiSpeedhack.MaxSwimSpeed then
            SendDetection("speedhack", "Übermäßige Schwimmgeschwindigkeit: " .. speed)
        end
    else
        -- Fahrzeuggeschwindigkeit prüfen
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        
        if DoesEntityExist(vehicle) then
            local vehicleModel = GetEntityModel(vehicle)
            local speed = GetEntitySpeed(vehicle)
            local maxSpeed = GetVehicleEstimatedMaxSpeed(vehicle)
            local modelMaxSpeed = GetVehicleModelEstimatedMaxSpeed(vehicleModel)
            
            -- Ignoriere bestimmte Fahrzeugmodelle
            local shouldIgnore = false
            for _, model in ipairs(Config.AntiSpeedhack.IgnoreModels) do
                if vehicleModel == GetHashKey(model) then
                    shouldIgnore = true
                    break
                end
            end
            
            if not shouldIgnore and speed > modelMaxSpeed * Config.AntiSpeedhack.MaxVehicleMultiplier then
                SendDetection("speedhack", "Übermäßige Fahrzeuggeschwindigkeit: " .. speed .. " (normal max: " .. modelMaxSpeed .. ")")
            end
        end
    end
    
    -- Erweiterte Speedhack-Erkennung
    if Config.AntiSpeedhack.AdvancedSpeedhackDetection.Enabled then
        -- Bewegungsanalyse
        if Config.AntiSpeedhack.AdvancedSpeedhackDetection.MovementAnalysis.Enabled then
            -- In einer vollständigen Implementierung: Analysiere Beschleunigung und Bewegungsmuster
        end
        
        -- Teleport-Erkennung
        if Config.AntiSpeedhack.AdvancedSpeedhackDetection.TeleportDetection.Enabled then
            -- Speichere letzte Position für Teleport-Prüfung
            if not lastPosition then
                lastPosition = GetEntityCoords(playerPed)
                lastPositionTime = GetGameTimer()
            else
                local currentPosition = GetEntityCoords(playerPed)
                local currentTime = GetGameTimer()
                local distance = #(currentPosition - lastPosition)
                local timeDiff = (currentTime - lastPositionTime) / 1000.0
                
                -- Ignoriere sehr kleine Zeitunterschiede
                if timeDiff > 0.1 then
                    local speed = distance / timeDiff
                    local maxAllowedDistance = Config.AntiSpeedhack.AdvancedSpeedhackDetection.TeleportDetection.MaxAllowedDistance
                    
                    -- Prüfe auf unnatürliche Positionsänderungen
                    if distance > maxAllowedDistance and not IsPedInAnyVehicle(playerPed, true) then
                        -- Prüfe ausgeschlossene Zonen
                        local isExcludedZone = false
                        for _, zone in ipairs(Config.AntiSpeedhack.AdvancedSpeedhackDetection.TeleportDetection.ExcludedZones) do
                            local zoneDist = #(currentPosition - vector3(zone.x, zone.y, zone.z))
                            if zoneDist <= zone.radius then
                                isExcludedZone = true
                                break
                            end
                        end
                        
                        if not isExcludedZone then
                            SendDetection("speedhack", "Möglicher Teleport erkannt: " .. distance .. " Meter in " .. timeDiff .. " Sekunden")
                        end
                    end
                end
                
                lastPosition = currentPosition
                lastPositionTime = currentTime
            end
        end
    end
end

local function CheckNoclip()
    if not Config.AntiNoclip.Enabled then return end
    
    local playerPed = PlayerPedId()
    
    -- Prüfe, ob Spieler berechtigt ist
    local allowed = false
    if PlayerData.job then
        for _, allowedJob in ipairs(Config.AntiNoclip.AllowedJobs) do
            if PlayerData.job.name == allowedJob then
                allowed = true
                break
            end
        end
    end
    
    if not allowed then
        -- Grundlegende Noclip-Erkennung
        local position = GetEntityCoords(playerPed)
        local isInAir = false
        
        -- Prüfe, ob Spieler in der Luft ist ohne zu fallen
        if not IsEntityInAir(playerPed) and not IsPedFalling(playerPed) and not IsPedInAnyVehicle(playerPed, true) then
            local groundFound, groundZ = GetGroundZFor_3dCoord(position.x, position.y, position.z, false)
            
            if not groundFound and position.z > 1.0 then
                isInAir = true
            end
        end
        
        -- Erweiterte Noclip-Erkennung
        if Config.AntiNoclip.AdvancedNoclipDetection.Enabled then
            -- Kollisionserkennung
            if Config.AntiNoclip.AdvancedNoclipDetection.CollisionDetection.Enabled then
                -- Prüfe, ob Entität Kollisionen hat
                if not IsEntityCollisionEnabled(playerPed) and not IsPedInAnyVehicle(playerPed, true) then
                    SendDetection("noclip", "Kollision deaktiviert")
                end
            end
            
            -- Weitere erweiterte Prüfungen könnten hier implementiert werden
        end
        
        if isInAir then
            if Config.AntiNoclip.NotifyPlayer then
                Notify("Verdächtiges Flugverhalten erkannt!")
            end
            
            SendDetection("noclip", "In der Luft ohne zu fallen")
        end
    end
end

-- Hilfsfunktion für Benachrichtigungen
function Notify(message)
    if Framework == "ESX" and ESX then
        ESX.ShowNotification(message)
    elseif Framework == "QBCore" and QBCore then
        QBCore.Functions.Notify(message)
    else
        -- Fallback auf native Benachrichtigung
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(true, false)
    end
end

-- Hauptthread für regelmäßige Überprüfungen
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        -- Warte auf Spieler-Spawn
        if isSpawned then
            -- Starte verschiedene Prüfungs-Timer
            StartCheckTimer("resources", Config.ResourceDetection.CheckInterval, CheckBlacklistedResources)
            StartCheckTimer("menus", Config.MenuDetection.CheckInterval, CheckBlacklistedMenus)
            StartCheckTimer("weapons", Config.WeaponDetection.CheckInterval, CheckBlacklistedWeapons)
            StartCheckTimer("vehicles", Config.VehicleDetection.CheckInterval, CheckBlacklistedVehicles)
            StartCheckTimer("objects", Config.ObjectDetection.CheckInterval, CheckBlacklistedObjects)
            StartCheckTimer("godmode", Config.AntiGodmode.CheckInterval, CheckGodmode)
            StartCheckTimer("spectate", Config.AntiSpectate.CheckInterval, CheckSpectate)
            StartCheckTimer("speedhack", Config.AntiSpeedhack.CheckInterval, CheckSpeedhack)
            StartCheckTimer("noclip", Config.AntiNoclip.CheckInterval, CheckNoclip)
            
            -- Verarbeite Timer
            ProcessCheckTimers()
        end
    end
end)

-- Event-Listener für die Kommunikation mit dem Server
RegisterNetEvent("anticheat:bypassStatus")
AddEventHandler("anticheat:bypassStatus", function(status)
    bypassActive = status
    
    if Config.Debug then
        print("[AntiCheat] Bypass-Status aktualisiert: " .. tostring(bypassActive))
    end
end)

-- Resourcenstart
AddEventHandler("onClientResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if Config.Debug then
            print("[AntiCheat] Client-Side gestartet.")
        end
        
        -- Initialen Bypass-Status vom Server abrufen
        TriggerServerEvent("anticheat:getBypassStatus")
    end
end)

-- Exportiere Funktionen, die von anderen Ressourcen verwendet werden können
exports("HasBypass", HasBypass)