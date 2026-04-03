Config = {}

Config.EnableBlips = true
Config.BlipSprite = 100
Config.BlipColor = 2
Config.BlipScale = 0.8
Config.BlipName = 'Smart Repair'

Config.PriceStandard = 100
Config.PricePremium = 250
Config.PriceLady = 250

Config.DamageMin = 800.0
Config.RequiredBodyHealthForScratchRepair = 800.0

Config.UseInventoryCashItem = true
Config.InventoryCashItem = 'money_item'

Config.EnableCosmeticNPCs = true

Config.NPCwashTime = 8000
Config.ParticleTime = 6000

Config.WashPlaces = {
    [1] = {
        id = 1,
        pos = vec3(174.32, -1736.78, 29.38),
        carPos = vec3(174.32, -1736.78, 28.88),
        carHeading = 270.0,

        npc = {
            enabled = true,
            modelStandard = "A_F_M_FatCult_01",
            modelPremium = "A_F_Y_Beach_02",
            modelLady ="A_M_Y_MusclBeac_01",

            spawn1 = vec4(171.11, -1732.52, 29.49, 184.95),
            spawn2 = vec4(177.53, -1740.84, 29.49, 15.30),

            clean1 = vec4(172.81, -1735.46, 29.29, 186.85),
            clean2 = vec4(175.27, -1738.09, 29.29, 354.67),
            clean3 = vec4(172.75, -1738.20, 29.29, 357.38),
            clean4 = vec4(175.41, -1735.46, 29.29, 182.11),

            exit1 = vec4(179.011, -1711.872, 29.2799, 0.0),
            exit2 = vec4(179.011, -1711.872, 29.2799, 0.0),
        }
    }
}