PLUGIN = nil
MAZES = {}

-- bad, bad random generator
math.randomseed(os.time())
math.random(); math.random(); math.random()

function Initialize(a_Plugin)
	a_Plugin:SetName("MazeGenerator")
	a_Plugin:SetVersion(1)

	PLUGIN = a_Plugin

	-- Hooks
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_DESTROYED, OnPlayerDestroyed)

	-- Command Bindings
	cPluginManager.BindCommand("/maze", "mazegenerator.command", CommandMazeGenerator , " - access to the maze commands")

	LOG("Initialised " .. a_Plugin:GetName() .. " v." .. a_Plugin:GetVersion())
	return true
end



function OnDisable()
	LOG(PLUGIN:GetName() .. " is shutting down...")
end



function OnPlayerDestroyed(a_Player)
	-- Remove maze
	MAZES[a_Player:GetName()] = nil
	-- collectgarbage()
end



function CommandMazeGenerator(a_Split, a_Player)
	-- Check param
	if ((#a_Split == 1)) then
		a_Player:SendMessage("/maze gen x - Generate a maze with x for all sizes")
		a_Player:SendMessage("/maze gen x z - Generate a maze with x and z and one height")
		a_Player:SendMessage("/maze gen x y z - Generate a maze with x, y and z")
		a_Player:SendMessage("/maze pos - Set a paste location, using your location")
		a_Player:SendMessage("/maze paste - Pastes the maze at the location")
		return true
	end

	if (a_Split[2] == "gen") then
		-- Remove maze
		if (MAZES[a_Player:GetName()] ~= nil) then
			MAZES[a_Player:GetName()] = nil
			-- collectgarbage()
		end

		if ((#a_Split ~= 3) and (#a_Split ~= 4) and (#a_Split ~= 5)) then
			a_Player:SendMessage("/maze gen x - Generate a maze with x for all sizes")
			a_Player:SendMessage("/maze gen x z - Generate a maze with x and z and one height")
			a_Player:SendMessage("/maze gen x y z - Generate a maze with x, y and z")
			return true
		end

		local sizeX, sizeY, sizeZ

		if (#a_Split == 3) then
			local sizeAll = tonumber(a_Split[3])
			if (sizeAll == nil) then
				a_Player:SendMessage("Input is not a number.")
				return true
			end
			sizeX = sizeAll
			sizeY = sizeAll
			sizeZ = sizeAll
		end

		if (#a_Split == 4) then
			sizeX = tonumber(a_Split[3])
			sizeY = 1
			sizeZ = tonumber(a_Split[4])
			if ((sizeX == nil) or (sizeZ == nil)) then
				a_Player:SendMessage("Only numbers are allowed.")
				return true
			end
		end

		if (#a_Split == 5) then
			sizeX = tonumber(a_Split[3])
			sizeY = tonumber(a_Split[4])
			sizeZ = tonumber(a_Split[5])
			if ((sizeX == nil) or (sizeY == nil) or (sizeZ == nil)) then
				a_Player:SendMessage("Only numbers are allowed.")
				return true
			end
		end

		local maze = c3DMaze.new(sizeX, sizeY, sizeZ)
		MAZES[a_Player:GetName()] = maze

		a_Player:SendMessage("Maze generated.")
		return true
	end


	if (a_Split[2] == "pos") then
		local maze = MAZES[a_Player:GetName()]
		if (maze == nil) then
			a_Player:SendMessage("You have no maze generated.")
			return true
		end

		maze:SetPos(a_Player:GetPosX(), a_Player:GetPosY(), a_Player:GetPosZ())
		a_Player:SendMessage("Position has been set.")
		return true
	end


	if (a_Split[2] == "paste") then
		local maze = MAZES[a_Player:GetName()]
		if (maze == nil) then
			a_Player:SendMessage("You have no maze generated.")
			return true
		end

		if (maze.m_PosX == nil) then
			a_Player:SendMessage("No place position has been set. Use /maze pos first.")
			return true
		end

		maze:Paste(a_Player:GetWorld())
		a_Player:SendMessage("Maze has been placed.")
		return true
	end

	return true
end
