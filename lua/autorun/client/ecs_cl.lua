
AddCSLuaFile()

local NOHELP = "There is no help for this command!"

local function PrintHelp( name, argCount, help )
	MsgC( 
		Color(125, 175, 255), "ECS: \n    ",
		Color(200, 225, 255), "Command: " .. name .. "\n    Arguments: " .. argCount .. "\n    Help: " .. help .. "\n"
	)
end

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
