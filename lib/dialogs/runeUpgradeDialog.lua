dialogInit()

addTextView("-------------------- Rune upgrading Configuration --------------------")newRow()
addTextView("Upgrade rune to level: ") newRow()
addRadioGroup("desiredRuneLevel", 12)
addRadioButton("+3  (Magic)", 3)
addRadioButton("+6  (Rare)", 6)
addRadioButton("+9  (Hero)", 9)
addRadioButton("+12 (Legend)", 12)
addRadioButton("+15 (Legend)", 15) newRow()
addTextView("  ") newRow()

addTextView("How much time do you need to select the next rune that you want upgraded?") newRow()
addEditNumber("runeUpgradePauseTime", 1) addTextView(" Minutes") newRow()
addTextView("  ") newRow()

addTextView("-------------------- Advanced Configuration --------------------") newRow()
addCheckBox("debugAll", "Debug ", false) if isPro() then addCheckBox("vibe", "Enable Vibrate ", true) end

dialogShow("SWAR X v"..scriptVersion.." Configuration")