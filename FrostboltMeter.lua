-- Frostbolt Meter
-- 14 Mar 2020
-- Olgruff / Hateduck fun addons for fun

-- Global Saved Variables
-- Saved when logout happens
totalFrostbolts = 0

--  slash command to toggle on and off
SLASH_FROSTBOLTMETER1 = '/fbm'

-- WoW way to add things to the command list table
function SlashCmdList.FROSTBOLTMETER(msg, editbox) 
		if (msg == "reset") then
		FrostboltMeter_ResetStats()
	elseif (msg == "toggle") then
		if FrostboltMeterMain:IsVisible() then
			FrostboltMeterMain:Hide()
		else 
			FrostboltMeterMain:Show()
		end
	end
end



function FrostboltMeterMain_OnLoad()
	FrostboltMeterMain:Show()
	FrostboltMeterMain:SetScript("OnMouseDown", FrosboltMeterStartMove)
	FrostboltMeterMain:SetScript("OnMouseUp", FrostBoltMeterStopMove)
	FrostboltMeterMain:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	FrostboltMeterMain:RegisterEvent("PLAYER_ENTERING_WORLD")

	print("Loaded Frostbolt Odometer!")
end

function ResetButton_OnClick()
	if (FrostboltMeterMainResetYes:IsVisible()) then
		ResetConfirm_Hide()
	else
		ResetConfirm_Show()
	end
end

function ResetConfirm_Show()
	FrostboltMeterMainResetYes:Show()
	FrostboltMeterMainResetNo:Show()
	FrostboltMeterMainResetText:Show()
end

function ResetConfirm_Hide()
	FrostboltMeterMainResetYes:Hide()
	FrostboltMeterMainResetNo:Hide()
	FrostboltMeterMainResetText:Hide()
end

function FrostboltMeter_ResetStats()
	totalFrostbolts = 0
	FrostboltCount:SetText(string.format("%09d",totalFrostbolts))
end

function FrostboltMeter_OnEnter(self)
	FrostboltMeterMainReset:Show()
end

function FrostboltMeter_OnLeave(self)
	FrostboltMeterMainReset:Hide()
end

function FrostboltMeterMain_OnEvent(self, event, ...)
	-- print("Event: "..event)
	
	if ( event == "PLAYER_ENTERING_WORLD") then
		--print("Loading Variable: Total Frostbolts: "..totalFrostbolts)
		FrostboltCount:SetText(string.format("%09d",totalFrostbolts))
	end

	if (event == "UNIT_SPELLCAST_SUCCEEDED") then
		local arg1, arg2, arg3 = ...;
		local spellington = GetSpellInfo(arg3)
		
		-- print("SpellID: "..arg3)
		-- print("Spell Name: "..spellington)
		
		if (string.find(spellington, "Frostbolt")) then
			-- print("Yup we got a bolt: "..spellington)
			-- print(string.format("%09d", totalFrostbolts))
			totalFrostbolts = totalFrostbolts + 1
			FrostboltCount:SetText(string.format("%09d",totalFrostbolts))
		end
	end


end

---------Functions to move the window around
function FrosboltMeterStartMove()
  FrostboltMeterMain:StartMoving();
end
function FrostBoltMeterStopMove()
  FrostboltMeterMain:StopMovingOrSizing(); 
end