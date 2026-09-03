Enemigo = {}
Enemigo.__index = Enemigo
-- Estos llamados de index si lo tuve que pedir por chatgpt porque
-- todavía no estoy tan familiarizado con los tipos de datos de Lua y como crear clase etc

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

function Enemigo:Actualizar(jugador, a, dt)

    self:seguirJugador(jugador, a, dt)

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

function Enemigo:seguirJugador(jugador, a, dt)

    local dx = jugador.x - self.x
    local dy = jugador.y - self.y

    local distance = math.sqrt(dx * dx + dy * dy)

    -- Si y solo si está más lejos que la distancia mínima
    if distance > a then

        -- Normalizamos la direccion
        dx = dx / distance
        dy = dy / distance

        -- Move_and_slide del godot
        self.x = self.x + dx * self.velocidad * dt
        self.y = self.y + dy * self.velocidad * dt

    end
end

return Enemigo