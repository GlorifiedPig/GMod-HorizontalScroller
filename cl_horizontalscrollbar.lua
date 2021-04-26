
local PANEL = {}

function PANEL:Init()
    self.Enabled = true
    self.Offset = 0
    self.Scroll = 0
    self.CanvasSize = 1
    self.BarSize = 1
    self.HoldPos = 0
    self.ScrollSpeed = 1.5

    self.GripButton = vgui.Create( "DScrollBarGrip", self )
end

function PANEL:GetOffset()
    if not self.Enabled then return 0 end
    return self.Scroll * -1
end

function PANEL:GetScroll()
    if not self.Enabled then self.Scroll = 0 end
    return self.Scroll
end

function PANEL:BarScale()
    if self.BarSize == 0 then return 1 end
    return self.BarSize / ( self.CanvasSize + self.BarSize )
end

function PANEL:SetEnabled( enabled )
    if not enabled then
        self.Offset = 0
        self:SetScroll( 0 )
        self.HasChanged = true
    end

    self:SetMouseInputEnabled( enabled )
    self:SetVisible( enabled )

    if self.Enabled ~= enabled then
        self:GetParent():InvalidateLayout()
    end

    self.Enabled = enabled
end

function PANEL:Setup( barSize, canvasSize )
    self.BarSize = barSize
    self.CanvasSize = math.max( canvasSize - barSize, 1 )

    self:SetEnabled( canvasSize > barSize )

    self:InvalidateLayout()
end

function PANEL:OnMouseWheeled( delta )
    if not self:IsVisible() then return false end

    return self:AddScroll( delta * -2 )
end

function PANEL:SetScrollSpeed( scrollSpeed )
    self.ScrollSpeed = math.Clamp( scrollSpeed, 0.1, 100 )
end

function PANEL:GetScrollSpeed()
    return self.ScrollSpeed
end

function PANEL:AddScroll( delta )
    local oldScroll = self:GetScroll()

    delta = delta * 25 * self.ScrollSpeed
    self:SetScroll( self:GetScroll() + delta )

    return oldScroll ~= self:GetScroll()
end

function PANEL:SetScroll( scroll )
    if not self.Enabled then self.Scroll = 0 return end

    self.Scroll = math.Clamp( scroll, 0, self.CanvasSize )

    self:InvalidateLayout()

    local scrollFunc = self:GetParent().OnScroll
    if scrollFunc then
        scrollFunc( self:GetParent(), self:GetOffset() )
    else
        self:GetParent():InvalidateLayout()
    end
end

function PANEL:Grip()
    if not self.Enabled or self.BarSize == 0 then return end
    self:MouseCapture( true )
    self.Dragging = true

    local x = self.GripButton:ScreenToLocal( gui.MouseX(), 0 )
    self.HoldPos = x
    self.GripButton.Depressed = true
end

function PANEL:OnMousePressed()
    local x = self:CursorPos()
    local pageSize = self.BarSize

    self:SetScroll( x > self.GripButton.x and self:GetScroll() + pageSize or self:GetScroll() - pageSize )
end

function PANEL:OnMouseReleased()
    self.Dragging = false
    self:MouseCapture( false )

    self.GripButton.Depressed = false
end

function PANEL:OnCursorMoved()
    if not self.Enabled or not self.Dragging then return end

    local x = self:ScreenToLocal( gui.MouseX(), 0 )

    x = x - self.HoldPos

    local trackSize = self:GetWide() - self.GripButton:GetWide()

    x = x / trackSize

    self:SetScroll( x * self.CanvasSize )
end

function PANEL:PerformLayout( w, h )
    local scroll = self:GetScroll() / self.CanvasSize
    local barSize = math.max( self:BarScale() * w, 10 )
    local track = w - barSize
    track = track + 1
    scroll = scroll * track

    self.GripButton:SetPos( scroll, 0 )
    self.GripButton:SetSize( barSize, h )
end

function PANEL:Paint( w, h )
    derma.SkinHook( "Paint", "VScrollBar", self, w, h )
    return true
end

vgui.Register( "HorizontalScrollBar", PANEL, "Panel" )