
----
-- This is a development section for players who wish to add their own commands to ECS.

ECS.Whitelist = {
	"prop_physics",
	"prop_vehicle_prisoner_pod",
	"wire",
	"acf"
}

----
-- Creates a new ECS command.
-- @function ECS.AddCommand
-- @tparam string name The name of the console command.
-- @tparam number argCount The maximum number of arguments.
-- @tparam function func The serverside function the command will execute.
function ECS.NewCommand( name, argCount, func )
	ECS.Commands[ name ] = {
		argCount = argCount,
		func = func
	}
end

----
-- Reloads ECS for all players.
-- @function ECS.Reload
-- @tparam[opt=nil] string name If a command name is given, it will only reload that command.
-- @tparam[opt=nil] player ply If a player is given, it will only reload for that player.
function ECS.Reload( name, ply )
	if name then
		if ECS.Commands[ name ] then
			net.Start( "ECS.SendToClient" )
				net.WriteString( name )
				net.WriteInt( ECS.Commands[ name ].argCount, 32 )
			if ply then net.Send( ply ) else net.Broadcast() end
		end
		return
	end

	for cmd, data in pairs( ECS.Commands ) do
		net.Start( "ECS.SendToClient" )
			net.WriteString( cmd )
			net.WriteInt( data.argCount, 32 )
		if ply then net.Send( ply ) else net.Broadcast() end
	end
end

-- Receive and execute the command from the client
net.Receive( "ECS.SendToServer", function( len, ply )
	local name = net.ReadString()
	local args = { }

	for i = 1, net.ReadInt( 32 ) do
		args[i] = net.ReadString()
	end

	ECS.Commands[ name ].func( ply, args )
end )


----
-- Checks if given entity's class is whitelisted by ECS.
-- @function ECS.Filter
-- @tparam entity ent Entity to check.
function ECS.Filter( ent )
	local entClass = ent:GetClass()

	if string.find( entClass, "hologram" ) then return false end

	for _, class in pairs( ECS.Whitelist ) do
		if string.find( entClass, class ) then return true end
	end
	return false
end

----
-- Returns the owner of the given entity.
-- @function ECS.GetOwner
-- @tparam entity ent Entity to check.
-- @return player
function ECS.GetOwner( ent )
	if CPPI then
		local ply = ent:CPPIGetOwner()
		if IsValid( ply ) then return ply end
	end
	return game.GetWorld()
end

----
-- Determines if given player has rights to given entity.
-- @function ECS.HasRights
-- @tparam player ply Player to check.
-- @tparam entity ent Entity to check.
-- @return bool
function ECS.HasRights( ply, ent )
	if not ECS.Filter( ent ) then return false end

	if CPPI then
		if ECS.GetOwner( ent ) == ply then return true end
		return false
	end
	return true
end

----
-- Returns the selection table of given player.
-- @function ECS.GetSelection
-- @tparam player ply Player to check.
-- @return player
function ECS.GetSelection( ply )
	return ECS.Selections[ ply ] or { }
end

----
-- Returns the number of entities selected by given player.
-- @function ECS.GetSelectionCount
-- @tparam player ply Player to check.
-- @return number
function ECS.GetSelectionCount( ply )
	return table.Count( ECS.GetSelection( ply ) )
end

----
-- Determines if given entity is currently selected by given player.
-- @function ECS.IsSelected
-- @tparam player ply Player to check.
-- @tparam entity ent Entity to check.
-- @return bool
function ECS.IsSelected( ply, ent )
	return ECS.GetSelection( ply )[ ent ] and true or false
end

----
-- Retrieves the player's ecs selection color.
-- @function ECS.GetPlyColor
-- @tparam player ply
-- @return color
function ECS.GetPlyColor( ply )
	return Color(
			ply:GetInfoNum( "ecs_selectioncolor_r", 255 ), 
			ply:GetInfoNum( "ecs_selectioncolor_g", 0 ), 
			ply:GetInfoNum( "ecs_selectioncolor_b", 0 ), 
			ply:GetInfoNum( "ecs_selectioncolor_a", 127 ) )
end

----
-- Adds given entity to given player's selection table. Checks for ownership and if the entity is already selected.
-- @function ECS.AddEnt
-- @tparam player ply Player to add entity to.
-- @tparam entity ent Entity to add.
function ECS.AddEnt( ply, ent, color )
	ECS.Selections[ ply ] = ECS.GetSelection( ply )

	if not ECS.HasRights( ply, ent ) then return end
	if ECS.IsSelected( ply, ent ) then return end

	ECS.Selections[ ply ][ ent ] = {
		Color = ent:GetColor(),
		Mode = ent:GetRenderMode()
	}

	ent:SetRenderMode( 4 )
	if color then ent:SetColor( color ) else ent:SetColor( ECS.GetPlyColor( ply ) ) end
end

----
-- Adds given table of entities to given player's selection table. Checks for ownership and if the entities are already selected.
-- @function ECS.AddEnts
-- @tparam player ply Player to add entities to.
-- @tparam entity ent Entity table to add.
function ECS.AddEnts( ply, entTable )
	local color = ECS.GetPlyColor( ply )
	for _, ent in pairs( entTable ) do
		ECS.AddEnt( ply, ent, color )
	end
end

----
-- Removes given entity from given player's selection table.
-- @function ECS.RemoveEnt
-- @tparam player ply Player to remove entity from.
-- @tparam entity ent Entity to remove.
function ECS.RemoveEnt( ply, ent )
	ECS.Selections[ ply ] = ECS.GetSelection( ply )

	if ECS.Selections[ ply ][ ent ] then
		ent:SetRenderMode( ECS.Selections[ ply ][ ent ].Mode )
		ent:SetColor( ECS.Selections[ ply ][ ent ].Color )

		ECS.Selections[ ply ][ ent ] = nil

		if table.Count( ECS.Selections[ ply ] ) == 0 then ECS.Selections[ ply ] = nil end
	end
end

----
-- Removes given table of entities from given player's selection table.
-- @function ECS.RemoveEnts
-- @tparam player ply Player to remove entities from.
-- @tparam entity ent Entity table to remove.
function ECS.RemoveEnts( ply, entTable )
	for _, ent in pairs( entTable ) do
		ECS.RemoveEnt( ply, ent )
	end
end

----
-- Clears given player's selection table
-- @function ECS.RemoveAll
-- @param ply Player to clear.
function ECS.RemoveAll( ply )
	for ent, info in pairs( ECS.GetSelection( ply ) ) do
		ECS.RemoveEnt( ply, ent )
	end
end

----
-- Converts argument table to a color.
-- @function ECS.GetColor
-- @tparam table args Argument table.
-- @return Color( Arg1, Arg2, Arg3 )
function ECS.GetColor( args )
	return Color( tonumber(args[1]) or 255, tonumber(args[2]) or 255, tonumber(args[3]) or 255 )
end

----
-- Converts argument table to a vector.
-- @function ECS.GetVector
-- @tparam table args Argument table.
-- @return Vector( Arg1, Arg2, Arg3 )
function ECS.GetVector( args )
	return Vector( tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0 )
end

----
-- Converts argument table to a angle.
-- @function ECS.GetAngle
-- @tparam table args Argument table.
-- @return Angle( Arg1, Arg2, Arg3 )
function ECS.GetAngle( args )
	return Angle( tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0 )
end