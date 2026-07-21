local BetterLockpickingContinueddefinition = CharacterProfessionDefinition.getCharacterProfessionDefinition(CharacterProfession.BURGLAR)
BetterLockpickingContinueddefinition:getGrantedRecipes():add("BetterLockpickingContinuedCreateBobbyPin")
BetterLockpickingContinueddefinition:getGrantedRecipes():add("BetterLockpickingContinuedCreateBobbyPin2")

local function BetterLockpickingContinued_BurglarProf()
	local player = getPlayer();
	if not player then return end
	if player:isDead() then return end

	local HeBurglar = player:getDescriptor():isCharacterProfession(CharacterProfession.BURGLAR)
	local HasTrait = player:getDescriptor():hasTrait("nimblefingers")
	local HeKnows = player:getKnownRecipes():contains("BetterLockpickingContinuedCreateBobbyPin")
	if (HeBurglar or HasTrait) and not HeKnows then
		player:learnRecipe("BetterLockpickingContinuedCreateBobbyPin");
		player:learnRecipe("BetterLockpickingContinuedCreateBobbyPin2");
		--print("lockpicking learned")
	end
end

Events.OnCreatePlayer.Add(BetterLockpickingContinued_BurglarProf);
Events.OnCreateLivingCharacter.Add(BetterLockpickingContinued_BurglarProf);