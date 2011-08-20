package  
{
	import dungeon.structure.Decor;
	import dungeon.structure.Nodemap;
	import dungeon.utilities.LevelInfoHolder;
	import dungeon.utilities.Overlay;
	import net.flashpunk.graphics.TiledImage;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.World;
	import dungeon.utilities.StatusScreen;
	import dungeon.utilities.GC;
	import dungeon.utilities.DataLoader;
	import dungeon.utilities.Camera;
	import dungeon.contents.Player;
	import dungeon.structure.Level;
	
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
		[Embed(source = 'assets/tilemap.png')] private const TILEMAP:Class;

		// these are redefined here for use in future map generation
		// it is possible that the dungeon will contain varied-size levels
		// so we will be generating map sizes that differ from the global constants for those
		public static var MAP_WIDTH:Number;
		public static var MAP_HEIGHT:Number;
		public static var TILE_WIDTH:Number;
		public static var TILE_HEIGHT:Number;
		public static var GRIDSIZE:Number;
		public static var TILESX:Number;
		public static var TILESY:Number;

		public static var dataloader:DataLoader = new DataLoader();
		public var cam:Camera;
		
		public static var LevelHolder:Vector.<LevelInfoHolder>;
		public static var LevelHolderCounter:int;
		
		// this is for detecting mouse clicks and positions, and taking actions on it
		public static var overlay:Overlay;
		
		public function Dungeon() {

		}
		
		override public function begin():void {
			super.begin();
			LevelHolder = new Vector.<LevelInfoHolder>;
			LevelHolderCounter = 0;
			initMapSizes();

			dataloader.setupItems();

			statusScreen = new StatusScreen();
			
			player = new Player;
			Dungeon.level = new Level;
			add(player);
			add(level);
			
			// set up cam
			cam = new Camera(GC.CAMERA_OFFSET, GC.PLAYER_MOVEMENT_SPEED);
			cam.adjustToPlayer(MAP_HEIGHT, MAP_WIDTH, player);
			
			// status screen creation
			add(statusScreen.background);
			addList(statusScreen.displayTexts);
			addList(statusScreen.inventoryTexts);

			overlay = new Overlay;
			add(overlay);
		}

		// this will be where a possible future dataloader will determine level size for customized levels
		// currently, just load from globals
		public function initMapSizes():void {
			MAP_WIDTH = GC.MAP_WIDTH; 
			MAP_HEIGHT = GC.MAP_HEIGHT;
			TILE_WIDTH = GC.GRIDSIZE;
			TILE_HEIGHT = GC.GRIDSIZE;
			GRIDSIZE = GC.GRIDSIZE;
			TILESX = MAP_WIDTH/TILE_WIDTH;
			TILESY = MAP_HEIGHT/TILE_HEIGHT;
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