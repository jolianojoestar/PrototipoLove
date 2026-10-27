Audio = Class{}

function Audio:init()
    self.shoot = love.audio.newSource("assets/sounds/shoot.mp3", "static")
    self.hit = love.audio.newSource("assets/sounds/golpe.mp3", "static")
    self.death = love.audio.newSource("assets/sounds/fly-you-fools.mp3", "static")

    Signal.register("jugadorDisparo", function()
        -- Si ya está sonando, lo rebobinamos; si no, lo reproducimos
        self.shoot:stop()
        self.shoot:play()
    end)

    Signal.register("jugadorGolpeado", function()
        self.hit:stop()
        self.hit:play()
    end)

    Signal.register("jugadorMuerto", function()
        self.death:stop()
        self.death:play()
    end)
end

return Audio