----
--

AddCSLuaFile()

ECS.CommandList = ECS.CommandList or { }

-- Receive and init command info from server.
net.Receive( "ECS.SendToClient", function( len )
	local name = net.ReadString()
	local argCount = net.ReadInt( 32 )

	ECS.CommandList[ name ] = {
		argCount = argCount
	}
end )

-- Print invalid command message.
function ECS.InvalidCommand()
	MsgC( Color(255, 127, 127), "Sorry, that is not a valid ECS command!\n" )
end

-- If valid command, instruct the server.
function ECS.DoCommand( ply, cmd, args )
	local name = args[1] or nil
	if not name then ECS.InvalidCommand() return end
	if not ECS.CommandList[ name ] then ECS.InvalidCommand() return end

	local sendCount = math.Min( ECS.CommandList[ name ].argCount, table.Count( args ) - 1 )
	
	net.Start( "ECS.SendToServer" )
		net.WriteString( name )
		net.WriteInt( sendCount, 32 )

		for i = 1, sendCount do
			net.WriteString( args[i + 1] )
		end
	net.SendToServer()
end

-- Autocompletion function
function ECS.DoAutoComplete( cmd, args )
	-- Fooken horriblé, need a better way to do this
	local autoc = { }
	for cmd, data in pairs ( ECS.CommandList ) do
		table.insert( autoc, "ecs " .. cmd )
	end
	table.sort( autoc )

	return autoc
end

concommand.Add( "ecs", ECS.DoCommand, ECS.DoAutoComplete )
