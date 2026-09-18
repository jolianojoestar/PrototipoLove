EstadoDerrota = Class{__includes = Estado}

function EstadoDerrota:init() end

function EstadoDerrota:dibujar()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Has perdido. Presiona Escape para ir al menú", 300, 300)
end