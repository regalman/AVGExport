local _, exportL = ...
local loadingText, skipAvgCheckbox, fAvgCheckbox, settingsContentFrame, scanBtn, exportFrame, exportScrollFrame, settingsFrame, exportEditBox, searchBox, avgCheckbox, avgEditBox, logFrame, logScrollFrame, logEditBox
local tempList = {}
local searchList = {}
local resultRows = {}
local searchResults = {}
local profile = {}
local logText = ""
local selectedRow = nil
local status = 0
local loading = 0

local function tableLength(tbl)
	local count = 0 
	for _ in pairs(tbl) do 
		count = count + 1 
	end 
	return count 
end

local function tableContains(tbl, x)
    found = false
    for _, v in pairs(tbl) do
        if v == x then 
            found = true 
        end
    end
    return found
end

local function searchItems(query)
    searchResults = {}
    query = string.lower(query)
    for _, item in pairs(exportL.itemList) do
		if fAvgCheckbox:GetChecked() then
			if profile[tostring(item.itemId)] then
				if profile[tostring(item.itemId)][1] then 
				    if string.find(string.lower(item.itemName), query) then
						table.insert(searchResults, item)
					end
				end
			else
				if item.getAvg then
					if string.find(string.lower(item.itemName), query) then
						table.insert(searchResults, item)
					end
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

local function addToLog(text)
	logText = logText..text.."\n"
end

function splitString(input, delimiter)
    local result = {}
    -- Escape magic characters in the delimiter
    delimiter = delimiter:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    for match in (input..delimiter):gmatch("(.-)" .. delimiter) do
        if match ~= "" then
            table.insert(result, match)
        end
    end
    return result
end

local function updateSearchResults(avg)
	if selectedRow then selectedRow.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5) end
	selectedRow = nil
	
    local query = searchBox:GetText()
    local results = avg or searchItems(query)
    for i, row in ipairs(resultRows) do
        if results[i] then
			local avgQ = (profile[tostring(results[i].itemId)] and profile[tostring(results[i].itemId)][2]) or results[i].dataQ
			if string.sub(results[i].itemName, 1, string.len("Enchant")) == "Enchant" then
				local sString = splitString(results[i].itemName, "-")
				row.text:SetText("Ench - "..sString[2]:gsub("%%$", "").." ("..avgQ..")")
			else
				row.text:SetText(results[i].itemName.." ("..avgQ..")")
			end
            row.itemData = results[i]
            row:Show()
        else
            row.text:SetText("")
            row.itemData = nil
            row:Hide()
        end
    end
    if selectedRow and (not selectedRow.itemData or not string.find(string.lower(selectedRow.itemData.itemName), string.lower(query))) then
        selectedRow.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
        selectedRow = nil
    end
end

local function reset()
	if selectedRow then
		selectedRow.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
		selectedRow = nil
	end
	profile = {}
	searchBox:SetText("")				
	searchResults = {}
	updateSearchResults()
end

local function getAvgData()
	if tableLength(searchList) == 0 and not skipAvgCheckbox:GetChecked() then
		for i,v in pairs(exportL.itemList) do
			if profile[tostring(v.itemId)] then
				if profile[tostring(v.itemId)][1] then searchList[tostring(v.itemId)] = v end
			elseif v.getAvg then searchList[tostring(v.itemId)] = v end							
		end
	end
	for d,v in pairs(searchList) do
		if not tableContains(tempList,v.itemId) then
			addToLog("Search for: "..v.itemId.."  "..v.itemName)
			local itemKey = C_AuctionHouse.MakeItemKey(v.itemId)
			C_AuctionHouse.SendSearchQuery(itemKey, {}, false)			
			local tLL = tableLength(tempList)
			C_Timer.After(3, function()			
				local function dontStop(x)
					addToLog(x.."  "..tableLength(tempList))
					if x == tableLength(tempList) then
						addToLog("Run getavgdataagain")
						getAvgData()
					end		
				end			
				dontStop(tLL)
			end)			
			return
		end
	end
	if tableLength(searchList) == tableLength(tempList) then
		addToLog("AVG done")
		status = 2
		getFastData()		
	end

end

local function createResultButton(index)
    local row = CreateFrame("Button", nil, settingsContentFrame)
    row:SetSize(300, 24)
    row:SetPoint("TOPLEFT", settingsContentFrame, "TOPLEFT", -4, -4 - (index - 1) * 26)
    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints()
    row.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
    row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
    row.highlight:SetAllPoints()
    row.highlight:SetColorTexture(0.3, 0.3, 0.3, 0.6)
    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.text:SetPoint("LEFT", row, "LEFT", 10, 0)

    row:SetScript("OnClick", function(self)
        if selectedRow then
            selectedRow.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
        end
        self.bg:SetColorTexture(0.2, 0.5, 0.8, 0.6)
        selectedRow = self

        if self.itemData then					
			if profile[tostring(selectedRow.itemData.itemId)] then
				avgEditBox:SetText(profile[tostring(selectedRow.itemData.itemId)][2])
				if profile[tostring(selectedRow.itemData.itemId)][1] then
					avgCheckbox:SetChecked(true)
				else
					avgCheckbox:SetChecked(false)
				end
			elseif self.itemData.getAvg then
				avgCheckbox:SetChecked(true)
				avgEditBox:SetText(tonumber(self.itemData.dataQ))
			else
				avgCheckbox:SetChecked(false)
				avgEditBox:SetText(tonumber(self.itemData.dataQ))
			end

            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. self.itemData.itemId)
            GameTooltip:Show()
        end
    end)

    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    return row
end

local function showAllAvg()
	local avgList = {}
	for i,v in pairs(exportL.itemList) do
		if profile[tostring(v.itemId)] then
			if profile[tostring(v.itemId)][1] then table.insert(avgList, v) end
		elseif v.getAvg then 
			table.insert(avgList, v) 
		end
	end
	updateSearchResults(avgList)
end

function exportDataFrame()
	if not exportFrame then
		exportFrame = CreateFrame("Frame", "ExportFrame", AuctionHouseFrame, "PortraitFrameTemplate")
		ButtonFrameTemplate_HidePortrait(exportFrame)
		exportFrame:SetSize(350, 300)
		exportFrame:SetPoint("CENTER")
		exportFrame.title = _G["ExportFrameTitleText"]
		exportFrame.title:SetText("AVGExport")
		exportFrame:SetFrameStrata("HIGH")

		exportScrollFrame = CreateFrame("ScrollFrame", nil, exportFrame, "UIPanelScrollFrameTemplate")
		exportScrollFrame:SetPoint("TOPLEFT", 20, -23)
		exportScrollFrame:SetPoint("BOTTOMRIGHT", -25, 8)

		exportEditBox = CreateFrame("EditBox", nil, exportScrollFrame)
		exportEditBox:SetMultiLine(true)
		exportEditBox:SetFontObject(ChatFontNormal)
		exportEditBox:SetWidth(300)
		exportEditBox:SetAutoFocus(false)
		exportEditBox:SetScript("OnEscapePressed", exportEditBox.ClearFocus)
		exportScrollFrame:SetScrollChild(exportEditBox)
		
		loadingText = exportScrollFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		loadingText:SetPoint("CENTER")
		loadingText:SetText(loading.."%")
		local myFont = CreateFont("MyAddonFont")
		myFont:SetFont("Fonts\\FRIZQT__.TTF", 44, "")
		--myFont:SetTextColor(1, 1, 1)  -- white
		myFont:SetShadowOffset(1, -1)
		loadingText:SetFontObject(myFont)
	end

	exportFrame:Show()
end

local function addDataToExportFrame()
	loadingText:SetText("Done")
	exportEditBox:SetText('\"Price\",\"Name\",\"Item Level\",\"Owned?\",\"Available\"'.."\n")
	for _,i in pairs(exportL.itemList) do
		exportEditBox:SetText(exportEditBox:GetText()..math.floor(i.price + 0.5)..",\""..i.itemName.."\""..",70,\"\",0\n")
	end
end

function openLog()
	if not logFrame then
		logFrame = CreateFrame("Frame", "LogFrame", AuctionHouseFrame, "PortraitFrameTemplate")
		ButtonFrameTemplate_HidePortrait(logFrame)
		logFrame:SetSize(350, 300)
		logFrame:SetPoint("RIGHT")
		logFrame.title = _G["LogFrameTitleText"]
		logFrame.title:SetText("Log")
		logFrame:SetFrameStrata("HIGH")

		logScrollFrame = CreateFrame("ScrollFrame", nil, logFrame, "UIPanelScrollFrameTemplate")
		logScrollFrame:SetPoint("TOPLEFT", 20, -23)
		logScrollFrame:SetPoint("BOTTOMRIGHT", -25, 8)

		logEditBox = CreateFrame("EditBox", nil, logScrollFrame)
		logEditBox:SetMultiLine(true)
		logEditBox:SetFontObject(ChatFontNormal)
		logEditBox:SetWidth(300)
		logEditBox:SetAutoFocus(false)
		logEditBox:SetScript("OnEscapePressed", logEditBox.ClearFocus)
		logScrollFrame:SetScrollChild(logEditBox)
	end
	logEditBox:SetText(logText)
	logFrame:Show()
end

function getFastData()
	if tableLength(tempList) >= tableLength(exportL.itemList) then
		addToLog("Stop trigger 2")	
		status = 0
		scanBtn:SetText("Scan")
		scanBtn:Enable()
		addDataToExportFrame()
		return
	end
	local keys = {}
	local count = 0
	for i,v in pairs(exportL.itemList) do
		if not tableContains(tempList,v.itemId) then
			v.sCount = v.sCount + 1 
			if v.skip == nil and v.sCount < 5 then		
				table.insert(keys, C_AuctionHouse.MakeItemKey(v.itemId))
				if count == 50 then
					break
				end
				count = count + 1				
			else		
				table.insert(tempList,v.itemId)			
				if tableLength(tempList) == tableLength(exportL.itemList) then
					for _,vb in pairs(exportL.itemList) do
						vb.sCount = 0
					end					
					addToLog("Stop trigger 3")		
					status = 0
					scanBtn:SetText("Scan")
					scanBtn:Enable()
					tempList = {}
					addDataToExportFrame()
					return
				end	
			end			
		end
	end
	C_AuctionHouse.SearchForItemKeys(keys,{})
	
	local tLL = tableLength(tempList)
	C_Timer.After(2, function()			
		local function dontStop(x)
			addToLog(x.."  "..tableLength(tempList))
			if x == tableLength(tempList) then
				addToLog("Run getfastdataagain")
				getFastData()
			end		
		end			
		dontStop(tLL)
	end)
end

local function openSettings()
	if settingsFrame and settingsFrame:IsShown() then
		settingsFrame:Hide()
		return 
	elseif settingsFrame then
		settingsFrame:Show()
		return
	end
	settingsFrame = CreateFrame("Frame", "SettingsFrame", mainFrame, "BackdropTemplate")
	settingsFrame:SetSize(350, 350)
	settingsFrame:SetPoint("TOPLEFT", mainFrame, "BOTTOMLEFT", 0, 0)
	settingsFrame:SetBackdrop({
		bgFile = "Interface\\FrameGeneral\\UI-Background-Marble",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 8, right = 8, top = 8, bottom = 8 }
	})

	local settingsScrollFrame = CreateFrame("ScrollFrame", nil, settingsFrame, "UIPanelScrollFrameTemplate")
	settingsScrollFrame:SetPoint("TOPLEFT", 15, -45)
	settingsScrollFrame:SetPoint("BOTTOMRIGHT", -35, 40)

	settingsContentFrame = CreateFrame("Frame", nil, settingsScrollFrame)
	settingsContentFrame:SetSize(1, 1)
	settingsScrollFrame:SetScrollChild(settingsContentFrame)

	StaticPopupDialogs["MY_CONFIRM_POPUP"] = {
		text = "Are you sure you want to reset all?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			reset()
		end,
		OnCancel = function()
			addToLog("Cancelled.")
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}

	local resetSettingsBtn = CreateFrame("Button", "ResetSettingsBtn", settingsFrame, "UIPanelButtonTemplate")
    resetSettingsBtn:SetSize(60, 25)
    resetSettingsBtn:SetText("Reset")
    resetSettingsBtn:SetPoint("BOTTOMRIGHT", settingsFrame, "BOTTOMRIGHT", -12, 13)
    resetSettingsBtn:SetScript("OnClick", function()
		StaticPopup_Show("MY_CONFIRM_POPUP")
    end)

	local avgFrame = CreateFrame("Frame", nil, settingsFrame)
	avgFrame:SetSize(1, 1)
	avgFrame:SetPoint("BOTTOMLEFT", settingsFrame, "BOTTOMLEFT", 0, 0)
	avgFrame:SetSize(125, 40)
	avgFrame:SetClipsChildren(true) 
	avgCheckbox = CreateFrame("CheckButton", "MyAddonCheckbox", avgFrame, "ChatConfigCheckButtonTemplate")
	avgCheckbox:SetPoint("BOTTOMLEFT", avgFrame, "BOTTOMLEFT", 90, 15)
	avgCheckbox.Text:SetText("Avg price:")
	avgCheckbox.Text:ClearAllPoints()
	avgCheckbox.Text:SetPoint("RIGHT", avgCheckbox, "LEFT", 0, 2)
	avgCheckbox.Text:SetTextColor(1, 0.8196, 0)
	avgCheckbox:SetSize(20, 20)
	avgCheckbox.Text:EnableMouse(false)
		
	avgCheckbox:SetScript("OnClick", function(self)
		if selectedRow == nil then return end
		if self:GetChecked() then
			--selectedRow.itemData.getAvg = true
			profile[tostring(selectedRow.itemData.itemId)] = {true,selectedRow.itemData.dataQ}
		else
			--selectedRow.itemData.getAvg = false
			profile[tostring(selectedRow.itemData.itemId)] = {false,selectedRow.itemData.dataQ}
		end
	end)

	local avgText = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	avgText:SetPoint("BOTTOMLEFT", settingsFrame, "BOTTOMLEFT", 120, 20)
	avgText:SetText("Avg quantity:")
	avgEditBox = CreateFrame("EditBox", nil, settingsFrame, "InputBoxTemplate")
	avgEditBox:SetSize(200, 30)
	avgEditBox:SetPoint("BOTTOMLEFT", settingsFrame, "BOTTOMLEFT", 220, 11)
	avgEditBox:SetAutoFocus(false)
	avgEditBox:SetSize(50, 30)
	avgEditBox:SetNumeric(true)
	avgEditBox:SetScript("OnTextChanged", function(self, userInput)
		if userInput then		
			--selectedRow.itemData.dataQ = tonumber(avgEditBox:GetText())
			if selectedRow == nil then return end
			profile[tostring(selectedRow.itemData.itemId)] = {avgCheckbox:GetChecked(),tonumber(avgEditBox:GetText())}
			local sString = splitString(selectedRow.text:GetText(), "(")
			selectedRow.text:SetText(sString[1].."("..avgEditBox:GetText()..")")
			--selectedRow.text:SetText(selectedRow.itemData.itemName.." ("..avgEditBox:GetText()..")")
		end
	end)
	
	local searchBoxText = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	searchBoxText:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 15, -25)
	searchBoxText:SetText("Search:")
		
	searchBox = CreateFrame("EditBox", nil, settingsFrame, "InputBoxTemplate")
	searchBox:SetSize(130, 30)
	searchBox:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 70, -17)
	searchBox:SetAutoFocus(false)
		
	fAvgFrame = CreateFrame("Frame", nil, settingsFrame)
	fAvgFrame:SetSize(1, 1)
	fAvgFrame:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", -20, -18)
	fAvgFrame:SetSize(125, 40)
	fAvgFrame:SetClipsChildren(true) 
	fAvgCheckbox = CreateFrame("CheckButton", "MyAddonCheckbox", fAvgFrame, "ChatConfigCheckButtonTemplate")
	fAvgCheckbox:SetPoint("BOTTOMLEFT", fAvgFrame, "BOTTOMLEFT", 90, 15)
	fAvgCheckbox.Text:SetText("Filter AVG:")
	fAvgCheckbox.Text:ClearAllPoints()
	fAvgCheckbox.Text:SetPoint("RIGHT", fAvgCheckbox, "LEFT", -2, 1)
	fAvgCheckbox.Text:SetTextColor(1, 0.8196, 0)
	fAvgCheckbox:SetSize(20, 20)
	fAvgCheckbox.Text:EnableMouse(false)
		
	fAvgCheckbox:SetScript("OnClick", function(self)
		updateSearchResults(avgList)
	end)
	
	for i = 1, 518 do
		resultRows[i] = createResultButton(i)
	end
	searchBox:SetScript("OnTextChanged", function(self, userInput)
		if userInput then
			updateSearchResults()
		end
	end)
end

local function createGui()
	if scanBtn then return end
	mainFrame = CreateFrame("Frame", "MyFrame", AuctionHouseFrame, "BackdropTemplate")
	mainFrame:SetSize(150, 77)
	mainFrame:SetPoint("TOPRIGHT", AuctionHouseFrame, "TOPRIGHT", 150, -10)
	mainFrame:SetBackdrop({
		bgFile = "Interface\\FrameGeneral\\UI-Background-Marble",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 8, right = 8, top = 8, bottom = 8 }
	})
	
	
    local btn = CreateFrame("Button", "ScanBtn", mainFrame, "UIPanelButtonTemplate")
    btn:SetSize(60, 25)
    btn:SetText("Scan")
    btn:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 17, -15)
    btn:SetScript("OnClick", function()
		local tLL = tableLength(tempList)
		for _,vb in pairs(exportL.itemList) do vb.sCount = 0 end
		logText = ""
		addToLog("Start search")
        status = 1
		tempList = {}
		searchList = {}
		btn:SetText(tLL.."/"..tableLength(exportL.itemList))
		exportDataFrame()
		exportEditBox:SetText("")
		loading = 0
		getAvgData()
    end)
		
	skipAvgFrame = CreateFrame("Frame", nil, mainFrame)
	skipAvgFrame:SetSize(1, 1)
	skipAvgFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", -5, -38)
	skipAvgFrame:SetSize(125, 40)
	skipAvgFrame:SetClipsChildren(true) 
	skipAvgCheckbox = CreateFrame("CheckButton", "MyAddonCheckbox", skipAvgFrame, "ChatConfigCheckButtonTemplate")
	skipAvgCheckbox:SetPoint("BOTTOMLEFT", skipAvgFrame, "BOTTOMLEFT", 90, 15)
	skipAvgCheckbox.Text:SetText("Skip AVG:") 
	skipAvgCheckbox.Text:ClearAllPoints()
	skipAvgCheckbox.Text:SetPoint("RIGHT", skipAvgCheckbox, "LEFT", -2, 1)
	skipAvgCheckbox.Text:SetTextColor(1, 0.8196, 0)
	skipAvgCheckbox:SetSize(20, 20)
	skipAvgCheckbox.Text:EnableMouse(false)				
		
	local logBtn = CreateFrame("Button", "LogBtn", mainFrame, "UIPanelButtonTemplate")
    logBtn:SetSize(25, 25)
    logBtn:SetText("L")
    logBtn:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 111, -15)
    logBtn:SetScript("OnClick", function()
		openLog()
    end)	
		
	local settingsBtn = CreateFrame("Button", "SettingsBtn", mainFrame, "UIPanelButtonTemplate")
    settingsBtn:SetSize(25, 25)
    settingsBtn:SetText("S")
    settingsBtn:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 82, -15)
    settingsBtn:SetScript("OnClick", function()
		openSettings()
    end)
	scanBtn = btn
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
    if status == 0 then return end
	local calcQ = 0
	local avgPrice = 0
	addToLog("Trigg before")
	if not tableContains(tempList,itemID) then
		addToLog("Triggered for: "..itemID)
		item = searchList[tostring(itemID)]
		if not item.skip then
			local dataQ = (profile[tostring(itemID)] and profile[tostring(itemID)][2]) or item.dataQ
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
			item.price = avgPrice/dataQ		
		end
		if avgPrice ~= 0 then
			--print(exportL.itemList[tostring(itemID)].itemName.."   "..exportL.itemList[tostring(itemID)].price)
			table.insert(tempList, itemID)
			local tlL = tableLength(tempList)
			local ilL = tableLength(exportL.itemList)
			scanBtn:SetText(tlL.."/"..ilL)
			loading = math.floor((tlL/ilL*100) + 0.5)
			loadingText:SetText(loading.."%")
		end
		
	end
	getAvgData()
end)

registerMyEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED", function(self, event, ...)
	if status ~= 2 then return end
    local results = C_AuctionHouse.GetBrowseResults()
    for i, result in pairs(results) do
		if result.minPrice ~= 0 then
			table.insert(tempList,result.itemKey.itemID)
			exportL.itemList[tostring(result.itemKey.itemID)].price = result.minPrice
			local tlL = tableLength(tempList)
			local ilL = tableLength(exportL.itemList)
			scanBtn:SetText(tlL.."/"..ilL)
			loading = math.floor((tlL/ilL*100) + 0.5)
			loadingText:SetText(loading.."%")
		end
	end
	if tableLength(tempList) ~= tableLength(exportL.itemList) then
		getFastData()
	else
		addToLog("Stop trigger 1")	
		status = 0
		scanBtn:SetText("Scan")
		scanBtn:Enable()
		tempList = {}
		addDataToExportFrame()	
	end
end)

registerMyEvent("AUCTION_HOUSE_SHOW", function(_, event, arg1)
	createGui()
end)

registerMyEvent("AUCTION_HOUSE_CLOSED", function(_, event, arg1)
	status = 0
	if exportFrame then
		exportFrame:Hide()
	end
	if logFrame then
		logFrame:Hide()
	end
	scanBtn:SetText("Scan")
end)

registerMyEvent("ADDON_LOADED", function(_, event, arg1)
	if arg1 == "AVGExport" then
		if exportSSprofile == nil then
			addToLog("no profile list")			
			profile = {}
		else
			addToLog("we got profile list")
			profile = exportSSprofile
		end
	end
end)

registerMyEvent("PLAYER_LOGOUT", function(_, event, arg1)
	exportSSprofile = profile
end)




