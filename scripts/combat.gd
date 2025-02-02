class_name Combat
extends Node

func randomize_director_pick() -> void:
	# has a chance to use their strongest attack twice in a row
	if Dialogic.VAR.Combat.last_hit != "none" and randf() < 0.5:
		# 50% chance to repeat their last successful attack
		print("director repeats attack ", Dialogic.VAR.Combat.last_hit)
		Dialogic.VAR.Combat.director_pick = Dialogic.VAR.Combat.last_hit
	else:
		match randi() % 3:
			0:
				print("director attacks morale")
				Dialogic.VAR.Combat.director_pick = "morale"
			1:
				print("director attacks reputation")
				Dialogic.VAR.Combat.director_pick = "reputation"
			2:
				print("director attacks authority")
				Dialogic.VAR.Combat.director_pick = "authority"


func set_round_winner() -> void:
	var dir_pick    = Dialogic.VAR.Combat.director_pick
	var player_pick = Dialogic.VAR.Combat.player_pick
	print("player picked", player_pick)
	if player_pick == "P2W":
		Dialogic.VAR.Combat.round_winner = "player"
	elif player_pick == "defend_morale":
		if dir_pick == "morale":
			Dialogic.VAR.Combat.round_winner = "defended_morale"
		else:
			Dialogic.VAR.Combat.round_winner = "director_vulnerable"
	elif player_pick == "defend_reputation":
		if dir_pick == "reputation":
			Dialogic.VAR.Combat.round_winner = "defended_reputation"
		else:
			Dialogic.VAR.Combat.round_winner = "director_vulnerable"
	elif player_pick == "defend_authority":
		if dir_pick == "authority":
			Dialogic.VAR.Combat.round_winner = "defended_authority"
		else:
			Dialogic.VAR.Combat.round_winner = "director_vulnerable"
	elif dir_pick == player_pick:
		Dialogic.VAR.Combat.round_winner = "draw"
	elif dir_pick == "morale" and player_pick == "reputation":
		Dialogic.VAR.Combat.round_winner = "player"
	elif dir_pick == "reputation" and player_pick == "authority":
		Dialogic.VAR.Combat.round_winner = "player"
	elif dir_pick == "authority" and player_pick == "morale":
		Dialogic.VAR.Combat.round_winner = "player"
	else:
		Dialogic.VAR.Combat.round_winner = "director"


func end_round() -> void:
	print("Round Winner ", Dialogic.VAR.Combat.round_winner)
	var damage_multiplier: float = 1.0
	if Dialogic.VAR.Combat.director_hit == 3:
		damage_multiplier = 1.2  # 20% more damage in desperate mode
	elif Dialogic.VAR.Combat.director_hit == 4:
		damage_multiplier = 1.5  # 50% more damage in desperate mode

	if Dialogic.VAR.Combat.round_winner == "director":
		match Dialogic.VAR.Combat.director_pick:
			"morale":
				power_manager.lose_moral(15 * damage_multiplier)
			"reputation":
				power_manager.lose_reputation(15 * damage_multiplier)
			"authority":
				power_manager.lose_authority(15 * damage_multiplier)

	elif Dialogic.VAR.Combat.round_winner == "director_vulnerable":
		match Dialogic.VAR.Combat.director_pick:
			"morale":
				power_manager.lose_moral(20 * damage_multiplier)
			"reputation":
				power_manager.lose_reputation(20 * damage_multiplier)
			"authority":
				power_manager.lose_authority(20 * damage_multiplier)

	else:
		match Dialogic.VAR.Combat.round_winner:
			"defended_morale":
				power_manager.gain_moral(15)
			"defended_reputation":
				power_manager.gain_reputation(15)
			"defended_authority":
				power_manager.gain_authority(15)
