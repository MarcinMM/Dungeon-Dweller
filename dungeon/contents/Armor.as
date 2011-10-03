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
		public const SLOTS:Array = [GC.SLOT_HEAD, GC.SLOT_BODY, GC.SLOT_SPECIAL];
		
		public const TILE_INDEX:uint = 0;
		
		public var armorMaterial:String;
		public var armorType:String;
		
		// combat vars
		public var defense:uint = 0;
		public var attack:uint = 0;
		public var crit:Number = 0;
		public var strengthReq:uint = 0;
		
		public function Armor(setGraphic:Boolean = true) 
		{
			var randArmor:uint = Math.round(Math.random() * (Dungeon.dataloader.armors.length - 1));
			var armorXML:XML = Dungeon.dataloader.armors[randArmor];
			
			// TODO: code for evolved weapon generation here
			// addArmorEnhancement(true);
			
			super();

			// set which tile this weapon is, based on type probably
			// this will be used for overlaying the player character to show equipment
			// at the moment defaulting to 0
			tileIndex = TILE_INDEX;
			DESCRIPTION = armorXML.@name;
			ITEM_TYPE = GC.C_ITEM_ARMOR;
			
			if (setGraphic) {
				if (GC.ARMOR_TILES[armorXML.type] == undefined) {
					_armors.add("static", [69], 0, false);
				} else {
					_armors.add("static", [GC.ARMOR_TILES[armorXML.type]], 0, false);
				}
				//_assets.add("anim", [6, 7, 8, 9, 10, 11], 0, false); // animations!
				graphic = _armors;	
				_armors.play("static");
			}
		}

		// stub for enhancements
		// the function call will also be used for adding armor enhancements during play
		public function addArmorEnhancement(init:Boolean=false, type:String=''):void {}
		
		public function selfCopy():Armor {
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
			newArmor.invLetter = invLetter;
			
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