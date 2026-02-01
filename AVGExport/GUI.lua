local _, AVGE = ...

function AVGE:CreateFrame(name, parent, loc1, loc2, x, y, width, height, template, hide)
    local template = template or nil
	local frame = CreateFrame("Frame", name, parent, template)
	frame:SetPoint(loc1, parent, loc2, x, y)
	frame:SetSize(width, height)
	--frame:SetClipsChildren(true)
	if template and template == "BackdropTemplate" then
		frame:SetBackdrop({
			bgFile = "Interface\\FrameGeneral\\UI-Background-Marble",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 32,
			insets = { left = 8, right = 8, top = 8, bottom = 8 }
		})
	end
	if template and template == "PortraitFrameTemplate" then
		ButtonFrameTemplate_HidePortrait(frame)
		frame.title = _G[name.."TitleText"]
		frame.title:SetText("AVGExport")
		frame:SetFrameStrata("HIGH")
	end
	if hide then frame:Hide() end
	return frame
end

function AVGE:CreateCheckbox(name, parent, labelText, loc1, loc2, x, y, width, height)
    local frame = AVGE:CreateFrame("Frame", parent, loc1, loc2, x, y, width, height, nil)
	frame:SetClipsChildren(true)
	local checkbox = CreateFrame("CheckButton", name, frame, "ChatConfigCheckButtonTemplate")   	
	checkbox:SetSize(20, 20)
    checkbox:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 90, 15)   
    checkbox.Text:SetText(labelText)
    checkbox.Text:ClearAllPoints()
    checkbox.Text:SetPoint("RIGHT", checkbox, "LEFT", -2, 1)
    checkbox.Text:SetTextColor(1, 0.8196, 0)
	checkbox.Text:EnableMouse(false)
    return checkbox
end

function AVGE:CreateBtn(name, parent, labelText, loc1, loc2, x, y, width, height) 
	local btn = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
	btn:SetSize(width, height)
    btn:SetText(labelText)
    btn:SetPoint(loc1, parent, loc2, x, y)
    return btn
end

function AVGE:CreateScrollFrame(parent, loc1, loc2, x, y, xx, yy, template, frame) 
	local scrollFrame = CreateFrame("ScrollFrame", nil, parent, template)
	scrollFrame:SetPoint(loc1, x, y)
	scrollFrame:SetPoint(loc2, xx, yy)
	if frame then
		local contentFrame = CreateFrame("Frame", nil, scrollFrame)
		contentFrame:SetSize(1, 1)
		scrollFrame:SetScrollChild(contentFrame)
		return contentFrame
	end
	return scrollFrame
end

function AVGE:CreateFont(parent, labelText, loc1, loc2, x, y, font)
	local text = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	text:SetPoint(loc1, parent, loc2, x, y)
	text:SetText(labelText)
	if font then
		local myFont = CreateFont("MyAddonFont")
		myFont:SetFont("Fonts\\FRIZQT__.TTF", 44, "")
		myFont:SetShadowOffset(1, -1)
		text:SetFontObject(myFont)
	end
	return text
end

function AVGE:CreateEditBox(parent, loc1, loc2, x, y, width, height, template, export)
	local editBox = CreateFrame("EditBox", nil, parent, template)
	if export then
		editBox:SetMultiLine(true)
		editBox:SetFontObject(ChatFontNormal)
		editBox:SetWidth(width)
		editBox:SetScript("OnEscapePressed", editBox.ClearFocus)
		parent:SetScrollChild(editBox)
	else
		editBox:SetSize(width, height)
		editBox:SetPoint(loc1, parent, loc2, x, y)
	end
	editBox:SetAutoFocus(false)
	return editBox
end