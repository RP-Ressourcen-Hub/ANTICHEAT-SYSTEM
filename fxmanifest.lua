fx_version 'cerulean'
game 'gta5'

name 'Advanced AntiCheat'
author 'Your Server'
version '1.0.0'
description 'Fortschrittliches Anticheat-System für FiveM'

shared_scripts {
    'config/config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

dependencies {
    '/onesync',
    '[standalone]/[framework_bridge]',
    '[standalone]/[discordlogs]'
}