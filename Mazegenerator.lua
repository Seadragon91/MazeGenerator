-- bad, bad random generator
math.randomseed(os.time())
math.random(); math.random(); math.random()

function OpenWall(a_CurrentCell, a_Dir, a_NewCell)
	a_CurrentCell.m_Walls[a_Dir] = nil
	
	if (a_Dir == 1) then
		a_NewCell.m_Walls[3] = nil	
	elseif (a_Dir == 2) then
		a_NewCell.m_Walls[4] = nil
	elseif (a_Dir == 3) then
		a_NewCell.m_Walls[1] = nil  
	elseif (a_Dir == 4) then
		a_NewCell.m_Walls[2] = nil
	end
end


function GetInvDir(a_Dir)
	if (a_Dir == 1) then
		return 3
	elseif (a_Dir == 2) then
		return 4
	elseif (a_Dir == 3) then
		return 1
	elseif (a_Dir == 4) then
		return 2
	end
end


function printMaze()
	local oy = 1
	local ox = 1
	for y = 1, sizeY do
		for x = 1, sizeX do
			local cell = maze[y][x]
			if (cell.m_Char ~= nil) then
				out[oy + 2][ox + 2] = cell.m_Char
			end
			ox = ox + 4
		end
		oy = oy + 4
		ox = 1
	end
	
		
	for y = 1, #out do
		local str = ""
		for x = 1, #out[y] do
			str = str .. out[y][x]
		end
		print(str)
	end
end


function Write()
	print(#out)
	local file = io.open("laby.txt", "w")

	-- Create ground
	for y = 1, #out do
		for x = 1, #out[y] do
			local str = (x - 1) .. ":0:" .. (y - 1).. ":1"
			file:write(str .. "\n")
		end
	end
	
	for y = 1, #out do
		for x = 1, #out[y] do
			if (out[y][x] == " ") then
				local str = (x - 1) .. ":1:" .. (y - 1) .. ":0"
				file:write(str .. "\n")
			elseif (out[y][x] == "#") then
				local str = (x - 1) .. ":1:" .. (y - 1).. ":1"
				file:write(str .. "\n")
			end
		end
	end
	
	file:close()
end


--- main ---
require "Cell"
require "Stack"


--- globals ---
maze = {}
out = {}
stack = cStack.new()

-- generate --

sizeX = 19
sizeY = 20


-- Create cells
for y = 1, sizeY do
	maze[y] = {}
	for x = 1, sizeX do
		maze[y][x] = cCell.new(y, x)
	end
end



-- Get Neighbors
for y = 1, sizeY do
	for x = 1, sizeX do
		maze[y][x]:SetNeighbors()
	end
end


local randCells = {}
table.insert(randCells, maze[math.random(sizeY)][math.random(sizeY)])

while true do -- visitedCells < maxAmount do
	currentCell = randCells[#randCells]
	if (#randCells == 0) then
		break
	end
	
	local newCell, dir = currentCell:GetRandomNeigbor()
	if (newCell ~= nil) then
		table.insert(randCells, newCell)
		OpenWall(currentCell, dir, newCell)
		currentCell.m_Visited = true
		newCell.m_Visited = true
	elseif (newCell == nil) then
		randCells[#randCells] = nil	
	end
end


-- Fill maze
oy = 1
ox = 1
for y = 1, sizeY do
	for x = 1, sizeX do
		local cell = maze[y][x]
		cell:Fill(out, oy, ox)
		ox = ox + 4
	end
	oy = oy + 4
	
	ox = 1
end
-- Write()

local currentCell = maze[1][1]
currentCell.m_Char = "."
add = false
stack = cStack.new()
cells = {}

while true do
	local leftNeighs = currentCell:GetOpenNeighbors()
	if (#leftNeighs == 1) then
		currentCell.m_Char = "."
		
		newCell = currentCell.m_Neighbors[leftNeighs[1]]
		newCell.m_Neighbors[GetInvDir(leftNeighs[1])] = nil
		currentCell.m_Neighbors[leftNeighs[1]] = nil
		
		if add then
			cells[stack.m_Stack[#stack.m_Stack]]:Push(currentCell)
		end

		currentCell = newCell
	elseif (#leftNeighs > 1) then
		stack:Push(currentCell)
		cells[currentCell] = cStack.new()
		add = true
		
		currentCell.m_Char = "."
		
		newCell = currentCell.m_Neighbors[leftNeighs[1]]
		newCell.m_Neighbors[GetInvDir(leftNeighs[1])] = nil
		currentCell.m_Neighbors[leftNeighs[1]] = nil
		
		currentCell = newCell
	else
		if (#stack.m_Stack == 0) then break end
		
		local newCell = stack:Pop()
		
		local reset = cells[newCell].m_Stack
		cells[newCell] = nil
		currentCell.m_Char = " "
		for _, cell in pairs(reset) do
			cell.m_Char = " "
		end
		add = false
		
		currentCell = newCell
	end
	
	if (currentCell.m_X == sizeX) and (currentCell.m_Y == sizeY) then break end
end

printMaze()

