package dungeon.structure 
{
	import net.flashpunk.Entity;
	import dungeon.structure.Node;
	import dungeon.structure.Nodemap;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.utils.Input;
	import dungeon.contents.NPC;
	import dungeon.utilities.GC;

	/**
	 * Noncollidable clutter entities. Bloodsplatters, plant growth, other FX PC or NPCs make.
	 * Scratches on walls? scorching? spilling other liquids? I dunno, but it's exciting to think about!
	 * @author ...
	 */
	public class Decor extends Entity
	{
		[Embed(source = '/assets/bloodsplatter.png')] private const BLOODSPLATTER:Class;
		public var _decor:Tilemap;
		
		public function Decor() 
		{
			_decor = new Tilemap(BLOODSPLATTER, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
			
			graphic = _decor;
			
			layer = GC.DECOR_LAYER;
		}
		
		// I wonder if we could make this a listener function instead of having to call it
		/**
		 * 
		 * @param	splatterPoint splatter coordinate
		 * @param	crit true = large splatter, false = small splatter
		 */
		public function splatter(splatterPoint:Point, crit:Boolean):void {
			if (crit) {
				_decor.setRect(splatterPoint.x, splatterPoint.y, 1, 1, 0);
			}
			// add "else" when we get real art for these
		}


		override public function update():void
		{
			// listen for hit "event" somehow, then fire splatter
		}
		
	}

}