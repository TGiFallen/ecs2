
util.AddNetworkString( "ECS.SendToClient" )
util.AddNetworkString( "ECS.SendToServer" )

ECS = ECS or {
	Commands = { },
	Selections = { },
	SavedSelections = { }
}

include( "ecs2/lib/ecs_lib.lua" )
include( "ecs2/cmd/select.lua" )
include( "ecs2/cmd/manipulate.lua" )
include( "ecs2/cmd/property.lua" )
include( "ecs2/cmd/constraint.lua" )

hook.Add( "PlayerConnect", "ECS.OnPlayerConnect", function ( ply )
	ECS.Reload( ply )
end )

hook.Add( "PlayerDisconnected", "ECS.OnPlayerDisconnect", function ( ply )
	ECS.RemoveAll( ply )
	ECS.SavedSelections[ ply ] = nil
end )

hook.Add( "EntityRemoved", "ECS.OnEntRemove", function( ent )
	for ply, info in pairs( ECS.Selections ) do
		if info[ ent ] then 
			ECS.RemoveEnt( ply, ent )
			break
		end
	end
end )
