
B_AH_VERSION = "1.0"

-------------------------------------------------------------------------------

-- True if the auction house window is shown
B_AH_IsOpen = false

-- Number of auctions on the currently shown page
B_AH_CurrentPageAuctions = 0

-- Total number of auctions in this auction house
B_AH_TotalAuctions = 0

-- Currently opened auction house page number
B_AH_Page = 0

-- Is the scan enabled
B_AH_Scanning = false

-- Player name
B_AH_Player = UnitName("player")

-------------------------------------------------------------------------------


--[[
	Print text in the chat frame
	Argument: msg - the text that you want to print
]]
function B_AH_Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg, 0.37, 1, 0)
end

-------------------------------------------------------------------------------

function B_AH_Start()
	B_AH_Scanning = true
	B_AH_Buy()

	B_AH_Button_Start:Disable()
	B_AH_Button_Stop:Enable()
end

function B_AH_Stop()
	B_AH_Scanning = false

	B_AH_Button_Start:Enable()
	B_AH_Button_Stop:Disable()
end

-------------------------------------------------------------------------------


--[[
	Buys all items that meet the user's specified requirements.
]]
function B_AH_Buy()

	local auctionIndex
	for auctionIndex = B_AH_CurrentPageAuctions, 1, -1 do

		--[[
			name, texture, count, quality, canUse, level, minBid, minIncrement,
			buyoutPrice, bidAmount, highBidder, owner = GetAuctionItemInfo("list|bidder|owner", offset)
		]]
		local name,_,_,_,_,_,_,_,buyPrice,_,_,owner = GetAuctionItemInfo("list", auctionIndex)

		if owner and strlower(owner) == strlower(B_AH_GS[B_AH_Player]["Name"]) then
			PlaceAuctionBid("list", auctionIndex, buyPrice)
			B_AH_Print("Buying: " .. name)
		end
	end
end

--[[
	Queries an auction house page using the user's defined settings.
]]
function B_AH_Scan()

	-- GUI fix only: Make the AH interface show the right page number
	AuctionFrameBrowse.page = B_AH_Page

	--[[
		QueryAuctionItems("name", minLevel, maxLevel, invTypeIndex, classIndex,
			subclassIndex, page, isUsable, qualityIndex, getAll)
	]]
	QueryAuctionItems("", nil, nil, 0, 0, 0, B_AH_Page, false, 0, false)

	-- Increase the page number by one; so next scan will show the next page
	B_AH_Page = B_AH_Page + 1
	if (B_AH_Page * 50 > B_AH_TotalAuctions) then
		B_AH_Page = 0
	end
end


-------------------------------------------------------------------------------


function B_AH_OnLoad()
	this:RegisterEvent("ADDON_LOADED")
	this:RegisterEvent("AUCTION_HOUSE_SHOW")
	this:RegisterEvent("AUCTION_HOUSE_CLOSED")
	this:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
end

function B_AH_OnEvent()
	if (event == "ADDON_LOADED") then
		if (string.lower(arg1) == "auctionhelper") then

			if B_AH_GS == nil then
				B_AH_GS = {}
			end

			if B_AH_GS[B_AH_Player] == nil then
				B_AH_GS[B_AH_Player] = {["Name"] = "ENTER A NAME"}
			end

			B_AH_Input_Name:SetText(B_AH_GS[B_AH_Player]["Name"])
			B_AH_Button_Stop:Disable()

			B_AH_Print("AuctionHelper " .. B_AH_VERSION .. " loaded.")
		end

	elseif (event == "AUCTION_HOUSE_SHOW") then
		B_AH_Frame:Show()
		B_AH_IsOpen = true

	elseif (event == "AUCTION_HOUSE_CLOSED") then
		B_AH_Stop()
		B_AH_Frame:Hide()
		B_AH_IsOpen = false

	elseif (event == "AUCTION_ITEM_LIST_UPDATE") then

		B_AH_CurrentPageAuctions, B_AH_TotalAuctions = GetNumAuctionItems("list")

		if (B_AH_IsOpen == true and B_AH_Scanning == true) then
			B_AH_Buy()
		end
	end
end

function B_AH_OnUpdate()

	if (B_AH_IsOpen == true and B_AH_Scanning == true and CanSendAuctionQuery()) then
		B_AH_Scan()
	end
end
