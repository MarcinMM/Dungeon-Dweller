package dungeon.utilities 
{
	/**
	 * ...
	 * @author MM
	 */
	
	import flash.utils.ByteArray;

	public class DataLoader 
	{
	
		[Embed(source = "../../assets/scripts/item_data.xml", mimeType = "application/octet-stream")] private var itemData:Class;
		
		public var weapons:Array = new Array();
		public var materials:Array = new Array();
		
		public function DataLoader() 
		{
			
		}

		public function setupItems():void
		{
			var itemDataByteArray:ByteArray = new itemData;
			var itemDataXML:XML = new XML(itemDataByteArray.readUTFBytes(itemDataByteArray.length));
			var i:XML;
			var items:Array = new Array();
			var armors:Array = new Array();

			for each (i in itemDataXML.items.weapons.weapon)
			{
				var weapon:WeaponPrototype = new WeaponPrototype();
				weapon.name = i.@name;
				weapon.attack = i.attack;
				weapon.defense = i.defense;
				weapon.pen = i.pen;
				weapon.hands = i.hands;
				weapon.offhand = i.offhand;
				weapon.offhandRating = i.offhandRating;
				weapon.crit = i.crit;
				weapon.strengthReq = i.strengthReq;

				weapons.push(weapon);
			}

			for each (i in itemDataXML.items.materials.material)
			{
				var material:MaterialPrototype = new MaterialPrototype();
				material.name = i.@name;
				material.modifier = i.modifier;
				material.rarity = i.rarity;
				material.upperRarityThreshold = i.upperRarityThreshold;
				material.upperRarityIncrement = i.upperRarityIncrement;
				material.lowerRarityThreshold = i.lowerRarityThreshold;
				material.lowerRarityIncrement = i.lowerRarityIncrement;
				material.shatter = i.shatter;
				material.burn = i.burn;
				material.rust = i.rust;
				material.specialAgainst = i.specialAgainst;
				material.specialModifier = i.specialModifier;

				materials.push(material);
			}
			
			items.push(weapons);
			items.push(materials);
		}
	}
}