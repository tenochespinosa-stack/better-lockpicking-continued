--[[
:getFirstTagRecurse("StartFire")
:getFirstTagEvalRecurse	("Hammer", predicateNotBroken)

:getFirstTypeRecurse	("Base.Gravelbag")
:getFirstTypeEvalRecurse("Base.PropaneTank", predicateNotEmpty)


// FOR BODYPIN AND HANDMADE BODYPIN
local bodipin = playerInv:getFirstTypeRecurse("BODYPIN")
	if not bodipin then
		bodypin = playerInv:getFirstTypeRecurse("BODYPIN2")
	end
]]--

-- ПРОВЕРКА ПРОЧНОСТИ ПРЕДМЕТА, ВОЗВРАЩАЕТ "-" ЕСЛИ СЛОМАНО
local function predicateCrowbar(item)
	if item:isBroken() then return false end
	local type = item:getType()
	return item:hasTag(ItemTag.CROWBAR) or type == "Crowbar" or type == "CrowbarForged"
end


require "Lockpicking/Utils"
require "Lockpicking/Actions/UnlockVehicleDoorAction"

CrowbarWindow = ISPanel:derive("CrowbarWindow");

local WINDOW_WIDTH = 340
local WINDOW_HEIGHT = 150
----
local greenSize = 10
local yellowSize = 40
local shiftYellow = 90
local shiftGreen = 135
----
local xShift = 20
local yShift = 40

local MODE_VEHICLE_DOOR = 0
local MODE_WINDOW = 1
local MODE_BUILDING_DOOR = 2

local arrowTex = getTexture("media/textures/BetterLockpickingContinued_arrow.png") --
local arrow_scale_step = 0
local arrowSpeed = 1
local arrow_dx = arrowSpeed
local arrow_step_to_x = (WINDOW_WIDTH - xShift*2)/100

local crowbarTimer = 0
local progressBarVal = 0

--------------

function CrowbarWindow:setVisible(visible)
    self.javaObject:setVisible(visible);
end

function CrowbarWindow:prerender()
    ISPanel.prerender(self)

    self:drawRect(xShift, yShift + 30, WINDOW_WIDTH - xShift*2, 20, 0.8, 1, 0, 0)
    self:drawRect(xShift + shiftYellow, yShift + 30, yellowSize*3, 20, 0.8, 1, 1, 0)
    self:drawRect(xShift + shiftGreen, yShift + 30, greenSize*3, 20, 0.8, 0, 1, 0)
    self:drawRectBorder(xShift, yShift + 30, WINDOW_WIDTH - xShift*2, 20, 1, 0.4, 0.4, 0.4)
end

local lastRenderMillis = nil
function CrowbarWindow:render()
    self:drawText(getText("UI_Controls_Crowbar"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Small, getText("UI_Controls_Crowbar")) / 2), 10, 1,1,1,1, UIFont.Small);

    self:drawProgressBar(xShift, yShift, WINDOW_WIDTH - xShift*2, 20, progressBarVal, {r=0, g=0.6, b=0, a=0.8 })
    self:drawRectBorder(xShift, yShift, WINDOW_WIDTH - xShift*2, 20, 1, 0.4, 0.4, 0.4)

    self:drawTexture(arrowTex, xShift - arrowTex:getWidth()/2 + arrow_scale_step*arrow_step_to_x, 75+30, 1, 1, 1, 1)
    
	
    local currentMillis = math.floor(getTimeInMillis())
	
    local isNewTimeStep = false
    if lastRenderMillis ~= currentMillis then
        lastRenderMillis = currentMillis
        isNewTimeStep = true
    end


    if crowbarTimer > 0 then return end
	
	local endurance = self.character:getStats():get(CharacterStat.ENDURANCE)
	--- BetterLockpickingContinued anti-abuze system
	if endurance <= 0.5 then
        self:close()			--CrowbarWindow.instance:close()
		return
    end---
	
    if isNewTimeStep then
        -- arrow_scale_step = arrow_scale_step + arrow_dx
		arrow_scale_step = arrow_scale_step + arrow_dx * UIManager.getMillisSinceLastRender() * 0.12 -- Thanks to Albion!  * UIManager.getMillisSinceLastRender()
        if arrow_scale_step >= 100 then
            arrow_scale_step = 100
            arrow_dx = -arrowSpeed
        elseif arrow_scale_step <= 0 then
            arrow_scale_step = 0
            arrow_dx = arrowSpeed
        end
    end
end

function CrowbarWindow:onOptionMouseDown(button, x, y)
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager();
        self:close()
    end
end

function CrowbarWindow:doUnlock()
	if self.mode == MODE_VEHICLE_DOOR then	-- ДВЕРЬ МАШИНЫ
		UnlockVehicleDoorAction.unlock(self.character, self.lockpick_object)
		self:setVisible(false)
		self:removeFromUIManager()
		self:close()
        self.character:getEmitter():playSound("UnlockDoor");
    elseif self.mode == MODE_WINDOW then	-- ОКНО
        self.lockpick_object:setIsLocked(false)
		self.lockpick_object:setPermaLocked(false)
        local skill = self.character:getPerkLevel(Perks.Nimble)
        local level = self.lockpick_object:getModData().LockpickLevel.num
        local chanceBreak = BetterLockpickingContinued.Utils.getChanceBreakLock(skill, level)

        if ZombRand(100) < chanceBreak then
            self.lockpick_object:Damage(100)
        end
    else																						-- ДВЕРЬ
        self.lockpick_object:setLockedByKey(false);
        self.lockpick_object:setKeyId(-3);
        self.lockpick_object:Damage(50)

        if BetterLockpickingContinued.Utils.isGarageDoor(self.lockpick_object) then							-- ГАРАЖНАЯ ДВЕРЬ
            local doorPrev = BetterLockpickingContinued.Utils.getGarageDoorPrev(self.lockpick_object)
            while doorPrev ~= nil do
                doorPrev:setLockedByKey(false);
                doorPrev = BetterLockpickingContinued.Utils.getGarageDoorPrev(doorPrev)
            end
    
            local doorNext = BetterLockpickingContinued.Utils.getGarageDoorNext(self.lockpick_object)
            while doorNext ~= nil do
                doorNext:setLockedByKey(false);
                doorNext = BetterLockpickingContinued.Utils.getGarageDoorNext(doorNext)
            end
        end

        self.character:getEmitter():playSound("UnlockDoor");
    end
    --self.character:getXp():AddXP(Perks.Nimble, self.addingXP/2);
end

function CrowbarWindow:close()
	self.character:getModData().BetterLockpickingContinuedStopFlag = 1
	
    self.lockpick_object:getModData()["BetterLockpickingContinued_crowbarProgressBar"] = progressBarVal

	--[[
    getCore():addKeyBinding("Left", self.character:getModData()["Lockpick_Left"])
    self.character:getModData()["Lockpick_Left"] = nil
    getCore():addKeyBinding("Right", self.character:getModData()["Lockpick_Right"])
    self.character:getModData()["Lockpick_Right"] = nil
    getCore():addKeyBinding("Forward", self.character:getModData()["Lockpick_Forward"])
    self.character:getModData()["Lockpick_Forward"] = nil
    getCore():addKeyBinding("Backward", self.character:getModData()["Lockpick_Backward"])
    self.character:getModData()["Lockpick_Backward"] = nil
    getCore():addKeyBinding("Melee", self.character:getModData()["Lockpick_Melee"])
    self.character:getModData()["Lockpick_Melee"] = nil
    ]]
	self.character:setBlockMovement(false)
	self.character:setIgnoreAimingInput(false)
	self.character:setBannedAttacking(false)
	
    ISTimedActionQueue.clear(self.character)	-- проигрывает стоп
    CrowbarWindow.instance = nil
    ISPanel.close(self)
end

--------------------------
-- Creating window
--------------------------

function CrowbarWindow:createVehicleDoor(playerObj, part)
    local modal = CrowbarWindow:new(Core:getInstance():getScreenWidth()/2 - WINDOW_WIDTH/2 + 300, Core:getInstance():getScreenHeight()/2 - 500/2, WINDOW_WIDTH, WINDOW_HEIGHT)
    modal.lockpick_object = part
    modal.mode = MODE_VEHICLE_DOOR
    modal.character = playerObj
    modal.diffLevel = part:getVehicle():getModData().LockpickLevel.num
    modal.addingXP = part:getVehicle():getModData().LockpickLevel.xp
    modal.isGarage = false

    modal:initialise()
    modal:addToUIManager()
end

function CrowbarWindow:createBuildingWindow(playerObj, window)
    local dx = window:getSquare():getX() - playerObj:getSquare():getX()
    local dy = window:getSquare():getY() - playerObj:getSquare():getY()
    local zGood = math.abs(window:getSquare():getZ() - playerObj:getSquare():getZ()) < 2
    local dist = math.sqrt(dx*dx + dy*dy)
    
    
    if not zGood or dist > 2 then 
        return
    end

    if not window:isLocked() then
        playerObj:Say(getText("UI_window_is_unlocked"))
        return
    end
    
    local modal = CrowbarWindow:new(Core:getInstance():getScreenWidth()/2 - WINDOW_WIDTH/2 + 300, Core:getInstance():getScreenHeight()/2 - 500/2, WINDOW_WIDTH, WINDOW_HEIGHT)

    modal.lockpick_object = window
    modal.mode = MODE_WINDOW
    modal.character = playerObj
    modal.diffLevel = window:getModData().LockpickLevel.num
    modal.addingXP = window:getModData().LockpickLevel.xp
    modal.isGarage = false

    playerObj:faceThisObject(window)

    modal:initialise()
    modal:addToUIManager()
end

function CrowbarWindow:createBuildingDoor(playerObj, door)
    local dx = door:getSquare():getX() - playerObj:getSquare():getX()
    local dy = door:getSquare():getY() - playerObj:getSquare():getY()
    local zGood = math.abs(door:getSquare():getZ() - playerObj:getSquare():getZ()) < 2
    local dist = math.sqrt(dx*dx + dy*dy)
    
    if not zGood or dist > 2 then 
        return
    end

    if not door:isLocked() then
        playerObj:Say(getText("UI_door_is_unlocked"))
        return
    end
	
	local spriteName = door:getSprite():getName()		-- RESTRICTION REINFORCED DOORS
    if  spriteName and 
        spriteName == "fixtures_doors_01_32"               or 
        spriteName == "fixtures_doors_01_33"               or
        spriteName == "location_community_police_01_4"     or
        spriteName == "location_community_police_01_5"     then 

        playerObj:Say(getText("IGUI_BetterLockpickingContinuedIsReinforced")) 
		return
    end  
	
    local modal = CrowbarWindow:new(Core:getInstance():getScreenWidth()/2 - WINDOW_WIDTH/2 + 300, Core:getInstance():getScreenHeight()/2 - 500/2, WINDOW_WIDTH, WINDOW_HEIGHT)
    modal.lockpick_object = door
    modal.mode = MODE_BUILDING_DOOR
    modal.character = playerObj
    modal.addingXP = door:getModData().LockpickLevel.xp
    modal.diffLevel = door:getModData().LockpickLevel.num
    modal.isGarage = BetterLockpickingContinued.Utils.isGarageDoor(door)

    playerObj:faceThisObject(door)

    modal:initialise()
    modal:addToUIManager()
end


function CrowbarWindow:initialise()
    if not self.character:getInventory():getFirstEvalRecurse(predicateCrowbar) then 
        return
    end

    ISPanel.initialise(self);
    self:create();
    CrowbarWindow.instance = self

	local BetterLockpickingContinuedStrength = self.character:getPerkLevel(Perks.Strength)
	if BetterLockpickingContinuedStrength <= 3 then -- c 1 по 3 силу 0 навыка
			skill = 0
		else
			skill = BetterLockpickingContinuedStrength - 3
	end
	if skill < 0 then skill = 0 end
	
    local sizes = BetterLockpickingContinued.Utils.getGreenYellowSize(skill, self.diffLevel)
    greenSize = sizes[1]
    yellowSize = sizes[2]

    shiftGreen = ZombRand(100-greenSize)*3
    shiftYellow = ZombRand(100-yellowSize)*3 
    --
    progressBarVal = self.lockpick_object:getModData()["BetterLockpickingContinued_crowbarProgressBar"]
    if progressBarVal == nil then
        progressBarVal = 0
    end
    --
	
	--[[
    self.character:getModData()["Lockpick_Left"] = getCore():getKey("Left")
    getCore():addKeyBinding("Left", nil)
    self.character:getModData()["Lockpick_Right"] = getCore():getKey("Right")
    getCore():addKeyBinding("Right", nil)
    self.character:getModData()["Lockpick_Forward"] = getCore():getKey("Forward")
    getCore():addKeyBinding("Forward", nil)
    self.character:getModData()["Lockpick_Backward"] = getCore():getKey("Backward")
    getCore():addKeyBinding("Backward", nil)
    self.character:getModData()["Lockpick_Melee"] = getCore():getKey("Melee")
    getCore():addKeyBinding("Melee", nil)
	]]
	self.character:setBlockMovement(true)
	self.character:setIgnoreAimingInput(true)
	self.character:setBannedAttacking(true)
	
    ISTimedActionQueue.clear(self.character)
    ISTimedActionQueue.add(CrowbarActionAnim:new(self.character, self.isGarage, self.lockpick_object))
end

function CrowbarWindow:create()
    self.cancel = ISButton:new((self:getWidth() / 2) - 50, self:getHeight() - 25, 100, 20, getText("UI_Cancel"), self, CrowbarWindow.onOptionMouseDown);
    self.cancel.internal = "CANCEL";
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.cancel);
end


function CrowbarWindow:new(x, y, width, height)
    local o = {};
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};

    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    o:setWantKeyEvents(true)
    return o;
end

function CrowbarWindow:ActionKeyPressed()

    local BetterLockpickingContinuedSkillStrength = self.character:getPerkLevel(Perks.Strength)
	local BetterLockpickingContinuedSkillFitness = self.character:getPerkLevel(Perks.Fitness)
	local BetterLockpickingContinuedSkillLockpicking = self.character:getPerkLevel(Perks.Nimble)
    local enduranceLevel = self.character:getStats():get(CharacterStat.ENDURANCE)
	
-- ПОПРАВКА МОЩНОСТИ И ТРАТЫ СТАМИНЫ ОТ НАВЫКА ВЗЛОМА
	local BetterLockpickingContinuedLPSTR_1 = 1
	local BetterLockpickingContinuedLPSTR_2 = 0
	local BetterLockpickingContinuedLPSTR_3 = 0
	local BetterLockpickingContinuedLPFIT = 0
	if BetterLockpickingContinuedSkillLockpicking <= 1 then
		BetterLockpickingContinuedLPSTR_1 = 1
		BetterLockpickingContinuedLPSTR_2 = 0
		BetterLockpickingContinuedLPSTR_3 = 0
		BetterLockpickingContinuedLPFIT = 0
	 elseif BetterLockpickingContinuedSkillLockpicking <= 4 then
		BetterLockpickingContinuedLPSTR_1 = 2
		BetterLockpickingContinuedLPSTR_2 = 1
		BetterLockpickingContinuedLPSTR_3 = 0
		BetterLockpickingContinuedLPFIT = 0.15
	 elseif BetterLockpickingContinuedSkillLockpicking == 5 then
		BetterLockpickingContinuedLPSTR_1 = 3
		BetterLockpickingContinuedLPSTR_2 = 2
		BetterLockpickingContinuedLPSTR_3 = 1
		BetterLockpickingContinuedLPFIT = 0.25
	 elseif BetterLockpickingContinuedSkillLockpicking <= 8 then
		BetterLockpickingContinuedLPSTR_1 = 4
		BetterLockpickingContinuedLPSTR_2 = 3
		BetterLockpickingContinuedLPSTR_3 = 2
		BetterLockpickingContinuedLPFIT = 0.35
	 else		-- BetterLockpickingContinuedSkillLockpicking <=10 then
		BetterLockpickingContinuedLPSTR_1 = 5
		BetterLockpickingContinuedLPSTR_2 = 4
		BetterLockpickingContinuedLPSTR_3 = 3
		BetterLockpickingContinuedLPFIT = 0.5
	end
	
	local BetterLockpickingContinuedSTR_1 = 9
	local BetterLockpickingContinuedSTR_2 = 6
	local BetterLockpickingContinuedSTR_3 = 4
	if BetterLockpickingContinuedSkillStrength <= 1 then
		BetterLockpickingContinuedSTR_1 = 9
		BetterLockpickingContinuedSTR_2 = 6
		BetterLockpickingContinuedSTR_3 = 4
	 elseif BetterLockpickingContinuedSkillStrength <= 4 then
		BetterLockpickingContinuedSTR_1 = 10
		BetterLockpickingContinuedSTR_2 = 7
		BetterLockpickingContinuedSTR_3 = 5
	 elseif BetterLockpickingContinuedSkillStrength == 5 then
		BetterLockpickingContinuedSTR_1 = 12
		BetterLockpickingContinuedSTR_2 = 8
		BetterLockpickingContinuedSTR_3 = 6
	 elseif BetterLockpickingContinuedSkillStrength <= 8 then
		BetterLockpickingContinuedSTR_1 = 15
		BetterLockpickingContinuedSTR_2 = 10
		BetterLockpickingContinuedSTR_3 = 7
	 else		-- BetterLockpickingContinuedSkillStrength <=10
		BetterLockpickingContinuedSTR_1 = 18
		BetterLockpickingContinuedSTR_2 = 12
		BetterLockpickingContinuedSTR_3 = 9
	end

	local BetterLockpickingContinuedFIT = 4.8
	if BetterLockpickingContinuedSkillFitness <= 1 then
		BetterLockpickingContinuedFIT = 4.8
	 elseif BetterLockpickingContinuedSkillFitness <= 4 then
		BetterLockpickingContinuedFIT = 4.0
	 elseif BetterLockpickingContinuedSkillFitness == 5 then
		BetterLockpickingContinuedFIT = 3.2
	 elseif BetterLockpickingContinuedSkillFitness <= 8 then
		BetterLockpickingContinuedFIT = 2.4
	 else		-- BetterLockpickingContinuedSkillFitness <=10
		BetterLockpickingContinuedFIT = 1.6
	end
	local BetterLockpickingContinuedFIT_1 = BetterLockpickingContinuedFIT
	local BetterLockpickingContinuedFIT_2 = BetterLockpickingContinuedFIT * 1.75
	local BetterLockpickingContinuedFIT_3 = BetterLockpickingContinuedFIT * 2.5

    if crowbarTimer > 0 then return end

    if arrow_scale_step >= shiftGreen/3 and arrow_scale_step <= (shiftGreen/3 + greenSize) then
        progressBarVal = progressBarVal + (BetterLockpickingContinuedSTR_1 + BetterLockpickingContinuedLPSTR_1)/100
		
		enduranceLevel = enduranceLevel - ((BetterLockpickingContinuedFIT_1 - BetterLockpickingContinuedLPFIT)/100)
		self.character:getStats():set(CharacterStat.ENDURANCE, enduranceLevel)
		crowbarTimer = 50
	
    elseif arrow_scale_step >= shiftYellow/3 and arrow_scale_step <= (shiftYellow/3 + yellowSize) then
        progressBarVal = progressBarVal + (BetterLockpickingContinuedSTR_2 + BetterLockpickingContinuedLPSTR_2)/100
		
		enduranceLevel = enduranceLevel - ((BetterLockpickingContinuedFIT_2 - BetterLockpickingContinuedLPFIT)/100)
		self.character:getStats():set(CharacterStat.ENDURANCE, enduranceLevel)
		crowbarTimer = 50
	
    else
        progressBarVal = progressBarVal + (BetterLockpickingContinuedSTR_3 + BetterLockpickingContinuedLPSTR_3)/100
		
		enduranceLevel = enduranceLevel - ((BetterLockpickingContinuedFIT_3 - BetterLockpickingContinuedLPFIT)/100)
		self.character:getStats():set(CharacterStat.ENDURANCE, enduranceLevel)
		crowbarTimer = 50
    end
	
    self.character:getXp():AddXP(Perks.Strength, self.addingXP/4)
    self.character:getXp():AddXP(Perks.Fitness, self.addingXP/4)
	
    if progressBarVal >= 1.0 then
        self.isEnd = true
        self:doUnlock()
    end
end

CrowbarWindow.OnKeyStartPressed = function(key)
    if CrowbarWindow.instance == nil then return end
    local win = CrowbarWindow.instance

    if key == Keyboard.KEY_SPACE then
       win:ActionKeyPressed()
    end

    if key == Keyboard.KEY_ESCAPE then
        --win:close()
		win:setVisible(false);			-- BetterLockpickingContinued Force Close FIX
        win:removeFromUIManager();		-- BetterLockpickingContinued Force Close FIX
        win:close()						-- BetterLockpickingContinued Force Close FIX
    end
end

local lastMillis = nil
CrowbarWindow.onTick = function()
    local currentMillis = math.floor(getTimeInMillis()/50)
    if lastMillis ~= currentMillis then
        lastMillis = currentMillis

        if CrowbarWindow.instance == nil then return end

        if crowbarTimer > 0 then
            crowbarTimer = crowbarTimer - 1
            local win = CrowbarWindow.instance
            if crowbarTimer == 0 and win ~= nil and win.isEnd then
                win:close()
            end
        end
    end
end


Events.OnKeyStartPressed.Add(CrowbarWindow.OnKeyStartPressed);
Events.OnTick.Add(CrowbarWindow.onTick);
