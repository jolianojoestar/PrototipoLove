Enemigo = {}
Enemigo.__index = Enemigo


-- =================== CONSTRUCTOR ===================

function Enemigo:Nuevo(x, y, img, v)

    local o = setmetatable({}, Enemigo)

    o.x = x
    o.y = y

    o.sprite = love.graphics.newImage(img)

    o.ancho = o.sprite:getWidth()
    o.alto = o.sprite:getHeight()

    o.origen_x = o.ancho / 2
    o.origen_y = o.alto / 2

    o.hitbox_x = 0
    o.hitbox_y = 0

    o.velocidad = v

    return o

end


-- =================== ACTUALIZAR ===================

function Enemigo:Actualizar(x, y, a, dt)

    local dist_x = math.abs(self.x - x)
    local dist_y = math.abs(self.y - y)

    if dist_x > dist_y then

        if dist_x > a then

            if self.x < x then
                self.x = self.x + (self.velocidad * dt)

            elseif self.x > x then
                self.x = self.x - (self.velocidad * dt)
            end

        end

    else

        if dist_y > a then

            if self.y < y then
                self.y = self.y + (self.velocidad * dt)

            elseif self.y > y then
                self.y = self.y - (self.velocidad * dt)
            end

        end

    end

    self.hitbox_x = self.x - self.origen_x
    self.hitbox_y = self.y - self.origen_y

end


-- =================== RENDERIZADO ===================

function Enemigo:Dibujar()

    love.graphics.draw(
        self.sprite,
        math.floor(self.x),
        math.floor(self.y),
        0,
        1,
        1,
        self.origen_x,
        self.origen_y
    )

end


-- =================== DEPURAR ===================

function Enemigo:Debug()

    love.graphics.rectangle(
        "line",
        math.floor(self.hitbox_x),
        math.floor(self.hitbox_y),
        self.ancho,
        self.alto
    )

    love.graphics.circle(
        "fill",
        math.floor(self.x),
        math.floor(self.y),
        1
    )

end


return Enemigo