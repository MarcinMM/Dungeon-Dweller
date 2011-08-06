package dungeon.structure
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.FP;
	import dungeon.utilities.GC;

	/**
	 * ...
	 * @author MM
	 * Tile 0: the void
	 * Tile 1: green stone
	 * Tile 2: green stone
	 */
	public class LevelMask extends Entity
	{
		[Embed(source = 'assets/tilemap.png')] private const TILEMAP:Class;
		private var _levelmask:Tilemap;
		private var _step:int = 0;
		
		public function LevelMask() 
		{
			_levelmask = new Tilemap(TILEMAP, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.GRIDSIZE, Dungeon.GRIDSIZE);
			//_levelmask.setRect(0,0,GC.MAP_WIDTH/GC.GRIDSIZE,GC.MAP_HEIGHT/GC.GRIDSIZE,1); // black overlay
			graphic = _levelmask;
			layer = GC.FOGOFWAR_LAYER;

			type = "level";
		}
		
		private function revealLevel():void {
			// this will be called by update as player moves around
			// level will be redrawn based on occlusion and player's light source
			// redraw will be done with visible tiles vs. the "void" ones used initially
			// looks like there's a "visible" property on each tile, investigate that instead?
		}

		override public function update():void {
			// synchronize updates with player turn
			// draw a tile under the player
			if (_step != Dungeon.player.STEP) {
				FP.log("Preclear at player: " + _levelmask.getTile(Dungeon.player.x/Dungeon.GRIDSIZE,Dungeon.player.y/Dungeon.GRIDSIZE) + "|step:" + _step);
				_levelmask.setTile(Dungeon.player.x/Dungeon.GRIDSIZE, Dungeon.player.y/Dungeon.GRIDSIZE,0);
				for (var i:int = 0; i <= Dungeon.player.LIGHT_RADIUS; i++) {
					_levelmask.clearTile(Dungeon.player.x/Dungeon.GRIDSIZE + i, Dungeon.player.y/Dungeon.GRIDSIZE);
					_levelmask.clearTile(Dungeon.player.x/Dungeon.GRIDSIZE - i, Dungeon.player.y/Dungeon.GRIDSIZE);
					_levelmask.clearTile(Dungeon.player.x/Dungeon.GRIDSIZE, Dungeon.player.y/Dungeon.GRIDSIZE + i);
					_levelmask.clearTile(Dungeon.player.x/Dungeon.GRIDSIZE, Dungeon.player.y/Dungeon.GRIDSIZE - i);
				}
				_step = Dungeon.player.STEP;
				FP.log("Tile at player: " + _levelmask.getTile(Dungeon.player.x/Dungeon.GRIDSIZE,Dungeon.player.y/Dungeon.GRIDSIZE) + "|step:" + _step);
			}
		}
	}
}