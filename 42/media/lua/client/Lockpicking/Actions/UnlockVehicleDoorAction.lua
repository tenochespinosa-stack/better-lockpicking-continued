require "TimedActions/ISBaseTimedAction"

UnlockVehicleDoorAction = ISBaseTimedAction:derive("UnlockVehicleDoorAction")

function UnlockVehicleDoorAction:isValid()
    return self.part and self.part:getDoor() and (self.forceValid or self.part:getDoor():isLocked())
end

local function isTrunkDoor(part)
    if part == nil then return false end
    local id = part:getId()
    return id == "TrunkDoor" or id == "DoorRear"
end

local function selectTrunkContainer(vehicle, part, character)
    if isServer() or not isTrunkDoor(part) then return end
    local truckBed = vehicle:getPartById("TruckBed")
    if truckBed == nil or truckBed:getItemContainer() == nil then return end
    if not vehicle:canAccessContainer(truckBed:getIndex(), character) then return end

    local loot = getPlayerLoot(character:getPlayerNum())
    loot:setForceSelectedContainer(truckBed:getItemContainer(), 100)
    loot:setVisible(true)
    loot.collapseCounter = 0
    if loot.isCollapsed then
        loot.isCollapsed = false
        loot:clearMaxDrawHeight()
        loot.collapseCounter = -30
    end
end

function UnlockVehicleDoorAction.unlock(character, part)
    if part == nil or not part:getDoor() then
        return false
    end

    local vehicle = part:getVehicle()
    if vehicle == nil then
        return false
    end

    if isClient() then
        sendClientCommand(character, 'BetterLockpickingContinuedVehicle', 'unlockDoor', {
            vehicle = vehicle:getId(),
            part = part:getId(),
        })
        return true
    end

    local door = part:getDoor()
    door:setLocked(false)
    if isTrunkDoor(part) then
        vehicle:setTrunkLocked(false)
    end
    if not door:isOpen() then
        door:setOpen(true)
        vehicle:playPartAnim(part, "Open")
    end
    vehicle:transmitPartDoor(part)
    triggerEvent("OnContainerUpdate")
    selectTrunkContainer(vehicle, part, character)
    return not door:isLocked()
end

function UnlockVehicleDoorAction:complete()
    return UnlockVehicleDoorAction.unlock(self.character, self.part)
end

function UnlockVehicleDoorAction:perform()
    ISBaseTimedAction.perform(self)
end

function UnlockVehicleDoorAction:new(character, part)
    local o = ISBaseTimedAction.new(self, character)
    o.part = part
    o.vehicle = part and part:getVehicle() or nil
    o.stopOnWalk = false
    o.stopOnRun = false
    o.forceValid = true
    o.maxTime = 1
    return o
end
