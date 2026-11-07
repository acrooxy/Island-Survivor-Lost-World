extends Node2D

const Survival = preload("res://scripts/survival.gd")
const AudioFactory = preload("res://scripts/audio_factory.gd")
const REGIONS = ["Sunbreak Beach","Emerald Jungle","Cloudpeak Mountains","Whispering Swamp","Ancient Ruins","Hidden Cove"]
const CENTRES = [Vector2(480,1500),Vector2(700,1000),Vector2(1400,550),Vector2(1350,1100),Vector2(650,500),Vector2(1520,1500)]
const COLOURS = [Color("e7c983"),Color("398b54"),Color("80969a"),Color("537e68"),Color("849962"),Color("ddbd78")]
const BUILDINGS = ["Campfire","Basic Shelter","Water Collector","Workbench","Wooden Chest","Raft","Wooden Cabin","Farming Plot","Defensive Fence","Radio Station"]
const QUESTS = [
	["The Awakening","Gather 3 wood","wood",3], ["The Awakening","Gather 2 stone","stone",2],
	["The Awakening","Craft a stone axe","stone axe",1], ["The Awakening","Build a basic shelter","Basic Shelter",1],
	["Into the Jungle","Discover the jungle","region",1], ["Into the Jungle","Gather 3 fibre","fibre",3],
	["Into the Jungle","Make 2 rope","rope",2], ["Into the Jungle","Build a water collector","Water Collector",1],
	["The Signal","Discover the mountains","region",2], ["The Signal","Craft a stone pickaxe","stone pickaxe",1],
	["The Signal","Gather 6 iron ore","iron ore",6], ["The Signal","Read the jungle journal","expedition notes",1],
	["The Lost Expedition","Discover the swamp","region",3], ["The Lost Expedition","Gather 3 herbs","herbs",3],
	["The Lost Expedition","Discover the ruins","region",4], ["The Lost Expedition","Solve the ancient seal","ancient key",1],
	["Escape or Stay","Discover the hidden cove","region",5], ["Escape or Stay","Recover 3 radio parts","radio parts",3],
	["Escape or Stay","Build a radio station","Radio Station",1], ["Escape or Stay","Build a raft and use it","escape",1]
]

var model = Survival.new()
var player := Vector2(440,1530)
var camera: Camera2D
var resources: Array = []
var animals: Array = []
var ui: CanvasLayer
var hud: Label
var hint: Label
var journal: Label
var panel: PanelContainer
var panel_body: VBoxContainer
var joystick := Vector2.ZERO
var stick_id := -1
var stick_origin := Vector2(125,590)
var stick_point := Vector2(125,590)
var paused := false
var selected_building := ""
var message := "A new shore. Find wood and stone nearby."
var message_time := 8.0
var autosave := 0.0
var attack_time := 0.0
var poison := 0.0
var grace := 0.0
var phase := 0.0
var weather := "Sunny"
var current_region := 0
var quick := ["coconut","berries","fish","meat","herbs"]
var ended := false
var rng := RandomNumberGenerator.new()
var music: AudioStreamPlayer
var ocean: AudioStreamPlayer
var effect: AudioStreamPlayer
var audio_volume := 0.65

func _ready() -> void:
	rng.seed = 84719
	generate_world()
	var saved: Dictionary = model.load_game()
	if not saved.is_empty():
		player = Vector2(saved.position[0],saved.position[1])
		resources = saved.get("resources",resources)
		if not valid_ground(player):
			player = Vector2(440,1530)
	camera = Camera2D.new()
	camera.position = player
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7
	add_child(camera)
	create_ui()
	setup_audio()
	update_hud()

func setup_audio() -> void:
	# Headless logic suites do not exercise audio playback.
	if DisplayServer.get_name() == "headless":
		return
	var settings := ConfigFile.new()
	if settings.load("user://settings.cfg") == OK:
		audio_volume = clampf(float(settings.get_value("audio","volume",0.65)),0,1)
	music = AudioStreamPlayer.new()
	music.stream = AudioFactory.create("music")
	add_child(music)
	music.play()
	ocean = AudioStreamPlayer.new()
	ocean.stream = AudioFactory.create("ocean")
	add_child(ocean)
	ocean.play()
	effect = AudioStreamPlayer.new()
	effect.stream = AudioFactory.create("effect")
	add_child(effect)
	set_audio_volume(audio_volume)

func set_audio_volume(value: float) -> void:
	audio_volume = clampf(value,0,1)
	if is_instance_valid(music):
		music.volume_db = linear_to_db(maxf(0.00001,audio_volume*0.45))
		ocean.volume_db = linear_to_db(maxf(0.00001,audio_volume*0.6))
		effect.volume_db = linear_to_db(maxf(0.00001,audio_volume*0.55))
	var settings := ConfigFile.new()
	settings.set_value("audio","volume",audio_volume)
	settings.save("user://settings.cfg")

func generate_world() -> void:
	var pools := [["wood","stone","leaves","coconut","fibre"],["wood","leaves","berries","fibre"],["stone","iron ore"],["herbs","fibre","wood"],["stone","herbs"],["wood","stone","fibre"]]
	for region in range(6):
		for i in range(48):
			var p: Vector2 = CENTRES[region] + Vector2(rng.randf_range(-260,260),rng.randf_range(-210,210))
			if not valid_ground(p) or p.distance_to(Vector2(440,1530)) < 45:
				continue
			resources.append({"x":p.x,"y":p.y,"item":pools[region][i % pools[region].size()],"ready":0.0})
	for i in range(20):
		var kind := i % 4
		var base: Vector2 = CENTRES[[0,1,3,2][kind]]
		var p := base + Vector2(rng.randf_range(-190,190),rng.randf_range(-180,180))
		animals.append({"kind":kind,"p":p,"home":p,"hp":[15.0,45.0,20.0,70.0][kind],"state":"Idle","timer":0.0,"cooldown":0.0,"dir":Vector2.RIGHT})

func create_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	var top := PanelContainer.new()
	top.position = Vector2(20,16)
	top.size = Vector2(650,106)
	ui.add_child(top)
	hud = Label.new()
	hud.add_theme_font_size_override("font_size",20)
	top.add_child(hud)
	journal = Label.new()
	journal.position = Vector2(24,132)
	journal.add_theme_font_size_override("font_size",19)
	ui.add_child(journal)
	hint = Label.new()
	hint.position = Vector2(275,654)
	hint.add_theme_font_size_override("font_size",21)
	ui.add_child(hint)
	button("PACK",Vector2(1050,20),func(): show_pack())
	button("CRAFT",Vector2(1050,80),func(): show_craft())
	button("PAUSE",Vector2(1050,140),func(): show_pause())
	button("ACT / E",Vector2(1090,560),func(): interact())
	button("ATTACK",Vector2(925,650),func(): attack())
	button("PLACE",Vector2(1090,630),func(): place_building())
	for i in range(5):
		var index := i
		button(str(i+1)+" "+quick[i].capitalize(),Vector2(280+i*132,558),func(): use_item(quick[index]),Vector2(125,55))
	panel = PanelContainer.new()
	panel.position = Vector2(300,85)
	panel.size = Vector2(650,470)
	ui.add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(650,470)
	panel.add_child(scroll)
	panel_body = VBoxContainer.new()
	panel_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(panel_body)
	panel.hide()

func button(text: String, pos: Vector2, action: Callable, dimensions := Vector2(150,54)) -> void:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = dimensions
	b.add_theme_font_size_override("font_size",18)
	b.pressed.connect(action)
	ui.add_child(b)

func clear_panel(title: String) -> void:
	for child in panel_body.get_children():
		panel_body.remove_child(child)
		child.queue_free()
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size",24)
	panel_body.add_child(label)
	panel.show()
	paused = true
	panel_button("Return to island",func(): panel.hide(); paused = false)

func panel_button(text: String, action: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(620,52)
	b.pressed.connect(action)
	panel_body.add_child(b)

func show_pack() -> void:
	clear_panel("Backpack • %d / 20 slots" % model.slots(model.inventory))
	for item in model.inventory:
		var key: String = item
		panel_button("%s × %d%s" % [item.capitalize(),model.inventory[item]," • use" if item in quick else ""],func(): use_item(key); show_pack())

func show_craft() -> void:
	clear_panel("Craft & build • structures are placed in front of you")
	for recipe in model.balance.recipes:
		var name: String = recipe
		panel_button(name+" • "+str(model.balance.recipes[recipe]),func(): craft(name))

func show_pause() -> void:
	clear_panel("Island Survivor: Lost World")
	panel_button("Save game",func(): save_now())
	panel_button("Credits & engine licences",func(): show_credits())
	var volume := HSlider.new()
	volume.min_value = 0
	volume.max_value = 1
	volume.step = 0.05
	volume.value = audio_volume
	volume.custom_minimum_size = Vector2(600,54)
	volume.value_changed.connect(set_audio_volume)
	var label := Label.new()
	label.text = "Audio volume (left = mute)"
	panel_body.add_child(label)
	panel_body.add_child(volume)
	panel_button("Restart • opens confirmation",func(): clear_panel("Erase this local adventure?"); panel_button("Confirm restart",restart))
	panel_button("Field guide",func(): clear_panel("Move: WASD / arrows / left thumb\nE: gather, drink at shore, use nearby structures\nSpace: attack • 1–5: eat / heal\nCraft structures, then PLACE on clear ground.\nShelters restore energy. Collectors supply safe water.\nRuins: read the seal, then activate it in daylight."))

func show_credits() -> void:
	clear_panel("Island Survivor • original project art and audio")
	for filename in ["Godot-LICENSE.txt","Godot-COPYRIGHT.txt"]:
		var name: String = filename
		panel_button(name,func():
			clear_panel(name)
			var text := Label.new()
			text.custom_minimum_size.x = 600
			text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			text.text = FileAccess.get_file_as_string("res://assets/legal/"+name)
			panel_body.add_child(text))

func notify(text: String) -> void:
	message = text
	message_time = 6
	if is_instance_valid(effect):
		effect.play()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x < 260 and event.position.y > 350 and stick_id == -1:
			stick_id = event.index
			stick_origin = event.position
			stick_point = event.position
		elif not event.pressed and event.index == stick_id:
			stick_id = -1
			joystick = Vector2.ZERO
			stick_origin = Vector2(125,590)
			stick_point = stick_origin
	if event is InputEventScreenDrag and event.index == stick_id:
		stick_point = stick_origin+(event.position-stick_origin).limit_length(66)
		joystick = (stick_point-stick_origin)/66
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_E: interact()
			KEY_SPACE: attack()
			KEY_I: show_pack()
			KEY_C: show_craft()
			KEY_ESCAPE: show_pause()
			KEY_1,KEY_2,KEY_3,KEY_4,KEY_5: use_item(quick[event.keycode-KEY_1])

func _process(delta: float) -> void:
	if paused:
		return
	phase += delta
	var direction := Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	if joystick.length() > 0.1:
		direction = joystick
	var target := player + direction.limit_length(1)*float(model.balance.move_speed)*delta*(0.65 if model.needs.Energy <= 0 else 1.0)
	if valid_ground(target) and not blocked(target):
		player = target
	camera.position = player
	model.tick(delta,direction.length() > 0.1)
	attack_time = maxf(0,attack_time-delta)
	grace = maxf(0,grace-delta)
	if poison > 0:
		poison -= delta
		model.needs.Health = maxf(0,model.needs.Health-delta*0.5)
	message_time -= delta
	weather = ["Sunny","Rain","Storm"][int(model.elapsed/180.0)%3]
	current_region = region_at(player)
	if current_region not in model.discoveries:
		model.discoveries.append(current_region)
		notify("Discovered "+REGIONS[current_region])
	update_animals(delta)
	check_quest()
	if model.needs.Health <= 0:
		respawn()
	autosave += delta
	if autosave >= 45:
		autosave = 0
		save_now(false)
	update_hud()
	queue_redraw()

func valid_ground(p: Vector2) -> bool:
	return p.distance_to(Vector2(1024,1024)) < 960 and p.x > 100 and p.x < 1948 and p.y > 100 and p.y < 1948

func blocked(p: Vector2) -> bool:
	for structure in model.structures:
		if structure.kind in ["Defensive Fence","Wooden Cabin","Wooden Chest","Radio Station"] and p.distance_to(Vector2(structure.x,structure.y)) < 30:
			return true
	return false

func region_at(p: Vector2) -> int:
	var best := 99999.0
	var result := 0
	for i in range(6):
		var d := p.distance_squared_to(CENTRES[i])
		if d < best:
			best = d
			result = i
	return result

func interact() -> void:
	if paused:
		return
	for structure in model.structures:
		if player.distance_to(Vector2(structure.x,structure.y)) < 85:
			use_structure(structure)
			return
	if player.distance_to(CENTRES[1]) < 70 and not model.inventory.has("expedition notes"):
		if model.add("expedition notes",1):
			notify("Journal: We hid the transmitter in the cove. The sun wakes the old seal.")
		return
	if player.distance_to(CENTRES[4]) < 70 and not model.inventory.has("ancient key"):
		if fmod(model.elapsed,720) < 480 and model.inventory.has("expedition notes"):
			model.add("ancient key",1)
			notify("The sun aligns the seal. An ancient key slides free.")
		else:
			notify("The seal reads: knowledge and daylight open the way.")
		return
	if player.distance_to(CENTRES[5]) < 70 and int(model.inventory.get("radio parts",0)) < 3:
		if model.inventory.has("ancient key"):
			model.add("radio parts",3-int(model.inventory.get("radio parts",0)))
			notify("The key opens an expedition cache: transmitter components.")
		else:
			notify("An expedition cache. Its lock bears the ancient seal.")
		return
	var nearest := -1
	var distance := 75.0
	for i in range(resources.size()):
		var r: Dictionary = resources[i]
		var d := player.distance_to(Vector2(r.x,r.y))
		if d < distance and float(r.ready) <= model.elapsed:
			distance = d
			nearest = i
	if nearest >= 0:
		var r: Dictionary = resources[nearest]
		if r.item == "iron ore" and not model.inventory.has("stone pickaxe"):
			notify("Iron needs a stone pickaxe.")
			return
		var tool := "stone pickaxe" if r.item in ["stone","iron ore"] else "stone axe"
		var amount := 3 if model.inventory.has(tool) else 2
		if model.add(r.item,amount):
			r.ready = model.elapsed+150
			model.needs.Energy = maxf(0,model.needs.Energy-0.5)
			wear_tool(tool)
			notify("+%d %s" % [amount,r.item])
		else:
			notify("Backpack full. Use food or store materials.")
	elif player.distance_to(Vector2(1024,1024)) > 810:
		if model.inventory.has("fishing rod"):
			if model.add("fish",1):
				wear_tool("fishing rod")
				notify("Caught a fish. Cook it at a campfire.")
		else:
			notify("Saltwater is unsafe. Coconuts restore thirst; build a collector.")
	else:
		notify("Move closer to a resource, landmark or structure.")

func wear_tool(tool: String) -> void:
	if not model.durability.has(tool):
		return
	model.durability[tool] -= 1
	if model.durability[tool] <= 0:
		model.consume({tool:1})
		model.durability.erase(tool)
		notify(tool.capitalize()+" broke.")

func craft(name: String) -> void:
	if name in ["Wooden Cabin","Radio Station"] and not has_structure("Workbench"):
		notify("Build a workbench first.")
		return
	if name in BUILDINGS:
		selected_building = name
		panel.hide()
		paused = false
		notify("Preview: "+name+". Move to clear ground, then PLACE. Costs paid on placement.")
	elif model.craft(name,false):
		notify("Crafted "+name)
		show_craft()
	else:
		notify("Missing materials or backpack space.")

func place_building() -> void:
	if paused or selected_building.is_empty():
		return
	var p := player+Vector2(0,-66)
	if not valid_ground(p) or blocked(p):
		notify("Choose clear land.")
		return
	for s in model.structures:
		if p.distance_to(Vector2(s.x,s.y)) < 80:
			notify("Too close to another structure.")
			return
	if selected_building == "Raft" and current_region != 5:
		notify("Build the escape raft in Hidden Cove.")
		return
	if model.craft(selected_building,true):
		model.structures.append({"kind":selected_building,"x":p.x,"y":p.y,"last":model.elapsed,"storage":{}})
		notify("Built "+selected_building)
		selected_building = ""
		save_now(false)
	else:
		notify("Not enough materials.")

func has_structure(kind: String) -> bool:
	for s in model.structures:
		if s.kind == kind:
			return true
	return false

func use_structure(s: Dictionary) -> void:
	match s.kind:
		"Basic Shelter","Wooden Cabin":
			if model.elapsed-float(s.last) < 60:
				notify("Rest available in %d seconds." % int(60-(model.elapsed-float(s.last))))
			else:
				model.needs.Energy = minf(100,model.needs.Energy+70)
				s.last = model.elapsed
				notify("Rested. +70 energy. Respawn point set.")
		"Water Collector":
			if model.elapsed-float(s.last) >= 30:
				model.needs.Thirst = minf(100,model.needs.Thirst+45)
				s.last = model.elapsed
				notify("Drank collected rainwater. +45 thirst.")
			else:
				notify("Collector filling. Ready every 30 seconds.")
		"Campfire":
			for food in ["fish","meat"]:
				if model.consume({food:1}):
					model.needs.Hunger = minf(100,model.needs.Hunger+35)
					notify("Cooked and ate "+food+". +35 hunger.")
					return
			notify("Bring fish or meat to cook.")
		"Wooden Chest":
			clear_panel("Storage chest")
			for item in model.inventory:
				var key: String = item
				panel_button("Store all "+key,func(): s.storage[key] = int(s.storage.get(key,0))+int(model.inventory.get(key,0)); model.inventory.erase(key); panel.hide(); paused=false)
			for item in s.storage:
				var key: String = item
				panel_button("Take %s × %d" % [key,s.storage[key]],func(): if model.add(key,int(s.storage[key])): s.storage.erase(key); panel.hide(); paused=false)
		"Farming Plot":
			if model.elapsed-float(s.last) > 120 and model.add("berries",4):
				s.last = model.elapsed
				notify("Harvested berries.")
			else:
				notify("Berries grow every two minutes. Check backpack space.")
		"Radio Station": notify("A ship answers: light a beacon and launch from the cove.")
		"Raft":
			if has_structure("Radio Station") and model.quest >= 19:
				ended = true
				model.quest = 20
				clear_panel("RESCUED • Island Survivor: Lost World\nYour signal reaches the horizon. The expedition's\nstory is safe, and a rescue vessel follows your raft.\nThe island will remain here whenever you return.")
				save_now(false)
			else:
				notify("Finish the expedition and build a radio station first.")
		_: show_craft()

func use_item(item: String) -> void:
	if item not in quick:
		return
	if not model.consume({item:1}):
		notify("No "+item+" in backpack.")
		return
	match item:
		"coconut": model.needs.Hunger=minf(100,model.needs.Hunger+12); model.needs.Thirst=minf(100,model.needs.Thirst+20)
		"berries": model.needs.Hunger=minf(100,model.needs.Hunger+16)
		"fish","meat": model.needs.Hunger=minf(100,model.needs.Hunger+10); notify("Raw food restores less. Try a campfire.")
		"herbs": model.needs.Health=minf(100,model.needs.Health+22); poison=0

func attack() -> void:
	if paused or attack_time > 0:
		return
	attack_time = 0.55
	var damage := 12 if model.inventory.has("stone axe") else 5
	for animal in animals:
		if animal.hp > 0 and player.distance_to(animal.p) < 85:
			animal.hp -= damage
			animal.state = "Flee" if animal.hp < 12 else "Chase"
			if animal.hp <= 0:
				model.add("meat",2)
				if animal.kind == 1:
					model.add("leather",1)
				animal.timer = 180
			wear_tool("stone axe")
			return

func update_animals(delta: float) -> void:
	for a in animals:
		a.cooldown = maxf(0,float(a.cooldown)-delta)
		a.timer -= delta
		if a.hp <= 0:
			if a.timer <= 0:
				a.hp = [15.0,45.0,20.0,70.0][a.kind]
				a.p = a.home
			continue
		if a.kind == 3 and fmod(model.elapsed,720) < 480:
			continue
		var distance: float = player.distance_to(a.p)
		if a.hp < 12:
			a.state = "Flee"
		elif a.p.distance_to(a.home) > 250 or grace > 0:
			a.state = "Return"
		elif distance < 33:
			a.state = "Attack" if a.kind != 0 or a.hp < 15 else "Idle"
		elif distance < (110 if a.kind != 0 else 55):
			a.state = "Chase" if a.kind != 0 or a.hp < 15 else "Idle"
		elif a.timer <= 0:
			a.state = "Wander" if rng.randf() > 0.4 else "Idle"
			a.dir = Vector2.from_angle(rng.randf()*TAU)
			a.timer = rng.randf_range(1,4)
		var move := Vector2.ZERO
		match a.state:
			"Chase": move = (player-a.p).normalized()*70
			"Flee": move = (a.p-player).normalized()*90
			"Return": move = (a.home-a.p).normalized()*55
			"Wander": move = a.dir*28
			"Attack":
				if a.cooldown <= 0 and grace <= 0:
					model.needs.Health -= [3,10,5,15][a.kind]
					a.cooldown = 1.5
					if a.kind == 2:
						poison = 12
		var next: Vector2 = a.p+move*delta
		if valid_ground(next) and not blocked(next):
			a.p = next

func respawn() -> void:
	player = Vector2(440,1530)
	for s in model.structures:
		if s.kind in ["Basic Shelter","Wooden Cabin"]:
			player = Vector2(s.x,s.y)+Vector2(0,65)
	for item in ["wood","stone","leaves","fibre"]:
		if model.inventory.has(item):
			model.inventory[item] = int(ceil(float(model.inventory[item])*0.8))
	model.needs = {"Health":100.0,"Hunger":60.0,"Thirst":60.0,"Energy":70.0}
	poison = 0
	grace = 25
	notify("Recovered at shelter. Lost 20% basic materials; 25s wildlife protection.")
	save_now(false)

func check_quest() -> void:
	if model.quest >= QUESTS.size():
		return
	var q: Array = QUESTS[model.quest]
	var done := false
	if q[2] == "region":
		done = int(q[3]) in model.discoveries
	elif q[2] in BUILDINGS:
		done = has_structure(q[2])
	else:
		done = int(model.inventory.get(q[2],0)) >= int(q[3])
	if done:
		model.quest += 1
		model.needs.Health = minf(100,model.needs.Health+10)
		notify("Quest complete • +10 health")

func update_hud() -> void:
	hud.text = "  ISLAND SURVIVOR  •  Day %d  •  %s\n  Health %d    Hunger %d    Thirst %d    Energy %d\n  %s" % [int(model.elapsed/720)+1,weather,model.needs.Health,model.needs.Hunger,model.needs.Thirst,model.needs.Energy,REGIONS[current_region]]
	journal.text = (QUESTS[model.quest][0]+" • "+QUESTS[model.quest][1]) if model.quest < 20 else "The horizon is yours • Continue exploring"
	hint.text = message if message_time > 0 else "E: interact • C: craft • I: backpack • Space: attack"

func save_now(feedback := true) -> void:
	var ok: bool = model.save_game(player,resources)
	if feedback or not ok:
		notify("Adventure saved." if ok else "Save failed. Check available storage.")

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_now(false)
		paused = true
	if what == NOTIFICATION_APPLICATION_RESUMED and is_instance_valid(panel):
		show_pause()

func _exit_tree() -> void:
	for audio in [music,ocean,effect]:
		if is_instance_valid(audio):
			audio.stop()
			audio.stream = null

func restart() -> void:
	model = Survival.new()
	player = Vector2(440,1530)
	resources.clear()
	animals.clear()
	generate_world()
	poison = 0
	grace = 25
	panel.hide()
	paused = false
	save_now()

func _draw() -> void:
	draw_rect(Rect2(-800,-800,3600,3600),Color("12657c"))
	for i in range(12):
		draw_arc(Vector2(1024,1024),985+i*14+sin(phase)*3,0,TAU,100,Color(0.3,0.76,0.81,0.08),3)
	draw_circle(Vector2(1024,1024),976,Color("76b9ac"))
	draw_circle(Vector2(1024,1024),950,Color("e7c983"))
	for i in range(6):
		draw_circle(CENTRES[i],330,COLOURS[i])
		draw_line(CENTRES[i],Vector2(1024,1024),Color("c5b583"),36,true)
	for r in resources:
		if float(r.ready) > model.elapsed:
			continue
		var p := Vector2(r.x,r.y)
		draw_ellipse_shadow(p,18)
		match r.item:
			"wood","leaves","coconut":
				draw_line(p,p+Vector2(-5,-34),Color("805233"),9,true)
				for j in range(5):
					var tip := p+Vector2(-5,-36)+Vector2.from_angle(j*TAU/5)*26
					draw_line(p+Vector2(-5,-34),tip,Color("245e45"),13,true)
					draw_circle(tip,9,Color("4ea268"))
				if r.item == "coconut":
					draw_circle(p+Vector2(-4,-28),6,Color("b5834c"))
			"stone","iron ore":
				draw_colored_polygon(PackedVector2Array([p+Vector2(-18,5),p+Vector2(-12,-17),p+Vector2(5,-23),p+Vector2(19,-5),p+Vector2(15,9)]),Color("738b92"))
				draw_line(p+Vector2(-10,-14),p+Vector2(3,-18),Color("bacbd0"),4,true)
				if r.item == "iron ore":
					draw_circle(p+Vector2(6,-5),5,Color("d99b6e"))
			_:
				draw_circle(p+Vector2(0,-6),15,Color("3e7950"))
				for j in range(3):
					draw_circle(p+Vector2(j*8-8,-9),4,Color("cf6b70") if r.item == "berries" else Color("a2c475"))
	for i in [1,4,5]:
		var p: Vector2 = CENTRES[i]
		draw_rect(Rect2(p-Vector2(28,26),Vector2(56,46)),Color("625749"))
		draw_rect(Rect2(p-Vector2(23,22),Vector2(46,9)),Color("dfc784"))
		draw_string(ThemeDB.fallback_font,p+Vector2(-43,-36),["Camp journal","Sun seal","Locked cache"][[1,4,5].find(i)],HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color.WHITE)
	for s in model.structures:
		draw_structure(s.kind,Vector2(s.x,s.y),false)
	if not selected_building.is_empty():
		draw_structure(selected_building,player+Vector2(0,-66),true)
	for a in animals:
		if a.hp <= 0 or (a.kind == 3 and fmod(model.elapsed,720) < 480):
			continue
		var p: Vector2 = a.p
		draw_ellipse_shadow(p,20)
		var colour: Color = [Color("dd7757"),Color("a27659"),Color("9eb74f"),Color("5e5778")][a.kind]
		draw_circle(p+Vector2(0,-9),[12,20,10,24][a.kind],colour)
		for side in [-1,1]:
			draw_circle(p+Vector2(side*7,-15),3,Color("fff2cf"))
			draw_circle(p+Vector2(side*7,-15),1.5,Color("263440"))
		draw_line(p+Vector2(-20,-37),p+Vector2(20,-37),Color("493d44"),4)
		draw_line(p+Vector2(-20,-37),p+Vector2(-20+40*a.hp/[15,45,20,70][a.kind],-37),Color("ed9876"),4)
	draw_ellipse_shadow(player,16)
	var bob := sin(phase*9)*1.5
	draw_line(player+Vector2(-6,0),player+Vector2(-7,9+bob),Color("354c60"),7,true)
	draw_line(player+Vector2(6,0),player+Vector2(7,9-bob),Color("354c60"),7,true)
	draw_circle(player+Vector2(0,-10),13,Color("e89559"))
	draw_circle(player+Vector2(0,-26),10,Color("efc698"))
	draw_arc(player+Vector2(0,-29),10,PI,TAU,12,Color("554236"),7,true)
	if attack_time > 0.3:
		draw_arc(player,65,-PI*0.8,-PI*0.1,14,Color("fff0c2"),5,true)
	# Fog hides undiscovered regions; discovered terrain remains visible.
	for i in range(6):
		if i not in model.discoveries:
			draw_circle(CENTRES[i],285,Color(0.05,0.17,0.23,0.88))
	var night := 0.40 if fmod(model.elapsed,720) > 480 else 0.0
	if night > 0:
		draw_rect(Rect2(camera.position-Vector2(700,400),Vector2(1400,800)),Color(0.03,0.07,0.20,night))
	if weather != "Sunny":
		for i in range(65):
			var p := camera.position+Vector2(fmod(i*137.0+phase*45,1400)-700,fmod(i*79.0+phase*400,800)-400)
			draw_line(p,p+Vector2(-5,17),Color(0.7,0.86,0.93,0.45),1)
	# Joystick is drawn in camera-relative screen coordinates.
	var origin := camera.get_screen_center_position()-Vector2(640,360)
	draw_circle(origin+stick_origin,72,Color(0.08,0.18,0.23,0.45))
	draw_arc(origin+stick_origin,72,0,TAU,48,Color(0.8,0.88,0.78,0.6),3,true)
	draw_circle(origin+stick_point,30,Color(0.84,0.91,0.79,0.65))

func draw_ellipse_shadow(p: Vector2, radius: float) -> void:
	draw_set_transform(p,0,Vector2(1,0.45))
	draw_circle(Vector2.ZERO,radius,Color(0.05,0.19,0.16,0.23))
	draw_set_transform(Vector2.ZERO)

func draw_structure(kind: String, p: Vector2, preview: bool) -> void:
	var colour := Color("d8a76c")
	if preview:
		colour = Color(0.6,1,0.7,0.6)
	draw_ellipse_shadow(p,35)
	if kind == "Campfire":
		draw_circle(p,23,Color("7c8182"))
		draw_circle(p,15,Color("f19b4b"))
		draw_circle(p+Vector2(0,-5),9,Color("ffe39a"))
	elif kind in ["Basic Shelter","Wooden Cabin"]:
		draw_rect(Rect2(p-Vector2(28,16),Vector2(56,35)),colour)
		draw_colored_polygon(PackedVector2Array([p+Vector2(-40,-15),p+Vector2(0,-58),p+Vector2(40,-15)]),Color("54855a") if not preview else colour)
		draw_rect(Rect2(p+Vector2(-9,-3),Vector2(18,22)),Color("634e3d"))
	else:
		draw_rect(Rect2(p-Vector2(28,20),Vector2(56,37)),colour)
		draw_line(p+Vector2(-25,-11),p+Vector2(25,-11),Color("7d6749"),4,true)
		if kind == "Radio Station":
			draw_line(p,p+Vector2(0,-65),Color("e4d9b2"),4,true)
			draw_arc(p+Vector2(0,-65),14,0,PI,12,Color("e4d9b2"),3,true)
	draw_string(ThemeDB.fallback_font,p+Vector2(-50,37),kind,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color.WHITE)
