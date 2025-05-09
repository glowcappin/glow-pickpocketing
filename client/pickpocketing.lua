-- VARIABLES
local pickpocketCooldown = 0
local processedPeds = {}
local PLAYER_PED = nil -- Will store the player's ped ID

-- BRIDGING
if GetResourceState(Config.FrameworkName .. "-base") ~= "started" then
    print("^1[Pickpocketing]^7 Waiting for ^1" .. Config.FrameworkName .. "-base^7 to load...")
    Wait(5000)
    print("^1[Pickpocketing]^7 Couldn't start for ^1" .. Config.FrameworkName .. "-base^7...")
    return
else
    print("^1[Pickpocketing]^7 Successfully started for ^1" .. Config.FrameworkName .. "-base^7...")
    AddEventHandler("Pickpocketing:Shared:DependencyUpdate", RetrieveComponents)
    function RetrieveComponents()
        Animations = exports[Config.FrameworkName .. "-base"]:FetchComponent("Animations")
        Logger = exports[Config.FrameworkName .. "-base"]:FetchComponent("Logger")
        Callbacks = exports[Config.FrameworkName .. "-base"]:FetchComponent("Callbacks")
        PedInteraction = exports[Config.FrameworkName .. "-base"]:FetchComponent("PedInteraction")
        Progress = exports[Config.FrameworkName .. "-base"]:FetchComponent("Progress")
        Phone = exports[Config.FrameworkName .. "-base"]:FetchComponent("Phone")
        Notification = exports[Config.FrameworkName .. "-base"]:FetchComponent("Notification")
        Polyzone = exports[Config.FrameworkName .. "-base"]:FetchComponent("Polyzone")
        Targeting = exports[Config.FrameworkName .. "-base"]:FetchComponent("Targeting")
        Progress = exports[Config.FrameworkName .. "-base"]:FetchComponent("Progress")
        Minigame = exports[Config.FrameworkName .. "-base"]:FetchComponent("Minigame")
        Keybinds = exports[Config.FrameworkName .. "-base"]:FetchComponent("Keybinds")
        Properties = exports[Config.FrameworkName .. "-base"]:FetchComponent("Properties")
        Sounds = exports[Config.FrameworkName .. "-base"]:FetchComponent("Sounds")
        Interaction = exports[Config.FrameworkName .. "-base"]:FetchComponent("Interaction")
        Inventory = exports[Config.FrameworkName .. "-base"]:FetchComponent("Inventory")
        Action = exports[Config.FrameworkName .. "-base"]:FetchComponent("Action")
        Blips = exports[Config.FrameworkName .. "-base"]:FetchComponent("Blips")
        EmergencyAlerts = exports[Config.FrameworkName .. "-base"]:FetchComponent("EmergencyAlerts")
        Doors = exports[Config.FrameworkName .. "-base"]:FetchComponent("Doors")
        ListMenu = exports[Config.FrameworkName .. "-base"]:FetchComponent("ListMenu")
        Input = exports[Config.FrameworkName .. "-base"]:FetchComponent("Input")
        Game = exports[Config.FrameworkName .. "-base"]:FetchComponent("Game")
        NetSync = exports[Config.FrameworkName .. "-base"]:FetchComponent("NetSync")
        Damage = exports[Config.FrameworkName .. "-base"]:FetchComponent("Damage")
        Lasers = exports[Config.FrameworkName .. "-base"]:FetchComponent("Lasers")
        UISounds = exports[Config.FrameworkName .. "-base"]:FetchComponent("UISounds")
    end

    AddEventHandler(
        "Core:Shared:Ready",
        function()
            exports[Config.FrameworkName .. "-base"]:RequestDependencies(
                "Pickpocketing",
                {
                    "Animations",
                    "Logger",
                    "Callbacks",
                    "Progress",
                    "Notification",
                    "Targeting",
                    "Progress",
                    "Minigame",
                    "Inventory",
                    "Action",
                    "Blips",
                    "EmergencyAlerts",
                    "Game",
                    "NetSync"
                },
                function(error)
                    if #error > 0 then
                        return
                    end
                    RetrieveComponents()

                    Citizen.CreateThread(function()
                        Citizen.Wait(20000) 
                        while true do
                            local peds = GetGamePool("CPed") 
                            for _, ped in pairs(peds) do
                                if not IsPedAPlayer(ped) and IsPedHuman(ped) and not IsEntityDead(ped) and not processedPeds[ped] and not IsPedBlacklisted(ped) then
                                    processedPeds[ped] = true 
                                    
                                    Targeting:AddPedModel(GetEntityModel(ped), "user", {
                                        {
                                            icon = "user",
                                            text = Config.Pickpocketing.TargetLabel,
                                            event = "Pickpocket:Client:DoPickpocket",
                                            minDist = Config.Pickpocketing.TargetDistance,
                                            data = { entity = ped },
                                            isEnabled = function(data, entity)
                                                return GetCloudTimeAsInt() >= pickpocketCooldown and not IsInBlacklistedZone()
                                            end,
                                        },
                                    }, Config.Pickpocketing.TargetDistance)
                                end
                            end
                            
                            Citizen.Wait(5000) 
                        end
                    end)
                end
            )
        end
    )
end

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports[Config.FrameworkName .. "-base"]:RegisterComponent("Pickpocketing", _PICKPOCKETING)
end)
-- END BRIDGING

-- MAIN EVENTS
AddEventHandler("Pickpocket:Client:DoPickpocket", function(data)
    PLAYER_PED = PlayerPedId()
    local ped = data.entity
    local currentTime = GetCloudTimeAsInt()
    
    if currentTime < pickpocketCooldown then
        Notification:Error(Config.Pickpocketing.CooldownText)
        return
    end
    
    local isFatPed = false
    
    if DoesEntityExist(ped) then
        local pedPos = GetEntityCoords(ped)
        local pedHeading = GetEntityHeading(ped)
        
        SetBlockingOfNonTemporaryEvents(ped, true)
        
        TaskTurnPedToFaceEntity(ped, PLAYER_PED, 1000)

        ClearPedTasksImmediately(ped) 

        TaskStandStill(ped, -1) 
        
        FreezeEntityPosition(ped, true)
        
        local pedModel = GetEntityModel(ped)
        for _, fatPedModel in ipairs(Config.Pickpocketing.FatPeds) do
            local fatPedHash = GetHashKey(fatPedModel)
            if pedModel == fatPedHash then
                isFatPed = true
                break
            end
        end
    end
    
    local dumbAnim = true

	RequestAnimDict('friends@frl@ig_1')
	while not HasAnimDictLoaded('friends@frl@ig_1') do
		Wait(5)
	end

	CreateThread(function()
		while dumbAnim do
			TaskPlayAnim(
				PlayerPedId(),
				'friends@frl@ig_1',
				'idle_b_lamar',
				1.0,
				1.0,
				1.0,
				16,
				0.0,
				0,
				0,
				0
			)
			Wait(1000)
		end
	end)
    
    Progress:Progress({
        name = "prepare_pickpocket",
        duration = Config.Pickpocketing.ProgressBar.Duration,
        label = Config.Pickpocketing.ProgressBar.Label,
        useWhileDead = false,
        canCancel = true,
        ignoreModifier = true,
        controlDisables = {
            disableMovement = Config.Pickpocketing.Controls.DisableMovement,
            disableCarMovement = Config.Pickpocketing.Controls.DisableCarMovement,
            disableMouse = Config.Pickpocketing.Controls.DisableMouse,
            disableCombat = Config.Pickpocketing.Controls.DisableCombat,
        },
        animation = false
    }, function(status)
        if not status then
            dumbAnim = false
            ClearPedTasks(PLAYER_PED)

            Minigame.Play:RoundSkillbar(1.0, 5, {
                onSuccess = function()
                    TriggerEvent("Pickpocket:Client:Result", true, ped, isFatPed)
                end,
                onFail = function()
                    TriggerEvent("Pickpocket:Client:Result", false, ped, isFatPed)
                end,
            }, {
                animation = {
                    animDict = "veh@break_in@0h@p_m_one@",
                    anim = "low_force_entry_ds",
                    flags = 49,
                }
            })

            ClearPedTasks(PLAYER_PED)
        else
            if DoesEntityExist(ped) then
                ClearPedTasksImmediately(ped)
                FreezeEntityPosition(ped, false)
                TaskWanderStandard(ped, 10.0, 10)
            end
            dumbAnim = false
        end
    end)
end)

AddEventHandler("Pickpocket:Client:Result", function(success, ped, isFatPed)
    if DoesEntityExist(ped) then
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(ped, false)
        
        if success and math.random(1, 100) <= Config.Pickpocketing.ChanceToGetCaught then
            TaskCombatPed(ped, PlayerPedId(), 0, 16)
        elseif success then
            TaskWanderStandard(ped, 10.0, 10)
        end 

        if not success then
            TaskCombatPed(ped, PlayerPedId(), 0, 16)
        end
    end
    
    if success then
        local cooldownTime = math.random(Config.Pickpocketing.Cooldown.Min, Config.Pickpocketing.Cooldown.Max)
        pickpocketCooldown = GetCloudTimeAsInt() + cooldownTime
        
        Notification:Success("Checking pockets...")
        
        Callbacks:ServerCallback("Pickpocket:Server:Success", {
            isFatPed = isFatPed
        }, function(callbackSuccess)
            if not callbackSuccess then
                Notification:Error("Your pockets are too full to hold anything else!")
            end
        end)
    else
        Notification:Error(Config.Pickpocketing.FailedText)
        
        if math.random(1, 100) <= Config.Pickpocketing.ChanceToGetCaught then
            Notification:Error(Config.Pickpocketing.CaughtText)
            
            TriggerServerEvent("Pickpocket:Server:Caught")
        end
        
        local cooldownTime = math.random(Config.Pickpocketing.Cooldown.Min, Config.Pickpocketing.Cooldown.Max)
        pickpocketCooldown = GetCloudTimeAsInt() + cooldownTime
    end
end)
-- END MAIN EVENTS

-- CLEANUP THREAD
Citizen.CreateThread(function()
    while LocalPlayer.state.LoggedIn do
        local playerPos = GetEntityCoords(PlayerPedId())
        
        for ped, _ in pairs(processedPeds) do
            if not DoesEntityExist(ped) or #(GetEntityCoords(ped) - playerPos) > 100.0 then
                processedPeds[ped] = nil
            end
        end
        
        Citizen.Wait(30000)
    end
end) 
-- END CLEANUP THREAD

-- FUNCTIONS
function ForceStopAllAnimations()
    ClearPedTasks(PLAYER_PED)
    ClearPedSecondaryTask(PLAYER_PED)
    StopAnimTask(PLAYER_PED, Config.Pickpocketing.ProgressBar.AnimDict, Config.Pickpocketing.ProgressBar.Anim, 1.0)
end

function IsPedBlacklisted(ped)
    local pedModel = GetEntityModel(ped)
    for _, blacklistedModel in ipairs(Config.Pickpocketing.BlacklistedPeds) do
        if GetHashKey(blacklistedModel) == pedModel then
            return true
        end
    end
    return false
end

function IsInBlacklistedZone()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, zone in ipairs(Config.Pickpocketing.BlacklistedZones) do
        local distance = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(zone.x, zone.y, zone.z))
        if distance <= zone.radius then
            return true
        end
    end
    return false
end
-- END FUNCTIONS