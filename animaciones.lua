Animacion = {}

function Animacion.Crear(imagen, limite, ancho, alto, velocidad, esVertical)
    local anim = {}
    anim.spritehseet = love.graphics.newImage(imagen)
    anim.indice = 1
    anim.velocidad = velocidad
    anim.quads = {}
    anim.activado = false -- empieza inactiva hasta que dispares

    local sw, sh = anim.spritehseet:getDimensions()

    if esVertical then
        for i = 0, limite - 1 do
            table.insert(anim.quads, love.graphics.newQuad(
                0, i * alto, ancho, alto, sw, sh
            ))
        end
    else
        for i = 0, limite - 1 do
            table.insert(anim.quads, love.graphics.newQuad(
                i * ancho, 0, ancho, alto, sw, sh
            ))
        end
    end

    return anim
end

function Animacion.Actualizar(anim, dt, unaVez)
    if not anim.activado then return end

    anim.indice = anim.indice + (anim.velocidad * dt)

    -- Si superó el último frame (para 3 frames, cuando pase de 4.0)
    if anim.indice >= #anim.quads + 1 then
        if unaVez then
            anim.activado = false
            anim.indice = 1
        else
            anim.indice = 1
        end
    end
end

function Animacion.Dibujar(anim, x, y, escala_x, escala_y, origen_x, origen_y)
    if not anim.activado then return end

    local i = math.floor(anim.indice)
    -- Salvaguarda: asegurarse de que el frame esté entre 1 y el total de quads
    if i >= 1 and i <= #anim.quads then
        love.graphics.draw(
            anim.spritehseet,
            anim.quads[i],
            x, y, 0,
            escala_x or 1,
            escala_y or 1,
            origen_x or 0,
            origen_y or 0
        )
    end
end

return Animacion