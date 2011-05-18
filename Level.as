package  
{
	import dungeon.contents.Armor;
	import dungeon.contents.Weapon;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.utils.Draw;	
	import dungeon.structure.Room;
	import dungeon.structure.Door;
	import dungeon.structure.Point;
	import dungeon.structure.Utils;
	import dungeon.structure.Node;
	import dungeon.structure.Nodemap;

	/**
	 * ...
	 * @author MM
	 */
	public class Level extends Entity
	{
		[Embed(source = 'assets/tilemap.png')] private const TILEMAP:Class;
		public var _dungeonmap:Tilemap;
		public var _nodemap:Nodemap;
		public var _grid:Grid;

		private const _roomsMax:int = 20;
		private const _roomsBigChance:int = 2; // 20% chance, 2 out of 10
		private const _roomsBigMax:int = 2;
		private const _roomLimitMax:int = 10;
		private const _roomLimitNormal:int = 6;
		Input.define("DownLevel", Key.L);

		public var _roomsA:Array = [];
		private var _rooms:int = 0;
		public var ITEMS:Array = [];
		public var NPCS:Array = [];

		// Level game data
		public var dungeonDepth:uint = 1;

		// frequency array for levels; will probably need to be dynamic
		// this rudimentary distribution array should work for now
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
		
        public static const FLOOR:int = 7;
		public static const HALL:int = 3;
        public static const NWALL:int = 8;
        public static const SWALL:int = 10;
        public static const WWALL:int = 11;
        public static const EWALL:int = 9;
		// top right bottom left
		public static const DEBUG:int = 2;

		public static const WALLS:Object = {left:11, right:9, top:8, bottom:10};
		public static const DOORS:Object = {left:15, right:13, top:12, bottom:14};
		public static const CORNERS:Object = {TL:19, TR:16, BL:18, BR:17};
		public static const HALLWAYTILES:Array = [2]; // rock and floor is available for hallway making
		
		// nonsolids
		public static const NONSOLIDS:Array = [7,12,13,14,15]; // doors and floor
		public static const DOORSA:Array = [12,13,14,15];
		
		public static const DEBUGR:int = 5;
		public static const DEBUGG:int = 6;

		
		public var _step:int = 0;
		
		// temporary monster generation
		public var MONSTARS:Array = ["paladin","rogue","warrior","monk","mage","fighter","sorcerer","wizard","shapeshifter","teleporter","ranger","vampire","archer"];

		
		public function Level() 
		{
			FP.console.enable();
			drawLevel();
			// init level tilemap and collision grid mask
			
			// TEH LOGIK
			
			/* This is going to be an attempt at creating an Architect type level-builder,
			 * in which the level is created organically by an "agent" that would start out
			 * in a room, hollow out a corridor to the next room, create the next room, and so on,
			 * returning to connect this and that room according to random whim. No quadrants or
			 * level division will be used.
			 * There are some assumptions/wishes:
			 * - not necessarily looped levels
			 * - dead ends are allowed but not too many for playability
			 * - only one or two BIG rooms, this is a dungeon afterall
			 * - FUTURE: dungeons can be irregular shapes, but only 2 or 3 pixels out (or in) from rectangular
			 * - FUTURE: there will be some premades
			 * - FUTURE: there will be hidden passages to secret rooms (right now algorithm will try to connect all, so this will be a post-generation thing)
			 */	
		}

		
		private function drawLevel():void {
			_dungeonmap = new Tilemap(TILEMAP, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
			_dungeonmap.setRect(0,0,Dungeon.TILESX, Dungeon.TILESY, DEBUG); 
			graphic = _dungeonmap;
			layer = 50;
			
			_grid = new Grid(Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT,0,0);
			mask = _grid;
			type = "level";
			
			drawRooms();
			_nodemap = new Nodemap(_dungeonmap, _roomsA);
			_nodemap.drawHallways();

			drawGrid();

			createItems();
			
			placeItems();
			
			placePlayer();
			
			createAndPlaceNPCs();
		}
		
		private function drawRooms():void {
			var _bigRoomCount:int = 0;
			var width:int = 0;
			var height:int = 0;
			var _bigRoomRand:int = 0;
			var x:int = 0;
			var y:int = 0;

			for (var i:int = 0; i < _roomsMax; i++) {
				_bigRoomRand = Math.round(Math.random() * 10);
				if ((_bigRoomRand < _roomsBigChance) && (_bigRoomCount < _roomsBigChance)) {
					width = Math.round(Math.random() * _roomLimitMax + 3);
					height = Math.round(Math.random() * _roomLimitMax + 3);
					_bigRoomCount++;
				} else {
					width = Math.round(Math.random() * _roomLimitNormal + 3);
					height = Math.round(Math.random() * _roomLimitNormal + 3);				
				}
				x = Math.round(Math.random() * Dungeon.TILESX);
				y = Math.round(Math.random() * Dungeon.TILESY);
				var newRoom:Room = new Room(x, y, width, height);
				_roomsA = newRoom.draw(_dungeonmap, _roomsA);
				if (_roomsA.length > _rooms) {
					_rooms++;
					// means room was added successfully
				} else {
					trace('no room added');
				}
			}			
		}

		// this will not only draw items but extra clutter
		// probably monsters
		// stairs
		// add interesting room features
		// etc
		public function placeItems():void {
			var x:uint = 0;
			var y:uint = 0;
			var roomIndex:uint = 0;

			for each (var item:* in ITEMS) {
				roomIndex = Math.max(0, (Math.round(Math.random() * _roomsA.length) - 1));
				x = (_roomsA[roomIndex].x + Math.max(1, Math.round(Math.random() * (_roomsA[roomIndex].width - 1)))) * 20;
				y = (_roomsA[roomIndex].y + Math.max(1, Math.round(Math.random() * (_roomsA[roomIndex].height - 1)))) * 20;
				item.x = x;
				item.y = y;
			}
		}
		
		public function createItems():void {
			// generate items for the level and handle drawing them as well
			for (var i:uint = 0; i < 10; i++) {
				var itemGen:uint = Math.round(Math.random() * 3);
				var callback:Function = ITEM_GEN[itemGen];
				callback();
			}
			// now draw the items from ITEMS array
			//ITEMS.forEach(drawItem);
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
		
		// create collision grid from nodemap objects
		private function drawGrid():void {
			//trace("nodemap size: " + _nodemap.length);
			for each (var node:Node in _nodemap._nodes) {
				_grid.setRect(node.x, node.y, 1, 1, node.solid);
			}
		}

		// find a random, non-trapped, non-monstered, non-stair position in 1st room
		private function placePlayer():void {
			var startingX:uint = 0;
			var startingY:uint = 0;
			var i:uint = 0;
			
			while ((_nodemap._nodes[(startingY * Dungeon.TILESX) + startingX].solid) && (i < 10)) {
				startingX = (Math.round(Math.random() * _roomsA[0].width)) + _roomsA[0].x;
				startingY = (Math.round(Math.random() * _roomsA[0].height)) + _roomsA[0].y;
				trace("plr plc:" + startingX + "-" + startingY);
				i++;
			}
			// TODO: now we have a non-wall (pillar, statue) location in room, check for
			// other obstructions
			Dungeon.player.setPlayerStartingPosition(startingX, startingY);
		}

		private function createAndPlaceNPCs():void {
			// TODO:
			// need a way to determine random number of NPCs
			// need a way to adjust their level (+/-1 of actual dungeon maybe?)
			// need a way to draw from pool of possible NPCs, level appropriate
			// NPCs should have level ranges just like weapons/armor
			var x:uint = 0;
			var y:uint = 0;
			var roomIndex:uint = 0;
			
			for (var j:int = 0; j < 10; j++) {
				var newNPC:NPC = new NPC();
				newNPC.NPCType = MONSTARS.pop();
				NPCS.push(newNPC);
			}
			
			for each (var npc:* in NPCS) {
				roomIndex = Math.max(0, (Math.round(Math.random() * _roomsA.length) - 1));
				x = (_roomsA[roomIndex].x + Math.max(1, Math.round(Math.random() * (_roomsA[roomIndex].width - 1)))) * 20;
				y = (_roomsA[roomIndex].y + Math.max(1, Math.round(Math.random() * (_roomsA[roomIndex].height - 1)))) * 20;
				npc.x = x;
				npc.y = y;
				
			}			
		}
		
		override public function update():void {
			// synchronize updates with player turn
			// handle things like open doors, triggered traps, dried up fountains, etc.
			if (_step != Dungeon.player.STEP) {
				//FP.watch(_roomsA.length);
				_nodemap.update();
				_step = Dungeon.player.STEP;
			}
			if (Input.pressed("DownLevel")) {
				// TODO: this needs a level saving and clearing routine
				_roomsA = [];
				_rooms = 0;
				drawLevel();
			}
		}
	}
}