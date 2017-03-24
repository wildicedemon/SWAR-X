-- TODO: Create new giftAllFriends function
giftedAllFriends = false
function giftAllFriends()
    local giftCount = 0
	if debugAll == true then toast("[Function] giftAllFriends") end
	
	if (battleButtonReg:existsClick(communityButton)) then
        
        if not friendTabReg:exists(friendTabActive, 1) then
            friendTabReg:existsClick(friendTabInactive, 1)
        end

        -- Assumption: when on first page there is no giftbutton, all friend are gifted
        if not communityListReg:exists(giftButton, 1) then
            if (giftedAllFriends) then toast("Already gifted all friends.") end
			wait(1)
            keyevent(4)  -- back button
            return true
		end

        giftCount = doGiftFriends()
        toast("Gave a gift to "..giftCount.." friends.")
        giftedAllFriends = true
	end
end
function doGiftFriends() 
    local communityList = listToTable(communityListReg:findAll(giftButton))
	local tCount = tableLength(communityList)
	if debugAll == true then toast(tCount.." Friends Found") end
    local giftCount = 0
	for i, gift in ipairs(communityList) do
		if i <= tCount then
			wait(.2)
			click(gift)
            giftCount = giftCount + 1
		end   

        if i >= tCount and swipeCount >= 6 then
			swipeCount = 0
            return giftCount
		end

		if i >= tCount then
			swipeCount = swipeCount + 1
			local swipeInt = swipeCount
			while swipeInt >= 1 do
				wait(.5)
				swipeInt = swipeInt -1
				swipe(Location(1700,1075),Location(1700,461))
			end
		end
	end
end