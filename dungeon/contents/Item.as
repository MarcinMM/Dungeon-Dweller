package dungeon.contents 
{
	import dungeon.structure.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.*;
	import net.flashpunk.FP;
	/**
	 * ...
	 * @author MM
	 */
	public class Item extends Entity
	{
		// uniqid, for target ec.
		public var UNIQID:uint = 0;
		
		// local step, to be synced with global PLAYER step
		private var _step:uint = 0;
		
		// which tile this item is represented by
		public var tileIndex:uint = 0;
		
		// intrinsics
		public var VALUE:uint;
		public var WEIGHT:uint;
		public var CURSED:Boolean;
		public var BLESSED:Boolean;
		public var ITEM_LEVEL:uint;
		public var MODIFIER:int;
		public var ITEM_TYPE:uint;
		
		// ownership
		public var OWNED:Boolean;
		public var EQUIPPED:Boolean = false;
		public var IN_STORE:Boolean;
		public var STOLEN:Boolean;
		
		// properties
		public const DESC_MODIFIER:Array = ["orcish", "elven", "dwarven", "draconic"];
		public var DESCRIPTION:String; // stores un-identified text
		public var TRUE_DESCRIPTION:String; // stores fully identified text
		public var rating:Number;
		
		// Inventory Management
		public var invLetter:String = "";
		public var slot:uint;
		
		// items get generated on level creation at random
		// we need an item quota perhaps based on dungeon level depth

		public function Item() 
		{
			// initialise various bits
			var uniqidSeed:Number = Math.random() * 10000000000;
			UNIQID = uint (uniqidSeed);
			
			// we can set a chance of cursed or blessed universally
			// just about everything else? probably should be init'd in subclasses
			// cursed/blessed chance is hardcoded at 5%
			var curseRand:uint = Math.round(Math.random() * 100);
			if (curseRand < 5) {
				CURSED = true;
			} else {
				var blessRand:uint = Math.round(Math.random() * 100);
				if (blessRand < 5) {
					BLESSED = true;
				}
			}
			
			// weight and value and level has to draw from item and from level ...
			
			// location, currently random within bounds
			var newX:uint = Math.round(Math.random() * Dungeon.TILESX);
			var newY:uint = Math.round(Math.random() * Dungeon.TILESY);
			x = newX * Dungeon.TILE_WIDTH;
			y = newY * Dungeon.TILE_HEIGHT;
			
			setHitbox(Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
			
			type = "items";
			layer = 25;
		}
		
		// common functions, what could they be?
		// carried vs. not carried? or player?
		// equipped vs not equipped? or on player?
		override public function update():void
		{
			// synchronize with global step
			if (_step != Dungeon.player.STEP) {
				_step = Dungeon.player.STEP;
				if (collide("player", x, y)) {
					FP.log("collision with player");
					//var s:Player = collide("player", x, y) as Player;
					FP.log("This is a: " + DESCRIPTION);
				}
			}
		}

	}

}