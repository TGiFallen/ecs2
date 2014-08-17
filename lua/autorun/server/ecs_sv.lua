
util.AddNetworkString( "ECS.SendToClient" )
util.AddNetworkString( "ECS.SendToServer" )

ECS = ECS or {
	Commands = { },
	Selections = { }
}

include( "ecs2/lib/ecs_lib.lua" )
include( "ecs2/cmd/select.lua" )
include( "ecs2/cmd/manipulate.lua" )
include( "ecs2/cmd/property.lua" )
include( "ecs2/cmd/constraint.lua" )
