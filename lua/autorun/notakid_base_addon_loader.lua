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