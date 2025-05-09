Config = {}

Config.FrameworkName = "mythic" -- supports "mythic", "sandbox", or a custom base name (i.e: "click")
Config.Base = "mythic" -- supports "mythic" for Mythic Framework, "sandbox" for Sandbox Framework

Config.TargetDistance = 2.0
Config.TargetLabel = "Pickpocket"

Config.StressAmountSuccess = 5
Config.StressAmountFail = 10

Config.ChanceToGetCaught = 50 -- For now, this will alert police and the ped will flee. However, in the next update, the ped will be able to attack the player.

Config.Cooldown = {
    Min = 180, -- in seconds (Inital: 3 minutes, 180s)
    Max = 480, -- in seconds (Inital: 8 minutes, 480s)
}

Config.ProgressBar = {
    Duration = 5500,
    Label = "Preparing...",

    -- This is an animation of the player looking around and "preparing" to pickpocket, this can be changed to any animation you want.
    AnimDict = "friends@frl@ig_1", 
    Anim = "idle_b_lamar",
    -- end 

    AnimFlags = 49
}

Config.Loot = {
    { item = 'cigarette', amount = {min = 1, max = 3}, weight = 30 },
    { item = 'petrock', amount = {min = 1, max = 1}, weight = 15 },
    { item = 'goldcoins', amount = {min = 8, max = 15}, weight = 5 },
}

Config.FatPedDistinction = true -- If true, the script will be able to distinguish between a "fat" and "skinny" ped. "Fat" peds will have a different loot table.

Config.FatPedLoot = {
    { item = 'burger', amount = {min = 1, max = 2}, weight = 30 },
    { item = 'orangotang_icecream', amount = {min = 1, max = 1}, weight = 15 },
    { item = 'crisp', amount = {min = 1, max = 1}, weight = 65 },
}

Config.FatPeds = {
    "a_m_m_fatlatin_01",
    "a_m_m_fatlatin_02",
    "a_m_m_fatblack_01",
    "a_m_m_fatwhite_01",
}

Config.BlacklistedPeds = {

}

Config.BlacklistedZones = {

}   

Config.CooldownText = "You must wait before pickpocketing again!"
Config.FailedText = "You got anxious and screwed up."
Config.CaughtText = "Someone noticed your suspicious behavior!"
Config.SuccessText = "You successfully pickpocketed the person."
Config.AlertTitle = "Suspicious Activity"
Config.AlertContent = "Petty Crime"

Config.AlertID = "pickpocket_alert"