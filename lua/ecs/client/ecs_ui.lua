----
--

AddCSLuaFile()

CreateClientConVar( "ecs_debugmsgs", 1, true, true )

CreateClientConVar( "ecs_selectioncolor_r", 255, true, true )
CreateClientConVar( "ecs_selectioncolor_g", 0, true, true )
CreateClientConVar( "ecs_selectioncolor_b", 0, true, true )
CreateClientConVar( "ecs_selectioncolor_a", 127, true, true )


-- Build the ECS utilities panel
local function UtilitiesPanel( CPanel )

	local DebugMsgs = CPanel:AddControl( "Checkbox", {
		Label = "Enable Debug Messages",
		Command = "ecs_debugmsgs"
	} )

	local ColorSelect = CPanel:AddControl( "Color", { 
		Label = "Entity Selection Color", 

		Red   = "ecs_selectioncolor_r",  
		Green = "ecs_selectioncolor_g",  
		Blue  = "ecs_selectioncolor_b",  
		Alpha = "ecs_selectioncolor_a",  
	} )

end

hook.Add( "PopulateToolMenu", "ECS.BuildMenu", function ()
	spawnmenu.AddToolMenuOption( "Utilities", "User", "Entity Command Suite", "#Entity Command Suite", "", "", UtilitiesPanel, nil )
end )


-- Build the ECS overlay
local function CommandOverlay( ply, cmd, args )

	-- Main Overlay Window
	local Overlay = vgui.Create( "DFrame" )
		Overlay:SetSize( 400, 200 )
		Overlay:Center()
		Overlay:SetTitle( "" )
		Overlay:SetVisible( true )
		Overlay:SetDraggable( false ) 
		Overlay:ShowCloseButton( false )
		Overlay:MakePopup()

		Overlay.btnMaxim:SetVisible( false )
		Overlay.btnMinim:SetVisible( false )

	Overlay.Paint = function ( self )
		draw.RoundedBoxEx( 8, 0, 0, self:GetWide(), self:GetTall(), Color(51, 51, 51), false, true, true, false )
		draw.RoundedBoxEx( 8, 1, 24, self:GetWide() - 2, self:GetTall() - 25, Color(127, 137, 147), false, false, true, false )

		draw.SimpleText( "Entity Command Suite", "DermaDefaultBold", 5, 4, Color(225, 225, 225), 0, 0 )
	end


	-- Close button
	local CloseButton = vgui.Create( "DButton", Overlay )
		CloseButton:SetText( "" )
		CloseButton:SetSize( 40, 24 )
		CloseButton:SetPos( Overlay:GetWide() - 40, 0 )

	CloseButton.TextColor = Color(225, 225, 225)
	CloseButton.FrameColor = Color(127, 137, 147)

	CloseButton.Paint = function ( self )
		draw.RoundedBoxEx( 8, 1, 1, self:GetWide() - 2, self:GetTall() - 2, CloseButton.FrameColor, false, true, false, false )
		draw.SimpleTextOutlined( "Close", "DermaDefaultBold", 5, 4, CloseButton.TextColor, 0, 0, 1, Color(51, 51, 51) )
	end

	CloseButton.OnCursorEntered = function ( self )
		self.TextColor = Color(255, 255, 255)
		self.FrameColor = Color(170, 180, 190)
	end

	CloseButton.OnCursorExited = function ( self )
		self.TextColor = Color(225, 225, 225)
		self.FrameColor = Color(127, 137, 147)	
	end

	CloseButton.DoClick = function ( self )
		Overlay:Close()
	end


	-- Options menu button
	local ConfigButton = vgui.Create( "DButton", Overlay )
		ConfigButton:SetText( "" )
		ConfigButton:SetSize( 52, 24 )
		ConfigButton:SetPos( Overlay:GetWide() - 91, 0 )

	ConfigButton.TextColor = Color(225, 225, 225)
	ConfigButton.FrameColor = Color(127, 137, 147)

	ConfigButton.Paint = function ( self )
		draw.RoundedBox( 0, 1, 1, self:GetWide() - 2, self:GetTall() - 2, ConfigButton.FrameColor )
		draw.SimpleTextOutlined( "Options", "DermaDefaultBold", 5, 4, ConfigButton.TextColor, 0, 0, 1, Color(51, 51, 51) )
	end

	ConfigButton.OnCursorEntered = function ( self )
		self.TextColor = Color(255, 255, 255)
		self.FrameColor = Color(170, 180, 190)
	end

	ConfigButton.OnCursorExited = function ( self )
		self.TextColor = Color(225, 225, 225)
		self.FrameColor = Color(127, 137, 147)	
	end

	ConfigButton.DoClick = function ( self )
		--Overlay:Close()
		--LocalPlayer():ConCommand( "+menu" )
	end


	-- Open ECS Documentation
	local HelpButton = vgui.Create( "DButton", Overlay )
		HelpButton:SetText( "" )
		HelpButton:SetSize( 34, 24 )
		HelpButton:SetPos( Overlay:GetWide() - 124, 0 )

	HelpButton.TextColor = Color(225, 225, 225)
	HelpButton.FrameColor = Color(127, 137, 147)

	HelpButton.Paint = function ( self )
		draw.RoundedBox( 0, 1, 1, self:GetWide() - 2, self:GetTall() - 2, HelpButton.FrameColor )
		draw.SimpleTextOutlined( "Help", "DermaDefaultBold", 5, 4, HelpButton.TextColor, 0, 0, 1, Color(51, 51, 51) )
	end

	HelpButton.OnCursorEntered = function ( self )
		self.TextColor = Color(255, 255, 255)
		self.FrameColor = Color(170, 180, 190)
	end

	HelpButton.OnCursorExited = function ( self )
		self.TextColor = Color(225, 225, 225)
		self.FrameColor = Color(127, 137, 147)	
	end

	HelpButton.DoClick = function ( self )
		-- gui.OpenURL( "https://dl.dropboxusercontent.com/u/10388108/ecs_doc/index.html" )
		-- http://maurits.tv/data/garrysmod/wiki/wiki.garrysmod.com/index01b1.html
	end

end



concommand.Add( "ecs_console", CommandOverlay )


