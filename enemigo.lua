Enemigo = {}
Enemigo.__index = Enemigo


-- =================== CONSTRUCTOR ===================

function Enemigo:Nuevo(x, y, img, v)

    local o = setmetatable({}, Enemigo)

    o.x = x
    o.y = y

    o.sprite = love.graphics.newImage(img)

    -- Tamaño deseado
    o.ancho = 125
    o.alto = 125

    -- Tamaño original de la imagen
    local ancho_original = o.sprite:getWidth()
    local alto_original = o.sprite:getHeight()

    -- Escala necesaria
    o.escala_x = o.ancho / ancho_original
    o.escala_y = o.alto / alto_original

    -- Centro de la imagen YA ESCALADA
    o.origen_x = o.ancho / 2
    o.origen_y = o.alto / 2

    -- Hitbox
    o.hitbox_x = o.x - o.origen_x
    o.hitbox_y = o.y - o.origen_y

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

    -- Actualizar hitbox
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
        self.escala_x,
        self.escala_y,
        self.sprite:getWidth() / 2,
        self.sprite:getHeight() / 2
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
        2
    )

end


return Enemigo