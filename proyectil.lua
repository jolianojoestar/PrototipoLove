Proyectil = Class{}

function Proyectil:init(x, y, targetX, targetY, mundo)
    self.x = x
    self.y = y
    self.mundo = mundo
    self.radio = 3 -- Radio lógico para la hitbox
    self.ancho = self.radio * 2
    self.alto = self.radio * 2
    
    self.velocidad = 300
    self.es_proyectil = true

    -- Calcular dirección hacia el clic del mouse
    local angle = math.atan2(targetY - y, targetX - x)
    self.dx = math.cos(angle)
    self.dy = math.sin(angle)

    -- Registrar en Bump.lua
    if self.mundo then
        self.mundo:add(self, self.x - self.radio, self.y - self.radio, self.ancho, self.alto)
    end
end

function Proyectil:Actualizar(dt)
    self.x = self.x + self.dx * self.velocidad * dt
    self.y = self.y + self.dy * self.velocidad * dt

    -- Actualizar posición en el mundo de Bump
    if self.mundo then
        self.mundo:update(self, self.x - self.radio, self.y - self.radio, self.ancho, self.alto)
    end
end

function Proyectil:Dibujar()
    love.graphics.setColor(1, 1, 0) -- Amarillo brillante para el proyectil
    love.graphics.circle("fill", redondear(self.x), redondear(self.y), self.radio)
    love.graphics.setColor(1, 1, 1)
end

function Proyectil:Destruir()
    if self.mundo and self.mundo:hasItem(self) then
        self.mundo:remove(self)
    end
end