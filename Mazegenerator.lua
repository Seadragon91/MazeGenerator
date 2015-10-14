-- bad, bad random generator
math.randomseed(os.time())
math.random(); math.random(); math.random()


-- top: 1; down: 2; right: 3; left: 4; backward: 5; foward: 6
function OpenWall(a_CurrentCell, a_Dir, a_NewCell)
	a_CurrentCell.m_Walls[a_Dir] = nil
	
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



function GetInvDir(a_Dir)
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



function WriteMaze()
	local file = io.open("laby.txt", "w")
	
	for x = 1, #out do
		for y = 1, #out[x] do
			for z = 1, #out[x][y] do
				if (out[x][y][z] == " ") then
					local str = (x - 1) .. ":" .. (y - 1) .. ":" .. (z - 1) .. ":0"
					file:write(str .. "\n")
				elseif (out[x][y][z] == "#") then
					local str = (x - 1) .. ":" .. (y - 1) .. ":" .. (z - 1) .. ":1"
					file:write(str .. "\n")
				else
					local str = (x - 1) .. ":" .. (y - 1) .. ":" .. (z - 1) .. ":" .. out[x][y][z]
					file:write(str .. "\n")
				end
			end
		end
	end

	file:close()
end


--- Main ---
require "Cell"
require "Stack"


--- Globals ---
maze = {}
out = {}
stack = cStack.new()

-- Initialization --
print("--- Initialize maze ---")

allSize = 7
sizeX = allSize or 5
sizeY = allSize or 1
sizeZ = allSize or 5

if allSize then
	print("Size: " .. allSize)
else
	print("Size: x = " .. sizeX .. " y = " .. sizeY .. " z = " .. sizeZ)
end


print("Create cells...")
-- Create cells
for x = 1, sizeX do
	maze[x] = {}
	for y = 1, sizeY do
		maze[x][y] = {}
		for z = 1, sizeZ do
			maze[x][y][z] = cCell.new(x, y, z)
		end
	end
end



print("Get Neighbors...")
-- Get Neighbors
for x = 1, sizeX do
	for y = 1, sizeY do
		for z = 1, sizeZ do
			maze[x][y][z]:SetNeighbors()
		end
	end
end


--- Maze algorithm ---
print("")
print("--- Generate maze ---")

-- Algorithm: Growing tree


local randCells = {}
table.insert(randCells, maze[math.random(sizeX)][math.random(sizeY)][math.random(sizeZ)])

while true do
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



print("Create output...")
outX = 1
outY = 1
outZ = 1
for x = 1, sizeX do
	for y = 1, sizeY do
		for z = 1, sizeZ do
			local cell = maze[x][y][z]
			cell:CreateCells(out, outX, outY, outZ)
			outZ = outZ + 4
		end
		outY = outY + 4
		outZ = 1
	end
	outX = outX + 4
	outY = 1
end



print("Generate crossings...")
-- Generate crossings
outX = 1
outY = 1
outZ = 1
for x = 1, sizeX do
	for y = 1, sizeY do
		for z = 1, sizeZ do
			local cell = maze[x][y][z]
			cell:CreateCrossings(out, outX, outY, outZ)
			outZ = outZ + 4
		end
		outY = outY + 4
		outZ = 1
	end
	outX = outX + 4
	outY = 1
end


WriteMaze()
print("Maze written to file...")
