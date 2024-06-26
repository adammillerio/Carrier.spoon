--- === Carrier ===
---
--- Automatically hide apps that are out of focus.
---
--- Download: https://github.com/adammillerio/Spoons/raw/main/Spoons/Carrier.spoon.zip
---
--- This uses a hs.window.filter to detect windows that have gone out of focus. Then,
--- if they are configured to be "swept" in the apps config, they will be automatically
--- hidden if they remain out of focus after sweepCheckInterval (default 15 seconds).
---
--- README with example usage: [README.md](https://github.com/adammillerio/Carrier.spoon/blob/main/README.md)
local Carrier = {}

Carrier.__index = Carrier

-- Metadata
Carrier.name = "Carrier"
Carrier.version = "0.0.3"
Carrier.author = "Adam Miller <adam@adammiller.io>"
Carrier.homepage = "https://github.com/adammillerio/Carrier.spoon"
Carrier.license = "MIT - https://opensource.org/licenses/MIT"

-- Dependency Libraries
local fnutils = require("hs.fnutils")
local timer = require("hs.timer")
local spaces = require("hs.spaces")
local inspect = require("hs.inspect")

-- Dependency Spoons
-- EnsureApp is used for handling app movements when showing/hiding.
EnsureApp = spoon.EnsureApp

--- Carrier.apps
--- Variable
--- Table containing each application's name and it's desired configuration. The
--- key of each entry is the name of the application, and the value is a
--- configuration table with the following entries:
---  * carry - If true, this application will be carried on Space change.
Carrier.apps = nil

--- Carrier.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log
--- level for the messages coming from the Spoon.
Carrier.logger = nil

--- Carrier.logLevel
--- Variable
--- Carrier specific log level override, see hs.logger.setLogLevel for options.
Carrier.logLevel = nil

--- Carrier.spaceWatcher
--- Variable
--- hs.spaces.watcher instance used for monitoring for space changes.
Carrier.spaceWatcher = nil

--- Carrier.carryApps
--- Variable
--- Table containing the name of every app to carry on space change.
Carrier.carryApps = nil

--- Carrier.carryDelay
--- Variable
--- Time in seconds to wait before carrying windows after space change. Default 5 seconds.
Carrier.carryDelay = 5

--- Carrier.carryDelayTimer
--- Variable
--- Any running hs.timer instance for a delayed carry, if enabled.
Carrier.carryDelayTimer = nil

--- Carrier:init()
--- Method
--- Spoon initializer method for Carrier.
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function Carrier:init() self.carryApps = {} end

-- Utility method for having instance specific callbacks.
-- Inputs are the callback fn and any arguments to be applied after the instance
-- reference.
function Carrier:_instanceCallback(callback, ...)
    return fnutils.partial(callback, self, ...)
end

-- Carry all configured apps. This just calls ensureApp on every configured app,
-- disabling focus so they do not show up in front on the new space.
function Carrier:_carryApps()
    self.logger.vf("Carrying apps: %s", inspect(self.carryApps))
    for _, app in ipairs(self.carryApps) do
        self.logger.vf("Carrying app: %s", app)
        -- Disable app focus since we don't want that on carry, same for opening,
        -- we don't want it to keep reopening apps we have closed.
        EnsureApp:ensureApp(app, {skipFocus = true, disableOpen = true})
    end

    if self.carryDelayTimer then
        -- Clear carry timer.
        self.carryDelayTimer:stop()
        self.carryDelayTimer = nil
    end
end

function Carrier:_delayCarryApps()
    self.logger.vf("Carrying apps after delay: %d", self.carryDelay)
    if self.carryDelayTimer then
        self.logger.v("Multiple space changes, cancelling existing timer")
        -- Multiple space changes, reset timer.
        self.carryDelayTimer:stop()
        self.carryDelayTimer = nil
    end

    self.carryDelayTimer = hs.timer.doAfter(self.carryDelay,
                                            self:_instanceCallback(
                                                self._carryApps))
end

--- Carrier:start()
--- Method
--- Spoon start method for Carrier.
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
---
--- Notes:
---  * Configures the window filter, and subscribes to all window unfocus events.
function Carrier:start()
    -- Start logger, this has to be done in start because it relies on config.
    self.logger = hs.logger.new("Carrier")

    if self.logLevel ~= nil then self.logger.setLogLevel(self.logLevel) end

    self.logger.v("Starting Carrier")

    for app, config in pairs(self.apps) do
        -- Build the table of app names to carry (ensure).
        if config.carry then table.insert(self.carryApps, app) end
    end

    -- Set space watcher to call handler on space change.
    self.logger.v("Creating and starting space watcher")
    if self.carryDelay then
        callbackFn = self:_instanceCallback(self._delayCarryApps)
    else
        callbackFn = self:_instanceCallback(self._carryApps)
    end

    self.spaceWatcher = hs.spaces.watcher.new(callbackFn)

    self.spaceWatcher:start()
end

--- Carrier:stop()
--- Method
--- Spoon stop method for Carrier.
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
---
--- Notes:
---  * Unsubscribes the window filter from all subscribed functions.
function Carrier:stop()
    self.logger.v("Stopping Carrier")

    self.logger.v("Stopping space watcher")
    self.spaceWatcher:stop()
end

return Carrier
