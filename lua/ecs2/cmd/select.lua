
----
-- These commands add or remove entities from your ECS selection.

ECS.SavedSelections = ECS.SavedSelections or { }

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

----
-- Saves your current selection for later use. Does not persist through sessions.
-- @function e_selectsave
-- @param name The name to use for your saved selection.
-- @param boolean If true, the selection will be added to the save, instead of overwriting it.
ECS.NewCommand( "e_selectsave", 2, function( ply, args ) 
	if not args[1] then return end

	if ECS.GetSelectionCount( ply ) > 0 then
		ECS.SavedSelections[ ply ] = ECS.SavedSelections[ ply ] or { }

		local name = args[1]
		if args[2] then
			ECS.SavedSelections[ ply ][ name ] = ECS.SavedSelections[ ply ][ name ] or { }
			table.Merge( ECS.SavedSelections[ ply ][ name ], ECS.GetSelection( ply ) )
		else
			ECS.SavedSelections[ ply ][ name ] = table.Copy( ECS.GetSelection( ply ) )
		end
	end	
end )

----
-- Loads given saved selection.
-- @function e_selectload
-- @param name The name to use for your saved selection.
-- @param boolean boolean If true, the save will be added to your current selection, instead of overwriting it.
ECS.NewCommand( "e_selectload", 2, function( ply, args ) 
	if not args[1] then return end
	if not ECS.SavedSelections[ ply ] then return end
	if not ECS.SavedSelections[ ply ][ args[1] ] then return end

	if not args[2] then ECS.RemoveAll( ply ) end
	
	local name = args[1]
	ECS.Selections[ ply ] = ECS.Selections[ ply ] or { }

	for ent, info in pairs( ECS.SavedSelections[ ply ][ name ] ) do
		if not IsValid( ent ) then
			ECS.SavedSelections[ ply ][ name ][ ent ] = nil
			continue
		end

		ECS.Selections[ ply ][ ent ] = info		
		ent:SetRenderMode( 4 )
		ent:SetColor( ECS.SelectColor )
	end
end )

