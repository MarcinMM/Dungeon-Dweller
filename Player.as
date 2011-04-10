package  
{
	import dungeon.contents.Item;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import dungeon.utilities.StatusScreen;
	import dungeon.utilities.GC;

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
		public var invLeterrsAss:Array = [];
		
		public function Player() 
		{
			graphic = new Image(PLAYER);
			Input.define("Left", Key.LEFT);
			Input.define("Right", Key.RIGHT);
			Input.define("Up", Key.UP);
			Input.define("Down", Key.DOWN);
			Input.define("I", Key.I);
			Input.define("a", Key.A);

			/*
			 * for each (var letter:String in invLettersUnass) {
				Input.define(letter, letter.charCodeAt);
			}*/
			
			//Input.define("a", Key.a);
			setHitbox(20, 20);
			x = 140;
			y = 140;
			type = "player";
			layer = 20;
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
			
			// then toggle equipped status in the found location
			foundItem.EQUIPPED = true;
			// then process whatever happens based on item type
			// this is probably a massive TODO
			switch(foundItem.ITEM_TYPE) {
				case GC.C_ITEM_ARMOR:
					break;
				case GC.C_ITEM_WEAPON:
					break;
			}
			Dungeon.statusScreen.updateInventory();
		}
		
		override public function update():void
		{
			var leftImpact:Boolean = false, rightImpact:Boolean = false, topImpact:Boolean = false, bottomImpact:Boolean = false;
			//var s:AnotherShip = collide("npcShip", x, y) as AnotherShip;
			if (collide("npcShip", x, y + GRIDSIZE) || collide("level", x, y + GRIDSIZE)) {
				topImpact = true;
			}
			if (collide("npcShip", x, y - GRIDSIZE) || collide("level", x, y - GRIDSIZE)) {
				bottomImpact = true;
			}
			if (collide("npcShip", x + GRIDSIZE, y) || collide("level", x + GRIDSIZE, y)) {
				leftImpact = true;
			}
			if (collide("npcShip", x - GRIDSIZE, y) || collide("level", x - GRIDSIZE, y)){
				rightImpact = true;
			}
			
			// Player movement
			if (Input.pressed("Left") && !rightImpact && !INVENTORY_OPEN) {
				x -= GRIDSIZE;
				STEP++;
				trace("player at:" + (x/GRIDSIZE) + "-" + (y/GRIDSIZE));
			}
			if (Input.pressed("Right") && !leftImpact && !INVENTORY_OPEN) {
				x += GRIDSIZE;
				STEP++;
				trace("player at:" + (x/GRIDSIZE) + "-" + (y/GRIDSIZE));
			}
			if (Input.pressed("Up") && !bottomImpact && !INVENTORY_OPEN) {
				y -= GRIDSIZE;
				STEP++;
				trace("player at:" + (x/GRIDSIZE) + "-" + (y/GRIDSIZE));
			}
			if (Input.pressed("Down") && !topImpact && !INVENTORY_OPEN) {
				y += GRIDSIZE;
				STEP++;
				trace("player at:" + (x/GRIDSIZE) + "-" + (y/GRIDSIZE));
			}

			// Inventory Management
			if (INVENTORY_OPEN) {
				if (Input.pressed("Up")) {
					Dungeon.statusScreen.up();
				}
				if (Input.pressed("Down")) {
					Dungeon.statusScreen.down();
				}
				// now all inventory keys
				if (Input.pressed("a")) {
					activateItemAt("a");
				}
				
			}
			if (Input.pressed("I")) {
				// this needs to suspend movement and turn directional keys to inventory traversal
				if (Dungeon.statusScreen.visible == false) {
					Dungeon.statusScreen.visible = true;
					INVENTORY_OPEN = true;
				} else {
					Dungeon.statusScreen.visible = false;					
					INVENTORY_OPEN = false;
				}
			}
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
				invLeterrsAss.push(newLetter);
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
			//FP.log("Step: " + STEP);
			//FP.watch("STEP");
		}
		
	}

}