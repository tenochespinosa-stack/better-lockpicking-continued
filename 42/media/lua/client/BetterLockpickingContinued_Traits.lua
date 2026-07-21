if BetterLockpickingContinued == nil then BetterLockpickingContinued = {} end

Events.OnGameBoot.Add(function()
    TraitFactory.addTrait(
        "nimblefingers",
        getText("UI_trait_nimblefingers"),
        3,
        getText("UI_trait_nimblefingersDesc"),
        false
    )
end)
