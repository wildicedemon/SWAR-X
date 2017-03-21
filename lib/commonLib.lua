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

-- ========== SWAR-X specific Functions ==========
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
function showStatsSection()
    ---Screen Stats
    statsSection:highlightOff()
    wait(.1)
    statsSection:highlight(
        "Runs: \n"..
        "T: "..tostring(runsCount).." | V: "..tostring(victoryCount).." | D: "..tostring(deathCount).."\n"..
        "\n"..
        "Runes: \n"..
        "B: "..tostring(runesKeptCount).." | S: "..tostring(runesSoldCount)
    )
end
function stageDetect()


end

function stageSelect()


end




function levelSelect()


end
