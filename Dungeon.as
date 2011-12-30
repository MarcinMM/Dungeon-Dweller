package  
{
	import dungeon.structure.Decor;
	import dungeon.structure.Nodemap;
	import dungeon.utilities.GameStatusScreen;
	import dungeon.utilities.LevelInfoHolder;
	import dungeon.utilities.Overlay;
	import dungeon.utilities.Step;
	import net.flashpunk.graphics.TiledImage;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.World;
	import dungeon.utilities.StatusScreen;
	import dungeon.utilities.GC;
	import dungeon.utilities.DataLoader;
	import dungeon.utilities.Camera;
	import dungeon.contents.Player;
	import dungeon.structure.Level;
	import dungeon.utilities.Step;
	import net.flashpunk.Signal;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.FP;
	
	/**
	 * ...
	 * @author MM
	 */
	public class Dungeon extends World
	{
		public static var gameEnd:Boolean = false; // global game over watch, be it victory, death or suspend
		
		public static var player:Player;
		// TODO: var dungeon:Dungeon = FP.world as Dungeon; - this should get us the instance of the world in any context (?)
		// TODO: then we can refer to the player var without it being static (alternatively try var dungeon:Dungeon = world as Dungeon;)

		// world STEP
		public static var STEP:Step;
		
		public static var level:Level;
		public static var statusScreen:StatusScreen;
		public static var gameStatusScreen:GameStatusScreen; // game start and game over screen
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
		
		public static var onCombat:Signal = new Signal;

		// this is for detecting mouse clicks and positions, and taking actions on it
		public static var overlay:Overlay;
		
		public function Dungeon() {

		}
		
		override public function begin():void {
			super.begin();
			
			STEP = new Step();
			
			LevelHolder = new Vector.<LevelInfoHolder>;
			LevelHolderCounter = 0;
			initMapSizes();

			dataloader.setupItems();

			statusScreen = new StatusScreen();
			gameStatusScreen = new GameStatusScreen();
			
			player = new Player; // this will need to pass in parameter from level select
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

			// game start and end screens?
			add(gameStatusScreen.background);
			addList(gameStatusScreen.startTexts);
			addList(gameStatusScreen.endTexts);
			
			overlay = new Overlay;
			add(overlay);
			
			STEP.setInitialNPCLength(level.NPCS.length);
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
		
		override public function end():void
		{
			// do a bunch of stuff clearing the previous state, then show the start screen again
			remove(player);
			remove(level);
			remove(overlay);
			removeAll(); // yoiks! hmm shouldn't this wipe out NPcs? and items? verify!
			
			begin();
			gameEnd = false;
		}
		
		override public function update():void {
			// global game over watch
			if (gameEnd && Input.pressed(Key.ANY)) {
				end();
			}
			
			// Camera moves if player reaches cam offset
			super.update();
			cam.followPlayer(MAP_HEIGHT, MAP_WIDTH, player);
		}
	}
}