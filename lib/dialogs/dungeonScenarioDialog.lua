dialogInit()
-- Spinners
spinnerStars = {"1 Star", "2 Star", "3 Star", "4 Star", "5 Star", "6 Star"}
spinnerRarity = {"Common", "Magic", "Rare", "Hero", "Legend" }
spinnerSubCent = {"25%", "33%", "50%", "66%", "75%", "100%" }
-- TODO: Complete the rest
spinnerAreaReturn = {
    "Giant's Keep",
    "Dragon's Lair",
    "Necropolis",
    "Hall of Light",
    "Hall of Dark",
    "Hall of Fire",
    "Hall of Water",
    "Hall of Wind",
    "Hall of Magic",
    "Trial of Ascension",
    "Rift of Worlds",
    "Arena",
    "World Boss",
    "Garen Forest",
    "Mt. Siz",
    "Mt. White Ragon",
    "Kabir Ruins",
    "Talain Forest",
    "Hydeni Ruins",
    "Tamor Desert",
    "Vrofagus Ruins",
    "Faimon Volcano",
    "Aiden Forest",
    "Ferun Castle",
    "Mt. Runar",
    "Chiruka Remains" }
spinnerRaidReturn = {
    "Dark Beast",
    "Fire Beast",
    "Ice Beast",
    "Light Beast",
    "Wind Beast"
}
spinnerLevel = {"1","2","3","4","5","6","7","8","9","10" }
spinnerDiff = {"Normal","Hard","Hell"}
spinnerTOA = {"Normal", "Hard" }

-- GUI
addTextView("------------------------------Area Farm Configuration---------------------------------")newRow()
if (action == 1) then
    addSpinnerIndex("AreaSelection", spinnerAreaReturn, "Garen Forest") addTextView("  ") addSpinnerIndex("diffSelection", spinnerDiff, "Hell") addTextView(" Lvl: ")  addSpinnerIndex("levelSelection", spinnerLevel, "1") newRow()
elseif (action == 2) then
    addSpinnerIndex("toaSelection", spinnerTOA, "Normal") addTextView(" Lvl: ")  addSpinnerIndex("levelSelection", spinnerLevel, "1") newRow()
elseif (action == 3) then
    addSpinnerIndex("raidSelection", spinnerRaidReturn, "Dark Beast") newRow()
end
addTextView("------------------------------Scenario Max Lv. Auto Swap---------------------------")newRow()
addCheckBox("SwapMaxTop","Top",false) addCheckBox("SwapMaxLeft","Left",false) addCheckBox("SwapMaxRight","Right",false) addCheckBox("SwapMaxBottom","Bottom",false)        newRow()newRow()
addTextView("----------------------------------------------------------------------------------------------------")newRow()
addCheckBox("nextArea", "Next Area", false) addCheckBox("sellRune", "Sell Runes ", false)    newRow()
addTextView("  ") newRow()

addTextView("------------------------------Arena Configuration-----------------------------------")newRow()
addCheckBox("arenaFarm", "Arena Farming", false)newRow()
addTextView("Arena Check Frequency [Mins]") addEditNumber("arenaTimeFreq", 60) newRow()
addTextView("Max # of Enemies") addEditNumber("ArenaMaxMon", 1) newRow()
addTextView("Max Avg Level of Enemies") addEditNumber("ArenaMaxAvgLvl", 40) newRow()
addTextView("  ") newRow()

addTextView("------------------------------Rune Evaluation Configuration----------------------------")newRow()
addCheckBox("CBRuneEval", "Evalu Runes: ", false) addCheckBox("CBRuneEvalStar", "Stars", false) addCheckBox("CBRuneEvalRarity", "Rarity", false) addCheckBox("CBRuneEvalPrimary", "Prime", false) addCheckBox("CBRuneEvalSubCent", "SubS", false) newRow()
addTextView("------------------------------Primary Stat Configuration--------------------------------")newRow()
addCheckBox("keepRunePrimeHP", "HP ", true) addCheckBox("keepRunePrimeATK", "ATK ", true) addCheckBox("keepRunePrimeDEF", "DEF ", true) addCheckBox("keepRunePrimeSPD", "SPD ", true) newRow()
addCheckBox("keepRunePrimeCRIRate", "CRI Rate", true) addCheckBox("keepRunePrimeCRIDmg", "CRI Dmg ", true) addCheckBox("keepRunePrimeRES", "RES ", true)addCheckBox("keepRunePrimeACC", "ACC ", true) newRow()
addSpinnerIndex("runeStars", spinnerStars, "5 Star") addSpinnerIndex("runeRarity", spinnerRarity, "Rare") addSpinnerIndex("runeSubCentage", spinnerSubCent, "25%") addTextView("Sub Stats as %") newRow()
addTextView("  ") newRow()

addTextView("------------------------------Refill Configuration-----------------------------------")newRow()
addCheckBox("refillEnergy", "Refill Energy with Crystal ", false) addTextView("  ") addCheckBox("limitEnergyRefills", "Energy Refill Limit: ", false)  addEditNumber("refillEnergyLimit", 20) newRow()
addCheckBox("refillWings", "Refill Wings with Crystal ", false) addTextView("  ") addCheckBox("limitWingsRefills", "Wing Refill Limit: ", false)  addEditNumber("refillWingsLimit", 20) newRow()
addTextView("  ") newRow()

addTextView("------------------------------Advanced Configuration--------------")newRow()
addCheckBox("debugAll", "Debug ", false) if isPro() then addCheckBox("vibe", "Enable Vibrate ", true) addCheckBox("dim", "Dim While Running", true) end newRow()

dialogShow("SWAR X v"..scriptVersion.." Configuration")