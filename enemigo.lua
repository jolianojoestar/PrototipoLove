-- Enemigo hereda todo de Jugador
Enemigo = Class{__includes = Jugador}

function Enemigo:init(x, y, img, v, mundo)
    Jugador.init(self, x, y, img, v, mundo)
    self.es_enemigo = true
    self.hilo = nil
end

-- =================== FÁBRICA DE ENEMIGOS ===================
-- Esta función encapsula la creación y sus comportamientos según el tipo
-- =================== FÁBRICA DE ENEMIGOS ===================
function Enemigo.crear(tipo, x, y, mundo)
    local sprite, velocidad, comportamiento

    if tipo == "samurai" then
        sprite = "assets/Samurai.png"
        velocidad = 25
        comportamiento = function(self, dt, jugador)
            while true do
                -- Guardamos dónde empieza a patrullar en este ciclo
                local inicio_patrulla = self.x

                -- 1. Patrullar a la derecha durante 2 segundos
                local tiempo = 0
                while tiempo < 4 do
                    dt = coroutine.yield() or dt
                    self.x = self.x + self.velocidad * dt
                    tiempo = tiempo + dt
                end

                -- Pausa quieto
                tiempo = 0
                while tiempo < 1 do
                    dt = coroutine.yield() or dt
                    tiempo = tiempo + dt
                end

                -- 2. Patrullar de regreso a la izquierda (pasando por su origen)
                tiempo = 0
                while tiempo < 4 do -- Damos más tiempo para que camine hacia la izquierda
                    dt = coroutine.yield() or dt
                    self.x = self.x - self.velocidad * dt
                    tiempo = tiempo + dt
                end

                -- Pausa quieto
                tiempo = 0
                while tiempo < 1 do
                    dt = coroutine.yield() or dt
                    tiempo = tiempo + dt
                end

                -- 3. Persecución al jugador durante 3 segundos
                tiempo = 0
                while tiempo < 4 do
                    dt = coroutine.yield() or dt
                    local dx = jugador.x - self.x
                    local dy = jugador.y - self.y
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist > 0 then
                        local vel_pers = 35
                        self.x = self.x + (dx / dist) * vel_pers * dt
                        self.y = self.y + (dy / dist) * vel_pers * dt
                    end
                    tiempo = tiempo + dt
                end
            end
        end

    elseif tipo == "esqueleto" then
        sprite = "assets/Esqueleto.png"
        velocidad = 10
    elseif tipo == "caballero" then
        sprite = "assets/Caballero.png"
        velocidad = 20
    end

    local ene = Enemigo(x, y, sprite, velocidad, mundo)
    if comportamiento then
        ene:setComportamiento(comportamiento)
    end
    return ene
end

function Enemigo:setComportamiento(func)
    self.hilo = coroutine.create(function(dt, jugador)
        func(self, dt, jugador)
    end)
end

function Enemigo:Actualizar(jugador, a, dt)
    if self.hilo then
        local estado = coroutine.status(self.hilo)
        if estado == "suspended" then
            -- Pasamos el dt actual directamente al hilo para que la velocidad sea estable
            coroutine.resume(self.hilo, dt, jugador)
        elseif estado == "dead" then
            self.hilo = nil
        end
    else
        self:seguirJugador(jugador, a, dt)
    end

    self.hitbox_x = self.x - (self.ancho/2)
    self.hitbox_y = self.y - (self.alto/2)
    self.mundo:update(self, self.hitbox_x, self.hitbox_y, self.ancho, self.alto)
end

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

function Enemigo:Destruir()
    if self.mundo and self.mundo:hasItem(self) then self.mundo:remove(self) end
end

return Enemigo