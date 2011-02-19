package dungeon.components
{
	import dungeon.components.Point;
	
    public class Utils {
		public static function findDistance(pointA:Point, pointB:Point):Number {
			return Math.sqrt((pointB.x - pointA.x)^2 + (pointB.y - pointA.y)^2);
		}
		
		public static function isAvailable(index:int, type:String):Boolean {			
			// this will need to have some switches for corridor pathing and creature pathing
			switch(type) {
				case "corridor":
					if ((index == Level.NWALL) ||
						(index == Level.EWALL) ||
						(index == Level.SWALL) ||
						(index == Level.WWALL))
					{
						return true;
					} else {
						return false;
					}
					break;
				case "creature":
					if ((index == Level.FLOOR)) {
						return true;
					} else {
						return false;
					}
					break;
				default:
					return false;
				break;
			}
		}
		
		// custom sort for finding lowest F cost node
		public function sortOnFWeight(nodeA:Node, nodeB:Node):Number {
			if(nodeA.fCost > nodeB.fCost) {
				return 1;
			} else if(nodeA.fCost < nodeB.fCost) {
				return -1;
			} else  {
				return 0;
			}			
		}
    }
	
}