Config = {}

Config.FrameworkName = "mythic" -- "mythic" for Mythic Framework, "sandbox" for Sandbox Framework, "basename" for Custom Base
Config.BaseName = "sandbox" 
Config.Debugging = true
Config.ServerLogging = true

Config.Pickpocketing = {
    TargetDistance = 2.0,
    TargetLabel = "Pickpocket",
    Cooldown = {
        Min = 180, 
        Max = 480, 
    },
    
    ChanceToGetCaught = 50,
    
    ProgressBar = {
        Duration = 5500,
        Label = "Preparing...",

        -- This is an animation of the player looking around and "preparing" to pickpocket, this can be changed to any animation you want.
        AnimDict = "friends@frl@ig_1", 
        Anim = "idle_b_lamar",
        -- END

        AnimFlags = 49
    },
    
    Loot = {
        { item = 'cigarette', amount = {min = 1, max = 3}, weight = 30 },
        { item = 'petrock', amount = {min = 1, max = 1}, weight = 15 },
        { item = 'goldcoins', amount = {min = 8, max = 15}, weight = 5 },
    },

    FatPedLoot = {
        { item = 'burger', amount = {min = 1, max = 2}, weight = 30 },
        { item = 'orangotang_icecream', amount = {min = 1, max = 1}, weight = 15 },
        { item = 'crisp', amount = {min = 1, max = 1}, weight = 65 },
    },

    FatPeds = {
        "a_m_m_fatlatin_01",
        "a_m_m_fatlatin_02",
        "a_m_m_fatblack_01",
        "a_m_m_fatwhite_01",
        "ig_chengsr", 
        "ig_fatc", 
        "cs_fatc", 
        "a_m_m_tourist_01", 
        "a_m_m_afriamer_01",
        "a_m_y_downtown_01",
        "a_m_m_polynesian_01",
        "a_f_m_fatbla_01",
        "a_f_m_fatcult_01",
        "a_f_m_fatwhite_01",
        "a_f_m_downtown_01",
        "s_m_m_gentransport" 
    },
        
    BlacklistedPeds = {

    },
    
    BlacklistedZones = {

    },
    
    Controls = {
        DisableMovement = true,
        DisableCarMovement = true,
        DisableMouse = false,
        DisableCombat = true
    },

    CooldownText = "You must wait before pickpocketing again!",
    FailedText = "You got anxious and screwed up.",
    CaughtText = "Someone noticed your suspicious behavior!",
    SuccessText = "You successfully pickpocketed the person.",
    AlertTitle = "Suspicious Activity",
    AlertContent = "Petty Crime",
    AlertID = "pickpocket_alert",
} 