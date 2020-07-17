--Global table with all functions
NAK = istable( NAK ) and NAK or {}

function NAK.NetworkAnim(ent) 
    net.Start("nak_setclientanims")
		net.WriteEntity(ent)
    net.Broadcast()
end
util.AddNetworkString( "nak_setclientanims" )