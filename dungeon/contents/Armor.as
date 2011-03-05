package dungeon.contents 
{
	/**
	 * ...
	 * @author MM
	 */
	public class Armor extends Item 
	{
		// armor class and type (leather, chain, plate, other)
		public var CLASS:uint;
		public const TYPE:Array = ["Leather", "Chain", "Plate", "Scale", "Splint", "Banded", "Studded Leather"];
		public const MATERIALS:Array = ["Hide", "Iron", "Copper", "Steel", "Bone", "Wood"];
		public const SLOTS:Array = ["Legs", "Head", "Chest", "Hands", "Arms", "Cloak", "Feet"];
		
		public const TILE_INDEX:uint = 0;
		
		public var armorMaterial:String;
		public var armorType:String;
		public var armorSlot:String;
		
		public function Armor() 
		{
			var randSlot:uint = Math.round(Math.random() * (SLOTS.length-1));
			var randMat:uint = Math.round(Math.random() * (MATERIALS.length-1));
			var randType:uint = Math.round(Math.random() * (TYPE.length-1));
			
			armorMaterial = MATERIALS[randMat];
			armorType = TYPE[randType];
			armorSlot = SLOTS[randSlot];
			
			super();

			// set which tile this weapon is, based on type probably
			// at the moment defaulting to 0
			tileIndex = TILE_INDEX;
			DESCRIPTION = armorMaterial + " " + armorType + " " + armorSlot;
			
		}
		
	}

}