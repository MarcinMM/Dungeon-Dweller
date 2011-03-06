package dungeon.contents 
{
	import dungeon.structure.Point;
	import net.flashpunk.Entity;
	/**
	 * ...
	 * @author MM
	 */
	public class Item extends Entity
	{
		[Embed(source = '../../assets/itemtile.png')] private const ITEMTILEMAP:Class;
		// which tile this item is represented by
		public var tileIndex:uint = 0;
		
		// intrinsics
		public var VALUE:uint;
		public var WEIGHT:uint;
		public var CURSED:Boolean;
		public var BLESSED:Boolean;
		public var ITEM_LEVEL:uint;
		public var MODIFIER:int;
		
		// ownership
		public var OWNED:Boolean;
		public var IN_STORE:Boolean;
		public var STOLEN:Boolean;
		
		// properties
		public const DESC_MODIFIER:Array = ["orcish", "elven", "dwarven", "draconic", "bone"];
		public var DESCRIPTION:String;
		
		// items get generated on level creation at random
		// we need an item quota perhaps based on dungeon level depth
		// 

		public function Item() 
		{
			// initialise various bits
			// we can set a chance of cursed or blessed universally
			// just about everything else? probably should be init'd in subclasses
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
			x = newX;
			y = newY;
			setHitbox(Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
		}
		
		// common functions, what could they be?
		// carried vs. not carried? or player?
		// equipped vs not equipped? or on player?
	}

}