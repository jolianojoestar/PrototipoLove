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

local jugador = Jugador:Nuevo(
    100,
    400,
    "assets/Gandalf.png",
    150
)

local enemigo1 = Enemigo:Nuevo(
    400,
    150,
    "assets/Samurai.png",
    4
)

local enemigo2 = Enemigo:Nuevo(
    130,
    72,
    "assets/Esqueleto.png",
    8
)

local enemigo3 = Enemigo:Nuevo(
    30,
    72,
    "assets/Caballero.png",
    12
)


-- =================== COLISION ===================

local function hayColision(
    x1, y1, ancho1, alto1,
    x2, y2, ancho2, alto2
)

    return x1 < x2 + ancho2
       and x2 < x1 + ancho1
       and y1 < y2 + alto2
       and y2 < y1 + alto1

end


local function colisionaJugadorEnemigo(jugador, enemigo)

    return hayColision(
        jugador.x,
        jugador.y,
        jugador.ancho,
        jugador.alto,

        enemigo.hitbox_x,
        enemigo.hitbox_y,
        enemigo.ancho,
        enemigo.alto
    )

end

function love.load()
    print("EL JUEGO ARRANCO")
end
-- =================== ACTUALIZAR ===================

function love.update(dt)

    -- JUGADOR
    jugador:Actualizar(dt)


    -- ENEMIGOS
    enemigo1:Actualizar(jugador.x,jugador.y,100,dt)

    enemigo2:Actualizar(jugador.x,jugador.y,100,dt)

    enemigo3:Actualizar(jugador.x,jugador.y,100,dt)


    -- COLISIONES
    -- Activar bandera si hay contacto con cualquier enemigo
    hay_colision_debug = colisionaJugadorEnemigo(jugador, enemigo1)
                      or colisionaJugadorEnemigo(jugador, enemigo2)
                      or colisionaJugadorEnemigo(jugador, enemigo3)
    if colisionaJugadorEnemigo(jugador, enemigo1) then
        print("COLISION CON SAMURAI")
    else
        print("NO HAY COLISION CON SAMURAI")
    end

    if colisionaJugadorEnemigo(jugador, enemigo2) then
        print("COLISION CON ESQUELETO")
    else
        print("NO HAY COLISION CON ESQUELETO")
    end

    if colisionaJugadorEnemigo(jugador, enemigo3) then
        print("COLISION CON CABALLERO")
    else
        print("NO HAY COLISION CON CABALLERO")
    end

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
