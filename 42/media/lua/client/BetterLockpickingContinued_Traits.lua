if BetterLockpickingContinued == nil then BetterLockpickingContinued = {} end

Events.OnMainMenuEnter.Add(function()
    if not TraitFactory or not TraitFactory.addTrait then return end
    TraitFactory.addTrait(
        "nimblefingers",
        getText("UI_trait_nimblefingers"),
        3,
        getText("UI_trait_nimblefingersDesc"),
        false
    )
end)
