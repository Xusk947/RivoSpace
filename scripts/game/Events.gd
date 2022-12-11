extends Node
# --- Expiriance Group ---
signal expiriance_gained(event) # expiriance:float, max_expiriance:float - called when player gain exp
signal level_up(event) # level:int - called when player reach max expiriance level
signal card_begin_selected(event) # card_holder:CardHolder - called when card begin selected
signal card_selected(event) # card:Card - called when player select card and card stop playing animation
signal reroll() # - called when player click on reroll button
# --- Units Group ---
signal player_spawned(event) # player:Unit - called when player added
signal player_killed(event) # player:Unit - called when player killed, not removed
