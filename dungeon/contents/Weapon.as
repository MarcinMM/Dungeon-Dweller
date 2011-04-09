package dungeon.contents 
{
	import dungeon.structure.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.*;
	import dungeon.utilities.GC;

	/**
	 * ...
	 * @author MM
	 */
	public class Weapon extends Item 
	{
		[Embed(source = '../../assets/weapon.png')] private const WEAPON:Class;
		
		public const MATERIAL:Array = ["Bone", "Wood", "Obsidian-laced", "Copper", "Iron", "Steel", "Silver", "Mithril"];
		
		public const TYPE:Array = ["H2SWORD", "H1SWORD", "CURVED", "BLUNT", "DAGGER", "POLEARM", "RANGED", "AXE"];
		public const H1SWORD:Array = ["Gladius", "Short sword", "Rapier", "Falchion", "Spatha"];
		public const H2SWORD:Array = ["Claymore", "Nodachi", "Flamberge"];
		public const CURVED:Array = ["Katana", "Saber", "Scimitar", "Falcata"];
		public const BLUNT:Array = ["Morning Star", "Mace", "Flail", "Club", "Warhammer", "Maul"];
		public const DAGGER:Array = ["Stiletto", "Kris", "Dagger", "Misericorde", "Katars", "Dirk", "Kukri", "Main-gauche"];
		public const POLEARM:Array = ["Spear", "Halberd", "Glaive", "Naginata", "Bardiche"];
		public const RANGED:Array = ["Bow", "Crossbow", "Sling", "Wand", "Throwing axe", "Throwing knife", "Shuriken"];
		public const AXE:Array = ["Axe", "Double-headed Axe", "Battleaxe", "Tomahawk"];
		
		public const TILE_INDEX:uint = 0;
		
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
			
			// need to weight this away from bone and wood, those should be relatively rare
			// later add a weight based on level so as to not find silver and mithril right away
			var randMat:uint = Math.round(Math.random() * (MATERIAL.length-1));
			weaponMaterial = MATERIAL[randMat] + " ";
			
			// weapon post-processing to remove silliness
			// slings should not have a type, shurikens shouldn't be made of wood (a duck!)
			// other ranged weapons should be "laced" with a certain extra material, not made of it
			if (weaponType == "RANGED") {
				switch(weaponSubtype) {
					case "Sling":
						weaponMaterial = "";
						break;
					case "Shuriken":
						if (weaponMaterial == "Wood ") {
							weaponMaterial = "Steel ";
						}
						break;
					case "Bow":
					case "Crossbow":
					case "Wand":
						weaponMaterial = weaponMaterial + "-laced ";
						break;
				}
			}
			
			super();
			
			// set which tile this weapon is, based on type probably
			// this will be used for overlaying the player character to show equipment
			// at the moment defaulting to 0
			tileIndex = TILE_INDEX;
			DESCRIPTION = weaponMaterial + weaponSubtype;
			ITEM_TYPE = GC.C_ITEM_WEAPON;

			graphic = new Image(WEAPON);
		}
		
	}

}