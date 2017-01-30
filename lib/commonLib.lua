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

function autoResize(target, defaultDimension, immersive)
    local max = 0
    local localX = defaultDimension
    if (exists(target, 0)) then
        return defaultDimension
    end

    setImmersiveMode(not immersive)
    if (exists(target, 0)) then
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
        return -1
    end

    return (localX + 9)
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

function existsMultiMax(region, target)
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


function simpleDialog(title, message)
    dialogInit()
    addTextView(message)
    dialogShow(title)
end

function stageDetect()


end

function stageSelect()


end




function levelSelect()


end

