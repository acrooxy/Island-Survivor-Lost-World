extends SceneTree

var failures := 0
var game: Node

func check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: "+label)
	else:
		push_error("FAIL: "+label)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	game = load("res://main.tscn").instantiate()
	game.model.save_prefix = "user://integration-test"
	root.add_child(game)
	game.set_process(false)
	game.paused = false
	game.model.inventory.clear()
	game.model.structures.clear()
	game.model.quest = 0
	check(game.resources.size() > 200,"six-region resource population")
	var reachable := true
	for r in game.resources:
		reachable = reachable and game.valid_ground(Vector2(r.x,r.y))
	check(reachable,"all generated resources on valid ground")
	game.player = Vector2(440,1530)
	var initial: Vector2 = game.player
	var event := InputEventKey.new()
	event.physical_keycode = KEY_D
	event.keycode = KEY_D
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	game._process(0.25)
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	check(game.player.x > initial.x,"keyboard movement through actual process loop")
	var crab: Dictionary = game.animals[0]
	crab.p = game.player
	crab.hp = 15.0
	var hp: float = game.model.needs.Health
	game.update_animals(0.1)
	check(crab.state == "Idle" and game.model.needs.Health == hp,"healthy crab does not attack starting player")
	for a in game.animals:
		a.p = a.home
	# Fixture materials bypass gathering time; this is progression logic coverage.
	game.model.inventory = {"wood":300,"stone":100,"leaves":70,"fibre":60,"iron ore":20,"rope":40}
	game.check_quest()
	game.check_quest()
	check(game.model.quest == 2,"first two material objectives")
	game.model.craft("Stone Axe",false)
	game.check_quest()
	game.selected_building = "Basic Shelter"
	game.place_building()
	game.check_quest()
	check(game.has_structure("Basic Shelter") and game.model.quest == 4,"shelter placement and chapter one progression")
	var count: int = game.model.structures.size()
	var before: Dictionary = game.model.inventory.duplicate()
	game.selected_building = "Campfire"
	game.place_building()
	check(game.model.structures.size() == count and game.model.inventory == before,"overlapping building rejects without costs")
	for step in range(4,19):
		var q: Array = game.QUESTS[step]
		if q[2] == "region":
			game.model.discoveries.append(q[3])
		elif q[2] in game.BUILDINGS:
			game.model.structures.append({"kind":q[2],"x":1000.0+step*4,"y":1400.0,"last":0.0,"storage":{}})
		elif q[2] == "expedition notes":
			game.player = game.CENTRES[1]
			game.interact()
		elif q[2] == "ancient key":
			game.player = game.CENTRES[4]
			game.interact()
		elif q[2] == "radio parts":
			game.player = game.CENTRES[5]
			game.interact()
		else:
			game.model.inventory[q[2]] = q[3]
		game.check_quest()
		check(game.model.quest == step+1,"quest %d progression" % (step+1))
	game.use_structure({"kind":"Raft","x":1500,"y":1500})
	check(game.ended and game.model.quest == 20,"ending reachable through 20-step progression fixture")
	game.panel.hide()
	game.paused = false
	game._process(0.1)
	check(game.model.quest == 20,"free exploration after ending")
	game.model.needs.Health = 0
	game.respawn()
	check(game.model.needs.Health == 100 and game.model.needs.Thirst == 60 and game.grace == 25,"respawn resets needs and grants protection")
	game.save_now(false)
	var loaded = load("res://scripts/survival.gd").new()
	loaded.save_prefix = "user://integration-test"
	loaded.load_game()
	check(loaded.structures.size() == game.model.structures.size(),"placed structures survive save round trip")
	print("RESULT: %d failures" % failures)
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
