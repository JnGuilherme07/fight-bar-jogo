extends CharacterBody2D

signal health_changed(current_health, max_value)
signal combo_status_changed(text)

@export var speed: float = 260.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1100.0
@export var max_health: int = 100
@export var player_number: int = 1
@export var arena_min_x: float = 80.0
@export var arena_max_x: float = 1200.0

var facing: int = 1
var health: int = max_health
var attack_cooldown: float = 0.0
var attack_timer: float = 0.0
var current_attack: String = ""
var enemy: CharacterBody2D
var spawn_position: Vector2 = Vector2(240, 570)

var move_left: int = KEY_A
var move_right: int = KEY_D
var jump_key: int = KEY_W
var crouch_key: int = KEY_S
var light_key: int = KEY_J
var heavy_key: int = KEY_K
var special_key: int = KEY_L

var combo_window: float = 0.0
var combo_count: int = 0
var special_ready: bool = false
var special_sequence: Array[String] = []
var hit_flash_timer: float = 0.0
var hit_knockback: Vector2 = Vector2.ZERO
var is_crouching: bool = false
var collision_shape: CollisionShape2D
var light_pressed: bool = false
var heavy_pressed: bool = false
var special_pressed: bool = false
var sprite: AnimatedSprite2D

func _load_texture(path: String) -> Texture2D:
	var resolved_path: String = ProjectSettings.globalize_path(path)
	var image := Image.new()
	if image.load(resolved_path) == OK:
		var texture := ImageTexture.create_from_image(image)
		if texture != null:
			return texture
	return null

func _create_strip_frames(animation_name: String, path: String, frame_count_hint: int = 0) -> void:
	var texture: Texture2D = _load_texture(path)
	if texture == null:
		return

	var frames := SpriteFrames.new()
	if sprite != null and sprite.sprite_frames != null:
		frames = sprite.sprite_frames

	if not frames.has_animation(animation_name):
		frames.add_animation(animation_name)

	var columns: int = frame_count_hint
	if columns <= 0:
		columns = max(1, int(texture.get_width() / 80.0))

	var frame_width: float = max(1.0, texture.get_width() / float(columns))
	var frame_height: float = texture.get_height()
	for index in range(columns):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(index * frame_width, 0.0, frame_width, frame_height)
		frames.add_frame(animation_name, atlas)

	frames.set_animation_loop(animation_name, animation_name != "attack" and animation_name != "hurt" and animation_name != "ko")
	frames.set_animation_speed(animation_name, 10)
	if sprite != null:
		sprite.sprite_frames = frames

func _ready() -> void:
	if player_number == 2:
		move_left = KEY_LEFT
		move_right = KEY_RIGHT
		jump_key = KEY_UP
		crouch_key = KEY_DOWN
		light_key = KEY_N
		heavy_key = KEY_M
		special_key = KEY_COMMA
		spawn_position = Vector2(1040, 570)
		add_to_group("player_2")
	else:
		move_left = KEY_A
		move_right = KEY_D
		jump_key = KEY_W
		crouch_key = KEY_S
		light_key = KEY_J
		heavy_key = KEY_K
		special_key = KEY_L
		add_to_group("player")

	enemy = get_parent().get_node_or_null("Player2") if player_number == 1 else get_parent().get_node_or_null("Player")
	if enemy == null:
		enemy = get_parent().get_node_or_null("Enemy")

	if player_number == 2:
		collision_shape = get_node("Player2Collision")
	else:
		collision_shape = get_node("PlayerCollision")

	sprite = get_node_or_null("AnimatedSprite2D")
	if sprite != null:
		_create_strip_frames("idle", "res://sprites/daniel-san-init.png", 4)
		_create_strip_frames("walk", "res://sprites/daniel-san-andando.png", 5)
		_create_strip_frames("attack", "res://sprites/daniel-san-ataque.png", 7)
		_create_strip_frames("hurt", "res://sprites/daniel-san-dano.png", 3)
		_create_strip_frames("ko", "res://sprites/daniel-san-derrotado.png", 5)
		_create_strip_frames("jump", "res://sprites/daniel-san-pulo.png", 6)
		sprite.centered = true
		sprite.offset = Vector2(0, -30)
		sprite.flip_h = false
		sprite.animation = "idle"
		sprite.play()

	position = spawn_position
	emit_signal("health_changed", health, max_health)
	emit_signal("combo_status_changed", "Combo: -")

func _physics_process(delta: float) -> void:
	if attack_cooldown > 0.0:
		attack_cooldown = max(0.0, attack_cooldown - delta)
	if attack_timer > 0.0:
		attack_timer = max(0.0, attack_timer - delta)
		if attack_timer == 0.0:
			current_attack = ""
	if combo_window > 0.0:
		combo_window = max(0.0, combo_window - delta)
		if combo_window == 0.0:
			combo_count = 0
			special_ready = false
			special_sequence.clear()
			emit_signal("combo_status_changed", "Combo: -")
	if hit_flash_timer > 0.0:
		hit_flash_timer = max(0.0, hit_flash_timer - delta)
	if hit_knockback.length() > 0.1:
		velocity.x += hit_knockback.x * delta * 8.0
		velocity.y += hit_knockback.y * delta * 8.0
		hit_knockback = hit_knockback.move_toward(Vector2.ZERO, 100.0 * delta)

	var move_dir: int = 0
	if Input.is_key_pressed(move_left):
		move_dir -= 1
	if Input.is_key_pressed(move_right):
		move_dir += 1

	if move_dir != 0:
		facing = move_dir

	if sprite != null:
		sprite.flip_h = facing < 0
		var next_animation: String = "idle"
		if current_attack != "":
			next_animation = "attack"
		elif not is_on_floor():
			next_animation = "jump"
		elif hit_flash_timer > 0.0:
			next_animation = "hurt"
		elif move_dir != 0:
			next_animation = "walk"
		elif health <= 0:
			next_animation = "ko"
		if sprite.animation != next_animation and sprite.sprite_frames != null and sprite.sprite_frames.has_animation(next_animation):
			sprite.animation = next_animation
			sprite.play()

	is_crouching = is_on_floor() and Input.is_key_pressed(crouch_key)
	if is_crouching:
		velocity.x = move_dir * speed * 0.6
	else:
		velocity.x = move_dir * speed

	if collision_shape != null and collision_shape.shape != null:
		var standing_size: Vector2 = Vector2(60, 100)
		var crouched_size: Vector2 = Vector2(60, 70)
		var target_size: Vector2 = crouched_size if is_crouching else standing_size
		collision_shape.shape.size = target_size
		collision_shape.position = Vector2(0, 10 if is_crouching else 0)

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if Input.is_key_pressed(jump_key):
			velocity.y = jump_velocity

	var light_kdown: bool = Input.is_key_pressed(light_key)
	var heavy_kdown: bool = Input.is_key_pressed(heavy_key)
	var special_kdown: bool = Input.is_key_pressed(special_key)

	var light_trigger: bool = light_pressed and not light_kdown
	var heavy_trigger: bool = heavy_pressed and not heavy_kdown
	var special_trigger: bool = special_pressed and not special_kdown

	if light_trigger:
		register_input("light")
		try_attack("light")
	if heavy_trigger:
		register_input("heavy")
		try_attack("heavy")
	if special_trigger:
		register_input("jump")
		try_special()

	light_pressed = light_kdown
	heavy_pressed = heavy_kdown
	special_pressed = special_kdown

	move_and_slide()
	global_position.x = clamp(global_position.x, arena_min_x, arena_max_x)

func get_attack_variant() -> String:
	if not is_on_floor():
		return "air"
	if Input.is_key_pressed(crouch_key):
		return "low"
	return "mid"

func register_input(input_name: String) -> void:
	special_sequence.append(input_name)
	if special_sequence.size() > 3:
		special_sequence.pop_front()

	combo_window = 0.8
	if special_sequence == ["light", "heavy", "jump"]:
		special_ready = true
		combo_count = 3
		emit_signal("combo_status_changed", "Combo: Especial pronto")
	elif special_sequence.size() >= 1:
		combo_count = min(3, special_sequence.size())
		emit_signal("combo_status_changed", "Combo: %d" % combo_count)

func try_attack(kind: String) -> void:
	if attack_cooldown > 0.0 or current_attack != "":
		return

	var attack_variant: String = get_attack_variant()
	current_attack = kind + "_" + attack_variant
	attack_cooldown = 0.42 if kind == "light" else 0.7
	attack_timer = 0.25 if kind == "light" else 0.45

	var attack_damage: int = 6 if kind == "light" else 10
	var reach: int = 70 if attack_variant == "low" else 90 if attack_variant == "air" else 80
	if kind == "heavy":
		reach = 80 if attack_variant == "low" else 110 if attack_variant == "air" else 100
	if attack_variant == "low":
		reach = 62 if kind == "light" else 86

	if enemy == null or not is_instance_valid(enemy):
		return

	var horizontal_distance: float = abs(global_position.x - enemy.global_position.x)
	var facing_enemy: bool = (enemy.global_position.x - global_position.x) * facing > 0

	if horizontal_distance <= reach and facing_enemy:
		enemy.apply_damage(attack_damage)
		var push_dir: float = 1.0 if global_position.x < enemy.global_position.x else -1.0
		enemy.hit_knockback = Vector2(push_dir * (16.0 if kind == "light" else 22.0), -90.0)
		enemy.hit_flash_timer = 0.12

func try_special() -> void:
	if attack_cooldown > 0.0:
		return

	if not special_ready:
		emit_signal("combo_status_changed", "Combo: Falta sequência")
		return

	current_attack = "special"
	attack_cooldown = 0.9
	attack_timer = 0.45
	special_ready = false
	special_sequence.clear()
	combo_window = 0.0
	emit_signal("combo_status_changed", "Combo: Especial!")

	if enemy == null or not is_instance_valid(enemy):
		return

	var horizontal_distance: float = abs(global_position.x - enemy.global_position.x)
	var facing_enemy: bool = (enemy.global_position.x - global_position.x) * facing > 0

	if horizontal_distance <= 140 and facing_enemy:
		enemy.apply_damage(25)
		var push_dir: float = 1.0 if global_position.x < enemy.global_position.x else -1.0
		enemy.hit_knockback = Vector2(push_dir * 40.0, -200.0)
		enemy.hit_flash_timer = 0.2

func apply_damage(amount: int) -> void:
	health = max(0, health - amount)
	hit_flash_timer = 0.18
	emit_signal("health_changed", health, max_health)
	if health == 0:
		var winner_name: String = "Player 2" if player_number == 1 else "Player 1"
		emit_signal("combo_status_changed", "%s venceu!" % winner_name)
		if enemy != null and is_instance_valid(enemy):
			enemy.emit_signal("combo_status_changed", "%s venceu!" % winner_name)
			enemy.position = enemy.spawn_position
			enemy.health = enemy.max_health
			enemy.emit_signal("health_changed", enemy.health, enemy.max_health)
			enemy.special_ready = false
			enemy.special_sequence.clear()
			enemy.combo_count = 0
			enemy.combo_window = 0.0

		position = spawn_position
		health = max_health
		emit_signal("health_changed", health, max_health)
		special_ready = false
		special_sequence.clear()
		combo_count = 0
		combo_window = 0.0

func _draw() -> void:
	if player_number == 1 and sprite != null:
		if current_attack != "":
			var reach: int = 80
			if current_attack.contains("low"):
				reach = 62
				if current_attack.begins_with("heavy"):
					reach = 86
			elif current_attack.contains("air"):
				reach = 90

			if current_attack.begins_with("heavy") and not current_attack.contains("low"):
				reach += 25

			var x_offset: int = facing * reach
			var attack_y_offset: float = 20.0 if current_attack.contains("low") else 0.0
			draw_line(Vector2(0, attack_y_offset), Vector2(x_offset, attack_y_offset), Color(1, 0.9, 0.2, 0.9), 8.0)
		return

	var base_color: Color = Color(0.25, 0.72, 1.0, 1.0)
	if hit_flash_timer > 0.0:
		base_color = Color(1.0, 0.35, 0.35, 1.0)

	var height: float = 100.0
	var y_offset: float = 0.0
	if is_crouching:
		height = 52.0
		y_offset = 26.0

	var rect: Rect2 = Rect2(Vector2(-20, -46 + y_offset), Vector2(40, height))
	draw_rect(rect, base_color)

	if current_attack != "":
		var reach: int = 80
		if current_attack.contains("low"):
			reach = 62
			if current_attack.begins_with("heavy"):
				reach = 86
		elif current_attack.contains("air"):
			reach = 90

		if current_attack.begins_with("heavy") and not current_attack.contains("low"):
			reach += 25

		var x_offset: int = facing * reach
		var attack_y_offset: float = 20.0 if current_attack.contains("low") else 0.0
		draw_line(Vector2(0, attack_y_offset), Vector2(x_offset, attack_y_offset), Color(1, 0.9, 0.2, 0.9), 8.0)
