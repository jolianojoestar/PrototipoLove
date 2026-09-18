EstadoTitulo = Class{__includes = Estado}

function EstadoTitulo:dibujar()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Presiona Enter para jugar", 300, 300)
end