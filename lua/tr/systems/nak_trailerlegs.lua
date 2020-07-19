return {
    Connect = function(ventity)
        if ventity.connection and IsValid(ventity.connection.ent) then
            local trailer = ventity.connection.ent
			if trailer.TrailerStandNAK then
				trailer:TrailerStandNAK(true)
			end
			print("TrailerStandNAK was TRUE")
        end
    end,
    Disconnect = function(ventity)
        if ventity.connection and IsValid(ventity.connection.ent) then
            local trailer = ventity.connection.ent
			if trailer.TrailerStandNAK then
				trailer:TrailerStandNAK(false)
			end
			print("TrailerStandNAK was FALSE")
        end
    end
}
