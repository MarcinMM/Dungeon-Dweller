package dungeon.components
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
    }
}
