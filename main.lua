-- Variables globales
puntaje = 0
textPuntaje = ""
    -- Pantalla
centroX = 0
centroY = 0
    -- Sprite
sprite = nil
centroSpriteX = 0
centroSpriteY = 0
escala = 1
escalaMax= 4
    -- SFX
clickSFX = love.audio.newSource("assets/jump.mp3", "static")
--musicBackground = love.audio.newSource("assets/background.mp3", "stream")

function love.load()
    textPuntaje = "Puntaje: " .. puntaje
    sprite = love.graphics.newImage("assets/Rehen.png")
    centroX = love.graphics.getWidth() / 2
    centroY = love.graphics.getHeight() / 2
    centroSpriteX = sprite:getWidth() / 2
    centroSpriteY = sprite:getHeight() / 2
end


function love.mousepressed(x,y,button)

    if button == 1 then
        distancia = math.sqrt((x - centroX)^2 + (y - centroY)^2) 
        if distancia <= centroSpriteX then
            puntaje = puntaje + 1
            clickSFX:play()
            escala = 1
        else
            puntaje = puntaje - 1
        end
    end
    textPuntaje = "Puntaje: " .. puntaje    
end

function love.draw()
    love.graphics.print(textPuntaje, 400, 50)
    love.graphics.draw(sprite, centroX - centroSpriteX, centroY - centroSpriteY,0,escala,escala)
end

function love.update(dt)
    if escala < escalaMax then
        escala = (escala + (0.3 * dt))
    end
end