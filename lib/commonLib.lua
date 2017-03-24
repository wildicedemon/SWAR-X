function immersiveAuto(target)
    if (getAppUsableScreenSize():getX() == getRealScreenSize():getX()) then
        setImmersiveMode(true)
        return true
    end

    local score = 0
    setImmersiveMode(false)
    if (exists(target, 0)) then
        score = getLastMatch():getScore()
    else
        setImmersiveMode(true)
        if (exists(target, 0)) then return end
        wait(target, 0)
    end
    setImmersiveMode(true)
    if (exists(target, 0)) then
        if (getLastMatch():getScore() > score) then return end
    end

    setImmersiveMode(false)
end

function regionFinder(target, var)
    if debugAll == true then toast("Try to find Region") target:highlight(1) end
    local x = target:getX() - var
    local y = target:getY() - var
    local w = target:getW() + (var * 2)
    local h = target:getH() + (var * 2)

    local orgReg = Region(x,y,w,h)

    if debugAll == true then toast("Found region: "..x..", "..y..", "..w..", "..h) end
    return orgReg
end

--[[
-- Determines the size on which images are matched.
-- ]]
function autoResize(target, defaultDimension, immersive, region)
    local oldROI = Settings:getROI();
    local max = 0
    local localX = defaultDimension
    if (region) then Settings:setROI(region) end
    if (exists(target, 0)) then
        resumeROI(oldROI)
        return defaultDimension
    end

    usePreviousSnap(true)

    setImmersiveMode(not immersive)
    if (exists(target, 0)) then
        resumeROI(oldROI)
        usePreviousSnap(false)
        return defaultDimension
    end

    setImmersiveMode(immersive)
    target:similar(0.8)
    local range = defaultDimension * 0.15
    for x = defaultDimension - range, defaultDimension + range, 10 do
        Settings:setCompareDimension(true, x)
        if (exists(target, 0)) then
            if (getLastMatch():getScore() < max) then
                localX = x - 10
                break
            end
            max = getLastMatch():getScore()
        end
    end

    max = 0
    for x = (localX - 9), (localX + 9) do
        Settings:setCompareDimension(true, x)
        if (exists(target, 0)) then
            if (getLastMatch():getScore() < max) then
                Settings:setCompareDimension(true, x - 1)
                Settings:setScriptDimension(true, x - 1)
                toast("CompareDimension = "..(x-1))
                return (x - 1)
            end
            max = getLastMatch():getScore()
        end
    end

    if (max == 0) then
        Settings:setCompareDimension(true, defaultDimension)
        Settings:setScriptDimension(true, defaultDimension)
	resumeROI(oldROI)
        usePreviousSnap(false)
        return -1
    end

    resumeROI(oldROI)
    usePreviousSnap(false)
    return (localX + 9)
end

-- ============= Image recognition related =============
function regionWaitMulti(target, seconds, debug, skipLocation)
    local timer = Timer()
    local match
    while (true) do
        for i, t in ipairs(target) do
            if (debug) then t.region:highlight(0.5) end
            if (i == 1) then usePreviousSnap(false) else usePreviousSnap(true) end
            if ((t.region and (t.region):exists(t.target, 0)) or
                    (not t.region and exists(t.target, 0))) then -- check once
                usePreviousSnap(false)
                if (t.region) then
                    match = (t.region):getLastMatch()
                else
                    match = getLastMatch
                end
                if (debug) then match:highlight(0.5) end
                return i, match, t.id
            end
        end
        if (skipLocation ~= nil) then click(skipLocation) end
        if (timer:check() > seconds) then
            usePreviousSnap(false)
            return -1, "__none__"
        end
    end
end

function waitMulti(target, seconds, skipLocation)
    local timer = Timer()
    while (true) do
        for i, t in ipairs(target) do
            if (i == 1) then usePreviousSnap(false) else usePreviousSnap(true) end
            if (exists(t, 0)) then -- check once
                usePreviousSnap(false)
                return i, getLastMatch()
            end
        end
        if (skipLocation ~= nil) then click(skipLocation) end
        if (timer:check() > seconds) then
            usePreviousSnap(false)
            return -1
        end
    end
end

function waitMultiReg(target, seconds, skipLocation, reg)
    local timer = Timer()
    while (true) do
        for i, t in ipairs(target) do
            if (i == 1) then usePreviousSnap(false) else usePreviousSnap(true) end
            if not reg[i] == nil then
                if (reg[i]:exists(t, 0)) then
                    usePreviousSnap(false)
                    return i, getLastMatch()
                end
            else
                if (exists(t, 0)) then
                    usePreviousSnap(false)
                    return i, getLastMatch()
                end
            end
        end
        if (skipLocation ~= nil) then click(skipLocation) end
        if (timer:check() > seconds) then
            usePreviousSnap(false)
            return -1
        end
    end
end

function waitMultiRegIndex(target, seconds, skipLocation, reg, index, maxIndex)
    local timer = Timer()
    while (true) do
        for i, t in ipairs(target) do
            if (i == index) or (i == index -1) or (index == maxIndex) then
                if (i == 1) then usePreviousSnap(false) else usePreviousSnap(true) end
                if not reg[i] == nil then
                    if (reg[i]:exists(t, 0)) then
                        usePreviousSnap(false)
                        return i, getLastMatch()
                    end
                else
                    if (exists(t, 0)) then
                        usePreviousSnap(false)
                        return i, getLastMatch()
                    end
                end
            end
        end
        if (skipLocation ~= nil) then click(skipLocation) end
        if (timer:check() > seconds) then
            usePreviousSnap(false)
            return -1
        end
    end
end

function waitMultiClick(target, seconds)
    local timer = Timer()
    while (true) do
        for i, t in ipairs(target) do
            if (existsClick(t, 0)) then -- check once
                return i, getLastMatch()
            end
        end
        if (timer:check() > seconds) then return -1 end
    end
end

function existsMultiMaxSnap(region, target)
    local oldROI = Settings:getROI();
    local maxScore = 0
    local maxIndex = 0
    if (region ~= nil) then Settings:setROI(region) end
    --    region:highlight(2)
    for i, t in ipairs(target) do
        if (exists(t, 0)) then -- check once
            local score = getLastMatch():getScore()
            if (score > maxScore) then
                maxScore = score
                maxIndex = i
            end
        end
    end
    if (oldROI ~= nil) then
        Settings:setROI(oldROI)
    else
        Settings:setROI()
    end

    if (maxScore == 0) then return -1 end
    return maxIndex
end

function existsMultiMax(target, region)
    local oldROI = Settings:getROI()
    local maxScore = 0
    local maxIndex = 0
    local match
    if (region ~= nil) then Settings:setROI(region) end
    for i, t in ipairs(target) do
        if (i == 1) then usePreviousSnap(false) else usePreviousSnap(true) end
        if (exists(t, 0)) then -- check once
        local score = getLastMatch():getScore()
        if (score > maxScore) then
            maxScore = score
            maxIndex = i
            match = getLastMatch()
        end
        end
    end

    resumeROI(oldROI)
    usePreviousSnap(false)
    if (maxScore == 0) then
        return -1
    end
    return maxIndex, match
end

function resumeROI(oldROI)
    if (oldROI) then
        Settings:setROI(oldROI)
    else
        Settings:setROI()
    end
end

-- ============= UI related ================
function simpleDialog(title, message)
    dialogInit()
    addTextView(message)
    dialogShow(title)
end

function detectLanguage(target, list)
    local langList = ""
    for i, l in ipairs(list) do
        if (exists(target..l..".png", 0)) then return l end
        langList = langList .. l .."\n"
    end
    return (getLanguage())
end

function offOnScreen(second, pinLock, pin)
    keyevent(26) -- power
    wait(second)
    keyevent(82) --unlock
    if (pinLock) then
        type(pin) --passcode
        keyevent(66) -- enter
    end
end

-- ============= strings related ================
function fileExists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

function loadStrings(path)
    local language = getLanguage()
    local file = path.."strings."..getLanguage()..".lua";
    if (fileExists(file)) then
        dofile(file)
    else
        if (fileExists(path.."strings.lua")) then
            dofile(path.."strings.lua")
        end
    end
end

-- ============= Lua language related =============
function tableLookup(table, item)
    for i, t in ipairs(table) do
        if (t == item) then return i end
    end
    return -1
end

function tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- ========== Ankulua version related ==========
function isPro()
    if string.find(getVersion(), "pro" ) then
        return true
    else
        return false
    end
end
function isLatestVersion()
    if string.find(getVersion(), "6.8.0" ) then
        return true
    else
        return false
    end
end

-- ========== SWAR-X specific Functions ==========
-- Allow new functionality to partially be supported in the script
function isSupportedDimension()
    -- ## CHANGING THIS MAY BREAK THE SCRIPT ##
    if appUsableSize:getX() == 2560 and appUsableSize:getY() == 1600 then
        return true
    else
        return false
    end
end
function showStatsSection(shouldShow)
    ---Screen Stats
    statsSection:highlightOff()
    wait(.1)

    if shouldShow then
        statsSection:highlight(
            "Runs: \n"..
            "T: "..tostring(runsCount).." | V: "..tostring(victoryCount).." | D: "..tostring(deathCount).."\n"..
            "\n"..
            "Runes: \n"..
            "K: "..tostring(runesKeptCount).." | S: "..tostring(runesSoldCount)
        )
    end

end

-- ========== SWAR-X farming Functions ==========
function stageDetect()


end
function stageSelect(stageOverride,difficultyOverride)
	if debugAll == true then toast("[Function] stageSelect") end
	local findLvl = ""
	local Stage = areaSelect
	if stageOverride then
		Stage = stageOverride
	end

	local Difficulty = diffSelection
	if difficultyOverride then
		Difficulty = difficultyOverride
	end


---TODO: difficulty Selection Should only occur where it exists -- Scenario --TOA( Normal & Hard)
	if exists(Pattern(Difficulty..".png"):similar(0.8), 0) then
	else
		local choice, diffMatch = waitMulti(difficultyList, 15, false)
		click(diffMatch)
		wait(.5)
		existsClick(Pattern(Difficulty.."Select.png"):similar(0.8), 0)
		wait(.5)
	end

---TODO: This Selects then level that should be executed and needs to be modified to account for the diffrent kinds of area
	if AreaSelection <= 9 then
		local loopVarX = 1
		while loopVarX == 1 do
			if exists(Pattern(Stage):similar(0.8), 0) then
				loopVarX = 0
				break
			end
			loopVarX = loopVarX + 1
			if loopVarX >= 10 then
				loopVarX = - 1
				simpleDialog("Error", "Failed to Select Stage")
			end
			swipe(Location(600,1250),Location(600,500))
		end
		dungeonStageReg:existsClick(Pattern(Stage):similar(0.8), 0)
		if debugAll == true then getLastMatch():highlight(2) end

		wait(1)

		local levelSelect = "b"..tostring(levelSelection)..".png" --this is for the dungeons
		local loopVar = 1

		while loopVar == 1 do
			findLvl = exists(Pattern(levelSelect):similar(0.8), 0)
			if findLvl ~= "" then
				loopVar = 0
				break
			end
			loopVar = loopVar + 1
			if loopVar >= 10 then
				loopVar = - 1
				simpleDialog("Error", "Failed to match level with selection")
			end
			swipe(Location(1700,1300),Location(1700,500))
		end
		local regLevel = Region(findLvl:getX() - 300, findLvl:getY() - 55 , 1150, 250)                             					 if debugAll == true then regLevel:highlight(2) end
		regLevel:existsClick(scenarioFlash, 0)
	elseif AreaSelection > 9 and AreaSelection < 14 then
	--- TODO: add the stuff to handle Arena, Rift, World Boss


		--World Boss Enter Confirmation
		existsClick(yes)

	elseif AreaSelection >= 14 then
		local levelSelect = "scenarioLevel"..tostring(levelSelection)..".png" --this should apply to the scenario
		local loopVar = 1

		while loopVar == 1 do
			if exists(Pattern(levelSelect):similar(0.8), 0) then
				findLvl = getLastMatch()
				loopVar = 0
				break
			end
			loopVar = loopVar + 1
			if loopVar >= 10 then
				loopVar = - 1
				simpleDialog("Error", "Failed to match level with selection")
			end
			swipe(Location(1900,1300),Location(1900,500))
		end
		local regLevel = Region(findLvl:getX() - 50, findLvl:getY() - 40 , 1165, 290)                             					 if debugAll == true then regLevel:highlight(2) end
		regLevel:existsClick(scenarioFlash, 0)
	end

end
function levelSelect()


end
