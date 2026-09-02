Jugador = {}
Jugador.__index = Jugador


-- =================== CONSTRUCTOR ===================

function Jugador:Nuevo(x, y, img, v)

    local o = setmetatable({}, Jugador)

    o.x = x
    o.y = y

    o.sprite = love.graphics.newImage(img)

    -- Tamaño que queremos que tenga el personaje
    o.ancho = 125
    o.alto = 125

    -- Tamaño original de la imagen
    local ancho_original = o.sprite:getWidth()
    local alto_original = o.sprite:getHeight()

    -- Calculamos cuánto escalar
    o.escala_x = o.ancho / ancho_original
    o.escala_y = o.alto / alto_original

    o.velocidad = v

    return o
end


-- =================== ACTUALIZAR ===================

function Jugador:Actualizar(dt)

    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        self.x = self.x - (self.velocidad * dt)
    end

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        self.x = self.x + (self.velocidad * dt)
    end

    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        self.y = self.y - (self.velocidad * dt)
    end

    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        self.y = self.y + (self.velocidad * dt)
    end

end


-- =================== RENDERIZADO ===================

function Jugador:Dibujar()

    love.graphics.draw(
        self.sprite,
        self.x,
        self.y,
        0,
        self.escala_x,
        self.escala_y
    )

end


-- =================== DEPURAR ===================

function Jugador:Debug()

    love.graphics.rectangle(
        "line",
        self.x,
        self.y,
        self.ancho,
        self.alto
    )

end


return Jugador