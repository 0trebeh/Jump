extends CharacterBody2D
## Jugador: rebota automáticamente al caer sobre una plataforma,
## se mueve a izquierda/derecha y aparece por el lado contrario al salir de la pantalla.

@export var gravity: float = 1500.0
@export var jump_velocity: float = -900.0   # altura máx. ≈ v² / 2g ≈ 270 px
@export var move_speed: float = 380.0
@export var acceleration: float = 2400.0

const HALF_WIDTH := 22.0
const BODY_COLOR := Color(1.0, 0.62, 0.2)
const OUTLINE_COLOR := Color(0.25, 0.15, 0.08)

var facing: int = 1
var squash: float = 0.0
var screen_width: float = 480.0


func _ready() -> void:
	screen_width = get_viewport_rect().size.x


func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("ui_left", "ui_right")
	if Input.is_physical_key_pressed(KEY_A):
		dir -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		dir += 1.0
	dir = clampf(dir, -1.0, 1.0)

	velocity.x = move_toward(velocity.x, dir * move_speed, acceleration * delta)
	if dir != 0.0:
		facing = 1 if dir > 0.0 else -1

	velocity.y += gravity * delta
	move_and_slide()

	if velocity.y >= 0.0 and is_on_floor():
		_land()

	# Wrap-around horizontal
	position.x = wrapf(position.x, -HALF_WIDTH, screen_width + HALF_WIDTH)

	squash = move_toward(squash, 0.0, delta * 1.5)
	queue_redraw()


func _land() -> void:
	var multiplier := 1.0
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider and collider.has_method("on_player_landed"):
			multiplier = collider.on_player_landed(self)
			break
	if multiplier > 0.0:
		velocity.y = jump_velocity * multiplier
		squash = 0.25


func _draw() -> void:
	# Aplastamiento al rebotar
	draw_set_transform(Vector2(0, 20), 0.0, Vector2(1.0 + squash, 1.0 - squash))
	var o := Vector2(0, -20)
	# Pies
	draw_rect(Rect2(o + Vector2(-13, 36), Vector2(9, 6)), OUTLINE_COLOR)
	draw_rect(Rect2(o + Vector2(4, 36), Vector2(9, 6)), OUTLINE_COLOR)
	# Cuerpo
	draw_circle(o + Vector2(0, 16), 21.0, OUTLINE_COLOR)
	draw_circle(o + Vector2(0, 16), 19.0, BODY_COLOR)
	# Ojos (miran hacia donde se mueve)
	var eye_offset := Vector2(5 * facing, 0)
	for ex in [-7.0, 7.0]:
		var eye := o + Vector2(ex, 10) + eye_offset
		draw_circle(eye, 6.0, Color.WHITE)
		draw_circle(eye + Vector2(2 * facing, 1), 3.0, OUTLINE_COLOR)
	draw_set_transform(Vector2.ZERO)
