-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'lib.class'

Jugador = Class{}
-- =================== INICIALIZACION ===================
function Jugador:init(x, y, img, v, mundo)
    self.x = x
    self.y = y
    self.sprite = love.graphics.newImage(img)
    
    -- Tamaño visual de la imagen
    self.sprite_ancho = self.sprite:getWidth()
    self.sprite_alto  = self.sprite:getHeight()
    
    -- TAMAÑO DE LA HITBOX REDUCIDO (ej: 32x32 en lugar de 125x125)
    self.ancho = 32
    self.alto  = 32
    
    self.origen_x = self.sprite_ancho / 2
    self.origen_y = self.sprite_alto  / 2
    
    self.hitbox_x = self.x - (self.ancho / 2)
    self.hitbox_y = self.y - (self.alto / 2)
    
    self.velocidad = v
    self.anterior_x = self.x
    self.anterior_y = self.y

    self.mundo = mundo
    if self.mundo then
        self.mundo:add(self, self.hitbox_x, self.hitbox_y, self.ancho, self.alto)
    end
end
-- =================== ACTUALIZAR ===================
function Jugador:Actualizar(dt)

    self.anterior_x = self.x
    self.anterior_y = self.y

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        self.x = self.x + (self.velocidad * dt)
        if self.x > 640 then self.x = 0 end
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        self.x = self.x - (self.velocidad * dt)
        if self.x < 0 then self.x = 640 end
    elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        self.y = self.y + (self.velocidad * dt)
        if self.y > 350 then self.y = 0 end
    elseif love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        self.y = self.y - (self.velocidad * dt)
        if self.y < 0 then self.y = 350 end
    end

    self.hitbox_x = self.x - (self.ancho/2)
    self.hitbox_y = self.y - (self.alto/2)
    self.mundo:update(self, self.hitbox_x, self.hitbox_y, self.ancho, self.alto)
end
-- =================== Colision ===================
function Jugador:Colision()
    --[[
   return  self.hitbox_x < otro_hitbox_x + otro_ancho and
           otro_hitbox_x < self.hitbox_x + self.ancho and
           self.hitbox_y < otro_hitbox_y + otro_alto and
           otro_hitbox_y < self.hitbox_y + self.alto
    ]]
    local hitboxes, cantidad = self.mundo:queryRect(self.hitbox_x, self.hitbox_y, self.ancho, self.alto)
    
    for i = 1, cantidad do
        local objeto = hitboxes[i]

        if objeto ~= self then
            if objeto.es_enemigo then
                return true
            elseif objeto.es_pared then
                self.x = self.anterior_x
                self.y = self.anterior_y
                self.hitbox_x = self.x - self.origen_x
                self.hitbox_y = self.y - self.origen_y
                self.mundo:update(self, self.hitbox_x, self.hitbox_y, self.ancho, self.alto)
            end
        end
    end
    return false
end
-- =================== RENDERIZADO ===================
-- =================== RENDERIZADO ===================
function Jugador:Dibujar()
    love.graphics.draw(
        self.sprite,redondear(self.x),redondear(self.y),0,
        (self.ancho/self.sprite_ancho),(self.alto/self.sprite_alto),self.origen_x,self.origen_y --(escala_x),(escala_y)
    )
end
function Jugador:Debug()
    love.graphics.rectangle(
        "line",
        math.floor(self.hitbox_x),
        math.floor(self.hitbox_y),
        self.ancho,
        self.alto
    )
    love.graphics.circle("fill", math.floor(self.x), math.floor(self.y), 2)
end