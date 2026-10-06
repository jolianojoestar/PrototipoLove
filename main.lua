-- =================== CARGAR DEPENDENCIAS ===================
require 'lib.dependencias'

-- Variable para la instancia del juego
Maquina_estados = nil
audio = nil
-- =================== ENTRADA DE USUARIO ===================

function love.mousepressed(x, y, button)
    -- Delegar el clic al estado activo
    if Maquina_estados
    and Maquina_estados.actual
    and Maquina_estados.actual.mousepressed then
        Maquina_estados.actual:mousepressed(x, y, button)
    end
end

function love.keypressed(key, scancode, isrepeat)

    if not Maquina_estados then
        return
    end

    -- Volver al título
    if key == "escape" then
        maquina_estados:cambiar("titulo")
    end

    -- Entrar a jugar
    if key == "return" then
        Maquina_estados:cambiar("jugar")
    end

    -- Activar / desactivar modo debug
    if key == "f1" then
        Signal.emit("modoDebug")
        return
    end

    -- Delegar al estado activo
    if Maquina_estados.actual and Maquina_estados.actual.keypressed then
        Maquina_estados.actual:keypressed(key)
    end

end

-- =================== LOAD ===================

function love.load()

    love.window.setMode(800, 600)
    love.graphics.setDefaultFilter("nearest", "nearest", 1)


    audio = Audio()
    -- Instanciar la máquina de estados
    Maquina_estados = MaquinaEstado{
        ['jugar'] = function()
            return EstadoJugar()
        end,

        ['titulo'] = function()
            return EstadoTitulo()
        end,

        ['derrota'] = function()
            return EstadoDerrota()
        end
    }

    Maquina_estados:cambiar("titulo")

end

-- =================== UPDATE ===================

function love.update(dt)
    if Maquina_estados then
        Maquina_estados:actualizar(dt)
    end
end

-- =================== DRAW ===================

function love.draw()
    if Maquina_estados then
        Maquina_estados:dibujar()
    end
end

function redondear(num)
    return math.floor(num + 0.5)
end