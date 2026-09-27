extends Node2D
## Controla la cámara, la generación de plataformas, la puntuación y el Game Over.

const PlatformScene := preload("res://scenes/platform.tscn")
const Platform := preload("res://scripts/platform.gd")

const MAX_GAP := 200.0          # separación máxima entre plataformas sólidas (salto ≈ 270 px)
const SAVE_PATH := "user://save.cfg"
const GRID_SPACING := 20.0
const BG_COLOR := Color(0.98, 0.96, 0.89)
const GRID_COLOR := Color(0.85, 0.82, 0.72, 0.6)

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var platforms: Node2D = $Platforms
@onready var score_label: Label = $HUD/ScoreLabel
@onready var game_over_panel: Control = $HUD/GameOver
@onready var game_over_label: Label = $HUD/GameOver/Label

var screen_size: Vector2
var highest_y: float
var start_y: float
var score: int = 0
var best: int = 0
var is_game_over: bool = false


func _ready() -> void:
	randomize()
	screen_size = get_viewport_rect().size
	RenderingServer.set_default_clear_color(BG_COLOR)
	_load_best()

	camera.position = screen_size / 2.0
	player.position = Vector2(screen_size.x / 2.0, screen_size.y - 100.0)
	start_y = player.position.y

	# Plataforma inicial justo debajo del jugador
	highest_y = player.position.y + 40.0
	_spawn_platform(Vector2(screen_size.x / 2.0, highest_y), Platform.Type.NORMAL)
	_generate()
	_update_score_label()


func _process(_delta: float) -> void:
	if is_game_over:
		if Input.is_action_just_pressed("ui_accept") or Input.is_physical_key_pressed(KEY_R):
			get_tree().reload_current_scene()
		return

	# La cámara solo sube, nunca baja
	camera.position.y = minf(camera.position.y, player.position.y - 50.0)

	var height_score := int((start_y - player.position.y) / 10.0)
	if height_score > score:
		score = height_score
		_update_score_label()

	_generate()
	_cleanup()
	queue_redraw()

	if player.position.y > camera.position.y + screen_size.y / 2.0 + 60.0:
		_game_over()


func _difficulty() -> float:
	return clampf(score / 3000.0, 0.0, 1.0)


func _generate() -> void:
	var top := camera.position.y - screen_size.y / 2.0 - 200.0
	while highest_y > top:
		var d := _difficulty()
		var min_gap := lerpf(45.0, 100.0, d)
		var max_gap := lerpf(95.0, MAX_GAP, d)
		var prev_y := highest_y
		highest_y -= randf_range(min_gap, max_gap)

		# Plataforma sólida (siempre alcanzable)
		var type := Platform.Type.NORMAL
		if randf() < lerpf(0.05, 0.35, d):
			type = Platform.Type.MOVING
		var spring := type == Platform.Type.NORMAL and randf() < 0.07
		_spawn_platform(Vector2(_random_x(), highest_y), type, spring)

		# Plataforma frágil extra entre medias (trampa)
		if prev_y - highest_y > 70.0 and randf() < lerpf(0.1, 0.3, d):
			var y := randf_range(highest_y + 30.0, prev_y - 30.0)
			_spawn_platform(Vector2(_random_x(), y), Platform.Type.BREAKING)


func _random_x() -> float:
	var half := Platform.WIDTH / 2.0 + 5.0
	return randf_range(half, screen_size.x - half)


func _spawn_platform(pos: Vector2, type: int, spring: bool = false) -> void:
	var p = PlatformScene.instantiate()
	p.position = pos
	platforms.add_child(p)
	p.setup(type, spring, _difficulty())


func _cleanup() -> void:
	var limit := camera.position.y + screen_size.y / 2.0 + 100.0
	for p in platforms.get_children():
		if p.position.y > limit:
			p.queue_free()


func _update_score_label() -> void:
	score_label.text = "%d" % score


func _game_over() -> void:
	is_game_over = true
	player.set_physics_process(false)
	if score > best:
		best = score
		_save_best()
	game_over_label.text = "GAME OVER\n\nPuntuación: %d\nRécord: %d\n\nPulsa Enter o R para reiniciar" % [score, best]
	game_over_panel.visible = true


func _load_best() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best = cfg.get_value("score", "best", 0)


func _save_best() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("score", "best", best)
	cfg.save(SAVE_PATH)


func _draw() -> void:
	# Fondo de papel cuadriculado que sigue a la cámara
	var top := camera.position.y - screen_size.y / 2.0
	var start := floorf(top / GRID_SPACING) * GRID_SPACING
	var rows := int(screen_size.y / GRID_SPACING) + 2
	for i in rows:
		var y := start + i * GRID_SPACING
		draw_line(Vector2(0, y), Vector2(screen_size.x, y), GRID_COLOR, 1.0)
	var x := 0.0
	while x <= screen_size.x:
		draw_line(Vector2(x, top), Vector2(x, top + screen_size.y), GRID_COLOR, 1.0)
		x += GRID_SPACING
