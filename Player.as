package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	/**
	 * ...
	 * @author MM
	 */
	public class Player extends Entity
	{
		[Embed(source = 'assets/player.png')] private const PLAYER:Class;
		private const GRIDSIZE:int = 20;
		public var STEP:int = 0;
		public var LIGHT_RADIUS:int = 1;
		
		public function Player() 
		{
			graphic = new Image(PLAYER);
			Input.define("Left", Key.LEFT);
			Input.define("Right", Key.RIGHT);
			Input.define("Up", Key.UP);
			Input.define("Down", Key.DOWN);
			setHitbox(20, 20);
			x = 140;
			y = 140;
		}
		
		public function setPlayerStartingPosition(setX:int, setY:int):void {
			x = setX * GRIDSIZE;
			y = setY * GRIDSIZE;
		}
		
		override public function update():void
		{
			var leftImpact:Boolean = false, rightImpact:Boolean = false, topImpact:Boolean = false, bottomImpact:Boolean = false;
			//var s:AnotherShip = collide("npcShip", x, y) as AnotherShip;
			if (collide("npcShip", x, y + GRIDSIZE) || collide("level", x, y + GRIDSIZE)) {
				topImpact = true;
			}
			if (collide("npcShip", x, y - GRIDSIZE) || collide("level", x, y - GRIDSIZE)) {
				bottomImpact = true;
			}
			if (collide("npcShip", x + GRIDSIZE, y) || collide("level", x + GRIDSIZE, y)) {
				leftImpact = true;
			}
			if (collide("npcShip", x - GRIDSIZE, y) || collide("level", x - GRIDSIZE, y)){
				rightImpact = true;
			}
			if (Input.pressed("Left") && !rightImpact) {
				x -= GRIDSIZE;
				STEP++;
				trace("player at:" + (x/GRIDSIZE) + "-" + (y/GRIDSIZE));
			}
			if (Input.pressed("Right") && !leftImpact) {
				x += GRIDSIZE;
				STEP++;
				trace("player at:" + (x/GRIDSIZE) + "-" + (y/GRIDSIZE));
			}
			if (Input.pressed("Up") && !bottomImpact) {
				y -= GRIDSIZE;
				STEP++;
				trace("player at:" + (x/GRIDSIZE) + "-" + (y/GRIDSIZE));
			}
			if (Input.pressed("Down") && !topImpact) {
				y += GRIDSIZE;
				STEP++;
				trace("player at:" + (x/GRIDSIZE) + "-" + (y/GRIDSIZE));
			}
			//FP.log("Step: " + STEP);
			//FP.watch("STEP");
		}
		
	}

}