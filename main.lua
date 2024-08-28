love.window.setMode(961,528,{fullscreen=false})
width,height = love.graphics.getWidth(), love.graphics.getHeight()
love.window.setTitle( "Connecter" )
place2=love.audio.newSource("place2.ogg","static")
place1=love.audio.newSource("place1.ogg","static")
love.audio.setVolume( 0.65 )
back=love.audio.newSource("back.ogg","static")
playPlace1=true

function Spark(pos,angle,speed,scale,emmisionRate,color)
  local t={}
  t.pos=pos
  t.angle=angle
  t.speed=speed
  t.emmisionRate=emmisionRate
  t.r,t.g,t.b=color[1],color[2],color[3]
  if scale==nil then t.scale=1 else t.scale=scale end
  t.alive=true
  
  t.move=function(dt)
    
    local movement={math.cos(t.angle)*t.speed*dt,math.sin(t.angle)*t.speed*dt}
    t.pos[1]=t.pos[1]+movement[1]
    t.pos[2]=t.pos[2]+movement[2]
    
    t.speed=t.speed-t.emmisionRate*dt
    
    if t.speed<=0 then t.alive=false end
    
    end
  
  t.draw=function () 
    if t.alive then
      
      local vertexes={t.pos[1]+math.cos(t.angle)*t.scale*t.speed, t.pos[2]+math.sin(t.angle)*t.scale*t.speed,
        t.pos[1]+math.cos(t.angle+math.pi/2)*t.scale*t.speed*0.3, t.pos[2]+math.sin(t.angle+math.pi/2)*t.scale*t.speed*0.3,
        t.pos[1]-math.cos(t.angle)*t.scale*t.speed*3.5, t.pos[2]-math.sin(t.angle)*t.scale*t.speed*3.5,
        t.pos[1]+math.cos(t.angle-math.pi/2)*t.scale*t.speed*0.3, t.pos[2]-math.sin(t.angle+math.pi/2)*t.scale*t.speed*0.3,
      }
      
      love.graphics.setColor(t.r,t.g,t.b)
      
      love.graphics.polygon("fill",vertexes)
      
    end
  end
  
  return t
  
end

sparks={}

function Rect(x,y,w,h)
  local t={}
  
    t.x=x
    t.y=y
    t.w=w
    t.h=h
    
    t.colliderect= function (rect)
      if (t.x+t.w>rect.x and t.x<rect.x+rect.w and t.y<rect.y+rect.h and t.y+t.h>rect.y) then
        return true
      else
        return false
      end
    end
    
    t.collidepoint= function (px,py)
      if (t.x<=px and t.x+t.w>=px and t.y<=py and t.y+t.h>=py) then return true
      else return false end
    end
    
  return t
  
end

Boundary=Rect(-25,0,5,280)
restart=Rect((width/2)-80,(height/2)-30,140,30)
Exit=Rect((width/2)-80,(height/2)+10,140,30)

function love.load(...)
  img = love.graphics.newImage(love.image.newImageData(1, 1, "rgba8", "\255\255\255\255"))
  
  width,height = love.graphics.getWidth(), love.graphics.getHeight()
  
  score=0
  
  current_pos={-10,150}
  cam={0,0}
  scale={width/480,height/280}
  lineS={current_pos[1],current_pos[2]}
  joints={{485,140,82/255,148/255,226/255,0.7},{500,200,82/255,148/255,226/255,0.7}}
  clicked={}
  jointsCheck={}
  jointsCheck[tostring(500)..200]={500,200,false}
  
  for i=0,5 do
        local y=math.random(20,270)
        local x=math.random(50,150)
        table.insert(joints,{joints[#joints][1]+x,y,82/255,148/255,226/255,0.7})
        for i,v in ipairs(joints) do
          if jointsCheck[tostring(v[1])..v[2]]==nil then 
            jointsCheck[tostring(v[1])..v[2]]={v[1],v[2],false}
            
          end  
        end
   end
  
  lost=false
  screenShakeTimer=0
  NormalScaleClick={0,0}
  delta=0
  gameTimer=0
  
  
  love.graphics.setLineStyle( 'rough' )
  love.graphics.setBackgroundColor(30/255, 30/255, 30/255)
  love.graphics.setPointSize( 6 )
  
  backgroundOb={}
  for i=0,30 do
    table.insert(backgroundOb,{math.random(5,width-50),math.random(10,height-40),math.random(30,80),math.random(30,80),math.rad(math.random(0,360)),{math.random(110,190)/255,math.random(110,190)/255,math.random(110,190)/255},0})
  end
  
  
end

function love.draw(...)
  
  
  love.graphics.setBlendMode("add", 'premultiplied')
  love.graphics.push()
  love.graphics.scale(scale[1],scale[2])
  
  if screenShakeTimer>0 then
  love.graphics.translate(cam[1]+math.random(-3,3),cam[2]+math.random(-3,3))
  else
    love.graphics.translate(cam[1],cam[2]) end
  
  if #joints>2 then
    love.graphics.points(joints)
      for i,v in ipairs(joints) do
        if not jointsCheck[tostring(v[1]..v[2])][3] then
          
          love.graphics.setColor(1,1,1)
          love.graphics.circle("line",v[1],v[2],5) 
        else 
          love.graphics.setColor(82/255,148/255,226/255)
          love.graphics.circle("line",v[1],v[2],5) 
        end
        end
  end
  
  if #lineS>=4 then
  love.graphics.setLineWidth( 1.4 )
  love.graphics.setColor(82/255,148/255,226/255)
  love.graphics.line(lineS)
  end
  
  love.graphics.setColor(1,1,1)
  
  love.graphics.setLineWidth( 0.5 )
  if not lost then 
  love.graphics.line(current_pos[1], current_pos[2], mx, my) end
  
  love.graphics.setBlendMode("alpha")
  love.graphics.push()
  love.graphics.translate(4,4)
  
  love.graphics.setColor(82/255,148/255,226/255,0.7)
  
  if #lineS>4 then love.graphics.line(lineS) end
  
  love.graphics.setColor(0.8,0.8,0.8,0.7)
  for i,v in ipairs(joints) do love.graphics.circle("line",v[1]-1,v[2]-1,5) end
  
  love.graphics.setColor(1,1,1,1)
  
  for i=0,1 do
  table.insert(sparks,Spark({mx,my}, math.rad(math.random(0,360)),math.random(1,3),0.7,0.2,{1,1,1})) end
  
  for i,v in ipairs(sparks) do
    v.move(delta)
    v.draw()
    if not v.alive then table.remove(sparks,i) end
  end
  
  love.graphics.pop()
  
  love.graphics.pop()
  
  --love.graphics.setFont(font)
  
  for i,v in ipairs(backgroundOb) do
    local s,c=math.sin(v[5]),math.cos(v[5])
    v[1],v[2]=v[1]+c*delta ,v[2]+s*delta
    
    if v[1]>=width then v[1]=2 end
    if v[1]<=0 then v[1]=width end
    if v[2]>=height then v[2]=2 end
    if v[2]<=0 then v[2]=height end
    
    love.graphics.setColor(v[6][1],v[6][2],v[6][3],0.5)
    
    love.graphics.draw(img,v[1],v[2],v[3],v[4],2,1,1)
    
  end
  
  love.graphics.setColor(1,1,1,1)
  
  love.graphics.print(tostring(love.timer.getFPS()),10,30)
  love.graphics.print("SCORE: "..tostring(score),(width/2)-20,30)
  
  if lost then 
    love.graphics.print("RESTART",(width/2)-60,(height/2)-30)
    love.graphics.print("EXIT",(width/2)-60,(height/2)+10)
    end
  
end

function love.update(dt)
  delta=love.timer.getDelta()*60
  mx, my = (love.mouse.getX()/scale[1])-cam[1], (love.mouse.getY()/scale[2])-cam[2]-- current position of the mouse
  gameTimer=gameTimer-dt
  if screenShakeTimer>0 then screenShakeTimer=screenShakeTimer-dt end
  dt=dt*60
  if not lost then
  cam[1]=cam[1]-2.5*dt+gameTimer/50
  
  else 
    cam[1]=cam[1]-(cam[1]/20)*dt 
    
    if restart.collidepoint(NormalScaleClick[1],NormalScaleClick[2]) then 
      love.load()
    elseif Exit.collidepoint(NormalScaleClick[1],NormalScaleClick[2]) then love.event.quit()
      
    end
    
  end
    
  if cam[1]>-200 then cam[1]=-200 end
  
  if jointsCheck[tostring(joints[#joints-5][1])..joints[#joints-5][2]][3] and not lost then
    for i=0,5 do
      local y=math.random(20,270)
      local x=math.random(50-gameTimer/50,150-gameTimer/50)
      table.insert(joints,{joints[#joints][1]+x,y,82/255,148/255,226/255,0.7})
      for i,v in ipairs(joints) do
        if jointsCheck[tostring(v[1])..v[2]]==nil then 
          jointsCheck[tostring(v[1])..v[2]]={v[1],v[2],false}
          
        end  
      end
      end
  end
  
  Boundary.x=-5-cam[1]

  for i,v in pairs(jointsCheck) do
        if Boundary.collidepoint(v[1],v[2]) and not v[3] then lost=true love.audio.play(back) end
        
  end 
  
  
end

function love.mousepressed(x,y,b)
  clicked={mx,my}
  NormalScaleClick={x,y}
  
  playPlace1=true
  
  for i,v in ipairs(joints) do
    if (((my-v[2])^2)+((mx-v[1])^2))<=400 then 
      clicked={v[1],v[2]} 
      
      love.audio.play(place2)
      playPlace1=false
      
      for i=0,7 do
        table.insert(sparks,Spark({v[1],v[2]}, math.rad(math.random(0,360)),math.random(3,6),1.5,0.1,{82/255,148/255,226/255}))
      end
      
      if not jointsCheck[(tostring(v[1]))..v[2]][3] then score=score+1 end
      
      if jointsCheck[(tostring(v[1]))..v[2]]==nil then
        jointsCheck[(tostring(v[1]))..v[2]]={v[1],v[2],true} 
      else
        jointsCheck[(tostring(v[1]))..v[2]][3]=true
      end
      
      
      screenShakeTimer=0.2
      end
  end
  
  if playPlace1 then love.audio.play(place1) end
  
  if not (clicked[1]==lineS[#lineS-1] and clicked[2]==lineS[#lineS]) then
    table.insert(lineS,clicked[1])
    table.insert(lineS,clicked[2])
    current_pos=clicked
  end
  
  
end