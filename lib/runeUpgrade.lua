-- TODO: Try using numberOCR for runeLevel
-- function keyNum()
-- 	local preMinSimilarity = Settings:get("MinSimilarity")
-- 	Settings:set("MinSimilarity", 0.7)
-- 	local anchor = bottomLeft:wait("slash.png")
-- 	local numRegion = Region(anchor:getX() - 110, anchor:getY(), 110, anchor:getH())
-- 	if debugAll == true then numRegion:highlight(1) end
-- 	local num = numberOCRNoFindException(numRegion, "vFlash")
-- 	Settings:set("MinSimilarity", preMinSimilarity)
-- end
currentRuneLevel = -1
function waitForNextRune()
    if debugAll == true then toast("[Function] waitForNextRune") end
    pauseTime = Timer()
    
    while true do
        timeLeft = runeUpgradePauseTime - pauseTime:check()
        if (timeLeft <= 0) then
            pauseTime = 0
            break
        else
            statsSection("Time remaining for \n next rune upgrade: \n\n"..
                    (timeLeft / 60).." minutes.")
        end
        wait(1)
    end
end

function currentRuneLevel()
    local runeLvl = numberOCRNoFindException(runeLvlReg,"runeLvl")
--    local currentRuneLevel = existsMultiMaxSnap(runeUpgradeLevelRegion,{
--			runeLevel15,
--			runeLevel12,
--			runeLevel9,
--			runeLevel6,
--			runeLevel3})
--    return currentRuneLevel or -1
end

function runeUpgradePossible()
    if currentRuneLevel() == -1 then scriptExit("Unknown error. Please report it.") end

    if currentRuneLevel() < desiredRuneLevel then 
        return true
    else
        simpleDialog("Rune upgraded to desired level.",
            "The rune is upgraded to atleast rune level +"..desiredRuneLevel.."\n\n"..
            "Click 'OK' to select the next rune.")
        return false 
    end
end
function doNextRuneUpgrade()
    -- Do runeLevel check
    continueClick(runePowerUpButtonReg, 1)
end

function upgradeRune()
    while true do
        -- CheckIfFirstRuneDialog is open, if not then ask to select the first rune
        if (runePowerUpButtonReg:exists(runePowerUpButton)) then
            if (runeUpgradePossible()) then
                doNextRuneUpgrade()
            else
                waitForNextRune()
            end
        else
            simpleDialog("Rune Power-up Button not found.",
                "Whoops! Couldn't find the Rune Power-up button. \n\n"..
                "Please check if the Rune Power-up Dialog of the rune you'd like to upgrade is opened. \n"..
                "If you have opened it, please report it on the forum.")
            waitForNextRune()
        end
    end
end