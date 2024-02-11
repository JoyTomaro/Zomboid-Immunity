--------------------------------------
--Inspect Bite Results
--------------------------------------

function ISInspectBite(items, result, player)
    local testData = player:getModData()
    local playerBody = player:getBodyDamage()
    local waitperiod = SandboxVars.TomaroImmunity.WaitPeriod
    if (testData.testStatus == "ready" or testData.testStatus == "tested") and testData.immune == true then
        player:Say(getText("IGUI_Say_ResultImmune"))
        playerBody:setIsFakeInfected(false)
        if not player:HasTrait("Immune") then
            player:getTraits():add("Immune")
        end
        testData.testStatus = "tested"
    elseif (testData.testStatus == "ready" or testData.testStatus == "tested") and testData.immune == false and playerBody:isInfected() then
        player:Say(getText("IGUI_Say_ResultInfected"))
        playerBody:setIsFakeInfected(false)
        testData.testStatus = "tested"
    else
        if testData.testStatus == "testing" then
            player:Say((testData.testStage) .. (getText("IGUI_Say_HoursSince1")))
            player:Say((getText("IGUI_Say_HoursSince2")) .. (waitperiod - (testData.testStage)) .. (getText("IGUI_Say_HoursSince3")))
        end
	end
end