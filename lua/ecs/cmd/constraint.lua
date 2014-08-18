
----
-- These commands create/remove constraints.

ECS.ConstraintTypes = {
	["advballsocket"] = "AdvBallsocket",
	["all"]           = "All",
	["axis"] 		  = "Axis",
	["ballsocket"]    = "Ballsocket",
	["elastic"] 	  = "Elastic",
	["nocollide"] 	  = "NoCollide",
	["rope"]          = "Rope",
	["slider"]        = "Slider",
	["weld"] 		  = "Weld",
}

local function ValidType( typ )
	for _, con in pairs ( ECS.ConstraintTypes ) do
		if typ == con then return true end
	end
	return false
end

----
-- Removes given constraint type from entity.
-- @function ecs rc
-- @tparam string type Type of constraint to remove. "all" will remove all constraints. Not case-sensitive.
-- Valid Types: All, AdvBallsocket, Axis, Ballsocket, Elastic, NoCollide, Rope, Slider, Weld
-- @usage ecs rc all // This will remove all constraints from every entity in your selection.
ECS.NewCommand( "rc", 1, function ( ply, args )
	if not ValidType( string.lower( args[1] or "" ) ) then return false end

	local constraintType = ECS.ConstraintTypes[ string.lower( args[1] ) ]

	if ECS.GetSelectionCount( ply ) > 0 then
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			if constraintType == "All" then constraint.RemoveAll( ent ) else constraint.RemoveConstraints( ent, constraintType ) end
		end
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if trace and ECS.HasRights( ply, trace ) then 
		if constraintType == "All" then constraint.RemoveAll( trace ) else constraint.RemoveConstraints( trace, constraintType ) end
	end
end )

----
-- Removes all collision from your aim entity (or your selection if you have any entities selected).
-- @function ecs nocollideall 
-- @tparam boolean enable/disable If true, this will re-enable collisions.
-- @usage ecs nocollideall 0 // This will disable collisions for every entity in your selection.
-- @usage e-nocollideall // This will also disable collisions for every entity in your selection.
ECS.NewCommand( "nocollideall", 1, function( ply, args )
	local group = COLLISION_GROUP_NONE
	if args[1] then group = COLLISION_GROUP_WORLD end

	if ECS.GetSelectionCount( ply ) > 0 then
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			ent:SetCollisionGroup( group )
		end
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if trace and ECS.HasRights( ply, trace ) then 
		trace:SetCollisionGroup( group )
	end
end )

----
-- Nocollides your selection to your aim entity.
-- @function ecs nocollide
ECS.NewCommand( "nocollide", 0, function( ply, args )
	if ECS.GetSelectionCount( ply ) > 0 then
		local trace = ply:GetEyeTrace().Entity
		if trace and ECS.HasRights( ply, trace ) then
			for ent, info in pairs( ECS.GetSelection( ply ) ) do
				if trace == ent then continue end
				constraint.NoCollide( ent, trace, 0, 0 )
			end
		end
	end
end )

----
-- Welds your selection to your aim entity.
-- @function ecs weld
-- @tparam[opt=0] number forceLimit Force limit for the weld.
ECS.NewCommand( "weld", 1, function( ply, args )
	if ECS.GetSelectionCount( ply ) > 0 then
		local trace = ply:GetEyeTrace().Entity
		if trace and ECS.HasRights( ply, trace ) then
			local forceLimit = tonumber( args[1] or "0" )
			for ent, info in pairs( ECS.GetSelection( ply ) ) do
				if trace == ent then continue end
				constraint.Weld( ent, trace, 0, 0, forceLimit, false )
			end
		end
	end
end )

----
-- Parents your selection to your aim entity.
-- @function ecs parent
ECS.NewCommand( "parent", 0, function( ply, args )
	if ECS.GetSelectionCount( ply ) > 0 then
		local trace = ply:GetEyeTrace().Entity
		if trace and ECS.HasRights( ply, trace ) then
			for ent, info in pairs( ECS.GetSelection( ply ) ) do
				if trace == ent then continue end
				
				local phys = ent:GetPhysicsObject()
				if IsValid( phys ) then
					phys:EnableCollisions( false )
					phys:EnableMotion( true )
					phys:Sleep()

					ent:SetParent( trace )
				end
			end
		end
	end
end )

----
-- Unparents your selection.
-- @function ecs unparent
local function Unparent( ent )
	if not ent:GetParent() then return false end

	local phys = ent:GetPhysicsObject()

	if phys:IsValid() then
		local pos = ent:GetPos()
		local ang = ent:GetAngles()
	
		phys:EnableCollisions( true )
		phys:EnableMotion( false )
		phys:Sleep()
		
		ent:SetParent( nil)
		ent:SetPos( pos )
		ent:SetAngles( ang )
	end
end

ECS.NewCommand( "unparent", 0, function( ply, args )
	if ECS.GetSelectionCount( ply ) > 0 then
		for ent, info in pairs( ECS.GetSelection( ply ) ) do
			Unparent( ent )
		end
		return
	end

	local trace = ply:GetEyeTrace().Entity
	if trace and ECS.HasRights( ply, trace ) then 
		Unparent( trace )
	end	
end )
