package  
{
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
	public class Player extends Entity
	{
		[Embed(source = 'assets/player.png')] private const PLAYER:Class;
		private const GRIDSIZE:int = 20;
		public var STEP:int = 0;
		public var LIGHT_RADIUS:int = 1;
			
		public var ARMOR:Array = new Array();
		public var WEAPONS:Array = new Array();
		public var SCROLLS:Array = new Array();
		public var POTIONS:Array = new Array();
		public var JEWELRY:Array = new Array();
		// this must correspond to the constants 0,1,2,3,4 so we can assign items properly
		public var ITEMS:Array = [ARMOR, WEAPONS, SCROLLS, POTIONS, JEWELRY];
		
		public var INVENTORY_OPEN:Boolean = false;
		public var INVENTORY_SIZE:uint = 0;
		
		public static var invLettersUnass:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
		public var invLettersAss:Array = [];
		
		// Stat Array
		public var STATS:Array = new Array();
		
		// Collision stats
		public var COLLISION:Array = [0, 0, 0, 0];
		public var COLLISION_TYPE:int = GC.COLLISION_NONE;
		
		public function Player() 
		{
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
			updatePlayerDerivedStats();
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
		
		// this also needs to work for monsters so we need to pull it out into either a higher tier class (say Creature? includes player and NPCs)
		// or make it a Util function. I like 1st approach better, I think.
		public function updatePlayerDerivedStats():void {
			// this will vary by class and equipment type later
			var weapon:Weapon = new Weapon();
			var headSlot:Armor = new Armor();
			var chestSlot:Armor = new Armor();
			var legSlot:Armor = new Armor();
			var handSlot:Armor = new Armor();
			var feetSlot:Armor = new Armor();
			
			// also, this needs to pull in all current armor and weapons, not to mention enchantments etc.
			for each (var itemAr:Array in ITEMS) {
				for each (var item:* in itemAr) {
					if (item.EQUIPPED) {
						switch(item.ITEM_TYPE) {
							case GC.C_ITEM_ARMOR:
								switch(item.armorSlot) {
									case "LEGS":
										legSlot = item;
									break;
									case "HEAD":
										headSlot = item;
									break;
									case "CHEST":
										chestSlot = item;
									break;
									case "HANDS":
										handSlot = item;
									break;
									case "FEET":
										feetSlot = item;
									break;
								}
							break;
							case GC.C_ITEM_JEWELRY:
							break;
							case GC.C_ITEM_POTIONS:
							break;
							case GC.C_ITEM_SCROLLS:
							break;
							case GC.C_ITEM_WEAPON:
								weapon = item;
							break;
						}
					}
				}
			}

			// weapon and stat for att and def are averaged, then armor is added
			// I am not sure if that makes sense, but it comes out to a sword having def. about equal to a chain chestplate
			// I guess natural stat max is 20
			// New idea: everything that relies on stats for boosts should only do so above 10pts of said stat, as 10pts is the baseline
			// New idea 2: strength and agility are %-based (of 10) multipliers on weapon attack and defence. Armor attack and defence is unaffected by stats.
			// New idea 3: weapon attack modifier should max out at 70% if str is 20. So every pt should be an extra 7%
			var attStatModifer:Number = 1 + ((STATS[GC.STATUS_STR] - 10) * 0.07) + (0.02 * (STATS[GC.STATUS_AGI] - 10));
			var defStatModifier:Number = 1 + ((STATS[GC.STATUS_AGI] - 10) * 0.7) + (0.02 * (STATS[GC.STATUS_STR] - 10));
			STATS[GC.STATUS_ATT] = Math.floor((attStatModifer * weapon.attack) + headSlot.attack + chestSlot.attack + legSlot.attack + handSlot.attack + feetSlot.attack); // plus items
			//STATS[GC.STATUS_ATT] = Math.floor(((STATS[GC.STATUS_STR] - 10) + weapon.attack + (0.2 * (STATS[GC.STATUS_AGI] - 10))) + headSlot.attack + chestSlot.attack + legSlot.attack + handSlot.attack + feetSlot.attack); // plus items
			STATS[GC.STATUS_ATT_MIN] = Math.ceil(STATS[GC.STATUS_ATT] / 2); // upper limit of half of calculated
			STATS[GC.STATUS_DEF] = Math.floor((defStatModifier * weapon.defense) + headSlot.defense + chestSlot.defense + legSlot.defense + handSlot.defense + feetSlot.defense); // plus items
			//STATS[GC.STATUS_DEF] = Math.floor(((STATS[GC.STATUS_AGI] - 10) + (0.2 * (STATS[GC.STATUS_STR] - 10)) + weapon.defense) + headSlot.defense + chestSlot.defense + legSlot.defense + handSlot.defense + feetSlot.defense); // plus items
			STATS[GC.STATUS_CRITDEF] = Math.floor((STATS[GC.STATUS_AGI] * 0.2) + headSlot.crit + chestSlot.crit + legSlot.crit + handSlot.crit + feetSlot.crit);
			STATS[GC.STATUS_PEN] = weapon.pen + (0.02 * (STATS[GC.STATUS_STR] - 10));
			STATS[GC.STATUS_PER] = STATS[GC.STATUS_CHA] / 20 + (0.01 * (STATS[GC.STATUS_STR] + STATS[GC.STATUS_WIS] - 20));
			STATS[GC.STATUS_MANA] = STATS[GC.STATUS_WIS] * 10; // plus items
			STATS[GC.STATUS_SPPOWER] = Math.floor(STATS[GC.STATUS_INT]/10); // straight dmg multiplier for spells, plus items; items should have % boosts, maybe lesser and greater spellpower being 5 and 10% boosts each?
			STATS[GC.STATUS_SPLEVEL] = STATS[GC.STATUS_LEVEL]; // plus items. should this be alterable?
			STATS[GC.STATUS_HP] = STATS[GC.STATUS_CON]; // plus items
			
			Dungeon.statusScreen.statUpdate(STATS);
		}
		
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
				updatePlayerDerivedStats();
				Dungeon.statusScreen.updateInventory();
			}
		}
		
		public function processMove():void {
			if (Input.pressed(GC.DIR_LEFT_TEXT) && (COLLISION[GC.DIR_RIGHT] == GC.COLLISION_NONE) && !INVENTORY_OPEN) {
				x -= GRIDSIZE;
				STEP++;
			}
			if (Input.pressed(GC.DIR_RIGHT_TEXT) && (COLLISION[GC.DIR_LEFT] == GC.COLLISION_NONE) && !INVENTORY_OPEN) {
				x += GRIDSIZE;
				STEP++;
			}
			if (Input.pressed(GC.DIR_UP_TEXT) && (COLLISION[GC.DIR_DOWN] == GC.COLLISION_NONE) && !INVENTORY_OPEN) {
				y -= GRIDSIZE;
				STEP++;
			}
			if (Input.pressed(GC.DIR_DOWN_TEXT) && (COLLISION[GC.DIR_UP] == GC.COLLISION_NONE) && !INVENTORY_OPEN) {
				y += GRIDSIZE;
				STEP++;
			}			
		}
		
		public function checkCollision(collisionEntity:String, collisionConstant:int):void {
			if (collide(collisionEntity, x, y + GRIDSIZE)) {
				COLLISION[GC.DIR_UP] = collisionConstant;
				COLLISION_TYPE = collisionConstant;
			}
			if (collide(collisionEntity, x, y - GRIDSIZE)) {
				COLLISION[GC.DIR_DOWN] = collisionConstant;
				COLLISION_TYPE = collisionConstant;
			}
			if (collide(collisionEntity, x + GRIDSIZE, y)) {
				COLLISION[GC.DIR_LEFT] = collisionConstant;
				COLLISION_TYPE = collisionConstant;
			}
			if (collide(collisionEntity, x - GRIDSIZE, y)){
				COLLISION[GC.DIR_RIGHT] = collisionConstant;
				COLLISION_TYPE = collisionConstant;
			}			
		}
		
		/*
		public function checkCollisionWall():void {
			if (collide("level", x, y + GRIDSIZE)) {
				COLLISION[GC.DIR_UP] = GC.COLLISION_WALL;
			}
			if (collide("level", x, y - GRIDSIZE)) {
				COLLISION[GC.DIR_DOWN] = GC.COLLISION_WALL;
			}
			if (collide("level", x + GRIDSIZE, y)) {
				COLLISION[GC.DIR_LEFT] = GC.COLLISION_WALL;
			}
			if (collide("level", x - GRIDSIZE, y)){
				COLLISION[GC.DIR_RIGHT] = GC.COLLISION_WALL;
			}
		}
		
		public function checkCollisionNPC():int {
			if (collide("npc", x, y + GRIDSIZE)) {
				COLLISION[GC.DIR_UP] = GC.COLLISION_NPC;
			}
			if (collide("npc", x, y - GRIDSIZE)) {
				COLLISION[GC.DIR_DOWN] = GC.COLLISION_NPC;
			}
			if (collide("npc", x + GRIDSIZE, y)) {
				COLLISION[GC.DIR_LEFT] = GC.COLLISION_NPC;
			}
			if (collide("npc", x - GRIDSIZE, y)){
				COLLISION[GC.DIR_RIGHT] = GC.COLLISION_NPC;
			}
		}*/
		
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
				
				// and from the display and nodemap
				// actually, just realized entities are an intrinsic part of the map
				// they can't be "removed" - they have to be relocated off screen instead
				// calculate a position 10/10 tiles (not pixels) off the current resolution
				itemAr[0].x = (Dungeon.TILESX + 10) * Dungeon.TILE_WIDTH;
				itemAr[0].y = (Dungeon.TILESY + 10) * Dungeon.TILE_HEIGHT;
				
				// now update inventory object
				Dungeon.statusScreen.updateInventory();	
			}			
		}
		
		// this could be a fight, a position switch, a conversation ... etc.
		public function processNPCCollision():void {
			Dungeon.statusScreen.updateCombatText("Bonk! You hit the enemy for " + STATS[GC.STATUS_ATT] + " damage! (but not really)");
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
			COLLISION_TYPE = GC.COLLISION_NONE;
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
			
			if (directionInput) {
				checkCollision(GC.LAYER_NPC_TEXT,GC.COLLISION_NPC);
				checkCollision(GC.LAYER_LEVEL_TEXT, GC.COLLISION_WALL);
				
				if (COLLISION_TYPE == GC.COLLISION_NONE) {
					processMove();
					postMove();
					STEP++;
				} else if (COLLISION_TYPE == GC.COLLISION_NPC) {
					// may or may not be combat, so just call it collision
					processNPCCollision();
					postNPCCollision();
					STEP++;
				} else if (COLLISION_TYPE == GC.COLLISION_WALL) {
					Dungeon.statusScreen.updateCombatText("Bonk! You run into a wall and lose 3,000 HP!");
				}
			} else if (!directionInput && !INVENTORY_OPEN) {
				// TODO: other actions such as zapping quaffing reading digging praying inscribing equipping that don't require collision checks go here
			} else if (INVENTORY_OPEN) {
				inventoryFunctions();
			}
		}
		
	}

}