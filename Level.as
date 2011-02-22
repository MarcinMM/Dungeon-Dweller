package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.utils.Draw;	
	import dungeon.components.Room;
	import dungeon.components.Door;
	import dungeon.components.Point;
	import dungeon.components.Utils;
	import dungeon.components.Node;
	import dungeon.components.Nodemap;

	/**
	 * ...
	 * @author MM
	 */
	public class Level extends Entity
	{
		[Embed(source = 'assets/tilemap.png')] private const TILEMAP:Class;
		public var _dungeonmap:Tilemap;
		public var _grid:Grid;
		public var _nodemap:Nodemap;

		private const _roomsMax:int = 20;
		private const _roomsBigChance:int = 2; // 20% chance, 2 out of 10
		private const _roomsBigMax:int = 2;
		private const _roomLimitMax:int = 11;
		private const _roomLimitNormal:int = 6;
		Input.define("DownLevel", Key.L);

		public var _roomsA:Array = [];
		private var _rooms:int = 0;

        public static const FLOOR:int = 7;
        public static const NWALL:int = 8;
        public static const SWALL:int = 10;
        public static const WWALL:int = 11;
        public static const EWALL:int = 9;
        public static const DOOR:int = 1;
		public static const DEBUG:int = 2;
		
		public static const DEBUGR:int = 5;
		public static const DEBUGG:int = 6;
		
		public var _step:int = 0;
		
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
			
			//_roomsMax = Math.round(Math.random() * 15) + 6; // this should give us a room number between 6 and 15
			//if (_roomsMax > 15) _roomsMax = 15;
		}
		
		private function drawLevel():void {
			_dungeonmap = new Tilemap(TILEMAP, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
			_dungeonmap.setRect(0,0,Dungeon.TILESX, Dungeon.TILESY, DEBUG); 
			graphic = _dungeonmap;
			layer = 2;
			
			_grid = new Grid(Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT,0,0);
			drawGrid();
			mask = _grid;
			type = "level";
			
			drawRooms();
			_nodemap = new Nodemap(_dungeonmap, _roomsA);
			_nodemap.drawHallways();
		}
		
		private function drawRooms():void {
			var _bigRoomCount:int = 0;
			var width:int = 0;
			var height:int = 0;
			var _bigRoomRand:int = 0;
			var x:int = 0;
			var y:int = 0;

// for debugging pathing we just want two rooms with one door each
//			for (var i:int = 0; i < _roomsMax; i++) {
			while (_rooms < 2) {
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
					FP.log('no room added');
				}
			}			
		}
		
		// alternate hallways to farthest/lowest NON-same-room doors
		
		private function drawGrid():void {
			_grid.setRect(10,10,1,20,true);			
		}

		override public function update():void {
			// synchronize updates with player turn
			// handle things like open doors, triggered traps, dried up fountains, etc.
			if (_step != Dungeon.player.STEP) {
				FP.watch(_roomsA.length);
			}
			if (Input.pressed("DownLevel")) {
				// TODO: this needs a level saving and clearing routine
				_roomsA = [];
				drawLevel();
			}
			
		}
		
	}

}