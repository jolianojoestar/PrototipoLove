-- =================== CARGAR CLASES ===================

local Jugador = require("jugador")
local Enemigo = require("enemigo")
local Proyectil = require("proyectil")
local hay_colision_debug = false
local enemigos_derrotados = 0
local mouse = {CARGAR=false, x=0, y=0}
--intento carga de tabla de spritesheet ataque
ataque = {
    spritehseet = nil,
    quads = {},
    indice = 1,
    activado = false,
    velocidad_anim = 6
}

--animacion
local escalaQuad = 125 / 32
--corte
spritehseet = nil
--quad
quads = {}
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

local clickSFX = love.audio.newSource("assets/jump.mp3", "static")
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
    if button == 1 and not ataque.activado then
        local proyectil = Proyectil:Nuevo(jugador.x, jugador.y, x, y)
        table.insert(proyectiles, proyectil)
        clickSFX:play()
        ataque.activado = true
        ataque.indice = 1 -- Empieza en el primer cuadro exacto
    end
end
-- === nuncca esta de mas que la tenga a mano===
function love.load()
    --cargamos assets y taBLA
    jugador = Jugador:Nuevo(100,400,"assets/Gandalf.png",150)
    enemigo1 = Enemigo:Nuevo(400,150,"assets/Samurai.png",40)
    enemigo2 = Enemigo:Nuevo(130,72,"assets/Esqueleto.png",10)
    enemigo3 = Enemigo:Nuevo(30,72,"assets/Caballero.png",30)
    enemigos = {enemigo1,enemigo2,enemigo3}
    
    ataque.spritehseet = love.graphics.newImage("assets/power.png")


    -- Crear quads para el sprite sheet
    local ancho_quad = 32
    local alto_quad = 32
    for i = 0, 2 do
        table.insert(ataque.quads, love.graphics.newQuad(i * ancho_quad, 0, ancho_quad, alto_quad, ataque.spritehseet))
    end
    ataque.spritehseet:setFilter("nearest", "nearest") -- Evita el suavizado al escalar

    proyectiles = {}

    clickSFX = love.audio.newSource("assets/jump.mp3", "static")
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

        for j = #enemigos, 1, -1 do
            local enemigo = enemigos[j]
            if colisionProyectilEnemigo(proyectil, enemigo) then
                table.remove(enemigos, j)
                table.remove(proyectiles, i)
                enemigos_derrotados = enemigos_derrotados + 1
                break
            end
        end
    end -- FIN DEL BUCLE DE PROYECTILES

    -- Avance de la animación (independiente de si hay proyectiles o no)
    if ataque.activado then
        ataque.indice = ataque.indice + ataque.velocidad_anim * dt
        if ataque.indice >= #ataque.quads + 1 then
            ataque.activado = false
            ataque.indice = 1
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
    --Anim poder
    if ataque.activado then
        local cuadro_actual = math.floor(ataque.indice)
        if cuadro_actual >= 1 and cuadro_actual <= #ataque.quads then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(
                ataque.spritehseet,
                ataque.quads[cuadro_actual],
                jugador.x - (jugador.origen_x or 0),
                jugador.y - (jugador.origen_y or 0),
                0,
                escalaQuad,
                escalaQuad
            )
        end
    end
    end
    -- Indicador de colisión en pantalla
    if hay_colision_debug then
        dibujarIndicadorVerde()
    end
    love.graphics.print("Enemigos derrotados: " .. enemigos_derrotados, 10, 10)
    love.graphics.setColor(1, 1, 1)
    if enemigos_derrotados >= 3 then
        love.graphics.setColor(0, 1, 0) -- verde
        love.graphics.print("¡GANASTEEE!", 350, 300)
    end
    if hay_colision_debug then
        love.graphics.setColor(1, 0, 0) -- Rojo
        love.graphics.print("¡YA PERDISTEE!!", 350, 300)
    end