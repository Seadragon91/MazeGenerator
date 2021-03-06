cCell = {}
cCell.__index = cCell

function cCell.new(a_X, a_Y, a_Z)
	local self = setmetatable({}, cCell)

	self.m_X = a_X
	self.m_Y = a_Y
	self.m_Z = a_Z
	self.m_Visited = false
	self.m_Walls = {} -- top: 1; down: 2; right: 3; left: 4; backward: 5; foward: 6
	self.m_Neighbors = {}

	return self
end



function cCell:SetNeighbors(a_Maze, a_SizeX, a_SizeY, a_SizeZ)
	if (self.m_X > 1) then
		self.m_Walls[4] = 4 -- left
		self.m_Neighbors[4] = a_Maze[self.m_X - 1][self.m_Y][self.m_Z]
	end

	if (self.m_X < a_SizeX) then
		self.m_Walls[3] = 3 -- right
		self.m_Neighbors[3] = a_Maze[self.m_X + 1][self.m_Y][self.m_Z]
	end


	if (self.m_Y > 1) then
		self.m_Walls[2] = 2 -- down
		self.m_Neighbors[2] = a_Maze[self.m_X][self.m_Y - 1][self.m_Z]
	end

	if (self.m_Y < a_SizeY) then
		self.m_Walls[1] = 1 -- top
		self.m_Neighbors[1] = a_Maze[self.m_X][self.m_Y + 1][self.m_Z]
	end


	if (self.m_Z > 1) then
		self.m_Walls[5] = 5 -- backward
		self.m_Neighbors[5] = a_Maze[self.m_X][self.m_Y][self.m_Z - 1]
	end

	if (self.m_Z < a_SizeZ) then
		self.m_Walls[6] = 6 -- forward
		self.m_Neighbors[6] = a_Maze[self.m_X][self.m_Y][self.m_Z + 1]
	end
end



function cCell:GetRandomNeigbor()
	local neighbors = {}

	-- First use all the neighbors on the same y level, makes better mazes :-)
	for x = 3, 6 do
		if ((self.m_Neighbors[x] ~= nil) and (not self.m_Neighbors[x].m_Visited) and (self.m_Walls[x] ~= nil)) then
			table.insert(neighbors, x)
		end
	end

	if (#neighbors == 0) then
		for x = 1, 2 do
			if ((self.m_Neighbors[x] ~= nil) and (not self.m_Neighbors[x].m_Visited) and (self.m_Walls[x] ~= nil)) then
				table.insert(neighbors, x)
			end
		end
	end

	if (#neighbors == 0) then return nil end

	local rnd = neighbors[math.random(#neighbors)]
	return self.m_Neighbors[rnd], rnd
end



function cCell:GetOpenNeighbors()
	local left = {}

	for x = 1, 6 do
		if ((self.m_Neighbors[x] ~= nil) and (self.m_Neighbors[x].m_Visited) and (self.m_Walls[x] == nil)) then
			table.insert(left, x)
		end
	end
	return left
end



function cCell:GetLeft()
	local left = {}

	for x = 1, 6 do
		if ((self.m_Neighbors[x] ~= nil) and (self.m_Walls[x] ~= nil)) then
			table.insert(left, x)
		end
	end

	return #left
end



function cCell:CreateBorders(a_Output, a_OutX, a_OutY, a_OutZ)
	for x = 0, 4 do
		if (a_Output[a_OutX + x] == nil) then
			a_Output[a_OutX + x] = {}
		end
		for y = 0, 4 do
			if (a_Output[a_OutX + x][a_OutY + y] == nil) then
				a_Output[a_OutX + x][a_OutY + y] = {}
			end
			for z = 0, 4 do
				a_Output[a_OutX + x][a_OutY + y][a_OutZ + z] = 1 -- stone
			end
		end
	end

	if (not self.m_Visited) then
		return
	end

	for x = 1, 3 do
		for y = 1, 3 do
			for z = 1, 3 do
				a_Output[a_OutX + x][a_OutY + y][a_OutZ + z] = 0 -- air
			end
		end
	end
end



function cCell:CreateCrossings(a_Output, a_OutX, a_OutY, a_OutZ)
	if (not self.m_Visited) then
		return
	end

	-- top: 1; down: 2; right: 3; left: 4; backward: 5; foward: 6

	-- top
	local isOpen = self:IsOpen(1)
	if isOpen then
		for x = 1, 3 do
			for z = 1, 3 do
				a_Output[a_OutX + x][a_OutY + 4][a_OutZ + z] = 0
			end
		end
	end

	-- forward
	isOpen = self:IsOpen(6)
	if isOpen then
		for x = 1, 3 do
			for y = 1, 3 do
				a_Output[a_OutX + x][a_OutY + y][a_OutZ + 4] = 0
			end
		end
	end

	-- right
	isOpen = self:IsOpen(3)
	if isOpen then
		for z = 1, 3 do
			for y = 1, 3 do
				a_Output[a_OutX + 4][a_OutY + y][a_OutZ + z] = 0
			end
		end
	end
end



function cCell:IsOpen(a_ToCheck)
	if ((self.m_Neighbors[a_ToCheck] ~= nil) and (self.m_Walls[a_ToCheck] == nil)) then
		return true
	else
		return false
	end
end



function cCell:CreateLadder(a_Output, a_OutX, a_OutY, a_OutZ)
	if (self.m_Neighbors[1] == nil or self.m_Walls[1] ~= nil) then
		return
	end

	-- Create stone
	for y = 1, 4 do
		a_Output[a_OutX + 2][a_OutY + y][a_OutZ + 2] = 1
	end

	-- Create ladders
	for z = 1, 3, 2 do
		for y = 1, 4 do
			if (z == 1) then
				a_Output[a_OutX + 2][a_OutY + y][a_OutZ + z] = { 65, 2 }
			else
				a_Output[a_OutX + 2][a_OutY + y][a_OutZ + z] = { 65, 3 }
			end
		end
	end

	for x = 1, 3, 2 do
		for y = 1, 4 do
			if (x == 1) then
				a_Output[a_OutX + x][a_OutY + y][a_OutZ + 2] = { 65, 4 }
			else
				a_Output[a_OutX + x][a_OutY + y][a_OutZ + 2] = { 65, 5 }
			end
		end
	end
end



function cCell:CreateChest(a_Chests, a_OutX, a_OutY, a_OutZ)
	if
	(
		(self.m_Neighbors[1] ~= nil) and (self.m_Walls[1] == nil) or
		(self.m_Neighbors[2] ~= nil) and (self.m_Walls[2] == nil)
	) then
		return
	end

	if (math.random(100) <= 70) then
		return
	end

	local items = cItems()
	for x = 1, 10 do
		local item = CHESTCONTENT[math.random(#CHESTCONTENT)]
		items:Add(cItem(item))
		if (item == E_ITEM_BOW) then
			items:Add(cItem(E_ITEM_ARROW, 16))
		end

		if (math.random() > 0.3) then
			break
		end
	end

	items:Add(cItem(E_ITEM_BAKED_POTATO, 6))
	items:Add(cItem(E_BLOCK_TORCH, 9))

	table.insert(a_Chests, { a_OutX + 2,  a_OutY + 1, a_OutZ + 2, math.random(2, 5), items })
end



function cCell:CreateMobSpawner(a_MobSpawners, a_OutX, a_OutY, a_OutZ)
	if
	(
		(self.m_Neighbors[1] ~= nil) and (self.m_Walls[1] == nil) or
		(self.m_Neighbors[2] ~= nil) and (self.m_Walls[2] == nil)
	) then
		return
	end

	if (math.random(100) <= 70) then
		return
	end

	local mobTypes = { mtSkeleton, mtSpider, mtZombie, mtCaveSpider }
	table.insert(a_MobSpawners, { a_OutX + 2,  a_OutY + 1, a_OutZ + 2, mobTypes[math.random(#mobTypes)] })
end
