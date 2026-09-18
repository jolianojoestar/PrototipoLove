-- =================== CARGAR DEPENDENCIAS ===================
require 'lib.dependencias'

-- Variable para la instancia del juego
maquina_estados = nil
-- =================== ENTRADA DE USUARIO ===================

function love.mousepressed(x, y, button)
    -- Delegar el clic al estado activo si este implementa mousepressed
    if maquina_estados and maquina_estados.actual.mousepressed then
        maquina_estados.actual:mousepressed(x, y, button)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if not maquina_estados then return end

    if key == "escape" then
        maquina_estados:cambiar("titulo")
    end
    if key == "return" then
        maquina_estados:cambiar("jugar")
    end
    if maquina_estados.actual and maquina_estados.actual.keypressed then
        maquina_estados.actual:keypressed(key)
    end
end

-- =================== LOAD ===================

function love.load()
    love.window.setMode(800, 600)
    love.graphics.setDefaultFilter("nearest", "nearest", 1)

    -- Instanciar la clase MaquinaEstado (en singular, como se definió)
    maquina_estados = MaquinaEstado{
        ['jugar'] = function () return EstadoJugar() end,
        ['titulo'] = function () return EstadoTitulo() end,
        ['derrota'] = function () return EstadoDerrota() end
    }

    maquina_estados:cambiar('titulo')
end

-- =================== UPDATE ===================

function love.update(dt)
    if maquina_estados then
        maquina_estados:actualizar(dt)
    end
end

-- =================== DRAW ===================

function love.draw()
    if maquina_estados then
        maquina_estados:dibujar()
    end
end

function redondear(num)
    return math.floor(num + 0.5)
end