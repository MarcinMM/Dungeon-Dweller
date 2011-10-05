package dungeon.contents
{
	import dungeon.contents.Creature;
	import dungeon.contents.Armor;
	import dungeon.contents.Item;
	import dungeon.contents.Weapon;
	import dungeon.structure.Node;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import dungeon.utilities.*;

	/**
	 * ...
	 * @author MM
	 */
	public class Player extends Creature
	{
		public var _imgOverlay:MonsterGraphic;
		private var syncStep:int = 0;

		public var LIGHT_RADIUS:int = 1;
		public var GRIDSIZE:int = GC.GRIDSIZE;
					
		public var INVENTORY_OPEN:Boolean = false;
		public var INVENTORY_SIZE:uint = 0;
		
		public static var invLettersUnass:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
		public var invLettersAss:Array = [];
		
		public function Player() 
		{
			super();
			
			determineCreatureType(true);
			
			_imgOverlay = new MonsterGraphic(creatureXML.graphic,0,0);
			graphic = _imgOverlay;

			Input.define(GC.DIR_LEFT_TEXT, Key.LEFT);
			Input.define(GC.DIR_RIGHT_TEXT, Key.RIGHT);
			Input.define(GC.DIR_UP_TEXT, Key.UP);
			Input.define(GC.DIR_DOWN_TEXT, Key.DOWN);
			Input.define("I", Key.I);
			Input.define("a", Key.A);
			Input.define("b", Key.B);
			Input.define("c", Key.C);
			Input.define("d", Key.D);
			Input.define("ENTER", Key.ENTER);
			Input.define(GC.NOOP, Key.SPACE);

			/*
			 * for each (var letter:String in invLettersUnass) {
				Input.define(letter, letter.charCodeAt);
			}*/
			
			setHitbox(GRIDSIZE, GRIDSIZE);
			x = 140;
			y = 140;
			type = "player";
			layer = GC.PLAYER_LAYER;
			
			// Initial player setup
			setPlayerStats();
			updatePlayerStats(true);
		}
		
		public function updatePlayerStats(init:Boolean=false):void {
			updateDerivedStats(init);
			Dungeon.statusScreen.statUpdate(STATS);			
		}
		
		public function setPlayerStats():void {
			STATS[GC.STATUS_LEVEL] = 1;
			STATS[GC.STATUS_XP] = 0;
			STATS[GC.STATUS_STR] = creatureXML.str;
			STATS[GC.STATUS_AGI] = creatureXML.agi;
			STATS[GC.STATUS_INT] = creatureXML.int;
			STATS[GC.STATUS_WIS] = creatureXML.wis;
			STATS[GC.STATUS_CHA] = creatureXML.cha;
			STATS[GC.STATUS_CON] = creatureXML.con;
			STATS[GC.STATUS_HEALRATE] = 15;
			STATS[GC.STATUS_HEALSTEP] = 0;
		}
		

		// Just a helper function for setting and updating stat visuals
		public function setPlayerStartingPosition(setX:int, setY:int):void {
			x = setX * GRIDSIZE;
			y = setY * GRIDSIZE;
		}
		
		// now neatly sidesteps the issue of what the item is and just lets you unequip/equip it based on type and slot, anonymously
		public function activateItemAt(letter:String):void {
			// first we need to find which item this is by its identifying letter
			for each (var itemAr:Array in ITEMS) {
				for each (var item:* in itemAr) {
					if (item.invLetter == letter) {
						var foundItem:Item = item;
					}
				}
			}
			
			// if not found, we need to skip the entire equip/unequip thing
			if (foundItem != null) {
				// then unequip the currently equipped item in that location and slot
				for each (item in ITEMS[foundItem.ITEM_TYPE]) {
					if (item.EQUIPPED && (item.slot == foundItem.slot)) {
						item.EQUIPPED = false;
					}
				}

				// then toggle equipped status in the found location
				foundItem.EQUIPPED = true;			
				// regardless of item equipment, stats need to be recalculated 
				updatePlayerStats();
				Dungeon.statusScreen.updateInventory();
			}
		}
		
		public function processMove():void {
			MOVE_DIR = 0;
			var newX:Number = x;
			var newY:Number = y;
			if (Input.pressed(GC.DIR_LEFT_TEXT) && !INVENTORY_OPEN) {
				MOVE_DIR = GC.DIR_LEFT;
				if (COLLISION[GC.DIR_LEFT] == GC.COLLISION_NONE) {
					newX -= GRIDSIZE;
				}
			}
			if (Input.pressed(GC.DIR_RIGHT_TEXT) && !INVENTORY_OPEN) {
				MOVE_DIR = GC.DIR_RIGHT;
				if (COLLISION[GC.DIR_RIGHT] == GC.COLLISION_NONE) {
					newX += GRIDSIZE;
				}
			}
			if (Input.pressed(GC.DIR_UP_TEXT) && !INVENTORY_OPEN) {
				MOVE_DIR = GC.DIR_UP;
				if (COLLISION[GC.DIR_UP] == GC.COLLISION_NONE) {
					newY -= GRIDSIZE;
				}
			}
			if (Input.pressed(GC.DIR_DOWN_TEXT) && !INVENTORY_OPEN) {
				MOVE_DIR = GC.DIR_DOWN;
				if (COLLISION[GC.DIR_DOWN] == GC.COLLISION_NONE) {
					newY += GRIDSIZE;
				}
			}
			// moving takes an amount of time, reset NPC move counter
			if (x != newX || y != newY) {
				Dungeon.STEP.playerStep++;
				move(newX, newY);
				Dungeon.STEP.reset();
			}
		}
		
		// make a copy
		// add copy to inventory
		// subtract original from level ITEM array
		// remove original from world
		// TODO: make this take a turn, and remember to reset npc move counter
		public function equipItem(item:*):void {
			if (item is Weapon) {
				var newInventoryWeapon:Weapon = item.selfCopy();
				ITEMS[item.ITEM_TYPE].push(newInventoryWeapon);
			} else if (item is Armor) {
				var newInventoryArmor:Armor = item.selfCopy();
				ITEMS[item.ITEM_TYPE].push(newInventoryArmor);
			}
			INVENTORY_SIZE++;

			// now remove it from level array
			Dungeon.level.ITEMS.splice(Dungeon.level.ITEMS.indexOf(item), 1);

			// and remove from world
			FP.world.remove(item);			
		}
		
		public function postMove():void {
			// TODO: atm this is item pick-up code dumped in from update, needs a once over
			if (collide("items", x, y)) {
				var itemAr:Array = [];
				collideInto("items", x, y, itemAr);
				trace(Dungeon.statusScreen.background.visible);
				// potentially could collide with all objects on the ground here
				// so we'll have to iterate
				FP.log("You see here an item :" + itemAr[0].DESCRIPTION);

				// TODO here's the code to give item to player, I guess we'll check for pickup at some point
				// for testing assume autopickup
				var newType:String = itemAr[0].ITEM_TYPE;
				// find a new letter for this and assign it to this item
				var newLetter:String = invLettersUnass.shift();
				invLettersAss.push(newLetter);
				itemAr[0].invLetter = newLetter;
				// now add item to local items
				if (itemAr[0] is Weapon) {
					var newInventoryWeapon:Weapon = itemAr[0].selfCopy();
					ITEMS[itemAr[0].ITEM_TYPE].push(newInventoryWeapon);
				} else if (itemAr[0] is Armor) {
					var newInventoryArmor:Armor = itemAr[0].selfCopy();
					ITEMS[itemAr[0].ITEM_TYPE].push(newInventoryArmor);
				}
				INVENTORY_SIZE++;

				// now remove it from level array
				Dungeon.level.ITEMS.splice(Dungeon.level.ITEMS.indexOf(itemAr[0]), 1);

				// and remove from world
				FP.world.remove(itemAr[0]);

				// now update inventory object
				Dungeon.statusScreen.updateInventory();	
			}			
		}
		
		// this could be a fight, a position switch, a conversation ... etc.
		public function processNPCCollision():void {
			if (COLLISION[MOVE_DIR] == GC.COLLISION_NPC) {
				var npcAr:Array = [];
				collideInto("npc", x + (GC.DIR_MOD_X[MOVE_DIR] * GRIDSIZE), y + (GC.DIR_MOD_Y[MOVE_DIR] * GRIDSIZE), npcAr); // this should get us the collided entity based on our move dir
				if (npcAr[0].processHit(STATS[GC.STATUS_ATT])) {
					Dungeon.statusScreen.updateCombatText("Bonk! You hit the " + npcAr[0].npcType + " for " + STATS[GC.STATUS_ATT] + " damage and kill it!");
					STATS[GC.STATUS_XP] += npcAr[0].xpGranted;
					Dungeon.STEP.playerStep++;
					Dungeon.STEP.globalStep++;
				} else {
					Dungeon.statusScreen.updateCombatText("Bonk! You hit the " + npcAr[0].npcType + " for " + STATS[GC.STATUS_ATT] + " damage!");
					Dungeon.STEP.playerStep++;
					Dungeon.STEP.globalStep++;
				}
			}
		}
		
		public function processHit(attackValue:int):void {
			// calculations to modify the attack based on player's defense stats
			STATS[GC.STATUS_HP] -= attackValue;
			Dungeon.statusScreen.updateCombatText("Bonk! You get hit for " + attackValue + " damage!");
			Dungeon.onCombat.dispatch(x, y, 'PHYSICAL', creatureXML.bloodType);
			if (STATS[GC.STATUS_HP] <= 0) {
				Dungeon.statusScreen.updateCombatText("You die ... more? Y/N/A/Q (not implemented HAR!)");
			}
			updatePlayerStats();			
		}
		
		// TODO: nothing here yet, but NPC actions will take place within NPC class based on collision
		public function postNPCCollision():void {}
		
		public function inventoryFunctions():void {
			if (Input.pressed(GC.DIR_UP)) {
				Dungeon.statusScreen.up();
			}
			if (Input.pressed(GC.DIR_DOWN)) {
				Dungeon.statusScreen.down();
			} else {
				// now test all keys for inventory
				var lastKey:uint = Input.lastKey;
				if ((lastKey != 73) && (lastKey >= 65) && (lastKey <= 90)) {
					FP.log(GC.KEYS[lastKey]);
					activateItemAt(GC.KEYS[lastKey]);
				}
			}			
		}
		
		override public function update():void
		{
			super.update();

			if (Dungeon.STEP.isReady()) {
			
				COLLISION_TYPE = [];
				COLLISION = [0, 0, 0, 0, 0];
				var directionInput:Boolean = false;
				var direction:int; // need to setup some GC directional constants for this
				var wallCollision:int = 0;
				var npcCollision:int = 0;
				
				// Set inventory flag as it overrides movement; also open status screen
				if (Input.pressed("I")) {
					if (Dungeon.statusScreen.visible == false) {
						Dungeon.statusScreen.visible = true;
						INVENTORY_OPEN = true;
					} else {
						Dungeon.statusScreen.visible = false;					
						INVENTORY_OPEN = false;
					}
				}
				
				if (( Input.pressed(GC.DIR_LEFT_TEXT) || Input.pressed(GC.DIR_RIGHT_TEXT) || Input.pressed(GC.DIR_UP_TEXT) || Input.pressed(GC.DIR_DOWN_TEXT)) && !INVENTORY_OPEN) {
					directionInput = true;
					direction = Input.lastKey;
				}
				
				if (Input.pressed(GC.NOOP)) {
					// no operation advances the player and the world
					Dungeon.STEP.playerStep++;
					Dungeon.STEP.globalStep++;
					Dungeon.STEP.reset();
				}
				
				if (directionInput) {
					COLLISION = [0, 0, 0, 0, 0];
					COLLISION_TYPE = [];

					checkCollision(GC.LAYER_NPC_TEXT,GC.COLLISION_NPC);
					checkCollision(GC.LAYER_LEVEL_TEXT, GC.COLLISION_WALL);

					processMove();
					postMove();
					processNPCCollision();
					postNPCCollision();

				} else if (!directionInput && !INVENTORY_OPEN) {
					// TODO: other actions such as zapping quaffing reading digging praying inscribing equipping that don't require collision checks go here
				} else if (INVENTORY_OPEN) {
					inventoryFunctions();
				}
				
				// process for things that only happen once per step
				if (Dungeon.STEP.playerStep != syncStep) {
					// process regeneration
					processRegen();
					Dungeon.statusScreen.statUpdate(STATS);	
					// process any cumulative equipment/enchantment effects
					syncStep = Dungeon.STEP.playerStep;
				}
			}
		}
		
	}

}