Jugador = {}
Jugador.__index = Jugador
--Estas cosas es redundancia de codigo o copia
-- Entiendo que lo ideal es herencia etc, pero quería ir directo a hacer el loop
-- ya que estoy entregando fuera de tiempo

-- =================== CONSTRUCTOR ===================

function Jugador:Nuevo(x, y, img, v)

    local o = setmetatable({}, Jugador)

    o.x = x
    o.y = y

    o.sprite = love.graphics.newImage(img)
    -- Tamaño que queremos que tenga el personaje
    o.ancho = 125
    o.alto = 125

    -- Tamaño originl de la imagen
    local ancho_original = o.sprite:getWidth()
    local alto_original = o.sprite:getHeight()

    -- Calculamos cuánto escalar
    o.escala_x = o.ancho / ancho_original
    o.escala_y = o.alto / alto_original
    
    o.origen_x = o.ancho / 2
    o.origen_y = o.alto / 2

    o.velocidad = v

    return o
end


-- =================== ACTUALIZAR ===================

function Jugador:Actualizar(dt)
    -- inputWASD o flechas
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
        self.x - self.origen_x,
        self.y - self.origen_y,
        0,
        self.escala_x,
        self.escala_y
    )

end


-- =================== DEPURAR ===================
-- Puse aparte para ahorrarme el comentar / descomentar
function Jugador:Debug()

    love.graphics.rectangle(
        "line",
        self.x - self.origen_x,
        self.y - self.origen_y,
        self.ancho,
        self.alto
        
    )
    -- punto al centro del jugador
    love.graphics.circle(
        "fill",
        math.floor(self.x),
        math.floor(self.y),
        2
    )

end


return Jugador