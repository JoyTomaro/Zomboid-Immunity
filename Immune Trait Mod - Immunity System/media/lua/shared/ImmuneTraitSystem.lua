--------------------------------------
--Add Traits
--------------------------------------
local ImmuneTrait = {}

--Immune. Thanks albion, Poltergeist, Chuckleberry Finn, Omar, and Panopticon!
ImmuneTrait.immuneTrait = function()
    TraitFactory.addTrait("Immune", getText("UI_trait_Immune"), 0, getText("UI_trait_Immunedesc"), true)
end

ImmuneTrait.setImmune = function(playerIndex,player)
    if player:HasTrait("Immune") and not player:getModData().immune then
        player:getModData().immune = true
    end
end

--Common Blood
ImmuneTrait.commonTrait = function()
    TraitFactory.addTrait("CommonBlood", getText("UI_trait_CommonBlood"), -1, getText("UI_trait_CommonBlooddesc"), false)
    if getActivatedMods():contains("TomaroBitten") then
        TraitFactory.setMutualExclusive("CommonBlood" , "Bitten")
    end
    TraitFactory.setMutualExclusive("CommonBlood" , "Immune")
end

ImmuneTrait.setCommon = function(playerIndex, player)
    if player:HasTrait("CommonBlood") and not player:getModData().immune then
        player:getModData().immune = false
    end
end

--adds data necessary for immunity mod to work
ImmuneTrait.spawnData = function(playerIndex, player)
    local testData = player:getModData()
    local immunechance = SandboxVars.TomaroImmunity.ImmuneChance
    if not testData.testStatus then
        if testData.immune == true then
            testData.testStatus = "tested"
        elseif testData.immune == false then
            testData.testStatus = "tested"
        elseif testData.bitten == true then
            testData.testStatus = "tested"
            testData.immune = false
        elseif ZombRand(1, 101) <= immunechance then --rolling for immunity
            testData.testStatus = "untested"
            testData.immune = true
        else
            testData.testStatus = "untested"
            testData.immune = false
        end
    end
    if not testData.testStage then
        testData.testStage = 0
    end
end

--removes infection from players with immunity
local function immuneResponse()
    for i = 0,3 do
        local player = getSpecificPlayer(i)
        if player then
            local playerBody = player:getBodyDamage()
            local testData = player:getModData()
            if playerBody:isInfected() and (testData.immune == true or player:HasTrait("Immune")) then
                for i = 0, playerBody:getBodyParts():size() -1 do
                    local bodyPart = playerBody:getBodyParts():get(i)
                    bodyPart:SetInfected(false)
                end
                playerBody:setInfected(false)
                playerBody:setIsFakeInfected(false)
                playerBody:setInfectionLevel(0)
                playerBody:setInfectionTime(-1)
            end
        end
    end
end

--if a player is bitten for the first time, they will panic and become fake infected until they examine themselves
local function bittenResponse()
    for i = 0,3 do
        local player = getSpecificPlayer(i)
        if player then
            local testData = player:getModData()
            local playerBody = player:getBodyDamage()
            local playerStats = player:getStats()
            if testData.testStatus == "untested" and playerBody:getNumPartsBitten() > 0 then
                playerBody:setIsFakeInfected(true) --fake infected because immune players do not know they are immune
                playerStats:setPanic(100)
                playerStats:setStress(1)
                testData.testStatus = "testing"
            end
        end
    end
end

--wait period before a player is able to examine a bite
local function waitingPeriod()
    for i = 0,3 do
        local player = getSpecificPlayer(i)
        if player then
            local testData = player:getModData()
            local playerBody = player:getBodyDamage()
            local waitperiod = SandboxVars.TomaroImmunity.WaitPeriod
            if testData.testStatus == "testing" then
                testData.testStage = testData.testStage + 1
                if testData.testStage >= waitperiod then
                    player:Say(getText("IGUI_Say_Ready"))
                    testData.testStatus = "ready" --players are now able to be tested
                end
            --updates player data if they are given the corresponding trait
            elseif player:HasTrait("Immune") then
                testData.testStatus = "tested"
                testData.immune = true
            elseif player:HasTrait("CommonBlood") then
                testData.testStatus = "tested"
                testData.immune = false
            end
        end
    end
end

if not getActivatedMods():contains("TomaroImmune") then
    Events.OnGameBoot.Add(ImmuneTrait.immuneTrait)
end
Events.OnCreatePlayer.Add(ImmuneTrait.setImmune)
Events.OnGameBoot.Add(ImmuneTrait.commonTrait)
Events.OnCreatePlayer.Add(ImmuneTrait.setCommon)
Events.OnCreatePlayer.Add(ImmuneTrait.spawnData)
Events.OnPlayerUpdate.Add(immuneResponse)
Events.OnPlayerUpdate.Add(bittenResponse)
Events.EveryHours.Add(waitingPeriod)
return ImmuneTrait