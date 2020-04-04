-- Frostbolt Meter
-- 14 Mar 2020 Original Commit
-- 04 APR 2020
-- Olgruff / Hateduck fun addons for fun

-- Olgruff actual bolts 7673
-- Lvl 31

-- Global Saved Variables
-- Saved when logout happens
totalFrostbolts = 0
zeroPadString = "%09d"
achievePopUpEnable = true
preferredFont = "NumberFontNormalLarge"
totalFrostyCrits = 0
totalFrostyDmg = 0
totalPartialResist = 0

-- Table to hold Achiement Nums
frostyAchieveNums = {1000, 2000, 4000, 8000, 16000, 32000}

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

	-- Make these windows movable with a mouse drag
	FrostboltMeterMain:SetScript("OnMouseDown", FrosboltMeterStartMove)
	FrostboltMeterMain:SetScript("OnMouseUp", FrostBoltMeterStopMove)
	FrostboltMeterMainAchievement:SetScript("OnMouseDown", FrosboltMeterStartMove)
	FrostboltMeterMainAchievement:SetScript("OnMouseUp", FrostBoltMeterStopMove)
	FrostboltMeterMainConfigure:SetScript("OnMouseDown", FrosboltMeterStartMove)
	FrostboltMeterMainConfigure:SetScript("OnMouseUp", FrostBoltMeterStopMove)

	--Register Events
	FrostboltMeterMain:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	FrostboltMeterMain:RegisterEvent("PLAYER_ENTERING_WORLD")
	FrostboltMeterMain:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	print("Loaded Frostbolt Odometer!")
end

function FrostboltMeterConfigure_OnLoad(self)
	if (totalFrostbolts >= 1000) then
		FrostboltMeterMainConfigureAchievement1000:Show()
		FrostboltMeterMainConfigureAchievement1000Locked:Hide()
	else
		FrostboltMeterMainConfigureAchievement1000Locked:Show()
		FrostboltMeterMainConfigureAchievement1000:Hide()
	end
end
--====================================================================================
--		OnClick Handlers for the Buttons in FrostboltMeter.xml
--====================================================================================
function ConfigButton_OnClick()
	if (FrostboltMeterMainConfigure:IsVisible()) then
		FrostboltMeterMainConfigure:Hide()
	else
		FrostboltMeterMainConfigure:Show()
	end
end

function ResetButton_OnClick()
	if (FrostboltMeterMainConfigureResetYes:IsVisible()) then
		FrostboltMeterMainConfigureResetYes:Hide()
		FrostboltMeterMainConfigureResetNo:Hide()
	else
		FrostboltMeterMainConfigureResetYes:Show()
		FrostboltMeterMainConfigureResetNo:Show()		
	end
end

-- Turn on zero padding if not enabled
-- (adds extra zeros to the left)
function ZeroPadButton_OnClick()
	if (zeroPadString ~= "%09d") then
		-- Put 9 zeros in front of #
		zeroPadString = "%09d"
	else
		zeroPadString = "%d"
	end
	FrostboltCount:SetText(string.format(zeroPadString,totalFrostbolts))
end

function ToggleAchieves_OnClick()
	if (achievePopUpEnable == true) then
		achievePopUpEnable = false
		FrostboltMeterMainConfigureToggleAchievesHeader:SetText("Toggle Achievement Popups: Disabled")
	else
		achievePopUpEnable = true
		FrostboltMeterMainConfigureToggleAchievesHeader:SetText("Toggle Achievement Popups: Enabled")
	end
end

function FrostboltMeter_ResetStats()
	totalFrostbolts = 0
	FrostboltCount:SetText(string.format(zeroPadString,totalFrostbolts))
end

function SetMeterFont(fontName)
	FrostboltCount:SetFontObject(fontName)
	preferredFont = fontName
end

--Event Handler
--Entry point to handle all events registered for in OnLoad func
function FrostboltMeterMain_OnEvent(self, event, ...)
	-- print("Event: "..event)

	-- Make sure saved variables and preferences are loaded
	if ( event == "PLAYER_ENTERING_WORLD") then
		--Configure from Saved Variables
		SetMeterFont(preferredFont)
		if (achievePopUpEnable == true) then
			FrostboltMeterMainConfigureToggleAchievesHeader:SetText("Toggle Achievement Popups: Enabled")
		else
			FrostboltMeterMainConfigureToggleAchievesHeader:SetText("Toggle Achievement Popups: Disabled")
		end
			FrostboltCount:SetText(string.format(zeroPadString,totalFrostbolts))
		end

	-- Parse Combat Events
	-- This is literally everything from the combat logging
	-- So we have to parse a bit to get to the info we want
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		-- Get 12 baseline payload values
		-- Only really need sourceName and eventType to get to next block
		local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, 
			  destGUID, destName, destFlags, destFlags2 = CombatLogGetCurrentEventInfo()
		
		-- Only care about our own spells, not NPC or other players
		if (sourceName == UnitName("player")) then
			-- If it was succesful spell cast event (cast bar finished)
			if (eventType == "SPELL_CAST_SUCCESS") then
				local  _,_,_,_,_,_,_,_,_,_,_, spellID, spellName, magSchool = CombatLogGetCurrentEventInfo()
				print(spellName)

				-- If the spell was a frost bolt
				if (string.find(spellName, "Frostbolt")) then
					-- Increment Frostbolts. Set text on frame
					totalFrostbolts = totalFrostbolts + 1
					FrostboltCount:SetText(string.format(zeroPadString,totalFrostbolts))
					-- Check table of achieves in case one needs firing
					for i,value in pairs(frostyAchieveNums) do
						if (value == totalFrostbolts) then
							fire_achievement(totalFrostbolts)
						end
					end
				end

			-- If the spell landed, or partial resisted, or was absorbed
			elseif (eventType == "SPELL_DAMAGE") then
				print("spell dmg codeblock")
				local  _,_,_,_,_,_,_,_,_,_,_, spellID, spellName, magSchool, amount, overkill, schoolAgain, 
					   wasResisted, wasBlocked, wasAbsorbed, wasCrit = CombatLogGetCurrentEventInfo()
				if (string.find(spellName, "Frostbolt") and wasCrit == true) then
					print("Frostbolt Crit!")
					-- Do stuff
				end
			-- Full Resist
			elseif (eventType == "SPELL_MISSED") then
				-- Save the miss
				print("Full Resist")
			end
		end 
		
	end
end

function fire_achievement(numBolts)
	if (achievePopUpEnable == true) then
		AchieveTitleString:SetText(numBolts.." Frostbolts!")
		AchieveText:SetText(frostyAchieveText[numBolts])
		FrostboltMeterMainAchievement:Show()
		PlaySoundFile("Interface\\AddOns\\FrostboltMeter\\sounds\\fbm_boom_crash_thunder.ogg", "Master")
	end
end

--====================================================================================
--		Functions for Window Manipulation
--====================================================================================
function FrosboltMeterStartMove(self)
  self:StartMoving();
end
function FrostBoltMeterStopMove(self)
  self:StopMovingOrSizing(); 
end

function FrostboltMeter_OnEnter(self)
	FrostboltMeterMainConfigButton:Show()
end

function FrostboltMeter_OnLeave(self)
	FrostboltMeterMainConfigButton:Hide()
end