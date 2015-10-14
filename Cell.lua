cCell = {}
cCell.__index = cCell

function cCell.new(a_Y, a_X)
	local self = setmetatable({}, cCell)
	
	self.m_Y = a_Y	
	self.m_X = a_X
	self.m_Visited = false
	self.m_Walls = {} -- top: 1; right: 2; down: 3; left: 4
	self.m_Neighbors = {}
	
	return self
end



function cCell:SetNeighbors()
	if (self.m_Y > 1) then
		self.m_Walls[1] = 1
		self.m_Neighbors[1] = maze[self.m_Y - 1][self.m_X]
	end
	
	if (self.m_X > 1) then
		self.m_Walls[4] = 4
		self.m_Neighbors[4] = maze[self.m_Y][self.m_X - 1]
	end
	
	if (self.m_Y < #maze) then
		self.m_Walls[3] = 3
		self.m_Neighbors[3] = maze[self.m_Y + 1][self.m_X]
	end
	
	if (self.m_X < #maze[1]) then
		self.m_Walls[2] = 2
		self.m_Neighbors[2] = maze[self.m_Y][self.m_X + 1]
	end
end 



function cCell:GetRandomNeigbor()
	local left = {}
	
	for x = 1, 4 do
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
	
	for x = 1, 4 do
		if ((self.m_Neighbors[x] ~= nil) and (self.m_Neighbors[x].m_Visited) and (self.m_Walls[x] == nil)) then
			table.insert(left, x)
		end
	end
    return left
end


function cCell:GetLeft()
	local left = {}
	
	for x = 1, 4 do
		if ((self.m_Neighbors[x] ~= nil) and (self.m_Walls[x] ~= nil)) then
			table.insert(left, x)
		end
	end
	
	return #left
end


function cCell:Fill(a_Out, a_OY, a_OX)
	for y = 0, 2 do
		if (a_Out[a_OY + y] == nil) then
			a_Out[a_OY + y] = {}
		end
		for x = 0, 2 do
			a_Out[a_OY + y][a_OX + x] = "#"
		end
	end

	if (not self.m_Visited) then
		return
	end
	
	
	a_Out[a_OY][a_OX + 1] = self:IsOpen(1) -- 1/2
	a_Out[a_OY + 1][a_OX] = self:IsOpen(4) -- 2/1
	a_Out[a_OY + 1][a_OX + 1] = " " -- 2/2
end


function cCell:IsOpen(a_ToCheck)
	if ((self.m_Neighbors[a_ToCheck] ~= nil) and (self.m_Walls[a_ToCheck] == nil)) then
		return " "
	else
		return "#"
	end
end
