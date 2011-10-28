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
		public static function traceLine(x:int, y:int, x1:int, y1:int, lightPath:Boolean = false):Object {
			var nodeList:Array = new Array
			var successFlag:Boolean = true;
			var slope:Number = 0;
			var currentX:int = 0;
			var currentY:int = 0;
			
			// let's always trace from left to right
			// don't forget 0 slope and undefined slope
			if (x > x1) {
				currentX = x1;
				currentY = y1;
				slope = (y1 - y) / (x1 - x);	
				nodeList.push(new Point(x1, y1));
			} else if (x1 > x) {
				currentX = x;
				currentY = y;
				slope = (y - y1) / (x - x1);
				nodeList.push(new Point(x, y));
				// rename x1 and y1 to x and y so we can just do one loop in the next step
				x = x1;
				y = y1;
			} else {
				// x1 = x, vertical line
				slope = 0;
				if (y1 > y) {
					// y1 is destination
					currentX = x;
					currentY = y;
					x = x1;
					y = y1;
				} else {
					// y is destination
					currentX = x1;
					currentY = y1;
				}
			}

			// thanks to the renaming above, x and y are now destination - currentX and currentY are origin			

			// now we need to check which dimension changes faster, and iterate over that
			// the reason being that whatever changes faster will determine how often the tile changes
			// and that in turn is to avoid using JOMMETRY
			// faster change == bigger change in coordinate

			var tileAtThisLocation:Point;
			var tileAtPreviousLocation:Point = new Point(currentX / GC.GRIDSIZE, currentY / GC.GRIDSIZE);
			
			var whileLimiter:uint = 0;
			
			// this relies on the trace direction always being up
			if (slope == 0) {
				while ((currentY < y) && (whileLimiter < 1000)) {
					whileLimiter++; // ************************ DEBUG
					currentY += 30;
					tileAtThisLocation = new Point(Math.floor(currentX / GC.GRIDSIZE), Math.floor(currentY / GC.GRIDSIZE));	
					if (!tileAtThisLocation.equals(tileAtPreviousLocation)) {
							nodeList.push(tileAtThisLocation);
							
							// check collision, for the moment assuming no collision
							if (false) {
								successFlag = false;
							}
							tileAtPreviousLocation.x = tileAtThisLocation.x;
							tileAtPreviousLocation.y = tileAtThisLocation.y;
					}
				}
			}
			else {
				if (Math.abs(y - currentY) > Math.abs(x - currentX)) {
					// y dimension changes faster, iterate through Y
					// since we are always moving from left to right, we just need to check for X dimension reaching target
					while ((x > currentX) && (whileLimiter < 1000)) {
						whileLimiter++; // ********************* DEBUG
						if (slope > 0) {
							currentY += 30;
						} else {
							currentY -= 30;
						}
						currentX += Math.abs(int (30 / slope));
						tileAtThisLocation = new Point(Math.floor(currentX / GC.GRIDSIZE), Math.floor(currentY / GC.GRIDSIZE));	
						if (!tileAtThisLocation.equals(tileAtPreviousLocation)) {
							nodeList.push(tileAtThisLocation);
							
							// check collision, faking for the moment for testing
							if (false) {
								successFlag = false;
							}
							tileAtPreviousLocation.x = tileAtThisLocation.x;
							tileAtPreviousLocation.y = tileAtThisLocation.y;
						}
					}

				} else {
					// x dimension changes faster, iterate through X
					while ((x > currentX) && (whileLimiter < 1000)) {
						whileLimiter++; // ********************* DEBUG
						currentX += 30;
						currentY += 30 * slope;
						tileAtThisLocation = new Point(Math.floor(currentX / GC.GRIDSIZE), Math.floor(currentY / GC.GRIDSIZE));										
						if (!tileAtThisLocation.equals(tileAtPreviousLocation)) {
							nodeList.push(tileAtThisLocation);
							
							// check collision, fix fakeage
							if (false) {
								successFlag = false;
							}
							tileAtPreviousLocation.x = tileAtThisLocation.x;
							tileAtPreviousLocation.y = tileAtThisLocation.y;
						}
					}
				}
			}
			// still need to cover vertical use case where slope is undefined
			
			// loop through node list for debug
			for each (var point:Point in nodeList) {
				Dungeon.level._dungeonmap.setRect(point.x, point.y, 1, 1, GC.DEBUGGREEN);
			}
			
			var returnThings:Object = 
			{
				"success": successFlag,
				"path": nodeList
			};

			return returnThings;
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