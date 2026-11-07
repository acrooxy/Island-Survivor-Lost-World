extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game = load("res://main.tscn").instantiate()
	game.model.save_prefix = "user://capture-only"
	root.add_child(game)
	game.player = Vector2(440,1530)
	game.camera.position = game.player
	game.model.needs = {"Health":100.0,"Hunger":80.0,"Thirst":80.0,"Energy":100.0}
	game.set_process(false)
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://docs/screenshots")
	root.get_texture().get_image().save_png("res://docs/screenshots/beach-development.png")
	game.show_craft()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/screenshots/crafting-development.png")
	print("CAPTURE: actual rendered beach and crafting screenshots saved")
	game.queue_free()
	await process_frame
	quit()
