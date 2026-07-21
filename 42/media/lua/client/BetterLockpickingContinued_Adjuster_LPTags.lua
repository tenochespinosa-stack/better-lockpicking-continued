--local function BetterLockpickingContinuedAdjust(Name, Property, Value)
--	local Item = ScriptManager.instance:getItem(Name)
--	if Item then
--		Item:DoParam(Property.." = "..Value)
--	end
--end
-- vanila crowbar
--	BetterLockpickingContinuedAdjust("Base.Crowbar","Tags","base:crowbar;base:removebarricade;base:killanimal;base:smeltablesteellarge;base:hasmetal;base:BetterLockpickingContinuedcrow");
--	BetterLockpickingContinuedAdjust("Base.CrowbarForged","Tags","base:crowbar;base:removebarricade;base:killanimal;base:smeltablesteellarge;base:hasmetal;base:BetterLockpickingContinuedcrow");
-- vanila screwdriver
-- BetterLockpickingContinuedAdjust("Base.Screwdriver","Tags","Screwdriver;BetterLockpickingContinuedScrew");

--[[

-- id: ToolsOfTheTrade (UtilityBar - one handed, animation not compatibility)
if getActivatedMods():contains("ToolsOfTheTrade") then
	BetterLockpickingContinuedAdjust("ToolsOfTheTrade.HalliganBar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
end

-- id: PaintableCrowbars PaintableCrowbars_SND_HL1 PaintableCrowbars_SND_HL2
if getActivatedMods():contains("PaintableCrowbars") or getActivatedMods():contains("PaintableCrowbars_SND_HL1") or getActivatedMods():contains("PaintableCrowbars_SND_HL2") then
	BetterLockpickingContinuedAdjust("Base.Crowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.BlackCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.BrownCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.CyanCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.GreenCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.GreyCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.LightBlueCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.LightBrownCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.OrangeCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.PinkCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.PurpleCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.RedCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.TurquoiseCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.WhiteCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.YellowCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.RainbowCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("Base.StrippedCrowbar","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
end

-- id: MonmouthCounty_new MonmouthCountyTributeLegacy
if getActivatedMods():contains("MonmouthCounty_new") then
	BetterLockpickingContinuedAdjust("MonmouthWeapons.CrowbarScorpion","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
	BetterLockpickingContinuedAdjust("MonmouthWeapons.Crowbarski","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
end
if getActivatedMods():contains("MonmouthCountyTributeLegacy") then
	BetterLockpickingContinuedAdjust("MonmouthWeapons.CrowbarScorpion","Tags","Crowbar;RemoveBarricade;BetterLockpickingContinuedCrow");
end

-- id: BasedCrowaxe
if getActivatedMods():contains("BasedCrowaxe") then
	BetterLockpickingContinuedAdjust("Base.BasedCrowaxe","Tags","ChopTree;Crowbar;CutPlant;RemoveBarricade;BetterLockpickingContinuedCrow");
end

]]