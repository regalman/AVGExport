local _, AVGE = ...


function AVGE:tableLength(tbl)
	local count = 0 
	for _ in pairs(tbl) do 
		count = count + 1 
	end 
	return count 
end

function AVGE:TableContains(tbl, x)
    found = false
    for _, v in pairs(tbl) do
        if v == x then 
            found = true 
        end
    end
    return found
end

function AVGE:TableContainsNest(tbl, value, visited)
    if type(tbl) ~= "table" then return false end
    
    visited = visited or {} 
    if visited[tbl] then return false end
    visited[tbl] = true

    for _, v in pairs(tbl) do
        if v == value then
            return true
        elseif type(v) == "table" then
            if AVGE:TableContainsNest(v, value, visited) then
                return true
            end
        end
    end
    return false
end


function AVGE:TableCountContains(tbl, x)
	local count = 0
    local found = false
    for _, v in pairs(tbl) do
        if v == x then 
            found = true
			count = count + 1
        end
    end
    return count
end

function AVGE:SplitString(input, delimiter)
    local result = {}
    delimiter = delimiter:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    for match in (input..delimiter):gmatch("(.-)" .. delimiter) do
        if match ~= "" then
            table.insert(result, match)
        end
    end
    return result
end

function AVGE:UI()
	if AVGE.mainFrame then return end
	
	-----mainframe-----
	self.mainFrame = AVGE:CreateFrame("Mainframe", AuctionHouseFrame, "TOPRIGHT", "TOPRIGHT",120 , -10, 120, 77, "BackdropTemplate")	
	self.skipAvgCB = AVGE:CreateCheckbox("SkipAvgCB", self.mainFrame, "Skip AVG:", "TOPLEFT", "TOPLEFT", -5, -38, 125, 40)
	self.scanBtn = AVGE:CreateBtn("ScanBtn", self.mainFrame, "Scan", "TOPLEFT", "TOPLEFT", 17, -15, 60, 25)
	--local logBtn = AVGE:CreateBtn("LogBtn", self.mainFrame, "L", "TOPLEFT", "TOPLEFT", 111, -15, 25, 25)
 	local settingsBtn = AVGE:CreateBtn("SettingsBtn", self.mainFrame, "S", "TOPLEFT", "TOPLEFT", 82, -15, 25, 25)
	local mainFFrame = AVGE:CreateFrame("Mainframe", self.mainFrame, "TOPRIGHT", "TOPRIGHT",150, -10, 150, 77)	
	-----exportframe-----	
	self.exportFrame = AVGE:CreateFrame("Exportframe", AuctionHouseFrame, "CENTER", nil,0, 0, 350, 300, "PortraitFrameTemplate")	
	local exportScrollFrame = AVGE:CreateScrollFrame(self.exportFrame, "TOPLEFT", "BOTTOMRIGHT", 20, -23, -25, 8, "UIPanelScrollFrameTemplate") 
	self.exportEditBox = AVGE:CreateEditBox(exportScrollFrame, nil, nil, nil, nil, 300, nil, nil,"export")
	self.loadingText = AVGE:CreateFont(exportScrollFrame, "0%", "CENTER", nil, nil, nil, "font")
	self.exportFrame:Hide()
	-----settingframe-----
	self.settingsFrame = AVGE:CreateFrame("SettingsFrame", AVGE.mainFrame, "TOPLEFT", "BOTTOMLEFT", 0, 0, 425, 380, "BackdropTemplate", "hide")
	self.settingsScrollFrame = AVGE:CreateScrollFrame(self.settingsFrame, "TOPLEFT","BOTTOMRIGHT", 15, -80, -35, 40, "UIPanelScrollFrameTemplate", "frame") 
 	local resetSettingsBtn = AVGE:CreateBtn("ResetSettingsBtn", self.settingsFrame, "Reset", "BOTTOMRIGHT", "BOTTOMRIGHT", -12, 13, 60, 25)
	local searchBoxText = AVGE:CreateFont(self.settingsFrame, "Search:", "TOPLEFT", "TOPLEFT", 15, -25)
	self.fAvgCheckbox = AVGE:CreateCheckbox("fAVGCheckbox", self.settingsFrame, "Filter AVG:", "TOPRIGHT", "TOPRIGHT", -20, -18, 125,40)					
	self.tWWCheckbox = AVGE:CreateCheckbox("TWWCheckbox", self.settingsFrame,"War Within:","BOTTOMLEFT", "BOTTOMLEFT", 10, 0,125,40)	
	self.mNCheckbox = AVGE:CreateCheckbox("MNCheckbox", self.settingsFrame,"Midnight:","BOTTOMLEFT", "BOTTOMLEFT", 100, 0,125,40)	
	self.allCheckbox = AVGE:CreateCheckbox("AllCheckbox", self.settingsFrame,"All:","BOTTOMLEFT", "BOTTOMLEFT", 150, 0,115,40)	
	self.searchEditBox = AVGE:CreateEditBox(self.settingsFrame, "TOPLEFT", "TOPLEFT", 70, -17, 130, 30, "InputBoxTemplate")
	self.shoppingListsDD = AVGE:CreateFrame("ShoppingListsDD", self.settingsFrame, "TOPLEFT", "TOPLEFT", 10, -45, 0, 0, "UIDropDownMenuTemplate")
	AVGE:SetupDropdown()
	local addAListBtn = AVGE:CreateBtn("AddAListBtn", self.settingsFrame, "Add", "TOPLEFT", "TOPLEFT", 240, -45, 50, 25)
    local noteText = AVGE:CreateFont(self.settingsFrame, "NOTE", "TOPLEFT", "TOPLEFT", 293, -51)
	noteText:SetTextColor(1, 0, 0)
	noteText:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText("Adding an entire category without search text doesn't work\ni.e. all reagents in the war within")
	end)
	noteText:SetScript("OnLeave", GameTooltip_Hide)
		
	if AVGE.data["MN"] then self.mNCheckbox:SetChecked(true) end
 	if AVGE.data["TWW"] then self.tWWCheckbox:SetChecked(true) end
	if AVGE.data["ALL"] then self.allCheckbox:SetChecked(true) end
	
	AVGE:SetupItemTable()

	
	-----OnClick functions-----
	addAListBtn:SetScript("OnClick", function()
		AVGE:AddItems()
    end)
	
    self.scanBtn:SetScript("OnClick", function()
		AVGE:Scan()
    end)
	
    --logBtn:SetScript("OnClick", function()
	--	openLog()
    --end)
	
    settingsBtn:SetScript("OnClick", function()
		AVGE:ToggleSettings()
    end)
	
	resetSettingsBtn:SetScript("OnClick", function()
		AVGE:ResetPopup()
		StaticPopup_Show("MY_CONFIRM_POPUP")
    end)
	
	self.tWWCheckbox:SetScript("OnClick", function(self)
		AVGE:updateList()
		AVGE.data["TWW"] = self:GetChecked()
	end)
	
	self.allCheckbox:SetScript("OnClick", function(self)
		AVGE:updateList()
		AVGE.data["ALL"] = self:GetChecked()
	end)
	
	self.fAvgCheckbox:SetScript("OnClick", function(self)
		AVGE:updateList()
	end)
	
	self.mNCheckbox:SetScript("OnClick", function(self)
		AVGE:updateList()
		AVGE.data["MN"] = self:GetChecked()
	end)
		
	self.searchEditBox:SetScript("OnTextChanged", function(self, userInput)
		if userInput then
			AVGE:updateList()
		end
	end)
end

function AVGE:Scan()
	AVGE:ResetScan()
	AVGE.exportFrame:Show()
	AVGE:SetupScan()
end

function AVGE:ResetScan()
	AVGE.sL = {scan = {}, avg = {}, temp = {}}
	AVGE.loading = 0
	AVGE.SC = 0
	AVGE.exportEditBox:SetText("")
	for _,item in pairs(AVGE.defItemList) do
		item.sCount = 0
	end
end

function AVGE:ScanCompleted(i)
	AVGE.status = 0
	AVGE.scanBtn:SetText("Scan")
	AVGE:AddDataToExportFrame()
end

function AVGE:AddDataToExportFrame()
	AVGE.loadingText:SetText("Done")
	AVGE.exportEditBox:SetText('\"Price\",\"Name\",\"Item Level\",\"Owned?\",\"Available\"'.."\n")
	local notFound = 0
	for _,i in pairs(AVGE.sL.scan) do
		local price = "NA"	
		if type(i.price) == "number" then
			price = math.floor(i.price + 0.5)
		elseif notFound == 0 then
			notFound = 1
			print("|cffffa500[AVGExport]|r No results for one or more items. Price have been set to \"NA\" for these items")
		end
		AVGE.exportEditBox:SetText(AVGE.exportEditBox:GetText()..price..",\""..i.itemName.."\""..",70,\"\",0\n")
	end
end

function AVGE:ResetPopup()
	StaticPopupDialogs["MY_CONFIRM_POPUP"] = {
		text = "Are you sure you want to reset all?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			AVGE:Reset()
		end,
		OnCancel = function()
			--addToLog("Cancelled.")
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
end

function AVGE:ToggleSettings()
	if AVGE.settingsFrame and AVGE.settingsFrame:IsShown() then
		AVGE.settingsFrame:Hide()
		return 
	elseif AVGE.settingsFrame then
		AVGE.settingsFrame:Show()
		return
	end
end

function AVGE:SetupDropdown()
	UIDropDownMenu_SetWidth(AVGE.shoppingListsDD, 190)
	UIDropDownMenu_SetText(AVGE.shoppingListsDD, "Add items from auctionator list") 
	UIDropDownMenu_Initialize(AVGE.shoppingListsDD, function(self, level)
		AVGE.shoppingListsDD.selectedValue = 0
		for i = 1, Auctionator.Shopping.ListManager:GetCount() do
			local list = Auctionator.Shopping.ListManager:GetByIndex(i):GetName()
			local info = UIDropDownMenu_CreateInfo()
			info.text =  list
			--info.value = list
			info.func = function()
				UIDropDownMenu_SetText(AVGE.shoppingListsDD, info.text)
				AVGE.shoppingListsDD.selectedValue = list
			end
			UIDropDownMenu_AddButton(info)
		end	
	end)
end

function AVGE:Reset()
	AVGE.data = {}
	AVGE.searchEditBox:SetText("")				
	AVGE:updateList()
end

function AVGE:AddItems()
	local selectedList = AVGE.shoppingListsDD.selectedValue
	if selectedList ==  0 then return end
	--print(selectedList)
	AVGE.auctionatorListItems = {}
	AVGE:ResetScan()
	AVGE.status = 3
	AVGE.exportFrame:Show()
	AVGE.exportEditBox:SetText("")
	AVGE.loadingText:SetText("Adding items\n\n0%")
	for i, s in ipairs(Auctionator.API.v1.GetShoppingListItems("AVGE", selectedList)) do
		local item = {}
		---Split string---
		for part in (s .. ";"):gmatch("(.-);") do
			table.insert(item, part)
		end
		table.insert(AVGE.auctionatorListItems,item)
	end
	AVGE:GetAuctionatorListItems(AVGE.auctionatorListItems)
end

function AVGE:SetupScan()
	AVGE.status = 1
	for _, item in pairs(AVGE.defItemList) do 
		item.sCount = 0		
		if AVGE.tWWCheckbox:GetChecked() and item.exp == 11 or AVGE.mNCheckbox:GetChecked() and item.exp == 12 or AVGE.allCheckbox:GetChecked() then
			local itemId = tostring(item.itemId)
			AVGE.sL.scan[itemId] = item	
			if AVGE.data[itemId] and not AVGE.skipAvgCB:GetChecked() then
				if AVGE.data[itemId][1] then AVGE.sL.avg[itemId] = item end
			elseif item.getAvg and not AVGE.skipAvgCB:GetChecked() then 
				AVGE.sL.avg[itemId] = item 
			end	
		end
	end
	AVGE.scanBtn:SetText("0/"..AVGE:tableLength(AVGE.sL.scan))
	AVGE:GetAvgData()
end

function AVGE:GetAuctionatorListItems(aucList)
	if AVGE.status ~= 3 then return end
	if AVGE:tableLength(AVGE.sL.temp) >= AVGE:tableLength(aucList) then
		AVGE.status = 0
		AVGE:WaitForResults()
		return
	end
	
	--AVGE.lastItem = false
	for i,item in pairs(aucList) do
		if not AVGE:TableContains(AVGE.sL.temp,item[1]) then
			if i == #aucList then
				--AVGE.lastItem = true	
				--AVGE:WaitForResults()			
			end
			---If no results after 5 tries then skip---
			item.searchTries = item.searchTries and item.searchTries + 1 or 1
			AVGE.currentSearchItem = item[1]
			if item.searchTries >= 3 then 
				table.insert(AVGE.sL.temp, item[1]) 
				AVGE:GetAuctionatorListItems(AVGE.auctionatorListItems)
				AVGE.exportEditBox:SetText(AVGE.exportEditBox:GetText().."No results found - "..item[1].."\n")
				return
			end
			
			local s = item[1]:gsub('"', '')
			local query = {searchString = s, sorts = {}, filters = {}}
			C_AuctionHouse.SendBrowseQuery(query)
			return
		else
			--if i > 1 and item[1] == aucList[i-1][1] then
			for i = AVGE:TableCountContains(AVGE.sL.temp, item[1])+1, AVGE:TableCountContains(aucList, item[1]) do				
				table.insert(AVGE.sL.temp, "placer")
			end
			if i == #aucList then
				AVGE.status = 0
				AVGE:WaitForResults()
			end			
			--end
		end
	end	
end

function AVGE:FilterCollectedItems()
	local itemsToAdd = {}
	--print("RUN FILTERING")
	for i,item in pairs(AVGE.auctionatorListItems) do
		--EXACT SEARCH--
		if item[1]:sub(1, 1) == '"' and item[1]:sub(-1) == '"' then
			for id, aListItem in pairs(AVGE.sL.scan) do
				if item[1]:gsub('"', ''):lower() == aListItem.itemName:gsub("%s+Tier%s+%d+$", ""):lower() then
					if item[12] then
						if aListItem.itemName:match("Tier%s+(%d+)$") == item[12] then
							itemsToAdd[tostring(id)] = aListItem
						end
					else
						itemsToAdd[tostring(id)] = aListItem
					end
				end
			end
		--SEARCH--
		else
			for id, aListItem in pairs(AVGE.sL.scan) do
				if aListItem.itemName:gsub("%s+Tier%s+%d+$", ""):lower():find(item[1]:lower()) then
					local tier = item[12] or "no tier"
					if item[12] then
						if aListItem.itemName:match("Tier%s+(%d+)$") == item[12] then
							itemsToAdd[tostring(id)] = aListItem
						end
					else
						itemsToAdd[tostring(id)] = aListItem
					end
									
				end
			end
		end
	end
	--profile.savedItems = {}
	for _,items in pairs(itemsToAdd) do
		if not AVGE.data.savedItems[tostring(items.itemId)] and not AVGE.defItemList[tostring(items.itemId)] then
			AVGE.data.savedItems[tostring(items.itemId)] = items
			AVGE.defItemList[tostring(items.itemId)] = items
			AVGE.exportEditBox:SetText(AVGE.exportEditBox:GetText().."Added - "..items.itemName.."\n")
			--print(items.itemName.."  Added")
		else
			AVGE.exportEditBox:SetText(AVGE.exportEditBox:GetText().."Already exist in scan - "..items.itemName.."\n")
			--print(items.itemName.."  Allready Added")
		end
	end
	AVGE.loadingText:SetText("Done")
	AVGE:SetupItemTable()

end

function AVGE:WaitForResults()
	C_Timer.After(1, function()
		if AVGE:TableContains(AVGE.sL.avg,true) then
			AVGE:WaitForResults()
		else
			AVGE:FilterCollectedItems()
		end
	end)
end	

function AVGE:GetAvgData()
	if AVGE.status ~= 1 then return end
	if AVGE.SC then 
		AVGE.SC = AVGE.SC + 1 
		--if AVGE.SC > 1 then return end
	else 
		AVGE.SC = 0 
	end
	for _, item in pairs(AVGE.sL.avg) do
		if not AVGE:TableContains(AVGE.sL.temp, item.itemId) then
			item.sCount = item.sCount + 1
			if item.skip == nil and item.sCount < 8 then
				C_AuctionHouse.SendSearchQuery(C_AuctionHouse.MakeItemKey(item.itemId), {}, false)	
				local SC = AVGE.SC
				local ttpL = AVGE:tableLength(AVGE.sL.temp)
				C_Timer.After(3, function()			
					local function dontStop(x,y)
						if x == AVGE:tableLength(AVGE.sL.temp) and y == AVGE.SC then
							AVGE:GetAvgData()
						end		
					end	
					dontStop(ttpL,SC )
				end)			
				return
			else
				item.price = "NA"
				table.insert(AVGE.sL.temp,item.itemId)
				local tlL = AVGE:tableLength(AVGE.sL.temp)
				local ilL = AVGE:tableLength(AVGE.sL.scan)
				AVGE.scanBtn:SetText(tlL.."/"..ilL)
				AVGE.loading = math.floor((tlL/ilL*100) + 0.5)
				AVGE.loadingText:SetText(AVGE.loading.."%")
				AVGE:GetAvgData()
			end
		end
	end
	if AVGE:tableLength(AVGE.sL.avg) == AVGE:tableLength(AVGE.sL.temp) then
		AVGE.status = 2
		AVGE:GetFastData()		
	end
end

function AVGE:GetFastData()
	if AVGE.status ~= 2 then return end
	if AVGE:tableLength(AVGE.sL.temp) >= AVGE:tableLength(AVGE.sL.scan) then
		AVGE:ScanCompleted(1)
		return
	end
	local keys = {}
	local count = 0
	
	for _,item in pairs(AVGE.sL.scan) do
		if not AVGE:TableContains(AVGE.sL.temp ,item.itemId) then
			item.sCount = item.sCount + 1
			if item.skip == nil and item.sCount < 6 then
				local itemKey = C_AuctionHouse.MakeItemKey(item.itemId)
				table.insert(keys, itemKey)
				--Scan for 50 items per scan--
				if count == 50 then
					break
				end
				count = count + 1				
			else
				item.price = "NA"
				table.insert(AVGE.sL.temp,item.itemId)
				local tlL = AVGE:tableLength(AVGE.sL.temp)
				local ilL = AVGE:tableLength(AVGE.sL.scan)
				AVGE.scanBtn:SetText(tlL.."/"..ilL)
				AVGE.loading = math.floor((tlL/ilL*100) + 0.5)
				AVGE.loadingText:SetText(AVGE.loading.."%")	
				if AVGE:tableLength(AVGE.sL.temp) >= AVGE:tableLength(AVGE.sL.scan) then
					AVGE:ScanCompleted(2)
					return
				end	
			end			
		end
	end
	C_AuctionHouse.SearchForItemKeys(keys,{})
	
	C_Timer.After(8, function()			
		local function dontStop(x)
			if x == AVGE:tableLength(AVGE.sL.temp) then
				AVGE:GetFastData()
			end		
		end			
		dontStop(AVGE:tableLength(AVGE.sL.temp))
	end)
end

function AVGE:SetupItemTable()
	if not AVGE.resultRows then AVGE.resultRows = {} end
	for i = AVGE:tableLength(AVGE.resultRows)+1, AVGE:tableLength(AVGE.defItemList) do
		local myRow = {}
		myRow[1] = AVGE:CreateFrame("RowFrame", AVGE.settingsScrollFrame, "TOPLEFT", "TOPLEFT", -4, -9 - (i - 1) * 26, 300, 24)
		myRow[2] = AVGE:CreateCheckbox("RowAvgCheckbox", myRow[1], "", "BOTTOMLEFT", "BOTTOMLEFT", -80, 0,125,40)			
		myRow[3] = AVGE:CreateFont(myRow[1], "Test test  test", "LEFT", "LEFT", 95, 15)
		myRow[4] = AVGE:CreateEditBox(myRow[1], "TOPLEFT", "TOPLEFT", 40, 17, 45, 30, "InputBoxTemplate")
		myRow[4]:SetNumeric(true)
		AVGE.resultRows[i] = myRow
		myRow[2]:SetScript("OnClick", function(self)
			if self:GetChecked() then
				local itemId = tostring(self.itemData.itemId)
				AVGE.data[itemId] = {true, AVGE.data[itemId] and AVGE.data[itemId][2] or self.itemData.dataQ}
			else
				AVGE.data[tostring(self.itemData.itemId)] = {false, AVGE.data[itemId] and AVGE.data[itemId][2] or self.itemData.dataQ}
			end
		end)
		
		myRow[4]:SetScript("OnTextChanged", function(self, userInput)
			if userInput then
				local itemId = tostring(self.itemData.itemId)			
				AVGE.data[itemId] = {AVGE.data[itemId] and AVGE.data[itemId][1] or self.itemData.getAvg,tonumber(self:GetText())}
			end
		end)
		
	end
	
	AVGE:updateList()
end

function AVGE:updateList()
	local query = AVGE.searchEditBox:GetText()
	local results = AVGE.defItemList[i] or avg or AVGE:SearchItems(query)
	for i, row in pairs(AVGE.resultRows) do
        if results[i] then
			local itemIdS = tostring(results[i].itemId)
			if string.sub(results[i].itemName, 1, string.len("Enchant")) == "Enchant" then
				local sString = AVGE:SplitString(results[i].itemName, "-")
				row[3]:SetText("Ench - "..sString[2]:gsub("%%$", ""))
			else
				row[3]:SetText(results[i].itemName)
			end
            row[2].itemData = results[i]
			row[4].itemData = results[i]
			if AVGE.data[itemIdS] then
				row[2]:SetChecked(AVGE.data[itemIdS][1])
			else
				row[2]:SetChecked(results[i].getAvg)
			end
			--row[2]:SetChecked(AVGE.data[itemIdS] and AVGE.data[itemIdS][1] or results[i].getAvg)
			row[4]:SetText(AVGE.data[itemIdS] and AVGE.data[itemIdS][2] or results[i].dataQ)
            row[1]:Show()
        else
            row[3]:SetText("")
            row.itemData = nil
            row[1]:Hide()
        end
    end
end

function AVGE:SearchItems(query)
    searchResults = {}
    query = string.lower(query)
    for _, item in pairs(AVGE.defItemList) do		
		if not (AVGE.tWWCheckbox:GetChecked() and item.exp == 11) and not (AVGE.mNCheckbox:GetChecked() and item.exp == 12) and not AVGE.allCheckbox:GetChecked() then
				--skip--
		elseif AVGE.fAvgCheckbox:GetChecked() then
			if AVGE.data and AVGE.data[tostring(item.itemId)] then
				if AVGE.data[tostring(item.itemId)][1] and string.find(string.lower(item.itemName), query) then
					table.insert(searchResults, item)
				end
			else
				if item.getAvg and string.find(string.lower(item.itemName), query) then
					table.insert(searchResults, item)
				end
			end
		else
			if string.find(string.lower(item.itemName), query) then
				table.insert(searchResults, item)
			end
		end
    end
    return searchResults
end



local eventFrame = CreateFrame("Frame")
local eventHandlers = {}

eventFrame:SetScript("OnEvent", function(self, event, ...)
    local handler = eventHandlers[event]
    if handler then
        handler(self, event, ...)
    end
end)

local function registerMyEvent(event, handler)
    eventHandlers[event] = handler
    eventFrame:RegisterEvent(event)
end

registerMyEvent("COMMODITY_SEARCH_RESULTS_UPDATED", function(self, event, itemID, ...)
    if AVGE.status ~= 1 then return end
	local calcQ = 0
	local avgPrice = 0
	if not AVGE:TableContains(AVGE.sL.temp,itemID) and AVGE:TableContainsNest(AVGE.sL.scan, itemID) then
		local item = AVGE.sL.avg[tostring(itemID)]
		if not item.skip then
			local dataQ = (AVGE.data[tostring(itemID)] and AVGE.data[tostring(itemID)][2]) or item.dataQ
			if dataQ < 1 then dataQ = 1 end
			for i = 1, C_AuctionHouse.GetNumCommoditySearchResults(itemID) do
				local result = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, i)
				if result.quantity < dataQ-calcQ then
					calcQ = calcQ + result.quantity
					avgPrice = avgPrice + result.quantity*result.unitPrice
				elseif calcQ < dataQ then 
					avgPrice = avgPrice +((dataQ-calcQ)*result.unitPrice)
					calcQ = dataQ 
				end
			end
			item.price = avgPrice/calcQ
		end
		if avgPrice ~= 0 then
			table.insert(AVGE.sL.temp, itemID)
			local tlL = AVGE:tableLength(AVGE.sL.temp)
			local ilL = AVGE:tableLength(AVGE.sL.scan)
			AVGE.scanBtn:SetText(tlL.."/"..ilL)
			AVGE.loading = math.floor((tlL/ilL*100) + 0.5)
			AVGE.loadingText:SetText(AVGE.loading.."%")
		end	
	end
	AVGE:GetAvgData()
end)

registerMyEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED", function(self, event, ...)
	
	
	if AVGE.status == 3 then 
		local results = C_AuctionHouse.GetBrowseResults()
		local validResults
		for i, result in pairs(results) do
			if result.itemKey.itemID then
				validResults = true
				AVGE.sL.avg[tostring(result.itemKey.itemID)] = true
				local function RunDelayedCheck(itemID)
					C_Timer.After(1, function()
						local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,itemEquipLoc, itemTexture, itemSellPrice,_,_,_, expacID = GetItemInfo(itemID)
						local tier
						if itemLink then
							tier = itemLink:match("(Tier%d+)")
							if tier then
								AVGE.sL.scan[tostring(itemID)] = {itemName = itemName.." "..tier:gsub("Tier(%d)", "Tier %1"), exp = expacID+1, itemId = itemID, tier = tier:gsub("Tier(%d)", "Tier %1"), price = 0, craftPrice = -1, dataQ = 100, getAvg = false, sCount = 0, available = 0}
							else
								AVGE.sL.scan[tostring(itemID)] = {itemName = itemName, exp = expacID+1, itemId = itemID, tier = 0, price = 0, craftPrice = -1, dataQ = 100, getAvg = false, sCount = 0, available = 0}
							end 
							AVGE.sL.avg[tostring(itemID)] = false
							local tLT = AVGE:tableLength(AVGE.sL.temp)
							local tLA = AVGE:tableLength(AVGE.auctionatorListItems) 
							if tLT >= tLA then
								local trueC = 0
								for _,i in pairs(AVGE.sL.avg) do
									if i == false then trueC = trueC + 1 end
								end
								
								AVGE.loading = math.floor((trueC/AVGE:tableLength(AVGE.sL.avg)*100) + 0.5)
								AVGE.loadingText:SetText("Adding items\n\n"..(AVGE.loading/2+48).."%")
							end
						else
							RunDelayedCheck(itemID)
						end
					end)
				end
				RunDelayedCheck(result.itemKey.itemID)
			end
		end
		if validResults then
			table.insert(AVGE.sL.temp, AVGE.currentSearchItem)
			AVGE.loading = math.floor((AVGE:tableLength(AVGE.sL.temp)/AVGE:tableLength(AVGE.auctionatorListItems)*100) + 0.5)
			AVGE.loadingText:SetText("Adding items\n\n"..(AVGE.loading/2).."%")

		end
		AVGE:GetAuctionatorListItems(AVGE.auctionatorListItems)
	end
	
	
	
	if AVGE.status ~= 2 then return end
    local results = C_AuctionHouse.GetBrowseResults()
    for i, result in pairs(results) do
		if result.minPrice ~= 0 and not AVGE:TableContains(AVGE.sL.temp, result.itemKey.itemID) and AVGE:TableContainsNest(AVGE.sL.scan, result.itemKey.itemID) then
			table.insert(AVGE.sL.temp,result.itemKey.itemID)
			AVGE.sL.scan[tostring(result.itemKey.itemID)].price = result.minPrice
			local tlL = AVGE:tableLength(AVGE.sL.temp)
			local ilL = AVGE:tableLength(AVGE.sL.scan)
			AVGE.scanBtn:SetText(tlL.."/"..ilL)
			AVGE.loading = math.floor((tlL/ilL*100) + 0.5)
			AVGE.loadingText:SetText(AVGE.loading.."%")
		end
	end
	if AVGE:tableLength(AVGE.sL.temp) >= AVGE:tableLength(AVGE.sL.scan) then
		AVGE:ScanCompleted(3)
	else
		AVGE:GetFastData()
	end
end)

registerMyEvent("AUCTION_HOUSE_SHOW", function(_, event, arg1)
	AVGE:UI()
end)

registerMyEvent("AUCTION_HOUSE_CLOSED", function(_, event, arg1)
	AVGE.status = 0
	AVGE.scanBtn:SetText("Scan")
	AVGE.exportFrame:Hide()
end)

registerMyEvent("ADDON_LOADED", function(_, event, arg1)
	if arg1 == "AVGExport" then
		if AVGEDB == nil then	
			AVGE.data = {}
			AVGE.data.savedItems = {}
			AVGE.data["TWW"] = true
			AVGE.data["MN"] = true
			AVGE.data["ALL"] = true
		else
			AVGE.data = AVGEDB
			if AVGE.data.savedItems then
				for _,items in pairs(AVGE.data.savedItems) do 
					AVGE.defItemList[tostring(items.itemId)] = items
				end
			else
				AVGE.data.savedItems = {}
			end
		end
	end
end)

registerMyEvent("PLAYER_LOGOUT", function(_, event, arg1)
	AVGEDB = AVGE.data
end)

