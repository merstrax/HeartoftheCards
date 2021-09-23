--Tab Functions
NUM_HOTCFRAME_TABS = 4;
local framenamespace = "HotCMainFrameViewFrame"
local HotCTabtable = {framenamespace.."SummaryFrame", framenamespace.."ClassFrame", framenamespace.."ClassFrame", framenamespace.."ClassFrame"};

function HotC_ExpanderSetup(button, bool)
	button.isExpanded = bool;
	button.subElements = 1;

	if (button.isExpanded) then
		button.expandIcon:SetTexCoord(0.5625, 1, 0, 0.4375);
	else
		button.expandIcon:SetTexCoord(0, 0.4375, 0, 0.4375);
	end
end

function HotC_Expander(button, bool)
	button.isExpanded = bool;

	local parent = button:GetParent();
	
	if (button.isExpanded) then
		button.expandIcon:SetTexCoord(0.5625, 1, 0, 0.4375);
		parent:SetHeight(((button.subElements+1) * 19) + 4)
		parent.container:SetHeight(((button.subElements+1) * 19) + 4)
		parent.container:Show()
	else
		button.expandIcon:SetTexCoord(0, 0.4375, 0, 0.4375);
		parent:SetHeight(17)
		parent.container:SetHeight(1)
		parent.container:Hide()
	end
end

function HotCFrame_TabSelect(tab_id)
	for i = 1, #HotCTabtable do
		_G[HotCTabtable[i]]:Hide();
	end
	
	_G[HotCTabtable[tab_id]]:Show();

end


