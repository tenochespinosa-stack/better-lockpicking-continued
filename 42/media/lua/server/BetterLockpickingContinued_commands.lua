local function BetterLockpickingContinuedVehicleUnlock(module, command, player, args)
    if module ~= 'BetterLockpickingContinuedVehicle' or command ~= 'unlockDoor' or type(args) ~= 'table' then return end

    local vehicle = getVehicleById(args.vehicle)
    if vehicle == nil then return end

    local part = vehicle:getPartById(args.part)
    if part == nil or not part:getDoor() then return end

    local door = part:getDoor()
    door:setLocked(false)
    if args.part == 'TrunkDoor' or args.part == 'DoorRear' then
        vehicle:setTrunkLocked(false)
    end
    if not door:isOpen() then
        door:setOpen(true)
        vehicle:playPartAnim(part, 'Open')
    end
    vehicle:transmitPartDoor(part)
end
Events.OnClientCommand.Add(BetterLockpickingContinuedVehicleUnlock)

local function BetterLockpickingContinuedCheatHotwireSync(module, command, player, args)
    if module ~= "BetterLockpickingContinuedVehicle" or command ~= "cheatHotwire" or type(args) ~= "table" then return end

    local vehicle = getVehicleById(args.vehicle)
    if not vehicle then return end
    if player:getVehicle() ~= vehicle then return end
    if not vehicle:isDriver(player) then return end

    vehicle:cheatHotwire(true, false)
end
Events.OnClientCommand.Add(BetterLockpickingContinuedCheatHotwireSync)
