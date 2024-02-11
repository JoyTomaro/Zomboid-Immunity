--------------------------------------
--Add Traits
--------------------------------------
local ImmuneTrait = {}

--Immune
ImmuneTrait.immuneTrait = function()
    TraitFactory.addTrait("Immune", getText("UI_trait_Immune"), 16, getText("UI_trait_Immunedesc"), false)
end

local function removeInfection()
    for i = 0,3 do
        local player = getSpecificPlayer(i)
        if player then
            local playerBody = player:getBodyDamage()
            if player:HasTrait("Immune") and playerBody:IsInfected() then
                for i = 0, playerBody:getBodyParts():size() -1 do
                    local bodyPart = playerBody:getBodyParts():get(i)
                    bodyPart:SetInfected(false)
                end
                playerBody:setInfected(false)
                playerBody:setInfectionLevel(0)
                playerBody:setInfectionTime(-1)
            end
        end
    end
end

Events.OnGameBoot.Add(ImmuneTrait.immuneTrait)
if not getActivatedMods():contains("TomaroImmunitySystem") then
    Events.OnPlayerUpdate.Add(removeInfection)
end
return ImmuneTrait