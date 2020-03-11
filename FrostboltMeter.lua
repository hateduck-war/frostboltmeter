-- Frostbolt Meter
-- 7 Mar 2020
-- Olgruff / Hateduck fun addons for fun

totalFrostbolts = 0

function FrostboltMeterMain_OnLoad()
	FrostboltMeterMain:Show()
	FrostboltMeterMain:SetScript("OnMouseDown", FrosboltMeterStartMove)
	FrostboltMeterMain:SetScript("OnMouseUp", FrostBoltMeterStopMove)
	FrostboltMeterMain:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	FrostboltMeterMain:RegisterEvent("PLAYER_ENTERING_WORLD")

	print("Loaded Frostbolt Odometer!")
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





