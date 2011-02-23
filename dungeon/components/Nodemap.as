package dungeon.components
{
	import dungeon.components.Point;
	import dungeon.components.Node;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.FP;
	
    public class Nodemap {

		public var _nodes:Vector.<Node>;
		private var roomsA:Array;
		private var _map:Tilemap;
		
        public function Nodemap(_dungeonmap:Tilemap, _roomsA:Array) {
			// initialize nodemap for pathing
			var node:Node;
			_nodes = new Vector.<Node>(Dungeon.TILESX * Dungeon.TILESY, true);
			for (var row:uint = 0; row < Dungeon.TILESY; row++) {
				for (var column:uint = 0; column < Dungeon.TILESX; column++) {
					node = new Node(column, row, _dungeonmap.getTile(column, row));
					//trace("node at:" + column + "-" + row + ":" + node.x + "-" + node.y + "|with index of: " + _dungeonmap.getTile(column, row) + " and id: " + node._id);
					_nodes[node._id] = node;
				}
			}

			// now that the nodemap is populated
			// go through and set up neighbours for all nodes
			
			for each (node in _nodes) {
				createNeighbors(node);
			}
			_map = _dungeonmap;
			roomsA = _roomsA;
			
		}

		public function createNeighbors(node:Node):void {
			var n:Node;
			n = getNode((node.x)+1, node.y);
			if (n != null && Utils.isAvailable(n.tileIndex, 'corridor')) {
				node.addNeighbor(n);
				
			}
			n = getNode((node.x)-1, node.y);
			if (n != null && Utils.isAvailable(n.tileIndex, 'corridor')) {
				node.addNeighbor(n);
			}
			n = getNode(node.x, (node.y)+1);
			if (n != null && Utils.isAvailable(n.tileIndex, 'corridor')) {
				node.addNeighbor(n);
			}
			n = getNode(node.x, (node.y)-1);
			if (n != null && Utils.isAvailable(n.tileIndex, 'corridor')) {
				node.addNeighbor(n);
			}
		}
		
		public function drawHallways():void {
			var destDoor:Point;
			
			for each(var room:Room in roomsA) {
				// make sure you search for doors in rooms OTHER than THIS one
				for each (var sourceDoor:Door in room.doors) {
					if (Math.random() > 0.5) {
						// find farthest
						destDoor = room.findFarthestDoor(sourceDoor, roomsA);
					} else {
						// find nearest
						destDoor = room.findNearestDoor(sourceDoor, roomsA);
					}
					createConnectingHallway(sourceDoor.loc, destDoor);
				}
			}
		}
		
		private function createConnectingHallway(sourceDoor:Point, destDoor:Point):void {
			FP.log(sourceDoor.x + "-" + sourceDoor.y + "-" + destDoor.x + "-" + destDoor.y);
			var path:Array = new Array();

			// A* time
			var source:Node = getNode(sourceDoor.x, sourceDoor.y);
			var destNode:Node = getNode(destDoor.x, destDoor.y);
			path = source.findPath(destNode);
			trace("path size:" + path.length);
			// we should be skipping the first and last
			// tile for doors
			var hCount:uint = 0;
			for each (var node:Node in path) {
				if (hCount > 0 && hCount < path.length) {
					_map.setRect(node.x, node.y, 1, 1, Level.DEBUGG);
				}
				hCount++;
			}

			// then draw path, including walls
			
		}
		
		public function getNode(x:int, y:int):Node {
			if ((x >= 0) && (y >= 0) && (x < Dungeon.TILESX) && (y < Dungeon.TILESY)) {
				return _nodes[(y * Dungeon.TILESX) + x];
			} else return null;
		}		

    }

}
