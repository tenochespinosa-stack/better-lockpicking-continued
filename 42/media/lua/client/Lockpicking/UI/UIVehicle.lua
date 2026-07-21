if BetterLockpickingContinued == nil then BetterLockpickingContinued = {} end
if BetterLockpickingContinued.UI == nil then BetterLockpickingContinued.UI = {} end
require "Lockpicking/Options"
require "Lockpicking/VehicleMenuCompatibility"

-- ПРОВЕРКА ПРОЧНОСТИ ПРЕДМЕТА, ВОЗВРАЩАЕТ "-" ЕСЛИ СЛОМАНО
local function predicateNotBroken(item)
	return not item:isBroken();
end--function
local function predicateCrowbar(item)
	if item:isBroken() then return false end
	local type = item:getType()
	return item:hasTag(ItemTag.CROWBAR) or type == "Crowbar" or type == "CrowbarForged"
end
local function predicateScrewdriver(item)
	if item:isBroken() then return false end
	local type = item:getType()
	return item:hasTag(ItemTag.SCREWDRIVER) or type == "Screwdriver" or type == "Screwdriver_Old" or type == "Screwdriver_Improvised"
end

-- ДОБАВЛЕНИЕ ОПЦИЙ В РАДИАЛЬНОЕ МЕНЮ
function BetterLockpickingContinued.UI.addOutsideOptions(playerObj)

	local endurance = playerObj:getStats():get(CharacterStat.ENDURANCE) -- BetterLockpickingContinued
	--local strength = playerObj:getPerkLevel(Perks.Strength) -- BetterLockpickingContinued

    local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
    if menu == nil then return end

    local vehicle = playerObj:getUseableVehicle()
    if vehicle == nil then return end

    local part = vehicle:getUseablePart(playerObj)
    if part and part:getDoor()then
	
        if part:getDoor():isLocked() then
            if vehicle:getModData().LockpickLevel == nil then
                vehicle:getModData().LockpickLevel = BetterLockpickingContinued.Utils.getLockpickingLevelVehicle(vehicle)
            end

            -- ОПЦИЯ ВЗЛОМА МОНТИРОВКОЙ
			if BetterLockpickingContinued.Options.isEnabled("vehicleCrowbar") then
				local inv = playerObj:getInventory();
				local crowbar = inv:getFirstEvalRecurse(predicateCrowbar);
                if not crowbar then
                    menu:addSlice(getText("ContextMenu_Require", getItemNameFromFullType("Base.Crowbar")), getTexture("media/textures/BetterLockpickingContinued_lockpick_Crowbar_Icon.png"))
                elseif endurance <= 0.5 then
					menu:addSlice(getText("UI_enduranceRequireCar"), getTexture("media/textures/BetterLockpickingContinued_lockpick_Crowbar_Icon.png"))
				else
                    local text = getText("UI_BetterLockpickingContinued_LockpickDoorCrowBar") .. " \n(" .. getText(vehicle:getModData().LockpickLevel.name) .. ")" 
                    menu:addSlice(text, getTexture("media/textures/BetterLockpickingContinued_lockpick_Crowbar_Icon.png"), BetterLockpickingContinued.UI.startLockpickingVehicleDoorCrowbar, playerObj, part)
                end
            end
			
			-- ОПЦИЯ ВЗЛОМА ОТМЫЧКАМИ
			if BetterLockpickingContinued.Options.isEnabled("vehicleBobbyPin") and playerObj:getKnownRecipes():contains("BetterLockpickingContinuedCreateBobbyPin") then
				local inv = playerObj:getInventory();
				local screwdriver = inv:getFirstEvalRecurse(predicateScrewdriver);
				if not (playerObj:getInventory():getFirstTypeRecurse("BetterLockpickingContinuedBobbyPin") or playerObj:getInventory():getFirstTypeRecurse("BetterLockpickingContinuedHandmadeBobbyPin")) then
					menu:addSlice(getText("ContextMenu_Require", getItemNameFromFullType("BetterLockpickingContinued.BetterLockpickingContinuedBobbyPin")), getTexture("media/textures/BetterLockpickingContinued_lockpick_Icon.png"))
				elseif not screwdriver then
					menu:addSlice(getText("ContextMenu_Require", getItemNameFromFullType("Base.Screwdriver")), getTexture("media/textures/BetterLockpickingContinued_lockpick_Icon.png"))
				else
					if part:getDoor():isLockBroken() then
						menu:addSlice(getText("IGUI_PlayerText_VehicleLockIsBroken"), getTexture("media/textures/BetterLockpickingContinued_lockpick_Icon.png"))
					else
						local text = getText("UI_BetterLockpickingContinued_LockpickDoorBobbyPin") .. " \n(" .. getText(vehicle:getModData().LockpickLevel.name) .. ")" 
						menu:addSlice(text, getTexture("media/textures/BetterLockpickingContinued_lockpick_Icon.png"), BetterLockpickingContinued.UI.startLockpickingVehicleDoorBobbyPin, playerObj, part)
					end
				end
			end
        end
    end
end

-- ВЗЛОМ ОТМЫЧКАМИ -- Работает только на базовую отвёртку, для других отвёрток и модовых мультитулов нужно допиливать скрипт.
function BetterLockpickingContinued.UI.startLockpickingVehicleDoorBobbyPin(playerObj, part)
    local vehicle = part:getVehicle()
	local inv = playerObj:getInventory();
    local screwdriverBetterLockpickingContinued = inv:getFirstEvalRecurse(predicateScrewdriver);
	local primaryhand = playerObj:getPrimaryHandItem();
	
	ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, part:getArea()))				-- Поиск пути
    if primaryhand and primaryhand:getType() == "Screwdriver" then												-- Экипировка отвёртки
	 else
		ISInventoryPaneContextMenu.equipWeapon(screwdriverBetterLockpickingContinued, true, false, playerObj:getPlayerNum())
	end
	ISTimedActionQueue.add(EmptyAction:new(playerObj, BobbyPinWindow.createVehicleDoor, nil, playerObj, part))	-- Открытие мини-игры BobbyPinWindow.createVehicleDoor
end

-- ВЗЛОМ МОНТИРОВКОЙ -- Работает на тегирование двуручных монтировок, выставленных вручную в adjuster
function BetterLockpickingContinued.UI.startLockpickingVehicleDoorCrowbar(playerObj, part)
    local vehicle = part:getVehicle()
	local inv = playerObj:getInventory();
	local crowbar = inv:getFirstEvalRecurse(predicateCrowbar);
	
	ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, part:getArea()))				-- Поиск пути
	if not playerObj:isItemInBothHands(crowbar) then															-- Экипировка лома
		ISInventoryPaneContextMenu.equipWeapon(crowbar, true, true, playerObj:getPlayerNum())
	end
	ISTimedActionQueue.add(EmptyAction:new(playerObj, CrowbarWindow.createVehicleDoor, nil, playerObj, part))	-- Открытие мини-игры CrowbarWindow.createVehicleDoor
end
