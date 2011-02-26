package dungeon.components
{
	import dungeon.components.Point;
	
    public class Utils {
		public static function findDistance(pointA:Point, pointB:Point):Number {
			return Math.sqrt(Math.pow((pointB.x - pointA.x),2) + Math.pow((pointB.y - pointA.y),2));
		}

		public static function findNodeDistance(nodeA:Node, nodeB:Node):Number {
			return Math.sqrt(Math.pow((nodeB.x - nodeA.x),2) + Math.pow((nodeB.y - nodeA.y),2));
		}
		
		public static function isAvailable(index:int, type:String):Boolean {			
			// this will need to have some switches for corridor pathing and creature pathing
			// TODO: this needs cleanup, but I'm confused by it. It should work for index simply being THE VOID, but it doesn't
			switch(type) {
				case "corridor":
					if ((index == Level.NWALL) ||
						(index == Level.EWALL) ||
						(index == Level.SWALL) ||
						(index == Level.WWALL) ||
						//(index == Level.FLOOR) ||
						(index == Level.CORNERS['TL']) ||
						(index == Level.CORNERS['TR']) ||
						(index == Level.CORNERS['BL']) ||
						(index == Level.CORNERS['BR']))
					{
						return false;
					} else {
						return true;
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