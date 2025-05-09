if GetResourceState(Config.FrameworkName .. "-base") ~= "started" then
    print("^1[Pickpocketing]^7 Waiting for ^1" .. Config.FrameworkName .. "-base^7 to load...")
    Wait(5000)
    print("^1[Pickpocketing]^7 Couldn't start for ^1" .. Config.FrameworkName .. "-base^7...")
    return
else
    print("^1[Pickpocketing]^7 Successfully started for ^1" .. Config.FrameworkName .. "-base^7...")

    AddEventHandler("Pickpocketing:Shared:DependencyUpdate", RetrieveComponents)
    function RetrieveComponents()
	    Fetch = exports[Config.FrameworkName .. "-base"]:FetchComponent("Fetch")
	    Logger = exports[Config.FrameworkName .. "-base"]:FetchComponent("Logger")
	    Callbacks = exports[Config.FrameworkName .. "-base"]:FetchComponent("Callbacks")
	    Inventory = exports[Config.FrameworkName .. "-base"]:FetchComponent("Inventory")
	    EmergencyAlerts = exports[Config.FrameworkName .. "-base"]:FetchComponent("EmergencyAlerts")
	    Status = exports[Config.FrameworkName .. "-base"]:FetchComponent("Status")
    end

    AddEventHandler("Core:Shared:Ready", function()
        exports[Config.FrameworkName .. "-base"]:RequestDependencies("Pickpocketing", {
            "Fetch",
            "Logger",
            "Callbacks",
            "Inventory",
            "EmergencyAlerts",
            "Status",
        }, function(error)
            if #error > 0 then
                return
            end
            RetrieveComponents()

            Callbacks:RegisterServerCallback("Pickpocket:Server:Success", function(source, data, cb)                
                HandlePickpocketSuccess(source, data, cb)
            end)
        end)
    end)
    
    AddEventHandler("Proxy:Shared:RegisterReady", function()
        exports[Config.FrameworkName .. "-base"]:RegisterComponent("Pickpocketing", _PICKPOCKETING)
    end)
    end

-- HELPER FUNCTIONS
function GetRandomLoot(isFatPed)
    local totalWeight = 0
    local lootTable = Config.Loot
    
    if isFatPed then
        lootTable = Config.FatPedLoot
    end
    
    for _, item in ipairs(lootTable) do
        totalWeight = totalWeight + item.weight
    end
    
    local randomWeight = math.random(totalWeight)
    local currentWeight = 0
    local selectedItem = nil
    
    for _, item in ipairs(lootTable) do
        currentWeight = currentWeight + item.weight
        if randomWeight <= currentWeight then
            selectedItem = item
            break
        end
    end
    
    local amount = math.random(selectedItem.amount.min, selectedItem.amount.max)
    
    return {
        item = selectedItem.item,
        amount = amount
    }
end

function HandlePickpocketSuccess(source, data, cb)
    local pState = Player(source).state

    local char

    if Config.Base == "mythic" then
        char = Fetch:Source(source):GetData("Character")
    elseif Config.Base == "sandbox" then
        char = Fetch:CharacterSource(source)
    end
    
    local loot = GetRandomLoot(data.isFatPed)

    local success = Inventory:AddItem(char:GetData("SID"), loot.item, loot.amount, {}, 1, false, false, false, false, false, false)
end
-- END HELPER FUNCTIONS

RegisterNetEvent("Pickpocket:Server:Caught")
AddEventHandler("Pickpocket:Server:Caught", function()
    local source = source
    PDAlert(source, Config.AlertTitle, Config.AlertContent, Config.AlertID)
end) 

function PDAlert(src, content, content2, name)
    EmergencyAlerts:Create(
        src,
        GetEntityCoords(GetPlayerPed(src)),
        "10-24",
        content,
        {
            icon = 500,
            size = 1,
            color = 1,
            duration = (60 * 5),
        },
        {
            icon = "shield-quartered",
            details = content2,
        },
        name
    )
end 