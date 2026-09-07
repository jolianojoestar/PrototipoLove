-- =================== CARGAR CLASES ===================

local Jugador = require("jugador")
local Enemigo = require("enemigo")
local Proyectil = require("proyectil")
local hay_colision_debug = false
local enemigos_derrotados = 0
local mouse = {CARGAR=false, x=0, y=0}

-- Esto es para hacer el debug
local function dibujarIndicadorVerde()
    local tamano = 20
    local margen = 10
    local ancho_pantalla = love.graphics.getWidth()
    local alto_pantalla = love.graphics.getHeight()

    love.graphics.setColor(0, 1, 0, 1) -- Verde
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
local enemigos = {enemigo1,enemigo2,enemigo3}
local proyectiles = {}

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
local function colisionProyectilEnemigo(proyectil, enemigo)

    -- Para el proyectil usamos su posición y radio
    local proyectil_x = proyectil.x - proyectil.radio
    local proyectil_y = proyectil.y - proyectil.radio
    local proyectil_ancho = proyectil.radio * 2
    local proyectil_alto = proyectil.radio * 2

    -- Para el enemigo usamos sus coordenadas de hitbox calculadas
    local enemigo_x = enemigo.hitbox_x or (enemigo.x - (enemigo.origen_x or 0))
    local enemigo_y = enemigo.hitbox_y or (enemigo.y - (enemigo.origen_y or 0))

    return hayColision(
        proyectil_x,
        proyectil_y,
        proyectil_ancho,
        proyectil_alto,

        enemigo_x,
        enemigo_y,
        enemigo.ancho,
        enemigo.alto
    )

end     

-- Evento de mouse
function love.mousepressed(x, y, button)
    if button==1 then
        local proyectil = Proyectil:Nuevo(jugador.x, jugador.y, x, y)

        table.insert(proyectiles, proyectil)
    end
end
-- === nuncca esta de mas que la tenga a mano===
function love.load()
    
end
-- =================== ACTUALIZAR ===================

function love.update(dt)

    -- JUGADOR
    jugador:Actualizar(dt)

    -- Enemigos 
    for i = #enemigos, 1, -1 do
    enemigos[i]:Actualizar(jugador, 125, dt)
    end
    -- Proyectiles
    for i = #proyectiles, 1, -1 do

    local proyectil = proyectiles[i]

    proyectil:Actualizar(dt)

    -- Comprobar contra todos los enemigos
    for j = #enemigos, 1, -1 do

        local enemigo = enemigos[j]

        if colisionProyectilEnemigo(proyectil, enemigo) then

            -- Eliminar enemigo
            table.remove(enemigos, j)

            -- Eliminar proyectil
            table.remove(proyectiles, i)

            -- Sumar enemigo derrotado
            enemigos_derrotados = enemigos_derrotados + 1

            -- Salimos del bucle de enemigos porque
            -- este proyectil ya fue eliminado
            break
        end
    end
    end
    -- COLISIONES
    hay_colision_debug = false
    for i = 1, #enemigos do
        if colisionaJugadorEnemigo(jugador, enemigos[i]) then
        hay_colision_debug = true
        break
        end
    end
                      
end


-- =================== DIBUJAR ===================

function love.draw()
    -- Dibujado de entidades y debug existente...
    love.graphics.setColor(1, 1, 1)
    jugador:Dibujar()
    --Enemigos
    for i = 1, #enemigos do
    enemigos[i]:Dibujar()
    end
    --Proyectiles
    for i = 1, #proyectiles do
    proyectiles[i]:Dibujar()
    end
    
    love.graphics.setColor(1, 0, 0)
    jugador:Debug()
    for i = 1, #enemigos do
    enemigos[i]:Debug()
    end

    -- Indicador de colisión en pantalla
    if hay_colision_debug then
        dibujarIndicadorVerde()
    end
    love.graphics.print("Enemigos derrotados: " .. enemigos_derrotados, 10, 10)
    love.graphics.setColor(1, 1, 1)
    if enemigos_derrotados >= 3 then
        love.graphics.setColor(0, 1, 0) -- Rojo
        love.graphics.print("¡GANASTEEE!", 350, 300)
    end
    if hay_colision_debug then
        love.graphics.setColor(1, 0, 0) -- Rojo
        love.graphics.print("¡YA PERDISTEE!!", 350, 300)
    end
end
