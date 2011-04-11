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
		
		public function DataLoader() 
		{
			
		}

		public function setupItems():Array
		{
			var itemDataByteArray:ByteArray = new itemData;
			var itemDataXML:XML = new XML(itemDataByteArray.readUTFBytes(itemDataByteArray.length));
			var i:XML;
			var items:Array = new Array();
			var weapons:Array = new Array();
			var armors:Array = new Array();
			var consumables:Array = new Array();

			for each (i in itemDataXML.items.weapons.weapon)
			{
				var weapon:Weapon = new Weapon();
				weapon.name = i.@name;
				weapon.damageType = i.damagetype;
				weapon.attackType = i.attacktype;
				weapon.damageRating = i.damagerating;

				if (i.twohanded == "true") weapon.twoHanded = true;
				else weapon.twoHanded = false;

				weapons.push(weapon);
			}
			
			items.push(weapons);
		
		}

}