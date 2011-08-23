package dungeon.contents
{
	import dungeon.contents.Item;
	import dungeon.contents.Creature;
	import dungeon.structure.Node;
	import dungeon.structure.Point;
	import flash.automation.StageCapture;
	import net.flashpunk.FP;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import dungeon.utilities.GC;
	import dungeon.utilities.resultItem;
	import dungeon.utilities.MonsterGraphic;
	/**
	 * ...
	 * @author MM
	 */
	public class NPC extends Creature
	{
		// some defaults and inits
		private const GRIDSIZE:int = GC.GRIDSIZE;
		public var STEP:int = 0;
		public var SIGHT_RANGE:int = 1;
		
		// What is this thing? And what type of descriptors do we need? Let's start simple.
		public var NPCType:String;
		public var NPCLevel:uint;
		public var UNIQUE:Boolean = false;
			
		// pathing status
		private var POSITION:Point;
		private var ENGAGE_STATUS:uint = GC.NPC_STATUS_IDLE;
		private var PATH:Array = new Array();
		private var PATH_TARGET_ID:uint = 0;
		
		// we need some way to decide what to DO once we get to where we were going!
		private var PATH_PURPOSE:String;
		public var newActionOverride:Boolean = false; 
		private var BLOCKCOUNT:uint = 0; // keeps track of how many times pathing's been blocked; when reaches 2, path reset to new
		// TODO: this gets set true if something drastic occurs
		// loud noise from player or HP low alert, or something else?
		
		// combat/action statuses
		// 'self' will attack anything, 'player' will help player, 'race' will attack other races, 'alignment' will attack other alignments
		// 'pacifist' will attack nothing and just run, 'defensive' will attack only when attacked ... what else?
		// default is alignment
		private var ACTION_TAKEN:Boolean = false;
		public var FACTION:String = 'alignment'; 

		public var _imgOverlay:MonsterGraphic;
		
		public function NPC() 
		{
			super();
			// TODO: this is random, but needs to be driven by creature type
			var randCritter:uint = Math.round((Math.random() * 16)) + 20;
			_imgOverlay = new MonsterGraphic(randCritter,0,0);
			graphic = _imgOverlay;
			
			setHitbox(GRIDSIZE, GRIDSIZE);
			type = "npc";
			STEP = Dungeon.player.STEP;
			POSITION = new Point(x, y);
			
			// now, what shall this critter be?
			determineNPCType();
			
			// TODO: what shall it wear/wield?
			// determineNPCEquipment();
			
			// and what kind of stats does it have?
			// TODO: This needs to use the common stats
			setNPCStats(NPCType, NPCLevel);
			setNPCDerivedStats(NPCType, NPCLevel);
			
			layer = GC.NPC_LAYER;
			
			// assign random alignment to creature
			ALIGNMENT = GC.ALIGNMENTS[Math.round(Math.random() * (GC.ALIGNMENTS.length - 1))];
		}
		
		// when no path request is being made, i.e. equivalent of idle animation
		// TODO: use array constants here instead of the clumsy string assign
		public function idleMovement():void {
			var impactsAllowed:Array = ["up","down","left","right"];
			// NPC considering a step, see what's allowed
			if (collide("npc", x, y + GRIDSIZE) || collide("player", x, y + GRIDSIZE) || collide("level", x, y + GRIDSIZE)) {
				impactsAllowed.splice(impactsAllowed.indexOf("down"),1);
			}
			if (collide("npc", x, y - GRIDSIZE) || collide("player", x, y - GRIDSIZE) || collide("level", x, y - GRIDSIZE)) {
				impactsAllowed.splice(impactsAllowed.indexOf("up"),1);
			}
			if (collide("npc", x + GRIDSIZE, y) || collide("player", x + GRIDSIZE, y) || collide("level", x + GRIDSIZE, y)) {
				impactsAllowed.splice(impactsAllowed.indexOf("right"),1);
			}
			if (collide("npc", x - GRIDSIZE, y) || collide("player", x - GRIDSIZE, y) || collide("level", x - GRIDSIZE, y)){
				impactsAllowed.splice(impactsAllowed.indexOf("left"),1);
			}

			// select random index then perform movement
			var rndMove:uint = Math.round(Math.random() * (impactsAllowed.length - 1));
			var rndMoveString:String = impactsAllowed[rndMove];
			switch (rndMoveString) {
				case "up":
				y -= GRIDSIZE;
				STEP++;
				break;
				case "down":
				y += GRIDSIZE;
				STEP++;
				break;
				case "left":
				x -= GRIDSIZE;
				STEP++;
				break;
				case "right":
				x += GRIDSIZE;
				STEP++;
				break;
			}
		}
		
		// this can be used to achieve goals such as pickup item or attack another entity, or seek escape route
		// before starting path, we need to obtain actual nodes from nodemap (nodemap stores collision data for entire level)
		public function initPathedMovement(pointA:Point, pointB:Point):Boolean {
			var source:Node = Dungeon.level._nodemap.getNode(pointA.x, pointA.y);
			var destNode:Node = Dungeon.level._nodemap.getNode(pointB.x, pointB.y);
			//var source:Node = new Node(pointA.x, pointA.y, -1);
			//var destNode:Node = new Node(pointB.x, pointB.y, -1);
			PATH = source.findPath(destNode, 'creature');
			trace("Path size: " + PATH.length);
			// need to take a step now
			return pathedMovementStep();
		}
		
		// get next point in the path
		// continue until depleted
		public function pathedMovementStep():Boolean {
			if ((PATH.length != 0) && !ACTION_TAKEN) {
				// TODO: if I use shift() here instead of pop(), this is a cheap teleport implementation ^_^
				var newLoc:Node = PATH.pop();
				// since this is more or less a teleport
				// except that it should be a teleport to the next tile over (if my path algorithm works correctly)
				// so nothing *really* broken
				// we need to check that the new node really IS just one tile away
				// and we need to ensure there's no collision happening
				var collisionTargets:Array = new Array("player", "npc");
				if (collideTypes(collisionTargets, newLoc.x * GC.GRIDSIZE, newLoc.y * GC.GRIDSIZE) != null) {
					trace(NPCType + " blocked!" );
					// if blocked, we can either reset path entirely or wait a turn, then try again - if 2 failures, clear and seek new obj.
					if (BLOCKCOUNT >= 2) {
						PATH = [];
						BLOCKCOUNT = 0;
						PATH.push(newLoc);
					} else {
						BLOCKCOUNT++;
					}
					// this is so that we can see if we're adjacent to enemy
					newActionOverride = true;
					return false;
				} else {
					trace("Moving to " + newLoc.x + "," + newLoc.y);
					// Sanity check; if movement is more than 1 off from current, do not process
					// also trace this, 'cuz it happens quite a lot
					var diffX:int = Math.abs(newLoc.x - (x / GC.GRIDSIZE));
					var diffY:int = Math.abs(newLoc.y - (y / GC.GRIDSIZE));
					trace('diffx:' + diffX + '|diffY:' + diffY);
					if (diffX > 1 || diffY > 1) {
						trace("blah teleport alert");
					} else {
						x = newLoc.x * GC.GRIDSIZE;
						y = newLoc.y * GC.GRIDSIZE;
						ACTION_TAKEN = true;
					}
					return true;
				}
			} else {
				// path ended, now what?
				// something must be able to read the return here and act appropriately
				switch(PATH_PURPOSE) {
					case "ITEM":
						// pickup if item VALUE (yet to be defined) is greater than current
						break;
					case "ENEMY":
						// ATTACK! (hee)
						break;
					case "PLAYER":
						// ... not sure. alignment-based stuff?
						break;
				}
				// action complete, reset status
				ENGAGE_STATUS = GC.NPC_STATUS_IDLE;
				newActionOverride = false;
				return false;
			}
		}
		
		// swarm cohort check
		public function checkSwarmInRoom():Boolean {
			return false;
		}
		
		// TODO: Monster Library
		// This needs to pull from some library of monsters, just like items do. 
		public function determineNPCType():void {
			NPCLevel = 1;
		}
		
		// we might need this to be available for the player, when morphed
		public function setNPCStats(npcType:String, npcLevel:uint):void {
			// TODO: use Creature level class
			STATS[GC.STATUS_STR] = 10;
			STATS[GC.STATUS_AGI] = 10;
			STATS[GC.STATUS_INT] = 10;
			STATS[GC.STATUS_WIS] = 10;
			STATS[GC.STATUS_CHA] = 10;
			STATS[GC.STATUS_CON] = 14;
			STATS[GC.STATUS_HEALRATE] = 15;
			STATS[GC.STATUS_HEALSTEP] = 0;
		}
		
		
		public function setNPCDerivedStats(npcType:String, npcLevel:uint):void {
			// TODO: use Creature level class
			STATS[GC.STATUS_ATT] = 3;
			STATS[GC.STATUS_DEF] = 3;
			STATS[GC.STATUS_HP] = 15;
			STATS[GC.STATUS_HPMAX] = 15;
		}
		
		public function processCombat():void {
			// TODO: detect if foes are in adjacent tile based on collision
			// then pick one either randomly or based on previous picks
			// or perhaps even some form of 'threat' management
			// then smack!
			
			//FP.log('coll:' + COLLISION_TYPE);
			if ((COLLISION_TYPE.length > 0) && (COLLISION_TYPE.indexOf(GC.COLLISION_NPC) != -1) && !ACTION_TAKEN) {
				// we have NPC collision
				// still needs threat list (which should include friendlies, maybe?)
				ENGAGE_STATUS = GC.NPC_STATUS_ATTACKING_NPC;
				
				var collAr:Array = [];
				for (var index:String in COLLISION) {
					if (COLLISION[index] == GC.COLLISION_NPC) {
						// index gives us the direction
						collAr.push(index);
						//FP.log("hit index: " + index);
					}
				}
				// TODO: threat list implementation (or something)
				// TODO: combat text needs to only show up for creatures within PLAYER's line of sight
				// for now, pick a random direction from available hittable things to hit in
				var pickRandomHit:int = Math.round(Math.random() * (collAr.length-1));
				var hitAr:Array = [];
				collideInto("npc", x + (GC.DIR_MOD_X[collAr[pickRandomHit]] * GRIDSIZE), y + (GC.DIR_MOD_Y[collAr[pickRandomHit]] * GRIDSIZE), hitAr); // this should get us the collided entity based on our move dir
				// now ensure that the random thing hit is not of the same alignment
				// and that there's nothing else to hit
				// there may be other checks here
				while ((collAr.length > 0) && (hitAr[0].ALIGNMENT == ALIGNMENT)) {
					hitAr = [];
					collAr.splice(collAr.indexOf(pickRandomHit), 1);
					if (collAr.length > 0) {
						pickRandomHit = Math.round(Math.random() * (collAr.length-1));
						collideInto("npc", x + (GC.DIR_MOD_X[collAr[pickRandomHit]] * GRIDSIZE), y + (GC.DIR_MOD_Y[collAr[pickRandomHit]] * GRIDSIZE), hitAr);
						trace("Attempting to attack " + hitAr[0].ALIGNMENT + " with own alignment of " + ALIGNMENT);
					}
				}

				// now process combats
				if (hitAr.length > 0) {
					// processHit returns true on opponent death, record status as disengaged for new pathfinding
					if (hitAr[0].processHit(STATS[GC.STATUS_ATT])) {
						Dungeon.statusScreen.updateCombatText(NPCType + " hits " + hitAr[0].NPCType + " for " + STATS[GC.STATUS_ATT] + " damage!");
						Dungeon.statusScreen.updateCombatText(hitAr[0].NPCType + " dies.");
						trace(hitAr[0].NPCType + " is hit, dies.");
						ENGAGE_STATUS = GC.NPC_STATUS_IDLE;
						trace(NPCType + " idle after kill.");
					} else {
						Dungeon.statusScreen.updateCombatText(NPCType + " hits " + hitAr[0].NPCType + " for " + STATS[GC.STATUS_ATT] + " damage!");
						trace(NPCType + "," + ALIGNMENT + " hits " + hitAr[0].NPCType + "," + hitAr[0].ALIGNMENT + " for " + STATS[GC.STATUS_ATT] + " damage!");
						trace(hitAr[0].NPCType + " is hit.");
					}
					ACTION_TAKEN = true;
				} else {
					// same alignment spliced the collision out of the hit Array
					trace(NPCType + " checks its swing! 'sup buddy?");	
				}
			}
			// TODO: Player needs to be included in threat list
			// right now the player gets 2nd priority after monster hits no matter what just because of where this is
			if ((COLLISION_TYPE.length > 0) && (COLLISION_TYPE.indexOf(GC.COLLISION_PLAYER) != -1)  && !ACTION_TAKEN) {
				ENGAGE_STATUS = GC.NPC_STATUS_ATTACKING_PLAYER;
				// there is only one player so we don't have to perform any calculations, just call player's hit calc
				// this is lazy if we ever do multiplayer, but that's just LOLS
				// if (threatList check here) {
				Dungeon.player.processHit(STATS[GC.STATUS_ATT]);
				ACTION_TAKEN = true;
				// end threat list check
			}
		}
		
		public function processHit(attackValue:int):Boolean {
			// calculations to modify the attack based on player's defense stats
			// return true if dead for text and player stat update (XP+)
			STATS[GC.STATUS_HP] -= attackValue;
			Dungeon.level.decor.splatter(x, y, false, GC.SPLAT_BLOOD);
			if (STATS[GC.STATUS_HP] <= 0) {
				// TODO: drop loot/corpse when dead
				// TODO: other effects? some creatures may explode or ooze poison or drip blood etc.
				for (var index in Dungeon.level.NPCS) {
					if (Dungeon.level.NPCS[index] == this) {
						Dungeon.level.NPCS.splice(Dungeon.level.NPCS[index],1);
					}
				}
				FP.world.remove(this);
				return true;
			} else {
				return false;
			}
		}
		
		public function findNPC():void {
			var NPCStart:Point;
			var NPCDest:Point;
			// other NPC seek
			var measuredDistance:uint;
			var interestingCreature:NPC;
			var interestingCreatureDistance:uint = 1000;
			trace(Dungeon.level.NPCS.length);
			for each (var currentNPC:NPC in Dungeon.level.NPCS) {
				// check distance if under threshold, then pick lowest
				measuredDistance = Math.sqrt(Math.pow(x - currentNPC.x, 2) + Math.pow(y - currentNPC.y, 2));
				if  (
						(measuredDistance != 0) && // ignore self when checking distance - NPCs should never stack
						(measuredDistance < (10 * GRIDSIZE)) && 
						(measuredDistance < interestingCreatureDistance) &&
					//	(currentNPC.ALIGNMENT != ALIGNMENT) && // TODO: this needs a faction check here too
						ENGAGE_STATUS == GC.NPC_STATUS_IDLE // this will need refinment to take into effect threat list; but if creature is already engaged that should show up as ACTION_TAKEN
					) 
				{
					trace(NPCType + " at " + x/GRIDSIZE + "," + y/GRIDSIZE + " measured: " + measuredDistance + "|interesting:" + interestingCreatureDistance);
					interestingCreatureDistance = measuredDistance;
					interestingCreature = currentNPC;
				}
			}
			
			if (interestingCreatureDistance < 1000) {
				// we have a creature closer than threshold (10 tiles away) of a different alignment, and this (not the found, but THIS) creature is idling: calculate path towards target
				NPCStart = new Point(x, y);
				NPCDest = new Point(interestingCreature.x, interestingCreature.y);
				if (initPathedMovement(NPCStart, NPCDest)) {
					trace(PATH.length);
					ENGAGE_STATUS = GC.NPC_STATUS_SEEKING_OBJECT;
					PATH_PURPOSE = 'ENEMY';	
					PATH_TARGET_ID = interestingCreature.UNIQID;
					trace(NPCType + " at " + x / GRIDSIZE + "," + y / GRIDSIZE + " is seeking " 
						+ interestingCreature.NPCType + " at " + interestingCreature.x / GRIDSIZE + "," + interestingCreature.y / GRIDSIZE 
						+ "| dist: " + Math.round(interestingCreatureDistance / GRIDSIZE));
				} else {
					trace(NPCType + " at " + x / GRIDSIZE + "," + y / GRIDSIZE + " is blocked on seeking " 
					+ interestingCreature.NPCType + " at " + interestingCreature.x / GRIDSIZE + "," + interestingCreature.y / GRIDSIZE 
					+ "| dist: " + Math.round(interestingCreatureDistance / GRIDSIZE));							
				}
			}
		}
		
		public function findPlayer():void {
			var NPCStart:Point;
			var NPCDest:Point;
			// alternately, player seek
			// for now, we'll just run the check regardless
			if (true) {
				NPCStart = new Point(x, y);
				NPCDest = new Point(Dungeon.player.x, Dungeon.player.y);
				if (initPathedMovement(NPCStart, NPCDest)) {
					// we don't want to start a path if it's farther than some X (60 for now, why not?)
					if (PATH.length < 60) {
						ENGAGE_STATUS = GC.NPC_STATUS_SEEKING_OBJECT;
						PATH_PURPOSE = 'PLAYER';
						trace(NPCType + " at " + x / GRIDSIZE + "," + y / GRIDSIZE + " is seeking player " 
							+ " at " + Dungeon.player.x / GRIDSIZE + "," + Dungeon.player.y / GRIDSIZE); 
					} else {
						// nothing, we're not using this path
						ENGAGE_STATUS = GC.NPC_STATUS_IDLE;
					}
				}
			}
		}
		
		public function findItem():void {
			var NPCStart:Point;
			var NPCDest:Point;
			// other NPC seek
			var measuredDistance:uint;
			var interestingItem:Item;
			var interestingItemDistance:uint = 1000;
			for each (var currentItem:Item in Dungeon.level.ITEMS) {
				// check distance if under threshold, then pick lowest
				measuredDistance = Math.sqrt(Math.pow(x - currentItem.x, 2) + Math.pow(y - currentItem.y, 2));
				if  (
						(measuredDistance != 0) && // ignore self when checking distance - NPCs should never stack
						(measuredDistance < (10 * GRIDSIZE)) && 
						(measuredDistance < interestingItemDistance) &&
						ENGAGE_STATUS == GC.NPC_STATUS_IDLE // this will need refinment to take into effect threat list; but if creature is already engaged that should show up as ACTION_TAKEN
					) 
				{
					trace(NPCType + " at " + x/GRIDSIZE + "," + y/GRIDSIZE + " measured: " + measuredDistance + "|interesting:" + interestingItemDistance);
					interestingItemDistance = measuredDistance;
					interestingItem = currentItem;
				}
			}
								
			if (interestingItemDistance != 1000) {
				// we have an item closer than threshold (10 tiles away): calculate path towards target
				NPCStart = new Point(x, y);
				NPCDest = new Point(interestingItem.x, interestingItem.y);
				if (initPathedMovement(NPCStart, NPCDest)) {
					ENGAGE_STATUS = GC.NPC_STATUS_SEEKING_OBJECT;
					PATH_PURPOSE = 'ITEM';
					PATH_TARGET_ID = interestingItem.UNIQID;
					trace(NPCType + " at " + x / GRIDSIZE + "," + y / GRIDSIZE + " is seeking " 
						+ interestingItem.ITEM_TYPE + " at " + interestingItem.x / GRIDSIZE + "," + interestingItem.y / GRIDSIZE 
						+ "| dist: " + Math.round(interestingItemDistance / GRIDSIZE));
				} else {
					trace(NPCType + " at " + x / GRIDSIZE + "," + y / GRIDSIZE + " is blocked on seeking " 
					+ interestingItem.ITEM_TYPE + " at " + interestingItem.x / GRIDSIZE + "," + interestingItem.y / GRIDSIZE 
					+ "| dist: " + Math.round(interestingItemDistance / GRIDSIZE));							
				}
			}			
		}
		
		// TODO: this needs more work, but should remove item from floor and give it to NPC inventory
		public function checkItem():void {
			if (collide("items", x, y)) {
				var itemAr:Array = [];
				collideInto("items", x, y, itemAr);

				// we have some assumptions for NPC equipment. 
				// 1. They should only be carrying one weapon
				// 2. They should only be carrying a chestpiece+headpiece at most
				// 3. Any weapon/armor carried will be immediately equipped. 
				// 4. Any better weapon/armor will be equipped and prior dropped.
				// 5. They should only be carrying one extra item, whatever is found first.

				for each (var itemOnFloor:* in itemAr) {
					var equippedItem:resultItem = getEquippedItemByItem(itemOnFloor);
					if ((equippedItem.found && equippedItem.item.rating < itemOnFloor.rating) || !equippedItem.found) {
						// found item is better than carried/equipped, pick up and mark as equipped
						itemOnFloor.EQUIPPED = true;
						Dungeon.statusScreen.updateCombatText(NPCType + " equips " + itemOnFloor.DESCRIPTION);
						
						if (itemOnFloor is Weapon) {
							var newInventoryWeapon:Weapon = itemOnFloor.selfCopy();
							ITEMS[itemOnFloor.ITEM_TYPE].push(newInventoryWeapon);
						} else if (itemOnFloor is Armor) {
							var newInventoryArmor:Armor = itemOnFloor.selfCopy();
							ITEMS[itemOnFloor.ITEM_TYPE].push(newInventoryArmor);
						}

						// now remove it from level array
						Dungeon.level.ITEMS.splice(Dungeon.level.ITEMS.indexOf(itemOnFloor), 1);
						
						// remove item from world
						FP.world.remove(itemOnFloor);
						
						// unequip current (if exists) and drop it
						if (equippedItem.found) {
							equippedItem.item.EQUIPPED = false;
							equippedItem.item.x = x;
							equippedItem.item.y = y;
							if (equippedItem.item is Weapon) {
								var droppedWeapon:Weapon = Weapon(equippedItem.item).selfCopy();
								Dungeon.level.ITEMS[droppedWeapon.ITEM_TYPE].push(droppedWeapon);
								FP.world.add(droppedWeapon);
							} else if (equippedItem.item is Armor) {
								var droppedArmor:Armor = Armor(equippedItem.item).selfCopy();
								Dungeon.level.ITEMS[droppedArmor.ITEM_TYPE].push(droppedArmor);
								FP.world.add(droppedArmor);
							}

							ITEMS.splice(ITEMS.indexOf(equippedItem.item), 1);
							Dungeon.statusScreen.updateCombatText(NPCType + " drops " + equippedItem.item.DESCRIPTION);
						}
					} else {
						Dungeon.statusScreen.updateCombatText(NPCType + " looks over the " + itemOnFloor.DESCRIPTION + " and leaves it alone.");
					}
				}
				updateDerivedStats();
			}
			ENGAGE_STATUS = GC.NPC_STATUS_IDLE;
		}
		
		public function selfCopy():NPC {
			var newNPC:NPC = new NPC();

			newNPC.graphic = graphic; // TODO: placeholder until NPCs are designed
			newNPC.x = x;
			newNPC.y = y;
			newNPC.ALIGNMENT = ALIGNMENT;
			newNPC.FACTION = FACTION;
			newNPC.NPCLevel = NPCLevel;
			newNPC.NPCType = NPCType;
			
			// now copy STATS and ITEMS arrays
			// actually stats are initialized on NPC init + type; precise numbers aren't that important for generic NPCS
			// we might have a subroutine for dealing with uniques, like so:
			// if (NPCUnique) { processUnique(); }
			// so only copy ITEMS array
			
			var copiedArmor:Array = new Array();
			var copiedWeapons:Array = new Array();
			var copiedItems:Array = [copiedArmor, copiedWeapons];
			for each (var itemCategory:Array in ITEMS) {
				for each (var item:Item in itemCategory) {
					if (item is Weapon) {
						var weaponItem:Weapon = item as Weapon;					
						var weaponCopy:Weapon = weaponItem.selfCopy();
						copiedItems[weaponCopy.ITEM_TYPE].push(weaponCopy);
					} else if (item is Armor) {
						var armorItem:Armor = item as Armor;
						var armorCopy:Armor = armorItem.selfCopy();
						copiedItems[armorCopy.ITEM_TYPE].push(armorCopy);
					}
				}
			}
			newNPC.ITEMS = copiedItems;
			
			// TODO: once NPC types exist, this is a simple call to recreate graphic
			//var _imgOverlay:MonsterGraphic = new MonsterGraphic(randCritter,0,0);
			//newNPC.graphic = _imgOverlay;

			return newNPC;
		}	
		
		override public function update():void {
			if (Dungeon.player.STEP != STEP) {
				ACTION_TAKEN = false;
				// Prototype basic NPC loop
				// 1. Check if an action is already being performed
				// 2. check NPC sight range if an enemy is within
				// 3. check NPC sight range if an item is within
				// 2,3a. Find path to enemy or item
				// 2.3b. Perform path
				// 2.3c. Perform item/enemy action (attack/check for item quality/equip)
				// 4. If attacking, flee check.
				// 4a. Flee.
				// 5. After item/attack succesful resume idling
				
				COLLISION = [0, 0, 0, 0, 0];
				COLLISION_TYPE = [];
				
				checkCollision(GC.LAYER_NPC_TEXT,GC.COLLISION_NPC);
				checkCollision(GC.LAYER_PLAYER_TEXT, GC.COLLISION_PLAYER);
				//checkCollision(GC.LAYER_LEVEL_TEXT, GC.COLLISION_WALL);
				checkItem();
				
				processCombat();
				pathedMovementStep();
	
				// currently the below means creature will seek nearest non-aligned NPC
				// TODO: run away if low on HP
				// TODO: seek nearest object vs. seek target vs. run away priorities
				// TODO: seek player vs. seek NPC
				// TODO: threat levels, permanent threat levels (history)
				// TODO: use items
				// TODO: break through current status if a new interesting event occurs 
				//		 (i.e. creature is already pathing towards something but a more hated target enters the room, or loud noise is heard? or other?
				
				if (!ACTION_TAKEN && (ENGAGE_STATUS == GC.NPC_STATUS_IDLE) && !newActionOverride) {
					// we need a decision tree for seeking items, npcs and player
					// priorities could be assigned based on equipment level
					// no equipment -> seek item
					// then whatever's closer based on alignment?

					// we might have something to do with comparative levels too?
					// or, we can setup a few native "hate" rules that override other concerns
					findNPC();
					if (ACTION_TAKEN) trace(NPCType + " taking action on other NPC");

					if (!ACTION_TAKEN && (ENGAGE_STATUS == GC.NPC_STATUS_IDLE) && !newActionOverride) {
						findPlayer();
						if (ACTION_TAKEN) trace(NPCType + " taking action on Player");						
					}

					if (!ACTION_TAKEN && (ENGAGE_STATUS == GC.NPC_STATUS_IDLE) && !newActionOverride) {
						findItem();
						if (ACTION_TAKEN) trace(NPCType + " taking action on Item");
					}
				}
				
				if (!ACTION_TAKEN) {
					trace(NPCType + " idling.");
					idleMovement();
				}

				// now that I think of it, some creatures won't regen
				processRegen();
				
				// finally sync NPC with player
				STEP = Dungeon.player.STEP;
			}
		}
	}
}