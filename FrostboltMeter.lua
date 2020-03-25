-- Frostbolt Meter
-- 14 Mar 2020
-- Olgruff / Hateduck fun addons for fun

-- Global Saved Variables
-- Saved when logout happens
-- actual 4031
totalFrostbolts = 0
zeroPadString = "%09d"

-- Table to hold Achiement Nums

frostyAchieveNums = {100, 500, 1000, 2000, 4000, 8000}

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



function FrostboltMeterMain_OnLoad(self)
	-- FrostboltMeterMain:Show()
	FrostboltMeterMain:SetScript("OnMouseDown", FrosboltMeterStartMove)
	FrostboltMeterMain:SetScript("OnMouseUp", FrostBoltMeterStopMove)
	FrostboltMeterMainAchievement:SetScript("OnMouseDown", FrosboltMeterStartMove)
	FrostboltMeterMainAchievement:SetScript("OnMouseUp", FrostBoltMeterStopMove)
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

function ZeroPadButton_OnClick()
	if (FrostboltMeterMainZeroPadYes:IsVisible()) then
		ZeroPadConfirm_Hide()
	else
		ZeroPadConfirm_Show()
	end
end


function ZeroPadConfirm_Show()
	FrostboltMeterMainZeroPadYes:Show()
	FrostboltMeterMainZeroPadNo:Show()
	FrostboltMeterMainZeroPadText:Show()
end

function ZeroPadConfirm_Hide()
	FrostboltMeterMainZeroPadYes:Hide()
	FrostboltMeterMainZeroPadNo:Hide()
	FrostboltMeterMainZeroPadText:Hide()
end

function FrostboltMeter_ResetStats()
	totalFrostbolts = 0
	FrostboltCount:SetText(string.format(zeroPadString,totalFrostbolts))
end

-- Turn on zero padding if not enabled
-- (adds extra zeros to the left)
function ZeroPadEnable()
	if (zeroPadString ~= "%09d") then
		zeroPadString = "%09d"
	end
	FrostboltCount:SetText(string.format(zeroPadString,totalFrostbolts))
end

-- Turn off zero padding 
function ZeroPadDisable()
	if (zeroPadString == "%09d") then
		zeroPadString = "%d"
	end
	FrostboltCount:SetText(string.format(zeroPadString,totalFrostbolts))
end


function FrostboltMeter_OnEnter(self)
	FrostboltMeterMainReset:Show()
	FrostboltMeterMainZeroPad:Show()
end

function FrostboltMeter_OnLeave(self)
	FrostboltMeterMainReset:Hide()
	FrostboltMeterMainZeroPad:Hide()
end

function FrostboltMeterMain_OnEvent(self, event, ...)
	-- print("Event: "..event)
	
	if ( event == "PLAYER_ENTERING_WORLD") then
		--print("Loading Variable: Total Frostbolts: "..totalFrostbolts)
		FrostboltCount:SetText(string.format(zeroPadString,totalFrostbolts))
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
			FrostboltCount:SetText(string.format(zeroPadString,totalFrostbolts))

			for i,value in pairs(frostyAchieveNums) do
				print("bolts: "..totalFrostbolts.." table: "..value)
				if (value == totalFrostbolts) then
					fire_achievement(totalFrostbolts)
				end
			end
		end
	end
end

function fire_achievement(num_bolts)
	AchieveTitleString:SetText(num_bolts.." Frostbolts!")
	AchieveText:SetText(frostyAchieveText[num_bolts])
	FrostboltMeterMainAchievement:Show()
	PlaySoundFile("Interface\\AddOns\\FrostboltMeter\\sounds\\fbm_boom_crash_thunder.ogg", "Master")
end

---------Functions to move the window around
function FrosboltMeterStartMove(self)
  self:StartMoving();
end
function FrostBoltMeterStopMove(self)
  self:StopMovingOrSizing(); 
end
--FrostboltMeterMain