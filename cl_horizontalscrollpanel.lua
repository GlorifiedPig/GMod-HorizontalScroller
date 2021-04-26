
local PANEL = {}

function PANEL:Init()
    self.CanvasPanel = vgui.Create( "Panel", self )
    self.CanvasPanel.OnMousePressed = function( canvasPanel, code )
        canvasPanel:GetParent():OnMousePressed( code )
    end
    self.CanvasPanel:SetMouseInputEnabled( true )
    self.CanvasPanel.PerformLayout = function( canvasPanel )
        self:PerformLayoutInternal()
        self:InvalidateParent()
    end

    self.Scrollbar = vgui.Create( "HorizontalScrollBar", self )
    self.Scrollbar:Dock( BOTTOM )

    self:SetMouseInputEnabled( true )

    self:SetPaintBackgroundEnabled( false )
    self:SetPaintBorderEnabled( false )
    self:SetPaintBackground( false )
end

function PANEL:AddItem( item )
    item:SetParent( self.CanvasPanel )
end

function PANEL:OnChildAdded( child )
    self:AddItem( child )
end

function PANEL:SetScrollSpeed( scrollSpeed )
    self.Scrollbar.ScrollSpeed = math.Clamp( scrollSpeed, 0.1, 100 )
end

function PANEL:GetScrollSpeed()
    return self.Scrollbar.ScrollSpeed
end

function PANEL:SizeToContents()
    self:SetSize( self.CanvasPanel:GetSize() )
end

function PANEL:Rebuild()
    self.CanvasPanel:SizeToChildren( true, false )

    if self.m_bNoSizing and self.CanvasPanel:GetWide() < self:GetWide() then
        self.CanvasPanel:SetPos( ( self:GetWide() - self.CanvasPanel:GetWide() ) * 0.5, 0 )
    end
end

function PANEL:PerformLayoutInternal()
    local w, h, xOffset = self.CanvasPanel:GetWide(), self:GetTall(), 0

    self:Rebuild()

    self.Scrollbar:Setup( self:GetWide(), self.CanvasPanel:GetWide() )
    xOffset = self.Scrollbar:GetOffset()

    if self.Scrollbar.Enabled then
        h = h - self.Scrollbar:GetTall()
    end

    self.CanvasPanel:SetPos( xOffset, 0 )
    self.CanvasPanel:SetTall( h )

    self:Rebuild()

    if w ~= self.CanvasPanel:GetWide() then
        self.Scrollbar:SetScroll( self.Scrollbar:GetScroll() )
    end
end

function PANEL:OnScroll( offset )
    self.CanvasPanel:SetPos( offset, 0 )
end

function PANEL:OnMouseWheeled( delta )
    return self.Scrollbar:OnMouseWheeled( delta )
end

function PANEL:PerformLayout()
    self:PerformLayoutInternal()
end

vgui.Register( "HorizontalScrollPanel", PANEL, "DPanel" )