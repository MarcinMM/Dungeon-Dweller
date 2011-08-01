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
			
			graphic = _overlay;
			
			layer = 30;
		}
		
		private function getTileNeighbors(x:uint, y:uint) {
			var tileX = x/GC.GRIDSIZE;
			var tileY = y/GC.GRIDSIZE;
			_overlay.setRect(tileX, tileY, 1, 1, GC.DEBUGRED);
			var nodeAt:Node = Dungeon.level._nodemap.getNodeTile(tileX, tileY);
			for each (var neighbor:Node in nodeAt.walkingNeighbors) {
				_overlay.setRect(neighbor.x, neighbor.y, 1, 1, GC.DEBUGGREEN);	
			}		
		}

		// this is totally untested
		private function getTileNPCInfo(x:uint, y:uint) {
			var tileX = x/GC.GRIDSIZE;
			var tileY = y/GC.GRIDSIZE;
			for each (var NPC:NPC in Dungeon.level.NPCS) {
				if (NPC.x == x && NPC.y == y) {
					Dungeon.statusScreen.updateCombatText(NPC.NPCType ", wielding a " + NPC.getEquippedItem(GC.C_ITEM_WEAPON, GC.PRIMARY_WEAPON));
				}
			}
			
		}


		override public function update():void
		{
			// mouse monitoring
			if (Input.mousePressed) {
				var mouseX = Input.mouseFlashX;
				var mouseY = Input.mouseFlashY;
				Dungeon.statusScreen.updateCombatText("Mouse clicky at: " + (mouseX/GC.GRIDSIZE) + "|" + (mouseY/GC.GRIDSIZE));
				this.getTileNeighbors(mouseX, mouseY);
				this.getTileNPCInfo(mouseX, mouseY);
			}
		}
		
	}

}