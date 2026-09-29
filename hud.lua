HUD = Class{}

function HUD:init()

    self.texto_vida = ""
    self.depurar = false
    -- SIGNALS
    Signal.register("modoDebug", function()
        self:DebugToggle()
    end)
    
    Signal.register("actualizarVidas", function(vidas)
        self:ActualizarVidas(vidas)
    end)

end

-- =========================
-- DIBUJAR HUD
-- =========================

function HUD:Draw()

    love.graphics.print(
        self.texto_vida,
        300,
        10
    )

end

-- =========================
-- DATOS DE DEBUG
-- =========================

function HUD:DrawGameData()

    if not self.depurar then
        return
    end

    love.graphics.setColor(0, 1, 0)

    love.graphics.print(
        "FPS: " .. love.timer.getFPS(),
        10,
        10
    )

    love.graphics.setColor(1, 1, 1)

end

-- =========================
-- ACTIVAR / DESACTIVAR DEBUG
-- =========================

function HUD:DebugToggle()

    self.depurar = not self.depurar

end

-- =========================
-- ACTUALIZAR VIDAS
-- =========================

function HUD:ActualizarVidas(vidas)

    self.texto_vida = "x" .. vidas

end