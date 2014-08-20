
----
-- These commands manipulate entities.

local function RemoveEnt( ent )
	constraint.RemoveAll( ent )

	ent:SetNotSolid( true )
	ent:SetMoveType( MOVETYPE_NONE )
	ent:SetNoDraw( true )

	ent:Remove()
end

local function EnableMovement( ent, bool )
	local phys = ent:GetPhysicsObject()

	if IsValid( phys ) then
		if phys:IsMoveable() then phys:Sleep() else phys:Wake() end
		phys:EnableMotion( bool )
	end
end

----
-- Removes your aim (or your selection if you have any entities selected).
-- @function remove
ECS.NewCommand( "remove", 0, function ( ply, args )
	if ECS.GetSelectionCount( ply ) > 0 then
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			RemoveEnt( ent )
		end
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if IsValid( trace ) and ECS.HasRights( ply, trace ) then RemoveEnt( trace ) end
end )

----
-- Freezes or unfreezes your aim (or your selection if you have any entities selected).
-- @function freeze
-- @tparam boolean freeze
-- @usage ecs freeze 0 // This will unfreeze all entities in your selection.
-- @usage ecs freeze 1 // This will freeze all entities in your selection.
ECS.NewCommand( "freeze", 1, function ( ply, args )
	local bool = false
	if args[1] and args[1] == "0" then bool = true end

	if ECS.GetSelectionCount( ply ) > 0 then
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			EnableMovement( ent, bool )
		end
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if IsValid( trace ) and ECS.HasRights( ply, trace ) then EnableMovement( trace, bool ) end
end )

----
-- Sets the position of your aim entity (or your selection if you have any entities selected) to the given coordinates. 
-- @function setpos
-- @tparam number x
-- @tparam number y
-- @tparam number z
-- @tparam boolean toAimEnt If true, this set the position of your selection to your aim entity's position offset by the given coordinates.
-- @usage ecs setpos 0 0 50 1 // If you are aiming at an entity, it will move your entire selection to 50 units above that entity.
-- @usage ecs setpos 0 0 50 // This will move your entire selection to Vector(0, 0, 50).
ECS.NewCommand( "setpos", 4, function ( ply, args )
	if ECS.GetSelectionCount( ply ) > 0 then
		local center = Vector(0, 0, 0)
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			center = center + ent:LocalToWorld( ent:OBBCenter() )
		end
		center = center / ECS.GetSelectionCount( ply )

		local newCenter = ECS.GetVector( args )
		if args[4] then
			local trace = ply:GetEyeTrace().Entity
			if IsValid( trace ) and ECS.HasRights( ply, trace ) then
				newCenter = trace:LocalToWorld( trace:OBBCenter() ) + newCenter
			end
		end

		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			ent:SetPos( (center - ent:LocalToWorld( ent:OBBCenter() )) + newCenter )
			EnableMovement( ent, false )
		end

		return
	end

	local trace = ply:GetEyeTrace().Entity
	if IsValid( trace ) and ECS.HasRights( ply, trace ) then
		trace:SetPos( ECS.GetVector( args ) )
		EnableMovement( trace, false ) 
	end	
end )

----
-- Offsets your aim entity's (or your selection if you have any entities selected) position by the given coordinates.
-- @function move
-- @tparam number x
-- @tparam number y
-- @tparam number z
-- @tparam boolean local. If true, the offset will be local to the entity.
-- @usage ecs move 0 0 50 1 // This will move your entire selection 50 units relative to each entity's Z axis.
-- @usage ecs move 0 0 50 // This will move your entire selection 50 units relative to the world's Z axis.
ECS.NewCommand( "move", 4, function ( ply, args )
	local moveLocal = args[4] or false

	if ECS.GetSelectionCount( ply ) > 0 then
		local moveVec = ECS.GetVector( args )
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			ent:SetPos( moveLocal and ent:LocalToWorld( moveVec ) or ent:LocalToWorld( ent:OBBCenter() ) + moveVec )
			EnableMovement( ent, false )
		end

		return
	end

	local trace = ply:GetEyeTrace().Entity
	if IsValid( trace ) and ECS.HasRights( ply, trace ) then
		local moveVec = ECS.GetVector( args )
		trace:SetPos( moveLocal and trace:LocalToWorld( moveVec ) or trace:LocalToWorld( trace:OBBCenter() ) + moveVec )
		EnableMovement( trace, false ) 
	end	
end )

----
-- Sets your aim entity's (or you rselection if you have any entities selected) angle to the given angle.
-- @function setang
-- @tparam number pitch
-- @tparam number yaw
-- @tparam number roll
-- @tparam boolean toAimEnt If true, this will set the angle to your aim entity's angle offset by the given angle.
-- @usage ecs setang 0 45 0 1 // If you are aiming at an entity, it will set the angle of your entire selection to that entity's angles offset by 45 yaw.
-- @usage ecs setang 0 45 0 // This will set the angles of your entire selection to Angle(0, 45, 0).
ECS.NewCommand( "setang", 4, function ( ply, args )
	if ECS.GetSelectionCount( ply ) > 0 then
		local newAngle = ECS.GetAngle( args )
		if args[4] then
			local trace = ply:GetEyeTrace().Entity
			if IsValid( trace ) and ECS.HasRights( ply, trace ) then
				newAngle = trace:LocalToWorldAngles( trace:GetAngles() + newAngle )
			end
		end

		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			ent:SetAngles( newAngle )
			EnableMovement( ent, false )
		end		

		return
	end

	local trace = ply:GetEyeTrace().Entity
	if IsValid( trace ) and ECS.HasRights( ply, trace ) then
		trace:SetAngles( ECS.GetAngle( args ) )
		EnableMovement( trace, false ) 
	end	
end )

----
-- Offsets your aim entity's (or your selection if you have any entities selected) angle by the given angle.
-- @function addrot
-- @tparam number x
-- @tparam number y
-- @tparam number z
-- @tparam boolean local If true, the offset will be local to the entity.
-- @usage ecs addrot 0 45 0 1 // This will rotate each entity in your selection by 45 yaw local to itself.
-- @usage ecs addrot 0 45 0 // This will rotate each entity in your selection by 45 yaw local to the world.
ECS.NewCommand( "addrot", 4, function ( ply, args )
	local rotateLocal = args[4] or false

	if ECS.GetSelectionCount( ply ) > 0 then
		local rotateAng = ECS.GetAngle( args )
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			ent:SetAngles( rotateLocal and ent:LocalToWorldAngles( rotateAng ) or ent:GetAngles() + rotateAng )
			EnableMovement( ent, false )
		end

		return
	end

	local trace = ply:GetEyeTrace().Entity
	if IsValid( trace ) and ECS.HasRights( ply, trace ) then
		local rotateAng = ECS.GetAngle( args )
		trace:SetAngles( rotateLocal and trace:LocalToWorldAngles( rotateAng ) or trace:GetAngles() + rotateAng)
		EnableMovement( trace, false ) 
	end
end )

----
-- Sets your aim entity's (or your selection if you have any entities selected) model to the given model
-- @function model
-- @tparam string modelPath -- wont do anything if the model doesn't exist on the server
-- @usage ecs model models/hunter/blocks/cube025x025x025.mdl
ECS.NewCommand( "model", 1, function ( ply, args )
	if not args[1] then return end
	if not util.IsValidModel( args[1] ) then return end

	local model = args[1]

	if ECS.GetSelectionCount( ply ) > 0 then
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			ent:SetModel( model )
			ent:PhysicsInit( SOLID_VPHYSICS )
		end

		return
	end

	local trace = ply:GetEyeTrace().Entity
	if IsValid( trace ) and ECS.HasRights( ply, trace ) then
		trace:SetModel( model )
		trace:PhysicsInit( SOLID_VPHYSICS )
	end	
end )
