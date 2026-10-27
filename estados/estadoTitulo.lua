EstadoTitulo = Class{__includes = Estado}

function EstadoTitulo:init()
    -- Opción seleccionada actualmente (para teclado o control)
    self.seleccionado = 1
    self.opciones = {"Jugar", "Instrucciones"}
end

function EstadoTitulo:actualizar(dt)
    -- Lógica opcional de actualización
end

function EstadoTitulo:keypressed(key)
    -- Navegación con flechas o W/S
    if key == "up" or key == "w" then
        self.seleccionado = self.seleccionado - 1
        if self.seleccionado < 1 then self.seleccionado = #self.opciones end
    elseif key == "down" or key == "s" then
        self.seleccionado = self.seleccionado + 1
        if self.seleccionado > #self.opciones then self.seleccionado = 1 end
    
    -- Seleccionar con Enter o Espacio
    elseif key == "return" or key == "space" then
        if self.seleccionado == 1 then
            Maquina_estados:cambiar("jugar")
        elseif self.seleccionado == 2 then
            print("Ir a instrucciones")
            -- Maquina_estados:cambiar("instrucciones")
        end
    end
end

function EstadoTitulo:dibujar()
    -- Fondo oscuro para el menú
    love.graphics.clear(0.1, 0.1, 0.15)

    -- =========================
    -- TÍTULO GRANDE
    -- =========================
    love.graphics.setColor(1, 0.8, 0.2) -- Color dorado/amarillo
    -- Centrado correctamente dentro de los 320 de ancho
    love.graphics.printf("Gandalf in Moria", 0, 70, 320, "center")

    -- =========================
    -- BOTÓN 1: JUGAR
    -- =========================
    if self.seleccionado == 1 then
        love.graphics.setColor(0.8, 0.3, 0.2) -- Color resaltado si está seleccionado
    else
        love.graphics.setColor(0.3, 0.3, 0.4) -- Color normal de fondo del botón
    end
    -- Centrado en X: 110 (ancho 100), Y: 130
    love.graphics.rectangle("fill", 110, 130, 100, 25, 3, 3) 
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Jugar", 110, 138, 100, "center")

    -- =========================
    -- BOTÓN 2: INSTRUCCIONES
    -- =========================
    if self.seleccionado == 2 then
        love.graphics.setColor(0.8, 0.3, 0.2)
    else
        love.graphics.setColor(0.3, 0.3, 0.4)
    end
    -- Centrado en X: 110 (ancho 100), Y: 165
    love.graphics.rectangle("fill", 110, 165, 100, 25, 3, 3)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Instrucciones", 110, 173, 100, "center")
end

return EstadoTitulo