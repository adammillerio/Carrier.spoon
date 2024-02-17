# Carrier.spoon
Hammerspoon - Carry a set of apps between Spaces.

This uses a hs.spaces.watcher to detect space changes. Then it will automatically "carry" any applications which are configured to the new Space, so that they are available in Mission Control/AltTAb.

# Installation

This Spoon depends on two other Spoons being installed, loaded, and configured:
* [EnsureApp](https://github.com/adammillerio/EnsureApp.spoon).
    * Example app configurations provided below
* [WindowCache](https://github.com/adammillerio/WindowCache.spoon)
    * No configuration needed other than start

## Automated

Carrier can be automatically installed from my [Spoon Repository](https://github.com/adammillerio/Spoons) via [SpoonInstall](https://www.hammerspoon.org/Spoons/SpoonInstall.html). See the repository README or the SpoonInstall docs for more information.

Example `init.lua` configuration which configures `SpoonInstall` and uses it to install and start Carrier:

```lua
hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.repos.adammillerio = {
    url = "https://github.com/adammillerio/Spoons",
    desc = "adammillerio Personal Spoon repository",
    branch = "main"
}

spoon.SpoonInstall:andUse("WindowCache", {repo = "adammillerio", start = true})

spoon.SpoonInstall:andUse("EnsureApp", {
    repo = "adammillerio",
    start = true,
    config = {
        apps = {
            ["Discord"] = {app = "Discord", action = "maximize"},
            ["Reminders"] = {app = "Reminders", action = "move"}
        }
    }
})

spoon.SpoonInstall:andUse("Carrier", {
    repo = "adammillerio",
    start = true,
    config = {
        carryDelay = 10,
        apps = {
            ["Discord"] = {carry = true},
            ["Reminders"] = {carry = true}
        }
    }
}
```

Now, the Discord and Reminders applications will be moved to the current Space whenever it is changed after a delay of 10 seconds. The apps are not focused so they will be behind whatever application was focused last in the Space. The default `carryDelay` is 5 seconds.

## Manual

Download the latest WindowCache release from [here.](https://github.com/adammillerio/Spoons/raw/main/Spoons/WindowCache.spoon.zip)

Download the latest EnsureApp release from [here.](https://github.com/adammillerio/Spoons/raw/main/Spoons/EnsureApp.spoon.zip)

Unzip them all and either double click to load the Spoons or place the contents manually in `~/.hammerspoon/Spoons`

Then load the Spoons in `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("WindowCache")

hs.spoons.use("WindowCache", {start = true})

hs.loadSpoon("EnsureApp")

hs.spoons.use("EnsureApp", {
    config = {
        apps = {
            ["Discord"] = {app = "Discord", action = "maximize"},
            ["Reminders"] = {app = "Reminders", action = "maximize"}
        }
    },
    start = true
})

hs.loadSpoon("Carrier")

hs.spoons.use("Carrier", {
    start = true,
    config = {
        carryDelay = 10,
        apps = {
            ["Discord"] = {carry = true},
            ["Reminders"] = {carry = true}
        }
    }
})
```

# Usage

Refer to the [hosted documentation](https://adammiller.io/Spoons/Carrier.html) for information on usage.
