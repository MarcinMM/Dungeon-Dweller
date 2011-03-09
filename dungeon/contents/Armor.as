package dungeon.contents 
{
	import net.flashpunk.graphics.*;
	/**
	 * ...
	 * @author MM
	 */
	public class Armor extends Item 
	{
		[Embed(source = '../../assets/armor.png')] private const ARMOR:Class;

		// armor class and type (leather, chain, plate, other)
		public var CLASS:uint;
		public const TYPE:Array = ["Leather", "Chain", "Plate", "Scale", "Splint", "Banded", "Studded Leather"];
		public const MATERIALS:Array = ["Hide", "Iron", "Copper", "Steel", "Bone", "Wood"];
		public const SLOTS:Array = ["Greaves", "Helm", "Chestpiece", "Gloves", "Cloak", "Boots"];
		
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
			
			graphic = new Image(ARMOR);
		}
		
	}

}