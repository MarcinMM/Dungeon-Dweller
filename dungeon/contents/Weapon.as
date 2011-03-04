package dungeon.contents 
{
	/**
	 * ...
	 * @author MM
	 */
	public class Weapon extends Item 
	{
		public const MATERIAL:Array = ["Bone", "Wood", "Copper", "Iron", "Silver", "Mithril", "Steel"];
		public const TYPE:Array = ["Two-handed sword", "Two-handed axe", "Axe", "Bastard sword", "Long sword", "Dagger", "Club", "Mace", "Flail", "Morning star", "Bow", "Crossbow", "Sling"];
		public const SWORDS:Array = ["Gladius", "Falcata", "Scimitar"];
	public const SUBTYPE:Object = {Swords: SWORDS};
		
		public function Weapon() 
		{
			super();
			
		}
		
	}

}