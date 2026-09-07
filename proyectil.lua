Proyectil = {}
Proyectil.__index = Proyectil

-- =================== CONSTRUCTOR ===================
function Proyectil:Nuevo(x, y, mouse_x, mouse_y)

    local o = setmetatable({}, Proyectil)

    o.x = x
    o.y = y

    o.velocidad = 500
    o.radio = 8

    -- Dirección hacia el mouse
    local dx = mouse_x - x
    local dy = mouse_y - y

    local distancia = math.sqrt(dx * dx + dy * dy)

    -- Normalizamos la dirección
    if distancia > 0 then
        o.dx = dx / distancia
        o.dy = dy / distancia
    else
        o.dx = 0
        o.dy = 0
    end

    return o

end

-- =================== ACTUALIZAR ===================
function Proyectil:Actualizar(dt)

    self.x = self.x + self.dx * self.velocidad * dt
    self.y = self.y + self.dy * self.velocidad * dt

end

-- =================== DIBUJAR ===================

function Proyectil:Dibujar()
    love.graphics.circle("fill",self.x,self.y,self.radio)
end

return Proyectil