package dungeon.structure
{
	import dungeon.structure.Point;
	import dungeon.structure.Node;
	import net.flashpunk.graphics.TiledImage;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.FP;
	import dungeon.utilities.GC;
	
    public class Nodemap {

		public var _nodes:Vector.<Node>;
		private var roomsA:Array;
		private var _map:Tilemap; // just a reference to level map
		private var _step:uint;
		
        public function Nodemap(_dungeonmap:Tilemap, _roomsA:Array) {
			_map = _dungeonmap;
			roomsA = _roomsA;

			_nodes = new Vector.<Node>(Dungeon.TILESX * Dungeon.TILESY, true);

			refreshpathingNodeList();
			collectNeighbors();	
			
			// now that we have a collision matrix, draw hallways
			drawHallways();
			// now that we have hallways we need to re-init node list and neighbors
			refreshpathingNodeList();
			collectNeighbors();
			
			// init solidity
			initSolidity();			
		}
				
		public function load(_dungeonmap:Tilemap):void {
			// reset nodes
			_nodes = new Vector.<Node>(Dungeon.TILESX * Dungeon.TILESY, true);
			
			// reassign tilemap to current map
			_map = _dungeonmap;

			// recreate walkable/nonwalkable
			refreshpathingNodeList();
			
			// recreate neighbors
			collectNeighbors();
			
			// set solid/nonsolid based on above
			initSolidity();
		}
		
		public function refreshpathingNodeList():void {
			var node:Node;
			for (var row:uint = 0; row < Dungeon.TILESY; row++) {
				for (var column:uint = 0; column < Dungeon.TILESX; column++) {
					node = new Node(column, row, _map.getTile(column, row));
					_nodes[node._id] = node;
				}
			}			
		}
		
		// this needs to be its own function since we might need to reinit this based on level changes
		// such as digging or rock/wall creating (why not?)
		public function collectNeighbors():void {
			var node:Node;
			for each (node in _nodes) {
				createSolidNeighbors(node);
				createWalkingNeighbors(node);
			}
		}
		
		// iterate through map and set not solid where FLOOR, DOORS
		private function initSolidity():void {
			for each(var node:Node in _nodes) {
				if (Level.NONSOLIDS.indexOf(_map.getTile(node.x, node.y)) != -1) {
					node.solid = false;
				}
			}
		}
		
		// this is neighbour creation for hallways
		// tiles available are: solid rock, door, hallway, floor
		public function createSolidNeighbors(node:Node):void {
			var n:Node;
			n = getNodeTile((node.x)+1, node.y);
			if (n != null && Utils.isAvailable(n.tileIndex, 'corridor')) {
				node.addSolidNeighbor(n);
			}
			n = getNodeTile((node.x)-1, node.y);
			if (n != null && Utils.isAvailable(n.tileIndex, 'corridor')) {
				node.addSolidNeighbor(n);
			}
			n = getNodeTile(node.x, (node.y)+1);
			if (n != null && Utils.isAvailable(n.tileIndex, 'corridor')) {
				node.addSolidNeighbor(n);
			}
			n = getNodeTile(node.x, (node.y)-1);
			if (n != null && Utils.isAvailable(n.tileIndex, 'corridor')) {
				node.addSolidNeighbor(n);
			}
		}
		
		// this is neighbour creation for things that need walking space
		// tiles available are: floors, hallways, doors
		public function createWalkingNeighbors(node:Node):void {
			var n:Node;
			n = getNodeTile((node.x)+1, node.y);
			if (n != null && Utils.isAvailable(n.tileIndex, 'creature')) {
				node.addWalkingNeighbor(n);
			}
			n = getNodeTile((node.x)-1, node.y);
			if (n != null && Utils.isAvailable(n.tileIndex, 'creature')) {
				node.addWalkingNeighbor(n);
			}
			n = getNodeTile(node.x, (node.y)+1);
			if (n != null && Utils.isAvailable(n.tileIndex, 'creature')) {
				node.addWalkingNeighbor(n);
			}
			n = getNodeTile(node.x, (node.y)-1);
			if (n != null && Utils.isAvailable(n.tileIndex, 'creature')) {
				node.addWalkingNeighbor(n);
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
			var startingRoom:Room;
			var firstRoom:Room;
			var splicedRoom:Array; // containing the room that was spliced out in element zero
			var destRoom:Room;
			
			// setup door list from room.door 
			for each(var room:Room in roomsA) {
				for each (var sourceD:Door in room.doors) {
					doorList.push(sourceD);
				}
			}
			
			// set up starting room
			randomRoomPick = Math.max(0, Math.round(Math.random() * roomList.length) - 1);
			splicedRoom = roomList.splice(randomRoomPick, 1);
			startingRoom = splicedRoom[0];
			firstRoom = startingRoom;
			
			while (roomList.length > 0) {
				// pick a random room for the new destination room
				destRoomPick = Math.max(0, Math.round(Math.random() * roomList.length) - 1);
				splicedRoom = roomList.splice(destRoomPick, 1);
				destRoom = splicedRoom[0];

				// now find random doors in each and connect them
				sourceDoorIndex = Math.max(0,Math.round(Math.random() * startingRoom.doors.length) - 1);
				sourceDoor = startingRoom.doors[sourceDoorIndex];
				
				destDoorIndex = Math.max(0,Math.round(Math.random() * destRoom.doors.length) - 1);
				destDoor = destRoom.doors[destDoorIndex];
				
				createConnectingHallway(sourceDoor.loc, destDoor.loc);
				
				// the destination becomes the new starter point 
				startingRoom = destRoom;
				// now remove the used doors from doors
				// somehow?
			}
			
			// it is possible only one room generated
			if ((destRoom != null) && (firstRoom != null)) {
				// now we need to loop back around to the start (firstRoom)
				// the last room is the last (destRoom)
				destDoorIndex = Math.max(0,Math.round(Math.random() * destRoom.doors.length) - 1);
				destDoor = destRoom.doors[destDoorIndex];
				sourceDoorIndex = Math.max(0,Math.round(Math.random() * firstRoom.doors.length) - 1);
				sourceDoor = firstRoom.doors[sourceDoorIndex];
				
				createConnectingHallway(destDoor.loc, sourceDoor.loc);
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
				
		private function createConnectingHallway(sourceDoor:Point, destDoor:Point):void {
			//FP.log(sourceDoor.x + "-" + sourceDoor.y + "-" + destDoor.x + "-" + destDoor.y);
			//trace(sourceDoor.x + "-" + sourceDoor.y + " to " + destDoor.x + "-" + destDoor.y);
			var path:Array = new Array();

			// A* time
			var source:Node = getNodeTile(sourceDoor.x, sourceDoor.y);
			var destNode:Node = getNodeTile(destDoor.x, destDoor.y);
			path = source.findPath(destNode, 'corridor');
			//trace("path size:" + path.length);
			// do not paint over any tile that's a door already
			// tile for doors
			var tileIndex:int;
			for each (var node:Node in path) {
				tileIndex = _map.getTile(node.x, node.y);
				if ((Level.DOORSA.indexOf(tileIndex) == -1) && (tileIndex != GC.FLOOR)) {
					_map.setRect(node.x, node.y, 1, 1, Level.HALL);
					node.solid = false;
				}
			}
		}
		
		// retrieve _nodes (premapped, pre-neighboured) node at given COORDINATE x,y location
		public function getNode(x:int, y:int):Node {
			x = x / GC.GRIDSIZE;
			y = y / GC.GRIDSIZE;
			if ((x >= 0) && (y >= 0) && (x < Dungeon.TILESX) && (y < Dungeon.TILESY)) {
				return _nodes[(y * Dungeon.TILESX) + x];
			} else return null;
		}

		// retrieve _nodes (premapped, pre-neighboured) node at given TILE x,y location
		public function getNodeTile(x:int, y:int):Node {
			if ((x >= 0) && (y >= 0) && (x < Dungeon.TILESX) && (y < Dungeon.TILESY)) {
				return _nodes[(y * Dungeon.TILESX) + x];
			} else return null;
		}		
		
		public function update():void {
			// synchronize updates with player turn
			// report on player tile solidity
			if (_step != Dungeon.player.STEP) {
				var node:Node = getNode(Dungeon.player.x, Dungeon.player.y);
				_step = Dungeon.player.STEP;
			}
		}


    }

}
