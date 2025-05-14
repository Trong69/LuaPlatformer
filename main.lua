function love.load()
    anim8 = require "libraries/anim8/anim8"

    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')

    local grid = anim8.newGrid(614,564, sprites.playerSheet:getWidth(),
        sprites.playerSheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-15',1),0.045) 
    animations.jump = anim8.newAnimation(grid('1-7',2),0.045)
    animations.run = anim8.newAnimation(grid('1-15',3),0.045)

    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0,1000,false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player')
    world:addCollisionClass('Danger')

    --Player--
    require('player')
    
    -- platforms --
    platforms = world:newRectangleCollider(250,400,300,100, {collision_class = "Platform"})
    platforms:setType('static')

    dangerZone = world:newRectangleCollider(0,550,800,50,{collision_class = "Danger"})
    dangerZone:setType('static')

    --TODO
    -- make game map, add map
end

function love.update(dt)
    world:update(dt)
    playerUpdate(dt)
end

function love.draw()
    world:draw()
    drawPlayer()
end

function love.keypressed(key)
    if key == 'w' and player.isGrounded then
            player:applyLinearImpulse(0, -4000)
    end
end

function love.mousepressed(x,y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200)
    end
end