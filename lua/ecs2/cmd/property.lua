
----
-- These commands edit the properties of entities.

local duplicator = duplicator
local construct = construct

----
-- Sets the mass of your aim entity (or your selection if you have any entities selected).
-- @function e_mass
-- @tparam number mass 
-- @usage e_mass 300 // This will set the mass of all entities in your selection to 300.
ECS.NewCommand( "e_mass", 1, function ( ply, args )
	local data = { mass = math.Clamp( tonumber( args[1] or "1" ), 0.01, 50000 ) }
	local mass = data.mass

	if ECS.GetSelectionCount( ply ) > 0 then
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			local phys = ent:GetPhysicsObject()
			if IsValid( phys ) then
				phys:SetMass( mass )
				duplicator.StoreEntityModifier( ent, "mass", data )
			end
		end
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if trace and ECS.HasRights( ply, trace ) then 
		local phys = trace:GetPhysicsObject()
		if IsValid( phys ) then
			trace:SetMass( mass )
			duplicator.StoreEntityModifier( trace, "mass", data )
		end
	end
end )

----
-- Toggles the gravity of your aim entity (or your selection if you have any entities selected).
-- @function e_gravity
-- @tparam boolean enable/disable
-- @usage e_gravity 0 // This will disable the gravity of all entities in your selection.
ECS.NewCommand( "e_gravity", 1, function ( ply, args )
	local data = { GravityToggle = true }
	if args[1] == "0" then data = { GravityToggle = false } end

	if ECS.GetSelectionCount( ply ) > 0 then
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			construct.SetPhysProp( ply, ent, 0, nil, data )
		end
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if trace and ECS.HasRights( ply, trace ) then 
		construct.SetPhysProp( ply, trace, 0, nil, data )
	end
end )


----
-- Toggles the drag of your aim entity (or your selection if you have any entities selected).
-- @function e_drag
-- @tparam boolean enable/disable
-- @usage e_drag 0 // This will disable the drag of all entities in your selection.
ECS.NewCommand( "e_mass", 1, function ( ply, args )
	local data = { DragOnOff = true }
	if args[1] == "0" then data = { DragOnOff = false } end
	local drag = data.DragOnOff

	if ECS.GetSelectionCount( ply ) > 0 then
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			local phys = ent:GetPhysicsObject()
			if IsValid( phys ) then
				phys:EnableDrag( drag )
				duplicator.StoreEntityModifier( ent, "DragEnabled", data )
			end
		end
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if trace and ECS.HasRights( ply, trace ) then 
		local phys = trace:GetPhysicsObject()
		if IsValid( phys ) then
			phys:EnableDrag( drag )
			duplicator.StoreEntityModifier( trace, "DragEnabled", data )
		end
	end
end )

----
-- Sets the physical property of your aim entity (or your selection if you have any entities selected).
-- @function e_physprop
-- @tparam string physprop Physprop material to set entities to.
-- @usage e_physprop jeeptire // This will set the physprop material of all entities in your selection to "jeeptire".
ECS.NewCommand( "e_physprop", 1, function ( ply, args )
	local data = { Material = args[1] or "" }

	if ECS.GetSelectionCount( ply ) > 0 then
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			construct.SetPhysProp( ply, ent, 0, nil, data )
		end
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if trace and ECS.HasRights( ply, trace ) then 
		construct.SetPhysProp( ply, trace, 0, nil, data )
	end
end )

----
-- Sets the color property of your aim entity (or your selection if you have any entities selected).
-- @function e_color
-- @tparam number r Red color component.
-- @tparam number g Green color component.
-- @tparam number b Blue color component.
-- @tparam[opt=nil] number a Alpha color component. If not given, entity retains current alpha.
-- @usage e_color 255 0 0 127 // This will set the color of all entities in your selection to Color(255, 0, 0, 127).
ECS.NewCommand( "e_color", 4, function ( ply, args )
	local color = ECS.GetColor( args )
	local alpha = -1
	if args[4] then 
		alpha = math.Clamp( tonumber( args[4] ), 0, 255 )
		color.a = alpha
	end

	if ECS.GetSelectionCount( ply ) > 0 then
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			info.Color = color
			if alpha ~= -1 then 
				info.Mode = alpha < 255 and 4 or 0
			end
		end
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if trace and ECS.HasRights( ply, trace ) then 
		if alpha ~= -1 then trace:SetRenderMode( alpha < 255 and 4 or 0 ) end
		trace:SetColor( color )
	end
end )

----
-- Sets the material of your aim entity (or your selection if you have any entities selected).
-- @function e_material
-- @tparam string material Material to set entities to. <b>DOUBLE CHECK PATH, YOU MIGHT LAG IF YOU PROVIDE AN INVALID MATERIAL.</b>
-- @usage e_material some/material/path // This will set the material of all entities in your selection to "some/material/path".
ECS.NewCommand( "e_material", 1, function ( ply, args )
	local data = { MaterialOverride = args[1] or "" }
	local mat = data.MaterialOverride

	if ECS.GetSelectionCount( ply ) > 0 then
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			ent:SetMaterial( mat )
			duplicator.StoreEntityModifier( ent, "material", data )
		end
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if trace and ECS.HasRights( ply, trace ) then 
		trace:SetMaterial( mat )
		duplicator.StoreEntityModifier( trace, "material", data )
	end
end )
