--[[
	BuildString
	Spell?Talent?SkillCard?RE
	
	SpellString
	Spell_ID:
	
	TalentString
	Class:Spec:Row:Column:Points+
	
	SkillCardString
	SkillCard1:SkillCard2:GSkillCard1:GSkillCard2
	
	REString
	RE_ID:Slot_ID+

	--Main Frame
		--Load and Save Build
		--Build Select Drop Down Menu
		--Class/Spec Select Drop Down Menu
		--Tabs at the bottom that swap the Inner Frame Group
	--Spell and Talent Inner Frame Group
	--RE and SkillCard Inner Frame Group
	--Summary Frame Inner Group
	--Skill Card Collection Inner Frame Group
		--Dropdown for character select and option to show all
		--Dropdown to show only regular or gold skill cards
]]

local MAX_TALENTS = 44;
local MAX_SPELLS = 36;

local SpellButtons = {}
local TalentButtons = {}

local Spells = {};
local Talents = {
	CLASS = 1,
	SPEC = 2,
	ROW = 3,
	COL = 4,
	POINTS = 5,
	total = 0,
};

local classSelected = "DRUID";
local specSelected = "BALANCE";


function OnLoad(frame)
	InitDB()

	BuildFrame(frame);
	SetupTalentLayout(frame);

	PanelTemplates_SetNumTabs(frame, 4)
	PanelTemplates_SetTab(frame, 1)
end

function BuildFrame(frame)
		
		local titlebg = frame:CreateTexture(nil, "BORDER")
		titlebg:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Title-Background")
		titlebg:SetPoint("TOPLEFT", 9, -6)
		titlebg:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -28, -24)

		local dialogbg = frame:CreateTexture(nil, "BACKGROUND")
		dialogbg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-CharacterTab-L1")
		dialogbg:SetPoint("TOPLEFT", 8, -12)
		dialogbg:SetPoint("BOTTOMRIGHT", -6, 8)
		dialogbg:SetTexCoord(0.255, 1, 0.29, 1)
		--[[
		local topleft = frame:CreateTexture(nil, "BORDER")
		topleft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft")
		topleft:SetWidth(64)
		topleft:SetHeight(64)
		topleft:SetPoint("TOPLEFT")
		--topleft:SetTexCoord(0.501953125, 0.625, 0, 1)

		local topright = frame:CreateTexture(nil, "BORDER")
		topleft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight")
		topright:SetWidth(64)
		topright:SetHeight(64)
		topright:SetPoint("TOPRIGHT")
		--topright:SetTexCoord(0.625, 0.75, 0, 1)

		
		local top = frame:CreateTexture(nil, "BORDER")
		top:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
		top:SetHeight(64)
		top:SetPoint("TOPLEFT", topleft, "TOPRIGHT")
		top:SetPoint("TOPRIGHT", topright, "TOPLEFT")
		top:SetTexCoord(0.25, 0.369140625, 0, 1)
		
		local bottomleft = frame:CreateTexture(nil, "BORDER")
		topleft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
		bottomleft:SetWidth(64)
		bottomleft:SetHeight(64)
		bottomleft:SetPoint("BOTTOMLEFT")
		--bottomleft:SetTexCoord(0.751953125, 0.875, 0, 1)

		local bottomright = frame:CreateTexture(nil, "BORDER")
		topleft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
		bottomright:SetWidth(64)
		bottomright:SetHeight(64)
		bottomright:SetPoint("BOTTOMRIGHT")
		--bottomright:SetTexCoord(0.875, 1, 0, 1)

		
		local bottom = frame:CreateTexture(nil, "BORDER")
		bottom:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
		bottom:SetHeight(64)
		bottom:SetPoint("BOTTOMLEFT", bottomleft, "BOTTOMRIGHT")
		bottom:SetPoint("BOTTOMRIGHT", bottomright, "BOTTOMLEFT")
		bottom:SetTexCoord(0.376953125, 0.498046875, 0, 1)

		local left = frame:CreateTexture(nil, "BORDER")
		left:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
		left:SetWidth(64)
		left:SetPoint("TOPLEFT", topleft, "BOTTOMLEFT")
		left:SetPoint("BOTTOMLEFT", bottomleft, "TOPLEFT")
		left:SetTexCoord(0.001953125, 0.125, 0, 1)

		local right = frame:CreateTexture(nil, "BORDER")
		right:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
		right:SetWidth(64)
		right:SetPoint("TOPRIGHT", topright, "BOTTOMRIGHT")
		right:SetPoint("BOTTOMRIGHT", bottomright, "TOPRIGHT")
		right:SetTexCoord(0.1171875, 0.2421875, 0, 1)
		]]--


		local dropDown = CreateFrame("Frame", "SpecSelect", HotCMainFrame.viewFrame.classFrame.navBar , "HotCDropDownMenuTemplate")
		dropDown:SetPoint("LEFT", 0, 0)
		
		UIDropDownMenu_SetWidth(dropDown, 135) -- Use in place of dropDown:SetWidth

		-- Bind an initializer function to the dropdown; see previous sections for initializer function examples.
		UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
			local info = UIDropDownMenu_CreateInfo()
			if (level or 1) == 1 then
			 	-- Display Class Options
				for i = 1, 9 do
					info.text, info.checked = SpecTable[i][1], classSelected == SpecTable[i][1]
					info.menuList, info.hasArrow = i, true
					UIDropDownMenu_AddButton(info)
				end
		   
			else
			 	-- Display a nested group of 10 favorite number options
				info.func = self.SetSpec
				for i = 1, 3 do
					info.text, info.arg1, info.arg2, info.checked = SpecTable[menuList][2][i], SpecTable[menuList][1], SpecTable[menuList][2][i], SpecTable[menuList][2][i] == specSelected
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end)

		function dropDown:SetSpec(class, spec)
			classSelected = class;
			specSelected = spec;
		
			ShowTalentsForSpec(class, spec);
			
			-- Update the text; if we merely wanted it to display newValue, we would not need to do this
			UIDropDownMenu_SetText(dropDown, specSelected)
			-- Because this is called from a sub-menu, only that menu level is closed by default.
			-- Close the entire menu with this next call
			CloseDropDownMenus()
		end
end

function InitDB()
	if not HotC then
		HotC = {}
	end
	
	if not HotC.builds then
		HotC.builds = {}
	end
end

function SetupTalentLayout(frame)

	local talent_frame = frame.viewFrame.classFrame.talentFrame

	for i = 1, MAX_TALENTS do
		TalentButtons[i] = CreateFrame("button", "talentBtn"..i, talent_frame, "TalentButton");
		TalentButtons[i]:SetPoint("TOP", talent_frame, -108 + ((((i-1) + 4) % 4) * 70), -12 - (math.floor((i-1) / 4) * 38));
	end

end

function SetupSpellLayout()

end

function LoadBuild(name)
	if HotC.builds[name] then
		Spells = {};
		Talents = {
			CLASS = 1,
			SPEC = 2,
			ROW = 3,
			COL = 4,
			POINTS = 5,
		};
		local finalized = HotC.builds[name];
		local spellString, talentString = strsplit("?", finalized)
		
		spellString = {strsplit(":", spellString)}
		talentString = {strsplit("+", talentString)}
		
		for i = 1, #spellString do
			Spells[i] = spellString[i]
		end
		
		for i = 1, #talentString do 
			local class, spec, row, col, points = strsplit(":", talentString[i])
			table.insert(Talents, {class, spec, row, col, points})
		end
	end
end

function SaveBuild(name)
	local spellString = ""
	local talentString = ""
	local finalized = ""
	
	for i = 1, #Spells do
		spellString = spellString..Spells[i]..":"
	end
	
	for i = 1, #Talents do
		local subTalent = Talents[i][1]..":"..Talents[i][2]..":"..Talents[i][3]..":"..Talents[i][4]..":"..Talents[i][5]
		talentString = talentString..subTalent.."+"
	end
	
	finalized = spellString.."?"..talentString
	
	table.insert(HotC.builds, name)
	HotC.builds[name] = finalized
end

function ShowSpellsForSpec()

end

function ShowTalentsForSpec(class, spec)
	--Hide all talent buttons, will show appropriate ones later
	for i = 1, MAX_TALENTS do 
		TalentButtons[i]:Hide();
	end
	
	for i = 1, #Class_DB[class][spec]["Talents"] do
		local talent = Class_DB[class][spec]["Talents"][i]
		local talent_loc = ((talent[1] - 1) * 4) + talent[2]
		
		local _, _, texture = GetSpellInfo(talent[3][1])
		
		local maxRank = #talent[3];
		local showBadge = maxRank > 1;

		TalentButtons[talent_loc].maxRank = maxRank;

		if not showBadge then
			TalentButtons[talent_loc].badge:Hide()
			TalentButtons[talent_loc].rank:Hide()
		else
			TalentButtons[talent_loc].badge:Show()
			TalentButtons[talent_loc].rank:Show()
		end


		TalentButtons[talent_loc].curRank = 0;

		if Talents[class] ~= nil and Talents[class][spec] ~= nil and Talents[class][spec][talent[3][1]] ~= nil then
			TalentButtons[talent_loc].curRank = Talents[class][spec][talent[3][1]]
		end

		if TalentButtons[talent_loc].curRank > maxRank then TalentButtons[talent_loc].curRank = maxRank; end
		
		TalentButtons[talent_loc].icon:SetTexture(texture)

		TalentButtons[talent_loc].rank:SetFontObject(GameFontGreenSmall)
		TalentButtons[talent_loc].icon:SetDesaturated(0);
		
		if TalentButtons[talent_loc].curRank == TalentButtons[talent_loc].maxRank then
			TalentButtons[talent_loc].rank:SetFontObject(GameFontNormalSmall)
		elseif TalentButtons[talent_loc].curRank == 0 then
			TalentButtons[talent_loc].rank:SetFontObject(GameFontDarkGraySmall)
			TalentButtons[talent_loc].icon:SetDesaturated(1);	
		end
		
		TalentButtons[talent_loc].class = class
		TalentButtons[talent_loc].spec = spec
		TalentButtons[talent_loc].ranks = talent[3]
		local linkRank = math.max(TalentButtons[talent_loc].curRank, 1);
		TalentButtons[talent_loc].link = talent[3][linkRank]
		TalentButtons[talent_loc].level = (talent[1] * 5) + 5

		TalentButtons[talent_loc].rank:SetText(TalentButtons[talent_loc].curRank.."/"..maxRank)
		

		if UnitLevel("player") < TalentButtons[talent_loc].level then
			TalentButtons[talent_loc].level = "|cffff0000"..TalentButtons[talent_loc].level;
		else
			TalentButtons[talent_loc].level = "|cffFFFFFF"..TalentButtons[talent_loc].level;
		end
		 
		TalentButtons[talent_loc]:Show()
	end
end

function UpdateTalentButton(button, arg)
	if arg == "LeftButton" and (Talents.total + 1 < 51) then
		if (button.curRank + 1 <= button.maxRank) then
			Talents.total = Talents.total + 1;
			button.curRank = math.min(button.curRank + 1, button.maxRank)
		else
			return
		end
	elseif arg == "RightButton" then
		if not (button.curRank - 1 < 0) then
			Talents.total = Talents.total - 1
			button.curRank = math.max( button.curRank - 1, 0);
		else
			return
		end 
	end

	if (arg == "LeftButton") or (arg == "RightButton") then
		if button.curRank > button.maxRank then button.curRank = button.maxRank; end
		if button.curRank < 0 then button.curRank = 0; end

		button.rank:SetFontObject(GameFontGreenSmall)
		button.icon:SetDesaturated(0);
		
		if button.curRank == button.maxRank then
			button.rank:SetFontObject(GameFontNormalSmall)
		elseif button.curRank == 0 then
			button.rank:SetFontObject(GameFontDarkGraySmall)
			button.icon:SetDesaturated(1);	
		end

		button.rank:SetText(button.curRank.."/"..button.maxRank)
		local temp = math.max(button.curRank, 1);
		button.link = button.ranks[temp];

		if(Talents[button.class] == nil) then Talents[button.class] = {} end;
		if(Talents[button.class][button.spec] == nil) then Talents[button.class][button.spec] = {} end
		
		if button.curRank == 0 then
			Talents[button.class][button.spec][button.ranks[1]] = nil
		else
			Talents[button.class][button.spec][button.ranks[1]] = button.curRank
		end
		
		HotCTooltip:Hide();
		HotCTooltip:SetOwner(button, "ANCHOR_RIGHT");
		HotCTooltip:SetHyperlink("spell:"..button.link);
		HotCTooltip:AddLine(" ");
		HotCTooltip:AddLine("Requires Level: "..button.level);
		HotCTooltip:Show();
	end
end

function ShowBuildOverview()
	
end

function ActivateSpellsForSpec()

end

function ActivateTalentsForSpec()

end

function ResetTalentButton(button)
	
end

function AddSpellToBuild()

end

function AddTalentToBuild(button)
	--if not button.talentTableVar then
		--Talents[button.talentTableVar]

end

function ShowClassFrame()
	
end

--Tab Functions
NUM_HOTCFRAME_TABS = 4;
local HotCTabtable = {};

local function CompareFrameSize(frame1, frame2)
	return frame1:GetWidth() > frame2:GetWidth();
end

function HotCFrame_TabBoundsCheck(self)
	if ( string.sub(self:GetName(), 1, 16) ~= "HotCMainFrameTab" ) then
		return;
	end
	
	local totalSize = 60;
	for i=1, NUM_HOTCFRAME_TABS do
		_G["HotCMainFrameTab"..i.."Text"]:SetWidth(0);
		PanelTemplates_TabResize(_G["HotCMainFrameTab"..i], 0);
		totalSize = totalSize + _G["HotCMainFrameTab"..i]:GetWidth();
	end
	
	local diff = totalSize - 465
	
	if ( diff > 0 and HotCMainFrameTab4:IsShown() and HotCMainFrameTab2:IsShown()) then
		--Find the biggest tab
		for i=1, NUM_HOTCFRAME_TABS do
			HotCTabtable[i]=_G["HotCMainFrameTab"..i];
		end
		table.sort(HotCTabtable, CompareFrameSize);
		
		local i=1;
		while ( diff > 0 and i <= NUM_HOTCFRAME_TABS) do
			local tabText = _G[HotCTabtable[i]:GetName().."Text"]
			local change = min(10, diff);
			tabText:SetWidth(tabText:GetWidth() - change);
			diff = diff - change;
			PanelTemplates_TabResize(HotCTabtable[i], 0);
			i = i+1;
		end
	end
end