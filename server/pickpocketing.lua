if GetResourceState(Config.FrameworkName .. "-base") ~= "started" then
    print("^1[Pickpocketing]^7 Waiting for ^1" .. Config.FrameworkName .. "-base^7 to load...")
    Wait(5000)
    print("^1[Pickpocketing]^7 Couldn't start for ^1" .. Config.FrameworkName .. "-base^7...")
    return
else
    print("^1[Pickpocketing]^7 Successfully started for ^1" .. Config.FrameworkName .. "-base^7...")

    AddEventHandler("Pickpocketing:Shared:DependencyUpdate", RetrieveComponents)
    function RetrieveComponents()
	    Banking = exports[Config.FrameworkName .. "-base"]:FetchComponent("Banking")
	    Fetch = exports[Config.FrameworkName .. "-base"]:FetchComponent("Fetch")
	    Logger = exports[Config.FrameworkName .. "-base"]:FetchComponent("Logger")
	    Utils = exports[Config.FrameworkName .. "-base"]:FetchComponent("Utils")
	    Callbacks = exports[Config.FrameworkName .. "-base"]:FetchComponent("Callbacks")
	    Middleware = exports[Config.FrameworkName .. "-base"]:FetchComponent("Middleware")
	    Inventory = exports[Config.FrameworkName .. "-base"]:FetchComponent("Inventory")
	    Loot = exports[Config.FrameworkName .. "-base"]:FetchComponent("Loot")
	    Wallet = exports[Config.FrameworkName .. "-base"]:FetchComponent("Wallet")
	    Execute = exports[Config.FrameworkName .. "-base"]:FetchComponent("Execute")
	    Chat = exports[Config.FrameworkName .. "-base"]:FetchComponent("Chat")
	    Sounds = exports[Config.FrameworkName .. "-base"]:FetchComponent("Sounds")
	    Tasks = exports[Config.FrameworkName .. "-base"]:FetchComponent("Tasks")
	    EmergencyAlerts = exports[Config.FrameworkName .. "-base"]:FetchComponent("EmergencyAlerts")
	    Properties = exports[Config.FrameworkName .. "-base"]:FetchComponent("Properties")
	    Routing = exports[Config.FrameworkName .. "-base"]:FetchComponent("Routing")
	    Status = exports[Config.FrameworkName .. "-base"]:FetchComponent("Status")
	    WaitList = exports[Config.FrameworkName .. "-base"]:FetchComponent("WaitList")
	    Reputation = exports[Config.FrameworkName .. "-base"]:FetchComponent("Reputation")
	    Jobs = exports[Config.FrameworkName .. "-base"]:FetchComponent("Jobs")
	    Doors = exports[Config.FrameworkName .. "-base"]:FetchComponent("Doors")
	    Crypto = exports[Config.FrameworkName .. "-base"]:FetchComponent("Crypto")
	    Phone = exports[Config.FrameworkName .. "-base"]:FetchComponent("Phone")
	    Vehicles = exports[Config.FrameworkName .. "-base"]:FetchComponent("Vehicles")
	    Vendor = exports[Config.FrameworkName .. "-base"]:FetchComponent("Vendor")
	    CCTV = exports[Config.FrameworkName .. "-base"]:FetchComponent("CCTV")
	    Sync = exports[Config.FrameworkName .. "-base"]:FetchComponent("Sync")
    end

    AddEventHandler("Core:Shared:Ready", function()
        exports[Config.FrameworkName .. "-base"]:RequestDependencies("Pickpocketing", {
            "Banking",
            "Fetch",
            "Logger",
            "Utils",
            "Callbacks",
            "Middleware",
            "Inventory",
            "Loot",
            "Wallet",
            "Execute",
            "Chat",
            "Sounds",
            "Tasks",
            "EmergencyAlerts",
            "Properties",
            "Routing",
            "Status",
            "WaitList",
            "Reputation",
            "Jobs",
            "Doors",
            "Crypto",
            "Phone",
            "Vehicles",
            "Vendor",
            "CCTV",
            "Sync",
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
    local lootTable = Config.Pickpocketing.Loot
    
    if isFatPed then
        lootTable = Config.Pickpocketing.FatPedLoot
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

    if Config.BaseName == "mythic" then
        char = Fetch:Source(source):GetData("Character")
    elseif Config.BaseName == "sandbox" then
        char = Fetch:CharacterSource(source)
    end
    
    local loot = GetRandomLoot(data.isFatPed)
    
    if Config.Debugging then
        print("^3[Pickpocketing DEBUG]^7 Generated loot:", loot.item, "x", loot.amount)
    end

    local success = Inventory:AddItem(char:GetData("SID"), loot.item, loot.amount, {}, 1, false, false, false, false, false, false)
    
    if Config.Debugging then
        print("^3[Pickpocketing DEBUG]^7 AddItem result:", success)
    end

end
-- END HELPER FUNCTIONS

RegisterNetEvent("Pickpocket:Server:Caught")
AddEventHandler("Pickpocket:Server:Caught", function()
    local source = source
    PDAlert(source, Config.Pickpocketing.AlertTitle, Config.Pickpocketing.AlertContent, Config.Pickpocketing.AlertID)
    if Config.ServerLogging then
        print(string.format("[Pickpocketing] Player %s was caught pickpocketing", source))
    end
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