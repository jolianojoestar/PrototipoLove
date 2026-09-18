-- =================== FUNCIONES AUXILIARES DE COLISIÓN ===================

local function hayColision(x1, y1, ancho1, alto1, x2, y2, ancho2, alto2)
    return x1 < x2 + ancho2 and
           x2 < x1 + ancho1 and
           y1 < y2 + alto2  and
           y2 < y1 + alto1
end

local function colisionaJugadorEnemigo(jugador, enemigo)
    local jugador_x = jugador.x - (jugador.origen_x or 0)
    local jugador_y = jugador.y - (jugador.origen_y or 0)

    local enemigo_x = enemigo.hitbox_x or (enemigo.x - (enemigo.origen_x or 0))
    local enemigo_y = enemigo.hitbox_y or (enemigo.y - (enemigo.origen_y or 0))

    return hayColision(
        jugador_x, jugador_y, jugador.ancho, jugador.alto,
        enemigo_x, enemigo_y, enemigo.ancho, enemigo.alto
    )
end

local function colisionProyectilEnemigo(proyectil, enemigo)
    local proyectil_x = proyectil.x - proyectil.radio
    local proyectil_y = proyectil.y - proyectil.radio
    local proyectil_ancho = proyectil.radio * 2
    local proyectil_alto = proyectil.radio * 2

    local enemigo_x = enemigo.hitbox_x or (enemigo.x - (enemigo.origen_x or 0))
    local enemigo_y = enemigo.hitbox_y or (enemigo.y - (enemigo.origen_y or 0))

    return hayColision(
        proyectil_x, proyectil_y, proyectil_ancho, proyectil_alto,
        enemigo_x, enemigo_y, enemigo.ancho, enemigo.alto
    )
end
ventana = {
        ancho  = 320,  -- O prueba con 160
        alto   = 240,  -- O prueba con 144
        escala = 2     -- Escala para que la ventana física sea más grande (ej: 640x480)
    }
-- =================== CLASE ESTADO JUGAR ===================
EstadoJugar = Class{__includes = Estado}

function EstadoJugar:init()
    mundo = nil
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest", "nearest")
    mundo = Bump.newWorld(16)
    lienzo  = love.graphics.newCanvas(ventana.ancho,ventana.alto)

    self.enemigos_derrotados = 0
    self.victoria = false
    self.derrota = false
    self.clickSFX = love.audio.newSource("assets/jump.mp3", "static")
    mapa = nil
    camara_principal = nil
    -- Entidades de la partida
    self.jugador = Jugador(50, 50, "assets/Gandalf.png", 150, mundo)    self.proyectiles = {}
    self.lista_enemigos = {
    { x = 500, y = 300, sprite = "assets/Samurai.png",   vel = 40 },
    { x = 550, y = 100, sprite = "assets/Esqueleto.png", vel = 10 },
    { x = 600, y = 250, sprite = "assets/Caballero.png", vel = 30 }
    }
    self.enemigos = {}
    for _, datos in ipairs(self.lista_enemigos) do
    -- Agregamos datos.vel en el cuarto lugar
    table.insert(self.enemigos, Enemigo(datos.x, datos.y, datos.sprite, datos.vel, mundo))
    end

    mapa = STI("mapa/mapa.lua")
    camara_principal = Camara()

    self.ataque = Animacion.Crear("assets/power.png", 3, 32, 32, 6, false)
    self.ataque.activado = false
    self.ataque.spritehseet:setFilter("nearest", "nearest")
end

-- Se ejecuta cada vez que el juego pasa a este estado (permite reiniciar la partida limpia)
function EstadoJugar:ingresar()
    self.victoria = false
    self.derrota = false
end

function EstadoJugar:salir() end

-- Manejador de clics delegado desde main.lua
function EstadoJugar:mousepressed(x, y, button)
    if self.victoria or self.derrota then return end

    if button == 1 and not self.ataque.activado then
        proyectil = Proyectil(self.jugador.x, self.jugador.y, x, y)
        table.insert(self.proyectiles, proyectil)
        self.clickSFX:play()
        self.ataque.activado = true
        self.ataque.indice = 1
    end
end

function EstadoJugar:actualizar(dt)
    if self.victoria or self.derrota then return
    end

    self.jugador:Actualizar(dt)
    camara_principal:lookAt(redondear(self.jugador.x), redondear(self.jugador.y))
    if self.ataque.activado then
        Animacion.Actualizar(self.ataque, dt, true)
    end

    local mapa_ancho = mapa.width * mapa.tilewidth
    local mapa_alto  = mapa.height * mapa.tileheight
    if camara_principal.x < ventana.ancho * 0.5 then camara_principal.x = ventana.ancho * 0.5 end
    if camara_principal.y < ventana.alto * 0.5 then camara_principal.y = ventana.alto * 0.5 end
    if camara_principal.x > (mapa_ancho - ventana.ancho * 0.5) then camara_principal.x = (mapa_ancho - ventana.ancho * 0.5) end
    if camara_principal.y > (mapa_alto - ventana.alto * 0.5) then camara_principal.y = (mapa_alto - ventana.alto * 0.5) end
    -- Enemigos
    for i = #self.enemigos, 1, -1 do
        self.enemigos[i]:Actualizar(self.jugador, 12, dt)
    end

    -- Proyectiles
    for i = #self.proyectiles, 1, -1 do
        local proy = self.proyectiles[i]
        proy:Actualizar(dt)

        for j = #self.enemigos, 1, -1 do
            local ene = self.enemigos[j]
            if colisionProyectilEnemigo(proy, ene) then
                table.remove(self.enemigos, j)
                table.remove(self.proyectiles, i)
                self.enemigos_derrotados = self.enemigos_derrotados + 1

                if self.enemigos_derrotados >= 3 then
                    self.victoria = true
                    -- Si tienes máquina de estados: maquina_estados:cambiar("victoria")
                end
                break
            end
        end
    end

    -- Colisión Jugador vs Enemigos
    for i = 1, #self.enemigos do
        if colisionaJugadorEnemigo(self.jugador, self.enemigos[i]) then
            self.derrota = true
            maquina_estados:cambiar("derrota")  -- Cambia al estado de derrota
            -- Si tienes máquina de estados: maquina_estados:cambiar("derrota")
            break
        end
    end
end

function EstadoJugar:dibujar()
    -- 1. Activamos nuestro lienzo virtual
    love.graphics.setCanvas(lienzo)
    love.graphics.clear() -- Limpiamos el lienzo de frame a frame
    love.graphics.setColor(1, 1, 1)
    
    camara_principal:attach(0,0,ventana.ancho,ventana.alto)
    if mapa.layers["Piso"] then
        mapa:drawLayer(mapa.layers["Piso"])
    end
    if mapa.layers["Deco"] then
        mapa:drawLayer(mapa.layers["Deco"])
    end
    self.jugador:Dibujar()

    for i = 1, #self.enemigos do
        self.enemigos[i]:Dibujar()
        self.enemigos[i]:Debug()
    end
    for i = 1, #self.proyectiles do
        self.proyectiles[i]:Dibujar()
    end

    self.jugador:Debug()
    if self.ataque.activado then
        Animacion.Dibujar(
            self.ataque,
            self.jugador.x,
            self.jugador.y,1,1,self.jugador.ancho/2,self.jugador.alto/2

        )
    end
    camara_principal:detach()
    -- Textos provisionales de estado (dentro del canvas si quieres que escalen con el pixel art)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Enemigos derrotados: " .. self.enemigos_derrotados, 10, 10)
    if self.victoria then
        love.graphics.setColor(0, 1, 0)
        -- Nota: Ajusta estas coordenadas si salían muy afuera de tu resolución virtual de 160x144
        love.graphics.print("¡GANASTEEE!", 50, 60)
    elseif self.derrota then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("¡YA PERDISTEE!!", 50, 60)
    end
    -- 2. IMPORTANTE: Desactivamos el lienzo para volver al canvas principal de la ventana
    love.graphics.setCanvas()

    -- 3. Dibujamos el lienzo escalado en la ventana real
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(lienzo, 0, 0, 0, ventana.escala, ventana.escala)
end

return EstadoJugar
