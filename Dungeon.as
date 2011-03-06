package  
{
	import net.flashpunk.World;
	import dungeon.utilities.StatusScreen;
	import dungeon.utilities.GC;
	
	/**
	 * ...
	 * @author MM
	 */
	public class Dungeon extends World
	{
		public static var player:Player;
		public static var level:Level;
		public var statusScreen:StatusScreen;

		public static const MAP_WIDTH:Number = 800;
		public static const MAP_HEIGHT:Number = 600;
		public static const TILE_WIDTH:Number = 20;
		public static const TILE_HEIGHT:Number = 20;
		public static const TILESX:Number = MAP_WIDTH/TILE_WIDTH;
		public static const TILESY:Number = MAP_HEIGHT/TILE_HEIGHT;
		
		public function Dungeon() 
		{
			Dungeon.player = new Player;
			Dungeon.level = new Level;
			add(player);
			add(level);
			
			// now add all the items as entities; items were generated in level creation
			// we will need an UNloader or perhaps REloader as well
			// but this is the init
			Dungeon.level.ITEMS.forEach(addItem);
			
			add(new AnotherShip);
			
			// status screen creation
			statusScreen = new StatusScreen();
			statusScreen.visible = true;
			//add(statusScreen.background);
			addList(statusScreen.displayTexts);		
		}
		
		private function addItem(item:*, index:int, array:Array):void {
			// instead of drawing we're actually adding to world
			add(item);
		}
	}

}