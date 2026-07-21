
require "Lockpicking/Actions/UnlockVehicleDoorAction"
require "Lockpicking/Utils"

BobbyPinWindow = ISPanel:derive("BobbyPinWindow");

local MODE_VEHICLE_DOOR = 0
local MODE_VEHICLE_ENGINE_KEY = 1
local MODE_BUILDING_DOOR = 2

local xPos = 125
local yPos = 250

local pickLockHealth = 350

local tmpVec1 = Vector3f.new()
local tmpVec2 = Vector3f.new():set(1, 0, 0)


local function forceUnlockChance(playerObj)
    return 10 + playerObj:getPerkLevel(Perks.Strength)
end

--------------

function BobbyPinWindow:setVisible(visible)
    self.javaObject:setVisible(visible);
end


local lastRenderMillis = nil
function BobbyPinWindow:render()
    self:drawText(getText("UI_Controls_BobbyPin"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Small, getText("UI_Controls_BobbyPin")) / 2), 10, 1,1,1,1, UIFont.Small);

    self:DrawTextureAngle(self.tex_LockBack, xPos, yPos, 0)
    self:DrawTextureAngle(self.tex_LockFront, xPos, yPos, self.angleScrew)
    self:DrawTextureAngle(self.tex_Screwdriver, xPos, yPos, self.angleScrew)
    
    local currentMillis = math.floor(getTimeInMillis()/100)
    local isNewTimeStep = false
    if lastRenderMillis ~= currentMillis then
        lastRenderMillis = currentMillis
        isNewTimeStep = true
    end

    if self.breakTimer > 0 then
        
        if isNewTimeStep then
            self.breakTimer = self.breakTimer - 0.1
        end
        if self.isEnd and not self.isFailEnd then
            self:DrawTextureAngle(self.tex_LockPick, xPos, yPos, self.anglePick)
        else
            self:DrawTextureAngle(self.tex_LockPickBreak, xPos, yPos, self.anglePick)
        end

        if self.breakTimer <= 0 then
            if self.isEnd or self.isFailEnd then
                self:setVisible(false);
                self:removeFromUIManager();
                self:close()
            end
        end
    else
        self:DrawTextureAngle(self.tex_LockPick, xPos, yPos, self.anglePick)
    end
end

function BobbyPinWindow:onOptionMouseDown(button, x, y)
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager();
        self:close()
    end
    if button.internal == "FORCE" then
        self:setVisible(false)	--
        self:forceUnlock()
        self:close()			--
    end
end

function BobbyPinWindow:forceUnlock()
    if ZombRand(100) < forceUnlockChance(self.character) then
        self:doUnlock()
    else
        self:doBreakLock()
    end

    self.breakTimer = 1
    self.isEnd = true
end

function BobbyPinWindow:doLock()
    self.lockpick_object:setLockedByKey(true);
    self.lockpick_object:setLocked(true)
    if BetterLockpickingContinued.Utils.isGarageDoor(self.lockpick_object) then
        local doorPrev = BetterLockpickingContinued.Utils.getGarageDoorPrev(self.lockpick_object)
        while doorPrev ~= nil do
            doorPrev:setLockedByKey(true);
            doorPrev:setLocked(true);
            doorPrev = BetterLockpickingContinued.Utils.getGarageDoorPrev(doorPrev)
        end

        local doorNext = BetterLockpickingContinued.Utils.getGarageDoorNext(self.lockpick_object)
        while doorNext ~= nil do
            doorNext:setLockedByKey(true);
            doorNext:setLocked(true);
            doorNext = BetterLockpickingContinued.Utils.getGarageDoorNext(doorNext)
        end
    end
    self.character:getEmitter():playSound("bobby_success");
    self.character:getXp():AddXP(Perks.Nimble, self.addingXP);
end

function BobbyPinWindow:doUnlock()
	if self.mode == MODE_VEHICLE_DOOR then					-- ВЗЛОМ МАШИНЫ
		UnlockVehicleDoorAction.unlock(self.character, self.lockpick_object)
        self.character:getEmitter():playSound("bobby_success");
    elseif self.mode == MODE_VEHICLE_ENGINE_KEY then
        self.lockpick_object:tryStartEngine(true)
    else
        self.lockpick_object:setLockedByKey(false);

        if BetterLockpickingContinued.Utils.isGarageDoor(self.lockpick_object) then
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

        self.character:getEmitter():playSound("bobby_success");
    end
    self.character:getXp():AddXP(Perks.Nimble, self.addingXP);
end

function BobbyPinWindow:doBreakLock()
    if self.mode == MODE_VEHICLE_DOOR then
        self.lockpick_object:getDoor():setLockBroken(true)
        self.character:getEmitter():playSound("lockpick_force_fail");
    elseif self.mode == MODE_VEHICLE_ENGINE_KEY then
        self.lockpick_object:setKeyId(-3);
        self.character:getEmitter():playSound("lockpick_force_fail");
    else
        self.lockpick_object:setKeyId(-3);

        if BetterLockpickingContinued.Utils.isGarageDoor(self.lockpick_object) then
            local doorPrev = BetterLockpickingContinued.Utils.getGarageDoorPrev(self.lockpick_object)
            while doorPrev ~= nil do
                doorPrev:setKeyId(-3);
                doorPrev = BetterLockpickingContinued.Utils.getGarageDoorPrev(doorPrev)
            end
    
            local doorNext = BetterLockpickingContinued.Utils.getGarageDoorNext(self.lockpick_object)
            while doorNext ~= nil do
                doorNext:setKeyId(-3);
                doorNext = BetterLockpickingContinued.Utils.getGarageDoorNext(doorNext)
            end
        end
        self.character:getEmitter():playSound("lockpick_force_fail");
    end
    self.character:getXp():AddXP(Perks.Nimble, self.addingXP/5);
end

function BobbyPinWindow:close()
	self.character:getModData().BetterLockpickingContinuedStopFlag = 1
	
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
    
    ISTimedActionQueue.clear(self.character)
    BobbyPinWindow.instance = nil
    ISPanel.close(self)
end

function BobbyPinWindow:onMouseMoveOutside(dx, dy)
    if self.angleScrew == self.maxAngle or self.breakTimer > 0 then
        return
    end
    
    if self:getMouseY() < 250 then
        tmpVec1:set(self:getMouseX() - 125, self:getMouseY() - 250, 0)
        local angle = tmpVec1:angle(tmpVec2)
        if tmpVec1:y() > 0 then angle = -angle end
        self.anglePick = -((angle/math.pi)*180 + 135 + 90)
    else
        if self:getMouseX() < 125 then
            self.anglePick = -405
        else
            self.anglePick = -405 + 180   
        end
    end

    local diff = math.abs((self.anglePick + 405) - self.keyAngle)
    if diff > 180 then diff = 360 - diff end

    if diff < self.diffAngle then 
        self.maxAngle = 90
    elseif diff >= 45 then
        self.maxAngle = 5
    else
        self.maxAngle = (90 - 2*diff)
    end
end

--------------------------
-- Creating window
--------------------------

function BobbyPinWindow:createVehicleDoor(playerObj, part)
    if part:getDoor():isLockBroken() then
        playerObj:Say(getText("IGUI_PlayerText_VehicleLockIsBroken"))
        return
    end
        
    local modal = BobbyPinWindow:new(Core:getInstance():getScreenWidth()/2 - 250/2 + 300, Core:getInstance():getScreenHeight()/2 - 500/2, 250, 90)
    modal.lockpick_object = part
    modal.mode = MODE_VEHICLE_DOOR
    modal.tex_LockBack = getTexture("media/textures/BetterLockpickingContinued_Back_VehDoor.png")
    modal.tex_LockFront = getTexture("media/textures/BetterLockpickingContinued_Front_VehDoor.png")
    modal.tex_LockPick = getTexture("media/textures/BetterLockpickingContinued_PickLock.png")
    modal.tex_LockPickBreak = getTexture("media/textures/BetterLockpickingContinued_PickLock_Break.png")
    modal.tex_Screwdriver = getTexture("media/textures/BetterLockpickingContinued_Screwdriver.png")
    modal.character = playerObj
    modal.addingXP = part:getVehicle():getModData().LockpickLevel.xp

    modal:initialise()
    modal:addToUIManager()
end

function BobbyPinWindow:createBuildingDoor(playerObj, door, goToOpen)
    local dx = door:getSquare():getX() - playerObj:getSquare():getX()
    local dy = door:getSquare():getY() - playerObj:getSquare():getY()
    local zGood = math.abs(door:getSquare():getZ() - playerObj:getSquare():getZ()) < 2
    local dist = math.sqrt(dx*dx + dy*dy)
    
    if not zGood or dist > 2 then 
        return
    end

    if goToOpen and not door:isLocked() then
        playerObj:Say(getText("UI_door_is_unlocked"))
        return
    end

    if not goToOpen and door:isLocked() then
        playerObj:Say(getText("UI_door_is_locked"))
        return
    end

    if door:getKeyId() == -3 then
        playerObj:Say(getText("IGUI_PlayerText_VehicleLockIsBroken"))
        return
    end

    local modal = BobbyPinWindow:new(Core:getInstance():getScreenWidth()/2 - 250/2 + 300, Core:getInstance():getScreenHeight()/2 - 500/2, 250, 90)
    modal.lockpick_object = door
    modal.mode = MODE_BUILDING_DOOR
    modal.tex_LockBack = getTexture("media/textures/BetterLockpickingContinued_Back_VehDoor.png")
    modal.tex_LockFront = getTexture("media/textures/BetterLockpickingContinued_Front_VehDoor.png")
    modal.tex_LockPick = getTexture("media/textures/BetterLockpickingContinued_PickLock.png")
    modal.tex_LockPickBreak = getTexture("media/textures/BetterLockpickingContinued_PickLock_Break.png")
    modal.tex_Screwdriver = getTexture("media/textures/BetterLockpickingContinued_Screwdriver.png")
    modal.character = playerObj
    modal.goToOpen = goToOpen
    modal.addingXP = door:getModData().LockpickLevel.xp

    playerObj:faceThisObject(door)

    modal:initialise()
    modal:addToUIManager()
end


function BobbyPinWindow:initialise()
    if not (self.character:getInventory():getFirstTypeRecurse("BetterLockpickingContinuedBobbyPin") or self.character:getInventory():getFirstTypeRecurse("BetterLockpickingContinuedHandmadeBobbyPin")) then -- containsType  -- getFirstTypeRecurse
        return
    end

    ISPanel.initialise(self);
    self:create();
    BobbyPinWindow.instance = self

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

    local skill = self.character:getPerkLevel(Perks.Nimble)

    local level
    if self.mode == MODE_VEHICLE_DOOR then
        level = self.lockpick_object:getVehicle():getModData().LockpickLevel.num
    else
        level = self.lockpick_object:getModData().LockpickLevel.num
    end

    self.chanceBreakLock = BetterLockpickingContinued.Utils.getChanceBreakLock(skill, level)
    self.diffAngle = BetterLockpickingContinued.Utils.getDiffAngleBobbyPin(skill, level)

    local diff = math.abs((self.anglePick + 405) - self.keyAngle)
    if diff > 180 then diff = 360 - diff end

    if diff < self.diffAngle then 
        self.maxAngle = 90
    elseif diff >= 45 then
        self.maxAngle = 5
    else
        self.maxAngle = (90 - 2*diff)
    end

    ISTimedActionQueue.clear(self.character)
    ISTimedActionQueue.add(BobbyPinActionAnim:new(self.character, self.lockpick_object))
end

function BobbyPinWindow:create()
    self.cancel = ISButton:new((self:getWidth() / 2) - 50, self:getHeight() - 55, 100, 20, getText("UI_Cancel"), self, BobbyPinWindow.onOptionMouseDown);
    self.cancel.internal = "CANCEL";
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.cancel);
	
	--[[
    if self.goToOpen then
        self.forceButton = ISButton:new((self:getWidth() / 2) - 100, self:getHeight() - 30, 200, 20, getText("UI_ForceUnlock") .. " (" .. forceUnlockChance(self.character) .. "%)", self, BobbyPinWindow.onOptionMouseDown);
        self.forceButton.internal = "FORCE";
        self.forceButton:initialise();
        self.forceButton:instantiate();
        self.forceButton.borderColor = {r=1, g=1, b=1, a=0.1};
        self:addChild(self.forceButton)
    end
	]]
end


function BobbyPinWindow:new(x, y, width, height)
    local o = {};
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.breakTimer = 0

    o.angleScrew = 0
    o.anglePick = -ZombRand(225, 406)
    o.keyAngle = ZombRand(178) + 1


    o.isEnd = false

    o.comboList = {};
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    o:setWantKeyEvents(true)
    return o;
end

BobbyPinWindow.OnKeyKeepPressed = function(key)
    if BobbyPinWindow.instance == nil then return end
    
    local win = BobbyPinWindow.instance
    if win.breakTimer > 0 then return end

    if key == Keyboard.KEY_A or key == Keyboard.KEY_D or key == Keyboard.KEY_W or key == Keyboard.KEY_S then
        -- win.angleScrew = win.angleScrew + 3
		win.angleScrew = win.angleScrew + win.deltaTime * 0.23 -- win.angleScrew = win.angleScrew + UIManager.getMillisSinceLastRender() * 0.23 -- Thanks to Albion! and Js!
        if win.angleScrew > win.maxAngle then 
            win.angleScrew = win.maxAngle
            if win.angleScrew == 90 then
                if win.goToOpen == nil or win.goToOpen == true then
                    win:doUnlock()
                else
                    win:doLock()
                end

                win.isEnd = true
                win.breakTimer = 1
            else
                -- pickLockHealth = pickLockHealth - 1 UIManager.getMillisSinceLastRender() * 0.1
				 pickLockHealth = pickLockHealth - win.deltaTime * 0.1 -- pickLockHealth = pickLockHealth - UIManager.getMillisSinceLastRender() * 0.1 -- Thanks to Albion! and Js!
                if pickLockHealth <= 0 then
                    win.breakTimer = 3
                    win.character:getEmitter():playSound("bobby_fail")
                    pickLockHealth = 350

                    if ZombRand(100) < win.chanceBreakLock then
                        win:doBreakLock()
                        win:close()                    
                    end
					
					local BetterLockpickingContinuedBP = win.character:getInventory():getFirstTypeRecurse("BetterLockpickingContinuedBobbyPin")
					local BetterLockpickingContinuedHBP = win.character:getInventory():getFirstTypeRecurse("BetterLockpickingContinuedHandmadeBobbyPin")
					if BetterLockpickingContinuedBP then
						BetterLockpickingContinuedBP:getContainer():DoRemoveItem(BetterLockpickingContinuedBP)
                    elseif BetterLockpickingContinuedHBP then
                        BetterLockpickingContinuedHBP:getContainer():DoRemoveItem(BetterLockpickingContinuedHBP)
                    else
                        win.breakTimer = 2
                        win.isFailEnd = true
                    end
                    if not (win.character:getInventory():getFirstTypeRecurse("BetterLockpickingContinuedBobbyPin") or win.character:getInventory():getFirstTypeRecurse("BetterLockpickingContinuedHandmadeBobbyPin")) then 	-- containsType
                        win.breakTimer = 2
                        win.isFailEnd = true
                    end
					--[[
                    if win.character:getInventory():containsType("BetterLockpickingContinuedBobbyPin") then	-- containsType
						win.character:getInventory():Remove("BetterLockpickingContinuedBobbyPin")
                    elseif win.character:getInventory():containsType("BetterLockpickingContinuedHandmadeBobbyPin") then -- containsType
                        win.character:getInventory():Remove("BetterLockpickingContinuedBobbyPin")
                    else
					
                        win.breakTimer = 2
                        win.isFailEnd = true
                    end
                    if not (win.character:getInventory():containsType("BetterLockpickingContinuedBobbyPin") or win.character:getInventory():containsType("BetterLockpickingContinuedHandmadeBobbyPin")) then
                        win.breakTimer = 2
                        win.isFailEnd = true
                    end
					]]
                end
            end 
        end
    end

    
    if key == Keyboard.KEY_ESCAPE then
        --win:close()
		win:setVisible(false);			-- BetterLockpickingContinued Force Close FIX
        win:removeFromUIManager();		-- BetterLockpickingContinued Force Close FIX
        win:close()						-- BetterLockpickingContinued Force Close FIX
    end
end

BobbyPinWindow.onTick = function() -- thanks to  and Js!
    local win = BobbyPinWindow.instance
    if win == nil or win.isEnd then return end
 
    local now = getTimeInMillis()
    win.deltaTime = now - (win.lastTick or now)
    win.lastTick = now
 
    win.angleScrew = win.angleScrew - win.deltaTime * 0.04
    if win.angleScrew < 0 then win.angleScrew = 0 end
end

Events.OnKeyKeepPressed.Add(BobbyPinWindow.OnKeyKeepPressed);
Events.OnTick.Add(BobbyPinWindow.onTick);
