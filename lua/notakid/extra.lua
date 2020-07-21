--//Makes tires toggle a bodygroup when popped (also changes the ghost wheels position as well as suspension height)
local function PatchWheel(self, bool)
	local BaseEnt = self:GetBaseEnt()
	if bool then
		self.dRadius = BaseEnt.NAKWheelSettings[3]
		self:EmitSound( "simulated_vehicles/sfx/tire_break.ogg" )
		if IsValid(self.GhostEnt) then
			self.GhostEnt:SetParent( nil )
			self.GhostEnt:GetPhysicsObject():EnableMotion( false )
			self.GhostEnt:SetPos( self:LocalToWorld( Vector(0,0,-self.dRadius) ) )
			self.GhostEnt:SetParent( self )
			self.GhostEnt:SetBodyGroups( BaseEnt.NAKWheelSettings[1] )
		end
		self.RollSound_Broken = CreateSound(self, "simulated_vehicles/sfx/tire_damaged.wav")
		self.Skid:Stop()
		self.Skid_Grass:Stop()
		self.Skid_Dirt:Stop()
		self.RollSound:Stop()
		self.RollSound_Grass:Stop()
		self.RollSound_Dirt:Stop()
		local Elastic = BaseEnt.Elastics[self.Index]
		if IsValid(Elastic) then
			Elastic:Fire( "SetSpringLength", BaseEnt.FrontHeight + BaseEnt.VehicleData.suspensiontravel_fl * BaseEnt.NAKWheelSettings[4] )
		end
	else
		if IsValid( self.GhostEnt ) then
			self.GhostEnt:SetParent( nil )
			self.GhostEnt:GetPhysicsObject():EnableMotion( false )
			self.GhostEnt:SetPos( self:LocalToWorld( Vector(0,0,0) ) )
			self.GhostEnt:SetParent( self )
			self.GhostEnt:SetBodyGroups( BaseEnt.NAKWheelSettings[2] )
		end
		if self.RollSound_Broken then
			self.RollSound_Broken:Stop()
		end
		if IsValid( BaseEnt ) then
			BaseEnt:SetSuspension( self.Index, bool )
		end	
	end
end
--[[
Make wheels toggle bodygroup(s), set suspension height, and fake wheel height to fix clipping
]]
function NAK.TireOverride( ent, bdgOn, bdgOff, gwPos, suspPos )
	ent.NAKWheelSettings = {bdgOn, bdgOff, gwPos, suspPos}
	for i = 1, table.Count( ent.Wheels ) do
		local Wheel = ent.Wheels[i]
		Wheel:NetworkVarNotify( "Damaged", function(entW, nwvarstring, old, new)
			if new == old then return end
			PatchWheel(entW, new)
		end)
	end
end
--[[
Select is there because some vehicles use skins. I want to keep the option to color skins with
the normal color tool like GTAV, but also not color them on spawn. Just a choice thing idk.
]]
function NAK.SpawnColor( ent, Select )
	--If proxy color is installed use it
	if Select == 0 or Select == nil then
		if ( ProxyColor ) then
			local ColorTable = {}
			for i=1,6 do
				local vect = VectorRand( 0, 255 )
				vect:Normalize()
				table.insert(ColorTable, i, vect:ToColor() )
			end
			ent:SetProxyColor( ColorTable )
		end
	end
	--else use normal coloring (allow for selecting one or other as well)
	if Select == 1 or Select == nil && ( !ProxyColor ) then
		local CoolColorTable = {
			Color(42,52,57),
			Color(244,114,9),
			Color(8,146,208),
			Color(189,22,44),
			Color(252,233,3),
			Color(184,41,40),
			Color(0,66,37),
			Color(58,50,45),
			Color(255,255,240),
			Color(116,195,101)
		}
		ent:SetColor(CoolColorTable[math.random(1,#CoolColorTable)])
	end
end
--[[
Creates an object to act as the trailer stand, because gmod is pp and has no moving collisions
]]
CreateConVar( "nak_tr_legs", 0, FCVAR_ARCHIVE, "Enables trailer legs on my trailers!", 0, 1 )
local function ToggleLegs(ent, Connected)

	--//around 12 mph~
	if ent:GetVelocity():Length() > 200 then return end

	if IsValid(ent.TrController) then
		if Connected or (!Connected && ent.TrController.dirlast == 1) then
			ent.NAKTrProp:GetPhysicsObject():SetMass( 100 )
			ent:SetPoseParameter( "trailer_legs", 100 )
			ent.TrController.direction = -1
			ent.TrController.dirlast = -1
		else
			ent.NAKTrProp:GetPhysicsObject():SetMass( 2000 )
			ent:SetPoseParameter( "trailer_legs", 0 )
			ent.TrController.direction = 1
			ent.TrController.dirlast = 1
		end
	end
end
function NAK.DisableUse(ent)
	ent.Use = nil
    for i = 1, table.Count(ent.Wheels) do 
		ent.Wheels[i].Use = nil
	end
end
function NAK.TrailerLegs( ent, LPos )
	if GetConVar( "nak_tr_legs" ):GetInt() == 0 then return end
	
	ent.NAKTrProp = ents.Create("prop_physics")
	ent.NAKTrProp:SetModel("models/hunter/blocks/cube025x150x025.mdl")
	ent.NAKTrProp:SetPos( ent:LocalToWorld( LPos ) )
	ent.NAKTrProp:SetAngles( ent:GetAngles() )
	ent.NAKTrProp:Spawn()
	ent.NAKTrProp:Activate()
	ent.NAKTrProp:GetPhysicsObject():SetMass( 2000 )
	ent.NAKTrProp:GetPhysicsObject():SetDragCoefficient( -9000 )
	
	local propOffset = LPos * Vector(0,-1,0)
	local LPos2 = LPos * Vector(1,0,1) + Vector(0,0,60)
	local debug = GetConVar( "nak_base_debug" )
	
	local hydraulic, rope, controller = constraint.Hydraulic(nil, ent, ent.NAKTrProp, 0, 0, LPos2, propOffset, 60, 0, math.abs(debug:GetInt() - 1), KEY_NONE, 1, 10000000, nil, true)
	--rope to lock the prop from going down too far
	constraint.Rope( ent, ent.NAKTrProp, 0, 0, LPos2, propOffset, 60, 0, 0, math.abs(debug:GetInt() - 1), "cable/rope", false )
	--rope to lock the prop from going up too far
	constraint.Rope( ent, ent.NAKTrProp, 0, 0, LPos2 - Vector(0,0,60), propOffset, 60, 0, 0, math.abs(debug:GetInt() - 1), "cable/cable2", false )
	--nocollide
	constraint.NoCollide( ent, ent.NAKTrProp, 0, 0	)
	--hide the prop (seems to not work with Improved Object Render)
	ent.NAKTrProp:DrawShadow( false )
	ent.NAKTrProp:SetNoDraw( debug:GetBool() )

	ent.TrHydraulic = hydraulic
	ent.TrController = controller
	ent.TrController.direction = 1
	ent.TrController.dirlast = 1

	ent.TrailerStandNAK = function(ent, Connected)
		ToggleLegs(ent, Connected)
	end

	ent.Use = function(ent, ply)
		if ply:GetActiveWeapon():GetClass() == "weapon_crowbar" then
			ToggleLegs(ent)
		end
	end

	NAK.PropRemove( ent, ent.NAKTrProp )
	-- local dblist = {
		-- "Prop Spawned:",
		-- IsValid(ent.NAKTrProp),
		-- "Hydraulic:",
		-- IsValid(ent.TrHydraulic),
		-- "Controller:",
		-- IsValid(ent.TrController), 
		-- "Function on Trailer:",
		-- ent.TrailerStandNAK,
	-- }
	-- NAK.Debug( ent, nil, "Trailer Legs Spawned!", dblist )
end
--[[
Global debug command
]]
CreateConVar( "nak_base_debug", 1, {FCVAR_NOTIFY}, "Global Debugging for my addons", 0, 1 )
function NAK.Debug( ent, Var1, Var2, Var3 )
	if GetConVar( "nak_base_debug" ):GetInt() == 1 then return end
	if Var1 then
		print(Var1)
	end
	if Var2 then
		PrintMessage( HUD_PRINTTALK, Var2 )
	end
	if Var3 then
		PrintTable(Var3)
	end
end
--[[
Function to delete props with a vehicle, sometimes I need this so I am just making it available for later
]]
function NAK.PropRemove( ent, prop )
	if !ent.NAKRemoveList then
		ent.NAKRemoveList = {}
		ent:CallOnRemove("NAKRemoveFunc", function(ent) 
			for k, v in pairs( ent.NAKRemoveList ) do
				if IsValid(k) then k:Remove() end
			end
		end)
	end
	ent.NAKRemoveList[prop] = prop
end