package dungeon.structure
{
	import net.flashpunk.FP;

    public class Point {
		public function Point(initX:int, initY:int) {
			// these refer to grid X and Y,  not real coordinates X and Y on the display
			x = initX;
			y = initY;
		}
		
		public var x:int;
		public var y:int;
		
		public function foundInArray(pointArray:Array):Boolean {
			var foundFlag:Boolean = false;
			for each (var usedPoint:Point in pointArray) {
				if ( (x == usedPoint.x) && (y == usedPoint.y) ) {
					foundFlag = true;
				}
			}
			return foundFlag;
		}
    }
	
	
}
