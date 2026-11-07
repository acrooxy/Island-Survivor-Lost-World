extends SceneTree

const Survival = preload("res://scripts/survival.gd")
var failures := 0

func check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: "+label)
	else:
		push_error("FAIL: "+label)
		failures += 1

func _initialize() -> void:
	var s = Survival.new()
	s.save_prefix = "user://unit-test"
	s.tick(60,false)
	check(s.needs.Hunger == 77 and s.needs.Thirst == 75,"exact hunger and thirst intervals")
	check(s.needs.Energy == 100,"standing does not drain energy")
	s.tick(30,true)
	check(s.needs.Energy == 98,"active energy interval")
	check(not s.craft("Stone Axe",false),"cannot craft without materials")
	s.add("wood",3)
	s.add("stone",2)
	check(s.craft("Stone Axe",false),"axe recipe succeeds")
	check(not s.inventory.has("wood") and not s.inventory.has("stone") and s.inventory.get("stone axe") == 1,"recipe consumes exact materials")
	check(s.durability.get("stone axe") == 60,"tool durability assigned")
	var snapshot: Dictionary = s.inventory.duplicate()
	check(not s.consume({"stone axe":1,"iron ore":2}) and s.inventory == snapshot,"failed consumption is atomic")
	s.inventory.clear()
	check(s.add("wood",1000),"20 stacks fit")
	check(not s.add("stone",1) and s.inventory.size() == 1,"21st stack rejected without mutation")
	s.inventory = {"wood":3,"stone":2}
	check(s.save_game(Vector2(123,456),[]),"save returns success")
	var loaded = Survival.new()
	loaded.save_prefix = s.save_prefix
	var data: Dictionary = loaded.load_game()
	check(data.get("position") == [123.0,456.0] and loaded.inventory == s.inventory,"save round trip")
	check(not s.valid_save({"version":1,"inventory":[],"needs":{}}),"malformed schema rejected")
	s.save_game(Vector2(123,456),[])
	var corrupt := FileAccess.open(s.save_prefix+".json",FileAccess.WRITE)
	corrupt.store_string('{"version":1,"inventory":[],"needs":{}}')
	corrupt.close()
	check(not loaded.load_game().is_empty() and loaded.inventory == s.inventory,"corrupt primary recovers valid backup")
	s.needs.Hunger = 0
	s.tick(4,false)
	check(s.needs.Health == 97,"starvation damages health")
	print("RESULT: %d failures" % failures)
	quit(1 if failures else 0)
