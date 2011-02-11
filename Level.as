package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
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
		private var _tiles:Tilemap;
		private var _grid:Grid;
		public var _step:int = 0;
		
		public function Level() 
		{
			// init level tilemap and collision grid mask
			_tiles = new Tilemap(TILEMAP, 800,600,20,20);
			drawLevel();			
			graphic = _tiles;
			layer = 2;
			
			_grid = new Grid(800,600,20,20,0,0);
			drawGrid();
			mask = _grid;

			type = "level";
		}

		private function drawLevel():void {
			_tiles.setRect(0,0,800/20,600/20,3); // background
			_tiles.setRect(10,10,1,10,2); // stone wall
		}
		
		private function drawGrid():void {
			_grid.setRect(10,10,1,20,true);			
		}

		override public function update():void {
			// synchronize updates with player turn
			// handle things like open doors, triggered traps, dried up fountains, etc.
			if (_step != Dungeon.player.STEP) {
				
			}
		}
		
	}

}