package dungeon.contents 
{
	import net.flashpunk.graphics.*;
	import dungeon.utilities.GC;
	/**
	 * ...
	 * @author MM
	 */
	public class Armor extends Item 
	{
		[Embed(source = '../../assets/armor.png')] private const ARMOR:Class;

		// armor class and type (leather, chain, plate, other)
		public var CLASS:uint;
		public const MATERIALS:Array = ["Cloth", "Leather", "Bone", "Iron", "Copper", "Steel"];
		public const TYPE:Array = ["Leather", "Studded Leather", "Chain", "Scale", "Banded", "Splint", "Plate"];
		public const SLOTS:Array = [GC.SLOT_SHOULDERS, GC.SLOT_HEAD, GC.SLOT_CHEST, GC.SLOT_HANDS, GC.SLOT_LEGS, GC.SLOT_FEET, GC.SLOT_WAIST];
		// not sure how to determine if a "special" is selected
		public const SPECIALS:Array = ["Cloak", "Shield"];
		
		public const TILE_INDEX:uint = 0;
		
		public var armorMaterial:String;
		public var armorType:String;
		
		// combat vars
		public var defense:uint = 0;
		public var attack:uint = 0;
		public var crit:Number = 0;
		public var strengthReq:uint = 0;
		
		public function Armor() 
		{
			var randSlot:uint = Math.round(Math.random() * (SLOTS.length-1));
			var randMat:uint = Math.round(Math.random() * (MATERIALS.length-1));
			var randType:uint = Math.round(Math.random() * (TYPE.length-1));
			var randSpecial:uint = Math.round(Math.random() * (SPECIALS.length-1));

			slot = SLOTS[randSlot];
			
			// armor post processing to remove silliness
			// if it's cloth or leather it shouldn't have a type
			// cloaks and shields are special types to be more fleshed out later
			if (slot == GC.SLOT_SPECIAL) {
				slot = SPECIALS[randSpecial];
				armorMaterial = "";
				armorType = "";
			} else {
				armorMaterial = MATERIALS[randMat] + " ";
				if ((armorMaterial == "Cloth ") || (armorMaterial == "Leather ") || (armorMaterial == "Bone ")) {
					armorType = "";
				} else {
					armorType = TYPE[randType] + " ";
				}
			}
						
			super();

			// set which tile this weapon is, based on type probably
			// this will be used for overlaying the player character to show equipment
			// at the moment defaulting to 0
			tileIndex = TILE_INDEX;
			DESCRIPTION = armorMaterial + " " + armorType + " " + GC.SLOT_DESCRIPTIONS[slot];
			ITEM_TYPE = GC.C_ITEM_ARMOR;
			
			graphic = new Image(ARMOR);
		}

		public function copy():Armor {
			var newArmor:Armor = new Armor();
			
			newArmor.graphic = graphic;
			newArmor.x = x;
			newArmor.y = y;
			newArmor.DESCRIPTION = DESCRIPTION;
			newArmor.TRUE_DESCRIPTION = TRUE_DESCRIPTION;
			newArmor.ITEM_TYPE = ITEM_TYPE;
			newArmor.ITEM_LEVEL = ITEM_LEVEL;
			newArmor.rating = rating;
			newArmor.UNIQID = UNIQID;
			newArmor.slot = slot;
			
			newArmor.defense = defense;
			newArmor.attack = TILE_INDEX;
			newArmor.crit = crit;
			newArmor.strengthReq = strengthReq;
			newArmor.armorMaterial = armorMaterial;
			newArmor.armorType = armorType;
			return newArmor;
		}
	}

}