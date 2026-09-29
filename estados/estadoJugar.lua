ventana = {
    ancho = 320,
    alto = 240,
    escala = 4
}
-- =================== CLASE ESTADO JUGAR ===================
EstadoJugar = Class{__includes = Estado}

function EstadoJugar:init()

    self.mundo = nil
    self.lienzo = nil
    self.mapa = nil
    self.camara_principal = nil
    self.hud = nil

    love.window.setMode(
        ventana.ancho * ventana.escala,
        ventana.alto * ventana.escala
    )

    love.graphics.setDefaultFilter("nearest", "nearest")

    self.mundo = Bump.newWorld(16)

    self.lienzo = love.graphics.newCanvas(
        ventana.ancho,
        ventana.alto
    )

    self.mapa = STI("mapa/Mapa_nuevo.lua")

    self.camara_principal = Camara()

    self.hud = HUD()

    -- =========================
    -- CARGAR COLISIONES DESDE TILED
    -- =========================

    if self.mapa.layers["Paredes"] then

        for _, obj in ipairs(self.mapa.layers["Colisiones"].objects) do

            obj.es_pared = true

            self.mundo:add(
                obj,
                obj.x,
                obj.y,
                obj.width,
                obj.height
            )

        end

    end

    -- Si Deco contiene objetos que bloquean al jugador
    if self.mapa.layers["Deco"] then

        for _, obj in ipairs(self.mapa.layers["Colisiones"].objects) do

            obj.es_pared = true

            self.mundo:add(
                obj,
                obj.x,
                obj.y,
                obj.width,
                obj.height
            )

        end

    end

    -- =========================
    -- BANDERAS Y DATOS
    -- =========================

    self.victoria = false
    self.derrota = false
    self.depurar = false
    self.enemigos_derrotados = 0

    self.clickSFX = love.audio.newSource(
        "assets/jump.mp3",
        "static"
    )

    -- =========================
    -- SIGNALS
    -- =========================

    Signal.register("modoDebug", function()
        self.depurar = not self.depurar
    end)

    -- =========================
    -- ACTORES DE JUEGO
    -- =========================

    self.jugador = Jugador(
        50,
        50,
        "assets/Gandalf.png",
        150,
        self.mundo
    )

    self.proyectiles = {}

    -- =========================
    -- ENEMIGOS
    -- =========================

    self.lista_enemigos = {
        {
            x = math.random(50, 600),
            y = math.random(50, 300),
            sprite = "assets/Samurai.png",
            vel = 40
        },

        {
            x = math.random(50, 600),
            y = math.random(50, 300),
            sprite = "assets/Esqueleto.png",
            vel = 10
        },

        {
            x = math.random(50, 600),
            y = math.random(50, 300),
            sprite = "assets/Caballero.png",
            vel = 30
        }
    }

    self.enemigos = {}

    for _, datos in ipairs(self.lista_enemigos) do

        table.insert(
            self.enemigos,
            Enemigo(
                datos.x,
                datos.y,
                datos.sprite,
                datos.vel,
                self.mundo
            )
        )

    end

    -- =========================
    -- ANIMACION
    -- =========================

    self.ataque = Animacion.Crear(
        "assets/Power.png",
        3,
        16,
        16,
        6,
        false
    )

    self.ataque.activado = false

    self.ataque.spritehseet:setFilter(
        "nearest",
        "nearest"
    )

end

function EstadoJugar:ingresar()
    self.victoria = false
    self.derrota = false
end

function EstadoJugar:salir() end

function EstadoJugar:mousepressed(x, y, button)

    if self.victoria or self.derrota then
        return
    end

    if button == 1 and not self.ataque.activado then

        -- Coordenadas físicas → coordenadas del canvas virtual
        local canvas_x = x / ventana.escala
        local canvas_y = y / ventana.escala

        -- Centro de la pantalla virtual
        local centro_pantalla_x = ventana.ancho / 2
        local centro_pantalla_y = ventana.alto / 2

        -- Coordenadas del mundo
        local world_x =
            self.camara_principal.x +
            (canvas_x - centro_pantalla_x)

        local world_y =
            self.camara_principal.y +
            (canvas_y - centro_pantalla_y)

        -- Crear proyectil
        local proyectil = Proyectil(
            self.jugador.x,
            self.jugador.y,
            world_x,
            world_y,
            self.mundo
        )

        table.insert(
            self.proyectiles,
            proyectil
        )

        self.clickSFX:play()

        self.ataque.activado = true
        self.ataque.indice = 1

    end

end

function EstadoJugar:actualizar(dt)

    if self.victoria or self.derrota then
        return
    end

    -- =========================
    -- JUGADOR
    -- =========================

    self.jugador:Actualizar(dt)

    self.camara_principal:lookAt(
        redondear(self.jugador.x),
        redondear(self.jugador.y)
    )

    -- =========================
    -- ANIMACION
    -- =========================

    Animacion.Actualizar(
        self.ataque,
        dt,
        true
    )

    -- =========================
    -- LIMITES DE CAMARA
    -- =========================

    local mapa_ancho =
        self.mapa.width * self.mapa.tilewidth

    local mapa_alto =
        self.mapa.height * self.mapa.tileheight

    if self.camara_principal.x < ventana.ancho * 0.5 then
        self.camara_principal.x = ventana.ancho * 0.5
    end

    if self.camara_principal.y < ventana.alto * 0.5 then
        self.camara_principal.y = ventana.alto * 0.5
    end

    if self.camara_principal.x >
        (mapa_ancho - ventana.ancho * 0.5) then

        self.camara_principal.x =
            mapa_ancho - ventana.ancho * 0.5

    end

    if self.camara_principal.y >
        (mapa_alto - ventana.alto * 0.5) then

        self.camara_principal.y =
            mapa_alto - ventana.alto * 0.5

    end
    -- =========================
    -- ENEMIGOS
    -- =========================
    for i = #self.enemigos, 1, -1 do

        self.enemigos[i]:Actualizar(
            self.jugador,
            12,
            dt
        )

    end
    -- =========================
    -- PROYECTILES
    -- =========================
    for i = #self.proyectiles, 1, -1 do

        local proy = self.proyectiles[i]
        proy:Actualizar(dt)
        local hitboxes, cantidad =
            self.mundo:queryRect(
                proy.x - proy.radio,
                proy.y - proy.radio,
                proy.ancho,
                proy.alto
            )
        local impacto = false

        for j = 1, cantidad do
            local objeto = hitboxes[j]

            if objeto.es_enemigo then
                impacto = true

                for e_idx, ene in ipairs(self.enemigos) do
                    if ene == objeto then
                        ene:Destruir()
                        table.remove(self.enemigos,e_idx)
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
            table.remove(self.proyectiles,i)
        end
    end

    -- =========================
    -- COLISION DEL JUGADOR
    -- =========================

    if self.jugador:Colision() then
        self.derrota = true
    end

end

function EstadoJugar:dibujar()

    -- =========================
    -- CANVAS
    -- =========================

    love.graphics.setCanvas(self.lienzo)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)

    -- =========================
    -- CAMARA
    -- =========================

    self.camara_principal:attach(
        0,
        0,
        ventana.ancho,
        ventana.alto
    )

    -- =========================
    -- MAPA
    -- =========================

    if self.mapa.layers["Piso"] then
        self.mapa:drawLayer(
            self.mapa.layers["Piso"]
        )
    end

    if self.mapa.layers["Deco"] then
        self.mapa:drawLayer(
            self.mapa.layers["Deco"]
        )
    end

    -- =========================
    -- JUGADOR
    -- =========================

    self.jugador:Dibujar()

    -- =========================
    -- ENEMIGOS
    -- =========================

    for i = 1, #self.enemigos do
        self.enemigos[i]:Dibujar()
    end

    -- =========================
    -- PROYECTILES
    -- =========================

    for i = 1, #self.proyectiles do
        self.proyectiles[i]:Dibujar()
    end

    -- =========================
    -- CAPA ENCIMA
    -- =========================

    if self.mapa.layers["Encima"] then
        self.mapa:drawLayer(
            self.mapa.layers["Encima"]
        )
    end

    -- =========================
    -- ANIMACION DE ATAQUE
    -- =========================

    Animacion.Dibujar(
        self.ataque,
        self.jugador.x,
        self.jugador.y,
        self.jugador.ancho / 16,
        self.jugador.alto / 16,
        8,
        8
    )

    -- =========================
    -- DEBUG
    -- =========================

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

        local items = self.mundo:getItems()

        for _, item in ipairs(items) do

            local x, y, ancho, alto =
                self.mundo:getRect(item)

            love.graphics.rectangle(
                "line",
                x,
                y,
                ancho,
                alto
            )

        end

        love.graphics.setColor(1, 1, 1)

    end

    -- =========================
    -- FIN DE LA CAMARA
    -- =========================

    self.camara_principal:detach()

    -- =========================
    -- MOSTRAR CANVAS
    -- =========================

    love.graphics.setCanvas()

    love.graphics.setColor(1, 1, 1)

    love.graphics.draw(
        self.lienzo,
        0,
        0,
        0,
        ventana.escala,
        ventana.escala
    )

    -- =========================
    -- HUD FIJO
    -- =========================

    self.hud:Draw()
    self.hud:DrawGameData()

end

return EstadoJugar