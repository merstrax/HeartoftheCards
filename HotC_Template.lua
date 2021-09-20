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