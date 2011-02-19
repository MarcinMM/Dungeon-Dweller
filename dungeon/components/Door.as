package dungeon.components
{
	import net.flashpunk.FP;
	import dungeon.components.Point;

    public class Door {

		public function Door(initLoc:Point, initWall:String) {
			loc = initLoc;
			wall = initWall; // left right top bottom
			type = 'normal'; // for now, determined by chance later
			state = true; // for now, determined by chance later
		}

        public var loc:Point;
        public var wall:String;
		public var type:String; // normal door, hidden door, hole (or destroyed door)
		public var state:Boolean; // 1 for closed, 0 for open?
		
    }
}