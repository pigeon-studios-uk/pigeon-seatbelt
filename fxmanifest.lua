fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'pigeon-seatbelt'
author 'Pigeon Studios'
description 'Buckle up with a key, or go through the windscreen in a crash, with a warning light and a chime.'
version '1.0.0'
repository 'https://github.com/pigeon-studios-uk/pigeon-seatbelt'

-- Pigeon Studios version registry entry, read by server/version_check.lua.
pigeon_slug 'pigeon-seatbelt'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js',
}

shared_scripts {
    'configuration/config.lua',
    'shared/rules.lua',
}

client_scripts {
    'locales/*.lua',
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
    'server/version_check.lua',
}
