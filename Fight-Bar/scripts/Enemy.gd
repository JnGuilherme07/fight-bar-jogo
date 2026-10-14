extends CharacterBody2D

signal health_changed(current_health, max_value)

@export var speed: float = 180.0
@export var gravity: float = 1100.0
@export var max_health: int = 100

var health: int = max_health
var player: CharacterBody2D

func _ready() -> void:
    player = get_parent().get_node("Player")
    position = Vector2(1040, 520)
    add_to_group("enemy")
    emit_signal("health_changed", health, max_health)

func _physics_process(delta: float) -> void:
    if player == null or not is_instance_valid(player):
        return

    var direction: float = sign(player.global_position.x - global_position.x)
    var distance: float = abs(player.global_position.x - global_position.x)

    if not is_on_floor():
        velocity.y += gravity * delta
    else:
        velocity.y = 0.0

    if distance > 100:
        velocity.x = direction * speed
    else:
        velocity.x = 0.0

    move_and_slide()

func apply_damage(amount: int) -> void:
    health = max(0, health - amount)
    emit_signal("health_changed", health, max_health)
    if health == 0:
        position = Vector2(1040, 520)
        health = max_health
        emit_signal("health_changed", health, max_health)

func _draw() -> void:
    var rect: Rect2 = Rect2(Vector2(-30, -50), Vector2(60, 100))
    draw_rect(rect, Color(1.0, 0.35, 0.35, 1.0))
