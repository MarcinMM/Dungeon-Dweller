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
		[Embed(source = "../../assets/scripts/npc_data.xml", mimeType = "application/octet-stream")] private var npcData:Class;
		[Embed(source = "../../assets/scripts/pc_data.xml", mimeType = "application/octet-stream")] private var pcData:Class;

		public var weapons:Array = new Array();
		public var armors:Array = new Array();
		public var materials:Array = new Array();
		public var potions:Array = new Array();
		public var npcs:Array = new Array();
		public var pcs:Array = new Array();
		
		public var npcDataXML:XML;
		
		public function DataLoader() 
		{
			
		}

		public function retrieveLevelCreatureList(level:int):Array {
			var availableCreatures:XML = npcDataXML.npc.(startsToAppearAt <= level && doesNotAppearPast >= level);
			var creatureChance:Object = new Object;
			var creatureChances:Array;
			var chance:Number;
			var chanceSum:Number = 0;
			var creaturesRolled:int = Math.round(Math.random() * 10);

			for each (var i:XML in availableCreatures) {
				var startIncrement:Number = (level - i.startsToAppearAt) * i.startAppearanceIncrement;
				if (startIncrement > 100) startIncrement = 100;
				if (level >= i.endsAppearingAt) {
					var endIncrement:Number = 100 - (Math.abs(i.endsAppearingAt - level) * i.endAppearanceIncrement);
				} else {
					endIncrement = 0;
				}
				if (endIncrement < 0) endIncrement = 0;
				
				chance = (startIncrement - endIncrement) * i.rarityModifier;
				chanceSum += chance;
				creatureChance = { creature: i.@name, chance: chance };
				creatureChances.push(creatureChance);
			}
			
			for each (var j:Object in creatureChances) {
				j.chance = Math.round((j.chance / chanceSum) * creaturesRolled);
			}
			
			return creatureChances;
		}
		
		public function setupItems():void {
			var itemDataByteArray:ByteArray = new itemData;
			var npcDataByteArray:ByteArray = new npcData;
			var pcDataByteArray:ByteArray = new pcData;
			var itemDataXML:XML = new XML(itemDataByteArray.readUTFBytes(itemDataByteArray.length));
			npcDataXML = new XML(npcDataByteArray.readUTFBytes(npcDataByteArray.length));
			var pcDataXML:XML = new XML(pcDataByteArray.readUTFBytes(pcDataByteArray.length));

			var i:XML;
			// Switching over to using XML objects in arrays, but still maintaing arrays for readability and random access
			//var items:Array = new Array();

			for each (i in itemDataXML.items.weapons.weapon)
			{
				weapons.push(i);
			}

			for each (i in itemDataXML.items.armors.armor)
			{
				armors.push(i);
			}

			for each (i in itemDataXML.items.materials.material)
			{
				materials.push(i);
			}
			
			for each (i in itemDataXML.items.potions.potion)
			{
				potions.push(i);
			}
			
			for each (i in npcDataXML.npcs.npc)
			{
				npcs.push(i);
			}
			
			for each (i in pcDataXML.pcs.pc)
			{
				pcs.push(i);
			}
		}
	}
}