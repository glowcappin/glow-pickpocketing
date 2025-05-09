fx_version 'cerulean'
game 'gta5'

name 'Glow Pickpocketing'
description 'A configurable pickpocketing script for Mythic and Sandbox Framework'
author 'glowcappin'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/pickpocketing.lua'
}

server_scripts {
    'server/pickpocketing.lua'
}

escrow_ignore {
    'shared/config.lua'
}
