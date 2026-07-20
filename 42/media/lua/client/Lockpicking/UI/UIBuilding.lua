if BetterLockpickingContinued == nil then BetterLockpickingContinued = {} end
if BetterLockpickingContinued.UI == nil then BetterLockpickingContinued.UI = {} end
require "Lockpicking/Options"

--[[
not should be ToolsOfTheTrade.UtilityBar - это одноручный гвоздодёр


:getFirstTagRecurse("StartFire")
:getFirstTagEvalRecurse	("Hammer", predicateNotBroken)

:getFirstTypeRecurse	("Base.Gravelbag")
:getFirstTypeEvalRecurse("Base.PropaneTank", predicateNotEmpty)


// FOR BODYPIN AND HANDMADE BODYPIN
local BetterLockpickingContinuedBobbyPin = playerInv:getFirstTypeRecurse("BetterLockpickingContinuedHandmadeBobbyPin")
	if not BetterLockpickingContinuedBobbyPin then
		BetterLockpickingContinuedBobbyPin = playerInv:getFirstTypeRecurse("BetterLockpickingContinuedBobbyPin")
	end
	
item:isTwoHandWeapon();
]]--

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

-- ВЗЛОМ ДВЕРИ ОТМЫЧКАМИ
function BetterLockpickingContinued.UI.goToDoorBobbyPin(playerObj, door, goToOpen)
    local sq = door:getSquare()
    if door:getOppositeSquare():DistTo(playerObj:getSquare()) < door:getSquare():DistTo(playerObj:getSquare()) then
        sq = door:getOppositeSquare()
    end
	
	local inv = playerObj:getInventory();
    local screwdriver = inv:getFirstEvalRecurse(predicateScrewdriver);
    if playerObj:getSecondaryHandItem() and playerObj:getSecondaryHandItem() ~= playerObj:getPrimaryHandItem() then
        ISTimedActionQueue.add(ISUnequipAction:new(playerObj, playerObj:getSecondaryHandItem(), 50));
    end
	ISInventoryPaneContextMenu.equipWeapon(screwdriver, true, false, playerObj:getPlayerNum());
	
    ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, sq));
    ISTimedActionQueue.add(EmptyAction:new(playerObj, BobbyPinWindow.createBuildingDoor, nil, playerObj, door, goToOpen))
end

-- ВЗЛОМ ДВЕРИ МОНТИРОВКОЙ
function BetterLockpickingContinued.UI.goToDoorCrowbar(playerObj, door)
    local sq = door:getSquare()
    if door:getOppositeSquare():DistTo(playerObj:getSquare()) < door:getSquare():DistTo(playerObj:getSquare()) then
        sq = door:getOppositeSquare()
    end

	local inv = playerObj:getInventory();
	local crowbar = inv:getFirstEvalRecurse(predicateCrowbar);
	ISInventoryPaneContextMenu.equipWeapon(crowbar, true, true, playerObj:getPlayerNum());
	ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, sq));
    ISTimedActionQueue.add(EmptyAction:new(playerObj, CrowbarWindow.createBuildingDoor, nil, playerObj, door))
end

-- ВЗЛОМ ОКНА МОНТИРОВКОЙ
function BetterLockpickingContinued.UI.goToWindowCrowbar(playerObj, window)
    local sq = window:getSquare()
    if window:getOppositeSquare():DistTo(playerObj:getSquare()) < window:getSquare():DistTo(playerObj:getSquare()) then
        sq = window:getOppositeSquare()
    end

	local inv = playerObj:getInventory();
	local crowbar = inv:getFirstEvalRecurse(predicateCrowbar);
	ISInventoryPaneContextMenu.equipWeapon(crowbar, true, true, playerObj:getPlayerNum());
    ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, sq));
    ISTimedActionQueue.add(EmptyAction:new(playerObj, CrowbarWindow.createBuildingWindow, nil, playerObj, window))
end



-- КОНТЕКСТОЕ МЕНЮ ДЛЯ ДВЕРИ / ОКНА
function BetterLockpickingContinued.UI.contextMenuOptions(player, context, worldobjects, test)
    local playerObj = getSpecificPlayer(player)
    local playerSkill = playerObj:getPerkLevel(Perks.Nimble)
	local playerStrength = playerObj:getPerkLevel(Perks.Strength) -- BetterLockpickingContinued
    local window = nil
    local door = nil
	local endurance = playerObj:getStats():get(CharacterStat.ENDURANCE) -- BetterLockpickingContinued

	for _,obj in ipairs(worldobjects) do
        if instanceof(obj, "IsoDoor") or (instanceof(obj, "IsoThumpable") and obj:isDoor()) then
            door = obj
        elseif instanceof(obj, "IsoWindow") then
            window = obj
        end
    end

    if door and not BetterLockpickingContinued.Options.isEnabled("buildingBobbyPin") and not BetterLockpickingContinued.Options.isEnabled("buildingCrowbar") then return end
    if window and not BetterLockpickingContinued.Options.isEnabled("windowCrowbar") then return end
    
    if door then
        if door:getModData().LockpickLevel == nil then
            door:getModData().LockpickLevel = BetterLockpickingContinued.Utils.getLockpickLevelBuildingObj(door)
        end
		
		local lockpickingMenuOption = context:addOption(getText("UI_Lockpick"))
		local subMenuLockpicking = context:getNew(context)
        context:addSubMenu(lockpickingMenuOption, subMenuLockpicking)
		
-- СУБМЕНЮ ВЗЛОМА ОТМЫЧКАМИ
		if BetterLockpickingContinued.Options.isEnabled("buildingBobbyPin") and playerObj:getKnownRecipes():contains("BetterLockpickingContinuedCreateBobbyPin") then
            local option = subMenuLockpicking:addOption(getText("UI_Lockpick_bobbypin"), playerObj, BetterLockpickingContinued.UI.goToDoorBobbyPin, door, true)
            option.toolTip = ISToolTip:new();
            option.toolTip:initialise();
            option.toolTip:setVisible(false);
            option.toolTip:setName(getText(door:getModData().LockpickLevel.name))

            local color
            if playerSkill >= door:getModData().LockpickLevel.num then
                color = " <RGB:1,1,1> "
            else
                color = " <RGB:0.9,0.5,0> "
            end
            option.toolTip.description = color .. getText("Tooltip_vehicle_recommendedSkill", playerSkill .. "/" .. door:getModData().LockpickLevel.num, "") .. " <LINE> "

            if not (playerObj:getInventory():getFirstTypeRecurse("BetterLockpickingContinuedBobbyPin") or playerObj:getInventory():getFirstTypeRecurse("BetterLockpickingContinuedHandmadeBobbyPin")) then
                color = " <RGB:0.9,0,0> "
                option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("BetterLockpickingContinued.BetterLockpickingContinuedBobbyPin")) .. " <LINE> "
                option.notAvailable = true
            end
-- ДВЕРЬ, КОНТЕКСТНОЕ МЕНЮ, ПРОВЕРКА ОТВЁРТКИ В ИНВЕНТАРЕ, ПОПЫТКИ...
			local inv = playerObj:getInventory();
			local screwdriver = inv:getFirstEvalRecurse(predicateScrewdriver);	--BetterLockpickingContinuedScrew
            if not screwdriver then
                color = " <RGB:0.9,0,0> "
                option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Screwdriver")) .. " <LINE> "
                option.notAvailable = true
            end

            if door:getKeyId() == -3 then
                color = " <RGB:0.9,0,0> "
                option.toolTip.description = option.toolTip.description .. color .. getText("IGUI_LockBroken")
                option.notAvailable = true
            end
        end
		
-- СУБМЕНЮ ВЗЛОМА ЛОМОМ
		if BetterLockpickingContinued.Options.isEnabled("buildingCrowbar") then
		context:addSubMenu(lockpickingMenuOption, subMenuLockpicking)
		local option = subMenuLockpicking:addOption(getText("UI_Lockpick_crowbar"), playerObj, BetterLockpickingContinued.UI.goToDoorCrowbar, door)
		option.toolTip = ISToolTip:new()
		option.toolTip:initialise()
		option.toolTip:setVisible(false)
		option.toolTip:setName(getText(door:getModData().LockpickLevel.name))

		local color
		if playerStrength >= door:getModData().LockpickLevel.num then
			color = " <RGB:1,1,1> "
		else
			color = " <RGB:0.9,0.5,0> "
		end
		option.toolTip.description = color .. getText("Tooltip_vehicle_recommendedSkill", playerStrength .. "/" .. door:getModData().LockpickLevel.num, "") .. " <LINE> "

-- ДВЕРЬ, КОНТЕКСТНОЕ МЕНЮ, ПРОВЕРКА ЛОМА В ИНВЕНТАРЕ, ПОПЫТКИ...
		local inv = playerObj:getInventory();
		local crowbarinv = inv:getFirstEvalRecurse(predicateCrowbar);
		if not crowbarinv then
			color = " <RGB:0.9,0,0> "
			option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Crowbar")) .. " <LINE> "
			option.notAvailable = true
		end
		if endurance <= 0.5 then
			color = " <RGB:0.9,0,0> "
			option.toolTip.description = option.toolTip.description .. color .. getText("UI_enduranceRequire") .. " <LINE> "
			option.notAvailable = true
		end
		end
    elseif window then
        if window:getModData().LockpickLevel == nil then
            window:getModData().LockpickLevel = BetterLockpickingContinued.Utils.getLockpickLevelBuildingObj(window)
        end

        if not window:isPermaLocked() then
            local lockpickingMenuOption = context:addOption(getText("UI_Lockpick"))
            local subMenuLockpicking = context:getNew(context)
            context:addSubMenu(lockpickingMenuOption, subMenuLockpicking)

            local option = subMenuLockpicking:addOption(getText("UI_Lockpick_crowbar"), playerObj, BetterLockpickingContinued.UI.goToWindowCrowbar, window)
            option.toolTip = ISToolTip:new()
            option.toolTip:initialise()
            option.toolTip:setVisible(false)
            option.toolTip:setName(getText(window:getModData().LockpickLevel.name))

            local color
            if playerStrength >= window:getModData().LockpickLevel.num then
                color = " <RGB:1,1,1> "
            else
                color = " <RGB:0.9,0.5,0> "
            end
            option.toolTip.description = color .. getText("Tooltip_vehicle_recommendedSkill", playerStrength .. "/" .. window:getModData().LockpickLevel.num, "") .. " <LINE> "

            option.toolTip.description = option.toolTip.description .. " <RGB:1,1,1> " .. getText("UI_chance_break_window") .. BetterLockpickingContinued.Utils.getChanceBreakLock(playerSkill, window:getModData().LockpickLevel.num) .. "%" .. " <LINE> "
			
			local inv = playerObj:getInventory();	--try
			local crowbarinv = inv:getFirstEvalRecurse(predicateCrowbar);-- try
            if not crowbarinv then
                color = " <RGB:0.9,0,0> "
                option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Crowbar")) .. " <LINE> "
                option.notAvailable = true
            end
			--- BetterLockpickingContinued
			if endurance <= 0.5 then
			    color = " <RGB:0.9,0,0> "
                option.toolTip.description = option.toolTip.description .. color .. getText("UI_enduranceRequire") .. " <LINE> "
                option.notAvailable = true
            end
        end
    else
    end
end

Events.OnFillWorldObjectContextMenu.Add(BetterLockpickingContinued.UI.contextMenuOptions);
