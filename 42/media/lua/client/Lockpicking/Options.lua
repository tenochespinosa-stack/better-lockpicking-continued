if BetterLockpickingContinued == nil then BetterLockpickingContinued = {} end

BetterLockpickingContinued.Options = BetterLockpickingContinued.Options or {
    vehicleBobbyPin = true,
    vehicleCrowbar = true,
    buildingBobbyPin = true,
    buildingCrowbar = true,
    windowCrowbar = true,
    hotwire = true,
}

function BetterLockpickingContinued.Options.isEnabled(id)
    return BetterLockpickingContinued.Options[id] ~= false
end

if PZAPI and PZAPI.ModOptions and not BetterLockpickingContinued.Options._registered then
    local options = PZAPI.ModOptions:create("BetterLockpickingContinued", "Better Lockpicking Continued")
    options:addTickBox("vehicleBobbyPin", "Vehicle lockpicking: bobby pin", true, "Show the custom bobby-pin vehicle lockpicking action.")
    options:addTickBox("vehicleCrowbar", "Vehicle lockpicking: crowbar", true, "Show the custom crowbar vehicle lockpicking action.")
    options:addTickBox("buildingBobbyPin", "Building doors: bobby pin", true, "Show the custom bobby-pin building-door lockpicking action.")
    options:addTickBox("buildingCrowbar", "Building doors: crowbar", true, "Show the custom crowbar building-door lockpicking action.")
    options:addTickBox("windowCrowbar", "Windows: crowbar", true, "Show the custom crowbar window-opening action.")
    options:addTickBox("hotwire", "Hotwire minigame", true, "Use the custom hotwire minigame instead of Project Zomboid's normal hotwire action.")

    options.apply = function(self)
        for id, value in pairs(self.dict) do
            if value.type ~= "button" then
                BetterLockpickingContinued.Options[id] = value:getValue()
            end
        end
    end

    BetterLockpickingContinued.Options._registered = true
    Events.OnMainMenuEnter.Add(function()
        options:apply()
    end)
end

return BetterLockpickingContinued.Options
