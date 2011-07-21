package dungeon.structure
{
	import dungeon.structure.Point;
	
	/**
	  * Like a point, but with weights depending on its position within a pathfinding call
	  * We'll probably need 
	*/
	
    public class Node extends Point {
        
        public var gCost:int; // cost to move here from starting position
        public var hCost:int; // estimate heuristic to move here from ending position
        public var fCost:int;  // combined cost
		private var parent:Node;
		public var solidNeighbors:Vector.<Node>;
		public var walkingNeighbors:Vector.<Node>;
		public var _id:uint;
		public var tileIndex:int = -1;
		public var solid:Boolean;
        
        public function Node(initX:int, initY:int, initTileIndex:int) {
			super(initX, initY);
			gCost = 0; 
			hCost = 0; 
			fCost = 0;
			_id = (y * Dungeon.TILESX) + x;
			if (tileIndex == -1) {
				tileIndex = initTileIndex;
			}
			if (initTileIndex == -1) {
				// this means we're initing an alredy existing node, so we need to grab the tile index from the nodemap
				tileIndex = Dungeon.level._dungeonmap.getIndex(x, y);
			}
			solidNeighbors = new Vector.<Node>();
			walkingNeighbors = new Vector.<Node>();
			solid = true;
        }
    	
		public function getGCost():int {
			return gCost;
		}
		
		public function setParent(node:Node):void {
			parent = node;
		}
		
		public function getParent():Node {
			return parent;
		}
		
		public function addWalkingNeighbor(node:Node):void {
			walkingNeighbors.push(node);
		}
		
		public function addSolidNeighbor(node:Node):void {
			// this could/should have checking for validity
			solidNeighbors.push(node);
		}
		
		// Manhattan H cost of path
		public function findH(endNode:Node):void {
			hCost = (Math.abs(endNode.x - x) + Math.abs(endNode.y - y)) * 10;
			updateF();
		}
		
		public function findG(prevNode:Node):void {
			if ( (prevNode.x == x) || (prevNode.y == y) ) {
				// if this node is on the same axis as the previous node, then it's a straight line move with cost 10
				gCost = prevNode.gCost + 10;
			} else {
				// otherwise it's a diagonal, and cost is 14
				gCost = prevNode.gCost + 14;
			}
		}
		
		public function updateF():void {
			fCost = gCost + hCost;
		}
		
		public function lessThan(otherNode:Node):Boolean {
			if (fCost < otherNode.fCost) return true;
			else return false;
		}

		public function greaterThan(otherNode:Node):Boolean {
			if (fCost > otherNode.fCost) return true;
			else return false;
		}
		
		public function sameLoc(otherNode:Node):Boolean {
			if (x == otherNode.x && y == otherNode.y) return true;
			else return false;
		}

		// this needs a selector for type of path to find - corridor through rock or walking for creature access
		public function findPath(endNode:Node, type:String):Array {
			var path:Array = new Array();
			var openList:Array = new Array();
			var closedList:Array = new Array();
			
			var neighborList:Vector.<Node>;
			
			trace("path from: " + this.x + "-" + this.y + " to " + endNode.x + "-" + endNode.y);
			
			// costs for traversing nodes vert/horizontally or diagonally
			// may play with diagonal value to increase chance of straight lines
			// but all that might result in is repeated L shaped diagonals instead of long hallways, hmm
			
			var currentNode:Node = this;
			openList.push(this);
			
			var i:int = 0;
			var thisOpenIndex:int;

			if (type == "corridor") {
				neighborList = currentNode.solidNeighbors;
			} else if (type == "creature") {
				neighborList = currentNode.walkingNeighbors;
			}

			
			// SAFTY OFF! [sic]
			while ((i < 1000) && ((currentNode != endNode) && (!currentNode.sameLoc(endNode))) && (openList.length != 0)) {
				// Look for lowest F cost node
				//trace("open: " + openList.length + "|closed: " + closedList.length);
// perf hit here, needs to turn openList into a priorityQueue from http://www.polygonal.de/doc/ds/
				openList.sortOn("fCost");
				// Switch it to the closed list
				currentNode = openList.shift();
				if (type == "corridor") {
					neighborList = currentNode.solidNeighbors;
				} else if (type == "creature") {
					neighborList = currentNode.walkingNeighbors;
				}
				closedList.push(currentNode);
				//trace("****** starting with node at: " + currentNode.x + "-" + currentNode.y);
				for each (var node:Node in neighborList) {
					thisOpenIndex = -1;
					//trace("neighbor: " + node.x + "-" + node.y);
					// if node is not on closed list
// perf hit here, need to turn closedList into a hashtable from flash.utils.Dictionary 
// so we can just do a check on (array[node] == true) rather than searching every time
// also
					if (closedList.indexOf(node) == -1) {
						// if node is not in open list
							node.findG(currentNode);
							node.findH(endNode);
							node.updateF();
							//trace("g: " + node.gCost + "|hCost: " + node.hCost + "|fCost:" + node.fCost);
						if (openList.indexOf(node) == -1) {
							//trace("adding node to OL at:" + node.x + "-" + node.y);
							openList.push(node);
							node.setParent(currentNode);
							//trace(currentNode.x + "-" + currentNode.y + " became parent of " + node.x + "-" + node.y);
						} else {
							// this means this node is already on the list, which in turn means
							// a different G path was found to it
							// check that path distance vs. previous path
							thisOpenIndex = openList.indexOf(node);
							//trace("new path found for node at: " + openList[thisOpenIndex].x + "-" + openList[thisOpenIndex].y);
							if (node.getGCost() < openList[thisOpenIndex].getGCost()) {
								
								node.setParent(currentNode);
								openList[thisOpenIndex] = node;
								//trace("replacing node at index:" + thisOpenIndex + "-xy: " + node.x + "-" + node.y + "-gcost:" + node.getGCost());
							}
						}
					}
					i++;
				}
			}
			i = 0;
			// now go back from the ending node to start
			var pathedNode:Node = endNode;
			//trace('start: ' + this.x + '-' + this.y);
			//trace('end: ' + endNode.x + '-' + endNode.y);
			while ((pathedNode != null && pathedNode != this) && (i < 100)) {
				//trace("path:" + pathedNode.x + "-" + pathedNode.y);
				path.push(pathedNode);
				pathedNode = pathedNode.parent;
				i++;
			}
			
			/*
			 * http://www.policyalmanac.org/games/aStarTutorial.htm
			1) Add the starting square (or node) to the open list.
			2) Repeat the following:
			a) Look for the lowest F cost square on the open list. We refer to this as the current square.
			b) Switch it to the closed list.
			c) For each of the 8 squares adjacent to this current square �
				* If it is not walkable or if it is on the closed list, ignore it. Otherwise do the following.           
				* If it isn�t on the open list, add it to the open list. Make the current square the parent of this square. Record the F, G, and H costs of the square. 
				* If it is on the open list already, check to see if this path to that square is better, using G cost as the measure. A lower G cost means that
				* this is a better path. If so, change the parent of the square to the current square, and recalculate the G and F scores of the square. If you are
				* keeping your open list sorted by F score, you may need to resort the list to account for the change.
			d) Stop when you:
				* Add the target square to the closed list, in which case the path has been found (see note below), or
				* Fail to find the target square, and the open list is empty. In this case, there is no path.   
			3) Save the path. Working backwards from the target square, go from each square to its parent square until you reach the starting square.
			That is your path.
			*/
			return path;
		}
    }
	
}