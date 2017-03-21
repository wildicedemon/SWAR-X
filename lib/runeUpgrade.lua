function waitForNextRune()
    if debugAll == true then toast("[Function] waitForNextRune") end
    pauseTime = Timer()

    statsSection:highlight("Time remaining for \n next rune upgrade:\n\n\n")
    while true do
        timeLeft = runeUpgradePauseTime * 60 - pauseTime:check()
        if (timeLeft <= 0) then
            statsSection:highlightOff()
            timeSection:highlightOff()
            pauseTime = 0
            break
        else
            local min = math.floor(timeLeft / 60)
            local sec = math.floor(math.fmod(timeLeft, 60))
            timeSection:highlight(min..":"..sec.." minutes.")
        end
        wait(2)
    end
end

function findCurrentRuneLevel()
    if debugAll == true then toast("[Function] currentRuneLevel") end
    local runeLvlFound = existsMultiMaxSnap(runeLvlReg, {
        runeLevel15,
        runeLevel14,
        runeLevel13,
        runeLevel12,
        runeLevel11,
        runeLevel10,
        runeLevel9,
        runeLevel8,
        runeLevel7,
        runeLevel6,
        runeLevel5,
        runeLevel4,
        runeLevel3,
        runeLevel2})
    local currentRuneLevel = 16 - runeLvlFound
    toast("CurrentRuneLevel is +"..currentRuneLevel)
    return currentRuneLevel
end

function runeUpgradePossible(currentRuneLevel)
    if debugAll == true then toast("[Function] runeUpgradePossible") end
    if currentRuneLevel == 17 then scriptExit("Unknown error. Please report it.") end

    if currentRuneLevel < desiredRuneLevel then
        return true
    else
        simpleDialog("Rune upgraded to desired level.",
            "The rune is upgraded to atleast rune level +"..desiredRuneLevel.."\n\n"..
            "Click 'OK' to select the next rune.")
        return false 
    end
end
function doNextRuneUpgrade(currentRuneLevel)
    if debugAll then toast("[Function] doNextRuneUpgrade") end
    local numPowerUpsNeeded = desiredRuneLevel - currentRuneLevel
    while numPowerUpsNeeded >= 1 do
        if debugAll then toast("numPowerUpsNeeded = "..numPowerUpsNeeded) end
        if (runePowerUpButtonReg:exists(runePowerUpButton, 40)) then
            if debugAll == true then runePowerUpButtonReg:highlight(0.5) end
            runePowerUpButtonReg:continueClick(runePowerUpButton, 1)
            numPowerUpsNeeded = numPowerUpsNeeded - 1
        end
        wait(6)
    end
end

function upgradeRune()
    if debugAll then toast("[Function] upgradeRune") end
    while true do
        -- CheckIfFirstRuneDialog is open, if not then ask to select the first rune
        if (runePowerUpButtonReg:exists(runePowerUpButton, 40)) then
            toast("Checking current Rune level")
            local currentRuneLevel = findCurrentRuneLevel()

            if (runeUpgradePossible(currentRuneLevel)) then
                doNextRuneUpgrade(currentRuneLevel)
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