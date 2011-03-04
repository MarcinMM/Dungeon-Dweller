package dungeon.contents 
{
	/**
	 * ...
	 * @author MM
	 */
	public class Weapon extends Item 
	{
		public const MATERIAL:Array = ["Bone", "Wood", "Copper", "Iron", "Silver", "Mithril", "Steel"];
		
		public const TYPE:Array = ["H2SWORD", "H1SWORD", "CURVED", "BLUNT", "DAGGER", "POLEARM", "RANGED", "AXE"];
		public const H1SWORD:Array = ["Gladius", "Short sword", "Rapier", "Falchion", "Spatha"];
		public const H2SWORD:Array = ["Claymore", "Nodachi", "Flamberge"];
		public const CURVED:Array = ["Katana", "Saber", "Scimitar", "Falcata"];
		public const BLUNT:Array = ["Morning Star", "Mace", "Flail", "Club", "Warhammer", "Maul"];
		public const DAGGER:Array = ["Stiletto", "Kris", "Dagger", "Misericorde", "Katars", "Dirk", "Kukri", "Main-gauche"];
		public const POLEARM:Array = ["Spear", "Halberd", "Glaive", "Naginata", "Bardiche"];
		public const RANGED:Array = ["Bow", "Crossbow", "Sling", "Wand", "Throwing axe", "Throwing knife", "Shuriken"];
		public const AXE:Array = ["Axe", "Double-headed Axe", "Battleaxe", "Tomahawk"];
		
		public const SUBTYPE:Object = {
			H1SWORD: H1SWORD,
			H2SWORD: H2SWORD,
			CURVED: CURVED,
			BLUNT: BLUNT,
			DAGGER: DAGGER,
			POLEARM: POLEARM,
			RANGED: RANGED,
			AXE: AXE
		};
		
		// now vars
		public var weaponType:String;
		public var weaponSubtype:String;
		public var weaponMaterial:String;
		
		public function Weapon() 
		{
			var randType:uint = Math.round(Math.random() * (TYPE.length-1));
			weaponType = TYPE[randType];
			
			var randSubtype:uint = Math.round(Math.random() * (SUBTYPE[weaponType].length-1));
			weaponSubtype = SUBTYPE[weaponType][randSubtype];
			
			var randMat:uint = Math.round(Math.random() * (MATERIAL.length-1));
			weaponMaterial = MATERIAL[randMat];
			
			super();
			
		}
		
	}

}