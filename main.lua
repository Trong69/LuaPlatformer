--link to repo
-- https://github.com/vrld/hump
-- https://github.com/karai17/Simple-Tiled-Implementation

function love.load()
    love.window.setMode(1000, 768)

    anim8 = require "libraries/anim8/anim8"
    sti = require 'libraries/Simple-Tiled-Implementation/sti'
    cameraFile = require 'libraries/hump/camera'
    require('libraries/show')
    

    --TODO 
    --Đi lại, idle, nhảy, đánh, chết. Đánh rung,
    --bị đẩy lùi, có vfx đằng sau. Parallax effect

    cam = cameraFile()

    --Tile and map
    mapWidth = 40
    tileSize = 64

    --Sound
    sounds ={}
    sounds.music = love.audio.newSource('audio/music.mp3','stream')
    sounds.jump = love.audio.newSource('audio/jump.wav','static')

    sounds.music:setLooping(true)
    sounds.music:setVolume(0.2)
    sounds.music:play()


    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')
    sprites.enemySheet = love.graphics.newImage('sprites/enemySheet.png')
    sprites.background = love.graphics.newImage('sprites/background.png')

    local playerGrid = anim8.newGrid(614,564, sprites.playerSheet:getWidth(),
        sprites.playerSheet:getHeight())

    local enemyGrid = anim8.newGrid(100,79,sprites.enemySheet:getWidth(),
        sprites.enemySheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(playerGrid('1-15',1),0.045) 
    animations.jump = anim8.newAnimation(playerGrid('1-7',2),0.045)
    animations.run = anim8.newAnimation(playerGrid('1-15',3),0.045)
    animations.enemy = anim8.newAnimation(enemyGrid('1-2',1),0.03)

    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0,1000,false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player')
    world:addCollisionClass('Danger')

    --Player--
    require('player')
    require('enemy')
    
    
    -- platforms --
    
    dangerZone = world:newRectangleCollider(-500,800,5000,50,{collision_class = "Danger"})
    dangerZone:setType('static')

    platforms = {}

    flagX = 0
    flagY = 0

    saveData ={}
    saveData.currentLevel = 'level1'

    if love.filesystem.getInfo("data.lua") then
        local data = love.filesystem.load("data.lua")
        data()
    end

    loadMap(saveData.currentLevel)

    --TODO
    -- make game map, add map
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
    updateEnemy(dt)

    local px, py = player:getPosition()
    local mapPixelWidth = mapWidth * tileSize 
    local halfScreenWidth = love.graphics.getWidth()/2
    local camX = math.max(halfScreenWidth, math.min(px,mapPixelWidth - halfScreenWidth))

    cam:lookAt(camX, love.graphics.getHeight()/2)

    local collider = world:queryRectangleArea(flagX,flagY,64,64,{'Player'})
    if #collider > 0 then
        if saveData.currentLevel == 'level1' then
            loadMap('level2')
        elseif saveData.currentLevel == 'level2' then
        loadMap('level1')
        end
    end
    
end

function love.draw()
    love.graphics.draw(sprites.background,0,0)
    cam:attach()
        gameMap:drawLayer(gameMap.layers['Tile Layer 1'])
        --world:draw() --turn off colider here 
        drawPlayer()
        drawEnemy()
    cam:detach()
    love.graphics.setFont(love.graphics.newFont(50))
    love.graphics.print(saveData.currentLevel, 0,0)
    
end

function love.keypressed(key)
    if key == 'w' and player.isGrounded then
            player:applyLinearImpulse(0, -5000)
            sounds.jump:setVolume(0.3)
            sounds.jump:play()
    end
end

function love.mousepressed(x,y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200)
    end
end

function spawnPlatform (x,y,width, height)
    if width > 0 and height > 0 then
        local platform  = world:newRectangleCollider(x,y,
            width,height, {collision_class = "Platform"})
        platform:setType('static')
        table.insert(platforms,platform)
    end
end

function destroyAll()
    local i = #platforms
    while i > -1 do
        if platforms[i] ~= nil then    
        platforms[i]:destroy()
        end
        table.remove(platforms,i)
        i = i - 1
    end

    local i = #enemies
    while i > -1 do
        if enemies[i] ~= nil then    
            enemies[i]:destroy()
        end
        table.remove(enemies,i)
        i = i - 1
    end
    
end

function loadMap(mapName)
    saveData.currentLevel = mapName
    love.filesystem.write('data.lua',table.show(saveData,'saveData'))
    destroyAll()
    --player:setPosition(playerStartX, playerStartY)
    gameMap = sti('maps/' .. mapName .. '.lua')
    for i, obj in pairs(gameMap.layers['Start'].objects) do
        playerStartX = obj.x
        playerStartY = obj.y
    end
    player:setPosition(playerStartX, playerStartY)
    for i, obj in pairs(gameMap.layers['Platforms'].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end

    for i, obj in pairs(gameMap.layers['Enemies'].objects) do
        spawnEnemy(obj.x, obj.y)
    end

    for i, obj in pairs(gameMap.layers['Flag'].objects) do
        flagX = obj.x 
        flagY = obj.y 
    end
end