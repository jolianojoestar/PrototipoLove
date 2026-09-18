Proyectil = Class{}

function Proyectil:init(x, y, mouse_x, mouse_y)
    self.x = x
    self.y = y
    self.velocidad = 500
    self.radio = 2

    local dx = mouse_x - x
    local dy = mouse_y - y
    local distancia = math.sqrt(dx * dx + dy * dy)

    if distancia > 0 then
        self.dx = dx / distancia
        self.dy = dy / distancia
    else
        self.dx = 0
        self.dy = 0
    end
end

function Proyectil:Actualizar(dt)
    self.x = self.x + self.dx * self.velocidad * dt
    self.y = self.y + self.dy * self.velocidad * dt
end

function Proyectil:Dibujar()
    love.graphics.circle("fill", self.x, self.y, self.radio)
end

return Proyectil