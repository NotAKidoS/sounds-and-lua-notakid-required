--//THIS CODE IS FOR AN ENTITY, SO WHEN IT TOUCHES CAR IT WILL MAKE THE HORN CHANGE PITCH BASED ON CLAMPED RPM!
--//Its implementation is really really really bad and will break things really bad. I accidently left it in here when uploading to github.

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

local function SetPowerUpFunc(ent) 
		
		ent.Think = function(self)
			
			local Time = CurTime()
			local self = ent
			local forward = self:EyeAngles():Forward()
			local selfphys = self:GetPhysicsObject()
			
			if self.horn then
				local speed = self:GetVelocity():Length()
				local mph = math.Round(speed * 0.0568182,0)
				self.horn:ChangePitch( Lerp(mph/100 - 0.2,100,120) , 0 )
			end
			
			self:OnTick()

				//--DEFAULT SIMFPHYS NEEDED CODE

				self.NextTick = self.NextTick or 0
				if self.NextTick < Time then
					self.NextTick = Time + 0.025
					
					if IsValid( self.DriverSeat ) then
						local Driver = self.DriverSeat:GetDriver()
						Driver = IsValid( self.RemoteDriver ) and self.RemoteDriver or Driver
						
						local OldDriver = self:GetDriver()
						if OldDriver ~= Driver then
							self:SetDriver( Driver )
							
							local HadDriver = IsValid( OldDriver )
							local HasDriver = IsValid( Driver )
							
							if HasDriver then
								self:SetActive( true )
								self:SetupControls( Driver )
								
								if Driver:GetInfoNum( "cl_simfphys_autostart", 1 ) > 0 then 
									self:StartEngine()
								end
								
							else
								self:UnLock()
								
								if self.ems then
									self.ems:Stop()
								end

								if self.horn then
									self.horn:Stop()
								end
								
								if self.PressedKeys then
									for k,v in pairs( self.PressedKeys ) do
										if isbool( v ) then
											self.PressedKeys[k] = false
										end
									end
								end
								
								if self.keys then
									for i = 1, table.Count( self.keys ) do
										numpad.Remove( self.keys[i] )
									end
								end
								
								if HadDriver then
									if OldDriver:GetInfoNum( "cl_simfphys_autostart", 1 ) > 0 then 
										self:StopEngine()
										self:SetActive( false )
									else
										self:ResetJoystick()
										
										if not self:EngineActive() then
											self:SetActive( false )
										end
									end
								else
									self:SetActive( false )
									self:StopEngine()
								end
							end
						end
					end
					
					if self:IsInitialized() then
						self:SetColors()
						self:SimulateVehicle( Time )
						self:ControlLighting( Time )
						self:ControlHorn()
						
						if istable( WireLib ) then
							self:UpdateWireOutputs()
						end
						
						self.NextWaterCheck = self.NextWaterCheck or 0
						if self.NextWaterCheck < Time then
							self.NextWaterCheck = Time + 0.2
							self:WaterPhysics()
						end
						
						if self:GetActive() then
							self:SetPhysics( ((math.abs(self.ForwardSpeed) < 50) and (self.Brake > 0 or self.HandBrake > 0)) )
						else
							self:SetPhysics( true )
						end
					end
				end
				
				self:NextThink( Time )
				
				return true
			end

		
		-- self:EmitSound("GTAV_BOOST_START")
end





function ENT:Initialize()
	self.Entity:SetModel("models/Items/combine_rifle_ammo01.mdl")
	-- self.Entity:SetMaterial("phoenix_storms/stripes.vmt")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
end
-- function OyFekOff( ply, ent )
-- if ent:GetClass() == "entity_simf_spikestrip" then return false end
-- end

function ENT:PhysicsCollide( data, phys )
local colidedent = data.HitEntity
	if colidedent:GetClass() == "gmod_sent_vehicle_fphysics_base" then
	    -- if ( data.Speed > 50 ) then self:EmitSound( Sound( "Flashbang.Bounce" ) ) end
		-- TakeDamage = math.random(0,200)
		if colidedent.EggplantTiresmoke then
		
			colidedent:EmitSound( "common/wpn_denyselect.wav" )
		
		return end
		
		local vPoint = self:GetPos()
		local effectdata = EffectData()
		effectdata:SetOrigin( vPoint )
		effectdata:SetEntity( colidedent )
		util.Effect( "ManhackSparks", effectdata )
		
		self:Remove()
		
		-- colidedent.EggplantTiresmoke = true
		SetPowerUpFunc(colidedent) 
		
		
	end
end

