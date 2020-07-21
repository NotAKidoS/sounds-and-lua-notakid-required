return {
    Connect = function(ventity)
        if ventity.connection and IsValid(ventity.connection.ent) then
            local trailer = ventity.connection.ent
			if trailer.TrailerStandNAK then
				trailer:TrailerStandNAK(true)
			end
        end
    end,
    Disconnect = function(ventity)
        if ventity.connection and IsValid(ventity.connection.ent) then
            local trailer = ventity.connection.ent
			if trailer.TrailerStandNAK then
				trailer:TrailerStandNAK(false)
			end
        end
    end
}
