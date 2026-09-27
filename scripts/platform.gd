extends StaticBody2D
## Plataforma de un solo sentido. Tipos: normal (verde), móvil (azul), frágil (marrón).
## Las normales pueden llevar un muelle que da un salto mucho más alto.

enum Type { NORMAL, MOVING, BREAKING }

const WIDTH := 70.0
const HEIGHT := 14.0
const SPRING_BOOST := 1.75

var type: Type = Type.NORMAL
var has_spring: bool = false
var move_speed: float = 0.0
var move_dir: int = 1
var broken: bool = false
var fall_speed: float = 0.0
var spring_timer: float = 0.0
var spring_x: float = 0.0
var screen_width: float = 480.0

@onready var shape: CollisionShape2D = $CollisionShape2D


func setup(p_type: Type, p_spring: bool = false, difficulty: float = 0.0) -> void:
	type = p_type
	has_spring = p_spring and type == Type.NORMAL
	spring_x = randf_range(-WIDTH * 0.3, WIDTH * 0.3)
	if type == Type.MOVING:
		move_speed = randf_range(60.0, 120.0) * (1.0 + difficulty)
		move_dir = [-1, 1].pick_random()
	queue_redraw()


func _ready() -> void:
	screen_width = get_viewport_rect().size.x


func _physics_process(delta: float) -> void:
	if broken:
		fall_speed += 1500.0 * delta
		position.y += fall_speed * delta
		modulate.a -= delta * 2.0
		if modulate.a <= 0.0:
			queue_free()
		return

	if type == Type.MOVING:
		position.x += move_speed * move_dir * delta
		var half := WIDTH / 2.0
		if position.x < half:
			position.x = half
			move_dir = 1
		elif position.x > screen_width - half:
			position.x = screen_width - half
			move_dir = -1

	if spring_timer > 0.0:
		spring_timer -= delta
		queue_redraw()


## Devuelve el multiplicador del salto (0 = no rebota).
func on_player_landed(player: Node2D) -> float:
	if type == Type.BREAKING:
		broken = true
		shape.set_deferred("disabled", true)
		queue_redraw()
		return 0.0
	if has_spring and absf(player.global_position.x - (global_position.x + spring_x)) < 20.0:
		spring_timer = 0.3
		queue_redraw()
		return SPRING_BOOST
	return 1.0


func _draw() -> void:
	var rect := Rect2(-WIDTH / 2.0, -HEIGHT / 2.0, WIDTH, HEIGHT)
	var fill: Color
	match type:
		Type.NORMAL: fill = Color(0.45, 0.78, 0.3)
		Type.MOVING: fill = Color(0.35, 0.6, 0.95)
		Type.BREAKING: fill = Color(0.6, 0.42, 0.25)
	var outline := fill.darkened(0.5)

	if type == Type.BREAKING:
		var gap := 8.0 if broken else 0.0
		var half := Rect2(rect.position, Vector2(WIDTH / 2.0, HEIGHT))
		for side in [-1, 1]:
			var r := half
			r.position.x = (rect.position.x if side < 0 else 0.0) + side * gap
			draw_rect(r, fill)
			draw_rect(r, outline, false, 2.0)
		if not broken:
			draw_polyline(PackedVector2Array([Vector2(0, -7), Vector2(-3, -1), Vector2(3, 2), Vector2(0, 7)]), outline, 2.0)
		return

	draw_rect(rect, fill)
	draw_rect(rect, outline, false, 2.0)

	if has_spring:
		var h := 22.0 if spring_timer > 0.0 else 10.0
		var base := Vector2(spring_x, -HEIGHT / 2.0)
		var pts := PackedVector2Array()
		var coils := 4
		for i in coils * 2 + 1:
			var x := -6.0 if i % 2 == 0 else 6.0
			pts.append(base + Vector2(x, -h * float(i) / float(coils * 2)))
		draw_polyline(pts, Color(0.4, 0.4, 0.45), 2.5)
		draw_rect(Rect2(base + Vector2(-8, -h - 3), Vector2(16, 3)), Color(0.4, 0.4, 0.45))
