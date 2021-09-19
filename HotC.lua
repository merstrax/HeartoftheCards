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
};

function initDB()
	if not HotC then
		HotC = {}
	end
	
	if not HotC.builds then
		HotC.builds = {}
	end
end



function SetupTalentLayout()
	initDB()

	for i = 1, MAX_TALENTS do
		TalentButtons[i] = CreateFrame("button", "talentBtn"..i, HotC_Main_TalentFrame, "SpellButton");
		TalentButtons[i]:SetPoint("TOPLEFT", 60 + ((((i-1) + 4) % 4) * 48), -42 - (math.floor((i-1) / 4) * 42));
		TalentButtons[i]:Hide();
	end

	ShowTalentsForSpec("DRUID", "BALANCE")
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
		
		TalentButtons[talent_loc].spells = talent[3]
		TalentButtons[talent_loc].class = class
		TalentButtons[talent_loc].spec = spec
		TalentButtons[talent_loc].link = talent[3][1]
		TalentButtons[talent_loc].level = (talent[1] * 5) + 5
		TalentButtons[talent_loc].icon:SetTexture(texture)

		if UnitLevel("player") < TalentButtons[talent_loc].level then
			TalentButtons[talent_loc].level = "|cffff0000"..TalentButtons[talent_loc].level;
		else
			TalentButtons[talent_loc].level = "|cffFFFFFF"..TalentButtons[talent_loc].level;
		end
		 
		TalentButtons[talent_loc]:Show()
	end
end

function ShowBuildOverview()
	
end

function ActivateSpellsForSpec()

end

function ActivateTalentsForSpec()

end

function ResetTalentButton(button)
	button.spells = nil
	button.talentTableVar = nil
	button.class = nil
	button.spec = nil
	button.points = 0
	
	button:Hide()
end

function AddSpellToBuild()

end

function AddTalentToBuild(button)
	--if not button.talentTableVar then
		--Talents[button.talentTableVar]

end

SetupTalentLayout()