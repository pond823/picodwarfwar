pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--pico dwarf war
--by sasha bilton
	
game={}
game.state = 1
game.cursor = {}
game.cursor.x = 8
game.cursor.y = 8
game.cursor.inc = 8
game.dx =0 --world view delta change
game.dy =0 
game.timer = 1
game.tick = 1
game.selected_structure = nil
game.path = nil

game.options={}
game.options.draw = 0
options = {}
flush_btn4 = 0
selected = 1
sprites = {}
structures ={}
totals = {
  resources = {
      food = 0,
      stone = 0,
      wood = 0,
      iron = 0
    }
}

game.message ={}
game.message.draw = 1
game.message.text = {'welcome to', 'pico dwarf war', 'press x to continue'}


 armies={}

function _init( ... )
  printh("initialising", "log.txt", true)
  create_options()
  create_initial_castle()
  create_initial_dwarves()
  new_sprite(game.cursor.x,game.cursor.y,10,{32,33}, 1, 0, 0) -- test animations are working
  calculate_total()
  --game.path = a_getpath({structures[1].x, structures[1].y},{structures[2].x, structures[2].y} )
end
	
function _update()
  if (game.state == 1) map_select()
  if (game.state == 2) select_options()
end

function _draw()
  cls()
  draw_map_view()
end

	--init functions
function create_initial_castle()
  local castle = {
    x = 8,
    y = 3,
    build = 1, -- castle
    owner = 1, --player
    spr = 18, --sprite to display
    smithy = 0,
    armoury = 0,
  }
  castle.name = random_castle()
  add (structures, castle)

  local castle2 = {
    x = 5,
    y = 7,
    build = 1, -- castle
    owner =1,
    spr = 18,
    smithy = 0,
    armoury = 0,
  }
  castle2.name = random_castle()
  add (structures, castle2)
end

function create_initial_dwarves() 
  local dwarf = {
    x = structures[1].x,
    y = structures[1].y,
    moves = 4,
    warriors = 5,
    elves = 1,
    dragons = 1,
    weapons = 3,
    armour = 2
  }
  local dwarf2 = {
    x = structures[1].x+1,
    y = structures[1].y+1,
    moves = 4,
    warriors = 5,
    elves = 0,
    dragons = 0,
    weapons = 0,
    armour = 0
  }
  add(armies,dwarf)
  add(armies,dwarf2)
 end


--update functions
	function map_select()
		update_timer()
		foreach(sprites, update_sprite)
  	if (btnp(0)) game.cursor.x-=1 
	 	if (btnp(1)) game.cursor.x+=1 
	 	if (btnp(2)) game.cursor.y-=1 
	 	if (btnp(3)) game.cursor.y+=1
   game.selected_structure = structure_at_location(game.cursor.x+game.dx, game.cursor.y+game.dy)
   game.selected_army = army_at_location(game.cursor.x+game.dx, game.cursor.y+game.dy)

   if (btnp(4)) then
    select_action()

  end
   if (btnp(5) and game.message.draw == 1) game.message.draw = 0
  
   if (game.cursor.x<0) then 
    game.cursor.x=0 
    if (game.dx >0 ) game.dx-=1 
   end
   if (game.cursor.y<0) then 
    game.cursor.y=0 
    if (game.dy >0 ) game.dy-=1
   end
   if (game.cursor.x>9) then 
    game.cursor.x=9 
    if (game.dx <32 ) game.dx+=1
   end
   if (game.cursor.y>9) then 
    game.cursor.y=9 
    if (game.dy <32 ) game.dy+=1
   end
   sprites[1].x = game.cursor.x*game.cursor.inc
   sprites[1].y = game.cursor.y*game.cursor.inc
	end

 function select_action()
  game.options.draw = 1
  game.state = 2
  if (game.selected_structure != nil and game.selected_army != nil) then 
    options = multi_options 
  elseif (game.selected_structure != nil) then
  	options = castle_options
 	elseif (game.selected_army != nil) then
    options = army_options

  elseif (game.selected_structure == nil and game.selected_army == nil) then
    options = game_options
 	end
  flush_btn4 = 1
end

function cancel_action()
  --game.options.draw = 0
  game.state = 2
end



	--draw functions
	function draw_map_view( ... )
		game.msg = ""
		map(game.dx,game.dy,0,0,10,10)
		foreach(structures, draw_structures)
    foreach(armies, draw_army)
		--spr(32, game.cursor.x*game.cursor.inc, game.cursor.y*game.cursor.inc)
		draw_message_box()
		draw_info_box()
    --draw_path()
    foreach(sprites, sprite_draw)

    if (game.options.draw == 1) draw_options()
    if (game.message.draw == 1) draw_message()
	end

	function draw_structures( structure )
		spr(structure.spr, structure.x*8 - game.dx*8, structure.y*8 - game.dy*8)
		rect((structure.x*8)-1 - game.dx*8,(structure.y*8)-1- game.dy*8, (structure.x*8)+7- game.dx*8, (structure.y*8)+7- game.dy*8,8) 
	end

function draw_message_box()
  rect(0,81,127,127,2)
  if(game.selected_structure != nil) then 
    local heading = game.selected_structure.name
    if (game.selected_structure.smithy > 0) heading = heading .. " smithy"
    print(heading, 2,83, 5)
    local army = army_at_structure(game.selected_structure)
    if (army != nil) draw_army_info( 2, 90, army)
  end
  if (game.selected_army != nil) draw_army_info( 2, 90, game.selected_army)
end

function draw_info_box()
  rect(80,0,127,81,2)
  draw_resources(81,0, totals.resources)
end

 function draw_resources(x,y, resources)
  spr(50, x,y)
  print(resources.food, x+9,y+2,5)
  spr(48,x,y+8)
  print(resources.iron, x+9,y+9,5)
  spr(49,x,y+15)
  print(resources.stone, x+9, y+17, 5)
  spr(51,x,y+23)
  print(resources.wood, x+9, y+25, 5)
 end

 function draw_path()
  if (game.path != nil) then
   for point in all(game.path) do
    spr(36,point[1]*8,point[2]*8)
   end
  end
 end

function draw_army(army)
  if (army != nil) then
    local atcastle = false
   
    if (structure_at_location(army.x, army.y) != nil) atcastle = true
    if (atcastle == false) then 
      local ax =  army.x*8 - game.dx*8
      local ay = army.y*8 - game.dy*8
      if ((ax >0 and ax <80) and (ay >0 and ay <80)) spr(21, ax, ay)
    end
  end
end

 function draw_army_info(x,y,army) 
  if(army != nil) then

   spr(21, x, y)
   print(army.warriors, x+9, y+2)
   spr(20, x, y+8)
   print(army.elves, x+9, y+10)
   spr(26, x, y+16)
   print(army.dragons,x+9 ,y+18)
   spr(28, x, y+24)
   print(army.weapons, x+9, y+26)
   spr(29, x+15, y+24)
   print(army.armour, x +24, y+26)
   
  end
 end


function army_at_structure(structure)
  for i=1, #armies do
   if (armies[i].x == structure.x and armies[i].y == structure.y) return armies[i]
  end
end

 function structure_at_location(x,y)
  for i=1,#structures do
   if (structures[i].x == x and structures[i].y == y) return structures[i]
  end
 end

 function army_at_location(x,y)
  for i=1,#armies do
   if (armies[i].x == x and armies[i].y == y) return armies[i]
  end
 end
--
-- sprite code
--
function new_sprite(x1, y1,tick, list, active, oneshot, move)
 s = {}
 s.x = x1
 s.y = y1
 s.list = list
 s.current = 1
 s.tick = tick -- change sprite frame every n refreshes (max 60)
 s.active = active -- is the sprite active?
 s.oneshot = oneshot -- does the sprite die 
 s.first_update = 1 -- marks the sprite as fresh
 s.move = move -- sprite moves
 add (sprites, s)
 return s
end


function sprite_draw(sprite)
  if (sprite.active == 1) then
    spr(sprite.list[sprite.current],sprite.x,sprite.y)

  end
end


function sprite_draw(sprite)
  if (sprite.active == 1) then
    spr(sprite.list[sprite.current],sprite.x,sprite.y)

  end
end

function update_sprite(sprite)
  if (sprite.active ==1) then
    if (sprite.first_update !=1 
      and sprite.move == 1 ) then
    sprite.x -= game.dx*8
    sprite.y -= game.dy*8
    sprite.first_update = 0
  else
    sprite.first_update = 0
  end
 -- check to see if we're on a tick
 if (game.timer % sprite.tick == 1) then
  if (sprite.current < #sprite.list) then
    sprite.current+=1
  else
    sprite.current =1
    if (sprite.oneshot == 1) then
      del(sprites,sprite)
    end
  end
 end
end
end

function update_timer()
  game.timer+=1
  if (game.timer>60) then
    game.timer = 1
  end

end

--
-- end of sprite code
--

-- name gen code

function random_castle()
	local a = {"khaz", "dur", "dun", "kharak","cral"}
	local b = {"zog", "dum", "dag", "kar", "vog", "hurn"}
	local c = {"dehad","gordum","fast","fort", "hold" }
	local i1 = flr(rnd(#a-1))+1
	local i2 = flr(rnd(#b-1))+1
	local i3 = flr(rnd(#c-1))+1
	local s = a[i1]..b[i2]..c[i3]
	game.msg = s
	return s
end

function log(msg)
	printh(time()..":"..msg, "log.txt")
end

function calculate_total()
	foreach(structures, structure_resources)

end

function structure_resources(structure)

	for lx = structure.x-1, structure.x+1 do
		for ly = structure.y-1, structure.y+1 do

			local loc = mget(lx,ly)
			-- 1 = plains, 2 = forest, 3= farmland, 4=hills, 5=mountains, 6=sea, 9= faerie ring, 10= cave 
			-- calculate surround resources
    totals.resources.food +=1 -- everything gives at least 1 food
    if (loc == 1) then
      totals.resources.food +=1
      totals.resources.wood +=1
     elseif (loc == 2) then
       totals.resources.wood +=3
     elseif (loc==3) then
      totals.resources.food +=2
     elseif (loc==4) then
      totals.resources.iron +=2
      totals.resources.stone +=1
     elseif (loc==5) then
      totals.resources.iron +=1
      totals.resources.stone +=3
     elseif (loc==6) then
      totals.resources.food +=2
     end
		end
	end
end


--
-- options code
--
function draw_options()

  if (#options>0) then
    
    oy = (64 - (#options * 6)/2)
    ox = 32
    rectfill(ox-7,oy-1,ox+65,65+((#options * 6)/2),0)
    rect(ox-7,oy-1,ox+65,65+((#options * 6)/2),2)
    for n= 1,#options do
      if (selected == n) then
        print(">"..options[n].display,ox-6,oy,9)
      else 
        print(options[n].display,ox,oy,12)
      end
      oy += 6
    end
  end
end


function select_options()

  if (btnp(2)) selected -=1 
  if (btnp(3)) selected +=1 

  if (selected < 1) then  
    selected =1
  elseif (selected > #options) then 
    selected = #options 
  end
    
  if (btnp(5)) then
    log("calling "..options[selected].display)
    options[selected].func()
  end
  -- flush_btn4 used to debounce btnp(4) as the first press is still in buffer  
  if (btnp(4) and flush_btn4 == 0) clear_options() -- cancel
  if (btnp(4) and flush_btn4 == 1) flush_btn4 = 0
 
end

function clear_options()
  game.state = 1
  options={}
  game.options.draw = 0
end

function train_warriors( ... )
  clear_options()


end

function build_smithy( ... )
  clear_options()
end

function select_castle_option (...)
  game.selected_army = nil
  options = castle_options
end

function selected_army_option (...)
  game.selected_structure = nil
  options = army_options
end

function split_army(...)
  
  if (game.selected_army != nil) then
    local new_army = {
      x = game.selected_army.x+1,
      y = game.selected_army.y+1,
      moves = 4,
      warriors = flr(game.selected_army.warriors/2),
      elves = flr(game.selected_army.elves/2),
      dragons = flr(game.selected_army.dragons/2),
      weapons = flr(game.selected_army.weapons/2),
      armour = flr(game.selected_army.armour/2)
    }
    -- -flr(-x) is ceiling(x)
    game.selected_army.warriors = -flr(-game.selected_army.warriors/2)
    game.selected_army.elves = -flr(-game.selected_army.elves/2)
    game.selected_army.dragons = -flr(-game.selected_army.dragons/2)
    game.selected_army.weapons = -flr(-game.selected_army.weapons/2)
    game.selected_army.armour = -flr(-game.selected_army.armour/2)
    add(armies,new_army)
    clear_options()
  end
end

function next_turn(...) 
  clear_options()
end

function end_game(...)
  stop()
end

-- must go after option functions in code
function create_options()

  castle_options = {
    { 
      display = "train warriors",
      func = train_warriors
    },
    {
      display = "build smithy",
      func = build_smithy
    },
    {
      display = "build armoury",
      func = build_smithy
    },
    {
      display = "form army",
      func = build_smithy
    }
  }

  army_options = {
    { 
      display = "move",
      func = train_warriors
    },
    {
      display = "fortify castle",
      func = build_smithy
    },
    {
      display = "build castle",
      func = build_smithy
    },
    {
      display = "split",
      func = split_army
    }
  }

  multi_options = {
    { 
      display = "select castle",
      func = select_castle_option
    },
    {
      display = "select army",
      func = selected_army_option
    }
  }

  game_options = {
  {  
      display = "next turn",
      func = next_turn
    },
    {
      display = "end game",
      func = end_game
    }
  }

  options = game_options
end

--pop up message

function draw_message()
  local message = game.message.text
  if (#message>0) then
    oy = (64 - (#message * 6)/2)
    ox = 16
    rectfill(ox-7,oy-2,ox+98,65+((#message * 6)/2),0)
    rect(ox-7,oy-2,ox+98,65+((#message * 6)/2),2)
    for n= 1,#message do
      print(message[n],ox,oy,12)
      oy += 6
    end
  end
end


-- a* pathfinding based on the work of @richy486
function a_getpath(start, goal) -- returns path{x,y}
 wallid = 6
 frontier = {}
 a_insert(frontier, start, 0)
 came_from = {}
 came_from[a_vectoindex(start)] = nil
 cost_so_far = {}
 cost_so_far[a_vectoindex(start)] = 0

 while (#frontier > 0 and #frontier < 1000) do
  current = a_popend(frontier)

  if a_vectoindex(current) == a_vectoindex(goal) then
   break
  end

  local neighbours = a_getneighbours(current)
  for next in all(neighbours) do
   local nextindex = a_vectoindex(next)
  
   local new_cost = cost_so_far[a_vectoindex(current)]  + 1 -- add extra costs here

   if (cost_so_far[nextindex] == nil) or (new_cost < cost_so_far[nextindex]) then
    cost_so_far[nextindex] = new_cost
    local priority = new_cost + a_heuristic(goal, next)
    a_insert(frontier, next, priority)
    
    came_from[nextindex] = current
   end 
  end
 end

 current = came_from[a_vectoindex(goal)]
 path = {}
 local cindex = a_vectoindex(current)
 local sindex = a_vectoindex(start)

 while cindex != sindex do
  add(path, current)
  current = came_from[cindex]
  cindex = a_vectoindex(current)
 end
 a_reverse(path)
 return path
end

-- manhattan distance on a square grid
function a_heuristic(a, b)
 return abs(a[1] - b[1]) + abs(a[2] - b[2])
end

-- find all existing neighbours of a position that are not walls
function a_getneighbours(pos)
 local neighbours={}
 local x = pos[1]
 local y = pos[2]
 if x > 0 and (mget(x-1,y) != wallid) then
  add(neighbours,{x-1,y})
 end
 if x < 32 and (mget(x+1,y) != wallid) then
  add(neighbours,{x+1,y})
 end
 if y > 0 and (mget(x,y-1) != wallid) then
  add(neighbours,{x,y-1})
 end
 if y < 32 and (mget(x,y+1) != wallid) then
  add(neighbours,{x,y+1})
 end

 -- for making diagonals
 if (x+y) % 2 == 0 then
  a_reverse(neighbours)
 end
 return neighbours
end

-- find the first location of a specific tile type
function a_getspecialtile(tileid)
 for x=0,15 do
  for y=0,15 do
   local tile = mget(x,y)
   if tile == tileid then
    return {x,y}
   end
  end
 end
 printh("did not find tile: "..tileid)
end

-- a_insert into start of table
function a_insert(t, val)
 for i=(#t+1),2,-1 do
  t[i] = t[i-1]
 end
 t[1] = val
end

-- a_insert into table and sort by priority
function a_insert(t, val, p)
 if #t >= 1 then
  add(t, {})
  for i=(#t),2,-1 do
   
   local next = t[i-1]
   if p < next[2] then
    t[i] = {val, p}
    return
   else
    t[i] = next
   end
  end
  t[1] = {val, p}
 else
  add(t, {val, p}) 
 end
end

-- a_pop the last element off a table
function a_popend(t)
 local top = t[#t]
 del(t,t[#t])
 return top[1]
end

function a_reverse(t)
 for i=1,(#t/2) do
  local temp = t[i]
  local oppindex = #t-(i-1)
  t[i] = t[oppindex]
  t[oppindex] = temp
 end
end

-- translate a 2d x,y coordinate to a 1d index and back again
function a_vectoindex(vec)
 return a_maptoindex(vec[1],vec[2])
end
function a_maptoindex(x, y)
 return ((x+1) * 16) + y
end
function a_indextomap(index)
 local x = (index-1)/16
 local y = index - (x*w)
 return {x,y}
end

-- a_pop the first element off a table (unused
function a_pop(t)
 local top = t[1]
 for i=1,(#t) do
  if i == (#t) then
   del(t,t[i])
  else
   t[i] = t[i+1]
  end
 end
 return top
end



__gfx__
00000000b3bbb3b0bbbbbbb0bbbbbbb09999999066666660ccccccc00000000000000000b3bbbbb0666666600000000000000000000000000000000000000000
00000000bbbbbbb0bb333bb0b9b9b9b099999990666566607cccccc00000000000000000bb7eeeb0666566600000000000000000000000000000000000000000
00700700bbbb3bb0b33333b0b9b9b9b09944499066575660cc7cc7c00000000000000000beee7e70665756600000000000000000000000000000000000000000
00077000bb3bbbb0bb333bb0bababab094a9449065777560ccccccc00000000000000000bbb99bb0656655600000000000000000000000000000000000000000
00077000bbbbb3b0bbb4bbb0bababab04a99944065665560cccccc7000000000000000003bbffbb0656565600000000000000000000000000000000000000000
007007003bbbbbb0b3b4b3b0bababab09999999056665550c7ccccc00000000000000000bbbffbb0566565500000000000000000000000000000000000000000
00000000bbbb3bb0bbbbbbb0bbbbbbb09999999066666660cccc7cc00000000000000000bbbbbb30666666600000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000022000000554000000000000055000000110000005500000000000882002000010010000044060000000000000000000000000
00000000000000000000000000222200000ff04000055000000bb00000155100000ff000000dd000088208800111116000565666555555600000000000000000
0006500000022000020220200008800000844240000ff05000bbb300001bb10000544545000fff04008088280115516000044066555555600000000000000000
0066550000222200022222200008200008082080055882400b0b30b001bbb310011555400009a004000880000555555000044060554995600000000000000000
000fd0000008800000888800000880000008204005582080000b30001b1b31b1011dd0f00f999904008888200115516000044000554955600000000000000000
000fd000000880000082880000082000008002400088820000b0030001bbb310000550000009a0f4088800000055556000044000554955600000000000000000
0000000000000000000000000008800008200420008002000bb00b3001b11310005005000099aa04808800000050050000044000055556000000000000000000
00000000000000000000000000000000000000000000000000000000001001000050050000f00f04000820000050050000000000005560000000000000000000
aa0aa0aa5000000500000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a000000a0000000000d0000000000dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000dd000000000dd00000111000000000000000000000000000000000000088000000000000000000000000000000000000000000000000000
a000000a00000000000d00000d0dd0000011d1000000000000000000000000000000000000888800000880000000000000000000000000000000000000000000
a000000a000000000000d0d000dd0000001dd1000000000000000000000000000000000000888800000880000000800000000000000000000000000000000000
000000000000000000000dd00ddd0000001111000000000008000000bbb0000000f0000000088000000000000000000000000000000000000000000000000000
a000000a000000000000ddd0dd00d000000000000000000088800000bbb000000ff0000000000000000000000000000000000000000000000000000000000000
aa0aa0aa5000000500000000000000000000000000000000080000000b000000fff0000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000030000000999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06dddd50006566000084380004999400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ddddd50056666500888878004445400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ddddd50065565600888888004544400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dddd550056656600888888004445400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005666000008800004544400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0606060606060606060606040606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606060601020201010105060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606060602020204050505060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606060102020904050505050606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060601030101040405050a050406060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606010404040402050505050404040600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606010202020202050505040404040600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606060606020202060504040405020600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606060606060606060604040402020600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606060606060606060606060202060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606060606060606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424344

