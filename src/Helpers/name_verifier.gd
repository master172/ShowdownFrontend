extends Node
class_name NameVerifier
var pokemon_names:Dictionary[String,String] = {}
const NAME_LIST = preload("res://resources/NameList.tres")

func _ready():
	#load_pokemon_names()
	pokemon_names = NAME_LIST.mapped_list
	#await get_tree().create_timer(2).timeout
	#find_best_match("basculegionf")

func similarity_ratio(s1: String, s2: String) -> float:
	s1 = s1.to_lower()
	s2 = s2.to_lower()
	var matches:int = 0
	var len_sum:int = s1.length() + s2.length()
	
	# Count matching characters in order (simple approximation)
	var i:int = 0
	var j:int = 0
	while i < s1.length() and j < s2.length():
		if s1[i] == s2[j]:
			matches += 2  # each match counts twice for ratio
			i += 1
			j += 1
		else:
			# try to skip a character in the longer string
			if s1.length() - i > s2.length() - j:
				i += 1
			else:
				j += 1
	
	if len_sum == 0:
		return 1.0
	return float(matches) / len_sum


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

func find_best_match(input_str: String, string_list: Dictionary = pokemon_names, threshold: float = 0.7) -> String:
	print_debug("name verifier called")
	input_str = input_str.to_lower()
	var best_match: String = ""
	var max_similarity: float = 0.0
	
	var mapped_name :String = string_list.get(input_str)
	
	if mapped_name != null:
		print_debug("returning name form mapped list: "+mapped_name)
		return mapped_name
		
	for i:String in string_list.values():
		if i.begins_with(input_str):
			print_debug("prefix match found: "+i)
			return i
			
	for s in string_list.values():
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
