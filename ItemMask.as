package  
{
	import dungeon.contents.Item;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	import dungeon.contents.Armor;
	import dungeon.contents.Weapon;
	/**
	 * ...
	 * @author MM
	 */
	public class ItemMask extends Entity
	{
		[Embed(source = 'assets/itemtile.png')] private const ITEMTILEMAP:Class;
		public var _itemmap:Tilemap;
		public var _itemgrid:Grid;
		public var ITEMS:Array = [];

		// more level entities
		public var ITEM_GEN:Object = {
			0: generateWeapon,
			1: generateWeapon,
			2: generateArmor,
			3: generateArmor
			/*
			4: generateScroll,
			5: generateScroll,
			6: generateScroll,
			7: generatePotion,
			8: generatePotion,
			9: generatePotion,
			10: generateJewelry,
			11: generateWand,
			12: generateGem,
			13: generateMoney,
			14: generateUnique */
		}
		
		public function ItemMask() 
		{
			_itemmap = new Tilemap(ITEMTILEMAP, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
			layer = 2;
			graphic = _itemmap;
			
			_itemgrid = new Grid(Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT,0,0);
			mask = _itemgrid;
			type = "items";
			// this should initialise with item array and report on collisions with its item entities
			init();
		}
		
		public function init():void {
			// generate items for the level and handle drawing them as well
			for (var i:uint = 0; i < 10; i++) {
				var itemGen:uint = Math.round(Math.random() * 3);
				var callback:Function = ITEM_GEN[itemGen];
				callback();
			}
			ITEMS.forEach(drawItem);
		}
		
		
		private function drawItem(item:*, index:int, array:Array):void {
			_itemmap.setRect(item.dropLoc.x, item.dropLoc.y, 1, 1, item.tileIndex);
			_itemgrid.setRect(item.dropLoc.x, item.dropLoc.y, 1, 1, true);
		}
		
		// handlers for generating new items and pushing them to the level item collection
		private function generateWeapon():void {
			var weapon:Weapon = new Weapon();
			ITEMS.push(weapon);
		}

		private function generateArmor():void {
			var armor:Armor = new Armor();
			ITEMS.push(armor);
		}
				
	}

}