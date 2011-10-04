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
	 * Noncollidable clutter entities. Bloodadds, plant growth, other FX PC or NPCs make.
	 * Scratches on walls? scorching? spilling other liquids? I dunno, but it's exciting to think about!
	 * @author ...
	 */
	public class Decor extends Entity
	{
		// TODO: this needs to be a spritemap of adds
		public var _decor:DecorGraphic;
		
		public function Decor() 
		{
			_decor = new DecorGraphic();
			
			graphic = _decor;
			
			layer = GC.DECOR_LAYER;
		}
		
		public function resetDecor():void {
			_decor.resetDecorGraphic();
		}
		
		public function selfCopy():Decor {
			var copy:Decor = new Decor();
			copy._decor = _decor.selfCopy();
			copy.graphic = copy._decor;
			return copy;
		}
		
		// TODO: I wonder if we could make this a listener function instead of having to call it
		// TODO: figure out how I can turn tiles solid on a one-off basis here somehow
		/**
		 * 
		 * @param	addPoint add coordinate
		 * @param	crit true = large add, false = small add
		 */
		public function addDecor(x:uint, y:uint, material:uint, crit:Boolean=false, solidity:Boolean=false):void {
			if (crit) {
				_decor.addGraphic(x / GC.GRIDSIZE, y / GC.GRIDSIZE, material, GC.SPLAT_OFFSET);
			} else {
				_decor.addGraphic(x / GC.GRIDSIZE, y / GC.GRIDSIZE, material, GC.SPLAT_OFFSET);
				addArea(x, y, 'SMALL', material);
			}
			// add "else" when we get real art for these
		}

		// This is a bigger splat with a potential area of effect. 
		// Size can come in SMALL, MEDIUM, LARGE
		// each size will have a 25, 50, 75% chance to add all sides, respectively
		// TODO: random add choice from material index
		/**
		 * 
		 * @param	addPoint add coordinate
		 * @param	crit true = large add, false = small add
		 */
		public function addArea(x:uint, y:uint, area:String, material:uint):void {
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
				_decor.addGraphic(x / GC.GRIDSIZE, (y / GC.GRIDSIZE) - 1, material, 5);
			}
			if (Math.random() < chance) {
				_decor.addGraphic(x / GC.GRIDSIZE, (y / GC.GRIDSIZE) + 1, material, 5); 
			}
			if (Math.random() < chance) {
				_decor.addGraphic((x / GC.GRIDSIZE) - 1, y / GC.GRIDSIZE, material, 5);
			}
			if (Math.random() < chance) {
				_decor.addGraphic((x / GC.GRIDSIZE) + 1, y / GC.GRIDSIZE, material, 5);
			}
		}

		override public function update():void
		{
			// TODO: listen for hit "event" somehow, then fire add
		}
		
	}

}