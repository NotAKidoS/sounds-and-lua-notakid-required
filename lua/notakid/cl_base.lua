--[[
	Set airboat sitting sequence for vehicles like bikes.
	Networks a variable that is checked in a hook.
]]--
net.Receive("nak_setclientanims", function()--Sets animation variable so the client can get it below
	local ent = net.ReadEntity()
	ent.NAKAnim = 1
end)

--Hood & Trunk toggles based on camera angles
--[[
concommand.Add("simf_nak_hoodandtrunk", function(ply)
	local pod = ply:GetVehicle()
	local ent = ply:GetSimfphys()
	if !IsValid(ent) then return end
	
	get players camera angles from vehicles angles
	local EyeAngles = ent:WorldToLocalAngles( ply:EyeAngles() )
	if not pod:GetThirdPersonMode() then
		firstperson flip
		Hood = EyeAngles.y > -25 and EyeAngles.y < 25 
		Trunk = EyeAngles.y < -155 or EyeAngles.y > 155 
	else
		if camera Y angle is smaller than -155 (-155,-156,-157...) OR if its bigger than 155 (155,156,157...) then activate hood
		Hood = EyeAngles.y < -155 or EyeAngles.y > 155 
		if camera Y ang is bigger than -25 (-25,-24,-23...) AND smaller than 25 (25,24,23...) then activate trunk
		Trunk = EyeAngles.y > -25 and EyeAngles.y < 25 
	end

	if Hood then
		ent:SetNAKHood( math.abs(1 - ent:GetNAKHood()) )
	else
		ent:SetNAKTrunk( math.abs(1 - ent:GetNAKTrunk()) )
	end
end)
]]

--Broken/WIP GTAV vehicle weapon select code
--[[
local mortarSelect = Material( "icons/rearmortar.png" ) -- Calling Material() every frame is quite expensive
local minigunSelect = Material( "icons/duelminigun.png" ) 
local frontmisslesSelect = Material( "icons/frontmissiles.png" ) 
local weaponSelect = 1
local function WeaponSelectFunc()
		
		weaponSelect = weaponSelect+1
		if weaponSelect == 2 then
			hook.Add("HUDPaint", "nak_weaponselect", function()
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( frontmisslesSelect  )
				surface.DrawTexturedRect(ScrW() / 2 - 75, ScrH() / 4-88, ScrH()/7.2, ScrH()/7.2 )
			end)
		elseif weaponSelect == 3 then
			hook.Add("HUDPaint", "nak_weaponselect", function()
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( mortarSelect  )
				surface.DrawTexturedRect(ScrW() / 2 - 75, ScrH() / 4-88, ScrH()/7.2, ScrH()/7.2 )
			end)
		elseif weaponSelect == 4 then
			weaponSelect = 1
		end
		if weaponSelect == 1 then
			hook.Add("HUDPaint", "nak_weaponselect", function()
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( minigunSelect  )
				surface.DrawTexturedRect(ScrW() / 2 - 75, ScrH() / 4-88, ScrH()/7.2, ScrH()/7.2 )
			end)
		end
		//wow hacky but works pls
		
		print(weaponSelect)
		
		
		
		timer.Create( "CLnakremoveWS", 2, 0, function()
			hook.Remove("HUDPaint", "nak_weaponselect")
		end)
		
		
	sound.PlayFile( "sound/simulated_vehicles/sfx/flasher_on.ogg", "noplay", function( station, errCode, errStr )
		if ( IsValid( station ) ) then
			station:Play()
		else
			print( "Error playing sound!", errCode, errStr )
		end
	end )
	
	return weaponSelect
end

concommand.Add( "simf_nak_weaponselect", function()
	local ply = LocalPlayer()
	local pod = ply:GetVehicle()
	if pod == NULL then return end
	if not ply:GetSimfphys() then return end
	
	local selected = WeaponSelectFunc()
	
	print(selected)

	net.Start( "net_nak_weaponselect" )
	net.WriteUInt( selected, 3 )
	net.SendToServer()
	print("dd")
end)
]]