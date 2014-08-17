
----
-- These commands add or remove entities from your ECS selection.

ECS.SavedSelections = { }

----
-- Adds your aim entity to your current selection.
-- @function e_select
-- @param all Adds all entities you own (or have rights to) to your current selection.
ECS.NewCommand( "e_select", 1, function( ply, args ) 
	if string.lower( args[1] or "" ) == "all" then
		ECS.AddEnts( ply, ents.GetAll() )
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if trace then ECS.AddEnt( ply, trace ) end
end )

----
-- Removes your aim entity from your current selection.
-- @function e_deselect
-- @param all Removes all entities from your selection.
ECS.NewCommand( "e_deselect", 1, function ( ply, args )
	if string.lower( args[1] or "" ) == "all" then
		ECS.RemoveAll( ply )
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if trace then ECS.RemoveEnt( ply, trace ) end
end )

----
-- Adds all entities within given radius of your aim position to your current selection.
-- @function e_selectsphere
-- @param radius The radius of the sphere to search for entities, originating from your aim position
ECS.NewCommand( "e_selectsphere", 1, function( ply, args )
	if tonumber( args[1] or "0" ) > 0 then
		local find = ents.FindInSphere( ply:GetEyeTrace().HitPos, tonumber( args[1] ) )
		ECS.AddEnts( ply, find or { } )
	end
end )

----
-- Removes all entities within given radius of your aim position from your current selection.
-- @function e_deselectsphere
-- @param radius The radius of the sphere to search for entities, originating from your aim position
ECS.NewCommand( "e_deselectsphere", 1, function( ply, args )
	if tonumber( args[1] or "0" ) > 0 then
		local find = ents.FindInSphere( ply:GetEyeTrace().HitPos, tonumber( args[1] ) )
		ECS.RemoveEnts( ply, find or { } )
	end
end )
