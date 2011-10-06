package dungeon.structure
{
	import dungeon.structure.Point;
	import dungeon.utilities.GC;
	
    public class Utils {
		
		// finds nearest object from collection of items/creatures/decors, returns index of array
		// only tricky bit is that pointA is given as a grid coord, collection x and y are real coords
		public static function findNearest(pointA:Point, collection:Array):uint {
			var shortestDistance:Number = 10000;
			var newDistance:Number = 0;
			var shortestIndex:int = -1;
			for (var i:int; i < collection.length; i++) {
				newDistance = Math.sqrt(Math.pow((pointA.x - (collection[i].x * GC.GRIDSIZE)), 2) + Math.pow((pointA.y - (collection[i].y * GC.GRIDSIZE)), 2));
				if (newDistance < shortestDistance) {
					shortestDistance = newDistance;
					shortestIndex = i;
				}
			}
			return shortestIndex;
		}
		
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
					if ((index == GC.TOPWALL) ||
						(index == GC.LEFTWALL) ||
						(index == GC.BOTTOMWALL) ||
						(index == GC.RIGHTWALL) ||
						//(index == GC.FLOOR) ||
						(index == GC.BOTTOMLEFTCORNER) ||
						(index == GC.BOTTOMRIGHTCORNER) ||
						(index == GC.TOPLEFTCORNER) ||
						(index == GC.TOPRIGHTCORNER))
					{
						return false;
					} else {
						return true;
					}
					break;
				case "creature":
					if (index == GC.HALL) {
						//trace('blibli');
					}
					if ((index == GC.FLOOR) ||
						(index == GC.HALL) ||
						(index == GC.BOTTOMDOOR) ||
						(index == GC.TOPDOOR) ||
						(index == GC.LEFTDOOR) ||
						(index == GC.RIGHTDOOR)
						) 
					{
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