package dungeon.components
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	//import net.flashpunk.masks.Grid;
	import net.flashpunk.FP;

    public class Room
    {
        public function Room(initX:int, initY:int, initHeight:int, initWidth:int) {
            x = initX;
            y = initY;
            height = initHeight + 2; // height is actually the given room height + top and bottom borders
            width = initWidth + 2; // width is actually the given room width + top and bottom borders
            xRight = x + width; // therefore the far right edge is starting point + new width
            yBottom = y + height;
        }
        
        // coordinates and bounds of room
        public var x:int;
        public var y:int;
        public var height:int;
        public var width:int;
        public var xRight:int;
        public var yBottom:int;
        
        // TODO: doors and holes
        
        // TODO: room decor
        
        // TODO: room traps and widgets
    
        public function draw(_dungeonmap:Tilemap, _roomsA:Array):Array {
            // sooooo for this we need a starting point and an ending point
            // and they must not intersect any other such arrangement on the map
            // we should also have room size maximums and minimums
            // let's say minimum is 3, maximum is 20
            
            var success:Boolean = true;
    
            // check bounds			
            if (xRight > Dungeon.TILESX) {
                width = Dungeon.TILESX - (x + 2);
                xRight = Dungeon.TILESX;
            }
            if (yBottom > Dungeon.TILESY) {
                height = Dungeon.TILESY - (y + 2);
                yBottom = Dungeon.TILESY;
            }
            
            //  now it is possible we have a 0 width/height room			
            if ( (width <= 0) || (height <= 0) ) {
                success = false;
            }
            
            // check for collisions, then start drawing
            if (!this.roomCollision(_roomsA) && success) {
                // top, bottom, left, then right
                _dungeonmap.setRect(x, y, width, 1, 2);
                _dungeonmap.setRect(x, yBottom, width, 1, 2);
                _dungeonmap.setRect(x, y, 1, height, 2);
                _dungeonmap.setRect(xRight, y, 1, height, 2);
                // add room to array since it was successful
                _roomsA.push(this);
                FP.log(x + " | " + y + " | " + width + " | " + height + " | " + _roomsA.length);
            } else {
                FP.log("fail");
            }
            // pushed or not, the room array is returned to handler
            return _roomsA;
        }
        
        private function roomCollision(_roomsA:Array):Boolean {
            var overlap:Boolean = false;
            for (var i:int = 0; i < _roomsA.length; i++) {
                var currentRoom:Room = _roomsA[i];
                if (
                    (currentRoom.x < xRight) &&
                    (currentRoom.xRight > x) &&
                    (currentRoom.y < yBottom) &&
                    (currentRoom.yBottom > y)
                ) {
                    overlap = true;
                }
            }
            return overlap;        
        }
    }
}