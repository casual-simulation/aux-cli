# Development Setup

## First Time Setup

Currently, auxcli has only been tested on a Raspberry Pi 3B+/4, so you will need one of those devices. 

1. Clone the repository to the computer you're working on.
    - `git clone https://github.com/casual-simulation/aux-cli.git`
                 

# Commands
    All commands need to have an entry made in /etc/auxcli/commands.json Preferrably added alphabetically like they appear in file structure. If the command has any flags/arguments/options available, it will need a config.json file. You can copy an existing command as a template so it will generate the usage for you.
    # CORE
        Core commands should work out-of-the-box, only using basic linux/raspbian tools, or auxcli helpers.
        They are supposed to be called directly, like `auxcli conf`
    # HELPER
        Helper commands should work out-of-the-box, only using basic linux/raspbian tools or other auxcli helpers.
        They are supposed to be used mainly inside other auxcli commands/services to reduce code duplication.
    # ADDITIONAL
        Additional commands only become available by installing extra components through auxcli.

# Components
    All components need to have an entry made in /etc/auxcli/components.json Preferrably added alphabetically like they appear in file structure.
    # CONFIGURATION
        Configuration components are dependencies that are system settings and not something you install, but enable/disable.
        Some settings need to be changed for hardware support, or for additional command support.
    # HARDWARE
        Hardware components are dependencies required to install specifically for a piece of external hardware, like for an NFC reader/writer, or a motion sensor.
    # TOOL
        Tool components are dependencies required to make additional commands available.

# Services
    Some aspects of auxcli will require a service to be made. If you need to have something run at boot/in the background/etc, try to make it a service instead of using crontab/cron. Prefix all services wtih "auxcli-". Services will all go into the `/etc/systemd/system` directory and if they run a script, that script will generally go in the `/lib/auxcli/commands/helper` directory or `/srv/www` directory.

## AUXCLI Service Order
    This is the current order in which services get called. 
    network.target
    auxcli-reboot-reset
        auxcli-wlan-checker
        auxcli-dnsmasq-checker
        auxcli-wpa-checker
        auxcli-hotspot-checker
    auxcli-first-boot
    auxcli-web
        auxcli-bt-serial-scan
        auxcli-bt-tether

# casualOS
    If you want to add/create a tool to interact with casualOS in some way, you will need to get that setup as well. There are developer instructions over on it's github page: https://github.com/casual-simulation/casualos.git

## casualOS Files to Touch
    AuxLibrary.spec.ts
    AuxLibrary.ts
    AuxLibraryDefinitions.def
    actions.mdx
    BotEvents.ts
    SerialModule.ts (as an example, make your own)
    package-lock.json
    package.json
    server.ts
