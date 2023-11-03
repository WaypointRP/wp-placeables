fx_version 'cerulean'
game 'gta5'

description 'Waypoint Placeables'
author 'BackSH00TER - Waypoint RP'
version '1.0.2'

shared_script {
    -- '@ox_lib/init.lua', -- Uncomment this if you are planning to use any ox scripts (such as ox notify)
    'shared/config.lua',
    'shared/framework.lua',
    'addons/yogamats/config.lua',
}

client_scripts {
    'client/client.lua',
    'client/pushables.lua',
    'client/placeables.lua',
    'addons/yogamats/yogamats.lua',
}

server_scripts {
    'server/server.lua',
}

lua54 'yes'
