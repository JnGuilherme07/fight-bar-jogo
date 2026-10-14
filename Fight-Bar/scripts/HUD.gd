extends CanvasLayer

@onready var player_bar: ProgressBar = $MarginContainer/HBoxContainer/PlayerHealthBar
@onready var enemy_bar: ProgressBar = $MarginContainer/HBoxContainer/EnemyHealthBar
@onready var combo_label: Label = $MarginContainer/HBoxContainer/ComboLabel

var player: CharacterBody2D
var enemy: CharacterBody2D

func _ready() -> void:
    var scene = get_tree().current_scene
    if scene:
        player = scene.get_node_or_null("Player")
        enemy = scene.get_node_or_null("Player2")
        if enemy == null:
            enemy = scene.get_node_or_null("Enemy")

    if player != null and player.has_signal("health_changed"):
        player.connect("health_changed", _on_player_health_changed)
    if player != null and player.has_signal("combo_status_changed"):
        player.connect("combo_status_changed", _on_combo_status_changed)
    if enemy != null and enemy.has_signal("health_changed"):
        enemy.connect("health_changed", _on_enemy_health_changed)

    _refresh_health()
    combo_label.text = "Combo: -"

func _refresh_health() -> void:
    if player != null and "max_health" in player:
        player_bar.max_value = player.max_health
        player_bar.value = player.health
    if enemy != null and "max_health" in enemy:
        enemy_bar.max_value = enemy.max_health
        enemy_bar.value = enemy.health

func _on_player_health_changed(current_health: int, max_value: int) -> void:
    player_bar.max_value = max_value
    player_bar.value = current_health

func _on_enemy_health_changed(current_health: int, max_value: int) -> void:
    enemy_bar.max_value = max_value
    enemy_bar.value = current_health

func _on_combo_status_changed(text: String) -> void:
    combo_label.text = text
