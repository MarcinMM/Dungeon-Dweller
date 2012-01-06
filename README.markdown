# Dungeon Contractor Strikes Back

An inverted roguelike (you play as the titular dweller of a dungeon, i.e. a monster) written in Flash with copious help from Flashpunk. Should be quite self-sufficient as long as you can compile AS3 already :)

# TODO MVP 12/31

* Stats fix. Looks like has to do with XML types not being ints.
* NPC a few special abilities. (doing away with creature levels, add more creature variants instead, such as goblin, tough goblin, goblin hero, goblin chief, goblin shaman, goblin wizard, etc. special abilities would be really good)
** Dog can summon with a low chance.
** Bat has double movement/attack.
** Goblin can throw stuff.
* PC Special Ability (currently dmg res for Ork)
* Ranged combat. The ability to "throw" stuff, basically. When a ranged weapon equipped, "throwing" uses weapon's ATT value. Non-ranged weapons throw does some random amount of damage based on STR. This needs some primitive form of line tracing (putting in Util). May use this for LoS lighting?
* Unique creature implementation for Grand Poombah (and others in future, of course)

# TODO FUTURE WISHLIST

*Top Priority Alpha Todos*

In other words things that aren't necessary for MVP, but really really need addressing.

* NPC goal management (IN PROGRESS - 50% goals, assuming pathing works)
* [take a look at combat per this post](http://codesquares.com/post/persistence_complete_now_proper_combats).
* Seriously look at Point vs x,y confusion. It's a mess. Entities aren't updating their POSITION fields, which might everything *tons* easier.

*Content/Features*

* Item use, rest of item creation (food! pots!).
* More PC design (remainder of classes: werewolf, skeleton, dwarf, demon).
* Hunger mechanic.
* Advanced NPC design. Communication (combat msgs about what creatures are doing, maybe random barks like Dredmor), more special abilities. Prevention of item use on certain NPCs.
* Item enhancement (tentatively spec'd in content doc) via loot drops and interactive decor items.
* Forward impetus design (why go further into dungeon/how to communicate goal of game) - details [in this post:](http://froggyfish.net/index.php?page=1&newsid=1219)
* Lore - details [in this post:](http://froggyfish.net/index.php?page=1&newsid=1218)
* Save/load game

*Graphics*

* Ability to layer transparent random tiles on top (north? y-1 anyway) of impassable tiles to create more convincing layered environments.
* Prebuilts in empty spaces. Detect a contiguous 2x2, 3x3, 4x4 (or other nonsquare) space and populate with appropriate larger prebuilts.
* Multiple types of tiles support. TODO outlined in GC.
* Fake non-square rooms by building solid randomized protrusions into room space.
* Combat animations using MonsterGraphic. Other Animations (below).
** Magic mapping reveal coming out of player's location.
** Monster aggravate scroll like a sonar pulse.
** Teleport with a flash of light, not just location shift.
** All sorts of magic wand/spell effects.
** Rippling water.
** Basically, dig into Brogue and see how some of the magic works. It's wonderfully simple but so well executed it's probably worth er, borrowing from.

*Tech/AI*

* Implement some signals for events that affect entire level. Combat should generate noise, splatters, for example. Combat itself still needs regular back-forth stuff with lots of variables passed, so not best use for broadcasting.
* NPC interaction (i.e. being able to recruit creatures or give them tasks such as "guard" or "follow").
* Item balance. Still finding silver stuff on lvl 1. 
* Item modifiers to go with item balance.
* Line of Sight NPC awareness and detection, with Player's light radius in account
* Pathing optimizations, per comments in code. Turn indexOf and arrays to objects, then check key presence.
* Change DecorGraphic from using multiple Tilemaps to a new version of DungeonTilemap that draws multiple tiles, per suggestion [in this post](http://codesquares.com/post/multilayering_terrain_randomization_old_todo_discovery#disqus_thread).
* Consolidate usage of x/y vs tileX/tileY. I really need automagic setters and getters on any entity with a location so I can fully work in tiles rather than absolute X/Y.
* Consolidate tile mess - right now we have solids arrays, walls objects, corner objects; need some unified way of managing this for pathfinding. I think I need 3 arrays: WALKABLE, SOLID, CORRIDOR. There's just too much overlap between corridor carving and walkables.
* Diagonal movement. Do we really need this?

*UI*

* Combat/action log. Status.update() alone just won't cut it. Needs a toggle key so you can see more of it.
* Better item interaction.
* Shift + direction => move until interrupted
* Player/friend swap code needed for tight quarters.
* Massive inventory prettification.

# HIGH PRIORITY BUGS

* Creatures now clip through each other, I think due to the motion Tween.
* Def numbers fluctuate with same gear. Also, just plain fluctuating. Or not even working right now. (is this still true?)
* Combat/action log. Status.update() alone just won't cut it. Needs a toggle key so you can see more of it.
* Slowdown on pathing. Is this still true?
* Creatures still spawn on each other or player.
* Creatures don't drop items.

# UPDATES 12/31
* Added Game Over screen with option to restart
* Added Game Start screen with overview and character select.
* Implemented new select -> confirm concept for on-screen text selection; no traversal vs. inventory display.
* Prepared Player to reinit on death/restart with new XML load (classes!)

# UPDATES 10/26
* Added stat variation to creatures.
* Moved healrate to XML from being hardcoded. That means some creatures will heal faster than others. :D
* Added a grand foozier poombah macguffin to level 10. Realized I have no way of limiting him from spawning multiple times. Added "unique" to TODO.
* Stubbed a partially complete "summon NPC" special ability, as well as special ability firing function on NPCs.
* Fixed NPC generation failure resulting from refactoring how creatureXML gets loaded onto creature.
* 

# UPDATES 10/25
* Cleaned up NPC generation; passing around creature name and re-reading XML for no apparent reason.
* Creature generation is now based on level semi-properly; at least the concept works. Now just tweaking the balances remains.

# UPDATES 10/4
* Stairs Fix
* Added a Signal to combat events; splatters are now signal driven. This start can be expanded to other actions.
* Made splatters use a creature bloodtype for the heck of it. Undead can have dust, orcs green blood, ice elementals can explode into unpassable crystal shards etc.
* Added a solidity toggle to add/remove terrain at whim (untested).
* Added stairs, but buggy right now.

# UPDATES 10/3
* Started more comprehensive work on decor layer. It is now Room-based, i.e. the Level will iterate through Rooms, which will internally determine where to put stuff within their bounds.  Added some constants for decor items. Added player position save on ascend/descend based on stairs (I think it's currently broken by not being multiplied by gridsize, another grid vs. absolute coordinates confusion). Also not every level is getting up/down stairs, not sure why.

# UPDATES 10/2
* Armor gen, basic [per this post.](http://codesquares.com/post/we_havent_blathered_about_design_in_a_while_armor_and_classes)
* [BUG] Fixed inventory letters; wasn't copying inventory letters on destructive item copy.

# UPDATES 8/27/2011

* Change movement code to actually move entities rather than displace them location to location. 
* Removed Level tile constants moved to GC.

# UPDATES 8/21/2011

* Completed level persistence with decor and proper copying of NPCs and Items (not just assigning reference addresses). Proper creature graphic copy will have to wait until we have proper creatures.

# UPDATES 8/18/2011

* Wrap up time-based regen.
* Pre-load/save tweaks to Level to make loading/saving possible. DrawLevel really needs to hold all of the level gen stuff, from floor to hallways to creatures to items.
* Vertical dungeon structure (saving/loading levels for going up/down). Save/load decor as well. Tentative plan: create a LevelHolder class that stores level Tilemap, decor DecorGraphic, level collision map, NPCs and Items. Dungeon has a Vector (?) of LevelHolders and can only add/remove them (no updating these during play). We can use this later for saving the game.

# UPDATES 8/10/2011

* Tweak hallway generation to not draw if tile != void. We don't want to be overwriting existing floors. Line 214 of Nodemap. This is already done for DOORS.

# UPDATES 8/9/2011

* Item equip graphical overlay using MonsterGraphic. Still need art, but the tech is in!
* Added real bloodspatter graphic and some constants to manage it.

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

