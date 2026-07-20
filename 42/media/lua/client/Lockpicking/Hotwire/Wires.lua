if BetterLockpickingContinued == nil then BetterLockpickingContinued = {} end
BetterLockpickingContinued.Wires = {}

local field_height = 224
local red_x = 40
local blue_x = 100
local green_x = 160
local yellow_x = 220


function BetterLockpickingContinued.Wires.addWires(parent)
    parent:addChild(BetterLockpickingContinued_BigRedWire:new(parent))
    parent:addChild(BetterLockpickingContinued_BigBlueWire:new(parent))
    parent:addChild(BetterLockpickingContinued_BigGreenWire:new(parent))
    parent:addChild(BetterLockpickingContinued_BigYellowWire:new(parent))
end


----------------
-- Red
----------------

BetterLockpickingContinued_BigRedWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_BigRedWire:onMouseDown(x, y)
    self.parent:removeChild(self)
    self.parent:addChild(BetterLockpickingContinued_UpRedWire:new())
    self.parent:addChild(BetterLockpickingContinued_DownRedWire:new(self.parent))
	return true
end

function BetterLockpickingContinued_BigRedWire:new(parent)
    local texture = getTexture("media/textures/wire/wire_red_big.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, red_x, 0, width, height)
    o.parent = parent
    o.texture = texture

	return o
end

----------------

BetterLockpickingContinued_UpRedWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_UpRedWire:new()
    local texture = getTexture("media/textures/wire/wire_red_up.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, red_x, 0, width, height)
    o.texture = texture

	return o
end

----------------

BetterLockpickingContinued_DownRedWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_DownRedWire:onMouseDown(x, y)
    if self.parent.selectedWire == nil then
        self.texture = getTexture("media/textures/wire/wire_red_select.png")
        self.parent.selectedWire = self
    else
        if self.parent.selectedWire == self then
            self.texture = getTexture("media/textures/wire/wire_red.png")
            self.parent.selectedWire = nil
        else
            if self.parent.selectedWire.name == "blue" then
                self.parent:addChild(BetterLockpickingContinued_BlueRedWire:new(self.parent))
            elseif self.parent.selectedWire.name == "yellow" then
                self.parent:addChild(BetterLockpickingContinued_YellowRedWire:new(self.parent))
            elseif self.parent.selectedWire.name == "green" then
                self.parent:addChild(BetterLockpickingContinued_GreenRedWire:new(self.parent))
            end
            self.parent:wireConnected(self.parent.selectedWire.name, self.name)
            self.parent:removeChild(self.parent.selectedWire)
            self.parent:removeChild(self)
            self.parent.selectedWire = nil
        end
    end
	return true
end

function BetterLockpickingContinued_DownRedWire:new(parent)
    local texture = getTexture("media/textures/wire/wire_red.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, red_x, field_height - height, width, height)
    o.parent = parent
    o.texture = texture
    o.name = "red"

	return o
end

----------------
-- Blue
----------------


BetterLockpickingContinued_BigBlueWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_BigBlueWire:onMouseDown(x, y)
    self.parent:removeChild(self)
    self.parent:addChild(BetterLockpickingContinued_UpBlueWire:new())
    self.parent:addChild(BetterLockpickingContinued_DownBlueWire:new(self.parent))
	return true
end

function BetterLockpickingContinued_BigBlueWire:new(parent)
    local texture = getTexture("media/textures/wire/wire_blue_big.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, blue_x, 0, width, height)
    o.parent = parent
    o.texture = texture

	return o
end

----------------

BetterLockpickingContinued_UpBlueWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_UpBlueWire:new()
    local texture = getTexture("media/textures/wire/wire_blue_up.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, blue_x, 0, width, height)
    o.texture = texture

	return o
end

----------------

BetterLockpickingContinued_DownBlueWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_DownBlueWire:onMouseDown(x, y)
    if self.parent.selectedWire == nil then
        self.texture = getTexture("media/textures/wire/wire_blue_select.png")
        self.parent.selectedWire = self
    else
        if self.parent.selectedWire == self then
            self.texture = getTexture("media/textures/wire/wire_blue.png")
            self.parent.selectedWire = nil
        else
            if self.parent.selectedWire.name == "red" then
                self.parent:addChild(BetterLockpickingContinued_BlueRedWire:new(self.parent))
            elseif self.parent.selectedWire.name == "yellow" then
                self.parent:addChild(BetterLockpickingContinued_YellowBlueWire:new(self.parent))
            elseif self.parent.selectedWire.name == "green" then
                self.parent:addChild(BetterLockpickingContinued_BlueGreenWire:new(self.parent))
            end
            self.parent:wireConnected(self.parent.selectedWire.name, self.name)
            self.parent:removeChild(self.parent.selectedWire)
            self.parent:removeChild(self)
            self.parent.selectedWire = nil
        end
    end
	return true
end

function BetterLockpickingContinued_DownBlueWire:new(parent)
    local texture = getTexture("media/textures/wire/wire_blue.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, blue_x, field_height - height, width, height)
    o.parent = parent
    o.texture = texture
    o.name = "blue"

	return o
end



----------------
-- Green
----------------




BetterLockpickingContinued_BigGreenWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_BigGreenWire:onMouseDown(x, y)
    self.parent:removeChild(self)
    self.parent:addChild(BetterLockpickingContinued_UpGreenWire:new())
    self.parent:addChild(BetterLockpickingContinued_DownGreenWire:new(self.parent))
	return true
end

function BetterLockpickingContinued_BigGreenWire:new(parent)
    local texture = getTexture("media/textures/wire/wire_green_big.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, green_x, 0, width, height)
    o.parent = parent
    o.texture = texture

	return o
end

----------------

BetterLockpickingContinued_UpGreenWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_UpGreenWire:new()
    local texture = getTexture("media/textures/wire/wire_green_up.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, green_x, 0, width, height)
    o.texture = texture

	return o
end

----------------

BetterLockpickingContinued_DownGreenWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_DownGreenWire:onMouseDown(x, y)
    if self.parent.selectedWire == nil then
        self.texture = getTexture("media/textures/wire/wire_green_select.png")
        self.parent.selectedWire = self
    else
        if self.parent.selectedWire == self then
            self.texture = getTexture("media/textures/wire/wire_green.png")
            self.parent.selectedWire = nil
        else
            if self.parent.selectedWire.name == "red" then
                self.parent:addChild(BetterLockpickingContinued_GreenRedWire:new(self.parent))
            elseif self.parent.selectedWire.name == "yellow" then
                self.parent:addChild(BetterLockpickingContinued_YellowGreenWire:new(self.parent))
            elseif self.parent.selectedWire.name == "blue" then
                self.parent:addChild(BetterLockpickingContinued_BlueGreenWire:new(self.parent))
            end
            self.parent:wireConnected(self.parent.selectedWire.name, self.name)
            self.parent:removeChild(self.parent.selectedWire)
            self.parent:removeChild(self)
            self.parent.selectedWire = nil
        end
    end
	return true
end

function BetterLockpickingContinued_DownGreenWire:new(parent)
    local texture = getTexture("media/textures/wire/wire_green.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, green_x, field_height - height, width, height)
    o.parent = parent
    o.texture = texture
    o.name = "green"

	return o
end






----------------
-- Yellow
----------------




BetterLockpickingContinued_BigYellowWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_BigYellowWire:onMouseDown(x, y)
    self.parent:removeChild(self)
    self.parent:addChild(BetterLockpickingContinued_UpYellowWire:new())
    self.parent:addChild(BetterLockpickingContinued_DownYellowWire:new(self.parent))
	return true
end

function BetterLockpickingContinued_BigYellowWire:new(parent)
    local texture = getTexture("media/textures/wire/wire_yellow_big.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, yellow_x, 0, width, height)
    o.parent = parent
    o.texture = texture

	return o
end

----------------

BetterLockpickingContinued_UpYellowWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_UpYellowWire:new()
    local texture = getTexture("media/textures/wire/wire_yellow_up.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, yellow_x, 0, width, height)
    o.texture = texture

	return o
end

----------------

BetterLockpickingContinued_DownYellowWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_DownYellowWire:onMouseDown(x, y)
    if self.parent.selectedWire == nil then
        self.texture = getTexture("media/textures/wire/wire_yellow_select.png")
        self.parent.selectedWire = self
    else
        if self.parent.selectedWire == self then
            self.texture = getTexture("media/textures/wire/wire_yellow.png")
            self.parent.selectedWire = nil
        else
            if self.parent.selectedWire.name == "red" then
                self.parent:addChild(BetterLockpickingContinued_YellowRedWire:new(self.parent))
            elseif self.parent.selectedWire.name == "blue" then
                self.parent:addChild(BetterLockpickingContinued_YellowBlueWire:new(self.parent))
            elseif self.parent.selectedWire.name == "green" then
                self.parent:addChild(BetterLockpickingContinued_YellowGreenWire:new(self.parent))
            end
            self.parent:wireConnected(self.parent.selectedWire.name, self.name)
            self.parent:removeChild(self.parent.selectedWire)
            self.parent:removeChild(self)
            self.parent.selectedWire = nil
        end
    end
	return true
end

function BetterLockpickingContinued_DownYellowWire:new(parent)
    local texture = getTexture("media/textures/wire/wire_yellow.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, yellow_x, field_height - height, width, height)
    o.parent = parent
    o.texture = texture
    o.name = "yellow"

	return o
end




----------------
-- Combination
----------------

BetterLockpickingContinued_BlueRedWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_BlueRedWire:onMouseDown(x, y)
    self.parent:removeChild(self)
    self.parent:addChild(BetterLockpickingContinued_DownRedWire:new(self.parent))
    self.parent:addChild(BetterLockpickingContinued_DownBlueWire:new(self.parent))
	return true
end

function BetterLockpickingContinued_BlueRedWire:new(parent)
    local texture = getTexture("media/textures/wire/wire_blue_red.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, blue_x, field_height-height, width, height)
    o.parent = parent
    o.texture = texture

	return o
end

--------------

BetterLockpickingContinued_BlueGreenWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_BlueGreenWire:onMouseDown(x, y)
    self.parent:removeChild(self)
    self.parent:addChild(BetterLockpickingContinued_DownGreenWire:new(self.parent))
    self.parent:addChild(BetterLockpickingContinued_DownBlueWire:new(self.parent))
	return true
end

function BetterLockpickingContinued_BlueGreenWire:new(parent)
    local texture = getTexture("media/textures/wire/wire_blue_green.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, blue_x, field_height-height, width, height)
    o.parent = parent
    o.texture = texture

	return o
end

--------------

BetterLockpickingContinued_GreenRedWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_GreenRedWire:onMouseDown(x, y)
    self.parent:removeChild(self)
    self.parent:addChild(BetterLockpickingContinued_DownRedWire:new(self.parent))
    self.parent:addChild(BetterLockpickingContinued_DownGreenWire:new(self.parent))
	return true
end

function BetterLockpickingContinued_GreenRedWire:new(parent)
    local texture = getTexture("media/textures/wire/wire_green_red.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, green_x, field_height-height, width, height)
    o.parent = parent
    o.texture = texture

	return o
end

--------------

BetterLockpickingContinued_YellowBlueWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_YellowBlueWire:onMouseDown(x, y)
    self.parent:removeChild(self)
    self.parent:addChild(BetterLockpickingContinued_DownYellowWire:new(self.parent))
    self.parent:addChild(BetterLockpickingContinued_DownBlueWire:new(self.parent))
	return true
end

function BetterLockpickingContinued_YellowBlueWire:new(parent)
    local texture = getTexture("media/textures/wire/wire_yellow_blue.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, blue_x, field_height-height, width, height)
    o.parent = parent
    o.texture = texture

	return o
end

--------------

BetterLockpickingContinued_YellowGreenWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_YellowGreenWire:onMouseDown(x, y)
    self.parent:removeChild(self)
    self.parent:addChild(BetterLockpickingContinued_DownYellowWire:new(self.parent))
    self.parent:addChild(BetterLockpickingContinued_DownGreenWire:new(self.parent))
	return true
end

function BetterLockpickingContinued_YellowGreenWire:new(parent)
    local texture = getTexture("media/textures/wire/wire_yellow_green.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, green_x, field_height-height, width, height)
    o.parent = parent
    o.texture = texture

	return o
end

--------------

BetterLockpickingContinued_YellowRedWire = ISWire:derive("ISWire")

function BetterLockpickingContinued_YellowRedWire:onMouseDown(x, y)
    self.parent:removeChild(self)
    self.parent:addChild(BetterLockpickingContinued_DownRedWire:new(self.parent))
    self.parent:addChild(BetterLockpickingContinued_DownYellowWire:new(self.parent))
	return true
end

function BetterLockpickingContinued_YellowRedWire:new(parent)
    local texture = getTexture("media/textures/wire/wire_yellow_red.png")
    local width = texture:getWidth()
    local height = texture:getHeight()

    local o = ISWire.new(self, red_x, field_height-height, width, height)
    o.parent = parent
    o.texture = texture

	return o
end