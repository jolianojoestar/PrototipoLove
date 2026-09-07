function CrearAnimacion(imagen,limite,ancho,alto,velocidad,esVertical)
    local animacion = {}
    
    animacion.spritehseet = love.graphics.newImage(imagen)
    animacion.indice = 1
    animacion.velocidad = velocidad
    animacion.quads = {}
    animacion.activado = true

    if esVertical then
        for i = 0, limite - 1 do
            table.insert(animacion.quads, love.graphics.newQuad(0, i * alto, ancho, alto, animacion.spritehseet))
        end
    else
        for i = 0, limite - 1 do
            table.insert(animacion.quads, love.graphics.newQuad(i * ancho, 0, ancho, alto, animacion.spritehseet))
        end
    end
    return animacion
end