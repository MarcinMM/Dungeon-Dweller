package dungeon.components
{
	import net.flashpunk.FP;
	import dungeon.components.Point;

    public class Wall {

		public function Wall(initStart:Point, initEnd:Point, initPosition:String) {			
			start = initStart;
			end = initEnd; // left right top bottom
			position = initPosition;
			type = 'normal'; // for now, determined by chance later
		}

        public var start:Point;
        public var end:Point;
		public var position:String;
		public var type:String; // reserved for future use
		
		// this is for placing doors on walls at random points
		public function findRandomPoint():Point {
			var span:int;
			var _pointCoord:int;
			var point:Point;
			if (start.x == end.x) {
				// this wall is vertical, our span is end y minus beginning y
				// and point is on X coord line
				span = end.y - start.y;
				trace("v span in random point:" + span + "|between: " + start.y + " and " + end.y);
				_pointCoord = Math.round(Math.random() * span);
				trace("pt: " + _pointCoord);
				if (_pointCoord == 0) {
					_pointCoord = 1;
				} else if (_pointCoord == span) {
					_pointCoord = span - 1;
				}
				//FP.log('vert wall with span:' + span + '-coord:' + _pointCoord);
				point = new Point(start.x, start.y + _pointCoord);
			} else {
				// this wall is horizontal, our span is end x minus beginning x
				// and point is on the Y coord line
				span = end.x - start.x;
				trace("h span in random point:" + span + "|between: " + start.x + " and " + end.x);
				_pointCoord = Math.round(Math.random() * span);
				trace("pt: " + _pointCoord);
				if (_pointCoord == 0) {
					_pointCoord = 1;
				} else if (_pointCoord == span) {
					_pointCoord = span - 1;
				}
				//FP.log('hor wall with span:' + span + '-coord:' + _pointCoord);
				point = new Point(start.x + _pointCoord, start.y);
			}
			trace("resulting door x-y: " + point.x + "-" + point.y);
			return point;
		}
    }
}