package dungeon.structure
{
	import dungeon.structure.Point;
	import flash.utils.Dictionary;
	import Dungeon;
	
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
			var closedListD:Dictionary = new Dictionary();
			
			var neighborList:Vector.<Node>;
			
			trace("path from: " + this.x + "-" + this.y + " to " + endNode.x + "-" + endNode.y);
						
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
			
			var openIndex:int;
			var closedIndex:int;
			var gCost2:int = 0;
			
			while (i < 1000 && openList.length > 0 && currentNode != endNode && (!currentNode.sameLoc(endNode))) {
				//i++;
				openList.sortOn("fCost");
// perf hit here, needs to turn openList into a priorityQueue from http://www.polygonal.de/doc/ds/
				currentNode = openList.shift();
				closedList.push(currentNode);
				closedListD[currentNode] = true;
				//if (closedListD[currentNode] == true) trace ('blibli');
				if (type == "corridor") {
					neighborList = currentNode.solidNeighbors;
				} else if (type == "creature") {
					neighborList = currentNode.walkingNeighbors;
				}

				for each (var neighbor:Node in neighborList) {
// perf hit here, need to turn closedList into a hashtable from flash.utils.Dictionary
// so we can just do a check on (array[node] == true) rather than searching every time
// also
					openIndex = openList.indexOf(neighbor);
					closedIndex = closedList.indexOf(neighbor);
					//currentNode.findG(neighbor); 
					gCost2 = currentNode.gCost + 10; // this needs an actual calculation
					if (gCost2 < neighbor.gCost) {
						if (openIndex !== -1) {
							openList.splice(openIndex, 1);
							openIndex = -1;
						}
						/*if (closedListD[neighbor] == true) {
							closedListD[neighbor] = false;
						}*/
						if (closedIndex !== -1) {
							trace(closedListD[neighbor]);
							closedList.splice(closedIndex, 1);
							closedIndex = -1;
						}
					}					
					//if (openIndex === -1 && closedListD[neighbor] !== true) {
					if (openIndex === -1 && closedIndex === -1) {
						neighbor.gCost = gCost2;
						neighbor.findH(endNode);
						neighbor.updateF();
						neighbor.setParent(currentNode);
						openList.push(neighbor);
					}
				}
			}
			i = 0;
			// now go back from the ending node to start
			var pathedNode:Node = endNode;
			//trace('start: ' + this.x + '-' + this.y);
			//trace('end: ' + endNode.x + '-' + endNode.y);
			while ((pathedNode != null && pathedNode != this) && (i < 100)) {
				trace("path:" + pathedNode.x + "-" + pathedNode.y);
				
				//Dungeon.level._dungeonmap.setRect(pathedNode.x,pathedNode.y,Dungeon.TILESX, Dungeon.TILESY, 6);
				path.push(pathedNode);
				pathedNode = pathedNode.parent;
				i++;
			}

			return path;
		}
    }
	
}