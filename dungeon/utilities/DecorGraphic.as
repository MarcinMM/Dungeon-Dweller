package dungeon.utilities
{

	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Tilemap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import Dungeon;
	
	public class DecorGraphic extends Graphic {

		public var layerArray:Array = [];
		public var mapLocations:Vector.<uint>;
		
		public var layerCount:uint = 4;
		// TODO: also add green and blue recolors of spatters
		[Embed(source = '/assets/surface_nonsolids.png')] private const DECOR_TILES:Class;

		public var layerIndex:uint = 0;
	  
		// init all layers in layerArray
		public function DecorGraphic(makeNew:Boolean = true) {
			if (makeNew) {
				for (var i:uint = 0; i < layerCount; i++ ) {
					var map:Tilemap = new Tilemap(DECOR_TILES, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
					var test:String = map.saveToString();
					layerArray.push(map);
				}
			}
			
			mapLocations = new Vector.<uint>(Dungeon.TILESX * Dungeon.TILESY);
		}
		
		// clear all decor on level load
		public function resetDecorGraphic():void {
			mapLocations = new Vector.<uint>(Dungeon.TILESX * Dungeon.TILESY);
			for each (var i:Tilemap in layerArray) {
				i.clearRect(0, 0, Dungeon.TILESX, Dungeon.TILESY);
			}
		}
		
		public function selfCopy():DecorGraphic {
			var copy:DecorGraphic = new DecorGraphic(false);
			for each (var i:Tilemap in layerArray) {
				var map:Tilemap = new Tilemap(DECOR_TILES, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
				var savedMap:String = i.saveToString();
				map.loadFromString(savedMap);
				copy.layerArray.push(map);
			}
			for (var j:uint = 0; j < mapLocations.length; j++) {
				copy.mapLocations[j] = mapLocations[j];
			}
			
			return copy;
		}
		
		// you have to choose material (which is the tile in tilemap) and the option to randomize; randomMaterial indicates maximum offset for random. 0 indicates no offset 
		public function addGraphic(x:uint, y:uint, material:uint, randomMaterial:uint):void {
			// TODO: randomize material index to generate varying decor components
			if (randomMaterial != 0) {
				var offset:uint = Math.round(Math.random() * randomMaterial);
				// TODO: randomized material calculation, offset from material
			}
			var currentLoc:uint = (y * Dungeon.TILESX) + x;
			if (mapLocations[currentLoc] < layerCount) {
				layerArray[mapLocations[currentLoc]].setRect(x, y, 1, 1, material + offset);
				mapLocations[currentLoc]++;
			}
		}

		override public function render(target:BitmapData, point:Point, camera:Point):void {
			for each (var i:Tilemap in layerArray) {
				i.render(target, point, camera);
			}
		}
	}
}