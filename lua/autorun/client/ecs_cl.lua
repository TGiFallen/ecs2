
AddCSLuaFile()

net.Receive( "ECS.SendToClient", function( len )
	local name = net.ReadString()
	local argCount = net.ReadInt( 32 )

	concommand.Add( name, function( ply, cmd, args )
		local count = math.min( argCount, table.Count( args ) )

		net.Start( "ECS.SendToServer" )
			net.WriteString( name )
			net.WriteInt( count, 32 )

			for i = 1, count do
				net.WriteString( args[i] )
			end
		net.SendToServer()
	end ) 
end )
