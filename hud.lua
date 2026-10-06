HUD = Class{}

function HUD:init()
    self.texto_vida = "3" -- Valor por defecto para asegurar que muestre algo
    print("HUD inicializado correctamente") -- <--- Agrega esto
    self.depurar = false

    Signal.register("modoDebug", function()
        print("HUD recibió nuevas vidas:", vidas) -- <--- Agrega esto
        self:DebugToggle()
    end)
    
    Signal.register("actualizarVidas", function(vidas)
        self:ActualizarVidas(vidas)
    end)
end

function HUD:Draw()

    print("HUD:Draw() se está ejecutando") --
    -- Dibuja un rectángulo negro sólido de fondo en la esquina superior izquierda del Canvas
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 8, 8, 70, 22, 4, 4)

    -- Dibuja el texto en color verde brillante o blanco puro para que salte a la vista
    love.graphics.setColor(0, 1, 0)
    love.graphics.print(
        "HP: " .. self.texto_vida,
        14,
        12
    )
    love.graphics.setColor(1, 1, 1) -- Restablecer color
end

function HUD:DrawGameData()
    if not self.depurar then return end
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 35)
    love.graphics.setColor(1, 1, 1)
end

function HUD:DebugToggle()
    self.depurar = not self.depurar
end

function HUD:ActualizarVidas(vidas)
    self.texto_vida = tostring(vidas)
end

return HUD