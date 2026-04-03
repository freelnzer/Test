fx_version 'cerulean'
game 'gta5'

name 'db-base'
author 'voffi'
description 'Dominion Bay - Utilities'
version '1.0.1'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    '@qb-core/shared/locale.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/CircleZone.lua',
    'client/client.lua',
    'client/blips.lua',
    'client/nonpc.lua',
    'client/combatroll.lua',
    'client/nohelicopters.lua',
    'client/hairstyle.lua',
    'client/sirenresponse.lua',
    'client/debug.lua',
    'client_commands.lua',
}


server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/commands.lua',
}

dependencies {
    'qb-core'
}

