fx_version "cerulean"
game "gta5"

lua54 "yes"

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'language.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'Server.lua',
}

client_scripts {
    'Client.lua',
}

dependencies {
    'qb-core'
}
