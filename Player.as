package  
{
	import dungeon.contents.Item;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import dungeon.utilities.StatusScreen;

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
		
		public var EQ_WEAPONS:Array;
		public var EQ_ARMOR:Array;
		public var EQ_JEWELRY:Array;
		
		public var ARMOR:Array = new Array();
		public var WEAPONS:Array = new Array();
		public var SCROLLS:Array = new Array();
		public var POTIONS:Array = new Array();
		public var JEWELRY:Array = new Array();
		// this must correspond to the constants 0,1,2,3,4 so we can assign items properly
		public var ITEMS:Array = [ARMOR, WEAPONS, SCROLLS, POTIONS, JEWELRY];
		
		public function Player() 
		{
			graphic = new Image(PLAYER);
			Input.define("Left", Key.LEFT);
			Input.define("Right", Key.RIGHT);
			Input.define("Up", Key.UP);
			Input.define("Down", Key.DOWN);
			Input.define("I", Key.I);
			setHitbox(20, 20);
			x = 140;
			y = 140;
			type = "player";
		}
		
		public function setPlayerStartingPosition(setX:int, setY:int):void {
			x = setX * GRIDSIZE;
			y = setY * GRIDSIZE;
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
			if (Input.pressed("Left") && !rightImpact) {
				x -= GRIDSIZE;
				STEP++;
				trace("player at:" + (x/GRIDSIZE) + "-" + (y/GRIDSIZE));
			}
			if (Input.pressed("Right") && !leftImpact) {
				x += GRIDSIZE;
				STEP++;
				trace("player at:" + (x/GRIDSIZE) + "-" + (y/GRIDSIZE));
			}
			if (Input.pressed("Up") && !bottomImpact) {
				y -= GRIDSIZE;
				STEP++;
				trace("player at:" + (x/GRIDSIZE) + "-" + (y/GRIDSIZE));
			}
			if (Input.pressed("Down") && !topImpact) {
				y += GRIDSIZE;
				STEP++;
				trace("player at:" + (x/GRIDSIZE) + "-" + (y/GRIDSIZE));
			}
			if (Input.pressed("I")) {
				if (Dungeon.statusScreen.visible == false) {
					Dungeon.statusScreen.visible = true;
				} else {
					Dungeon.statusScreen.visible = false;					
				}
			}
			if (collide("items", x, y)) {
				var itemAr:Array = [];
				collideInto("items", x, y, itemAr);
				// potentially could collide with all objects on the ground here
				// so we'll have to iterate
				FP.log("You see here an item :" + itemAr[0].DESCRIPTION);

				// here's the code to give item to player, I guess we'll check for pickup at some point
				// for testing assume autopickup
				var newType:String = itemAr[0].ITEM_TYPE;
				ITEMS[itemAr[0].ITEM_TYPE].push(itemAr[0]);

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