MazeGenerator V1
===========

MazeGenerator lua plugin for Cuberite, the c++ minecraft server.

###How to use
1) /maze gen 10 - Generates a maze with x, y, z = 10.  
2) /maze pos - Set a paste position, uses player's position  
3) /maze paste - Pastes the maze  


###Calculation of blocks
For x, y, z = 10. This would be 68.921 blocks to be placed.  
Calculation: ((sizeX * 4 + 1) * (sizeY * 4 + 1) * (sizeZ * 4 + 1))  

###NOTE
To avoid server and client freeze, the plugin denies the generation of mazes greater than 226.981 blocks.

