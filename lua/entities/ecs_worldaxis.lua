
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )
 
ENT.PrintName	= "World Axis"
ENT.Author		= "shadowscion"
ENT.Category    = "Entity Command Suite"

ENT.Editable    = true
ENT.Spawnable	= true
ENT.AdminOnly	= false

ENT.RenderGroup = RENDERGROUP_OPAQUE 

function ENT:SetupDataTables()
	self:NetworkVar( "Float", 0, "LengthX", { KeyName = "lengthX", Edit = { type = "Float", min = 6, max = 4096, order = 1 } } )
	self:NetworkVar( "Float", 1, "LengthY", { KeyName = "lengthY", Edit = { type = "Float", min = 6, max = 4096, order = 2 } } )
	self:NetworkVar( "Float", 2, "LengthZ", { KeyName = "lengthZ", Edit = { type = "Float", min = 6, max = 4096, order = 3 } } )
	self:NetworkVar( "Float", 3, "Width", { KeyName = "width", Edit = { type = "Float", min = 2, max = 16, order = 4 } } )
end

function ENT:SpawnFunction( ply, tr, className )
	if not tr.Hit then return end

	local ent = ents.Create( className )

	ent:SetLengthX( 128 )
	ent:SetLengthY( 128 )
	ent:SetLengthZ( 128 )
	ent:SetWidth( 4 )

	ent:SetPos( tr.HitPos + tr.HitNormal * 32 )
	ent:DrawShadow( false )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
		self:PhysicsInitSphere( 6, "gmod_silent" )

		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:Wake()
			phys:EnableMotion( false )
		end

		self:SetCollisionBounds( Vector( -6, -6, -6 ), Vector( 6, 6, 6 ) )
	else

	end
end

-- Lock the entity's angles, and freeze it when not being held.
function ENT:PhysicsUpdate() 
	if SERVER then
		if not self:IsPlayerHolding() then
			local phys = self:GetPhysicsObject()
			if IsValid( phys ) then
				phys:EnableMotion( false )
			end
		else
			self:SetAngles( Angle(0, 0, 0) )
		end
	end
end

if CLIENT then
	local mat = Material( "effects/laser_tracer" )

	local red = Color(255, 0, 0, 255)
	local green = Color(0, 255, 0, 255)
	local blue = Color(0, 0, 255, 255)

	function ENT:Draw()	
		local origin = self:GetPos()
		local width = self:GetWidth()

		render.SetMaterial( mat )

		render.DrawBeam( origin, origin + Vector( self:GetLengthX(), 0, 0 ), width, 0.25, 0.75, red )
		render.DrawBeam( origin, origin + Vector( 0, self:GetLengthY(), 0 ), width, 0.25, 0.75, green )
		render.DrawBeam( origin, origin + Vector( 0, 0, self:GetLengthZ() ), width, 0.25, 0.75, blue )

		local scalar = math.max( self:GetLengthX(), self:GetLengthY(), self:GetLengthZ() )
		local bounds = Vector( scalar, scalar, scalar )
		self:SetRenderBounds( -bounds, bounds )
	end
end
