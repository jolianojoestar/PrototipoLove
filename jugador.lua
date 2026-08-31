Jugador = {}
Jugador.__index = Jugador

-- =================== CONSTRUCTOR ===================

function Jugador:Nuevo(x, y, img, v)

    local o = setmetatable({}, Jugador)

    o.x = x
    o.y = y

    o.sprite = love.graphics.newImage(img)

    o.ancho = o.sprite:getWidth()
    o.alto = o.sprite:getHeight()

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
        self.y
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