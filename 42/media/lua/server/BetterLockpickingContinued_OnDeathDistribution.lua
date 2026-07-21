function BetterLockpickingContinued_CheckDrops(zombie)

	if not zombie:getOutfitName() then return false end
	local outfit = tostring(zombie:getOutfitName());
	local inv = zombie:getInventory();
	if (outfit == "Bandit") or (outfit == "InmateEscaped") then
		if 90 >= ZombRand(1, 100) then
			inv:AddItems("BetterLockpickingContinued.LockpickingMag", 1);
		end
		
	end
end

Events.OnZombieDead.Add(BetterLockpickingContinued_CheckDrops);