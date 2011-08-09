class DecorGraphic extends Graphic {
  public var layerOne:Tilemap;
  public var layerTwo:Tilemap;
  public var layerThree:Tilemap;
  public var layerFour:Tilemap;

  public var layerArray:Array = [layerOne, layerTwo, layerThree, layerFour];

  [Embed(source = '/assets/bloodsplatter.png')] private const BLOODSPLATTER:Class;

  public var layerIndex:uint = 1;
  
  // init all layers in layerArray
  public function DecorGraphic() {
    for (var i:int in layerArray) {
      layerArray[i] = new Tilemap(BLOODSPLATTER, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
    }
  }

  // you have to choose material (which is the tile in tilemap) and the option to randomize; randomMaterial indicates maximum offset for random. 0 indicates no offset  
  public function addDecor(x:uint, y:uint, area:String, material:uint, randomMaterial:uint) {
    // TODO: randomize material index to generate varying decor components
    if (randomMaterial != 0) {
      // TODO: randomized material calculation, offset from material
    }
    if (layerIndex < layerArray.length) {
      layerArray[layerIndex].setRect(x / GC.GRIDSIZE, (y / GC.GRIDSIZE)-1, 1, 1, material);
      layerIndex++;
    }
  }

  override public function render(target:BitmapData, point:Point, camera:Point):void {
    for (var i:int in layerArray) {
      layerArray[i].render(target, point, camera);
    }
  }
}