-- Enemigo hereda todo de Jugador
Enemigo = Class{__includes = Jugador}

-- =================== CONSTRUCTOR ===================

function Enemigo:init(x, y, img, v, mundo)
    -- Pasamos todos los parámetros en orden correcto a Jugador (incluyendo img, v y mundo)
    Jugador.init(self, x, y, img, v, mundo)
    
    self.es_enemigo = true
end
-- =================== ACTUALIZAR ===================

function Enemigo:Actualizar(jugador, a, dt)
    self:seguirJugador(jugador, a, dt)
    self.hitbox_x = self.x - (self.ancho/2)
    self.hitbox_y = self.y - (self.alto/2)
    self.mundo:update(self, self.hitbox_x, self.hitbox_y, self.ancho, self.alto)
end

-- =================== SEGUIMIENTO ===================

function Enemigo:seguirJugador(jugador, a, dt)
    local dx = jugador.x - self.x
    local dy = jugador.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > a and distance > 0 then
        dx = dx / distance
        dy = dy / distance

        self.x = self.x + dx * self.velocidad * dt
        self.y = self.y + dy * self.velocidad * dt
    end
end

return Enemigo