package dungeon.utilities 
{
	import dungeon.contents.Item;
	import net.flashpunk.Entity;
	import dungeon.structure.Node;
	import dungeon.structure.Nodemap;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.utils.Input;
	import dungeon.contents.NPC;
	import dungeon.utilities.GC;

	/**
	 * ...
	 * @author ...
	 */
	public class Overlay extends Entity
	{
		[Embed(source = '/assets/tilemap.png')] private const TILEMAP:Class;
		public var _overlay:Tilemap;
		
		public function Overlay() 
		{
			_overlay = new Tilemap(TILEMAP, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
			
			graphic = _overlay;
			
			layer = GC.OVERlAY_LAYER;
		}
		
		private function getTileNeighbors(x:uint, y:uint):void {
			var tileX:uint = Math.floor(x/GC.GRIDSIZE);
			var tileY:uint = Math.floor(y/GC.GRIDSIZE);
			_overlay.setRect(tileX, tileY, 1, 1, GC.DEBUGRED);
			var nodeAt:Node = Dungeon.level._nodemap.getNodeTile(tileX, tileY);
			for each (var neighbor:Node in nodeAt.walkingNeighbors) {
				_overlay.setRect(neighbor.x, neighbor.y, 1, 1, GC.DEBUGGREEN);	
			}		
		}

		private function getTileNPCInfo(x:uint, y:uint):void {
			var tileX:uint = Math.floor(x/GC.GRIDSIZE);
			var tileY:uint = Math.floor(y/GC.GRIDSIZE);
			for each (var critter:NPC in Dungeon.level.NPCS) {
				if (Math.floor(critter.x / GC.GRIDSIZE) == tileX && Math.floor(critter.y / GC.GRIDSIZE) == tileY) {
					var equipment:resultItem = critter.getEquippedItem(GC.C_ITEM_WEAPON, GC.SLOT_PRIMARY_WEAPON);
					if (equipment.found) {
						Dungeon.statusScreen.updateCombatText(critter.npcType + "[" + critter.STATS[GC.STATUS_HP] + "/" + critter.STATS[GC.STATUS_HPMAX] + "], wielding a " + equipment.item.DESCRIPTION);
					} else {
						Dungeon.statusScreen.updateCombatText(critter.npcType + "[" + critter.STATS[GC.STATUS_HP] + "/" + critter.STATS[GC.STATUS_HPMAX] + "]. It is unarmed.");
					}
					
				}
			}
		}

		private function getTileItemInfo(x:uint, y:uint):void {
			var tileX:uint = Math.floor(x/GC.GRIDSIZE);
			var tileY:uint = Math.floor(y/GC.GRIDSIZE);
			for each (var item:Item in Dungeon.level.ITEMS) {
				if (Math.floor(item.x / GC.GRIDSIZE) == tileX && Math.floor(item.y / GC.GRIDSIZE) == tileY) {
					Dungeon.statusScreen.updateCombatText("A " + item.DESCRIPTION + ".");
				}
			}			
		}
		
		override public function update():void
		{
			// mouse monitoring
			if (Input.mousePressed) {
				var mouseX:int = Input.mouseFlashX;
				var mouseY:int = Input.mouseFlashY;
				//Dungeon.statusScreen.updateCombatText("Mouse clicky at: " + (mouseX/GC.GRIDSIZE) + "|" + (mouseY/GC.GRIDSIZE));
				//this.getTileNeighbors(mouseX, mouseY);
				this.getTileNPCInfo(mouseX, mouseY);
				this.getTileItemInfo(mouseX, mouseY);
			}
		}
		
	}

}