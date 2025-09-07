extends Node
class_name NameVerifier
var pokemon_names: Array = []

func _ready():
	load_pokemon_names()

func load_pokemon_names():
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_names_loaded)
	http.request("https://pokeapi.co/api/v2/pokemon?limit=10000")

func _on_names_loaded(result: int, code: int, headers: PackedStringArray, body: PackedByteArray):
	if code != 200:
		push_error("Failed to fetch Pokémon names")
		return
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var data = json.get_data()
	for entry in data["results"]:
		pokemon_names.append(entry["name"])

func levenshtein(s1: String, s2: String) -> int:
	if s1.length() < s2.length():
		return levenshtein(s2, s1)
	
	if s2.length() == 0:
		return s1.length()
	
	var previous_row: Array = []
	for i in range(s2.length() + 1):
		previous_row.append(i)
	
	for i in range(s1.length()):
		var current_row: Array = [i + 1]
		var c1: String = s1[i]
		for j in range(s2.length()):
			var c2: String = s2[j]
			var insertions: int = previous_row[j + 1] + 1
			var deletions: int = current_row[j] + 1
			var substitutions: int = previous_row[j] + (1 if c1 != c2 else 0)
			current_row.append(min(insertions, deletions, substitutions))
		previous_row = current_row
	
	return previous_row[-1]

func find_best_match(input_str: String, string_list: Array = pokemon_names, threshold: float = 0.8) -> String:
	print_debug("name verifier called")
	var best_match: String = ""
	var max_similarity: float = 0.0
	
	for s in string_list:
		var dist: int = levenshtein(input_str, s)
		var longer: int = max(input_str.length(), s.length())
		var sim: float = 1.0 - (float(dist) / longer) if longer > 0 else 0.0
		if sim > max_similarity:
			max_similarity = sim
			best_match = s
	
	if max_similarity >= threshold:
		print_debug("returning best match ",best_match)
		return best_match
	else:
		print_debug("no match found")
		return ""
