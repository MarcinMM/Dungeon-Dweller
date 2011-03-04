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
		public const TYPE:Array = ["Leather", "Chain", "Plate", "Scale"];
		public const MATERIALS:Array = ["Hide", "Iron", "Copper", "Steel", "Bone", "Wood"];
		public const SLOTS:Array = ["Legs", "Head", "Chest", "Hands", "Arms", "Cloak", "Feet"];
		
		
		public function Armor() 
		{
			
			super();
			
		}
		
	}

}