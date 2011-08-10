package dungeon.utilities {

	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Spritemap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import Dungeon;
	
	public class MonsterGraphic extends Graphic {
		public var creatureSprite:Spritemap;
		public var armorSprite:Spritemap;
		public var weaponSprite:Spritemap;
		[Embed(source = '/assets/item_overlay_test.png')] private const ITEM_OVERLAYS:Class;
  
		public function MonsterGraphic(creature:uint, armor:uint, weapon:uint) {
			// the ints will be ITEM_OVERLAY indices, hardcoded now for testing
			creatureSprite = new Spritemap(ITEM_OVERLAYS, 32, 32);
			creatureSprite.add("staticCreature", [27], 0, false);
			creatureSprite.play("staticCreature");
			
			armorSprite = new Spritemap(ITEM_OVERLAYS, 32, 32);
			armorSprite.add("staticArmor", [0], 0, false);
			armorSprite.play("staticArmor");

			weaponSprite = new Spritemap(ITEM_OVERLAYS, 32, 32);
			weaponSprite.add("staticWeapon", [14], 0, false);
			weaponSprite.play("staticWeapon");
		}

		override public function render(target:BitmapData, point:Point, camera:Point):void {
			creatureSprite.render(target, point, camera);
			armorSprite.render(target, point, camera);
			weaponSprite.render(target, point, camera);
		}
	}
}