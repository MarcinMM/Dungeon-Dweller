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

			// TODO: stub for combat signal listener to add visual FX
			// TODO: consider a third var for splatter type, maybe each creature should have a splatter type? blood/chlorophyll/dust for undeads/elemental chunks from elementals?
			Dungeon.onCombat.add(function(x:int, y:int, combatType:String, dmgType:int):void {
			    // dispatch visual events based on type of deformation happening
			    switch(combatType) {
			    	case 'PHYSICAL':
			    		// blood spatters
			    		addDecor(x, y, dmgType, GC.SPLAT_OFFSET);
			    		break;
			    	case 'ICE':
			    		// impassable icicles form
			    		break;
			    	case 'FIRE':
			    		// fire breaks out (does damage)
			    		break;
			    	case 'DIG':
			    		// holes in terrain
			    		break;
			    }
			});
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
		
		// TODO: the one-off solidity seems like it might not work; I have a feeling it'll get overriden somehow (so watch this space and Nodemap's initSolidity)
		public function addDecor(x:uint, y:uint, material:uint, offset:uint, crit:Boolean=false, solidity:Boolean=false):void {
			if (!crit) {
				_decor.addGraphic(x / GC.GRIDSIZE, y / GC.GRIDSIZE, material, offset);
			} else {
				_decor.addGraphic(x / GC.GRIDSIZE, y / GC.GRIDSIZE, material, offset);
				addArea(x, y, 'SMALL', material);
			}
			// this needs to be deferred so that it's only calculated after all the solidity updates are done
			// how to do this?
			if (solidity) {
				// this only sets a solid tile in a give location; the graphic is still within decor
				Dungeon.level._grid.setRect(x / GC.GRIDSIZE, y / GC.GRIDSIZE, 1, 1, true);
				var node:Node = Dungeon.level._nodemap.getNode(x, y);
				node.solidOverride = true;
				Dungeon.level._nodemap.reload();
			}
			// add "else" when we get real art for these
		}

		// This is a bigger splat with a potential area of effect. 
		// Size can come in SMALL, MEDIUM, LARGE
		// each size will have a 10, 35, 55% chance to add all sides, respectively
		// TODO: random add choice from material index
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