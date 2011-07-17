package  
{
	import net.flashpunk.World;
	import dungeon.utilities.StatusScreen;
	import dungeon.utilities.GC;
	import dungeon.utilities.DataLoader;
	import dungeon.utilities.Camera;
	
	/**
	 * ...
	 * @author MM
	 */
	public class Dungeon extends World
	{
		public static var player:Player;
		// TODO: var dungeon:Dungeon = FP.world as Dungeon; - this should get us the instance of the world in any context (?)
		// TODO: then we can refer to the player var without it being static (alternatively try var dungeon:Dungeon = world as Dungeon;)
		
		public static var level:Level;
		public static var statusScreen:StatusScreen;
		
		public static const MAP_WIDTH:Number = 1216;
		public static const MAP_HEIGHT:Number = 800;
		public static const TILE_WIDTH:Number = GC.GRIDSIZE;
		public static const TILE_HEIGHT:Number = GC.GRIDSIZE;
		public static const TILESX:Number = MAP_WIDTH/TILE_WIDTH;
		public static const TILESY:Number = MAP_HEIGHT/TILE_HEIGHT;


		public static var dataloader:DataLoader = new DataLoader();
		public var cam:Camera;
		
		public function Dungeon() 
		{
			dataloader.setupItems();

			statusScreen = new StatusScreen();
			
			player = new Player;
			Dungeon.level = new Level;
			add(player);
			add(level);
			
			// set up cam
			cam = new Camera(GC.CAMERA_OFFSET, GC.PLAYER_MOVEMENT_SPEED);
			cam.adjustToPlayer(MAP_HEIGHT, MAP_WIDTH, player);

			// now add all the items as entities; items were generated in level creation
			// we will need an UNloader or perhaps REloader as well
			// but this is the init
			Dungeon.level.ITEMS.forEach(addItem);
			
			// ditto for entities
			Dungeon.level.NPCS.forEach(addNPC);
			
			// status screen creation
			add(statusScreen.background);
			addList(statusScreen.displayTexts);
			addList(statusScreen.inventoryTexts);
		}
		
		private function addItem(item:*, index:int, array:Array):void {
			// instead of drawing we're actually adding to world
			add(item);
		}

		private function addNPC(npc:*, index:int, array:Array):void {
			// instead of drawing we're actually adding to world
			add(npc);
		}

		
		override public function update():void {
			// Camera moves if player reaches cam offset
			super.update();
			cam.followPlayer(MAP_HEIGHT, MAP_WIDTH, player);
		}
	}
}