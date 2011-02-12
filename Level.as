package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.FP;

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
		private var _dungeonmap:Tilemap;
		private var _grid:Grid;

		private var _rooms:int = 0;
		private var _roomsMax:int = 5;
		private var _roomsA:Array = [];
		
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
			 * - not necessarily square rooms
			 * - dead ends are allowed but not too many
			 * - 
			 */
			// 1. Need a room

			
			for (var i:int = 0; i < _roomsMax; i++) {
				var x:int = Math.round(Math.random() * Dungeon.TILESX);
				var y:int = Math.round(Math.random() * Dungeon.TILESY);
				var width:int = Math.round(Math.random() * 15 + 3);
				var height:int = Math.round(Math.random() * 15 + 3);
				drawRoom(x,y,width,height);
				trace(x + "|" + y + "|" + i);
			}
		}
		
		private function drawRoom(x:int,y:int,width:int,height:int):void {
			// sooooo for this we need a starting point and an ending point
			// and they must not intersect any other such arrangement on the map
			// we should also have room size maximums and minimums
			// let's say minimum is 3, maximum is 20
			
			var success:Boolean = true;

			// check bounds			
			if (x + width > Dungeon.TILESX) {
				width = Dungeon.TILESX - (x + 2);
			}
			if (y + height > Dungeon.TILESY) {
				height = Dungeon.TILESY - (y + 2);
			}
			
			//  now it is possible we have a 0 width/height room			
			if ( (width <= 0) || (height <= 0) ) {
				success = false;
			}
			
			// TODO: check other rooms; iterate through their coords and ensure we have no collisions
			for (var i:int = 0; i < _roomsA.length; i++) {
				if (roomCollision(i, x, y, width, height)) {
					success = false;
				}
			}
			
			
			// top wall
			if (success) {
				_dungeonmap.setRect(x,y,width+2,1,2);
				// bottom wall
				_dungeonmap.setRect(x,y+height+1,width+2,1,2);
				// left wall
				_dungeonmap.setRect(x,y,1,height+2,2);
				// right wall
				_dungeonmap.setRect(x+width+1,y,1,height+2,2);
				
				var roomA:Array = [x,y,width,height];
				_roomsA.push(roomA);
				FP.log(x + "|" + y + "|" + width + "|" + height + "|" + _roomsA.length);
			} else {
				FP.log("fail");
			}
		}
		
		private function roomCollision(i, x, y, width, height) {
			
		}
		
		private function drawHallway():void {
			
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