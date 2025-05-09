-- VARIABLES
local pickpocketCooldown = 0
local processedPeds = {}
local PLAYER_PED = nil 

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
        Progress = exports[Config.FrameworkName .. "-base"]:FetchComponent("Progress")
        Notification = exports[Config.FrameworkName .. "-base"]:FetchComponent("Notification")
        Status = exports[Config.FrameworkName .. "-base"]:FetchComponent("Status")
        Targeting = exports[Config.FrameworkName .. "-base"]:FetchComponent("Targeting")
        Minigame = exports[Config.FrameworkName .. "-base"]:FetchComponent("Minigame")
        Inventory = exports[Config.FrameworkName .. "-base"]:FetchComponent("Inventory")
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
                    "Status",
                    "Targeting",
                    "Minigame",
                    "Inventory",
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
                                            text = Config.TargetLabel,
                                            event = "Pickpocket:Client:DoPickpocket",
                                            minDist = Config.TargetDistance,
                                            data = { entity = ped },
                                            isEnabled = function(data, entity)
                                                return GetCloudTimeAsInt() >= pickpocketCooldown and not IsInBlacklistedZone()
                                            end,
                                        },
                                    }, Config.TargetDistance)
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
        Notification:Error(Config.CooldownText)
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
        for _, fatPedModel in ipairs(Config.FatPeds) do
            local fatPedHash = GetHashKey(fatPedModel)
            if pedModel == fatPedHash then
                isFatPed = true
                break
            end
        end
    end
    
	RequestAnimDict(Config.ProgressBar.AnimDict)
	while not HasAnimDictLoaded(Config.ProgressBar.AnimDict) do
		Wait(5)
	end

    TaskPlayAnim(PlayerPedId(), Config.ProgressBar.AnimDict, Config.ProgressBar.Anim, 1, 1, 0, 0, 0)
    
    Progress:Progress({
        name = "prepare_pickpocket",
        duration = Config.ProgressBar.Duration,
        label = Config.ProgressBar.Label,
        useWhileDead = false,
        canCancel = false,
        ignoreModifier = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = false
    }, function(status)
        if not status then
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
        end
    end)
end)

AddEventHandler("Pickpocket:Client:Result", function(success, ped, isFatPed)
    if success then
        local cooldownTime = math.random(Config.Cooldown.Min, Config.Cooldown.Max)
        pickpocketCooldown = GetCloudTimeAsInt() + cooldownTime
        
        Callbacks:ServerCallback("Pickpocket:Server:Success", {
            isFatPed = isFatPed
        }, function(callbackSuccess)
            if not callbackSuccess then
                Notification:Error("Your pockets are too full to hold anything else!")
            end
        end)

        Status.Modify:Add("PLAYER_STRESS", Config.StressAmountSuccess, false, true)
    else
        Notification:Error(Config.FailedText)
        
        local cooldownTime = math.random(Config.Cooldown.Min, Config.Cooldown.Max)
        pickpocketCooldown = GetCloudTimeAsInt() + cooldownTime

        Status.Modify:Add("PLAYER_STRESS", Config.StressAmountFail, false, true)
    end

    FreezeEntityPosition(ped, false)

    local chance = math.random(1, 100)
    if chance <= Config.ChanceToGetCaught then
        -- if math.random(1, 2) == 1 then
        --     local relationshipGroup = GetHashKey("HATES_PLAYER")
        --     SetPedRelationshipGroupHash(ped, relationshipGroup)
            
        --     SetRelationshipBetweenGroups(5, relationshipGroup, GetHashKey("PLAYER"))
            
        --     TaskCombatPed(ped, PlayerPedId(), 0, 16)
        --     TriggerServerEvent("Pickpocket:Server:Caught")
        -- else

        --     Notification:Error("2")
        -- end
        SetPedFleeAttributes(ped, 0, 0)
        TaskSmartFleePed(ped, PlayerPedId(), 100.0, -1, true, true)
        Notification:Error(Config.CaughtText)
    elseif success then
        TaskWanderStandard(ped, 10.0, 10)
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
    StopAnimTask(PLAYER_PED, Config.ProgressBar.AnimDict, Config.ProgressBar.Anim, 1.0)
end

function IsPedBlacklisted(ped)
    local pedModel = GetEntityModel(ped)
    for _, blacklistedModel in ipairs(Config.BlacklistedPeds) do
        if GetHashKey(blacklistedModel) == pedModel then
            return true
        end
    end
    return false
end

function IsInBlacklistedZone()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, zone in ipairs(Config.BlacklistedZones) do
        local distance = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(zone.x, zone.y, zone.z))
        if distance <= zone.radius then
            return true
        end
    end
    return false
end
-- END FUNCTIONS