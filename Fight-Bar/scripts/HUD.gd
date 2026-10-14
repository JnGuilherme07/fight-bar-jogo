extends CanvasLayer

@onready var player_bar: ProgressBar = $MarginContainer/HBoxContainer/PlayerColumn/PlayerHealthBar
@onready var enemy_bar: ProgressBar = $MarginContainer/HBoxContainer/EnemyColumn/EnemyHealthBar
@onready var player_wins_label: Label = $MarginContainer/HBoxContainer/PlayerColumn/PlayerWinsLabel
@onready var enemy_wins_label: Label = $MarginContainer/HBoxContainer/EnemyColumn/EnemyWinsLabel
@onready var combo_label: Label = $MarginContainer/HBoxContainer/ComboLabel
@onready var timer_label: Label = $MarginContainer/HBoxContainer/TimerContainer/TimerLabel
@onready var countdown_timer: Timer = $CountdownTimer

var player: CharacterBody2D
var enemy: CharacterBody2D
var current_time: int = 99

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
    if player != null and player.has_signal("wins_changed"):
        player.connect("wins_changed", _on_player_wins_changed)
    if enemy != null and enemy.has_signal("health_changed"):
        enemy.connect("health_changed", _on_enemy_health_changed)
    if enemy != null and enemy.has_signal("wins_changed"):
        enemy.connect("wins_changed", _on_enemy_wins_changed)

    countdown_timer.timeout.connect(_on_countdown_tick)
    countdown_timer.wait_time = 1.0
    countdown_timer.start()

    _refresh_health()
    _refresh_wins()
    _update_timer_display()
    combo_label.text = "Combo: -"

func _refresh_health() -> void:
    if player != null and "max_health" in player:
        player_bar.max_value = player.max_health
        player_bar.value = player.health
    if enemy != null and "max_health" in enemy:
        enemy_bar.max_value = enemy.max_health
        enemy_bar.value = enemy.health

func _refresh_wins() -> void:
    if player != null and "wins" in player:
        player_wins_label.text = "Vitórias: %d" % player.wins
    if enemy != null and "wins" in enemy:
        enemy_wins_label.text = "Vitórias: %d" % enemy.wins

func _on_player_health_changed(current_health: int, max_value: int) -> void:
    player_bar.max_value = max_value
    player_bar.value = current_health

func _on_enemy_health_changed(current_health: int, max_value: int) -> void:
    enemy_bar.max_value = max_value
    enemy_bar.value = current_health

func _on_player_wins_changed(current_wins: int) -> void:
    player_wins_label.text = "Vitórias: %d" % current_wins

func _on_enemy_wins_changed(current_wins: int) -> void:
    enemy_wins_label.text = "Vitórias: %d" % current_wins

func _on_combo_status_changed(text: String) -> void:
    combo_label.text = text

func _on_countdown_tick() -> void:
    if current_time > 0:
        current_time -= 1
    _update_timer_display()

func _update_timer_display() -> void:
    timer_label.text = str(current_time)
    timer_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
