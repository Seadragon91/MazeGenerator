c3DMaze = {}
c3DMaze.__index = c3DMaze

function c3DMaze.new(a_SizeX, a_SizeY, a_SizeZ)
	local self = setmetatable({}, c3DMaze)

	self.m_SizeX = a_SizeX
	self.m_SizeY = a_SizeY
	self.m_SizeZ = a_SizeZ
	self.m_Maze = {}
	self.m_Output = {}
	self.m_Chests = {}
	self.m_MobSpawner = {}

	self:CreateCells()
	self:SetNeighbors()
	self:Generate()
	self:CreateOutput()
	self:CreateCrossings()
	self:CreateLadders()
	self:CreateSpecificBlocks()

	return self
end



function c3DMaze:WriteMazeToFile()
	local file = assert(io.open("laby.txt", "w"))

	for x = 1, #self.m_Output do
		for y = 1, #self.m_Output[x] do
			for z = 1, #self.m_Output[x][y] do
				file:write((x - 1) .. ":" .. (y - 1) .. ":" .. (z - 1) .. ":" .. self.m_Output[x][y][z] .. "\n")
			end
		end
	end

	file:close()
	collectgarbage() -- clean up file handle
end



function c3DMaze:CreateCells()
	for x = 1, self.m_SizeX do
		self.m_Maze[x] = {}
		for y = 1, self.m_SizeY do
			self.m_Maze[x][y] = {}
			for z = 1, self.m_SizeZ do
				self.m_Maze[x][y][z] = cCell.new(x, y, z)
			end
		end
	end
end



function c3DMaze:SetNeighbors()
	for x = 1, self.m_SizeX do
		for y = 1, self.m_SizeY do
			for z = 1, self.m_SizeZ do
				self.m_Maze[x][y][z]:SetNeighbors(self.m_Maze, self.m_SizeX, self.m_SizeY, self.m_SizeZ)
			end
		end
	end
end



function c3DMaze:Generate()
	-- Algorithm: Growing tree, modified

	local cells = {}
	table.insert(cells, self.m_Maze[math.random(self.m_SizeX)][math.random(self.m_SizeY)][math.random(self.m_SizeZ)])

	local index = 0
	while true do
		if (#cells == 0) then
			-- No more cells left, end reached
			break
		end

		local currentCell
		if (math.random(100) <= 80) then
			currentCell = cells[#cells]
			index = #cells
		else
			index = math.random(#cells)
			currentCell = cells[index]
		end

		local randCell, dir = currentCell:GetRandomNeigbor()
		if (randCell ~= nil) then
			table.insert(cells, randCell)
			self:OpenWall(currentCell, dir, randCell)
		else
			-- No more neighbors left in currentCell, remove currentCell from list
			table.remove(cells, index)
		end
	end
end



function c3DMaze:CreateOutput()
	local outX = 1
	local outY = 1
	local outZ = 1
	for x = 1, self.m_SizeX do
		for y = 1, self.m_SizeY do
			for z = 1, self.m_SizeZ do
				local cell = self.m_Maze[x][y][z]
				cell:CreateBorders(self.m_Output, outX, outY, outZ)
				outZ = outZ + 4
			end
			outY = outY + 4
			outZ = 1
		end
		outX = outX + 4
		outY = 1
	end
end



function c3DMaze:CreateCrossings()
	local outX = 1
	local outY = 1
	local outZ = 1
	for x = 1, self.m_SizeX do
		for y = 1, self.m_SizeY do
			for z = 1, self.m_SizeZ do
				local cell = self.m_Maze[x][y][z]
				cell:CreateCrossings(self.m_Output, outX, outY, outZ)
				outZ = outZ + 4
			end
			outY = outY + 4
			outZ = 1
		end
		outX = outX + 4
		outY = 1
	end
end



function c3DMaze:CreateLadders()
	local outX = 1
	local outY = 1
	local outZ = 1
	for x = 1, self.m_SizeX do
		for y = 1, self.m_SizeY do
			for z = 1, self.m_SizeZ do
				local cell = self.m_Maze[x][y][z]
				cell:CreateLadder(self.m_Output, outX, outY, outZ)
				outZ = outZ + 4
			end
			outY = outY + 4
			outZ = 1
		end
		outX = outX + 4
		outY = 1
	end
end


function c3DMaze:CreateSpecificBlocks()
	local outX = 1
	local outY = 1
	local outZ = 1
	for x = 1, self.m_SizeX do
		for y = 1, self.m_SizeY do
			for z = 1, self.m_SizeZ do
				if (math.random(1, 2) == 1) then
					self.m_Maze[x][y][z]:CreateChest(self.m_Chests, outX, outY, outZ)
				else
					self.m_Maze[x][y][z]:CreateMobSpawner(self.m_MobSpawner, outX, outY, outZ)
				end
				outZ = outZ + 4
			end
			outY = outY + 4
			outZ = 1
		end
		outX = outX + 4
		outY = 1
	end
end



function c3DMaze:SetPos(a_PosX, a_PosY, a_PosZ)
	self.m_PosX = a_PosX
	self.m_PosY = a_PosY
	self.m_PosZ = a_PosZ
end



function c3DMaze:Paste(a_World)
	local area = cBlockArea()
	area:Create(#self.m_Output, #self.m_Output[1], #self.m_Output[1][1])

	local block
	for x = 1, #self.m_Output do
		for y = 1, #self.m_Output[1] do
			for z = 1, #self.m_Output[1][1] do
				block = self.m_Output[x][y][z]
				if (type(block) == "table") then
					area:SetBlockTypeMeta(x - 1, y - 1, z - 1, block[1], block[2])
				else
					area:SetBlockType(x - 1, y - 1, z - 1, block)
				end
			end
		end
	end

	area:Write(a_World, self.m_PosX, self.m_PosY, self.m_PosZ)

	-- Place specific blocks
	for _, spawner in pairs(self.m_MobSpawner) do
		local x, y, z = spawner[1] + self.m_PosX - 1, spawner[2] + self.m_PosY - 1, spawner[3] + self.m_PosZ - 1
		a_World:SetBlock(x, y, z, E_BLOCK_MOB_SPAWNER, 0)
		a_World:DoWithBlockEntityAt(x, y, z,
			function(a_MobSpawner)
				local mobSpawner = tolua.cast(a_MobSpawner, "cMobSpawnerEntity")
				mobSpawner:SetEntity(spawner[4])
			end)
	end

	for _, chest in pairs(self.m_Chests) do
		local x, y, z = chest[1] + self.m_PosX - 1, chest[2] + self.m_PosY - 1, chest[3] + self.m_PosZ - 1
		a_World:SetBlock(x, y, z, E_BLOCK_CHEST, chest[4])
		a_World:DoWithChestAt(x, y, z,
			function(a_Chest)
				a_Chest:GetContents():AddItems(chest[5])
			end)
	end
end



-- top: 1; down: 2; right: 3; left: 4; backward: 5; foward: 6
function c3DMaze:OpenWall(a_CurrentCell, a_Dir, a_NewCell)
	a_CurrentCell.m_Walls[a_Dir] = nil

	a_CurrentCell.m_Visited = true
	a_NewCell.m_Visited = true

	if (a_Dir == 1) then
		a_NewCell.m_Walls[2] = nil
	elseif (a_Dir == 2) then
		a_NewCell.m_Walls[1] = nil
	elseif (a_Dir == 3) then
		a_NewCell.m_Walls[4] = nil
	elseif (a_Dir == 4) then
		a_NewCell.m_Walls[3] = nil
	elseif (a_Dir == 5) then
		a_NewCell.m_Walls[6] = nil
	elseif (a_Dir == 6) then
		a_NewCell.m_Walls[5] = nil
	end
end



function c3DMaze:GetInvDir(a_Dir)
	if (a_Dir == 1) then
		return 2
	elseif (a_Dir == 2) then
		return 1
	elseif (a_Dir == 3) then
		return 4
	elseif (a_Dir == 4) then
		return 3
	elseif (a_Dir == 5) then
		return 6
	elseif (a_Dir == 6) then
		return 5
	end
end
