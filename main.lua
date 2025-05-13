function love.load()
    anim8 = require "libraries/anim8/anim8"

    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0,1000,false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player')
    world:addCollisionClass('Danger')



    player = world:newRectangleCollider(360,100,80,80, {collision_class = "Player"})
    player:setFixedRotation(true)
    player.speed = 240

    platforms = world:newRectangleCollider(250,400,300,100, {collision_class = "Platform"})
    platforms:setType('static')

    dangerZone = world:newRectangleCollider(0,550,800,50,{collision_class = "Danger"})
    dangerZone:setType('static')
end

function love.update(dt)
    world:update(dt)
    if player.body then
        local px , py = player:getPosition()
        if love.keyboard.isDown('d') then
            player:setX(px + player.speed*dt)
        end
        if love.keyboard.isDown('a') then
            player:setX(px - player.speed*dt)
        end

        if player:enter('Danger') then
            player:destroy()
        end
    end
end

function love.draw()
    world:draw()
end

function love.keypressed(key)
    if key == 'w' then
        local colliders = world:queryRectangleArea(player:getX() - 40,
            player:getY() + 40,80,2, {'Platform'})
        -- number of collider is greater than 0 then jump 
        if #colliders > 0 then          
            player:applyLinearImpulse(0, -7000)
        end
    end
end

function love.mousepressed(x,y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200)  
        --for i, c in ipairs(colliders) do
            --c:destroy()
        --end
    end
end