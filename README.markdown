# Dungeon Dweller

An inverted roguelike (you play as the titular dweller of a dungeon, i.e. a monster) written in Flash with copious help from Flashpunk. Should be quite self-sufficient as long as you can compile AS3 already :)

# TODO MVP 8/7

* Vertical dungeon structure (saving/loading levels for going up/down). Save/load decor as well.
* Armor gen, same as weapon gen. Armor doesn't actually exist yet, as such.
* Wrap up time-based regen.
* NPC goal management (IN PROGRESS - 50% goals, assuming pathing works)
* Item use, rest of item creation.
* Corridor walls for hallways. Pretty big aesthetic plus, I think. Use neighbors from Nodemap.
* Pathing optimizations.
* Consolidate usage of x/y vs tileX/tileY. I really need automagic setters and getters on any entity with a location so I can fully work in tiles rather than absolute X/Y.
* Consolidate tile mess - right now we have solids arrays, walls objects, corner objects; need some unified way of managing this for pathfinding. I think I need 3 arrays: WALKABLE, SOLID, CORRIDOR. There's just too much overlap between corridor carving and walkables.
* Diagonal movement. Do we really need this?

# TODO FUTURE WISHLIST

*Graphics*

* Item equip graphical overlay using MonsterGraphic.
* Combat animations using MonsterGraphic.

*Tech/AI*

* NPC design. Stats, XP, communication (combat msgs about what creatures are doing, maybe random barks like Dredmor), combats.
* NPC interaction (i.e. being able to recruit creatures or give them tasks such as "guard" or "follow").
* Item balance. Still finding silver stuff on lvl 1. 
* Item modifiers to go with item balance.
* Forward impetus design (why go further into dungeon/how to communicate goal of game) - details [in this post:](http://froggyfish.net/index.php?page=1&newsid=1219)
* Lore - details [in this post:](http://froggyfish.net/index.php?page=1&newsid=1218)
* Line of Sight NPC awareness and detection, with Player's light radius in account

*UI*

* Combat/action log. Status.update() alone just won't cut it. Needs a toggle key so you can see more of it.
* Shift + direction => move until interrupted
* Player/friend swap code needed for tight quarters.

# HIGH PRIORITY BUGS

* Bloodspatters stay through level re-gen. Need to be saved with level state.
* Def numbers fluctuate with same gear. Also, just plain fluctuating. Or not even working right now.
* Combat/action log. Status.update() alone just won't cut it. Needs a toggle key so you can see more of it.
* Slowdown on pathing.

# UPDATES 8/8/2011

* Completed splats with minimal tilemap, added critical chance for extra splat.
* Completed splattermap randomization engine. This same technique should allow for clutter randomization as well (make it a DecorGraphic class and draw on level load).
* Added MonsterGraphic (untested) for player/NPC overlay purposes. Similar to DecorGraphic but using spritemap entities as single graphics rather than tilemaps.
* Mouseover info on items, as NPCs.

# UPDATES 8/7/2011

* Added bloodsplatters. Added critical hit + potential 4-way splatters. Not quite a 3x3 explosion, but you'll know something drastic happened there. Currently only supports a single tile spatter.
* Reworked item gen with spritemaps. Needed to change slots to text (it'll be more readable anyway) and added a bunch of weapon sprites and sprite constants. 
* Added NPC info on mouse-click. 

# UPDATES 8/3

* Time-based regen - start of work.

# UPDATES 8/2

* Possibly maybe finally fixed pathing.

# UPDATES 7/30

* Mouseover neighbor display. While I'm at it, mouseover (maybe mouseover + click) mob info (name, alignment, maybe current weapon) to display.combattext.
* Mouseover revealed that collision map wasn't being rebuilt after hallways were built. This obviously prevented any monster paths from succeeding (unless within same room). This is now fixed, however pathing is still wonky.
* Massive refactoring of hardcoded weapon constants (for type and slot). Refactoring of item slots in general.

# UPDATES 7/28

* NPCs can equip weapon and armor and judge based on rating whether an item is better than current. Sadly, the pathing is still borked, resulting in infinite paths all the time. Possibly something to do with neighbours not populating properly? Was able to see that once in the debugger on creature path.

# UPDATES 7/24

* Status screen fixes post-scrolling movement.
* NPC pathfinding for goals.

# UPDATES 7/18

* Scrolling movement is in.
* Resize to 32x32 tiles is in. 

