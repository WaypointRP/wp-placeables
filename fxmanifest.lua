fx_version 'cerulean'
game 'gta5'

description 'Waypoint Placeables'
author 'BackSH00TER - Waypoint RP'
version '1.0.2'

shared_script {
    -- '@ox_lib/init.lua', -- Uncomment this if you are planning to use any ox scripts (such as ox notify)
    'shared/config.lua',
    'shared/framework.lua',
    'addons/printers/config.lua',
}

client_scripts {
    'client/client.lua',
    'client/pushables.lua',
    'client/placeables.lua',
    'addons/printers/client.lua',
}

server_scripts {
    'server/server.lua',
    'addons/printers/server.lua',
}

ui_page "addons/printers/html/index.html"

files {
    "addons/printers/html/*",
}

lua54 'yes'
