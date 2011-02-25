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
		private var _step:uint;
		
        public function Nodemap(_dungeonmap:Tilemap, _roomsA:Array) {
			_nodes = new Vector.<Node>(Dungeon.TILESX * Dungeon.TILESY, true);
			// initialize nodemap for pathing
			var node:Node;
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
			// init room solidity
			initSolidity();			
		}
		
		// iterate through map and set not solid where FLOOR, DOORS
		private function initSolidity():void {
			for each(var node:Node in _nodes) {
				if (Level.NONSOLIDS.indexOf(_map.getTile(node.x, node.y)) != -1) {
					node.solid = false;
				}
			}
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
			// make a copy of the rooms array
			var roomList:Array = new Array();
			roomList = roomList.concat(roomsA);

			var randomRoomPick:int = 0;
			var destRoomPick:int = 0;

			// doors
			var doorList:Array = new Array();
			var usedDoorList:Array = new Array();
			var destDoorIndex:uint;
			var sourceDoorIndex:uint;
			var destDoor:Door;
			var sourceDoor:Door;
			
			// rooms
			var firstRoom:Room = roomList[0];
			var startingRoom:Room;
			var splicedRoom:Array; // containing the room that was spliced out in element zero
			var destRoom:Room;
			
			// setup door list from room.door 
			for each(var room:Room in roomsA) {
				for each (var sourceD:Door in room.doors) {
					doorList.push(sourceD);
				}
			}
			
			while (roomList.length > 0) {
				// pick a random room
				randomRoomPick = Math.max(0, Math.round(Math.random() * roomList.length) - 1);
				splicedRoom = roomList.splice(randomRoomPick, 1);
				startingRoom = splicedRoom[0];
				
				// it's possible we're out of rooms now
				if (roomList.length > 0) {
					destRoomPick = Math.max(0, Math.round(Math.random() * roomList.length) - 1);
					splicedRoom = roomList.splice(destRoomPick, 1);
					destRoom = splicedRoom[0];
				} else {
					// so this room has to circle back to the first room
					destRoom = firstRoom;
				}
				// now find random doors in each and connect them
				sourceDoorIndex = Math.max(0,Math.round(Math.random() * startingRoom.doors.length) - 1);
				sourceDoor = startingRoom.doors[sourceDoorIndex];
				
				destDoorIndex = Math.max(0,Math.round(Math.random() * destRoom.doors.length) - 1);
				destDoor = destRoom.doors[destDoorIndex];
				
				createConnectingHallway(sourceDoor.loc, destDoor.loc);
				// now remove the used doors from doors
				// somehow?
			}
			
			/*
			var destPoint:Point;
			for each(room in roomsA) {
				// make sure you search for doors in rooms OTHER than THIS one
				for each (sourceDoor in room.doors) {
					if (Math.random() > 0.5) {
						// find farthest
						destPoint = room.findFarthestDoor(sourceDoor, roomsA);
					} else {
						// find nearest
						destPoint = room.findNearestDoor(sourceDoor, roomsA);
					}
					createConnectingHallway(sourceDoor.loc, destPoint);
				}
			} 
			*/
		}
		
		public function setNodeSolidity(coordX:uint, coordY:uint, solidity:Boolean):void {
			var node:Node = new Node(coordX, coordY, 0);
			node.solid = solidity;
		}
		
		private function createConnectingHallway(sourceDoor:Point, destDoor:Point):void {
			FP.log(sourceDoor.x + "-" + sourceDoor.y + "-" + destDoor.x + "-" + destDoor.y);
			var path:Array = new Array();

			// A* time
			var source:Node = getNode(sourceDoor.x, sourceDoor.y);
			var destNode:Node = getNode(destDoor.x, destDoor.y);
			path = source.findPath(destNode);
			trace("path size:" + path.length);
			// do not paint over any tile that's a door already
			// tile for doors
			var tileIndex:int;
			for each (var node:Node in path) {
				tileIndex = _map.getTile(node.x, node.y);
				if (Level.DOORSA.indexOf(tileIndex) == -1) {
					_map.setRect(node.x, node.y, 1, 1, Level.HALL);
					node.solid = false;
				}
			}

			// then draw path, including walls
			
		}
		
		public function getNode(x:int, y:int):Node {
			if ((x >= 0) && (y >= 0) && (x < Dungeon.TILESX) && (y < Dungeon.TILESY)) {
				return _nodes[(y * Dungeon.TILESX) + x];
			} else return null;
		}
		
		public function update():void {
			// synchronize updates with player turn
			// report on player tile solidity
			if (_step != Dungeon.player.STEP) {
				var node:Node = getNode(Dungeon.player.x/20, Dungeon.player.y/20);
				FP.log('following in nodemap, solid: ' + node.solid);
				_step = Dungeon.player.STEP;
			}
		}


    }

}
