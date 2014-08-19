
util.AddNetworkString( "ECS.SendToClient" )
util.AddNetworkString( "ECS.SendToServer" )

ECS = ECS or { 
	Commands = { },
	Selections = { },
	SavedSelections = { }
}

include( "ecs/lib/ecs_lib.lua" )
include( "ecs/cmd/select.lua" )
include( "ecs/cmd/manipulate.lua" )
include( "ecs/cmd/property.lua" )
include( "ecs/cmd/constraint.lua" )

hook.Add( "PlayerInitialSpawn", "ECS.InitPlayer", function ( ply )
	ECS.Reload( nil, ply )
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
