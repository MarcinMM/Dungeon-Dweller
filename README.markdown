# Dungeon Dweller

An inverted roguelike (you play as the titular dweller of a dungeon, i.e. a monster) written in Flash with copious help from Flashpunk. Should be quite self-sufficient as long as you can compile AS3 already :)

# TODO MVP 7/25

* NPC goal management (IN PROGRESS)
* Diagonal movement.
* Vertical dungeon structure (saving/loading levels for going up/down).
* Item use, rest of item creation.
* Time-based regen.
* Corridor walls for hallways. Pretty big aesthetic plus, I think.

# TODO FUTURE

* Item equip overlays.
* Line of Sight NPC awareness and detection, with Player's light radius in account
* Shift + direction => move until interrupted
* Combat balance. NPCs hit way too hard now.
* Item balance. Still finding silver stuff on lvl 1. 
* Item modifiers to go with item balance.
* NPC design. Stats, XP, communication (combat msgs about what creatures are doing, maybe random barks like Dredmor).
* NPC interaction (i.e. being able to recruit creatures or give them tasks such as "guard" or "follow").

* Player/friend swap code needed for tight quarters.
* Combat animations.
* Forward impetus design (why go further into dungeon/how to communicate goal of game) - details [in this post:](http://froggyfish.net/index.php?page=1&newsid=1219)
* Lore - details [in this post:](http://froggyfish.net/index.php?page=1&newsid=1218)

# HIGH PRIORITY BUGS

* Def numbers fluctuate with same gear. Also, just plain fluctuating.
* Combat/action log. Status.update() alone just won't cut it. Needs a toggle key so you can see more of it.

# UPDATES 7/18

* Scrolling movement is in.
* Resize to 32x32 tiles is in. 

# UPDATES 7/24

* Status screen fixes post-scrolling movement.
* NPC pathfinding for goals.
