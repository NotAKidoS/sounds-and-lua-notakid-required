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
function NAK.TrailerLegs( ent, LPos, LPos2 )
	if true then
		ent.NAKTrProp = ents.Create("prop_physics")
		ent.NAKTrProp:SetModel("models/hunter/blocks/cube025x150x025.mdl")
		ent.NAKTrProp:SetPos( ent:LocalToWorld( LPos ) )
		ent.NAKTrProp:SetAngles( ent:GetAngles() )
		ent.NAKTrProp:Spawn()
		ent.NAKTrProp:Activate()
		ent.NAKTrProp:GetPhysicsObject():SetMass( 2000 )
		
		local hydraulic, rope, controller = constraint.Hydraulic(nil, ent, ent.NAKTrProp, 0, 0, LPos2, Vector(0,-20,0), 64, 0, 0, KEY_NONE, 1, 10000000, nil, true)

		ent.TrHydraulic = hydraulic
		ent.TrController = controller
		controller.direction = 1
	end
	
	ent.TrailerStandNAK = function(Connected)
		if IsValid(ent.TrController) then
			if Connected then
				ent:SetPoseParameter( "trailer_legs", 1 )
				ent.TrController.direction = -1
				ent.TrHydraulic:SetCollisionGroup( COLLISION_GROUP_WORLD )
			else
				ent:SetPoseParameter( "trailer_legs", 0 )
				ent.TrController.direction = 1
				ent.TrHydraulic:SetCollisionGroup( COLLISION_GROUP_NONE )
			end
		end
	end
end