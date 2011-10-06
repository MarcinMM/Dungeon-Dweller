package dungeon.structure
{
	import dungeon.structure.Point;
	import dungeon.utilities.GC;
	
    public class Utils {
		
		// this needs to draw the line between two points, then check every 30 pixels for new tile, then add tile to nodelist
		// when done, iterate over nodelist and check collisions on each
		// if no collisions except for final, the path is clear
		// we can also use this for raytraced lighting at some point
		// so it needs to return two things, a true/false parameter and the path
		public static function traceLine(x, y, x1, y1, lightPath=false):Object {
			var nodeList:Array = new Array
			var successFlag:Boolean = true;
			
			// let's always trace from left to right
			// don't forget 0 slope and undefined slope
			if (x > x1) {
				var currentX:int = x1;
				var currentY:int = y1;
				var slope:Number = (y1 - y) / (x1 - x);	
				nodeList.push(new Point(x1, y1));
			} else if (x1 > x) {
				var currentX:int = x;
				var currentY:int = y;
				var slope:Number = (y - y1) / (x - x1);
				nodeList.push(new Point(x, y));
				// rename x1 and y1 to x and y so we can just do one loop in the next step
				x = x1;
				y = y1;
			} else {
				// x1 = x, vertical line
			}

			// thanks to the renaming above, x and y are now destination - currentX and currentY are origin			

			// now we need to check which dimension changes faster, and iterate over that
			// the reason being that whatever changes faster will determine how often the tile changes
			// and that in turn is to avoid using JOMMETRY
			// faster change == bigger change in coordinate

			var tileAtThisLocation:Point;
			var tileAtPreviousLocation:Point = new Point(currentX / GC.GRIDSIZE, currentY / GC.GRIDSIZE);

			// need to handle case

			if (y - currentY) > (x - currentX) {
				// y dimension changes faster, iterate through Y
				// since we are always moving from left to right, we just need to check for X dimension reaching target
				while (x < currentX) {
					currentY += 30;
					currentX += 30 / slope;
					tileAtThisLocation = new Point(Math.floor(currentX / GC.GRIDSIZE), Math.floor(currentY / GC.GRIDSIZE));	
					if (!tileAtThisLocation.equals(tileAtPreviousLocation)) {
						// we've reached a new tile
						// 0. push into nodeList for potential future lighting use
						// 1. check collision
						// 2. continue if nothing, set flag if failed successFlag = false;
						// 3. tileAtPreviousLocation = tileAtThisLocation;
					}
					// else push on to the next coordinate
				}

			} else {
				// x dimension changes faster, iterate through X
				while (x < currentX) {
					currentX += 30;
					currentY += 30 * slope;
					tileAtThisLocation = new Point(Math.floor(currentX / GC.GRIDSIZE), Math.floor(currentY / GC.GRIDSIZE));										
					if (!tileAtThisLocation.equals(tileAtPreviousLocation)) {
						// we've reached a new tile
						// 0. push into nodeList for potential future lighting use
						// 1. check collision
						// 2. continue if nothing, exit if collided (i.e. set false flag)
						// 3. tileAtPreviousLocation = tileAtThisLocation;
					}
					// else continue to iterate
				}
			}

			// still need to cover vertical use case where slope is undefined
			
			var returnThings:Object = 
			{
				"success": successFlag,
				"path": nodeList
			};

			return true;
		}
		
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