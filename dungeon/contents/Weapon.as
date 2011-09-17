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
		public const TILE_INDEX:uint = 0;

		// now vars
		public var weaponType:String;
		public var weaponMaterial:String;
		
		// combat vars, empty hands by default?
		public var attack:uint = 0;
		public var defense:uint = 0;
		public var pen:Number = 0;
		public var hands:uint = 1;
		public var offhand:Boolean = false;
		public var offhandRating:Number = 0;
		public var crit:Number = 0.3;
		public var strengthReq:uint = 0;
		public var gtype:String; // graphic type
		
		public function Weapon(setGraphic:Boolean = true) 
		{
			slot = GC.SLOT_PRIMARY_WEAPON; // default slot for weapons
			var randWeapon:uint = Math.round(Math.random() * (Dungeon.dataloader.weapons.length - 1));
			var weaponXML:XML = Dungeon.dataloader.weapons[randWeapon];
			var materialXML:XML = new XML();
			
			// how to select from materials based on rarity? Iterate through all?
			// Formula: rarity = materialRarity - (Max((lowerLevelTreshold - Level),0) * lowerTresholdIncrement) - ((Max(Level - UpperLevelTreshold),0)
			// Then if the material rand is larger than computed rarity, this material is allowed
			var randMaterial:uint = Math.round(Math.random() * 100);
			var adjustedMaterialRarity:uint;
			var allowedMaterials:Array = new Array();
			var finalMaterialRand:uint = 0;
			
			// vars for testing
			var lowerThreshold:int = 0;
			var upperThreshold:int = 0;
			
			// could this be done any other way than a foreach?
			// TODO: implememnt XML searching as shown at: http://www.senocular.com/flash/tutorials/as3withflashcs3/?page=4#e4x
			for (var i:uint = 1; i < Dungeon.dataloader.materials.length; i++) {
				materialXML = Dungeon.dataloader.materials[i];
				
				// hmm can't access Dungeon.level.dungeonDepth
				lowerThreshold = Math.max((1 - materialXML.lowerRarityThreshold), 0) * materialXML.lowerRarityIncrement;
				upperThreshold = Math.max((materialXML.upperRarityThreshold - 1), 0) * materialXML.upperRarityIncrement;
				adjustedMaterialRarity = materialXML.rarity - lowerThreshold - upperThreshold;
				
				// change this to adding all materials that pass probability
				// then do another random on the resulting array
				if (randMaterial < adjustedMaterialRarity) {
					allowedMaterials.push(i);
				}
			}
			
			finalMaterialRand = Math.round(Math.random() * (allowedMaterials.length - 1));
			
			materialXML = Dungeon.dataloader.materials[allowedMaterials[finalMaterialRand]];
			
			// weapon post-processing to remove silliness
			// slings should not have a type, shurikens shouldn't be made of wood (a duck!)
			// other ranged weapons should be "laced" with a certain extra material, not made of it
			if (weaponXML.type == "RANGED") {
				switch(weaponXML.@name) {
					case "Sling":
						materialXML = Dungeon.dataloader.materials[0]; // no material
						break;
					case "Shuriken":
						if (materialXML == Dungeon.dataloader.materials[1]) {
							materialXML = Dungeon.dataloader.materials[3]; // this needs to be steel
						}
						break;
					case "Bow":
					case "Crossbow":
					case "Wand":
						materialXML = Dungeon.dataloader.materials[0]; // this needs to be no material
						break;
				}
			}
			
			// now that we have material selected, we need to apply the modifiers and set the final vars
			
			attack = Math.floor(materialXML.modifier * weaponXML.attack);
			defense = Math.floor(materialXML.modifier * weaponXML.defense);
			pen = materialXML.modifier * weaponXML.pen;
			hands = weaponXML.hands;
			offhand = weaponXML.offhand;
			offhandRating = weaponXML.offhandRating;
			crit = materialXML.modifier * weaponXML.crit;
			strengthReq = weaponXML.strengthReq;
			rating = (attack * pen) + (attack * crit * pen) + defense; // absolute weapon rating used for creatures to determine relative weapon quality
			
			gtype = weaponXML.type;
			
			super();
			
			// set which tile this weapon is, based on type probably
			// this will be used for overlaying the player character to show equipment
			// at the moment defaulting to 0
			tileIndex = TILE_INDEX;
			DESCRIPTION = materialXML.@name + " " + weaponXML.@name;
			ITEM_TYPE = GC.C_ITEM_WEAPON;

			// TODO: fix dynamic weapon display assignation
			// dynamic spritemap assignation based on item type. one day, maybe on material too.
			// i.e.: weaponXML.name, materialXML.name
			if (setGraphic) {
				if (GC.WEAPON_TILES[weaponXML.type] == undefined) {
					_assets.add("static", [69], 0, false);
				} else {
					_assets.add("static", [GC.WEAPON_TILES[weaponXML.type]], 0, false);
				}
				//_assets.add("anim", [6, 7, 8, 9, 10, 11], 0, false); // animations!
				graphic = _assets;	
				_assets.play("static");
			}
		}
		
		public function selfCopy():Weapon {
			var newWeapon:Weapon = new Weapon(false);

			newWeapon.x = x;
			newWeapon.y = y;
			newWeapon.DESCRIPTION = DESCRIPTION;
			newWeapon.TRUE_DESCRIPTION = TRUE_DESCRIPTION;
			newWeapon.ITEM_TYPE = ITEM_TYPE;
			newWeapon.ITEM_LEVEL = ITEM_LEVEL;
			newWeapon.rating = rating;
			newWeapon.UNIQID = UNIQID;
			newWeapon.slot = slot;
			newWeapon.defense = defense;
			
			//newWeapon.TILE_INDEX = TILE_INDEX;
			newWeapon.tileIndex = tileIndex;
			newWeapon.attack = attack;
			newWeapon.pen = defense;
			newWeapon.hands = pen;
			newWeapon.offhand = offhand;
			newWeapon.offhandRating = offhandRating;
			newWeapon.crit = crit;
			newWeapon.strengthReq = strengthReq;
			newWeapon.gtype = gtype;
			newWeapon.crit = defense;
			newWeapon.weaponMaterial = weaponMaterial;
			
			newWeapon._assets.add("static", [GC.WEAPON_TILES[newWeapon.gtype]], 0, false);
			newWeapon.graphic = newWeapon._assets;
			newWeapon._assets.play("static");
			return newWeapon;
		}
	}

}