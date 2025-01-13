fx_version 'cerulean'
game 'gta5'

description 'Waypoint Placeables'
author 'BackSH00TER - Waypoint RP'
version '1.1.2'

shared_script {
    -- '@ox_lib/init.lua', -- Uncomment this if you are planning to integrate with any ox scripts
    'shared/config.lua',
    'shared/framework.lua',
}

client_scripts {
    'client/client.lua',
    'client/pushables.lua',
    'client/placeables.lua',
}

server_scripts {
    'server/server.lua',
}

lua54 'yes'
