-- =================== CARGAR CLASES ===================

local Jugador = require("jugador")
local Enemigo = require("enemigo")


-- =================== INSTANCIAS ===================

local jugador = Jugador:Nuevo(
    100,
    400,
    "img/ataque/frame1.png",
    150
)

local enemigo1 = Enemigo:Nuevo(
    400,
    150,
    "img/Samurai.png",
    4
)

local enemigo2 = Enemigo:Nuevo(
    130,
    72,
    "img/Esqueleto.png",
    8
)

local enemigo3 = Enemigo:Nuevo(
    30,
    72,
    "img/Caballero.png",
    12
)


-- =================== COLISION ===================

function hayColision(
    x1, y1, ancho1, alto1,
    x2, y2, ancho2, alto2
)

    return x1 < x2 + ancho2
       and x2 < x1 + ancho1
       and y1 < y2 + alto2
       and y2 < y1 + alto1

end


function colisionaJugadorEnemigo(jugador, enemigo)

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


-- =================== ACTUALIZAR ===================

function love.update(dt)

    -- JUGADOR
    jugador:Actualizar(dt)


    -- ENEMIGOS
    enemigo1:Actualizar(
        jugador.x,
        jugador.y,
        100,
        dt
    )

    enemigo2:Actualizar(
        jugador.x,
        jugador.y,
        100,
        dt
    )

    enemigo3:Actualizar(
        jugador.x,
        jugador.y,
        100,
        dt
    )


    -- COLISIONES

    if colisionaJugadorEnemigo(jugador, enemigo1) then
        print("COLISION CON SAMURAI")
    end

    if colisionaJugadorEnemigo(jugador, enemigo2) then
        print("COLISION CON ESQUELETO")
    end

    if colisionaJugadorEnemigo(jugador, enemigo3) then
        print("COLISION CON CABALLERO")
    end

end


-- =================== DIBUJAR ===================

function love.draw()

    -- SPRITES

    love.graphics.setColor(1, 1, 1)

    jugador:Dibujar()

    enemigo1:Dibujar()
    enemigo2:Dibujar()
    enemigo3:Dibujar()


    -- DEBUG

    love.graphics.setColor(1, 0, 0)

    jugador:Debug()

    enemigo1:Debug()
    enemigo2:Debug()
    enemigo3:Debug()


    -- VOLVER A BLANCO

    love.graphics.setColor(1, 1, 1)

end