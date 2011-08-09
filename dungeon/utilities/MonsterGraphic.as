class MonsterGraphic extends Graphic {
  public var creatureSprite:Spritemap;
  public var armorSprite:Spritemap;
  public var weaponSprite:Spritemap;
  
  public function MonsterGraphic(creature:uint, armor:uint, weapon:uint) {
  	
  }

  override public function render(target:BitmapData, point:Point, camera:Point):void {
    creatureSprite.render(target, point, camera);
    armorSprite.render(target, point, camera);
    weaponSprite.render(target, point, camera);
  }
}