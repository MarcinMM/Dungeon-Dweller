package dungeon.contents 
{
	import dungeon.structure.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.*;
	import dungeon.utilities.GC;
	import dungeon.utilities.MaterialPrototype;
	import dungeon.utilities.WeaponPrototype;

	/**
	 * ...
	 * @author MM
	 */
	public class Weapon extends Item 
	{
		[Embed(source = '../../assets/weapon.png')] private const WEAPON:Class;

		public const TILE_INDEX:uint = 0;

		// now vars
		public var weaponType:String;
		public var weaponMaterial:String;
		
		// combat vars
		public var attack:uint;
		public var defense:uint;
		public var pen:Number;
		public var hands:uint;
		public var offhand:Boolean;
		public var offhandRating:Number;
		public var crit:Number;
		public var strengthReq:uint;
		
		public function Weapon() 
		{
			var randWeapon:uint = Math.round(Math.random() * (Dungeon.dataloader.weapons.length - 1));
			var weaponPrototype:WeaponPrototype = Dungeon.dataloader.weapons[randWeapon];
			var materialPrototype:MaterialPrototype = new MaterialPrototype;
			
			// how to select from materials based on rarity? Iterate through all?
			// Formula: rarity = materialRarity - (Max((lowerLevelTreshold - Level),0) * lowerTresholdIncrement) - ((Max(Level - UpperLevelTreshold),0)
			// Then if the material rand is larger than computed rarity, this material is allowed
			var randMaterial:uint = Math.round(Math.random() * 100);
			var adjustedMaterialRarity:uint;
			var materialRarity:uint = 0;
			var selectedMaterial:uint = 0;
			var allowedMaterials:Array = new Array();
			var finalMaterialRand:uint = 0;
			
			// vars for testing
			var lowerThreshold:int = 0;
			var upperThreshold:int = 0;
			
			// could this be done any other way than a foreach?
			for (var i:uint = 1; i < Dungeon.dataloader.materials.length; i++) {
				materialPrototype = Dungeon.dataloader.materials[i];
				
				// hmm can't access Dungeon.level.dungeonDepth
				lowerThreshold = Math.max((1 - materialPrototype.lowerRarityThreshold), 0) * materialPrototype.lowerRarityIncrement;
				upperThreshold = Math.max((materialPrototype.upperRarityThreshold - 1), 0) * materialPrototype.upperRarityIncrement;
				adjustedMaterialRarity = materialPrototype.rarity - lowerThreshold - upperThreshold;
				
				// change this to adding all materials that pass probability
				// then do another random on the resulting array
				if (randMaterial < adjustedMaterialRarity) {
					allowedMaterials.push(i);
				}
			}
			
			finalMaterialRand = Math.round(Math.random() * (allowedMaterials.length - 1));
			
			materialPrototype = Dungeon.dataloader.materials[allowedMaterials[finalMaterialRand]];
			
			// weapon post-processing to remove silliness
			// slings should not have a type, shurikens shouldn't be made of wood (a duck!)
			// other ranged weapons should be "laced" with a certain extra material, not made of it
			if (weaponPrototype.type == "RANGED") {
				switch(weaponPrototype.name) {
					case "Sling":
						materialPrototype = Dungeon.dataloader.materials[0]; // no material
						break;
					case "Shuriken":
						if (materialPrototype == Dungeon.dataloader.materials[1]) {
							materialPrototype = Dungeon.dataloader.materials[3]; // this needs to be steel
						}
						break;
					case "Bow":
					case "Crossbow":
					case "Wand":
						materialPrototype = Dungeon.dataloader.materials[0]; // this needs to be no material
						break;
				}
			}
			
			// now that we have material selected, we need to apply the modifiers and set the final vars
			
			attack = Math.floor(materialPrototype.modifier * weaponPrototype.attack);
			defense = Math.floor(materialPrototype.modifier * weaponPrototype.defense);
			pen = materialPrototype.modifier * weaponPrototype.pen;
			hands = weaponPrototype.hands;
			offhand = weaponPrototype.offhand;
			offhandRating = weaponPrototype.offhandRating;
			crit = materialPrototype.modifier * weaponPrototype.crit;
			strengthReq = weaponPrototype.strengthReq;
			
			super();
			
			// set which tile this weapon is, based on type probably
			// this will be used for overlaying the player character to show equipment
			// at the moment defaulting to 0
			tileIndex = TILE_INDEX;
			DESCRIPTION = materialPrototype.name + weaponPrototype.name;
			ITEM_TYPE = GC.C_ITEM_WEAPON;

			graphic = new Image(WEAPON);
		}
		
	}

}