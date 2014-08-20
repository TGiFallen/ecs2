
AddCSLuaFile()

if SERVER then
	util.AddNetworkString( "ECS.SendToClient" )
	util.AddNetworkString( "ECS.SendToServer" )

	ECS = ECS or { 
		Commands = { },
		Selections = { },
		SavedSelections = { }
	}

	include( "ecs/server/ecs_core.lua" )
	include( "ecs/server/commands/select.lua" )
	include( "ecs/server/commands/manipulate.lua" )
	include( "ecs/server/commands/property.lua" )
	include( "ecs/server/commands/constraint.lua" )

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
end

if CLIENT then
	ECS = ECS or { }

	include( "ecs/client/ecs_proc.lua" )
	include( "ecs/client/ecs_ui.lua" )
end
