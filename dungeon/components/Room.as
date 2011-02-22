package dungeon.components
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	//import net.flashpunk.masks.Grid;
	import net.flashpunk.FP;
    import dungeon.components.Point;
    import dungeon.components.Door;
    import dungeon.components.Wall;

    public class Room
    {
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
            // doors init
            doors['top'] = new Array();
            doors['bottom'] = new Array();
            doors['left'] = new Array();
            doors['right'] = new Array();
        }
        
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
        
        // TODO: doors and holes
        // Doors array has 4 members which are themselves array: left right top bottom
        public var doors:Array = [];
        
        // TODO: room decor/clutter
        
        // TODO: room traps and widgets
    
        public function draw(_dungeonmap:Tilemap, _roomsA:Array):Array {
            // sooooo for this we need a starting point and an ending point
            // and they must not intersect any other such arrangement on the map
            // we should also have room size maximums and minimums
            // let's say minimum is 3, maximum is 20
            
            var success:Boolean = true;
    
            // check bounds
            // FIXME: this is fubared somehow
            if (xRight >= Dungeon.TILESX-1) {
                width = Dungeon.TILESX - (x + 2);
                xRight = Dungeon.TILESX - 2;
            }
            if (yBottom >= Dungeon.TILESY-1) {
                height = Dungeon.TILESY - (y + 2);
                yBottom = Dungeon.TILESY - 2;
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
                _dungeonmap.setRect(x, y, width+1, 1, Level.NWALL);
                _dungeonmap.setRect(x, yBottom, width+1, 1, Level.SWALL);
                _dungeonmap.setRect(x, y, 1, height+1, Level.WWALL);
                _dungeonmap.setRect(xRight, y, 1, height+1, Level.EWALL);
                // now floor
                _dungeonmap.setRect(x+1,y+1,width-1,height-1, Level.FLOOR);
                // now doors
                trace("room x xRight y ybottom:" + x + "-" + xRight + "-" + y + "-" + yBottom);
                drawDoors(_dungeonmap);

                // now interactives
                // drawWidgets();
                // now clutter
                // drawClutter();
                
                _roomsA.push(this);
            } else {
                FP.log("room add fail");
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
                    doorSeed = Math.round(Math.random() * 10);
                    if (doorSeed < _doorChance) {
                        // door chance successful, create a new door somewhere on this wall
                        // first find a point on the wall
                        point = _wall.findRandomPoint();
                        // draw the door only if it's a wall tile and door max hasn't been reached
                        if ((_dungeonmap.getTile(point.x, point.y) != Level.FLOOR) && (doorCount <= _maxDoorsPerRoom)) {
                            // check if random point isn't next to an existing door
                            if (_wall.position == 'top' || _wall.position == 'bottom') {
                                if ((_dungeonmap.getTile(point.x + 1, point.y) == Level.DOOR) ||
                                   (_dungeonmap.getTile(point.x - 1, point.y) == Level.DOOR))
                                {
                                    doorSuccess = false;
                                }
                            }
                            if (_wall.position == 'left' || _wall.position == 'right') {
                                if ((_dungeonmap.getTile(point.x, point.y + 1) == Level.DOOR) ||
                                   (_dungeonmap.getTile(point.x, point.y - 1) == Level.DOOR))
                                {
                                    doorSuccess = false;
                                }
                            }
                            if (doorSuccess) {
                                door = new Door(point,_wall.position);
                                
                                // add door to room.wall property
                                doors[_wall.position].push(door);
                                _dungeonmap.setRect(point.x, point.y, 1, 1, Level.DOOR);
                                doorCount++;
                            }
                        }
                    }
                }
            }
            
            if (doorCount == 0) {
                // add a door if there are none; all rooms should have doors
                // even if some are secret
                // pick a wall at random and add a door
                for each(_wall in walls) {
                    if (doorCount == 0) {
                        doorSeed = Math.round(Math.random() * 10);
                        if (doorSeed > 5) {
    
                            point = _wall.findRandomPoint();
                            door = new Door(point,_wall.position);
                            
                            // add door to room.wall property
                            doors[_wall.position].push(door);
                            _dungeonmap.setRect(point.x, point.y, 1, 1, Level.DEBUGG);
                            doorCount++;
                        }
                    }
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
                    for each (var doorA:Array in otherRoom.doors) {
                        for each (var destDoor:Door in doorA) {
                            currentDistance = Utils.findDistance(sourceDoor.loc, destDoor.loc);
                            if (currentDistance < shortestDistance) {
                                shortestDistance = currentDistance;
                                closestDoorPoint = destDoor.loc;
                            }
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
                    for each (var doorA:Array in otherRoom.doors) {
                        for each (var destDoor:Door in doorA) {
                            currentDistance = Utils.findDistance(sourceDoor.loc, destDoor.loc);
                            if (currentDistance > farthestDistance) {
                                farthestDistance = currentDistance;
                                farthestDoorPoint = destDoor.loc;
                            }
                        }
                    }
                }
            }
            return farthestDoorPoint;
		}        
        
    }
}