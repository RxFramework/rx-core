fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'RX Framework'
description 'Core resource for RXFramework, contains all the core functionality and features'
version '1.3.0'

provide 'qb-core'
provide 'qbx_core'
provide 'es_extended'
provide 'ND_Core'
provide 'vrp'

shared_scripts {
    'config/config.lua',
    'shared/locale.lua',
    'locale/en.lua',
    'locale/*.lua',
    'shared/main.lua',
    'shared/items.lua',
    'shared/jobs.lua',
    'shared/vehicles.lua',
    'shared/gangs.lua',
    'shared/weapons.lua',
    'shared/locations.lua',
    'bridge/shared/netforward.lua',
    'bridge/shared/core.lua',
    'bridge/qbcore/shared/main.lua',
    'bridge/qbcore/shared/events.lua',
    'bridge/qbox/shared/main.lua',
    'bridge/qbox/shared/events.lua',
    'bridge/qbox/shared/vehicles.lua',
    'bridge/esx/shared/main.lua',
    'bridge/esx/shared/player.lua',
    'bridge/esx/shared/events.lua',
    'bridge/ndcore/shared/main.lua',
    'bridge/ndcore/shared/player.lua',
    'bridge/ndcore/shared/events.lua',
    'bridge/vrp/shared/main.lua',
    'bridge/vrp/shared/player.lua',
    'bridge/vrp/shared/events.lua'
}

client_scripts {
    'client/main.lua',
    'client/functions.lua',
    'client/loops.lua',
    'client/events.lua',
    'client/drawtext.lua',
    'bridge/qbcore/client/main.lua',
    'bridge/qbcore/client/events.lua',
    'bridge/qbox/client/main.lua',
    'bridge/qbox/client/exports.lua',
    'bridge/qbox/client/events.lua',
    'bridge/esx/client/main.lua',
    'bridge/esx/client/events.lua',
    'bridge/ndcore/client/main.lua',
    'bridge/ndcore/client/events.lua',
    'bridge/vrp/client/main.lua',
    'bridge/vrp/client/events.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'bridge/qbcore/server/events.lua',
    'bridge/qbox/server/events.lua',
    'bridge/esx/server/events.lua',
    'bridge/ndcore/server/events.lua',
    'bridge/vrp/server/events.lua',
    'server/functions.lua',
    'server/player.lua',
    'server/events.lua',
    'server/commands.lua',
    'server/exports.lua',
    'server/debug.lua',
    'bridge/qbcore/server/main.lua',
    'bridge/qbox/server/main.lua',
    'bridge/qbox/server/exports.lua',
    'bridge/esx/server/main.lua',
    'bridge/ndcore/server/main.lua',
    'bridge/vrp/server/main.lua'
}

ui_page 'web/ui/index.html'

files {
    'web/ui/index.html',
    'web/css/style.css',
    'web/css/drawtext.css',
    'web/css/quasar.prod.css',
    'web/js/*.js',
    'web/js/vendor/*.js'
}

dependency 'oxmysql'
