package dungeon.utilities 
{
	import net.flashpunk.Entity;
	import dungeon.structure.Node;
	import dungeon.structure.Nodemap;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.utils.Input;

	/**
	 * ...
	 * @author ...
	 */
	public class Overlay extends Entity
	{
		[Embed(source = '/assets/tilemap.png')] private const TILEMAP:Class;
		public var _overlay:Tilemap;
		public static const DEBUGR:int = 5;
		public static const DEBUGG:int = 6;
		
		public function Overlay() 
		{
			_overlay = new Tilemap(TILEMAP, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
			//_overlay.setRect(0,0,Dungeon.TILESX, Dungeon.TILESY, DEBUG); 
			
			graphic = _overlay;
			
			layer = 30;
		}
		
		override public function update():void
		{
			// mouse monitoring
			if (Input.mousePressed) {
				var tileX:uint = Math.floor(Input.mouseFlashX / GC.GRIDSIZE);
				var tileY:uint = Math.floor(Input.mouseFlashY / GC.GRIDSIZE);
				Dungeon.statusScreen.updateCombatText("Mouse clicky at: " + tileX + "|" + tileY);
				
				_overlay.setRect(tileX, tileY, 1, 1, 5);
				var nodeAt:Node = Dungeon.level._nodemap.getNodeTile(tileX, tileY);
				for each (var neighbor:Node in nodeAt.walkingNeighbors) {
					_overlay.setRect(neighbor.x, neighbor.y, 1, 1, 6);	
				}
			}
		}
		
	}

}