extends Node2D

export var sizeX :int #Width
export var sizeY :int #Height
export var gridScale :int

export var offsetX :int
export var offsetY :int
var offsetVector :Vector2
var noise :OpenSimplexNoise

var matrix = []
var configurations = {
	0000: [],
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
	bin2int("1011"): ["g", "f"],
	
	# 4 Dots
	bin2int("1111"): []
}



func _ready():
	offsetVector = Vector2(offsetX, offsetY)
	
	noise = OpenSimplexNoise.new()
	randomize()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8
	
	print(configurations)
	
	createGridWithRandomValues()
	update()

func _process(_delta):
	pass

func createGridWithRandomValues():	
	matrix.clear()
	matrix = []		
	for x in range(sizeX):
		matrix.append([])
		matrix[x].resize(sizeX)
		
		for y in range(sizeY):
			var noiseValue = noise.get_noise_2d(x, y)
			if noiseValue > 0:
				matrix[x][y] = 1
			else:
				matrix[x][y] = 0
	
func _draw():
	# Dots
	for x in range(sizeX):
		for y in range(sizeY):
			if matrix[x][y] == 0:
				draw_circle(Vector2(x, y) * gridScale + offsetVector, 5, Color.whitesmoke)
			else:
				draw_circle(Vector2(x, y) * gridScale + offsetVector, 5, Color.blue)
				
	# Marching Squares
	for x in range(0, sizeX - 1):
		for y in range(0, sizeY - 1):
			
			# Corner Point Values
			var a = matrix[x]    [y]
			var b = matrix[x + 1][y]
			var c = matrix[x + 1][y + 1]
			var d = matrix[x]	 [y + 1]
			
			# is filled or empty
			if(a == b and b == c and c == d):
				continue
			
			# Corner Point Positions
			var aPos = Vector2(x, y) 		* gridScale + offsetVector
			var bPos = Vector2(x + 1, y)	* gridScale + offsetVector
			var cPos = Vector2(x + 1, y + 1)* gridScale + offsetVector
			var dPos = Vector2(x, y + 1)	* gridScale + offsetVector
			
			# Connection Points
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
			
			# Convert into configuration
			var configuration :int = a * pow(2,0) + b * pow(2,1) + c * pow(2, 2) + d * pow(2, 3)
			var pointsToConnect :Array = configurations[configuration]
			
			#print("Configuration: ", configuration)
			
			for i in range(0, pointsToConnect.size(), 2):
				var pointA = pointsToConnect[i]
				var pointB = pointsToConnect[i + 1]
				
				var pointAVec = dicPoints[pointA]
				var pointBVec = dicPoints[pointB]
							
				#print("Connecting Points: ", pointA, "-", pointB)
				#print("Vectors: ", pointAVec, "-", pointBVec)

				
				draw_line(pointAVec, pointBVec, Color.red, 2)


func bin2int(bin_str):
	var out = 0
	
	for c in bin_str:
		out = (out << 1) + int(c == "1")
		
	return out
