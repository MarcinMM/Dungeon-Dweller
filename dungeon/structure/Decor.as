package dungeon.structure 
{
	import net.flashpunk.Entity;
	import dungeon.structure.Node;
	import dungeon.structure.Nodemap;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.utils.Input;
	import dungeon.contents.NPC;
	import dungeon.utilities.GC;
	import dungeon.utilities.DecorGraphic;

	/**
	 * Noncollidable clutter entities. Bloodsplatters, plant growth, other FX PC or NPCs make.
	 * Scratches on walls? scorching? spilling other liquids? I dunno, but it's exciting to think about!
	 * @author ...
	 */
	public class Decor extends Entity
	{
		// TODO: this needs to be a spritemap of splatters
		public var _decor:DecorGraphic;
		
		public function Decor() 
		{
			_decor = new DecorGraphic();
			//_decor = new Tilemap(BLOODSPLATTER, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
			
			graphic = _decor;
			
			layer = GC.DECOR_LAYER;
		}
		
		// TODO: I wonder if we could make this a listener function instead of having to call it
		/**
		 * 
		 * @param	splatterPoint splatter coordinate
		 * @param	crit true = large splatter, false = small splatter
		 */
		public function splatter(x:uint, y:uint, crit:Boolean, material:uint):void {
			if (crit) {
				_decor.addDecor(x / GC.GRIDSIZE, y / GC.GRIDSIZE, material, 5);
			} else {
				_decor.addDecor(x / GC.GRIDSIZE, y / GC.GRIDSIZE, material, 5);
				splatterArea(x, y, 'SMALL', material);
			}
			// add "else" when we get real art for these
		}

		// This is a bigger splat with a potential area of effect. 
		// Size can come in SMALL, MEDIUM, LARGE
		// each size will have a 25, 50, 75% chance to splatter all sides, respectively
		// TODO: random splatter choice from material index
		/**
		 * 
		 * @param	splatterPoint splatter coordinate
		 * @param	crit true = large splatter, false = small splatter
		 */
		public function splatterArea(x:uint, y:uint, area:String, material:uint):void {
			var chance:Number;
			switch (area) {
				case 'SMALL':
					chance = 0.10;
					break;
				case 'MEDIUM':
					chance = 0.35;
					break;
				case 'LARGE':
					chance = 0.55;
					break;
			}
			// up down left right
			if (Math.random() < chance) {
				_decor.addDecor(x / GC.GRIDSIZE, (y / GC.GRIDSIZE) - 1, material, 5);
			}
			if (Math.random() < chance) {
				_decor.addDecor(x / GC.GRIDSIZE, (y / GC.GRIDSIZE) + 1, material, 5); 
			}
			if (Math.random() < chance) {
				_decor.addDecor((x / GC.GRIDSIZE) - 1, y / GC.GRIDSIZE, material, 5);
			}
			if (Math.random() < chance) {
				_decor.addDecor((x / GC.GRIDSIZE) + 1, y / GC.GRIDSIZE, material, 5);
			}
		}

		override public function update():void
		{
			// TODO: listen for hit "event" somehow, then fire splatter
		}
		
	}

}