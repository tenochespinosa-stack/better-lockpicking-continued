if BetterLockpickingContinued == nil then BetterLockpickingContinued = {} end
if BetterLockpickingContinued.UI == nil then BetterLockpickingContinued.UI = {} end

require "Lockpicking/Options"

if BetterLockpickingContinued.UI._vehicleCompatibilityRegistered then return end
BetterLockpickingContinued.UI._vehicleCompatibilityRegistered = true

function BetterLockpickingContinued.UI.installVehicleMenuCompatibility()
    if BetterLockpickingContinued.UI._vehicleCompatibilityInstalled then return end
    if ISVehicleMenu == nil then return end

    BetterLockpickingContinued.UI._vehicleCompatibilityInstalled = true

    local previousShowRadialMenu = ISVehicleMenu.showRadialMenu
    ISVehicleMenu.showRadialMenu = function(playerObj)
        previousShowRadialMenu(playerObj)
        if not playerObj:getVehicle() then
            BetterLockpickingContinued.UI.addOutsideOptions(playerObj)
        end
    end

    local previousOnHotwire = ISVehicleMenu.onHotwire
    ISVehicleMenu.onHotwire = function(playerObj)
        if BetterLockpickingContinued.Options.isEnabled("hotwire") then
            HotwireWindow:createWindow(playerObj)
        else
            previousOnHotwire(playerObj)
        end
    end

    local previousToggleTrunkLocked = ISVehicleMenu.onToggleTrunkLocked
    ISVehicleMenu.onToggleTrunkLocked = function(playerObj)
        local vehicle = playerObj:getVehicle()
        if not vehicle then return previousToggleTrunkLocked(playerObj) end

        for _, partId in ipairs({ "TrunkDoor", "DoorRear" }) do
            local part = vehicle:getPartById(partId)
            local door = part and part:getDoor() or nil
            if door and door:isLockBroken() then
                playerObj:Say(getText("IGUI_PlayerText_VehicleLockIsBroken"))
                return
            end
        end

        previousToggleTrunkLocked(playerObj)
    end
end

Events.OnGameStart.Add(BetterLockpickingContinued.UI.installVehicleMenuCompatibility)
