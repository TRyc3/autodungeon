extends dungeon

#maze rules
#0 = empty
#1 = four sides open
#2 = bottom, right open
#3 = top, right open
#4 = bottom, left open
#5 = top, left open
#6 = left, right, bottom open
#7 = left, right, top open
#8 = right, top, bottom open
#9 = left top, bottom open

#10 = hall four sides open
#11 = hall bottom, right open
#12 = hall top, right open
#13 = hall bottom, left open
#14 = hall top, left open
#15 = hall left, right, bottom open
#16 = hall left, right, top open
#17 = hall right, top, bottom open
#18 = hall left top, bottom open
#19 = hall top, bottom open
#20 = hall right, left open
#21 = hall top open
#22 = hall right open
#23 = hall bottom open
#24 = hall left open

var player

func make_dungeon():
	tile_size = Map.cell_size
	#maze = tile assignment, y = walls
	for x in range(width):
		build.append([])
		for y in range(height):
			build[x].append(0)
			build[x][y] = Vector2(0,0)
	for x in range(width):
		creature.append([])
		for y in range(height):
			creature[x].append(0)
			creature[x][y] = 0
	make_room()
	make_maze()
	make_path()
	set_texture()
	spawn_player()


func make_room():
	var minsizex = (width) / 15
	var maxsizex = (width) / 8
	var minsizey = (height) / 15
	var maxsizey = (height) / 8
	for _i in range (5000):
		var make = false
#		+2 so no rooms touch
		var sizex = randi() % maxsizex + 2
		var sizey = randi() % maxsizey + 2
		var startx = (randi() % width )
		var starty = (randi() % height)
		
#		if within boundries, make room
		if (startx + sizex + 2) < width:
			if sizex >= minsizex:
				if (starty + sizey + 2) < height:
					if sizey >= minsizey:
						make = true
		if make:
			for x in range (startx - 2, startx + sizex + 2):
				for y in range (starty - 2, starty + sizey + 2):
					if build[x][y].x == 1:
						make = false
						break
				if !make:
					break

		if make:
#				store room location and dimension
			core.append(Vector2(startx, starty))
			dim.append(Vector2(sizex, sizey))
			
#				set corners
			build[startx][starty].x = 2
			build[startx][starty].y = 6
			build[startx][starty + sizey].x = 3
			build[startx][starty + sizey].y = 3
			build[startx + sizex][starty].x = 4
			build[startx + sizex][starty].y = 12
			build[startx + sizex][starty + sizey].x = 5
			build[startx + sizex][starty + sizey].y = 9
#				set outer walls
			for x in range(startx + 1, startx + sizex):
				build[x][starty].x = 6
				build[x][starty].y = 14
				build[x][starty + sizey].x = 7
				build[x][starty + sizey].y = 11
			for y in range (starty + 1, starty + sizey):
				build[startx][y].x = 8
				build[startx][y].y = 7
				build[startx + sizex][y].x = 9
				build[startx + sizex][y].y = 13
#					set inside rooms
			for x in range (startx, startx + sizex):
				for y in range (starty, starty + sizey):
					build[x][y].x = 1
					build[x][y].y = 15


func make_maze():
#	build maze array
	for x in range(width):
		maze.append([])
		for y in range(height ):
			maze[x].append([])
			if build[x][y].x == 0:
				maze[x][y] = Vector2(0,0)
			else:
				maze[x][y] = Vector2(2,0)
				
#	set outer boundries to avoid overflow
	for x in width:
		maze[x][0] = Vector2(1,0)
		maze[x][height - 1] = Vector2(1,0)
	for y in height:
		maze[0][y] = Vector2(1,0)
		maze[width - 1][y] = Vector2(1,0)
		
#	select starting position
	var posx = randi() % width
	var posy = randi() % height
	while build[posx][posy].x != 0:
		posx = randi() % width
		posy = randi() % height
		
#	build maze until no empty spaces are left
	var stack = []
	stack.push_back(Vector2(posx, posy))
	while !stack.empty():
		var cur = stack.front()
		if cur.x != 0 && cur.x != width - 1 && cur.y != 0 && cur.y != height - 1:
#			check for empty neighbors
			if maze[cur.x+1][cur.y].x == 0||maze[cur.x-1][cur.y].x == 0||maze[cur.x][cur.y+1].x == 0|| maze[cur.x][cur.y-1].x == 0:
#				if a neighbor is empty, pick a random available direction and continue
				var go = true
				while go:
					var next = randi() % 4
					if next == 0 && maze[cur.x + 1][cur.y].x == 0:
						go = false
						stack.push_front(Vector2(cur.x + 1, cur.y))
						maze[cur.x][cur.y].y += 2
						maze[cur.x + 1][cur.y].y += 8
						maze[cur.x + 1][cur.y].x = 1
					elif next == 1 && maze[cur.x - 1][cur.y].x == 0:
						go = false
						stack.push_front(Vector2(cur.x - 1, cur.y))
						maze[cur.x][cur.y].y += 8
						maze[cur.x - 1][cur.y].y += 2
						maze[cur.x - 1][cur.y].x = 1
					elif next == 2 && maze[cur.x][cur.y + 1].x == 0:
						go = false
						stack.push_front(Vector2(cur.x, cur.y + 1))
						maze[cur.x][cur.y].y += 4
						maze[cur.x][cur.y + 1].y += 1
						maze[cur.x][cur.y + 1].x = 1
					elif next == 3 && maze[cur.x][cur.y - 1].x == 0:
						go = false
						stack.push_front(Vector2(cur.x, cur.y - 1))
						maze[cur.x][cur.y].y += 1
						maze[cur.x][cur.y - 1].y += 4
						maze[cur.x][cur.y - 1].x = 1
			else:
#				if no empty neighbors, save dead end and pop from stack
				stack.pop_front()
				deadend.append(Vector2(cur.x, cur.y))
#		else:
#			stack.pop_front()
	
#	connect rooms to maze
	while !core.empty() && !dim.empty():
		var repeat = 1 + (randi() % 3)
		var one = true
		var two = true
		var three = true
		var four = true
		while repeat > 0 && ( one || two || three || four):
			var dir = randi() % 4
			var connector
			if dir == 0 && one:
				connector = randi() % int(dim.front().x - 2) + 1
				if build[core.front().x + connector][core.front().y].x != 1:
					build[core.front().x + connector][core.front().y].x = 1
					build[core.front().x + connector][core.front().y].y = 15
					maze[core.front().x + connector][core.front().y - 1].y += 4
					repeat -= 1
				else:
					one = false
			elif dir == 1 && two:
				connector = randi() % int(dim.front().x - 2) + 1
				if build[core.front().x + connector][core.front().y + dim.front().y].x != 1:
					build[core.front().x + connector][core.front().y + dim.front().y].x = 1
					build[core.front().x + connector][core.front().y + dim.front().y].y = 15
					maze[core.front().x + connector][core.front().y + dim.front().y + 1].y += 1
					repeat -= 1
				else:
					two = false
			elif dir == 2 && three:
				connector = randi() % int(dim.front().y - 2) + 1
				if build[core.front().x][core.front().y + connector].x != 1:
					build[core.front().x][core.front().y + connector].x = 1
					build[core.front().x][core.front().y + connector].y = 15
					maze[core.front().x - 1][core.front().y + connector].y += 2
					repeat -= 1
				else:
					three = false
			elif dir == 3 && four:
				connector = randi() % int(dim.front().y - 2) + 1
				if build[core.front().x + dim.front().x][core.front().y + connector].x != 1:
					build[core.front().x + dim.front().x][core.front().y + connector].x = 1
					build[core.front().x + dim.front().x][core.front().y + connector].y = 15
					maze[core.front().x + dim.front().x + 1][core.front().y + connector].y += 8
					repeat -= 1
				else:
					four = false
#				if at surrounded by edges, break
				if !one && !two && !three && !four:
					for x in dim.front().x:
						for y in dim.front().y:
							build[core.front().x + x][core.front().y + y] = Vector2(1,0)
		roomcenter.push_front(core.front())
		roomdim.push_front(dim.front())
		core.pop_front()
		dim.pop_front()


func make_path():
#	take a dead end and delete it, continue till there are no dead ends
	var posx
	var posy
	while !deadend.empty():
		posx = deadend.front().x
		posy = deadend.front().y
		if maze[posx][posy].y == 1 || maze[posx][posy].y == 2 || maze[posx][posy].y == 4 || maze[posx][posy].y == 8:
			if int(maze[posx][posy].y) == 1:
				maze[posx][posy] = Vector2(1,0)
				maze[posx][posy - 1].y -= 4
				if posx != 0 && posx != width - 1 && posy - 1 != 0:
					deadend.append(Vector2(posx, posy - 1))
			elif int(maze[posx][posy].y) == 2:
				maze[posx][posy] = Vector2(1,0)
				maze[posx + 1][posy].y -= 8
				if posx + 1 != width - 1 && posy - 1 != 0 && posy - 1 != height - 1:
					deadend.append(Vector2(posx + 1, posy))
			elif int(maze[posx][posy].y) == 4:
				maze[posx][posy] = Vector2(1,0)
				maze[posx][posy + 1].y -= 1
				if posx != 0 && posx != width + 1 && posy + 1 != height - 1:
					deadend.append(Vector2(posx, posy + 1))
			elif int(maze[posx][posy].y) == 8:
				maze[posx][posy] = Vector2(1,0)
				maze[posx - 1][posy].y -= 2
				if posx - 1 != 0 && posx - 1 != width - 1 && posy != 0 && posy != height - 1:
					deadend.append(Vector2(posx - 1, posy))
		deadend.pop_front()

#set build
	for x in width:
		for y in height:
			if maze[x][y].x == 1:
				build[x][y].y = maze[x][y].y
				if maze[x][y].y == 1:
					build[x][y].x = 21
				elif  maze[x][y].y == 2:
					build[x][y].x = 22
				elif  maze[x][y].y == 3:
					build[x][y].x = 12
				elif  maze[x][y].y == 4:
					build[x][y].x = 23
				elif  maze[x][y].y == 5:
					build[x][y].x = 19
				elif  maze[x][y].y == 6:
					build[x][y].x = 11
				elif  maze[x][y].y == 7:
					build[x][y].x = 17
				elif  maze[x][y].y == 8:
					build[x][y].x = 24
				elif  maze[x][y].y == 9:
					build[x][y].x = 14
				elif  maze[x][y].y == 10:
					build[x][y].x = 20
				elif  maze[x][y].y == 11:
					build[x][y].x = 16
				elif  maze[x][y].y == 12:
					build[x][y].x = 13
				elif  maze[x][y].y == 13:
					build[x][y].x = 18
				elif  maze[x][y].y == 14:
					build[x][y].x = 15
				elif  maze[x][y].y == 15:
					build[x][y].x = 10


func set_texture():
	for x in range(width):
		for y in range(height):
			if build[x][y].x == 1:
				Map.set_cell(x, y, 20)
			elif build[x][y].x == 2:
				Map.set_cell(x, y, 26)
			elif build[x][y].x == 3:
				Map.set_cell(x, y, 22)
			elif build[x][y].x == 4:
				Map.set_cell(x, y, 18)
			elif build[x][y].x == 5:
				Map.set_cell(x, y, 24)
			elif build[x][y].x == 6:
				Map.set_cell(x, y, 17)
			elif build[x][y].x == 7:
				Map.set_cell(x, y, 23)
			elif build[x][y].x == 8:
				Map.set_cell(x, y, 19)
			elif build[x][y].x == 9:
				Map.set_cell(x, y, 21)
			elif build[x][y].x == 10:
				Map.set_cell(x, y, 0)
			elif build[x][y].x == 11:
				Map.set_cell(x, y, 9)
			elif build[x][y].x == 12:
				Map.set_cell(x, y, 12)
			elif build[x][y].x == 13:
				Map.set_cell(x, y, 3)
			elif build[x][y].x == 14:
				Map.set_cell(x, y, 6)
			elif build[x][y].x == 15:
				Map.set_cell(x, y, 1)
			elif build[x][y].x == 16:
				Map.set_cell(x, y, 4)
			elif build[x][y].x == 17:
				Map.set_cell(x, y, 8)
			elif build[x][y].x == 18:
				Map.set_cell(x, y, 2)
			elif build[x][y].x == 19:
				Map.set_cell(x, y, 15)
			elif build[x][y].x == 20:
				Map.set_cell(x, y, 10)
			elif build[x][y].x == 21:
				Map.set_cell(x, y, 14)
			elif build[x][y].x == 22:
				Map.set_cell(x, y, 13)
			elif build[x][y].x == 23:
				Map.set_cell(x, y, 11)
			elif build[x][y].x == 24:
				Map.set_cell(x, y, 7)

func spawn_player():
	var spawn = randi() % roomcenter.size()
	var posx = roomcenter[spawn].x + (randi() % (int(roomdim[spawn].x) - 2) + 1)
	var posy = roomcenter[spawn].y + (randi() % (int(roomdim[spawn].y) - 2) + 1)
	player = Vector2(posx, posy)
	creature[posx][posy] = 1

