----
-- These commands add or remove entities from your ECS selection.

----
-- Adds your aim entity to your current selection.
-- @function select
-- @tparam[opt=false] string all Adds all entities you own (or have rights to) to your current selection.
-- @usage ecs select all // This will add all available entities to your selection.
-- @usage ecs select // This will add your aim entity to your selection.
ECS.NewCommand( "select", 1, function ( ply, args ) 
	if string.lower( args[1] or "" ) == "all" then
		ECS.AddEnts( ply, ents.GetAll() )
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if IsValid( trace ) then ECS.AddEnt( ply, trace ) end
end )

-- Removes your aim entity from your current selection.
-- @function deselect
-- @tparam[opt=nil] string all Removes all entities from your selection.
-- @usage ecs deselect all // This will clear all entities from your selection.
-- @usage ecs deselect // This will remove your aim entity from your selection.
ECS.NewCommand( "deselect", 1, function ( ply, args )
	if string.lower( args[1] or "" ) == "all" then
		ECS.RemoveAll( ply )
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if IsValid( trace ) then ECS.RemoveEnt( ply, trace ) end
end )

----
-- Adds all entities within given radius of your aim position to your current selection.
-- @function selectsphere
-- @tparam number radius The radius of the sphere to search for entities, originating from your aim position
-- @usage ecs selectsphere 300 // This will add all available entities within 300 units of your aim position to your current selection.
ECS.NewCommand( "selectsphere", 1, function ( ply, args )
	if tonumber( args[1] or "0" ) > 0 then
		local find = ents.FindInSphere( ply:GetEyeTrace().HitPos, tonumber( args[1] ) )
		ECS.AddEnts( ply, find or { } )
	end
end )

----
-- Removes all entities within given radius of your aim position from your current selection.
-- @function deselectsphere
-- @tparam number radius The radius of the sphere to search for entities, originating from your aim position
-- @usage ecs deselectsphere 300 // This will remove all entities within 300 units of your aim position from your current selection.
ECS.NewCommand( "deselectsphere", 1, function ( ply, args )
	if tonumber( args[1] or "0" ) > 0 then
		local find = ents.FindInSphere( ply:GetEyeTrace().HitPos, tonumber( args[1] ) )
		ECS.RemoveEnts( ply, find or { } )
	end
end )

----
-- Saves your current selection for later use. Does not persist through sessions.
-- @function selectsave
-- @tparam string name The name to use for your saved selection.
-- @tparam[opt=false] boolean addToSave If true, the selection will be added to the save, instead of overwriting it.
-- @usage ecs selectsave test 1 // This will add your current selection to the "test" save.
-- @usage ecs selectsave test // This will replace the "test" save with your current selection.
ECS.NewCommand( "selectsave", 2, function ( ply, args ) 
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
-- @function selectload
-- @tparam string name The name to use for your saved selection.
-- @tparam[opt=false] boolean addToSelection If true, the save will be added to your current selection, instead of overwriting it.
-- @usage ecs selectload test 1 // This will add the "test" save to your current selection.
-- @usage ecs selectload test // This will replace your current selection with the "test" save.
ECS.NewCommand( "selectload", 2, function ( ply, args ) 
	if not args[1] then return end
	if not ECS.SavedSelections[ ply ] then return end
	if not ECS.SavedSelections[ ply ][ args[1] ] then return end

	if not args[2] then ECS.RemoveAll( ply ) end
	
	local name = args[1]
	ECS.Selections[ ply ] = ECS.Selections[ ply ] or { }

	local color = ECS.GetPlyColor( ply )
	for ent, info in pairs( ECS.SavedSelections[ ply ][ name ] ) do
		if not IsValid( ent ) then
			ECS.SavedSelections[ ply ][ name ][ ent ] = nil
			continue
		end

		ECS.Selections[ ply ][ ent ] = info		
		ent:SetRenderMode( 4 )
		ent:SetColor( color )
	end
end )

----
-- Selects all child props attached to your aim entity.
-- @tparam[opt=false] boolean addToSelection // If true, the child props will overwrite your current selection, instead of adding to it.
-- @usage ecs selectchildren 1 // This will replace your current selection with all the child props of your aim entity.
ECS.NewCommand( "selectchildren", 1, function ( ply, args )
	local trace = ply:GetEyeTrace().Entity
	if IsValid( trace ) and ECS.HasRights( ply, trace ) then
		if args[2] then ECS.RemoveAll( ply ) end

		local color = ECS.GetPlyColor( ply )
		for _, ent in pairs ( ents.GetAll() ) do
			if ent:GetParent() ~= trace then continue end
			ECS.AddEnt( ply, ent, color )
		end
	end
end )



/*
local Select = { }
local Deselect = { }

Select[ "all" ] = function ( ply, args )
	ECS.AddEnts( ply, ents.GetAll() )
end

Select[ "sphere" ] = function ( ply, args )
	if tonumber( args[2] or "0" ) > 0 then
		local find = ents.FindInSphere( ply:GetEyeTrace().HitPos, tonumber( args[2] ) )
		ECS.AddEnts( ply, find or { } )
	end
end

Select[ "children" ] = function ( ply, args )
	local trace = ply:GetEyeTrace().Entity
	if IsValid( trace ) and ECS.HasRights( ply, trace ) then
		if args[2] then ECS.RemoveAll( ply ) end

		for _, ent in pairs ( ents.GetAll() ) do
			if ent:GetParent() ~= trace then continue end
			ECS.AddEnt( ply, ent )
		end
	end	
end

Select[ "save" ] = function ( ply, args )
	if not args[2] then return end

	if ECS.GetSelectionCount( ply ) > 0 then
		ECS.SavedSelections[ ply ] = ECS.SavedSelections[ ply ] or { }

		local name = args[2]
		if args[3] then
			ECS.SavedSelections[ ply ][ name ] = ECS.SavedSelections[ ply ][ name ] or { }
			table.Merge( ECS.SavedSelections[ ply ][ name ], ECS.GetSelection( ply ) )
		else
			ECS.SavedSelections[ ply ][ name ] = table.Copy( ECS.GetSelection( ply ) )
		end
	end	
end

Select[ "load" ] = function ( ply, args )
	if not args[2] then return end
	if not ECS.SavedSelections[ ply ] then return end
	if not ECS.SavedSelections[ ply ][ args[2] ] then return end

	if not args[3] then ECS.RemoveAll( ply ) end
	
	local name = args[2]
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
end

ECS.NewCommand( "select", 3, function ( ply, args )
	if not args[1] then 
		local trace = ply:GetEyeTrace().Entity
		if IsValid( trace ) then ECS.AddEnt( ply, trace ) end

		return 
	end

	if not Select[ args[1] ] then return end
	Select[ args[1] ]( ply, args )
end )
*/