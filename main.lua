-- =================== DECLARACION ===================
-- Caja Jugador
Jugador = {
    x = 100,
    y = 400,
    ancho = 125,
    alto = 125,
    vel = 150,
    sprite = nil
}

-- Caja Enemigo
Enemigo = {
    x = 0,
    y = 0,
    ancho = 125,
    alto = 125,
    x_spawn = 400,
    y_spawn = 150,
    vivo = true,
    sprite = nil
}

-- Caja Proyectil
Proyectil = {
    x = 400,
    y = 400,
    ancho = 30,
    alto = 30,
    vel = 250,
    activo = false
}

-- Banderas de Estado del Juego
Juego = {
    gameover = false,
    victoria = false,
    proyectilEnemigo = false
}

-- =================== MIS FUNCIONES ===================
function hayColision(x1, y1, ancho1, alto1, x2, y2, ancho2, alto2)
    return  x1 < x2 + ancho2 and
            x2 < x1 + ancho1 and
            y1 < y2 + alto2  and
            y2 < y1 + alto1
end

-- =================== INICIALIZACION ===================
function love.load()
    Jugador.sprite = love.graphics.newImage("assets/Argentino.png")
    Enemigo.sprite = love.graphics.newImage("assets/Dracula.png")

    Enemigo.x = Enemigo.x_spawn
    Enemigo.y = Enemigo.y_spawn
end

-- =================== INTERACCION ===================
function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        Proyectil.activo = true
        Proyectil.x = Jugador.x + (Jugador.ancho / 2)
        Proyectil.y = Jugador.y
    end

    if button == 2 then
        Proyectil.activo = false
    end
end
-- =================== ACTUALIZACION ===================
function love.update(dt)

    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        Jugador.x = Jugador.x - (Jugador.vel * dt)
    end

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        Jugador.x = Jugador.x + (Jugador.vel * dt)
    end

    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        Jugador.y = Jugador.y - (Jugador.vel * dt)
    end

    if love.keyboard.isDown("down") then
         Jugador.y = Jugador.y + (Jugador.vel * dt)
    end

    Juego.gameover = hayColision(Jugador.x, Jugador.y, Jugador.ancho, Jugador.alto, Enemigo.x, Enemigo.y, Enemigo.ancho, Enemigo.alto)
    
    Juego.victoria = hayColision(Jugador.x,
                                 Jugador.y,
                                 Jugador.ancho,
                                 Jugador.alto,
                                 100,
                                 100,
                                 100,
                                 100)

    if Enemigo.vivo then
         Juego.proyectilEnemigo = hayColision(Proyectil.x,
                                              Proyectil.y,
                                              Proyectil.ancho,
                                              Proyectil.alto,
                                              Enemigo.x,
                                              Enemigo.y,
                                              Enemigo.alto,
                                              Enemigo.ancho)
    end
   
    if Juego.proyectilEnemigo then
       Enemigo.vivo = false
       Proyectil.activo = false
    end

    if Proyectil.activo then
        Proyectil.y = Proyectil.y - (Proyectil.vel * dt)
    end

    if Juego.gameover then
        Jugador.x = 700
        Jugador.y = 600
    end

    if Proyectil.y < 0 then
        Proyectil.x = Jugador.x + (Jugador.ancho / 2)
        Proyectil.y = Jugador.y
    end

end
-- =================== RENDERIZADO ===================
function love.draw()

    -- Rectángulos de debug
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("line", Jugador.x, Jugador.y, Jugador.ancho, Jugador.alto)
    love.graphics.rectangle("line", Enemigo.x, Enemigo.y, Enemigo.ancho, Enemigo.alto)

    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 100, 100, 100, 100)
    
    -- Volvemos a blanco para dibujar sprites
    love.graphics.setColor(1, 1, 1)

    -- JUGADOR
    love.graphics.draw(
        Jugador.sprite,
        Jugador.x,
        Jugador.y,
        0,
        Jugador.ancho / Jugador.sprite:getWidth(),
        Jugador.alto / Jugador.sprite:getHeight()
    )

    -- ENEMIGO
    if Enemigo.vivo then
        love.graphics.draw(
            Enemigo.sprite,
            Enemigo.x,
            Enemigo.y,
            0,
            Enemigo.ancho / Enemigo.sprite:getWidth(),
            Enemigo.alto / Enemigo.sprite:getHeight()
        )
    end

    -- PROYECTIL
    if Proyectil.activo then
        love.graphics.rectangle(
            "fill",
            Proyectil.x,
            Proyectil.y,
            Proyectil.ancho,
            Proyectil.alto
        )
    end

    -- MENSAJES
    if Juego.gameover then
        love.graphics.print("GAME OVER", 400, 00)
    end

    if Juego.victoria then
        love.graphics.print("Victoria", 400, 100)
    end
end