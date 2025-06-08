player = world:newRectangleCollider(360,100,40,100, {collision_class = "Player"})
player:setFixedRotation(true)
player.speed = 240
player.direction = 1 

player.animation = animations.idle
player.isMoving = false
player.isGrounded = true

function playerUpdate(dt)
    if player.body then
        local colliders = world:queryRectangleArea(player:getX() - 20,
            player:getY() + 50,40,2, {'Platform'})
        -- number of collider is greater than 0 then player is grounded 
        if #colliders > 0 then
            player.isGrounded = true
        else
            player.isGrounded = false
        end

        player.isMoving = false

        local px , py = player:getPosition()
        if love.keyboard.isDown('d') then
            player.isMoving = true
            player.direction = 1 
            player:setX(px + player.speed*dt)
        end
        if love.keyboard.isDown('a') then
            player.isMoving = true
            player.direction = -1
            player:setX(px - player.speed*dt)
        end

        if player:enter('Danger') then
            player:setPosition(300, 100)
        end
    end

    if player.isGrounded then
        if player.isMoving == true then
            player.animation = animations.run
        else
            player.animation = animations.idle
        end
    else
        player.animation = animations.jump
    end
    player.animation:update(dt)
end

function drawPlayer()
    local px, py = player:getPosition()
    player.animation:draw(sprites.playerSheet,px,py, nil,
        0.25 * player.direction, 0.25,130,300)
end