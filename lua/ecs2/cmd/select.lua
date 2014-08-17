----
-- These commands add or remove entities from your ECS selection.

----
-- Adds your aim entity to your current selection.
-- @function e_select
-- @tparam[opt=false] string all Adds all entities you own (or have rights to) to your current selection.
-- @usage e_select all // This will add all available entities to your selection.
-- @usage e_select // This will add your aim entity to your selection.
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
-- @tparam[opt=false] string all Removes all entities from your selection.
-- @usage e_deselect all // This will clear all entities from your selection.
-- @usage e_deselect // This will remove your aim entity from your selection.
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
-- @tparam number radius The radius of the sphere to search for entities, originating from your aim position
-- @usage e_selectsphere 300 // This will add all available entities within 300 units of your aim position to your current selection.
ECS.NewCommand( "e_selectsphere", 1, function( ply, args )
	if tonumber( args[1] or "0" ) > 0 then
		local find = ents.FindInSphere( ply:GetEyeTrace().HitPos, tonumber( args[1] ) )
		ECS.AddEnts( ply, find or { } )
	end
end )

----
-- Removes all entities within given radius of your aim position from your current selection.
-- @function e_deselectsphere
-- @tparam number radius The radius of the sphere to search for entities, originating from your aim position
-- @usage e_deselectsphere 300 // This will remove all entities within 300 units of your aim position from your current selection.
ECS.NewCommand( "e_deselectsphere", 1, function( ply, args )
	if tonumber( args[1] or "0" ) > 0 then
		local find = ents.FindInSphere( ply:GetEyeTrace().HitPos, tonumber( args[1] ) )
		ECS.RemoveEnts( ply, find or { } )
	end
end )

----
-- Saves your current selection for later use. Does not persist through sessions.
-- @function e_selectsave
-- @tparam string name The name to use for your saved selection.
-- @tparam[opt=false] boolean addToSave If true, the selection will be added to the save, instead of overwriting it.
-- @usage e_selectsave test 1 // This will add your current selection to the "test" save.
-- @usage e_selectsave test // This will replace the "test" save with your current selection.
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
-- @tparam string name The name to use for your saved selection.
-- @tparam[opt=false] boolean addToSelection If true, the save will be added to your current selection, instead of overwriting it.
-- @usage e_selectload test 1 // This will add the "test" save to your current selection.
-- @usage e_selectload test // This will replace your current selection with the "test" save.
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

