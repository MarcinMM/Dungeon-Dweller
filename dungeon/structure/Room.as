package dungeon.structure
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	//import net.flashpunk.masks.Grid;
	import net.flashpunk.FP;
    import dungeon.structure.Point;
    import dungeon.structure.Door;
    import dungeon.structure.Wall;
    import dungeon.utilities.GC;

    public class Room
    {
        // statics
        public const _maxDoorsPerWall:int = 3;
        public const _maxDoorsPerRoom:int = 5;
        public const _doorChance:int = 3; // 30% door chance? consider making this a variable and alternating door avg.
        
        // coordinates and bounds of room
        public var x:int;
        public var y:int;
        public var height:int;
        public var width:int;
        public var xRight:int;
        public var yBottom:int;
        public var walls:Array;
        
        public var doors:Array = [];
        
        // TODO: room decor/clutter
        
        // TODO: room traps and widgets
        
        public function Room(initX:int, initY:int, initHeight:int, initWidth:int) {
            // room coordinates are actually tile/grid coordinates, not actual x and y
            // might want to standardise real x and y vs. grid x and y
            x = initX;
            y = initY;
            height = initHeight + 1; // height is actually the given room height + top and bottom borders
            width = initWidth + 1; // width is actually the given room width + top and bottom borders
            xRight = x + width; // therefore the far right edge is starting point + new width
            yBottom = y + height;
            // now init walls 
            walls = [];
        }
    
        public function draw(_dungeonmap:Tilemap, _roomsA:Array):Array {
            // sooooo for this we need a starting point and an ending point
            // and they must not intersect any other such arrangement on the map
            // we should also have room size maximums and minimums
            // let's say minimum is 3, maximum is 20
            
            var success:Boolean = true;
    
            // check bounds
            // FIXME: this is fubared somehow
            if (xRight >= Dungeon.TILESX-2) {
                width = Dungeon.TILESX - (x + 3);
                xRight = Dungeon.TILESX - 3;
            }
            if (yBottom >= Dungeon.TILESY-2) {
                height = Dungeon.TILESY - (y + 3);
                yBottom = Dungeon.TILESY - 3;
            }
			if (x < 1) {
				width = width - 2;
				x = 2;
			}
			if (y < 1) {
				height = height - 2;
				y = 2;
			}
            
            //  now it is possible we have a 0 width/height room			
            if ( (width <= 1) || (height <= 1) ) {
                success = false;
            }
            
            // check for collisions, then start drawing
            if (!this.roomCollision(_roomsA) && success) {
                // now that we know where this room really is, we can define walls
                var newWall:Wall = new Wall(new Point(x,y), new Point(xRight,y), 'top');
                walls.push(newWall);
                newWall = new Wall(new Point(x,yBottom), new Point(xRight,yBottom), 'bottom');
                walls.push(newWall);
                newWall = new Wall(new Point(x,y), new Point(x,yBottom), 'left');
                walls.push(newWall);
                newWall = new Wall(new Point(xRight,y), new Point(xRight,yBottom),'right');
                walls.push(newWall);                
                // top, bottom, left, then right, the room itself
                _dungeonmap.setRect(x, y, width+1, 1, GC.TOPWALL);
                _dungeonmap.setRect(x, yBottom, width+1, 1, GC.BOTTOMWALL);
                _dungeonmap.setRect(x, y, 1, height+1, GC.LEFTWALL);
                _dungeonmap.setRect(xRight, y, 1, height+1, GC.RIGHTWALL);
                // now corners
                _dungeonmap.setRect(x, y, 1, 1, GC.TOPLEFTCORNER);
                _dungeonmap.setRect(xRight, y, 1, 1, GC.TOPRIGHTCORNER);
                _dungeonmap.setRect(x, yBottom, 1, 1, GC.BOTTOMLEFTCORNER);
                _dungeonmap.setRect(xRight, yBottom, 1, 1, GC.BOTTOMRIGHTCORNER);
                // now floor
                _dungeonmap.setRect(x+1,y+1,width-1,height-1, GC.FLOOR);
                // now doors
                //trace("room x xRight y ybottom:" + x + "-" + xRight + "-" + y + "-" + yBottom);
                drawDoors(_dungeonmap);

                // now interactives
                // drawWidgets();
                // now clutter
                // drawClutter();
                
                _roomsA.push(this);
            } else {
                //trace("room add fail");
            }
            // pushed or not, the room array is returned to handler
            return _roomsA;
        }
        
        private function roomCollision(_roomsA:Array):Boolean {
            var overlap:Boolean = false;
            for (var i:int = 0; i < _roomsA.length; i++) {
                var currentRoom:Room = _roomsA[i];
                if (
                    (currentRoom.x-1 <= xRight) &&
                    (currentRoom.xRight+1 >= x) &&
                    (currentRoom.y-1 <= yBottom) &&
                    (currentRoom.yBottom+1 >= y)
                ) {
                    overlap = true;
                }
            }
            return overlap;        
        }
        
        private function drawDoors(_dungeonmap:Tilemap):void {
            var doorSeed:int = 0;
            var point:Point = new Point(0,0);
            var door:Door = new Door(point, 'top');
            var doorCount:int = 0;
            var doorSuccess:Boolean = true;
			
            for each(var _wall:Wall in walls) {
                for (var i:int = 0; i < _maxDoorsPerWall; i++) {
                    if (doorCount <= 1) {
                    doorSeed = Math.round(Math.random() * 10);
                    if (doorSeed < _doorChance) {
                        // door chance successful, create a new door somewhere on this wall
                        // first find a point on the wall
                        point = _wall.findRandomPoint();
                        // draw the door only if it's a wall tile and door max hasn't been reached
                        if ((_dungeonmap.getTile(point.x, point.y) != GC.FLOOR) && (doorCount <= _maxDoorsPerRoom)) {
                            // check if random point isn't next to an existing door
                            if (_wall.position == 'top' || _wall.position == 'bottom') {
                                if ((_dungeonmap.getTile(point.x + 1, point.y) == GC.TOPDOOR) ||
                                   (_dungeonmap.getTile(point.x - 1, point.y) == GC.BOTTOMDOOR) ||
                                   (_dungeonmap.getTile(point.x + 1, point.y) == GC.BOTTOMDOOR) ||
                                   (_dungeonmap.getTile(point.x - 1, point.y) == GC.TOPDOOR))
                                {
                                    doorSuccess = false;
                                }
                            }
                            if (_wall.position == 'left' || _wall.position == 'right') {
                                if ((_dungeonmap.getTile(point.x, point.y + 1) == GC.LEFTDOOR) ||
                                   (_dungeonmap.getTile(point.x, point.y - 1) == GC.RIGHTDOOR) ||
                                   (_dungeonmap.getTile(point.x, point.y + 1) == GC.RIGHTDOOR) ||
                                   (_dungeonmap.getTile(point.x, point.y - 1) == GC.LEFTDOOR))
                                {
                                    doorSuccess = false;
                                }
                            }
                            if (doorSuccess) {
                                door = new Door(point,_wall.position);
                                // add door to room.wall property
                                doors.push(door);
                                _dungeonmap.setRect(point.x, point.y, 1, 1, GC.DOORS[_wall.position]);
                                doorCount++;
                            }
                        }
                    }
                    }
                }
            }
            
            
            if (doorCount == 0) {
                // add a door if there are none; all rooms should have doors
                // pick a wall at (4 walls, so a random out of 4)
				doorSeed = Math.round(Math.random() * 3);
				var doorIndex:uint = 0;
                for each(_wall in walls) {
                    if (doorIndex == doorSeed) {
						point = _wall.findRandomPoint();
						door = new Door(point,_wall.position);
						
						// add door to room.wall property
						doors.push(door);
						_dungeonmap.setRect(point.x, point.y, 1, 1, GC.DOORS[_wall.position]);
						doorCount++;
                    }
					doorIndex++;
                }
            }
        }
        
		public function findNearestDoor(sourceDoor:Door, _roomsA:Array):Point {
            var closestDoorPoint:Point = new Point(0,0);
            var shortestDistance:Number = 1000;
            var currentDistance:Number = 0;
			for each (var otherRoom:Room in _roomsA) {
                // ensure we are searching through OTHER rooms for the closest door
                if ((otherRoom.x != x) && (otherRoom.y != y)) {
                    for each (var destDoor:Door in otherRoom.doors) {
                        currentDistance = Utils.findDistance(sourceDoor.loc, destDoor.loc);
                        if (currentDistance < shortestDistance) {
                            shortestDistance = currentDistance;
                            closestDoorPoint = destDoor.loc;
                        }
                    }
                    
                }
            }
            return closestDoorPoint;
		}
		
		public function findFarthestDoor(sourceDoor:Door, _roomsA:Array):Point {
            var farthestDoorPoint:Point = new Point(0,0);            
            var farthestDistance:Number = 0;
            var currentDistance:Number = 0;
            
			for each (var otherRoom:Room in _roomsA) {
                // ensure we are searching through OTHER rooms for the closest door
                if ((otherRoom.x != x) && (otherRoom.y != y)) {
                    for each (var destDoor:Door in otherRoom.doors) {
                        currentDistance = Utils.findDistance(sourceDoor.loc, destDoor.loc);
                        if (currentDistance > farthestDistance) {
                            farthestDistance = currentDistance;
                            farthestDoorPoint = destDoor.loc;
                        }
                    }
                }
            }
            return farthestDoorPoint;
		}        
        
    }
}