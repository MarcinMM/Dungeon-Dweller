package dungeon.structure
{
	import net.flashpunk.FP;
	import dungeon.utilities.GC;

    public class Point {
		public function Point(initX:int, initY:int, convert:Boolean = false) {
			if (!convert) {
				x = initX;
				y = initY;
			} else {
				x = Math.floor(initX / GC.GRIDSIZE);
				y = Math.floor(initY / GC.GRIDSIZE);
			}
		}
		
		// it might be an idea to make these private and only have getters and setters. those always feel so wordy though :/
		public var x:int;
		public var y:int;
		
		public function setPoint(newX:int, newY:int, convert:Boolean = false):void {
			if (!convert) {
				x = newX;
				y = newY;
			} else {
				x = Math.floor(newX / GC.GRIDSIZE);
				y = Math.floor(newY / GC.GRIDSIZE);
			}
		}
		
		public function foundInArray(pointArray:Array):Boolean {
			var foundFlag:Boolean = false;
			for each (var usedPoint:Point in pointArray) {
				if ( (x == usedPoint.x) && (y == usedPoint.y) ) {
					foundFlag = true;
				}
			}
			return foundFlag;
		}
		
		public function equals(otherPoint:Point):Boolean {
			if ((otherPoint.x == x) && (otherPoint.y == y)) {
				return true;
			}
			return false;
		}
    }
	
	
}
