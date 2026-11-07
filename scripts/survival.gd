extends RefCounted

var balance: Dictionary
var inventory: Dictionary = {}
var needs: Dictionary = {"Health":100.0,"Hunger":80.0,"Thirst":80.0,"Energy":100.0}
var timers: Dictionary = {"Hunger":0.0,"Thirst":0.0,"Energy":0.0}
var elapsed := 0.0
var structures: Array = []
var discoveries: Array = [0]
var quest := 0
var durability: Dictionary = {}
var save_prefix := "user://island"

func _init() -> void:
	balance = JSON.parse_string(FileAccess.get_file_as_string("res://data/balance.json"))

func slots(items: Dictionary) -> int:
	var count := 0
	for amount in items.values():
		count += int(ceil(float(amount) / float(balance.stack_limit)))
	return count

func add(item: String, amount: int) -> bool:
	var next := inventory.duplicate()
	next[item] = int(next.get(item,0)) + amount
	if amount < 0 or slots(next) > int(balance.inventory_slots):
		return false
	inventory = next
	return true

func consume(cost: Dictionary) -> bool:
	for key in cost:
		if int(inventory.get(key,0)) < int(cost[key]):
			return false
	for key in cost:
		inventory[key] -= int(cost[key])
		if inventory[key] == 0:
			inventory.erase(key)
	return true

func craft(item: String, building: bool) -> bool:
	if not balance.recipes.has(item):
		return false
	var before := inventory.duplicate()
	if not consume(balance.recipes[item]):
		return false
	if not building:
		var result := item.to_lower()
		if not add(result,1):
			inventory = before
			return false
		if item in ["Stone Axe","Stone Pickaxe","Fishing Rod"]:
			durability[result] = 60
	return true

func tick(delta: float, active: bool) -> void:
	elapsed += delta
	for stat in timers:
		if stat == "Energy" and not active:
			continue
		timers[stat] += delta
		var interval := float(balance[stat.to_lower()+"_seconds"])
		while timers[stat] >= interval:
			timers[stat] -= interval
			needs[stat] = maxf(0,needs[stat]-1)
	if needs.Hunger <= 0 or needs.Thirst <= 0:
		needs.Health = maxf(0,needs.Health-delta*0.75)

func save_game(position: Vector2, resources: Array) -> bool:
	var data := {"version":1,"inventory":inventory,"needs":needs,"timers":timers,"elapsed":elapsed,"structures":structures,"discoveries":discoveries,"quest":quest,"durability":durability,"position":[position.x,position.y],"resources":resources}
	var file := FileAccess.open(save_prefix+".tmp",FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	if FileAccess.file_exists(save_prefix+".json"):
		DirAccess.copy_absolute(save_prefix+".json",save_prefix+".bak")
	return DirAccess.rename_absolute(save_prefix+".tmp",save_prefix+".json") == OK

func load_game() -> Dictionary:
	for path in [save_prefix+".json",save_prefix+".bak"]:
		if not FileAccess.file_exists(path):
			continue
		var data = JSON.parse_string(FileAccess.get_file_as_string(path))
		if not valid_save(data):
			continue
		inventory = data.inventory
		for item in inventory:
			inventory[item] = int(inventory[item])
		for key in needs:
			needs[key] = clampf(float(data.needs.get(key,80)),0,100)
		timers = data.get("timers",timers)
		elapsed = float(data.get("elapsed",0))
		structures = data.get("structures",[])
		discoveries = data.get("discoveries",[0])
		quest = clampi(int(data.get("quest",0)),0,20)
		durability = data.get("durability",{})
		return data
	return {}

func number(value: Variant) -> bool:
	return (value is float or value is int) and is_finite(float(value))

func valid_save(data: Variant) -> bool:
	if not data is Dictionary or data.get("version") != 1:
		return false
	if not data.get("inventory") is Dictionary or not data.get("needs") is Dictionary:
		return false
	for item in data.inventory:
		if not item is String or not number(data.inventory[item]) or float(data.inventory[item]) <= 0 or float(data.inventory[item]) > 1000:
			return false
	if slots(data.inventory) > int(balance.inventory_slots):
		return false
	for key in needs:
		if not number(data.needs.get(key)):
			return false
	if not data.get("position") is Array or data.position.size() != 2:
		return false
	for coordinate in data.position:
		if not number(coordinate) or float(coordinate) < 0 or float(coordinate) > 2048:
			return false
	if not number(data.get("elapsed")) or float(data.elapsed) < 0:
		return false
	if not data.get("timers") is Dictionary:
		return false
	for key in timers:
		if not number(data.timers.get(key)) or float(data.timers[key]) < 0:
			return false
	for key in ["structures","discoveries","resources"]:
		if not data.get(key) is Array:
			return false
	if data.structures.size() > 500 or data.resources.size() > 2000:
		return false
	for s in data.structures:
		if not s is Dictionary or not s.get("kind") is String or not number(s.get("x")) or not number(s.get("y")) or not number(s.get("last")) or not s.get("storage") is Dictionary:
			return false
		for item in s.storage:
			if not number(s.storage[item]) or float(s.storage[item]) < 0:
				return false
	for r in data.resources:
		if not r is Dictionary or not number(r.get("x")) or not number(r.get("y")) or not number(r.get("ready")) or not r.get("item") is String:
			return false
	for region in data.discoveries:
		if not number(region) or int(region) < 0 or int(region) > 5:
			return false
	if not number(data.get("quest")) or not data.get("durability") is Dictionary:
		return false
	for amount in data.durability.values():
		if not number(amount):
			return false
	return true
