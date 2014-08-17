
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
-- @function e_remove
ECS.NewCommand( "e_remove", 0, function ( ply, args )
	if ECS.GetSelectionCount( ply ) > 0 then
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			RemoveEnt( ent )
		end
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if trace and ECS.HasRights( ply, trace ) then RemoveEnt( trace ) end
end )

----
-- Freezes or unfreezes your aim (or your selection if you have any entities selected).
-- @function e_freeze
-- @param boolean 1/0 for freeze/unfreeze
ECS.NewCommand( "e_freeze", 1, function ( ply, args )
	local bool = false
	if args[1] and args[1] == "0" then bool = true end

	if ECS.GetSelectionCount( ply ) > 0 then
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			EnableMovement( ent, bool )
		end
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if trace and ECS.HasRights( ply, trace ) then EnableMovement( trace, bool ) end
end )

----
-- Sets the position of your aim entity (or your selection if you have any entities selected) to the given coordinates. 
-- @function e_setpos
-- @param X
-- @param Y
-- @param Z
-- @param ent If you pass "ent" as a fourth argument, it will set the position to your aim entity's position offset by the given coordinates.
ECS.NewCommand( "e_setpos", 4, function ( ply, args )
	if ECS.GetSelectionCount( ply ) > 0 then
		local center = Vector(0, 0, 0)
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			center = center + ent:LocalToWorld( ent:OBBCenter() )
		end
		center = center / ECS.GetSelectionCount( ply )

		local newCenter = ECS.GetVector( args )
		if string.lower( args[4] or "" ) == "ent" then
			local trace = ply:GetEyeTrace().Entity
			if trace and ECS.HasRights( ply, trace ) then
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
	if trace and ECS.HasRights( ply, trace ) then
		trace:SetPos( ECS.GetVector( args ) )
		EnableMovement( trace, false ) 
	end	
end )

----
-- Offsets your aim entity's (or your selection if you have any entities selected) position by the given coordinates.
-- @function e_move
-- @param X
-- @param Y
-- @param Z
-- @param local Boolean argument, if true the offset will be local to the entity.
ECS.NewCommand( "e_move", 4, "Add pos to trace entity or selection. 4th bool arg for local.", function ( ply, args )
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
	if trace and ECS.HasRights( ply, trace ) then
		local moveVec = ECS.GetVector( args )
		trace:SetPos( moveLocal and trace:LocalToWorld( moveVec ) or trace:LocalToWorld( trace:OBBCenter() ) + moveVec )
		EnableMovement( trace, false ) 
	end	
end )

----
-- Sets your aim entity's (or you rselection if you have any entities selected) angle to the given angle.
-- @function e_setang
-- @param Pitch
-- @param Yaw
-- @param Roll
-- @param ent If you pass "ent" as a fourth argument, it will set the angle to your aim entity's angle offset by the given angle.
ECS.NewCommand( "e_setang", 4, "Set ang of trace entity or selection. 4th arg \"ent\" to copy trace entity.", function ( ply, args )
	if ECS.GetSelectionCount( ply ) > 0 then
		local newAngle = ECS.GetAngle( args )
		if string.lower( args[4] or "" ) == "ent" then
			local trace = ply:GetEyeTrace().Entity
			if trace and ECS.HasRights( ply, trace ) then
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
	if trace and ECS.HasRights( ply, trace ) then
		trace:SetAngles( ECS.GetAngle( args ) )
		EnableMovement( trace, false ) 
	end	
end )

----
-- Offsets your aim entity's (or your selection if you have any entities selected) angle by the given angle.
-- @function e_move
-- @param X
-- @param Y
-- @param Z
-- @param local Boolean argument, if true the offset will be local to the entity.
ECS.NewCommand( "e_addrot", 4, "Add ang of trace entity or selection. 4th arg for local.", function ( ply, args )
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
	if trace and ECS.HasRights( ply, trace ) then
		local rotateAng = ECS.GetAngle( args )
		trace:SetAngles( rotateLocal and trace:LocalToWorldAngles( rotateAng ) or trace:GetAngles() + rotateAng)
		EnableMovement( trace, false ) 
	end
end )
