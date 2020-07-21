NAK = istable( NAK ) and NAK or {}
if SERVER then
	include("notakid/sv_base.lua")--Base functions
	AddCSLuaFile("notakid/cl_base.lua")
	include("notakid/extra.lua")--Extra functions
else
	include("notakid/cl_base.lua")--Base functions (client)
end

--//hook to set players sequence (has to be on server and client)
hook.Add("CalcMainActivity", "simfphysSeatActivityOverridePatch", function(ply)
	if not IsValid( ply:GetSimfphys() ) then return end

	local IsDriverSeat = ply:IsDrivingSimfphys()
	if !IsDriverSeat then return end
	if !ply:GetSimfphys().NAKAnim then return end
	
	ply.CalcIdeal = ACT_HL2MP_SIT
	ply.CalcSeqOverride = IsDriverSeat and ply:LookupSequence( "drive_airboat" ) or -1

	return ply.CalcIdeal, ply.CalcSeqOverride
end)
--//Shared !!
--[[
Adaptation of the gtasa hitbox code, but just for exploding trailers!
]]
local function TankerDamage(ent, DmgPos, Damage)
    for k, v in pairs( ent.NAKTankerHB ) do
        if DmgPos:WithinAABox( v.OBBMin, v.OBBMax) then
			ent:TakeDamage(Damage*10)
			if vFireInstalled then
				CreateVFire(ent, ent:LocalToWorld(DmgPos), DmgPos:GetNormalized(), 15)
			end
		end
	end
end
--
function NAK.TankerHitbox( self )
	--Bullet Damage
    self.NAKOnTakeDamage = self.OnTakeDamage
    self.OnTakeDamage = function(self, dmginfo) 
        local Damage = dmginfo:GetDamage()
        local DamagePos = self:WorldToLocal(dmginfo:GetDamagePosition())
        local Explosion = dmginfo:IsExplosionDamage()
        TankerDamage(self, DamagePos, Damage)
        self:NAKOnTakeDamage(dmginfo)
    end
	--Physics Damage
    self.NAKHBPhysicsCollide = self.PhysicsCollide
    self.PhysicsCollide = function(self, data, physobj)
        if (not data.HitEntity:IsNPC()) and (not data.HitEntity:IsNextBot()) and
            (not data.HitEntity:IsPlayer()) then
            if (data.DeltaTime > 0.2) then
				local spd = data.Speed + data.OurOldVelocity:Length() + data.TheirOldVelocity:Length()
				local dmgmult = math.Round(spd / 30, 0)
				local damagePos = self:WorldToLocal(data.HitPos)
                TankerDamage(self, damagePos, dmgmult)
            end
        end
        self:NAKHBPhysicsCollide(data, physobj)
    end
	
	--//need to code a timer or something that slowly lets out fuel, and base how much fuel is left on the explosion size!
	self.OnDestroyed = function(self) 
		if !self.destroyed then return end
		CreateVFireBall(300, 100, self:GetPos()+Vector(0,0,200), Vector(0, 100, 25), nil)
		CreateVFireBall(300, 100, self:GetPos()+Vector(0,0,200), Vector(0, -100,25), nil)
		CreateVFireBall(300, 100, self:GetPos()+Vector(0,0,200), Vector(100, 0, 25), nil)
		CreateVFireBall(300, 100, self:GetPos()+Vector(0,0,200), Vector(-100, 0,25), nil)
	end
end