package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	/**
	 * ...
	 * @author MM
	 */
	public class ItemMask extends Entity
	{
		public var _itemmap:Tilemap;
		public var _itemgrid:Grid;
		private var ITEMS:Array;
		
		public function ItemMask() 
		{
			_itemmap = new Tilemap(TILEMAP, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
			layer = 2;
			graphic = _itemmap;
			
			_itemgrid = new Grid(Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT,0,0);
			mask = _itemgrid;
			type = "items";
			// this should initialise with item array and report on collisions with its item entities
		}
		
	}

}