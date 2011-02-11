package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	/**
	 * ...
	 * @author MM
	 * Tile 0: brown stone
	 * Tile 1: green stone
	 */
	public class Level extends Entity
	{
		[Embed(source = 'assets/tilemap.png')] private const TILEMAP:Class;
		private var _tiles:Tilemap;
		private var _grid:Grid;
		public var _step:int = 0;
		
		public function Level() 
		{
			_tiles = new Tilemap(TILEMAP, 800,600,20,20);
			graphic = _tiles;
			layer = 1;
			
			_tiles.setRect(0,0,800/20,600/20,1); // background
			_tiles.setRect(10,10,1,10,0); // stone wall
			
			_grid = new Grid(800,600,20,20,0,0); // stone wall collision grid
			mask = _grid;
			
			_grid.setRect(10,10,1,20,true);
			
			type = "level";
		}

		override public function update():void {
			// synchronize updates with player turn
			// draw a tile under the player
			if (_step != MyWorld.player.STEP) {
				_tiles.setTile(MyWorld.player.x/20, MyWorld.player.y/20, 0);
				_step = MyWorld.player.STEP;
			}
		}
		
	}

}