package dungeon.utilities
{

	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Tilemap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import Dungeon;
	
	public class DecorGraphic extends Graphic {

		public var layerOne:Tilemap;
		public var layerTwo:Tilemap;
		public var layerThree:Tilemap;
		public var layerFour:Tilemap;

		public var layerArray:Array = [];
		public var mapLocations:Vector.<uint>;
		
		public var layerCount:uint = 4;
		// TODO: make actual spatters tilemap with 10? 20? spatters
		// TODO: also add green and blue recolors of spatters
		[Embed(source = '/assets/surface_nonsolids.png')] private const BLOODSPLATTER:Class;

		public var layerIndex:uint = 0;
	  
		// init all layers in layerArray
		public function DecorGraphic() {
			var map:Tilemap;
			for (var i:uint = 0; i < layerCount; i++ ) {
				map = new Tilemap(BLOODSPLATTER, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
				layerArray.push(map);
			}
			
			mapLocations = new Vector.<uint>(Dungeon.TILESX * Dungeon.TILESY);
		}
		
		// clear all decor on level load
		public function resetDecor():void {
			mapLocations = new Vector.<uint>(Dungeon.TILESX * Dungeon.TILESY);
			for each (var i:Tilemap in layerArray) {
				i.clearRect(0, 0, Dungeon.TILESX, Dungeon.TILESY);
			}		
		}
		
		// TODO: we'll need restore and save decor as well
		/*
		public function saveDecor() {
			for each (var i:Tilemap in layerArray) {
				i.saveToString(",", ":");
			}
		}
		
		public function loadDecor() {
			for each (var i:Tilemap in layerArray) {
				i.loadFromString(str, ",", ":");
			}
		}
		*/
		
		// you have to choose material (which is the tile in tilemap) and the option to randomize; randomMaterial indicates maximum offset for random. 0 indicates no offset 
		public function addDecor(x:uint, y:uint, material:uint, randomMaterial:uint):void {
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