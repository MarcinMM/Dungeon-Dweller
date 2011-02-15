package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.FP;
	import dungeon.components.Room;

	/**
	 * ...
	 * @author MM
	 * Tile 0: alpha (future)
	 * Tile 1: the void (future)
	 * Tile 2: brown stone
	 * Tile 3: green stone
	 */
	public class Level extends Entity
	{
		[Embed(source = 'assets/tilemap.png')] private const TILEMAP:Class;
		public var _dungeonmap:Tilemap;
		public var _grid:Grid;

		private var _rooms:int = 0;
		private var _roomsMax:int = 10;
		private var _roomsBigChange:int = 2; // 20% chance, 2 out of 10
		private var _roomsBigMax:int = 2;
		private var _roomLimitMax:int = 15;
		private var _roomLimitNormal:int = 8;
		public var _roomsA:Array = [];
		
		public var _step:int = 0;
		
		public function Level() 
		{
			FP.console.enable();
			// init level tilemap and collision grid mask
			_dungeonmap = new Tilemap(TILEMAP, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
			drawLevel();			
			graphic = _dungeonmap;
			layer = 2;
			
			_grid = new Grid(Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT,0,0);
			drawGrid();
			mask = _grid;

			type = "level";
			
			//_roomsMax = Math.round(Math.random() * 15) + 6; // this should give us a room number between 6 and 15
			//if (_roomsMax > 15) _roomsMax = 15;
			FP.log('rmax: ' + _roomsMax);
		}

		private function drawLevel():void {
			_dungeonmap.setRect(0,0,Dungeon.TILESX, Dungeon.TILESY, 3); // background, 800x600 screen = 40x30 tiles, seems small?
			
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
			// 1. Need a room!
			// Let's say a 20% chance generating a big room, with a max of 2

			var _bigRoomCount:int = 0;			
			var width:int = 0;
			var height:int = 0;
			var _bigRoomRand:int = 0;
			var x:int = 0;
			var y:int = 0;
			
			for (var i:int = 0; i < _roomsMax; i++) {
				_bigRoomRand = Math.round(Math.random() * 10);
				if ((_bigRoomRand < 2) && (_bigRoomCount < 2)) {
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
		
		private function drawHallway(room1:int, room2:int):void {
			
		}
		
		private function drawGrid():void {
			_grid.setRect(10,10,1,20,true);			
		}

		override public function update():void {
			// synchronize updates with player turn
			// handle things like open doors, triggered traps, dried up fountains, etc.
			if (_step != Dungeon.player.STEP) {
				FP.watch(_roomsA.length);
			}
		}
		
	}

}