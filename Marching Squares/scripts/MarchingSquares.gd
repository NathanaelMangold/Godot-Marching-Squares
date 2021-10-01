extends Node2D

var sizeX :int = 20 	#Width
var sizeY :int = 20 	#Height
var gridScale :int = 25

var dotSize :float = 2.5
var gridOffsetVector :Vector2 = Vector2(75, 75)

# Noise function and configuration
var noise :OpenSimplexNoise
var noiseOctaves = 4
var noisePeriod = 20.0
var noisePersistence = 0.8
var noiseOffsetVector = Vector2.ZERO

# Colors for displaying
export var dotColorFilled :Color
export var dotColorEmpty :Color
export var lineColor :Color

# Value of each point that the Algorithm checks
var matrix = []

# All possible configurations for each square with the
# corresponding connected points
var configurations = {
	0: [],
	bin2int("1111"): [],
	
	# 1 Dot
	bin2int("0001"): ["e", "h"],
	bin2int("0010"): ["e", "f"],
	bin2int("0100"): ["f", "g"],
	bin2int("1000"): ["g", "h"],
	
	# 2 Dots
	bin2int("0011"): ["h", "f"],
	bin2int("0110"): ["e", "g"],
	bin2int("1100"): ["h", "f"],
	bin2int("1001"): ["e", "g"],
	
	bin2int("0101"): ["h", "e", "g", "f"],
	bin2int("1010"): ["h", "g", "e", "f"],
	
	# 3 Dots
	bin2int("0111"): ["h", "g"],
	bin2int("1110"): ["h", "e"],
	bin2int("1101"): ["e", "f"],
	bin2int("1011"): ["g", "f"]
}

func _ready() -> void:
	# Randomize Godot Seed
	randomize()
	
	# Random Noise Function
	noise = OpenSimplexNoise.new()
	noise.seed = randi()

func updateValues() -> void:
	updateGridValues()
	update()

# Updates the values in the grid with the current noise offset to make it "move"
func updateGridValues() -> void:	
	matrix.clear()
	matrix = []
	for x in range(sizeX):
		matrix.append([])
		matrix[x].resize(sizeY)
		
		for y in range(sizeY):
			var noiseValue = noise.get_noise_2d(x + noiseOffsetVector.x, y + noiseOffsetVector.y)
			if noiseValue > 0:
				matrix[x][y] = 1
			else:
				matrix[x][y] = 0

func _draw() -> void:
	# Dots
	for x in range(matrix.size()):
		for y in range(matrix[x].size()):
			if matrix[x][y] == 0:
				draw_circle(Vector2(x, y) * gridScale + gridOffsetVector, dotSize, dotColorEmpty)
			else:
				draw_circle(Vector2(x, y) * gridScale + gridOffsetVector, dotSize, dotColorFilled)

	# Marching Squares Algorithm	
	for x in range(0, matrix.size() - 1):
		for y in range(0, matrix[x].size() -1):
			
			# Corner point values
			var a = matrix[x]    [y]
			var b = matrix[x + 1][y]
			var c = matrix[x + 1][y + 1]
			var d = matrix[x]	 [y + 1]
			
			# If all values are 0 or 1 it can be skipped
			if(a == b and b == c and c == d):
				continue
			
			# Corner point positions
			var aPos = Vector2(x, y) 		* gridScale + gridOffsetVector
			var bPos = Vector2(x + 1, y)	* gridScale + gridOffsetVector
			var cPos = Vector2(x + 1, y + 1)* gridScale + gridOffsetVector
			var dPos = Vector2(x, y + 1)	* gridScale + gridOffsetVector
			
			# Position of the connection points
			var e = ((bPos - aPos) / 2) + aPos
			var f = ((cPos - bPos) / 2) + bPos
			var g = ((dPos - cPos) / 2) + cPos
			var h = ((dPos - aPos) / 2) + aPos
			
			var dicPoints = {
				"e": e,
				"f": f,
				"g": g,
				"h": h
			}
			
			# Convert values into configuration
			var configuration :int = a * pow(2,0) + b * pow(2,1) + c * pow(2, 2) + d * pow(2, 3)
			var pointsToConnect :Array = configurations[configuration]
			
			# Draw the lines out of the configurations
			for i in range(0, pointsToConnect.size(), 2):
				var pointA = pointsToConnect[i]
				var pointB = pointsToConnect[i + 1]
				
				var pointAPos = dicPoints[pointA]
				var pointBPos = dicPoints[pointB]

				draw_line(pointAPos, pointBPos, lineColor, 2)

# Converts a binary string into the corresponding int value
func bin2int(bin_str) -> int:
	var out :int = 0
	
	for c in bin_str:
		out = (out << 1) + int(c == "1")
		
	return out
