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
			trace('node x and y:' + node.x + '-' + node.y);
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
				for each(var sourceDoorA:Array in room.doors) {
					for each (var sourceDoor:Door in sourceDoorA) {
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
		}
		
		private function createConnectingHallway(sourceDoor:Point, destDoor:Point):void {
			FP.log(sourceDoor.x + "-" + sourceDoor.y + "-" + destDoor.x + "-" + destDoor.y);
			var path:Array = new Array();

			// A* time
			// initialize node, nodemap, neighbours, and costs
			var source:Node = new Node(sourceDoor.x, sourceDoor.y, 0);
			path = source.findPath(destDoor);
			
			for each (var node:Node in path) {
				_map.setRect(node.x, node.y, 1, 1, Level.DEBUGR);
			}

			// then draw path, including walls
			
		}
		
		public function getNode(x:int, y:int):Node {
			if (x > 0 && y > 0 && x < Dungeon.TILESX && y < Dungeon.TILESY) {
				return _nodes[(y*x) + x];
			} else return null;
		}		

    }

}
