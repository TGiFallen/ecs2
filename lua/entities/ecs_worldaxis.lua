
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
	self:NetworkVar( "Bool", 0, "LockAngle", { KeyName = "lockAngle", Edit = { type = "Boolean", category = "Options", order = 1 } } )
	self:NetworkVar( "Bool", 1, "AlwaysShowWorld", { KeyName = "AlwaysShowWorld", Edit = { type = "Boolean", category = "Options" } } )

	self:NetworkVar( "Float", 0, "LengthX", { KeyName = "lengthX", Edit = { type = "Float", category = "Customize", min = 1, max = 4096 } } )
	self:NetworkVar( "Float", 1, "LengthY", { KeyName = "lengthY", Edit = { type = "Float", category = "Customize",  min = 1, max = 4096 } } )
	self:NetworkVar( "Float", 2, "LengthZ", { KeyName = "lengthZ", Edit = { type = "Float", category = "Customize",  min = 1, max = 4096 } } )
	self:NetworkVar( "Float", 3, "Width", { KeyName = "width", Edit = { type = "Float", category = "Customize",  min = 1, max = 16 } } )
end

function ENT:SpawnFunction( ply, tr, className )
	if not tr.Hit then return end

	local ent = ents.Create( className )

	ent:SetLockAngle( true )
	ent:SetAlwaysShowWorld( true )

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

		self:NetworkVarNotify( "LockAngle", self.OnLockAngleChanged )
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
				if self:GetLockAngle() then 
					self:SetAngles( Angle(0, 0, 0) ) 
				end
			end
		else
			if self:GetLockAngle() then 
				self:SetAngles( Angle(0, 0, 0) ) 
			end
		end
	end
end

function ENT:OnLockAngleChanged( name, old, new )
	if SERVER then
		self:SetAngles( new and Angle(0, 0, 0) or self:GetAngles() )
	end
end

if CLIENT then
	local mat = Material( "effects/laser_tracer" )

	local red = Color(255, 0, 0, 255)
	local green = Color(0, 255, 0, 255)
	local blue = Color(0, 0, 255, 255)

	local redFade = Color(255, 0, 0, 127)
	local greenFade = Color(0, 255, 0, 127)
	local blueFade = Color(0, 0, 255, 127)

	function ENT:Draw()	
		local origin = self:GetPos()
		local width = self:GetWidth()
		local lockAngle = self:GetLockAngle()

		render.SetMaterial( mat )

		if not lockAngle then
			render.DrawBeam( origin, self:LocalToWorld( Vector( self:GetLengthX(), 0, 0 ) ), width, 0.25, 0.75, red )
			render.DrawBeam( origin, self:LocalToWorld( Vector( 0, self:GetLengthY(), 0 ) ), width, 0.25, 0.75, green )
			render.DrawBeam( origin, self:LocalToWorld( Vector( 0, 0, self:GetLengthZ() ) ), width, 0.25, 0.75, blue )	

			if self:GetAlwaysShowWorld() then
				render.DrawBeam( origin, origin + Vector( 64, 0, 0 ), 1, 0.25, 0.75, redFade )
				render.DrawBeam( origin, origin + Vector( 0, 64, 0 ), 1, 0.25, 0.75, greenFade )
				render.DrawBeam( origin, origin + Vector( 0, 0, 64 ), 1, 0.25, 0.75, blueFade )	
			end	
		else
			render.DrawBeam( origin, origin + Vector( self:GetLengthX(), 0, 0 ), width, 0.25, 0.75, red )
			render.DrawBeam( origin, origin + Vector( 0, self:GetLengthY(), 0 ), width, 0.25, 0.75, green )
			render.DrawBeam( origin, origin + Vector( 0, 0, self:GetLengthZ() ), width, 0.25, 0.75, blue )
		end

		local scalar = math.max( self:GetLengthX(), self:GetLengthY(), self:GetLengthZ() )
		local bounds = Vector( scalar, scalar, scalar )
		self:SetRenderBounds( -bounds, bounds )
	end
end
