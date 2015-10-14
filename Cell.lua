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



function cCell:SetNeighbors()
	if (self.m_X > 1) then
		self.m_Walls[4] = 4 -- left
		self.m_Neighbors[4] = maze[self.m_X - 1][self.m_Y][self.m_Z]
	end
	
	if (self.m_X < sizeX) then
		self.m_Walls[3] = 3 -- right
		self.m_Neighbors[3] = maze[self.m_X + 1][self.m_Y][self.m_Z]
	end
	
	
	if (self.m_Y > 1) then
		self.m_Walls[2] = 2 -- down
		self.m_Neighbors[2] = maze[self.m_X][self.m_Y - 1][self.m_Z]
	end
	
	if (self.m_Y < sizeY) then
		self.m_Walls[1] = 1 -- top
		self.m_Neighbors[1] = maze[self.m_X][self.m_Y + 1][self.m_Z]
	end
	
	
	if (self.m_Z > 1) then
		self.m_Walls[5] = 5 -- backward
		self.m_Neighbors[5] = maze[self.m_X][self.m_Y][self.m_Z - 1]
	end
	
	if (self.m_Z < sizeZ) then
		self.m_Walls[6] = 6 -- forward
		self.m_Neighbors[6] = maze[self.m_X][self.m_Y][self.m_Z + 1]
	end
end 



function cCell:GetRandomNeigbor()
	local left = {}
	
	for x = 1, 6 do
		if ((self.m_Neighbors[x] ~= nil) and (not self.m_Neighbors[x].m_Visited) and (self.m_Walls[x] ~= nil)) then
			table.insert(left, x)
		end
	end
	
	if (#left == 0) then return nil end
	
	local rnd = left[math.random(#left)]
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


function cCell:CreateCells(a_Out, a_OutX, a_OutY, a_OutZ)
	for x = 0, 4 do
		if (a_Out[a_OutX + x] == nil) then
			a_Out[a_OutX + x] = {}
		end
		for y = 0, 4 do
			if (a_Out[a_OutX + x][a_OutY + y] == nil) then
				a_Out[a_OutX + x][a_OutY + y] = {}
			end
			for z = 0, 4 do
				a_Out[a_OutX + x][a_OutY + y][a_OutZ + z] = "#"
			end
		end
	end

	if (not self.m_Visited) then
		return
	end
	
	for x = 1, 3 do
		for y = 1, 3 do
			for z = 1, 3 do
				a_Out[a_OutX + x][a_OutY + y][a_OutZ + z] = " "
			end
		end
	end
end



function cCell:CreateCrossings(a_Out, a_OutX, a_OutY, a_OutZ)
	if (not self.m_Visited) then
		return
	end
	
	-- top: 1; down: 2; right: 3; left: 4; backward: 5; foward: 6
	
	-- top
	for x = 1, 3 do
		for z = 1, 3 do
			a_Out[a_OutX + x][a_OutY + 4][a_OutZ + z] = self:IsOpen(1)
		end
	end
	
	-- forward
	for x = 1, 3 do
		for y = 1, 3 do
			a_Out[a_OutX + x][a_OutY + y][a_OutZ + 4] = self:IsOpen(6)
		end
	end
	
	-- right
	for z = 1, 3 do
		for y = 1, 3 do
			a_Out[a_OutX + 4][a_OutY + y][a_OutZ + z] = self:IsOpen(3)
		end
	end
end



function cCell:IsOpen(a_ToCheck)
	if ((self.m_Neighbors[a_ToCheck] ~= nil) and (self.m_Walls[a_ToCheck] == nil)) then
		return " "
	else
		return "#"
	end
end
