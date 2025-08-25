fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Nmil4'
description 'Advanced Crafting System with Weapon Customization'
version '1.0.0'

dependencies {
    'object_gizmo'
}

optional_dependencies {
    'qb-core',
    'qbx_core',
    'ox_inventory',
    'qb-target',
    'ox_target',
    'interact'
}

ui_page 'web/index.html'

shared_scripts {
    'shared/systems.lua',
    'shared/config.lua',
    'shared/weapons.lua'
}

client_scripts {
    'client/camera.lua',
    'client/client_events.lua',
    'client/ui_handlers.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/discord.lua',
    'server/server_events.lua',
    'server/crafting_logic.lua',
    'server/weapon_attachments.lua'
}

files {
	'web/index.html',
	'web/assets/*',
	'config/recipes.lua',
	'config/blueprints.lua',
	'theme.json'
}