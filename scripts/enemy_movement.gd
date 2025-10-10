extends CharacterBody2D

# === CONFIG ===
@export var speed: float = 75.0
@export var max_health: int = 50
@export var stop_distance: float = 35.0

# === STATE ===
var chasing := false
var player: Node2D = null
var health := max_health

var is_hurt := false
var is_dead := false
var is_attacking := false
var attack_cooldown := false

# === NODES ===
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var timer: Timer = $Timer

@onready var hitboxes := {
	"up": $AreaUp/HitboxUp,
	"down": $AreaDown/HitboxDown,
	"left": $AreaLeft/HitboxLeft,
	"right": $AreaRight/HitboxRight
}

# === PHYSICS ===
func _physics_process(_delta: float) -> void:
	if is_dead or is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if chasing and player and not is_dead:
		nav_agent.target_position = player.global_position
		var distance := global_position.distance_to(player.global_position)

		if distance <= stop_distance and not is_hurt:
			velocity = Vector2.ZERO
			attack()
		else:
			var next_point := nav_agent.get_next_path_position()
			var direction := (next_point - global_position).normalized()
			velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if not is_hurt and not is_dead and not is_attacking:
		_update_animation()


# === ANIMATION ===
func _update_animation() -> void:
	if velocity == Vector2.ZERO:
		anim.play("idle_down")
	else:
		if abs(velocity.x) > abs(velocity.y):
			anim.play("flight_side")
			anim.flip_h = velocity.x < 0
		elif velocity.y < 0:
			anim.play("flight_back")
		else:
			anim.play("flight_down")


# === DETECTION ===
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		chasing = true
		player = body
		timer.start()


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		chasing = false
		player = null
		timer.stop()


func _on_timer_timeout() -> void:
	if player:
		nav_agent.target_position = player.global_position
	timer.start()


# === DAMAGE SYSTEM ===
func damage(amount: int) -> void:
	if is_dead:
		return

	# Angriff abbrechen, wenn getroffen
	if is_attacking:
		is_attacking = false
		_disable_all_hitboxes()
		anim.stop()

	health = clamp(health - amount, 0, max_health)
	is_hurt = true
	anim.play("hurt_down")

	await anim.animation_finished

	is_hurt = false
	if health <= 0:
		die()


# === ATTACK SYSTEM ===
func attack() -> void:
	if is_attacking or attack_cooldown or is_dead or is_hurt:
		return

	is_attacking = true

	# Richtung zum Spieler berechnen
	var dir := (player.global_position - global_position).normalized()
	var attack_dir := _get_attack_direction(dir)

	# Animationen
	match attack_dir:
		"left", "right":
			anim.play("attack_side")
			anim.flip_h = attack_dir == "left"
		"up":
			anim.play("attack_up")
		"down":
			anim.play("attack_down")

	# Warte leicht, bevor die Hitbox aktiv wird
	await get_tree().create_timer(0.4).timeout
	_enable_hitbox(attack_dir)

	await anim.animation_finished
	_disable_all_hitboxes()

	is_attacking = false
	attack_cooldown = true
	await get_tree().create_timer(0.4).timeout
	attack_cooldown = false


func _get_attack_direction(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	return "up" if dir.y < 0 else "down"


# === HITBOXES ===
func _enable_hitbox(dir: String) -> void:
	_disable_all_hitboxes()
	if hitboxes.has(dir):
		hitboxes[dir].set_deferred("disabled", false)


func _disable_all_hitboxes() -> void:
	for hb in hitboxes.values():
		hb.set_deferred("disabled", true)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("damage"):
		body.damage(10)


# === DEATH ===
func die() -> void:
	is_dead = true
	_disable_all_hitboxes()
	anim.play("death_side")
	await anim.animation_finished
	queue_free()
