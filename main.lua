-- =========
-- Settings
-- =========
scriptVersion = "1.0"

localPath = scriptPath()
--Language Detection
--language = detectLanguage("cancelWord.", {"en", "zh", "ko"})
--language = getLanguage()
language = "en"
imgPath = localPath.."images"
dofile(localPath.."lib/commonLib.lua")
dofile(localPath.."lib/images.lua")
appUsableSize = getAppUsableScreenSize()
toast ("Auto Detected Resolution: " .. appUsableSize:getX() .. " x " .. appUsableSize:getY())
Settings:setScriptDimension(true, 2560)
Settings:setCompareDimension(true, appUsableSize:getX())
Settings:set("MinSimilarity", 0.90)
setImmersiveMode(false)

-- Give more details when the script is stopped in all cases
if isLatestVersion() then
	setStopMessage(
		"Start time: "..os.date("%H:%M:%S - %d/%m/%Y" , os.time()).."\n"..
		"Ankulua v"..getVersion().."\n"..
		"CompareDimension: " .. appUsableSize:getX() .. " x " .. appUsableSize:getY().."\n"
	)
else
	print(
		"Start time: "..os.date("%H:%M:%S - %d/%m/%Y" , os.time()).."\n"..
		"Ankulua v"..getVersion().."\n"..
		"CompareDimension: " .. appUsableSize:getX() .. " x " .. appUsableSize:getY().."\n"
	)
end

-- =========
-- Variables
-- =========
AMonMax = 0
fileCount = 0
monsterRepCount = 0
arenaRepCount = 0
arenaLvlCount = 0
arenaEmptyCount = 0
arenaMain = 0
arenaExe = 1
swipeCount = 0
refillEnergyLimit = 0
rstars = 0
rslot = 0
rrarity = ""
rprime = ""
rsub = 0
levelSelect = ""

-- ========== Statistics ==========
runsCount = 0
victoryCount = 0
deathCount = 0
runesKeptCount = 0
runesSoldCount = 0

-- ========== Region Update Flags ==========
battleGearWheelRegFlag = 0
victoryDiamondRegFlag = 0
worldMapRegFlag = 0
bigFlashRegFlag = 0
arenaBigWingRegFlag = 0
arenaResultsRegFlag = 0
bigCancalRegFlag = 0

-- ========================
-- Graphical User Interface
-- ========================
-- Resolution & StartScreen
dialogInit()
-- Spinners
spinnerRes = {"2560x1600", "2560x1440", "1920x1200", "1920x1080", "1280x800", "1280x720"}
spinnerAction = {"Dungeon / Scenario", "Trial of Ascension", "Rift of Worlds", "Rune upgrading"}
-- GUI
addTextView("  ") addTextView("Resolution: ") 
addTextView("  ") addTextView(appUsableSize:getX() .. "x" .. appUsableSize:getY() .. " (Auto detected)")newRow()
addTextView("  ") addTextView("Custom resolution: ") addSpinner("resChoice", spinnerRes, appUsableSize:getX() .. "x" .. appUsableSize:getY()) newRow()
addTextView("  ") newRow()
addTextView("  ") addTextView("What would you like to do?") newRow()
addRadioGroup("action", 1)
addRadioButton("Dungeon / Scenario", 1)
--addRadioButton("Trial of Ascension", 2)
--addRadioButton("Rift of Worlds", 3)
if isSupportedDimension() then addRadioButton("Rune upgrading", 4) end
addTextView("  ") newRow()
dialogShow("Resolution & Action")

-- Resolution of images and compareDimension
if (resChoice ~= nil) then
	if resChoice == "2560x1600" or resChoice == "1920x1200" or resChoice == "1280x800" then
		dofile(localPath.."lib/regions/regions_2560x1600.lua")
	elseif resChoice == "2560x1440" or resChoice == "1920x1080" or resChoice == "1280x720" then
		dofile(localPath.."lib/regions/regions_2560x1440.lua")
	end
	imgPath = imgPath.."/"..resChoice
	setImagePath(imgPath)

	if resChoice == "1920x1200" or resChoice == "1920x1080" or resChoice == "1280x800" or resChoice == "1280x720" then
		simpleDialog("WARNING: Experimental resolution", "With the resolution you have choosen this script uses auto-resized images. \n Please keep in mind that this means the script may not fully work. \n\n If you encounter any issues please report them!")
	end
else
	scriptExit("Error", "No resolution seems to be choosen. Please report this issue.")
end

-- == Configuration ==
if action == 1 or action == 2 or action == 3 then -- GUI for dungeon / scenario
	dofile(localPath.."lib/dialogs/dungeonScenarioDialog.lua")
elseif action == 4 then -- GUI for rune upgrading
	dofile(localPath.."lib/dialogs/runeUpgradeDialog.lua")
else
	scriptExit("Error", "No action seems to be choosen. Please report this issue.")
end

--Dim Screen
if (dim) then
	setBrightness(1)
end

-- =========================
-- SWAR-X specific Functions
-- =========================
function keyNum()
	local preMinSimilarity = Settings:get("MinSimilarity")
	Settings:set("MinSimilarity", 0.7)
	local anchor = bottomLeft:wait("slash.png")
	local numRegion = Region(anchor:getX() - 110, anchor:getY(), 110, anchor:getH())
	if debugAll == true then numRegion:highlight(1) end
	local num = numberOCRNoFindException(numRegion, "vFlash")
	Settings:set("MinSimilarity", preMinSimilarity)
end
function clickButton(target, num)
	if debugAll == true then toast("[Function] clickButton") end
	if (exists(target,4)) then
		if debugAll == true then toast("button found") end
		local allButton = findAll(target)
		local sortFunc = function(a, b) return (a:getX() < b:getX()) end
		table.sort(allButton, sortFunc)
		if debugAll == true then allButton[num]:highlight(1) end
		allButton[num]:setTargetOffset(37,0)
		click(allButton[num])
	end
end
function refillEnergy()
	if debugAll == true then toast("[Function] refillEnergy") end
	if (limitEnergyRefills and refillEnergyLimit > 0 or not limitEnergyRefills) then
		refillEnergyLimit = refillEnergyLimit - 1
		waitClick(yes, 3)
		rechargeEnergy:waitClick(rechargeFlash, 3)
		waitClick(yesRecharge, 3)

		-- If not enough crystals
		if exists(yes) then
			keyevent(4)  -- back button
			keyevent(4)  -- back button
			toast("Not enough crystals, waiting 1 minute before retrying.")
			wait(60)
		else
			keyevent(4)  -- back button
			keyevent(4)  -- back button
		end
	else
		keyevent(4)  -- back button
		toast("Not enough energy, waiting 10 minutes before retrying.")
		wait(10 * 60)
	end
end
function refillArena()
	if debugAll == true then toast("[Function] refillArena") end
	if (limitWingsRefills and refillWingsLimit > 0 or not limitWingsRefills) then
		refillWingsLimit = refillWingsLimit - 1
		waitClick(yes, 2)
		waitClick(rechargeWing, 3)
		waitClick(yesRecharge, 2)

		-- If not enough crystals
		if exists(yes) then
			keyevent(4)  -- back button
			keyevent(4)  -- back button
			toast("Not enough crystals, waiting 1 minute before retrying.")
			wait(60)
		else
			keyevent(4)  -- back button
			keyevent(4)  -- back button
		end
	else
		keyevent(4)  -- back button
		toast("Not enough wings, waiting 10 minutes before retrying.")
		wait(10 * 60)
	end

	areaGoTo(areaArena)
end
function ripairs(t)
	if debugAll == true then toast("[Function] ripairs") end
	local function ripairs_it(t,i)
		i=i-1
		local v=t[i]
		if v==nil then return v end
		return i,v
	end
	return ripairs_it, t, #t+1
end

function multiCancel()
	if debugAll == true then toast("[Function] multiCancel") end
	local rewardEnd, match = regionWaitMulti(cancelClickList,45, debugAll, false)
	if (rewardEnd == nil) then
		toast("nil use BackUp [multiCancel]")
		local rewardEnd, match = waitMulti(cancelList,45,false)
	elseif (rewardEnd == -1) then
		toast("-1 use BackUp [multiCancel]")
		local rewardEnd, match = waitMulti(cancelList,45,false)
	end
	if (rewardEnd ~= nil) then click(match) end
	if (debugAll == true) then
		if (rewardEnd == nil) then toast("rewardEnd returned nil [multiCancel]")
		elseif (rewardEnd == -1) then toast("rewardEnd returned -1 [multiCancel]")
		elseif (rewardEnd == 1) then toast("Ok [multiCancel]")
		elseif (rewardEnd == 2) then toast("Yes [multiCancel]")
		elseif (rewardEnd == 3) then toast("CancelCross [multiCancel]")
		elseif (rewardEnd == 4) then toast("Cancel2 [multiCancel]")
		elseif (rewardEnd == 5) then toast("CancelLong [multiCancel]")
		elseif (rewardEnd == 6) then toast("CancelRefill [multiCancel]")
		else toast("Unknown [multiCancel]") end
	end
end
function arenaRefresh()
	if debugAll == true then toast("[Function] arenaRefresh") end
	arenaRefreshReg:existsClick(arenaRefreshList, 0)
	arenaRefreshListReg:existsClick(arenaRefreshListConfirm, 0)
	wait(2)
	while true do
		if arenaRefreshWaitReg:exists(arenaRefreshWait, 0) then
		wait(2)
		arenaRefreshListReg:existsClick(arenaRefreshListConfirm, 0)
		else
			break
		end

	end
end
function checkIfMax()
	if debugAll == true then toast("[Function] checkIfMax") end
	for i, Reg in ipairs(RegionMatchEXP) do
		if (i == 1) then usePreviousSnap(false) else usePreviousSnap(true) end
		if AMonMax == 1 then click(Location(1320,720)) break end
		if debugAll == true then Reg:highlight(2) end
		if Reg:exists(expBarMax, 0) then
			getLastMatch():highlight(.25)
			AMonMax = 1
		else
			AMonMax = 2
		end
	end
	usePreviousSnap(false)
	click(Location(1320,720))
end
function freshFodderLevel(slot)
	if debugAll == true then toast("[Function] freshFodderLevel") end
	local pFood = Region(slot:getX() + 110, slot:getY() + 185 , 130, 100)                             					 if debugAll == true then pFood:highlight(2) end
	local pFoodClick = Location(pFood:getX(), pFood:getY())

	local preMinSimilarity = Settings:get("MinSimilarity")
	Settings:set("MinSimilarity", 0.65) --works with issues at .7, .75 misses many monsters
	local lv, lvfound = numberOCRNoFindException(pFood,"LowLv")                                      					  if debugAll == true then  pFood:highlight(tostring(lv),2) end
	Settings:set("MinSimilarity", preMinSimilarity)
	return lv, lvfound, pFoodClick
end
function monsterLevelCheck()
	if debugAll == true then toast("[Function] monsterLevelCheck") end
	for _, Reg in ipairs(RegionMatch) do
		if (i == 1) then usePreviousSnap(false) else usePreviousSnap(true) end
		local newReg = Region(Reg:getX() + 152,Reg:getY() + 184,Reg:getW() - 160,Reg:getH() - 184)
		-- local Stars = Region(Reg:getX(),Reg:getY(),90,90)
		local lv = numberOCRNoFindException(newReg,"lvl")
		if debugAll == true then newReg:highlight(tostring(lv),.5) end
		local numStar = existsMultiMaxSnap(Reg,{oneStar, twoStar, threeStar, fourStar, fiveStar, sixStar, emptyMon})
		if (numStar == -1) then toast("Unknown Error") elseif numStar == 7 then toast("Slot Empty Why Are we Testing This?") end
		if debugAll == true then toast(numStar.." Star Monster") end
		if debugAll == true then Reg:highlight(1) end
		if lv == 15 and numStar == 1  then click(Location(Reg:getX() + 145, Reg:getY() + 145)) monsterRepCount = monsterRepCount + 1
		elseif lv == 20 and numStar == 2 then click(Location(Reg:getX() + 145, Reg:getY() + 145)) monsterRepCount = monsterRepCount + 1
		elseif lv == 25 and numStar == 3 then click(Location(Reg:getX() + 145, Reg:getY() + 145)) monsterRepCount = monsterRepCount + 1
		elseif lv == 30 and numStar == 4 then click(Location(Reg:getX() + 145, Reg:getY() + 145)) monsterRepCount = monsterRepCount + 1
		elseif lv == 35 and numStar == 5 then click(Location(Reg:getX() + 145, Reg:getY() + 145)) monsterRepCount = monsterRepCount + 1
		elseif lv == 40 and numStar == 6 then click(Location(Reg:getX() + 145, Reg:getY() + 145)) monsterRepCount = monsterRepCount + 1
		elseif numStar == 7 then toast("Slot is empty fill with monster") monsterRepCount = monsterRepCount + 1
		else   toast("The Monster Is NOT Max Level Yet.")
		end
	end
	usePreviousSnap(false)
end
function arenaLevelCheck()
	if debugAll == true then toast("[Function] arenaLevelCheck") end
	showStatsSection(false)
	arenaLvlCount = 0
	arenaRepCount = 0
	arenaEmptyCount = 0
	for _, Reg in ipairs(arenaRegionMatch) do
		if (i == 1) then usePreviousSnap(false) else usePreviousSnap(true) end
		local newReg = Region(Reg:getX() + 152,Reg:getY() + 184,Reg:getW() - 160,Reg:getH() - 184)
		-- local Stars = Region(Reg:getX(),Reg:getY(),90,90)
		local lv = numberOCRNoFindException(newReg,"lvl")
		if debugAll == true then newReg:highlight(tostring(lv),.5) end
		local numStar = existsMultiMaxSnap(Reg,{oneStar, twoStar, threeStar, fourStar, fiveStar, sixStar, arenaEmptyMon})
		if (numStar == -1) then toast("Unknown Error") elseif numStar == 7 then toast("Slot Empty") end
		if debugAll == true and numStar <= 6 then toast(numStar.." Star Monster") end
		if debugAll == true then Reg:highlight(1) end
		arenaLvlCount = arenaLvlCount + lv
		if numStar >= 1 and numStar <= 6 then arenaRepCount = arenaRepCount + 1
		elseif numStar == 7 then toast("Slot is empty") arenaEmptyCount = arenaEmptyCount + 1
		else   toast("Unknown Error(ArenaLevelCheck-Stars")
		end
	end
	usePreviousSnap(false)
end
function swapMaxFood()
	if debugAll == true then toast("[Function] swapMaxFood") end
	if find(bigCancel) then
		if AMonMax == 1 then
			AMonMax = 0
			monsterLevelCheck()
			while not EndofMonL:exists(endOfMonList, 0) do
				swipe(monListRight,monListLeft)
			end
			wait(1)
		while monsterRepCount > 0 do
				local abort = 20
						if debugAll == true then NewFodder:highlight(1) end
						local FodderList = listToTable(NewFodder:findAll(fodderAnchor))
						local tCount = tableLength(FodderList)
						if debugAll == true then toast(tCount..": Anchors Found") end
						for i, slot in ripairs(FodderList) do
							if (i == 1) then usePreviousSnap(false) else usePreviousSnap(true) end
							local lv, lvfound, pFoodClick = freshFodderLevel(slot)
							if lv <= 14  and lvfound == true then click(pFoodClick) monsterRepCount = monsterRepCount - 1
								if monsterRepCount <= 0 then monsterLevelCheck() end
								if monsterRepCount <= 0 then break end
							elseif i >= tCount then
								swipe(monListLeft,monListRight)
								abort = abort - 1
								wait(1)
							end
						end
						usePreviousSnap(false)
						if abort <= 1 then
							break
						end
			end
		else
			toast("Called Outside of expected Time Frame!, XXXX")
		end
	end
end
function runeStarEval()
	if debugAll == true then toast("[Function] runeStarEval") end
	local starFind = listToTable(runeStarRegion:findAll(runeStar))
	local starCount = tableLength(starFind)
	local runeStarWord = "runeStar"..tostring(starCount)..".png"
	if runeStarRegion:exists(Pattern(runeStarWord):similar(.9), 3) then
		rstars = starCount
		if debugAll == true then runeStarsRegionD:highlight(tostring(starCount), 2) end
		if starCount < minRuneStar then
			return false
		else
			return true
		end
	else
		local runeStarMatch = existsMultiMaxSnap(runeStarRegion,{
			runeStar6,
			runeStar5,
			runeStar4,
			runeStar3,
			runeStar2,
			runeStar1})
		if runeStarMatch < minRuneStar then
			return false
		else
			return true
		end
		toast("Found a "..toString(starCount).." star rune")
	end
end
function runeDim()
	if debugAll == true then toast("[Function] runeDim") end
	local runeCompDim = ""
	local runeDimMatch = existsMultiMaxSnap(runeTypeAndSlotRegion,{
		Pattern("runeWord.png"):similar(0.9),
		Pattern("runeWord98.png"):similar(0.9),
		Pattern("runeWord96.png"):similar(0.9),
		Pattern("runeWord94.png"):similar(0.9),
		Pattern("runeWord92.png"):similar(0.9),
		Pattern("runeWord90.png"):similar(0.9),
		Pattern("runeWord88.png"):similar(0.9),
		Pattern("runeWord86.png"):similar(0.9),
		Pattern("runeWord84.png"):similar(0.9),
		Pattern("runeWord82.png"):similar(0.9),
		Pattern("runeWord80.png"):similar(0.9),
		Pattern("runeWord78.png"):similar(0.9),
		Pattern("runeWord76.png"):similar(0.9),
		Pattern("runeWord74.png"):similar(0.9),
		Pattern("runeWord72.png"):similar(0.9),
		Pattern("runeWord70.png"):similar(0.9),
		Pattern("runeWord68.png"):similar(0.9),
		Pattern("runeWord66.png"):similar(0.9),
		Pattern("runeWord64.png"):similar(0.9)})
	if runeDimMatch == -1 then
		scriptExit("Error", "Couldn't find a matching runeWord for runeDimMatch.")
	elseif runeDimMatch == 1 then
		runeCompDim = ""
	else
		runeCompDim = tostring((100 - ((runeDimMatch -1) * 2)))
		if debugAll == true then toast("runeCompDim = "..runeCompDim.." [runeDime]") end
	end

	return runeCompDim
end
function runeRarityEvaluation ()
	if debugAll == true then toast("[Function] runeRarityEvaluation") end
	local runeRarityMatch = existsMultiMaxSnap(runeRarityRegion,{
		runeRarityNormal,
		runeRarityMagic,
		runeRarityRare,
		runeRarityHero,
		runeRarityLegend})

		if runeRarityMatch == -1 then
			rrarity = "Nil"
			varRuneRarity = runeRarityMatch
			return true
		end

	varRuneRarity = runeRarityMatch
	if runeRarityMatch == 1 then
		local RuneR = tostring("Common")
		rrarity = RuneR
	elseif runeRarityMatch == 2 then
		local RuneR = tostring("Magic")
		rrarity = RuneR
	elseif runeRarityMatch == 3 then
		local RuneR = tostring("Rare")
		rrarity = RuneR
	elseif runeRarityMatch == 4 then
		local RuneR = tostring("Hero")
		rrarity = RuneR
	elseif runeRarityMatch == 5 then
		local RuneR = tostring("Legend")
		rrarity = RuneR
	end

	if debugAll == true then getLastMatch():highlight(rrarity, 2) end

	if runeRarityMatch < minRuneRarity then
		return false
	else
		return true
	end

end
function runeSlotEvaluation()
	if debugAll == true then toast("[Function] runeSlotEvaluation") end
	local preMinSimilarity = Settings:get("MinSimilarity")
	Settings:set("MinSimilarity", 0.7)
	local runeSlotMatch = -1
	if isSupportedDimension() then
		runeSlotMatch = existsMultiMaxSnap(runeStarRegion,{
			runeSlot2,
			runeSlot3,
			runeSlot4,
			runeSlot5,
			runeSlot6})
		if debugAll == true then runeStarsRegionD:highlight(tostring(runeSlotMatch),2) end
		if runeSlotMatch == -1 then runeSlotMatch = 1 end
	else
		local runeCompDim = runeDim()
		runeSlotMatch = existsMultiMaxSnap(runeTypeAndSlotRegion,{
			"runeSlot1"..runeCompDim..".png",
			"runeSlot2"..runeCompDim..".png",
			"runeSlot3"..runeCompDim..".png",
			"runeSlot4"..runeCompDim..".png",
			"runeSlot5"..runeCompDim..".png",
			"runeSlot6"..runeCompDim..".png"})
		if debugAll == true then getLastMatch():highlight(tostring(runeSlotMatch),2) end
	end
	rslot = runeSlotMatch
	Settings:set("MinSimilarity", preMinSimilarity)
	return runeSlotMatch
end
function runePrimaryEvaluation()
	if debugAll == true then toast("[Function] runePrimaryEvaluation") end
	local slot = runeSlotEvaluation()
	if slot == -1 then
		rprime = "Nil"
		return true
	elseif slot == 1 or slot == 3 or slot == 5 then
		rprime = "N/A"
		return true
	end
	local runePrimeMatch = existsMultiMaxSnap(runePrimeRegion,{
		runePrimeHP,
		runePrimeATK,
		runePrimeDEF,
		runePrimeSPD,
		runePrimeCRIRate,
		runePrimeCRIDmg,
		runePrimeRES,
		runePrimeACC})
	if runePrimeMatch == 1 then
		local RuneP = tostring("HP")
		rprime = RuneP
	elseif runePrimeMatch == 2 then
		local RuneP = tostring("ATK")
		rprime = RuneP
	elseif runePrimeMatch == 3 then
		local RuneP = tostring("DEF")
		rprime = RuneP
	elseif runePrimeMatch == 4 then
		local RuneP = tostring("SPD")
		rprime = RuneP
	elseif runePrimeMatch == 5 then
		local RuneP = tostring("CRI Rate")
		rprime = RuneP
	elseif runePrimeMatch == 6 then
		local RuneP = tostring("CRI Dmg")
		rprime = RuneP
	elseif runePrimeMatch == 7 then
		local RuneP = tostring("Resistance")
		rprime = RuneP
	elseif runePrimeMatch == 8 then
		local RuneP = tostring("Accuracy")
		rprime = RuneP
	elseif runePrimeMatch == -1 then
		rprime = "Fail"
	end
	if debugAll == true then getLastMatch():highlight(RuneP, 3) end
	if  primeStatKeep[runePrimeMatch] == 0 then
		return false
	else
		if runePrimeRegion:exists(runePrimePercentage) then
			rprime = rprime.."%"
			return true
		else
			if runePrimeMatch == 4 then -- Keep SPD runes (they will not match percentage)
				return true
			else
				return false
			end
		end
	end
end
function runeSubEvaluation()
	if debugAll == true then toast("[Function] runeSubEvaluation") end
	if debugAll == true then runeSubRegion:highlight(1) end
	if runeSubRegion:exists(runeSubPercentage) then
		subStatFind = listToTable(runeSubRegion:findAll(runeSubPercentage))
		subStatCent = tableLength(subStatFind)
	else
		subStatCent = 0
	end
	if runeSubRegion:exists(runeSubSPD, 3) then
		subStatCent = subStatCent + 1
	end

	if varRuneRarity == nil or CBRuneEvalRarity == false then runeRarityEvaluation() end
	if varRuneRarity == 1 then varRuneRarity = nil return true end
	if varRuneRarity == -1 then rsub = "Nil" return true end
	local subCent = math.floor((subStatCent / (varRuneRarity - 1) ) * 100)
	rsub = subCent
	if debugAll == true then
		local wCount = 10
		while wCount > 0 do
			if debugAll == true then
				if vibe == true then vibrate(1) end
				toast(tostring(subCent).."% of %Subs on a "..varRuneRarity.." Rune")
			end
			wait(2)
			wCount = wCount - 1
		end
	end
	if subCent < minCentSubStat then
		varRuneRarity = nil
		return false
	else
		varRuneRarity = nil
		return true
	end
end
function runeEval()
	if debugAll == true then toast("[Function] runeEval") end
	showStatsSection(false)
	local sellRune = 0
	--all called functions return false unless keep conditions meet where they return true
	if sellRune == 0 and CBRuneEvalStar == true and runeStarEval() == false then
		sellRune = 1
	end
	if sellRune == 0 and CBRuneEvalRarity == true and runeRarityEvaluation() == false then
		sellRune = 1
	end
	if sellRune == 0 and CBRuneEvalPrimary == true and runePrimaryEvaluation() == false then
		sellRune = 1
	end
	if sellRune == 0 and CBRuneEvalSubCent == true and runeSubEvaluation() == false then
		sellRune = 1
	end

	runeEvalStats:highlight("Stars: "..tostring(rstars).."\n"..
							"Slot: "..tostring(rslot).."\n"..
							"Rarity: "..rrarity.."\n"..
							"Prime: "..rprime.."\n"..
							"Sub: "..tostring(rsub).."%\n")
	wait(2)
	if sellRune == 1 then
		setImagePath(localPath.."runes/")
		fileCount = fileCount + 1
		runeSnap:save("Sold - "..rrarity.." Rune ("..fileCount..").png")
		wait(.4)
		runeEvalStats:highlightOff()
		setImagePath(imgPath)
		return true
	else
		setImagePath(localPath.."runes/")
        fileCount = fileCount + 1
		runeSnap:save("Kept - "..rrarity.." Rune ("..fileCount..").png")
		wait(.4)
		runeEvalStats:highlightOff()
		setImagePath(imgPath)
		return false
	end
end
function runeSale()
	if debugAll == true then toast("[Function] runeSale") end
	--TODO: This is where to Modify for only selling 5 and 6 star runes.
	if (buttonRegion:exists(sell)) then
		if debugAll == true then
			toast("Found: Sell Rune img")
			getLastMatch():highlight(0.5)
		end
		wait(1)
		if CBRuneEval == true then
			if runeEval() == true then
				if debugAll == true then toast("This Rune Will be Sold!") wait(.75)end
				if debugAll == true then
					if vibe == true then vibrate(1) end
					wait(.5)
					if vibe == true then vibrate(1) end
				end
				if debugAll == true then
					toast("Selling Rune in 15! (Screenshot taken)")
					setImagePath(localPath.."runes/")
					fileCount = fileCount + 1
                    runeSnap:save("Sold - "..rrarity.." Rune ("..fileCount..").png")
					wait(.4)
					runeEvalStats:highlightOff()
					setImagePath(imgPath)
					wait(15)
				end
				buttonRegion:existsClick(sell, 0)
				if debugAll == true then toast("Rune Sold!") wait(.75) end
				existsClick(yes)
				runesSoldCount = runesSoldCount + 1
				showStatsSection(true)
				local sellResponse, match = waitMulti({yes, worldMap}, 3)
				if (sellResponse == 1) then
					click(match)
				end

			else
				if debugAll == true then toast("Keep Rune!") wait(.75) end
				if debugAll == true then toast("Keeping Rune!") wait(.75) end
				runesKeptCount = runesKeptCount + 1
				showStatsSection(true)
				if not existsClick(get) then
					multiCancel()
				end
			end
		else
			buttonRegion:existsClick(sell)
			runesSoldCount = runesSoldCount + 1
			wait(.5)
			yesWordPngReg:existsClick(yes)
		end

	elseif not (buttonRegion:exists(sell)) then
		if debugAll == true then toast("No Sell Buttion Found") end
		multiCancel()
	end
end
function areaGoTo(areaOverride)
	if debugAll == true then toast("[Function] areaGoTo") end
	if AreaSelection <= 9 then
		destination = areaCairos
	end
	if areaOverride == arena then
		destination = areaArena
	end

	if areaMapReg:exists(areaMap, 0) then

	elseif battleButtonReg:existsClick(battleButton, 0) then
	else
		local loopW = 10
		while loopW >= 1 do
		keyevent(4)
			if existsClick(cancelRefill, 0) then
				existsClick(yes)
			end
			if battleButtonReg:exists(battleButton, 0) then
				if exists(endNow, 0) then
					keyevent(4)
				end
				loopW = -2
				battleButtonReg:existsClick(battleButton, 0)
				break
			end
			loopW = loopW - 1
			if loopW == 0 then
			toast("Unknown Error [Area Return]")
			end
		end
	end
	wait(.75)


	local loopVarG = 1
	if debugAll == true then toast("Navigating to: "..spinnerAreaReturn[AreaSelection]) end
	while loopVarG == 1 do
		if existsClick(Pattern(destination):similar(0.8), 2) then
			if debugAll == true then getLastMatch():highlight(2) end
			wait(.75)
			if existsClick(Pattern(destination):targetOffset(0,-80):similar(0.8), 0) then 
				if debugAll == true then  getLastMatch():highlight(2) end
				yesWordPngReg:existsClick(yes, 0.5)
				if areaOverride == arena then
					arenaSelectNormalReg:existsClick(arenaSelectNormal, 0.5)
				end
			end
			loopVarG = 0
			break
		end
		loopVarG = loopVarG + 1
		if loopVarG >= 10 then
			loopVarG = - 1
			simpleDialog("Error", "Failed to Select Stage")
		end
		swipe(Location(1900,900),Location(600,900))
	end
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

function timeCheck(minutes)
	if debugAll == true then toast("[Function] timeCheck") end
	seconds = minutes * 60
	if (xTime:check() > seconds) then
		xTime = Timer()
		return true
	else
		return false
	end
end

-- =============================
-- Image Matching & Region Lists
-- =============================
stageClickList = {
	{target = battleGearWheel, region = battleGearWheelReg, id = "battleGearWheelClick"},
	{target = victoryDiamond, region = victoryDiamondReg, id = "victoryClick"},
	{target = victoryRaidDamage, region = victoryRaidDamageReg, id = "victoryRaidDamage"},
	{target = worldMap, region = worldMapReg, id = "worldMapClick"},
	{target = bigFlash, region = bigFlashReg, id = "bigFlashClick"},
	{target = defeatedDiamond, region = left, id = "defeatedDiamondClick"}
}
arenaClickList = {
	{target = battleGearWheel, region = battleGearWheelReg, id = "battleGearWheelClick"},
	{target = victoryDiamond, region = victoryDiamondReg, id = "victoryClick"},
	{target = arenaResults, region = arenaResultsReg, id = "arenaResultsClick"},
	{target = arenaBigWing, region = arenaBigWingReg, id = "arenaBigWingClick"}
}
backList = {
	battleGearWheel,
	victoryDiamond,
	victoryRaidDamage,
	worldMap,
	bigFlash,
	defeatedDiamond,
	bigCancel,
	networkDelay,
	networkConnection,
	cancelRefill,
	areaMap,
	battleButton
}
arenabackList = {
	battleGearWheel,
	victoryDiamond,
	arenaResults,
	arenaBigWing,
	bigCancel,
	rechargeWing,
	networkDelay,
	networkConnection,
	cancelRefill,
	areaMap,
	battleButton
}
cancelClickList = {
	{target = ok, region = okenReg, id ="okClick"},
	{target = yes, region = yesWordPngReg, id ="yesClick"},
	{target = cancelCross, region = cancelCrossReg, id ="cancelCrossClick"},
	{target = cancel2, region = cancel2Reg, id ="cancel2Click"},
	{target = cancelLong, region = cancelLongReg, id ="cancelLongClick"},
	{target = cancelRefill, region = cancelRefillReg, id ="cancelRefillClick"}
}
cancelList = {
	ok,
	yes,
	cancelCross,
	cancel2,
	cancelLong,
	cancelRefill
}
difficultyList = {
	scenarioNormal,
	scenarioHard,
	scenarioHell
}
arenaRegionMatch = { eTopMon, eLeftMon, eBottomMon, eRightMon}
if (nextArea) then
	table.insert(stagelist, "ilin.png")
	table.insert(stagelist, "libia.png")
	table.insert(stagelist, "dulander.png")
end
if (nextArea) then flashRequireRegion = right else flashRequireRegion = left end
RegionMatch = {}
if (SwapMaxTop) then  table.insert(RegionMatch, TopMon) end
if (SwapMaxLeft) then  table.insert(RegionMatch, LeftMon) end
if (SwapMaxRight) then  table.insert(RegionMatch, RightMon) end
if (SwapMaxBottom) then  table.insert(RegionMatch, BottomMon) end
RegionMatchEXP = {}
if (SwapMaxTop) then  table.insert(RegionMatchEXP, TopMonEXP) end
if (SwapMaxLeft) then  table.insert(RegionMatchEXP, LeftMonEXP) end
if (SwapMaxRight) then  table.insert(RegionMatchEXP, RightMonEXP) end
if (SwapMaxBottom) then  table.insert(RegionMatchEXP, BottomMonEXP) end


if SwapMaxTop == true or SwapMaxLeft == true  or SwapMaxRight == true or SwapMaxBottom == true then  skip = false else skip = true end

minRuneStar = tonumber(runeStars)
minRuneRarity = tonumber(runeRarity)

if runeSubCentage == 1 then minCentSubStat = 25
elseif runeSubCentage == 2 then minCentSubStat = 33
elseif runeSubCentage == 3 then minCentSubStat = 50
elseif runeSubCentage == 4 then minCentSubStat = 66
elseif runeSubCentage == 5 then minCentSubStat = 75
elseif runeSubCentage == 6 then minCentSubStat = 100
end

if AreaSelection == 1 then areaSelect = dungeonGiants
elseif AreaSelection == 2 then areaSelect = dungeonDragons
elseif AreaSelection == 3 then areaSelect = dungeonNecros
elseif AreaSelection == 4 then areaSelect = dungeonLight
elseif AreaSelection == 5 then areaSelect = dungeonDark
elseif AreaSelection == 6 then areaSelect = dungeonFire
elseif AreaSelection == 7 then areaSelect = dungeonWater
elseif AreaSelection == 8 then areaSelect = dungeonWind
elseif AreaSelection == 9 then areaSelect = dungeonMagic
elseif AreaSelection == 10 then areaSelect = areaTrial
elseif AreaSelection == 11 then areaSelect = areaRift
elseif AreaSelection == 12 then areaSelect = areaArena
elseif AreaSelection == 13 then areaSelect = areaWorld
elseif AreaSelection == 14 then areaSelect = areaGaren
elseif AreaSelection == 15 then areaSelect = areaMtSiz
elseif AreaSelection == 16 then areaSelect = areaMtWhite
elseif AreaSelection == 17 then areaSelect = areaKabir
elseif AreaSelection == 18 then areaSelect = areaTalain
elseif AreaSelection == 19 then areaSelect = areaHydeni
elseif AreaSelection == 20 then areaSelect = areaTamor
elseif AreaSelection == 21 then areaSelect = areaVrofagus
elseif AreaSelection == 22 then areaSelect = areaAiden
elseif AreaSelection == 23 then areaSelect = areaFerun
elseif AreaSelection == 24 then areaSelect = areaMtRunar
elseif AreaSelection == 25 then areaSelect = areaChiruka
end

if diffSelection == 1 then diffSelection = "scenarioNormal"
elseif diffSelection == 2 then diffSelection = "scenarioHard"
elseif diffSelection == 3 then diffSelection = "scenarioHell"
end

primeStatKeep = {}
if (keepRunePrimeHP) then  table.insert(primeStatKeep, 1) else table.insert(primeStatKeep, 0) end
if (keepRunePrimeATK) then  table.insert(primeStatKeep, 1) else table.insert(primeStatKeep, 0) end
if (keepRunePrimeDEF) then  table.insert(primeStatKeep, 1) else table.insert(primeStatKeep, 0) end
if (keepRunePrimeSPD) then  table.insert(primeStatKeep, 1) else table.insert(primeStatKeep, 0) end
if (keepRunePrimeCRIRate) then  table.insert(primeStatKeep, 1) else table.insert(primeStatKeep, 0) end
if (keepRunePrimeCRIDmg) then  table.insert(primeStatKeep, 1) else table.insert(primeStatKeep, 0) end
if (keepRunePrimeRES) then  table.insert(primeStatKeep, 1) else table.insert(primeStatKeep, 0) end
if (keepRunePrimeACC) then  table.insert(primeStatKeep, 1) else table.insert(primeStatKeep, 0) end

-- ==================================
-- Scenario / Dungeon / Raid routines
-- ==================================
-- Battle Preperation Routine
function battlePreperationRoutine(choice, stageMatch)
	currentIndex = 4
	if AMonMax == 1 then swapMaxFood() end
	if AMonMax == 2 then AMonMax = 0 end
	if bigFlashRegFlag == 0 then
		bigFlashReg = regionFinder(stageMatch, 2)
		bigFlashRegFlag = 1
	end

	if bigFlashReg:existsClick(bigFlash) then
		existsClick(yes, 2) -- Click yes in "No Leadership skill" pop-up
		runsCount = runsCount + 1
		showStatsSection(true)
	end
end
-- Battle Routine
function battleRoutine(choice, stageMatch)
	currentIndex = 1
	if battleGearWheelRegFlag == 0 then
		battleGearWheelReg = regionFinder(stageMatch, 2)
		battleGearWheelRegFlag = 1
	end

	if AMonMax == 2 then AMonMax = 0 end

	arenaDialogReg:existsClick(arenaDialog,0)
	if debugAll == true then arenaDialogReg:highlight(0.5) end
	playReg:existsClick(play,0)
	if debugAll == true then playReg:highlight(1) end
	pauseReg:existsClick(pause, 0)
	if debugAll == true then pauseReg:highlight(1) end
end
-- Victory Routine
function victoryRoutine(choice, stageMatch)
	victoryCount = victoryCount + 1
	toast("Victory! [Victory Routine] #"..tostring(victoryCount))
	showStatsSection(true)
	currentIndex = 2
	if victoryDiamondRegFlag == 0 then
		victoryDiamondReg = regionFinder(stageMatch, 2)
		victoryDiamondRegFlag = 1
	end

	-- TODO: Don't do checkIfMax() if arena
	local randomTime = math.random(0,90)
	local randomInstance = 0
	if arenaMain == 0 then
		randomInstance = math.random(1,3)
		if skip == false then
			if AMonMax == 0 then checkIfMax() end
			setContinueClickTiming(10 + randomTime / 4, 65 + randomTime / 1)
			if AMonMax == 1 then continueClick(1800, 300, 15, 15, 1 + randomInstance) end
			if AMonMax == 2 then continueClick(1800, 300, 15, 15, 1 + randomInstance) end
		else
			setContinueClickTiming(10 + randomTime / 4, 65 + randomTime / 1)
			continueClick(1800, 300, 15, 15, 1 + randomInstance)
		end
	end
	wait(.5)
	setContinueClickTiming(10 + randomTime / 4, 65 + randomTime / 1)
	continueClick(1800, 300, 15, 15, 1 + randomInstance)
	wait(0.75 )
	if arenaMain == 0 then
		if (sellRune) then
			runeSale()
		else
			if not okenReg:existsClick(ok, 1) then
				multiCancel()
			end
		end
	end
end

-- Continue / Repeat routine
function continueRepeatRoutine(choice, stageMatch)

	if worldMapRegFlag == 0 then
		worldMapReg = regionFinder(stageMatch, 2)
		worldMapRegFlag = 1
	end

	currentIndex = 3
	--Next Area
	if (nextArea and (stagelist[choice] == "ilin.png" or stagelist[choice] == "libia.png" or stagelist[choice] == "dulander.png")) then
		while (existsClick(stagelist[choice], 0)) do
			wait(1)
		end
	end
	if (nextArea and flashRequireRegion:exists(requireEnergy0,0)) then
		simpleDialog("Warning", "Reach end of curent area.")
		return
	end

--	if (not flashRequireRegion:existsClick(smallFlash)) then
--		if debugAll == true then toast("smallFlash not found [Continue Repeat Routine]") end
		flashRequireRegion:existsClick(smallFlash, 2)
--	end

	wait(.5)
	if debugAll == true then toast("Try matching Yes [Continue Repeat Routine]") end
	if (exists(yes, 2)) then
		if (worldMapReg:exists(worldMap, 0) and refillEnergy) then
			if arenaFarm == true and timeCheck(arenaTimeFreq) == true then
				ArenaOverRide = 1
			else
				refillEnergy()
			end
		elseif (worldMapReg:exists(worldMap, 0) and arenaFarm == true) then
			ArenaOverRide = 1
		else
			-- TODO: Check what this code does and why it is here
			keyevent(4)
			local requiredFlash = existsMultiMaxSnap(flashRequireRegion, { requireEnergy3, requireEnergy4, requireEnergy5, requireEnergy6, requireEnergy7, requireEnergy8 })
			if (requiredFlash == -1) then requiredFlash = 9 else requiredFlash = requiredFlash + 2 end
			if debugAll == true then toast("Current Energy :" .. tostring(keyNum()) .. " of " .. tostring(requiredFlash) .. " Required. Waiting 10 minutes before repeating.") end
			wait(10 * 60)
		end
	end

end
-- Death Routine
function deathRoutine(choice, stageMatch)
	deathCount = deathCount + 1
	toast("Defeated! [Death Routine] #"..tostring(deathCount))
	showStatsSection(true)
	while true do
		Region(1300,900,800,300):existsClick(defeatedNo)
		AMonMax = 0
		if victoryDiamondReg:exists(victoryDiamond, 5) then
			local randomInstance = math.random(0,1)
			continueClick(1800, 300, 50, 50, 1 + randomInstance)
		end
		wait(.5)
		if flashRequireRegion:existsClick(smallFlash) then break end
		if debugAll == true then toast("smallFlash not found. Repeating [Death Routine]") end
	end
end

-- Network Delay / Connection Routine
function networkDelayConnectionRoutine(choice, stageMatch)
	existsClick(yes)
	wait(5)
end
--

-- ========================
-- Main Botting Application
-- ========================
currentIndex = 4
maxIndexStageList = 4
xTime = Timer()
ArenaOverRide = 0

while true do
	if (action == 4) then
		upgradeRune()
	end

	showStatsSection(true)

-- ========== Arena battles ==========
	if (AreaSelection == 12 or ArenaOverRide == 1) and currentIndex ~= 2 then
		toast("Arena Farm Should be Activated")
		areaGoTo(arena)
		arenaButtonReg:waitClick(arenaOrangeButton, 2)
		arenaMain = 1
		wait(2)
	end

	-- Do Arena Battles if
	while arenaMain == 1 do
		ArenaOverRide = 0
			if not arenaOppReg:exists(arenaSmallWing, 0) then
				swipeCount = 0
				arenaExe = 0
				arenaRefresh()
				wait(1)
			end
			local opponentList = listToTable(arenaOppReg:findAll(arenaSmallWing))
			local tCount = tableLength(opponentList)
			if debugAll == true then toast(tCount..": Opponent's Found") end
			for i, opp in ipairs(opponentList) do
				if i <= tCount then
					wait(.2)
					click(opp)
					arenaExe = 1
				end
				--------------------------------------------------------------------------------------------------------
				--------------------------------------------------------------------------------------------------------
				---Code Needs to be inserted here to keep track of and control what happens if there are not enough wings
				---This is also where we can control the refill of wings if we are out of them or return to another area to
				---continue with out farming if refills for wings are not enabled.
				--------------------------------------------------------------------------------------------------------
				--------------------------------------------------------------------------------------------------------

				while arenaExe == 1 do
					--------------------------------------------------------------------------------------------------------
					local choice, stageMatch = regionWaitMulti(arenaClickList, 20, debugAll)
					--If we didn't find a match on the arenaClickList, search the bigger list
					if (choice == -1) then
						toast("No match found [arenaClickList]")
						choice, stageMatch = waitMulti(arenabackList, 20*60, false)

						if (choice == -1) then
							if debugAll == true then toast("Choice -1 [Multi Cancel]") end
							multiCancel()
							wait(1)
						end
					end

					if debugAll == true then stageMatch:highlight(1) end
					--------------------------------------------------------------------------------------------------------
					---Starts the Fight

					if (choice == 4) then
						currentIndex = 4
						arenaLevelCheck() ---Obtains information regarding opponent
						if (arenaEmptyCount >= ArenaMaxMon) or ((arenaLvlCount / arenaRepCount) <= ArenaMaxAvgLvl) then
							arenaBigWingReg:existsClick(arenaBigWing)
							if arenaBigWingRegFlag == 0 then
								arenaBigWingReg = regionFinder(stageMatch, 2)
								arenaBigWingRegFlag = 1
							end
						else ---Cancel the fight and proceed to the next opponent
							arenaExe = 0
							if bigCancalRegFlag == 0 then
								bigCancalReg = regionFinder(exists(bigCancel, 0), 2) ---Does Last MatchWork Here?
								bigCancalRegFlag = 1
							end
							bigCancalReg:existsClick(bigCancel, 3)
							break
						end
					end
					--------------------------------------------------------------------------------------------------------
					---Events During the Actual Battle
					if (choice == 1) then
						if debugAll == true then toast("Choice 1 [Battle Routine]") end
						battleRoutine(choice, stageMatch)
					end
					--------------------------------------------------------------------------------------------------------
					---At End of fight Contols What Happens
					if (choice == 2) then
						victoryRoutine(choice, stageMatch)
					end

					--------------------------------------------------------------------------------------------------------
					---Results of the Fight Check/Continue/Accept
					if choice == 3 then
					currentIndex = 3
					arenaExe = 0
						arenaResultsReg:existsClick(arenaResults, 0)
						if debugAll == true then stageMatch:highlight(0.75) end
						break
					end

					-- TODO: Misc Checks
					-- TODO: Network  Resubmit

					if (choice == 6) then
						if refillWings == true then
							refillArena()
						else
							keyevent(4)
										wait(.7)
							keyevent(4)
										wait(.7)
							keyevent(4)
										wait(.7)
							arenaMain = 0
							arenaExe = 0
							areaGoTo()
										wait(3)
							stageSelect()
										wait(2)
							break
						end
					end

					if (choice == 7) or (choice == 8) then
						existsClick(yes)
						wait(5)
					end

					--Cancel Max Monster and  Misc Menus
					if (choice == 9) then
						if debugAll == true then toast("Choice 9 [Cancel Max Monster & Misc Menus]") end
						click(stageMatch)
						wait(5)
					end

					if choice == 10 or choice == 11 then
					if debugAll == true then toast("Choice 11 or 12 [areaGoTo]") end
					areaGoTo(arena)
					end

				end

				if i >= tCount then
					swipeCount = swipeCount +1
					local swipeInt = swipeCount
					while swipeInt >= 1 do
						wait(.5)
						swipeInt = swipeInt -1
						swipe(Location(1700,1075),Location(1700,461))
					end
				end
				--Critria for refreshing the list.
				if i >= tCount and EndofArenaL:exists(endArenaList, 0) then
					swipeCount = 0
					arenaExe = 0
					arenaRefresh()
				end
			end
	end

-- ========== Scenario battles ==========
	--TODO: Code to return to here we need to.
	local choice, stageMatch = regionWaitMulti(stageClickList, 20, debugAll)
	--If we didn't find a match on the stagelist, search the bigger list
	if (choice == -1) then
		if debugAll == true then toast("No match found [StageList]") end
		choice, stageMatch = waitMulti(backList, 20*60, false)

		--If we didn't find a match again try to end all actions
		if (choice == -1) then
			if debugAll == true then toast("Choice -1 [Multi Cancel]") end
			multiCancel()
			wait(1)
		end
	end

	if debugAll == true then stageMatch:highlight(1) end

	--Battle Preperation Routine
	if (choice == 5) or (choice == 7) then
		if debugAll == true then toast("Choice 5 or 7 [Battle Preperation Routine]") end
		battlePreperationRoutine(choice, stageMatch)
	end

	--Battle Routine
	if (choice == 1) then
		if debugAll == true then toast("Choice 1 [Battle Routine]") end
		battleRoutine(choice, stageMatch)
	end

	--Victory Routine
	if (choice == 2) then
		if debugAll == true then toast("Choice 2 [Victory Routine]") end
		victoryRoutine(choice, stageMatch)
	end

	--Continue Repeat Routine
	if (choice == 3)  or (choice == 4) then
		if debugAll == true then toast("Choice 3 or 4 [Continue / Repeat Routine]") end
		continueRepeatRoutine(choice, stageMatch)
	end

	--Death Routine
	if (choice == 6) then
		if debugAll == true then toast("Choice 6 [Death Routine]") end
		deathRoutine(choice, stageMatch)
	end

	--Network Resubmit
	if (choice == 8) or (choice == 9) then
		if debugAll == true then toast("Choice 8 or 9 [Network Delay / Connection Routine]") end
		networkDelayConnectionRoutine(choice, stageMatch)
	end

	--Cancel Max Monster and Misc Menus
	if (choice == 10) then
		if debugAll == true then toast("Choice 10 [Cancel Max Monster & Misc Menus]") end
		click(stageMatch)
		wait(5)
	end

	if choice == 11 or choice == 12 then
		if debugAll == true then toast("Choice 11 or 12 [areaGoTo]") end
		areaGoTo()
	end
end