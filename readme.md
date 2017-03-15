# SWAR-X

SWAR-X is another Ankulua automation bot for Summoners War. This bot automates lots of repetitive actions in Summoners War and makes the endless grinding a bit more pleasant.

## Features
Features of this script include: Farming of all Scenarios, Dungeons, Trail of Ascension, Rift, and Arena

### Automated Fodder Swapping
* Evaluates the Number of Stars and Level of monsters
* ONLY Selected Slots are Checked
* Replaces monsters that are Max Level with New Fodder lvl 1-14
* Prioritizes Lowest Star then Level Monsters First (Some Errors Present ATM)

### Rune Evaluation System
Based on the following criteria:

* Stars
* Slot
* Rarity (Normal, Magic, Hero, Legend)
* Primary Stat % (Slot 2, 4 and 6) (SPD counts towards the %)
* % of Secondary stats which are % vs Flat (SPD counts towards the %)

### Area Switching and Return
* Will Automatically Switch to Arena use wings and Return (User Configurable)
* Switches if Out of Energy and X Minutes (User Configurable) Elapsed Since Start/Last Run
* **DO NOT ENABLE BOTH ENERGY AND WING REFILLS**

### Automated **Smart** Arena Farming
* Evaluates the Level of Enemy Monsters
* Evaluates the Number of Enemy Monsters
* Proceeds to start arena Battle if Either of the Following Conditions is true
* If the Number of Enemy Monsters is less then X (User Configurable)
* If the Average Level of the Enemy Monsters is less then X (User Configurable)

### Miscellaneous
* Automatic Refill of Wings and Energy
* Continue After Death, Network Instability, Promotions Etc
* Statistics Area: Currently [Runs, Deaths, Runes Kept #, Runes Sold #]
* Speed Optimizations and New Library Code for Efficiency and Speed

## Configuration
* When starting the script you'll be asked which Resolution your device has. The best resolution is selected automatically
* Second you'll be asked what you like to do:
 * General / Scenario's
 * Rift of World
 * Arena
 * Rune upgrading

## Next steps / coming features:
- [x] Rift of World (Beasts) support
- [ ] Rift of World (Raid) support
- [ ] Rune evaluation based on rune efficiency
- [ ] Avoid certain Monsters in Arena battles

## Known issues
* **Not tested** resolutions other than 2560x1440 & 2560x1600
* Fodder Picker: Will Skip over some monsters even though they meet the criteria
* Area Switching seems to have some issues still

## More information
Read more: http://ankulua.boards.net/thread/291/summoner-swarx-fodder-swapping-evaluation