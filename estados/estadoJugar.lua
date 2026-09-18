ventana = {
    ancho = 320,
    alto = 240,
    escala = 2
}

-- =================== CLASE ESTADO JUGAR ===================
EstadoJugar = Class{__includes = Estado}

function EstadoJugar:init()
    mundo = nil
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest", "nearest")
    mundo = Bump.newWorld(16)
    lienzo  = love.graphics.newCanvas(ventana.ancho, ventana.alto)
    
    mapa = nil
    camara_principal = nil
    mapa = STI("mapa/Mapa_nuevo.lua")
    camara_principal = Camara()

    -- 1. CARGAR COLISIONES DESDE TILED AL MUNDO DE BUMP
    if mapa.layers["Paredes"] then
        for _, obj in ipairs(mapa.layers["Colisiones"].objects) do
            obj.es_pared = true
            mundo:add(obj, obj.x, obj.y, obj.width, obj.height)
        end
    end

    -- Si la capa "Deco" tiene objetos físicos que deben bloquear al jugador:
    if mapa.layers["Deco"] then
        for _, obj in ipairs(mapa.layers["Colisiones"].objects) do
            obj.es_pared = true -- Al marcarlo como true, el jugador rebotará o chocará contra ellos
            mundo:add(obj, obj.x, obj.y, obj.width, obj.height)
        end
    end

    -- Banderas y datos
    self.victoria = false
    self.derrota = false
    self.depurar = true
    self.enemigos_derrotados = 0
    self.clickSFX = love.audio.newSource("assets/jump.mp3", "static")

    -- ACTORES DE JUEGO
    self.jugador = Jugador(50, 50, "assets/Gandalf.png", 150, mundo)
    self.proyectiles = {}

    -- Añadimos enemigos
    self.lista_enemigos = {
    { x = math.random(50, 600), y = math.random(50, 300), sprite = "assets/Samurai.png",   vel = 40 },
    { x = math.random(50, 600), y = math.random(50, 300), sprite = "assets/Esqueleto.png", vel = 10 },
    { x = math.random(50, 600), y = math.random(50, 300), sprite = "assets/Caballero.png", vel = 30 }
    }
    
    self.enemigos = {}
    for _, datos in ipairs(self.lista_enemigos) do
        table.insert(self.enemigos, Enemigo(datos.x, datos.y, datos.sprite, datos.vel, mundo))
    end

    -- Animación
    self.ataque = Animacion.Crear("assets/power.png", 3, 16, 16, 6, false)
    self.ataque.activado = false
    self.ataque.spritehseet:setFilter("nearest", "nearest")
end

function EstadoJugar:ingresar()
    self.victoria = false
    self.derrota = false
end

function EstadoJugar:salir() end

function EstadoJugar:mousepressed(x, y, button)
    if self.victoria or self.derrota then return end

    --- Tenia un desfase enorme en los tiros y la direccion el mouse entonces pedi ayuda con ia
    if button == 1 and not self.ataque.activado then
        -- 1. Convertimos las coordenadas físicas de la ventana a coordenadas del canvas virtual
        local canvas_x = x / ventana.escala
        local canvas_y = y / ventana.escala

        -- 2. Calculamos el centro de tu pantalla virtual (donde siempre está el jugador/cámara)
        local centro_pantalla_x = ventana.ancho / 2
        local centro_pantalla_y = ventana.alto / 2

        -- 3. Obtenemos la posición del mundo sumando la posición de la cámara al desplazamiento del mouse desde el centro
        local world_x = camara_principal.x + (canvas_x - centro_pantalla_x)
        local world_y = camara_principal.y + (canvas_y - centro_pantalla_y)

        -- 4. Creamos el proyectil apuntando exactamente a esas coordenadas del mundo
        local proyectil = Proyectil(self.jugador.x, self.jugador.y, world_x, world_y, mundo)
        table.insert(self.proyectiles, proyectil)
        
        self.clickSFX:play()
        self.ataque.activado = true
        self.ataque.indice = 1
    end
end

function EstadoJugar:keypressed(key)
    if key == "f1" then
        self.depurar = not self.depurar
    end
end

function EstadoJugar:actualizar(dt)
    if self.victoria or self.derrota then return end

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

        local hitboxes, cantidad = mundo:queryRect(proy.x - proy.radio, proy.y - proy.radio, proy.ancho, proy.alto)
        local impacto = false

        for j = 1, cantidad do
            local objeto = hitboxes[j]
            if objeto.es_enemigo then
                impacto = true

                for e_idx, ene in ipairs(self.enemigos) do
                    if ene == objeto then
                        ene:Destruir()
                        table.remove(self.enemigos, e_idx)
                        self.enemigos_derrotados = self.enemigos_derrotados + 1
                        break
                    end
                end

                if self.enemigos_derrotados >= 3 then
                    self.victoria = true
                end
                break
            end
        end

        if impacto then
            proy:Destruir()
            table.remove(self.proyectiles, i)
        end
    end

    -- Colisión Jugador vs Enemigos / Paredes
    if self.jugador:Colision() then
        self.derrota = true
    end
end

function EstadoJugar:dibujar()
    love.graphics.setCanvas(lienzo)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)
    
    camara_principal:attach(0, 0, ventana.ancho, ventana.alto)
    
    -- Capas del mapa ordenadas visualmente
    if mapa.layers["Piso"] then
        mapa:drawLayer(mapa.layers["Piso"])
    end
    if mapa.layers["Deco"] then
        mapa:drawLayer(mapa.layers["Deco"])
    end

    self.jugador:Dibujar()

    for i = 1, #self.enemigos do
        self.enemigos[i]:Dibujar()
    end
    
    for i = 1, #self.proyectiles do
        self.proyectiles[i]:Dibujar()
    end

    -- Capa superior de decoración que va por encima de los personajes ("Encima")
    if mapa.layers["Encima"] then
        mapa:drawLayer(mapa.layers["Encima"])
    end

    if self.ataque.activado then
        Animacion.Dibujar(
            self.ataque,
            self.jugador.x,
            self.jugador.y, 1, 1,
            self.jugador.ancho / 2,
            self.jugador.alto / 2
        )
    end

    -- =================== DEPURACIÓN DENTRO DE LA CÁMARA ===================
    if self.depurar then
        love.graphics.setColor(1, 1, 1)
        
        if self.jugador.Debug then
            self.jugador:Debug()
        end
        
        for i = 1, #self.enemigos do
            if self.enemigos[i].Debug then
                self.enemigos[i]:Debug()
            end
        end

        -- Dibuja todos los elementos registrados en Bump (Paredes y objetos de Deco)
        if mundo then
            local items = mundo:getItems()
            for _, item in ipairs(items) do
                local x, y, ancho, alto = mundo:getRect(item)
                love.graphics.rectangle("line", x, y, ancho, alto)
            end
        end
        love.graphics.setColor(1, 1, 1)
    end
    -- ======================================================================

    camara_principal:detach()

    -- Textos de interfaz fijos en pantalla
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Enemigos derrotados: " .. self.enemigos_derrotados, 10, 10)
    
    if self.depurar then
        love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 25)
    end

    if self.victoria then
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("¡GANASTE!", ventana.ancho/2 - 50,ventana.alto/2)
    elseif self.derrota then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("¡YA PERDISTE!!", ventana.ancho/2 - 50,ventana.alto/2)
    end

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(lienzo, 0, 0, 0, ventana.escala, ventana.escala)
end

return EstadoJugar