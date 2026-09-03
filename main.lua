-- =================== CARGAR CLASES ===================

local Jugador = require("jugador")
local Enemigo = require("enemigo")
local hay_colision_debug = false

-- =================== INSTANCIAS ===================
local function dibujarIndicadorVerde()
    local tamano = 20
    local margen = 10
    local ancho_pantalla = love.graphics.getWidth()
    local alto_pantalla = love.graphics.getHeight()

    love.graphics.setColor(0, 1, 0, 1) -- Verde puro
    love.graphics.rectangle(
        "fill",
        ancho_pantalla - tamano - margen,
        alto_pantalla - tamano - margen,
        tamano,
        tamano
    )
    love.graphics.setColor(1, 1, 1, 1) -- Restaurar color
end

local jugador = Jugador:Nuevo(100,400,"assets/Gandalf.png",150)

local enemigo1 = Enemigo:Nuevo(400,150,"assets/Samurai.png",40)

local enemigo2 = Enemigo:Nuevo(130,72,"assets/Esqueleto.png",10)

local enemigo3 = Enemigo:Nuevo(30,72,"assets/Caballero.png",30)


-- =================== COLISION ===================

local function hayColision(x1, y1, ancho1, alto1, x2, y2,ancho2,alto2)

    return  x1<x2+ancho2    and
            x2<x1+ancho1    and
            y1<y2+alto2     and
            y2<y1+alto1

end


local function colisionaJugadorEnemigo(jugador, enemigo)

    -- Si el jugador tiene origen centrado, su esquina superior izquierda es:
    local jugador_x = jugador.x - (jugador.origen_x or 0)
    local jugador_y = jugador.y - (jugador.origen_y or 0)

    -- Para el enemigo usamos sus coordenadas de hitbox calculadas
    local enemigo_x = enemigo.hitbox_x or (enemigo.x - (enemigo.origen_x or 0))
    local enemigo_y = enemigo.hitbox_y or (enemigo.y - (enemigo.origen_y or 0))

    return hayColision(
        jugador_x,
        jugador_y,
        jugador.ancho,
        jugador.alto,

        enemigo_x,
        enemigo_y,
        enemigo.ancho,
        enemigo.alto
    )

end

function love.load()
    
end
-- =================== ACTUALIZAR ===================

function love.update(dt)

    -- JUGADOR
    jugador:Actualizar(dt)

    -- Enemigos y ahora tiene seguir 
    enemigo1:Actualizar(jugador, 125, dt)
    enemigo2:Actualizar(jugador, 125, dt)
    enemigo3:Actualizar(jugador, 120, dt)

    -- COLISIONES
    -- Activar bandera si hay contacto con cualquier enemigo
    hay_colision_debug = colisionaJugadorEnemigo(jugador, enemigo1)
                      or colisionaJugadorEnemigo(jugador, enemigo2)
                      or colisionaJugadorEnemigo(jugador, enemigo3)
end


-- =================== DIBUJAR ===================

function love.draw()
    -- Dibujado de entidades y debug existente...
    love.graphics.setColor(1, 1, 1)
    jugador:Dibujar()
    enemigo1:Dibujar()
    enemigo2:Dibujar()
    enemigo3:Dibujar()

    love.graphics.setColor(1, 0, 0)
    jugador:Debug()
    enemigo1:Debug()
    enemigo2:Debug()
    enemigo3:Debug()

    -- Indicador de colisión en pantalla
    if hay_colision_debug then
        dibujarIndicadorVerde()
    end

    love.graphics.setColor(1, 1, 1)
end
