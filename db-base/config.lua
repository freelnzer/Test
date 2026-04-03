-- db-base / config.lua

Config = {}

-- Globales Debugging
Config.Debug = true

-- Module-Schalter 
Config.Modules = {
    Blips = true, 
    NoNpcZones = true,
    CombatRoll = true,
    NoNpcHelicopters = true,
    Hairstyle = true,         -- Frisierset-Item öffnet Frisur-Menü
    SirenResponse = true,     -- NPC-Fahrzeuge reagieren auf Blaulicht/Sirene
}

--PANIKBUTTON
Config.CommandName = 'panicbtn'
Config.DefaultKey = 'F10'
Config.RequiredItem = 'gps'
Config.PanicEvent = 'ps-dispatch:client:triggerpanic'

-- SIREN RESPONSE
Config.SirenResponse = {
    detectionRadius = 180.0,
    responseRadius = 45.0,
    checkInterval = 350,

    reactCooldown = 2800,

    evadeDuration = 1000,
    slowdownDelay = 700,
    slowdownPercent = 8,
    minSlowSpeed = 6.0,
    resetDelay = 1800,

    minNpcSpeed = 4.0,

    frontDotThreshold = 0.15,
    directionDotThreshold = 0.30
}

-- HAIRSTYLE
-- Erlaubt Spielern, per Item das Frisur-Menü (tgiann-clothing) zu öffnen.
Config.Hairstyle = {
    item         = 'frisierset',                        -- Item-Name im Inventar
    notification = true,                                -- Benachrichtigung bei Benutzung?
    notifyText   = 'Du holst dein Frisierset heraus...', -- Benachrichtigungstext
    animDict     = 'mp_player_intcelebrationloops',     -- Animations-Dictionary
    animName     = 'selfie',                            -- Animations-Name (Charakter schaut in Kamera)
    animDuration = 3000,                                -- Animations-Dauer in ms (vor Menü-Öffnung)
}

-- BLIPS
-- Aktiviere/Deaktiviere die Erstellung aller Blips global
Config.Blips = {
    {
        enabled = true,
        name = 'State Administration',
        coords = vector3(-538.7228, -214.6586, 37.7097),
        sprite = 419,       -- Landmark
        color = 0,          -- Weiß
        scale = 1.0,        -- 0.0 - 1.0 (typisch 0.6 - 1.0)
        display = 4,        -- 2 = Map, 3 = Minimap, 4 = beides
        shortRange = false,  -- nur in der Nähe sichtbar
        category = nil,     -- optional
        route = false       -- optional
    },
    {
        enabled = true,
        name = 'Pier 76 - Car Club',
        coords = vector3(-425.1133, 18.6771, 46.3475),
        sprite = 524,       -- Landmark
        color = 31,          -- Weiß
        scale = 0.7,        -- 0.0 - 1.0 (typisch 0.6 - 1.0)
        display = 4,        -- 2 = Map, 3 = Minimap, 4 = beides
        shortRange = false,  -- nur in der Nähe sichtbar
        category = nil,     -- optional
        route = false       -- optional
    },
    {
        enabled = true,
        name = 'Calloway Holding',
        coords = vector3(-1799.1331, 473.3504, 133.7837),
        sprite = 207,       -- Landmark
        color = 73,          -- Weiß
        scale = 0.7,        -- 0.0 - 1.0 (typisch 0.6 - 1.0)
        display = 4,        -- 2 = Map, 3 = Minimap, 4 = beides
        shortRange = false,  -- nur in der Nähe sichtbar
        category = nil,     -- optional
        route = false       -- optional
    },
    --[[{
        enabled = true,
        name = 'San Andreas Fire Department',
        coords = vector3(-636.0016, -123.2746, 39.0744),
        sprite = 436,        
        color = 1,          
        scale = 0.9,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },]]
    {
        enabled = true,
        name = 'Department of Justice',
        coords = vector3(-557.2015, -238.2594, 38.3128),
        sprite = 677,        
        color = 16,          
        scale = 0.9,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    --[[{
        enabled = true,
        name = 'San Andreas Court',
        coords = vector3(-557.2015, -238.2594, 38.3128),
        sprite = 677,        
        color = 16,          
        scale = 0.9,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'San Andreas Attorney',
        coords = vector3(-508.6044, -208.8564, 38.3305),
        sprite = 408,       
        color = 16,          
        scale = 0.9,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },]]
    --[[{
        enabled = true,
        name = 'Emergency Medical Service',
        coords = vector3(-706.7086, -1179.0199, 10.6921),
        sprite = 61,       
        color = 1,          
        scale = 0.6,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },]]
    {
        enabled = false,
        name = 'Immobilienbüro und Bauamt',
        coords = vector3(200.0818, -869.1932, 29.7762), -- 200.0818, -869.1932, 29.7762, 67.0297
        sprite = 566,       
        color = 26,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Vespucci Cars by Barn Motors',
        coords = vector3(-1116.2308, -1727.5641, 4.2758), -- 200.0818, -869.1932, 29.7762, 67.0297
        sprite = 326,       
        color = 39,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    --[[{
        enabled = true,
        name = 'Mosleys',
        coords = vector3(-44.6962, -1660.7557, 29.2832), -- 200.0818, -869.1932, 29.7762, 67.0297
        sprite = 446,      --446 
        color = 47,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },]]
    {
        enabled = false,
        name = 'Pannenhilfe',
        coords = vector3(-8.6315, -1643.3870, 29.1687), -- 200.0818, -869.1932, 29.7762, 67.0297
        sprite = 446,      --446 
        color = 47,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Bubble Cafe',
        coords = vector3(-1231.7216, -1042.2653, 8.2833), -- 200.0818, -869.1932, 29.7762, 67.0297
        sprite = 106,       
        color = 27,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'The Town',
        coords = vector3(-1340.8220, -1078.3137, 7.0282), -- 200.0818, -869.1932, 29.7762, 67.0297
        sprite = 889,       
        color = 62,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Tierhandlung',
        coords = vector3(234.9060, -15.6061, 74.9869),
        sprite = 273,       
        color = 4,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    
    ---Kleidungsläden
    {
        enabled = true,
        name = 'Digital Den',
        coords = vector3(-508.8819, 277.9439, 83.3101),
        sprite = 355,       
        color = 50,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Beauty Salon',
        coords = vector3(-59.4947, -208.8053, 45.8095),
        sprite = 279,       
        color = 8,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Ponsenbys',
        coords = vector3(-708.4875, -155.4815, 37.4151), -- -708.4875, -155.4815, 37.4151, 75.1397
        sprite = 73,       
        color = 13,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Binco',
        coords = vector3(77.4158, -1393.3911, 29.2717), -- 77.4158, -1393.3911, 29.2717, 125.5100
        sprite = 73,       
        color = 31,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Eventaustattung',
        coords = vector3(-1065.9854, -506.3437, 36.5058), -- -1065.9854, -506.3437, 36.5058, 335.9029
        sprite = 790,       
        color = 39,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Schneiderei',
        coords = vector3(717.0646, -964.7588, 30.3954), -- 717.0646, -964.7588, 30.3954, 189.7818
        sprite = 73,       
        color = 28,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Juwelier',
        coords = vector3(-623.6329, -231.9900, 37.9571), -- -623.6329, -231.9900, 37.9571, 285.1138
        sprite = 617,       
        color = 37,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Kleider & Zwirn',
        coords = vector3(-162.9566, -300.1603, 39.6333), -- -162.9566, -300.1603, 39.6333, 96.1562
        sprite = 73,       
        color = 32,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Masken & Hüte',
        coords = vector3(-1337.1821, -1278.2970, 4.7683), -- -1337.1821, -1278.2970, 4.7683, 259.5025
        sprite = 362,       
        color = 28,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Outdoor',
        coords = vector3(-769.0653, 5597.5244, 33.6759), -- -769.0653, 5597.5244, 33.6759, 331.5464
        sprite = 73,       
        color = 28,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Bikeclothing',
        coords = vector3(-3173.9004, 1044.2361, 20.9532), -- -3173.9004, 1044.2361, 20.9532, 337.2662
        sprite = 73,       
        color = 28,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },    
    {
        enabled = true,
        name = 'Rucksackstore',
        coords = vector3(398.8878, 98.6797, 101.6080), -- 398.8878, 98.6797, 101.6080, 151.3287
        sprite = 850,       
        color = 28,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Dessous & Bademode',
        coords = vector3(-821.5002, -1075.7762, 11.3281), -- -821.5002, -1075.7762, 11.3281, 64.9700
        sprite = 73,       
        color = 28,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Sizes',
        coords = vector3(-1192.6176, -772.1875, 17.3197), -- -1192.6176, -772.1875, 17.3197, 309.0766
        sprite = 73,       
        color = 28,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Suburban',
        coords = vector3(123.5665, -220.2218, 54.4528), -- 123.5665, -220.2218, 54.4528, 151.3616
        sprite = 73,       
        color = 28,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = '24/7 - Großmarkt',
        coords = vector3(151.8101, 235.0074, 106.7888), -- 123.5665, -220.2218, 54.4528, 151.3616
        sprite = 590,       
        color = 2,          
        scale = 1.0,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    --[[{
        enabled = true,
        name = 'Mirrorpark Ink',
        coords = vector3(1214.3849, -415.8015, 67.7527),
        sprite = 75,       
        color = 4,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },]]
    --[[{
        enabled = true,
        name = 'Ho Ho Ho Shop',
        coords = vector3(1476.3000, 2723.9255, 37.5177),
        sprite = 525,       
        color = 4,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },]]
    {
        enabled = true,
        name = 'Cruisin Craftsmen - Werkstatt',
        coords = vector3(-332.9456, -1391.4135, 35.5168),
        sprite = 446,       
        color = 1,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Fahrzeugbedarf',
        coords = vector3(-317.0681, -1377.2894, 31.4423),
        sprite = 59,       
        color = 3,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Southside Customs',
        coords = vector3(920.7058, -2520.5010, 28.2919),
        sprite = 72,       
        color = 38,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
    {
        enabled = true,
        name = 'Lawson & Partner',
        coords = vector3(-302.79, -724.05, 33.55),
        sprite = 77,       
        color = 22,          
        scale = 0.7,
        display = 4,
        shortRange = false,
        category = nil,
        route = false
    },
}

Config.NoNpcSettings = {
    enableDebugDraw            = true,   -- Erlaubt die visuelle Zonenanzeige überhaupt
    forceDebugAllZones         = true,  -- Ignoriert debugPoly pro Zone und zeichnet alle Zonen
    debugDrawDistance          = 220.0,  -- In welcher Entfernung Zonen gezeichnet werden
    debugAlpha                 = 90,     -- Transparenz der gezeichneten Zone

    activationDistance         = 120.0,  -- Extra-Puffer um eine Zone, bevor Cleanup aktiv wird
    nearRefreshInterval        = 500,    -- Wie oft Zonen in Spielernaehe neu bewertet werden (ms)
    idleRefreshInterval        = 2500,   -- Wie oft weit entfernte Zonen neu bewertet werden (ms)

    pedScanRadius              = 140.0,  -- Nur Peds in diesem Radius um den Spieler werden geprueft
    vehicleScanRadius          = 180.0,  -- Nur Fahrzeuge in diesem Radius um den Spieler werden geprueft

    activePedCleanupInterval   = 700,    -- Cleanup-Intervall fuer Peds, wenn der Spieler zonennah ist (ms)
    activeVehicleCleanupInterval = 1800, -- Cleanup-Intervall fuer Fahrzeuge, wenn der Spieler zonennah ist (ms)
    idleCleanupInterval        = 2500,   -- Wartezeit fuer Ped-Cleanup, wenn keine Zone relevant ist (ms)
    idleVehicleCleanupInterval = 4000,   -- Wartezeit fuer Vehicle-Cleanup, wenn keine Zone relevant ist (ms)

    debugLog                   = true,  -- Extra Konsolenlogs fuer Fehlersuche
}

-- NoNpcZones
Config.NoNpcZones = {
    {
        enabled = true,
        points = {
            vector4(-17.8274, 881.9095, 232.6343, 0.0), 
            vector4(-23.6444, 1034.2059, 227.1945, 0.0),
            vector4(-241.6043, 1042.9647, 235.2579, 0.0),
            vector4(-182.9814, 851.3582, 232.7003, 0.0),
            vector4(-49.3069, 775.4215, 227.9317, 0.0),
        },
        debugPoly = true, 
        removePeds = true, 
        removeVehicles = true 
    },
        -- Ocean Medical
    {
        enabled = true,
        points = {
            vector4(-1881.7219, -259.8636, 49.8358, 174.4033),
            vector4(-1943.3201, -346.7935, 46.9785, 250.8553),
            vector4(-1931.7343, -379.5977, 48.8160, 9.9306),
            vector4(-1865.1683, -441.3437, 46.2628, 312.9947),
            vector4(-1793.8895, -350.0116, 44.6090, 47.7239),
        },
        debugPoly = true, 
        removePeds = true, 
        removeVehicles = true 
    },

    -- MRPD
    {
        enabled = true,
        points = {
            vector4(405.4880, -1033.2396, 29.3281, 350.0876), 
            vector4(494.3553, -1023.9196, 28.1293, 92.2951),
            vector4(493.2305, -963.0287, 27.2060, 95.2310),
            vector4(406.2009, -963.7166, 29.3944, 175.8319),
        },
        debugPoly = true, 
        removePeds = true, 
        removeVehicles = true 
    },

    -- Stadtverwaltung / DOJ
    {
        enabled = true,
        points = {
            vector4(-569.63, -247.69, 36.28, 31.81), 
            vector4(-494.31, -204.66, 36.94, 103.68),
            vector4(-522.11, -158.79, 38.65, 290.93),
            vector4(-595.21, -201.45, 37.65, 301.39),
        },
        debugPoly = true, 
        removePeds = true, 
        removeVehicles = true 
    }, 

        -- Stadtpark
    {
        enabled = true,
        points = {
            vector4(387.9006, -1121.4919, 29.5047, 6.5118), 
            vector4(231.5390, -1118.5444, 32.7550, 353.1432),
            vector4(233.1407, -1070.7797, 32.7457, 273.6158),
            vector4(389.0810, -1070.8282, 33.0964, 178.4978),
        },
        debugPoly = true, 
        removePeds = true, 
        removeVehicles = true 
    }, 
    -- PLS 421
    {
        enabled = true,
        points = {
            vector4(-2556.8193, 1875.7114, 168.9680, 347.8831), 
            vector4(-2614.5745, 1829.9744, 162.8030, 41.7415),
            vector4(-2666.4302, 1879.7474, 163.0823, 306.1115),
            vector4(-2606.9631, 1936.7758, 167.1470, 209.2614),
            vector4(-2541.5955, 1930.5455, 173.6143, 84.7733),
            vector4(-2548.0930, 1914.5439, 171.6532, 175.1275),
        },
        debugPoly = true, 
        removePeds = true, 
        removeVehicles = true 
    }, 
    -- PLS unbekannt
    {
        enabled = true,
        points = {
            vector4(-1091.0500, 343.0492, 73.4671, 65.1354), 
            vector4(-1093.6154, 383.0012, 74.2503, 88.1275),
            vector4(-1111.8607, 389.8086, 77.5062, 175.5289),
            vector4(-1178.6837, 392.7045, 80.6901, 204.9777),
            vector4(-1182.3701, 386.1027, 82.5412, 255.9225),
            vector4(-1181.5762, 364.4877, 79.8377, 195.1352),
            vector4(-1176.7811, 355.8799, 79.7573, 223.8359),
            vector4(-1176.7811, 355.8799, 79.7573, 223.8359),
            vector4(-1159.3793, 342.1467, 78.8544, 341.6311),
        },
        debugPoly = true, 
        removePeds = true, 
        removeVehicles = true 
    }, 
    --PLZ 459
    {
        enabled = true,
        points = {
            vector4(-1772.7432, 365.9259, 94.0172, 297.1030), 
            vector4(-1746.9036, 319.6913, 90.0573, 301.8274),
            vector4(-1695.0090, 363.7355, 92.3437, 144.3470),
            vector4(-1708.8091, 400.7603, 95.7559, 174.1107),
        },
        debugPoly = true, 
        removePeds = true, 
        removeVehicles = true 
    }, 

    --PLZ Hustler Hood
    {
        enabled = true,
        points = {
            vector4(-1317.6742, -894.8251, 15.2956, 153.9924), 
            vector4(-1357.3389, -919.8573, 18.9198, 200.2128),
            vector4(-1342.6052, -955.7782, 16.0343, 287.8505),
            vector4(-1299.5458, -942.1878, 14.5931, 17.9290),
        },
        debugPoly = true, 
        removePeds = true, 
        removeVehicles = true 
    }, 
    -- crusin craftsmen
    {
        enabled = true,
        points = {
            vector4(-296.5762, -1254.5741, 32.9560, 92.8897),
            vector4(-326.3768, -1259.9668, 34.0080, 102.8110),
            vector4(-353.7893, -1285.4495, 34.8175, 144.7007),
            vector4(-364.5382, -1324.7411, 36.5152, 175.7636),
            vector4(-364.5668, -1408.9886, 33.7408, 267.2991),
            vector4(-298.4317, -1408.1155, 33.9289, 358.9919),

        },
        debugPoly = true, 
        removePeds = true, 
        removeVehicles = true 
    }, 
    -- PLZ 016 und 17
    {
        enabled = true,
        points = {
            vector4(-415.7829, 6186.9517, 35.1529, 25.9403),
            vector4(-422.4715, 6203.9668, 35.9122, 9.1686),
            vector4(-414.5965, 6268.6650, 35.8763, 75.5072),
            vector4(-451.4458, 6284.1675, 32.9463, 234.6805),
            vector4(-487.0508, 6172.2173, 34.0634, 306.1765),

        },
        debugPoly = true, 
        removePeds = true, 
        removeVehicles = true 
    }, 
    -- Cardealer
    {
        enabled = true,
        points = {
            vector4(-1088.4238, -1718.1061, 6.0656, 121.9244),
            vector4(-1177.8977, -1781.7546, 8.0088, 34.9953),
            vector4(-1204.7686, -1750.6062, 11.6968, 301.0583),
            vector4(-1112.4836, -1685.6987, 10.4095, 215.7041),
        },
        debugPoly = true, 
        removePeds = true, 
        removeVehicles = true 
    }, 

    -- Calloway Holding
    {
        enabled = true,
        points = {
            vector4(-1744.4329, 479.3197, 135.5892, 182.3577),
            vector4(-1724.4543, 419.3604, 120.4069, 112.3970),
            vector4(-1881.9930, 349.8827, 122.0915, 6.0978),
            vector4(-1892.7148, 434.8979, 128.3587, 274.0504),
            vector4(-1870.4158, 431.7181, 128.2238, 319.1684),
            vector4(-1838.9487, 476.8483, 137.7016, 276.8848),
        },
        debugPoly = true, 
        removePeds = true, 
        removeVehicles = true 
    },
}