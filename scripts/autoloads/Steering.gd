## Utility functions to calculate steering motion to use as an autoloaded Node.
extends Node

const DEFAULT_MASS: = 2.0
const DEFAULT_SLOW_RADIUS: = 5.0
const DEFAULT_TARGET_RADIUS: = 2.0
const DEFAULT_MAX_SPEED: = 4.0

## Calculates and returns a new velocity with the arrive steering behavior.
func arrive_to(
		velocity: Vector2,
		global_position: Vector2,
		target_position: Vector2,
		max_speed: = DEFAULT_MAX_SPEED,
		slow_radius: = DEFAULT_SLOW_RADIUS,
		target_radius: = DEFAULT_TARGET_RADIUS,
		mass: = DEFAULT_MASS
	) -> Vector2:
	var to_target: = global_position.distance_to(target_position)
	var speed_multiplier: float = 1.5 if to_target > 1.8 else 1.0
	var desired_velocity: = (target_position - global_position).normalized() * (max_speed * speed_multiplier)
	if to_target < target_radius:
		desired_velocity = Vector2.ZERO
	elif to_target < slow_radius:
		desired_velocity *= (to_target / slow_radius) * .75 + .25
	var steering: Vector2 = (desired_velocity - velocity) / mass
	return velocity + steering
