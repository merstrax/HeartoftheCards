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

local ovTalentCats = {}
local ovTalentSubCats = {}

local ovSpellCats = {}
local ovSpellSubCats = {}

HotCSpells = {
	total = 0
};
HotCTalents = {
	CLASS = 1,
	SPEC = 2,
	ROW = 3,
	COL = 4,
	POINTS = 5,
	total = 0,
};

HotCclassSelected = "DRUID";
HotCspecSelected = "BALANCE";

function OnLoad(frame)
	InitDB()

	BuildFrame(frame);
	SetupSpellLayout(frame);
	SetupTalentLayout(frame);
	SetupOverviewSpells()
	SetupOverviewTalents()

	PanelTemplates_SetNumTabs(frame, 4)
end

function InitDB()
	if not HotcDB then
		HotcDB = {}
	end
	
	if not HotcDB.builds then
		HotcDB.builds = {}
	end
end

--Start Frame Setups
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

	local dropDown = CreateFrame("Frame", "SpecSelect", _G[HotCNavBar:GetName()], "HotCDropDownMenuTemplate")
	dropDown:SetPoint("LEFT", -10, -2)
	
	UIDropDownMenu_SetWidth(dropDown, 135) -- Use in place of dropDown:SetWidth
	UIDropDownMenu_SetText(dropDown, "Select Class and Spec")
	-- Bind an initializer function to the dropdown; see previous sections for initializer function examples.
	UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		if (level or 1) == 1 then
			-- Display Class Options
			info.func = self.SetSpec
			for i = 1, 9 do
				info.text, info.checked, info.arg1 = SpecTable[i][1], SpecTable[i][1] == HotCclassSelected, SpecTable[i][1]
				UIDropDownMenu_AddButton(info)
			end
		end
	end)

	function dropDown:SetSpec(class)
		HotCclassSelected = class;
		HotCspecSelected = SpecTable2[class][1];
		
		local navBar = HotCMainFrame.viewFrame.classFrame.navBar
		
		_G[navBar:GetName().."Tab1"]:SetText(SpecTable2[class][1]);
		_G[navBar:GetName().."Tab2"]:SetText(SpecTable2[class][2]);
		_G[navBar:GetName().."Tab3"]:SetText(SpecTable2[class][3]);


		ShowSpellsForSpec(HotCclassSelected, HotCspecSelected);
		ShowTalentsForSpec(HotCclassSelected, HotCspecSelected);
		UIDropDownMenu_SetText(dropDown, class)
		PanelTemplates_SetTab(HotCNavBar, 1);
		-- Close the entire menu with this next call
		CloseDropDownMenus()
	end

	SpellFrameBG:SetTexture("Interface\\Addons\\HotC\\Resources\\UI-Background-Paper")
	HotCclassSelected = "DRUID";
	HotCspecSelected = "BALANCE";
end

function SetupTalentLayout(frame)
	local talent_frame = frame.viewFrame.classFrame.talentFrame

	for i = 1, MAX_TALENTS do
		TalentButtons[i] = CreateFrame("button", "HotCtalentBtn"..i, talent_frame, "HotCTalentButton");
		TalentButtons[i]:SetPoint("TOP", talent_frame, -108 + ((((i-1) + 4) % 4) * 70), -12 - (math.floor((i-1) / 4) * 38));
	end

end

function SetupSpellLayout(frame)
	local spell_frame = frame.viewFrame.classFrame.spellFrame

	for i = 1, MAX_SPELLS do
		SpellButtons[i] = CreateFrame("frame", "HotCspellBtn"..i, spell_frame, "HotCSpellButtonFrame");
		SpellButtons[i]:SetPoint("TOPLEFT", spell_frame, 4 + ((((i-1) + 3) % 3) * 112), -10 - (math.floor((i-1) / 3) * 40));
	end
end

function SetupOverviewSpells()
	local spell_frame = HotCMainFrameViewFrameSummaryFrameSpellList;

	for i = 1, #SpecTable do
		ovSpellCats[i] = CreateFrame("Frame", "ovSpellCat"..i, spell_frame.child, "HotCCategoryFrame")
		ovSpellCats[i].button.title:SetText(SpecTable[i][1])
		if i == 1 then
			ovSpellCats[i]:SetPoint("TOPLEFT", spell_frame.child, "TOPLEFT")
		else
			ovSpellCats[i]:SetPoint("TOPLEFT", ovSpellCats[i-1]:GetName(), "BOTTOMLEFT", 0, -2);
		end
		ovSpellCats[i]:Hide();
	end

	for n = 1, 30 do
		ovSpellSubCats[n] = CreateFrame("Button", "ovSpellSubCat"..n, ovSpellCats[1].container , "HotCSubCatButton")
		if n == 1 then
			ovSpellSubCats[n]:SetPoint("TOPLEFT", ovSpellCats[1].container, "TOPLEFT")
		else
			ovSpellSubCats[n]:SetPoint("TOPLEFT", ovSpellSubCats[n-1]:GetName(), "BOTTOMLEFT", 0, -1);
		end
		ovSpellSubCats[n]:Hide();
	end
end

function SetupOverviewTalents()
	local talent_frame = HotCMainFrameViewFrameSummaryFrameTalentList;

	for i = 1, #SpecTable do
		ovTalentCats[i] = CreateFrame("Frame", "ovTalentCat"..i, talent_frame.child, "HotCCategoryFrame")
		ovTalentCats[i].button.title:SetText(SpecTable[i][1])
		if i == 1 then
			ovTalentCats[i]:SetPoint("TOPLEFT", talent_frame.child, "TOPLEFT")
		else
			ovTalentCats[i]:SetPoint("TOPLEFT", ovTalentCats[i-1]:GetName(), "BOTTOMLEFT", 0, -2);
		end
		ovTalentCats[i]:Hide();
	end

	for n = 1, 51 do
		ovTalentSubCats[n] = CreateFrame("Button", "ovTalentSubCat"..n, ovTalentCats[1].container , "HotCSubCatButton")
		if n == 1 then
			ovTalentSubCats[n]:SetPoint("TOPLEFT", ovTalentCats[1].container, "TOPLEFT")
		else
			ovTalentSubCats[n]:SetPoint("TOPLEFT", ovTalentSubCats[n-1]:GetName(), "BOTTOMLEFT", 0, -1);
		end
		ovTalentSubCats[n]:Hide();
	end
end
--End Frame Setup

--Start Load and Save Builds
function LoadBuild(name)
	if HotcDB.builds[name] then
		HotCSpells = {
			total = 0
		};
		HotCTalents = {
			CLASS = 1,
			SPEC = 2,
			ROW = 3,
			COL = 4,
			POINTS = 5,
			total = 0
		};
		local finalized = HotcDB.builds[name];
		local spellString, talentString = strsplit("?", finalized)

		if(spellString ~= "") then
			spellString = {strsplit("+", spellString)}
			for i = 1, #spellString do
				if spellString[i] ~= "" then
					local class, spec, spells = strsplit(":", spellString[i])
					if class ~= "" or spec ~= "" then
						if HotCSpells[class] == nil then
							HotCSpells[class] = {};
						end
						if HotCSpells[class][spec] == nil then
							HotCSpells[class][spec] = {};
						end
					
						HotCSpells[class][spec] = {strsplit("/", spells)};
						for n = 2, #HotCSpells[class][spec] do
							HotCSpells[class][spec][n-1] = tonumber(HotCSpells[class][spec][n])
						end

						HotCSpells.total = HotCSpells.total + (#HotCSpells[class][spec] * 2)
					end
				end
			end
		end
		
		if(talentString ~= "") then
			talentString = {strsplit("+", talentString)}
			for i = 1, #talentString do
				if(talentString[i] ~= "") then 
					local class, spec, rank_1, points = strsplit(":", talentString[i])

					if HotCTalents[class] == nil then
						HotCTalents[class] = {};
					end
					if HotCTalents[class][spec] == nil then
						HotCTalents[class][spec] = {};
					end
					print(class..":"..spec..":"..rank_1..":"..points)
					HotCTalents[class][spec][tonumber(rank_1)] = tonumber(points);
					HotCTalents.total = HotCTalents.total + points;
				end
			end
		end

		TalentPointsText:SetText(HotCTalents.total.."/51");
		AbilityPointsText:SetText(HotCSpells.total.."/60");
	end
end

function SaveBuild(name)
	local spellString = ""
	local talentString = ""
	local finalized = ""
	
	--SpellLayout : Spells["class_name"]["spec_name"] = {List of spells...}
	for class = 1, #SpecTable do
		if HotCSpells[SpecTable[class][1]] ~= nil then
			local _c = SpecTable[class][1];
			for spec = 1, 3 do
				if HotCSpells[_c][SpecTable[class][2][spec]] ~= nil then
					local _s = HotCSpells[_c][SpecTable[class][2][spec]];
					spellString = spellString.._c..":"..SpecTable[class][2][spec]..":"
					for spell = 1, #_s do
						spellString = spellString.."/".._s[spell]
					end
					spellString = spellString.."+"
				end
			end
		end
	end

	--TalentLayout : Talents["class_name"]["spec_name"] = {Rank_1, Points, {Ranks}}
	for class = 1, #SpecTable do
		if HotCTalents[SpecTable[class][1]] ~= nil then
			local _c = SpecTable[class][1];
			for spec = 1, 3 do
				if HotCTalents[_c][SpecTable[class][2][spec]] ~= nil then
					local _s = SpecTable[class][2][spec];
					for spell = 1, #Class_DB[_c][_s]["Talents"] do
						local _sp = Class_DB[_c][_s]["Talents"][spell][3][1]
						if HotCTalents[_c][_s][_sp] ~= nil then
							local rank = HotCTalents[_c][_s][_sp]
							if rank > 0 then
								talentString = talentString.._c..":".._s..":".._sp..":"..rank.."+"
							end
						end
					end
				end
			end
		end
	end
	
	finalized = spellString.."?"..talentString;

	if not (tContains(HotcDB.builds, name)) then
		table.insert(HotcDB.builds, name)
	end
	HotcDB.builds[name] = finalized
end
--End Load and Save Builds

--Class Frame Functions
function ShowClassFrame(class, spec)
	ShowSpellsForSpec(class, spec)
	ShowTalentsForSpec(class, spec)
end


function ShowSpellsForSpec(class, spec)
	for i = 1, MAX_SPELLS do 
		SpellButtons[i]:Hide();
	end

	table.sort (Class_DB[class][spec]["Spells"], function (k1, k2) return k1[2] < k2[2] end)

	for i = 1, #Class_DB[class][spec]["Spells"] do
		local spell = Class_DB[class][spec]["Spells"][i]

		SpellButtons[i].button.class = class
		SpellButtons[i].button.spec = spec

		if spell[3] ~= nil then
			SpellButtons[i].button.cost = spell[3];
		else
			SpellButtons[i].button.cost = 2;
		end

		local name, _, texture = GetSpellInfo(spell[1])

		SpellButtons[i].button.icon:SetTexture(texture)
		SpellButtons[i].button.learned = 0;
		SpellButtons[i].button.icon:SetDesaturated(1);

		if HotCSpells[class] ~= nil and HotCSpells[class][spec] ~= nil then
			if tContains(HotCSpells[class][spec], spell[1]) then
				SpellButtons[i].button.learned = 1;
				SpellButtons[i].button.icon:SetDesaturated(0);
			end
		end
		
		SpellButtons[i].button.link = tonumber(spell[1])
		SpellButtons[i].button.level = spell[2]

		SpellButtons[i].button.costText = "AE: "..SpellButtons[i].button.cost.." TE: 0"

		if UnitLevel("player") < SpellButtons[i].button.level then
			SpellButtons[i].button.level = "|cffff0000"..SpellButtons[i].button.level;
		else
			SpellButtons[i].button.level = "|cffFFFFFF"..SpellButtons[i].button.level;
		end

		SpellButtons[i].text.text:SetText(name)

		SpellButtons[i]:Show();
	end
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

		TalentButtons[talent_loc].cost = 0
		if maxRank == 1 then
			TalentButtons[talent_loc].cost = 2;
		end

		TalentButtons[talent_loc].curRank = 0;
		TalentButtons[talent_loc].loc = nil;

		if HotCTalents[class] ~= nil and HotCTalents[class][spec] ~= nil  then
			for n = 1, #HotCTalents[class][spec] do
				if HotCTalents[class][spec][n][1] == talent[3][1] then
					TalentButtons[talent_loc].loc = n;
					TalentButtons[talent_loc].curRank = HotCTalents[class][spec][n][2]
				end
			end	
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
		
		TalentButtons[talent_loc].costText = "AE: "..TalentButtons[talent_loc].cost.." TE: 1"

		if UnitLevel("player") < TalentButtons[talent_loc].level then
			TalentButtons[talent_loc].level = "|cffff0000"..TalentButtons[talent_loc].level;
		else
			TalentButtons[talent_loc].level = "|cffFFFFFF"..TalentButtons[talent_loc].level;
		end
		 
		TalentButtons[talent_loc]:Show()
	end
end

function UpdateTalentButton(button, arg)
	if arg == "LeftButton" and (HotCTalents.total + 1 < 52) and (HotCSpells.total + button.cost < 61) then
		if (button.curRank + 1 <= button.maxRank) then
			HotCTalents.total = HotCTalents.total + 1;
			HotCSpells.total = HotCSpells.total + button.cost;
			TalentPointsText:SetText(HotCTalents.total.."/51");
			AbilityPointsText:SetText(HotCSpells.total.."/60");
			button.curRank = math.min(button.curRank + 1, button.maxRank)
		else
			return
		end
	elseif arg == "RightButton" then
		if not (button.curRank - 1 < 0) then
			HotCTalents.total = HotCTalents.total - 1
			HotCSpells.total = HotCSpells.total - button.cost;
			TalentPointsText:SetText(HotCTalents.total.."/51");
			AbilityPointsText:SetText(HotCSpells.total.."/60");
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

		if(HotCTalents[button.class] == nil) then HotCTalents[button.class] = {} end;
		if(HotCTalents[button.class][button.spec] == nil) then HotCTalents[button.class][button.spec] = {} end
		
		if button.curRank == 0 then
			table.remove(HotCTalents[button.class][button.spec], button.loc)
			button.loc = nil;
		elseif button.loc ~= nil then
			HotCTalents[button.class][button.spec][button.loc][2] = button.curRank
		else
			table.insert( HotCTalents[button.class][button.spec], {button.ranks[1], button.curRank, button.ranks})
			button.loc = #HotCTalents[button.class][button.spec]
		end
		
		HotCTooltip:Hide();
		HotCTooltip:SetOwner(button, "ANCHOR_RIGHT");
		HotCTooltip:SetHyperlink("spell:"..button.link);
		HotCTooltip:AddLine(" ");
		HotCTooltip:AddLine(button.costText);
		HotCTooltip:AddLine("Requires Level: "..button.level);
		HotCTooltip:Show();
	end
end

function UpdateSpellButton(button, arg)
	if arg == "LeftButton" and (HotCSpells.total + button.cost < 61) then
		if (button.learned == 0) then
			HotCSpells.total = HotCSpells.total + button.cost;
			AbilityPointsText:SetText(HotCSpells.total.."/60");
			button.learned = 1;
		else
			return
		end
	elseif arg == "RightButton" then
		if (button.learned == 1) then
			HotCSpells.total = math.max(HotCSpells.total - button.cost, 0)
			AbilityPointsText:SetText(HotCSpells.total.."/60");
			button.learned = 0;
		else
			return
		end 
	end

	if (arg == "LeftButton") or (arg == "RightButton") then
		if(HotCSpells[button.class] == nil) then HotCSpells[button.class] = {} end;
		if(HotCSpells[button.class][button.spec] == nil) then HotCSpells[button.class][button.spec] = {} end
			
		if button.learned == 0 then
			button.icon:SetDesaturated(1);
		else
			button.icon:SetDesaturated(0);
		end

		if button.learned == 0 then
			if (tContains(HotCSpells[button.class][button.spec], tonumber(button.link))) then
				table.remove(HotCSpells[button.class][button.spec], tonumber(button.link))
				print("Removed: "..button:GetParent().text.text:GetText())
			end
		else
			table.insert(HotCSpells[button.class][button.spec], button.link)
		end
		
		HotCTooltip:Hide();
		HotCTooltip:SetOwner(button, "ANCHOR_RIGHT");
		HotCTooltip:SetHyperlink("spell:"..button.link);
		HotCTooltip:AddLine(" ");
		HotCTooltip:AddLine(button.costText);
		HotCTooltip:AddLine("Requires Level: "..button.level);
		HotCTooltip:Show();
	end
end
--End Class Frame Functions

--Overview Frame Functions
function ShowBuildOverview()
	ShowSpellOverview();
	ShowTalentOverview();
end


function ShowSpellOverview()
	--Hide all Spec tabs unless we have talants in this spec
	for i = 1, 9 do
		ovSpellCats[i]:Hide();
		if i ~= 1 then
			ovSpellCats[i]:SetPoint("TOPLEFT", ovSpellCats[i-1], "BOTTOMLEFT", 0, -19);
		end
	end

	--Hide all sub-items unless we show them later
	for i = 1, 30 do
		ovSpellSubCats[i]:SetParent(_G["UIParent"]);
		ovSpellSubCats[i]:SetParent(_G[ovSpellCats[1].container:GetName()]);
		ovSpellSubCats[i]:Hide();
		if i ~= i then
			ovSpellSubCats[i]:SetPoint("TOPLEFT", ovSpellSubCats[i-1]:GetName(), "BOTTOMLEFT", 0, -1);
		else
			ovSpellSubCats[i]:SetPoint("TOPLEFT", ovSpellCats[1].container, "TOPLEFT")
		end
	end

	local spell_count = 0;
	local cat_count = {};
	for i = 1, 9 do
		if HotCSpells[SpecTable[i][1]] ~= nil then
			local spell_count_class = 0;
			for n = 1, 3 do
				if HotCSpells[SpecTable[i][1]][SpecTable[i][2][n]] ~= nil then
					local spells = HotCSpells[SpecTable[i][1]][SpecTable[i][2][n]];
					for s = 1, #spells do
						spell_count = spell_count + 1;
						spell_count_class = spell_count_class + 1;
						--Set Local Variables
						local name, _, texture = GetSpellInfo(spells[s])
						--Set Location
						ovSpellSubCats[spell_count]:SetParent(_G[ovSpellCats[i].container:GetName()]);
						if s == 1 and spell_count_class == 1 then
							ovSpellSubCats[spell_count]:SetPoint("TOPLEFT", ovSpellCats[i].container, "TOPLEFT")
						else
							ovSpellSubCats[spell_count]:SetPoint("TOPLEFT", ovSpellSubCats[spell_count - 1]:GetName(), "BOTTOMLEFT", 0, -1);
						end
						--Set Visuals
						ovSpellSubCats[spell_count].icon:SetTexture(texture)
						ovSpellSubCats[spell_count].name:SetText(name)
						if (s % 2 == 0) then
							ovSpellSubCats[spell_count].bg:Hide();
						else
							ovSpellSubCats[spell_count].bg:Show();
						end
						--Set Function arguments
						ovSpellSubCats[spell_count].class = SpecTable[i][1];
						ovSpellSubCats[spell_count].spec = SpecTable[i][2][n];
						--Finally show the element
						ovSpellSubCats[spell_count]:Show()
						
					end
				end
			end
			if spell_count_class > 0 then
				ovSpellCats[i]:Show();
				ovSpellCats[i].button.subElements = spell_count_class;
				HotC_Expander(ovSpellCats[i].button, true);
				table.insert(cat_count, ovSpellCats[i]:GetName())
			end
		end
	end
	for i = 1, #cat_count do
		if i == 1 then
			_G[cat_count[i]]:SetPoint("TOPLEFT", _G[cat_count[i]]:GetParent(), "TOPLEFT", 0, -4)
		else
			_G[cat_count[i]]:SetPoint("TOPLEFT", _G[cat_count[i-1]], "BOTTOMLEFT", 0, -4)
		end
	end
end

function ShowTalentOverview()
	
	--Hide all Spec tabs unless we have talants in this spec
	for i = 1, 9 do
		ovTalentCats[i]:Hide();
		if i ~= 1 then
			ovTalentCats[i]:SetPoint("TOPLEFT", ovTalentCats[i-1], "BOTTOMLEFT", 0, -19);
		end
	end

	--Hide all sub-items unless we show them later
	for i = 1, 51 do
		ovTalentSubCats[i]:SetParent(_G["UIParent"]);
		ovTalentSubCats[i]:SetParent(_G[ovTalentCats[1].container:GetName()]);
		ovTalentSubCats[i]:Hide();
		if i ~= i then
			ovTalentSubCats[i]:SetPoint("TOPLEFT", ovTalentSubCats[i-1]:GetName(), "BOTTOMLEFT", 0, -1);
		else
			ovTalentSubCats[i]:SetPoint("TOPLEFT", ovTalentCats[1].container, "TOPLEFT")
		end
	end

	local spell_count = 0;
	local cat_count = {};
	for i = 1, 9 do
		local _c = SpecTable[i][1]
		if HotCTalents[_c] ~= nil then
			local spell_count_class = 0;
			for n = 1, 3 do
				local _s = SpecTable[i][2][n]
				if HotCTalents[_c][_s] ~= nil then
					for s = 1, #HotCTalents[_c][_s] do
						if HotCTalents[_c][_s][s] ~= nil then
							spell_count = spell_count + 1;
							spell_count_class = spell_count_class + 1;
							--Set Local Variables
							local talent = HotCTalents[_c][_s][s]
							local container = ovTalentCats[i].container
							local name, _, texture = GetSpellInfo(talent[1])
							--Set Location
							ovTalentSubCats[spell_count]:SetParent(_G[container:GetName()]);
							if spell_count_class == 1 and s == 1 then
								ovTalentSubCats[spell_count]:SetPoint("TOPLEFT", _G[container:GetName()], "TOPLEFT")
							else
								ovTalentSubCats[spell_count]:SetPoint("TOPLEFT", ovTalentSubCats[spell_count - 1]:GetName(), "BOTTOMLEFT", 0, -1);
							end
							--Set Visuals
							ovTalentSubCats[spell_count].icon:SetTexture(texture)
							ovTalentSubCats[spell_count].name:SetText(name)
							ovTalentSubCats[spell_count].rank:SetText(talent[2].."/"..#talent[3]);
							if (s % 2 == 0) then
								ovTalentSubCats[spell_count].bg:Hide();
							else
								ovTalentSubCats[spell_count].bg:Show();
							end
							--Set function arguments
							ovTalentSubCats[spell_count].class = SpecTable[i][1];
							ovTalentSubCats[spell_count].spec = SpecTable[i][2][n];
							--Finally Show element
							ovTalentSubCats[spell_count]:Show()
							
						end
					end
				end
			end

			if spell_count_class > 0 then
				ovTalentCats[i]:Show();
				ovTalentCats[i].button.subElements = spell_count_class;
				HotC_Expander(ovTalentCats[i].button, true);
				table.insert(cat_count, ovTalentCats[i]:GetName())
			end
		end
	end

	for i = 1, #cat_count do
		if i == 1 then
			_G[cat_count[i]]:SetPoint("TOPLEFT", _G[cat_count[i]]:GetParent(), "TOPLEFT", 0, -4)
		else
			_G[cat_count[i]]:SetPoint("TOPLEFT", _G[cat_count[i-1]], "BOTTOMLEFT", 0, -4)
		end
	end
end



function ResetBuild()
	HotCSpells = {
		total = 0
	};
	HotCTalents = {
		CLASS = 1,
		SPEC = 2,
		ROW = 3,
		COL = 4,
		POINTS = 5,
		total = 0
	};

	TalentPointsText:SetText(HotCTalents.total.."/51");
	AbilityPointsText:SetText(HotCSpells.total.."/60");

	ShowSpellsForSpec("DRUID", "BALANCE");
	ShowTalentsForSpec("DRUID", "BALANCE");
	ShowBuildOverview()
end


