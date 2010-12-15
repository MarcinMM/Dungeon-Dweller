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
	public class MyEntity extends Entity
	{
		[Embed(source = 'assets/player.png')]
		private const PLAYER:Class;
		private const GRIDSIZE:int = 25;
		public var STEP:int = 0;
		
		public function MyEntity() 
		{
			graphic = new Image(PLAYER);
			Input.define("Left", Key.LEFT);
			Input.define("Right", Key.RIGHT);
			Input.define("Up", Key.UP);
			Input.define("Down", Key.DOWN);
			setHitbox(42, 21);
		}
		
		override public function update():void
		{
			var leftImpact:Boolean = false, rightImpact:Boolean = false, topImpact:Boolean = false, bottomImpact:Boolean = false;
			var s:AnotherShip = collide("npcShip", x, y) as AnotherShip;
			if (collide("npcShip", x, y + GRIDSIZE)) {
				topImpact = true;
			}
			if (collide("npcShip", x, y - GRIDSIZE)) {
				bottomImpact = true;
			}
			if (collide("npcShip", x + GRIDSIZE, y)) {
				leftImpact = true;
			}
			if (collide("npcShip", x - GRIDSIZE, y)) {
				rightImpact = true;
			}
			if (Input.pressed("Left") && !rightImpact) {
				x -= GRIDSIZE;
				STEP++;
			}
			if (Input.pressed("Right") && !leftImpact) {
				x += GRIDSIZE;
				STEP++;
			}
			if (Input.pressed("Up") && !bottomImpact) {
				y -= GRIDSIZE;
				STEP++;
			}
			if (Input.pressed("Down") && !topImpact) {
				y += GRIDSIZE;
				STEP++;
			}
			FP.log("Step: " + STEP);
			FP.watch("STEP");
		}
		
	}

}