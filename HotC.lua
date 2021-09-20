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
	local window = frame;

	local titlebg = window:CreateTexture(nil, "BORDER")
	titlebg:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Title-Background")
	titlebg:SetPoint("TOPLEFT", 9, -6)
	titlebg:SetPoint("BOTTOMRIGHT", window, "TOPRIGHT", -28, -24)

	local dialogbg = window:CreateTexture(nil, "BACKGROUND")
	dialogbg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-CharacterTab-L1")
	dialogbg:SetPoint("TOPLEFT", 8, -12)
	dialogbg:SetPoint("BOTTOMRIGHT", -6, 8)
	dialogbg:SetTexCoord(0.255, 1, 0.29, 1)

	local dropDown = CreateFrame("Frame", "SpecSelect", HotCMainFrame.viewFrame.classFrame.navBar , "HotCDropDownMenuTemplate")
	dropDown:SetPoint("LEFT", -10, -2)
	
	UIDropDownMenu_SetWidth(dropDown, 135) -- Use in place of dropDown:SetWidth
	UIDropDownMenu_SetText(dropDown, "Select Class and Spec")
	-- Bind an initializer function to the dropdown; see previous sections for initializer function examples.
	UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		if (level or 1) == 1 then
			-- Display Class Options
			for i = 1, 9 do
				info.text = SpecTable[i][1]
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
		
		-- Because this is called from a sub-menu, only that menu level is closed by default.
		-- Close the entire menu with this next call
		CloseDropDownMenus()
	end

	SpellFrame.bg:SetTexture()
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
	--Set Background for spec
	local file = Class_DB[class][spec].File;
	local frame = "HotCTalentFrameBackground";
	_G[frame.."TopLeft"]:SetTexture(file.."-TopLeft")
	_G[frame.."TopRight"]:SetTexture(file.."-TopRight")
	_G[frame.."BottomLeft"]:SetTexture(file.."-BottomLeft")
	_G[frame.."BottomRight"]:SetTexture(file.."-BottomRight")

	--Hide all talent buttons, will show appropriate ones later
	for i = 1, MAX_TALENTS do 
		TalentButtons[i]:Hide();
	end
	
	for i = 1, #Class_DB[class][spec]["Talents"] do
		local talent = Class_DB[class][spec]["Talents"][i]
		local talent_loc = ((talent[1] - 1) * 4) + talent[2]
		
		local _, _, texture = GetSpellInfo(talent[3][1])
		
		local maxRank = #talent[3];

		TalentButtons[talent_loc].maxRank = maxRank;

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
			TalentPointsText:SetText(Talents.total.."/51");
			button.curRank = math.min(button.curRank + 1, button.maxRank)
		else
			return
		end
	elseif arg == "RightButton" then
		if not (button.curRank - 1 < 0) then
			Talents.total = Talents.total - 1
			TalentPointsText:SetText(Talents.total.."/51");
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

