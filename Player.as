package  
{
	import dungeon.Creature;
	import dungeon.contents.Armor;
	import dungeon.contents.Item;
	import dungeon.contents.Weapon;
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
		[Embed(source = 'assets/player.png')] private const PLAYER:Class;
		public var STEP:int = 0;
		public var LIGHT_RADIUS:int = 1;
		public var GRIDSIZE:int = 20;
					
		public var INVENTORY_OPEN:Boolean = false;
		public var INVENTORY_SIZE:uint = 0;
		
		public static var invLettersUnass:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
		public var invLettersAss:Array = [];
		
		public function Player() 
		{
			super();
			graphic = new Image(PLAYER);
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
			
			setHitbox(20, 20);
			x = 140;
			y = 140;
			type = "player";
			layer = 20;
			
			// Initial player setup
			setPlayerStats("bruiser");
			updatePlayerStats(true);
		}
		
		public function updatePlayerStats(init:Boolean=false):void {
			updateDerivedStats(init);
			Dungeon.statusScreen.statUpdate(STATS);			
		}
		
		public function setPlayerStats(playerClass:String):void {
			STATS[GC.STATUS_LEVEL] = 1;
			STATS[GC.STATUS_XP] = 0;
			switch(playerClass) {
				case "bruiser":
					STATS[GC.STATUS_STR] = 14;
					STATS[GC.STATUS_AGI] = 10;
					STATS[GC.STATUS_INT] = 10;
					STATS[GC.STATUS_WIS] = 10;
					STATS[GC.STATUS_CHA] = 10;
					STATS[GC.STATUS_CON] = 14;
					break;
				case "shaman":
					STATS[GC.STATUS_STR] = 10;
					STATS[GC.STATUS_AGI] = 10;
					STATS[GC.STATUS_INT] = 13;
					STATS[GC.STATUS_WIS] = 13;
					STATS[GC.STATUS_CHA] = 12;
					STATS[GC.STATUS_CON] = 10;
					break;
				case "scout":
					STATS[GC.STATUS_STR] = 11;
					STATS[GC.STATUS_AGI] = 12;
					STATS[GC.STATUS_INT] = 11;
					STATS[GC.STATUS_WIS] = 11;
					STATS[GC.STATUS_CHA] = 11;
					STATS[GC.STATUS_CON] = 12;
					break;
			}
		}
		

		// Just a helper function for setting and updating stat visuals
		public function setPlayerStartingPosition(setX:int, setY:int):void {
			x = setX * GRIDSIZE;
			y = setY * GRIDSIZE;
		}
		
		// Equip, wield, wear or whatever? This needs to do hand-detection, applying effects, modifying attack, defense and resistances
		// and everything else that happens when you uh "activate" an item. :D
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
				// then unequip the currently equipped item in that location
				switch(foundItem.ITEM_TYPE) {
					case GC.C_ITEM_ARMOR:
						// this needs to unequip based on slot, atm it unequips all
						var armorItem:Armor = foundItem as Armor;
						for each (var armor:Armor in ITEMS[GC.C_ITEM_ARMOR]) {
							if (armor.EQUIPPED && (armor.armorSlot == armorItem.armorSlot)) {
								armor.EQUIPPED = false;
							}
						}
					break;
					case GC.C_ITEM_WEAPON:
						var weaponItem:Weapon = foundItem as Weapon;
						// this needs to unequip based on handedness, atm it unequips all
						for each (var weapon:Weapon in ITEMS[GC.C_ITEM_WEAPON]) {
							if (weapon.EQUIPPED) {
								weapon.EQUIPPED = false;
							}
						}
					break;
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
			if (Input.pressed(GC.DIR_LEFT_TEXT) && !INVENTORY_OPEN) {
				MOVE_DIR = GC.DIR_LEFT;
				if (COLLISION[GC.DIR_LEFT] == GC.COLLISION_NONE) {
					x -= GRIDSIZE;
					STEP++;
				}
			}
			if (Input.pressed(GC.DIR_RIGHT_TEXT) && !INVENTORY_OPEN) {
				MOVE_DIR = GC.DIR_RIGHT;
				if (COLLISION[GC.DIR_RIGHT] == GC.COLLISION_NONE) {
					x += GRIDSIZE;
					STEP++;
				}
			}
			if (Input.pressed(GC.DIR_UP_TEXT) && !INVENTORY_OPEN) {
				MOVE_DIR = GC.DIR_UP;
				if (COLLISION[GC.DIR_UP] == GC.COLLISION_NONE) {
					y -= GRIDSIZE;
					STEP++;
				}
			}
			if (Input.pressed(GC.DIR_DOWN_TEXT) && !INVENTORY_OPEN) {
				MOVE_DIR = GC.DIR_DOWN;
				if (COLLISION[GC.DIR_DOWN] == GC.COLLISION_NONE) {
					y += GRIDSIZE;
					STEP++;
				}
			}
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

				// here's the code to give item to player, I guess we'll check for pickup at some point
				// for testing assume autopickup
				var newType:String = itemAr[0].ITEM_TYPE;
				// find a new letter for this and assign it to this item
				var newLetter:String = invLettersUnass.shift();
				invLettersAss.push(newLetter);
				itemAr[0].invLetter = newLetter;
				// now add item to local items
				ITEMS[itemAr[0].ITEM_TYPE].push(itemAr[0]);
				INVENTORY_SIZE++;

				// now remove it from level array
				Dungeon.level.ITEMS.splice(Dungeon.level.ITEMS.indexOf(itemAr[0]), 1);
				
				// entities can't be "removed" - they have to be relocated off screen instead
				// calculate a position 10/10 tiles (not pixels) off the current resolution
				itemAr[0].x = (Dungeon.TILESX + 10) * Dungeon.TILE_WIDTH;
				itemAr[0].y = (Dungeon.TILESY + 10) * Dungeon.TILE_HEIGHT;
				
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
					Dungeon.statusScreen.updateCombatText("Bonk! You hit the enemy for " + STATS[GC.STATUS_ATT] + " damage and kill it!");
					STEP++;
				} else {
					Dungeon.statusScreen.updateCombatText("Bonk! You hit the enemy for " + STATS[GC.STATUS_ATT] + " damage!");
					STEP++;
				}
			}
		}
		
		public function processHit(attackValue:int):void {
			// calculations to modify the attack based on player's defense stats
			STATS[GC.STATUS_HP] -= attackValue;
			Dungeon.statusScreen.updateCombatText("Bonk! You get hit for " + attackValue + " damage!");
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
				STEP++;
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
		}
		
	}

}