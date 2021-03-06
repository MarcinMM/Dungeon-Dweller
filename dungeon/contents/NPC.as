package dungeon.contents
{
	import dungeon.contents.Item;
	import dungeon.contents.Creature;
	import dungeon.structure.Node;
	import dungeon.structure.Point;
//	import flash.automation.StageCapture;
	import net.flashpunk.FP;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import dungeon.utilities.GC;
	import dungeon.utilities.resultItem;
	import dungeon.utilities.MonsterGraphic;
	import net.flashpunk.Signal;
	import dungeon.structure.Utils;
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
		public var npcType:String;
		public var UNIQUE:Boolean = false;
		public var xpGranted:uint;
			
		// pathing status
		public var ENGAGE_STATUS:String = GC.NPC_STATUS_IDLE;
		private var PATH:Array = new Array();
		private var PATH_TARGET_ID:uint = 0;
		
		// we need some way to decide what to DO once we get to where we were going!
		public var PATH_PURPOSE:String;
		public var newActionOverride:Boolean = false; 
		private var BLOCKCOUNT:uint = 0; // keeps track of how many times pathing's been blocked; when reaches 2, path reset to new
		// TODO: this gets set true if something drastic occurs
		// loud noise from player or HP low alert, or something else?
		
		// combat/action statuses
		// 'self' will attack anything, 'player' will help player, 'race' will attack other races, 'alignment' will attack other alignments
		// 'pacifist' will attack nothing and just run, 'defensive' will attack only when attacked ... what else?
		// default is alignment
		public var FACTION:String = 'alignment'; 
		public var hitSignal:Signal;
		public var counterSignal:Signal;

		public var _imgOverlay:MonsterGraphic;
		
		// small tweak TODO: change creatureName to be creatureXML coming in from Level creature generator
		// damn I hope I remember what this means!
		public function NPC(creatureProperties:XML) 
		{
			super();
			
			// gotta consolidate this somehow
			// except that a player's init is later than creature init
			creatureXML = creatureProperties;

			// load up skills into skill array
			var skills:Array = creatureXML.skills.split(",");
			for each (var skill:String in skills) {
				SKILLS.push(skill);
			}
			
			setHitbox(GRIDSIZE, GRIDSIZE);
			type = "npc";
			STEP = Dungeon.STEP.globalStep;
			POSITION = new Point(x, y);
			

			_imgOverlay = new MonsterGraphic(creatureXML.graphic,0,0);
			graphic = _imgOverlay;
			
			// TODO: what shall it wear/wield?
			// determineNPCEquipment();
			
			// and what kind of stats does it have?
			setNPCStats();

			updateDerivedStats(true);
			
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
			var newX:Number = x;
			var newY:Number = y;

			switch (rndMoveString) {
				case "up":
				newY = y - GRIDSIZE;
				STEP++;
				break;
				case "down":
				newY = y + GRIDSIZE;
				STEP++;
				break;
				case "left":
				newX = x - GRIDSIZE;
				STEP++;
				break;
				case "right":
				newX = x + GRIDSIZE;
				STEP++;
				break;
			}
			ACTIONS_TAKEN++;
			this.move(newX, newY);
		}
		
		// this can be used to achieve goals such as pickup item or attack another entity, or seek escape route
		// before starting path, we need to obtain actual nodes from nodemap (nodemap stores collision data for entire level)
		public function initPathedMovement(pointA:Point, pointB:Point):void {
			var source:Node = Dungeon.level._nodemap.getNode(pointA.x, pointA.y);
			var destNode:Node = Dungeon.level._nodemap.getNode(pointB.x, pointB.y);
			//var source:Node = new Node(pointA.x, pointA.y, -1);
			//var destNode:Node = new Node(pointB.x, pointB.y, -1);
			PATH = source.findPath(destNode, 'creature');
			trace("Path size: " + PATH.length);
		}
		
		// get next point in the path
		// continue until depleted
		public function pathedMovementStep(teleport:Boolean = false):Boolean {
			if (PATH.length != 0) {
				// TODO (old): if I use shift() here instead of pop(), this is a cheap teleport implementation ^_^
				// TODO 3/31: now test this!
				var newLoc:Node;
				if (teleport) {
					newLoc = PATH.shift();
				}
				else {
					newLoc = PATH.pop();
				}
				// since this is more or less a teleport
				// except that it should be a teleport to the next tile over (if my path algorithm works correctly)
				// so nothing *really* broken
				// we need to check that the new node really IS just one tile away
				// and we need to ensure there's no collision happening
				var collisionTargets:Array = new Array("player", "npc");
				if (collideTypes(collisionTargets, newLoc.x * GC.GRIDSIZE, newLoc.y * GC.GRIDSIZE) != null) {
					trace(npcType + " blocked!" );
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
						this.move(newLoc.x * GC.GRIDSIZE, newLoc.y * GC.GRIDSIZE);
						//x = newLoc.x * GC.GRIDSIZE;
						//y = newLoc.y * GC.GRIDSIZE;
						POSITION.setPoint(x, y, true);
						ACTIONS_TAKEN++;
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
				
		// we might need this to be available for the player, when morphed
		public function setNPCStats():void {
			npcType = creatureXML.@name;
			xpGranted = creatureXML.xpgranted;
			// introduce 10% variation into these
			STATS[GC.STATUS_STR] = randomizeStat(uint(creatureXML.str));
			STATS[GC.STATUS_AGI] = randomizeStat(uint(creatureXML.agi));
			STATS[GC.STATUS_INT] = randomizeStat(uint(creatureXML.int));
			STATS[GC.STATUS_WIS] = randomizeStat(uint(creatureXML.wis));
			STATS[GC.STATUS_CHA] = randomizeStat(uint(creatureXML.cha));
			STATS[GC.STATUS_CON] = randomizeStat(uint(creatureXML.con));
			STATS[GC.STATUS_HEALRATE] = uint(creatureXML.healrate);
			STATS[GC.STATUS_HEALSTEP] = 0; 
		}

		public function randomizeStat(stat:uint):uint {
			var upOrDownOrNeither:Number = Math.random();
			if (upOrDownOrNeither < 0.33) {
				stat += Math.round(Math.random() * 0.1 * stat);
			} else if (upOrDownOrNeither < 0.66) {
				stat -= Math.round(Math.random() * 0.1 * stat);
			}
			// or neither
			return stat;
		}
		
		public function processCombat():void {
			// TODO: detect if foes are in adjacent tile based on collision
			// then pick one either randomly or based on previous picks
			// or perhaps even some form of 'threat' management
			// then smack!
			
			//FP.log('coll:' + COLLISION_TYPE);
			if ((COLLISION_TYPE.length > 0) && (COLLISION_TYPE.indexOf(GC.COLLISION_NPC) != -1) && !amIDone()) {
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
						Dungeon.statusScreen.updateCombatText(npcType + " hits " + hitAr[0].npcType + " for " + STATS[GC.STATUS_ATT] + " damage!");
						Dungeon.statusScreen.updateCombatText(hitAr[0].npcType + " dies.");
						trace(hitAr[0].npcType + " is hit, dies.");
						ENGAGE_STATUS = GC.NPC_STATUS_IDLE;
						trace(npcType + " idle after kill.");
					} else {
 						Dungeon.statusScreen.updateCombatText(npcType + " hits " + hitAr[0].npcType + " for " + STATS[GC.STATUS_ATT] + " damage!");
						trace(npcType + "," + ALIGNMENT + " hits " + hitAr[0].npcType + "," + hitAr[0].ALIGNMENT + " for " + STATS[GC.STATUS_ATT] + " damage!");
						trace(hitAr[0].npcType + " is hit.");
					}
					ACTIONS_TAKEN++;
					Dungeon.STEP.npcSteps++;					
				} else {
					// same alignment spliced the collision out of the hit Array
					trace(npcType + " checks its swing! 'sup buddy?");	
				}
			}
			// TODO: Player needs to be included in threat list
			// right now the player gets 2nd priority after monster hits no matter what just because of where this is
			if ((COLLISION_TYPE.length > 0) && (COLLISION_TYPE.indexOf(GC.COLLISION_PLAYER) != -1)  && !amIDone()) {
				ENGAGE_STATUS = GC.NPC_STATUS_ATTACKING_PLAYER;
				// there is only one player so we don't have to perform any calculations, just call player's hit calc
				// this is lazy if we ever do multiplayer, but that's just LOLS
				// if (threatList check here) {
				Dungeon.player.processHit(STATS[GC.STATUS_ATT]);
				ACTIONS_TAKEN++;
				Dungeon.STEP.npcSteps++;				
				// end threat list check
			}
		}
		
		public function processHit(attackValue:int):Boolean {
			// calculations to modify the attack based on player's defense stats
			// return true if dead for text and player stat update (XP+)
			STATS[GC.STATUS_HP] -= attackValue;
			Dungeon.onCombat.dispatch(x, y, 'PHYSICAL', creatureXML.bloodType);
			if (STATS[GC.STATUS_HP] <= 0) {
				// TODO: drop loot/corpse when dead
				// TODO: other effects? some creatures may explode or ooze poison or drip blood etc. event this!
				for (var index:String in Dungeon.level.NPCS) {
					var npcAr:Array = Dungeon.level.NPCS;
					if (Dungeon.level.NPCS[index] == this) {
						Dungeon.level.NPCS.splice(index,1);
					}
				}
				FP.world.remove(this);
				return true;
			} else {
				//hitSignal.dispatch(this.UNIQID);
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
						ENGAGE_STATUS == GC.NPC_STATUS_IDLE // this will need refinment to take into effect threat list
					) 
				{
					trace(npcType + " at " + x/GRIDSIZE + "," + y/GRIDSIZE + " measured: " + measuredDistance + "|interesting:" + interestingCreatureDistance);
					interestingCreatureDistance = measuredDistance;
					interestingCreature = currentNPC;
				}
			}
			
			if (interestingCreatureDistance < 1000) {
				// we have a creature closer than threshold (10 tiles away) of a different alignment, and this (not the found, but THIS) creature is idling: calculate path towards target
				NPCStart = new Point(x, y);
				NPCDest = new Point(interestingCreature.x, interestingCreature.y);
				initPathedMovement(NPCStart, NPCDest);
				if (PATH.length > 0) {
					trace(PATH.length);
					ENGAGE_STATUS = GC.NPC_STATUS_SEEKING_OBJECT;
					PATH_PURPOSE = 'ENEMY';	
					PATH_TARGET_ID = interestingCreature.UNIQID;
					trace(npcType + " at " + x / GRIDSIZE + "," + y / GRIDSIZE + " is seeking " 
						+ interestingCreature.npcType + " at " + interestingCreature.x / GRIDSIZE + "," + interestingCreature.y / GRIDSIZE 
						+ "| dist: " + Math.round(interestingCreatureDistance / GRIDSIZE));
				} else {
					trace(npcType + " at " + x / GRIDSIZE + "," + y / GRIDSIZE + " is blocked on seeking " 
					+ interestingCreature.npcType + " at " + interestingCreature.x / GRIDSIZE + "," + interestingCreature.y / GRIDSIZE 
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
				initPathedMovement(NPCStart, NPCDest);
					// we don't want to start a path if it's farther than some X (60 for now, why not?)
				if (PATH.length > 0 && PATH.length < 60) {
					ENGAGE_STATUS = GC.NPC_STATUS_SEEKING_OBJECT;
					PATH_PURPOSE = 'PLAYER';
					trace(npcType + " at " + x / GRIDSIZE + "," + y / GRIDSIZE + " is seeking player " 
						+ " at " + Dungeon.player.x / GRIDSIZE + "," + Dungeon.player.y / GRIDSIZE); 
				} else {
					// nothing, we're not using this path
					ENGAGE_STATUS = GC.NPC_STATUS_IDLE;
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
						ENGAGE_STATUS == GC.NPC_STATUS_IDLE && // this will need refinment to take into effect threat list;
						(
							(currentItem is Weapon && creatureXML.canWield) || // check if creature can even use the item
							(currentItem is Armor && creatureXML.canWear)
						)
					) 
				{
					trace(npcType + " at " + x/GRIDSIZE + "," + y/GRIDSIZE + " measured: " + measuredDistance + "|interesting:" + interestingItemDistance);
					interestingItemDistance = measuredDistance;
					interestingItem = currentItem;
				}
			}
								
			if (interestingItemDistance != 1000) {
				// we have an item closer than threshold (10 tiles away): calculate path towards target
				NPCStart = new Point(x, y);
				NPCDest = new Point(interestingItem.x, interestingItem.y);
				initPathedMovement(NPCStart, NPCDest);
				if (PATH.length > 0) {
					ENGAGE_STATUS = GC.NPC_STATUS_SEEKING_OBJECT;
					PATH_PURPOSE = 'ITEM';
					PATH_TARGET_ID = interestingItem.UNIQID;
					trace(npcType + " at " + x / GRIDSIZE + "," + y / GRIDSIZE + " is seeking " 
						+ interestingItem.ITEM_TYPE + " at " + interestingItem.x / GRIDSIZE + "," + interestingItem.y / GRIDSIZE 
						+ "| dist: " + Math.round(interestingItemDistance / GRIDSIZE));
				} else {
					trace(npcType + " at " + x / GRIDSIZE + "," + y / GRIDSIZE + " is blocked on seeking " 
					+ interestingItem.ITEM_TYPE + " at " + interestingItem.x / GRIDSIZE + "," + interestingItem.y / GRIDSIZE 
					+ "| dist: " + Math.round(interestingItemDistance / GRIDSIZE));							
				}
			}			
		}
		
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
					// check if creature can even use this item
					if ((itemOnFloor is Weapon && creatureXML.canWield) || (itemOnFloor is Armor && creatureXML.canWear)) {
						var equippedItem:resultItem = getEquippedItemByItem(itemOnFloor);
						if ((equippedItem.found && equippedItem.item.rating < itemOnFloor.rating) || !equippedItem.found) {
							// found item is better than carried/equipped, pick up and mark as equipped
							itemOnFloor.EQUIPPED = true;
							Dungeon.statusScreen.updateCombatText(npcType + " equips " + itemOnFloor.DESCRIPTION);
							
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
								Dungeon.statusScreen.updateCombatText(npcType + " drops " + equippedItem.item.DESCRIPTION);
							}
							ACTIONS_TAKEN++;
							Dungeon.STEP.npcSteps++;						
						} else {
							Dungeon.statusScreen.updateCombatText(npcType + " looks over the " + itemOnFloor.DESCRIPTION + " and leaves it alone.");
						}
					}
				}
				updateDerivedStats();
			}
			ENGAGE_STATUS = GC.NPC_STATUS_IDLE;
		}
		
		public function selfCopy():NPC {
			var newNPC:NPC = new NPC(creatureXML);

			newNPC.x = x;
			newNPC.y = y;
			newNPC.POSITION = POSITION;
			newNPC.ALIGNMENT = ALIGNMENT;
			newNPC.FACTION = FACTION;
			newNPC.npcType = npcType;
			
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
			
			return newNPC;
		}
		
		// note the X and Y here are absolute coordinates, let's make it use tiles
		public function findTileNear(origin:Point):Point {
			var newLocation:Point = origin;
			var coordX:uint = origin.x * GC.GRIDSIZE;
			var coordY:uint = origin.y * GC.GRIDSIZE;
			
			var collisionTypes:Array = [ GC.LAYER_LEVEL_TEXT, GC.LAYER_NPC_TEXT, GC.LAYER_PLAYER_TEXT ];
			
			// just check the four cardinal directions nearby
			// TODO: maybe check 2 squares away?
			if (collideTypes(collisionTypes, coordX + GC.GRIDSIZE, coordY) != null) {
				newLocation = new Point(coordX + 1, coordY, true);
			} else if (collideTypes(collisionTypes, coordX - GC.GRIDSIZE, coordY) != null) {
				newLocation = new Point(coordX - 1, coordY, true);
			} else if (collideTypes(collisionTypes, coordX, coordY + GC.GRIDSIZE) != null) {
				newLocation = new Point(coordX, coordY + 1, true);
			} else if (collideTypes(collisionTypes, coordX, coordY - GC.GRIDSIZE) != null) {
				newLocation = new Point(coordX, coordY - 1, true);
			}
			/*
			for each (var critter:NPC in NPCS) {
				if ((critter.POSITION.x == x) && (critter.POSITION.y == y)) {
					flag = false;
				}
			}
			if (Dungeon.player.x == x && Dungeon.player.y == y) {
				flag = false;
			}
			if (collide(GC.LAYER_LEVEL_TEXT)) {
				flag = false;
			}*/
			
			return newLocation;
		}
		
		override public function processSkills():void {
			super.processSkills();
			// this will need to know somehow that an action has been taken in skills; for now, disable so that 
			// we can see life again
			//ENGAGE_STATUS = GC.NPC_STATUS_USING_SPECIAL;
			//ACTIONS_TAKEN++;
			//Dungeon.STEP.npcSteps++;
		}
		
		override public function update():void {
			super.update();
			if (Dungeon.STEP.globalStep != STEP) {
				ACTIONS_TAKEN = 0;
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
				if (creatureXML.canWield || creatureXML.canWear) {
					checkItem();
				}

				// passives and actives pre-combat
				// gonna have to rename combat to melee I think. even that is not accurate as some specials will be melee
				// TODO: perhaps combat needs to not deal with the decision making of which creature to hit, but only with the consequences
				// that would make more sense
				// processDamage(); processSkills(); - perhaps skills should include even things like melee, since it'll include ranged ... hmm!
				// shit I need a better TODO. Something with more oomph, like TODOORDIE!
				
				// a creature can have multiple actions per STEP (turn)
				while (!amIDone()) {
					if (ACTIONS_TAKEN < 1) {
						// since skills can modify amounts of further actions taken, they are only allowed once
						processSkills();
					}

					processCombat();

					if (!amIDone()) {
						pathedMovementStep();
					}
		
					// currently the below means creature will seek nearest non-aligned NPC
					// TODO: run away if low on HP
					// TODO: seek nearest object vs. seek target vs. run away priorities
					// TODO: seek player vs. seek NPC
					// TODO: threat levels, permanent threat levels (history)
					// TODO: use items
					// TODO: break through current status if a new interesting event occurs 
					//		 (i.e. creature is already pathing towards something but a more hated target enters the room, or loud noise is heard? or other?
					
					if (!amIDone() && (ENGAGE_STATUS == GC.NPC_STATUS_IDLE) && !newActionOverride) {
						// we need a decision tree for seeking items, npcs and player
						// priorities could be assigned based on equipment level
						// no equipment -> seek item
						// then whatever's closer based on alignment?

						// we might have something to do with comparative levels too?
						// or, we can setup a few native "hate" rules that override other concerns
						findNPC();
						if (amIDone()) trace(npcType + " taking action on other NPC");

						if (!amIDone() && (ENGAGE_STATUS == GC.NPC_STATUS_IDLE) && !newActionOverride) {
							findPlayer();
							if (amIDone()) trace(npcType + " taking action on Player");						
						}

						if (!amIDone() && (ENGAGE_STATUS == GC.NPC_STATUS_IDLE) && !newActionOverride && (creatureXML.canWear || creatureXML.canWield)) {
							findItem();
							if (amIDone()) trace(npcType + " taking action on Item");
						}
					}
					
					if (!amIDone()) {
						trace(npcType + " idling.");
						idleMovement();
					}
				}
				
				// finally sync NPC with player
				STEP = Dungeon.STEP.globalStep;
			}
		}
	}
}
