require "TimedActions/ISBaseTimedAction"
require "Lockpicking/Crowbar/CrowbarWindow"

BobbyPinActionAnim = ISBaseTimedAction:derive("BobbyPinActionAnim")

function BobbyPinActionAnim:isValid()
	if instanceof(self.lockpick_object, "IsoDoor") or (instanceof(self.lockpick_object, "IsoThumpable") and self.lockpick_object:isDoor()) or instanceof(self.lockpick_object, "IsoWindow") then
		return true
	 else
		return self.lockpick_object:getVehicle():isStopped()
	end
end

function BobbyPinActionAnim:waitToStart()
	if instanceof(self.lockpick_object, "IsoDoor") or (instanceof(self.lockpick_object, "IsoThumpable") and self.lockpick_object:isDoor()) or instanceof(self.lockpick_object, "IsoWindow") then
		self.character:faceThisObject(self.lockpick_object)
		return self.character:shouldBeTurning()
	 else
		self.character:faceThisObject(self.lockpick_object:getVehicle())
		return self.character:shouldBeTurning()
	end
end

function BobbyPinActionAnim:update()
	local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
    if uispeed ~= 1 then
        UIManager.getSpeedControls():SetCurrentGameSpeed(1)
    end
	
	if instanceof(self.lockpick_object, "IsoDoor") or (instanceof(self.lockpick_object, "IsoThumpable") and self.lockpick_object:isDoor()) or instanceof(self.lockpick_object, "IsoWindow") then
		self.character:faceThisObject(self.lockpick_object)	
	 else
		self.character:faceThisObject(self.lockpick_object:getVehicle())
	end
end

function BobbyPinActionAnim:start()
	self:setActionAnim("Picklock")
	
	self.character:getModData().BetterLockpickingContinuedStopFlag = 0
end

function BobbyPinActionAnim:stop()
	if self.character:getModData().BetterLockpickingContinuedStopFlag == 0 then
		local win = BobbyPinWindow.instance
		if win ~= nil then
			win:close()
		end
		self.character:getModData().BetterLockpickingContinuedStopFlag = 1
	end
	
	ISBaseTimedAction.stop(self)
end

function BobbyPinActionAnim:perform()
	ISBaseTimedAction.perform(self)
end

function BobbyPinActionAnim:new(character, lockpick_object)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.lockpick_object = lockpick_object
	o.maxTime = 50000
	
	return o
end
