require "TimedActions/ISBaseTimedAction"
require "Lockpicking/Crowbar/CrowbarWindow"

CrowbarActionAnim = ISBaseTimedAction:derive("CrowbarActionAnim")

function CrowbarActionAnim:isValid()
	if instanceof(self.lockpick_object, "IsoDoor") or (instanceof(self.lockpick_object, "IsoThumpable") and self.lockpick_object:isDoor()) or instanceof(self.lockpick_object, "IsoWindow") then
		return true;
	 else
		return self.lockpick_object:getVehicle():isStopped()
	end
end

function CrowbarActionAnim:waitToStart()
	if instanceof(self.lockpick_object, "IsoDoor") or (instanceof(self.lockpick_object, "IsoThumpable") and self.lockpick_object:isDoor()) or instanceof(self.lockpick_object, "IsoWindow") then
		self.character:faceThisObject(self.lockpick_object)
		return self.character:shouldBeTurning()
	 else
		self.character:faceThisObject(self.lockpick_object:getVehicle())
		return self.character:shouldBeTurning()
	end
end

function CrowbarActionAnim:update()
	local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
    if uispeed ~= 1 then
        UIManager.getSpeedControls():SetCurrentGameSpeed(1)
	end
	
	if not self.sound or not self.sound:isPlaying() then
		self.sound = getSoundManager():PlayWorldSound("BetterLockpickingContinued_crowbarSound", self.character:getCurrentSquare(), 1, 25, 2, true)
	end

	if instanceof(self.lockpick_object, "IsoDoor") or (instanceof(self.lockpick_object, "IsoThumpable") and self.lockpick_object:isDoor()) or instanceof(self.lockpick_object, "IsoWindow") then
		self.character:faceThisObject(self.lockpick_object)	
	 else
		self.character:faceThisObject(self.lockpick_object:getVehicle())
	end
end

function CrowbarActionAnim:start()
	if self.isGarage then
		self:setActionAnim("CrowbarGarageAction")
	 else
		self:setActionAnim("CrowbarAction")
	end
	
	self.character:getModData().BetterLockpickingContinuedStopFlag = 0
end

function CrowbarActionAnim:stop()
	getSoundManager():StopSound(self.sound)
	
	if self.character:getModData().BetterLockpickingContinuedStopFlag == 0 then
		local win = CrowbarWindow.instance
		if win ~= nil then
			win:close()
		end
		self.character:getModData().BetterLockpickingContinuedStopFlag = 1
	end
	
	ISBaseTimedAction.stop(self)
end

function CrowbarActionAnim:perform()
	getSoundManager():StopSound(self.sound)
	ISBaseTimedAction.perform(self)
end

function CrowbarActionAnim:new(character, isGarage, lockpick_object)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.lockpick_object = lockpick_object
	o.maxTime = 50000
	o.isGarage = isGarage
	
	return o
end
