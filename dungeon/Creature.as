package dungeon
{
	import dungeon.contents.Armor;
	import dungeon.contents.Item;
	import dungeon.contents.Weapon;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import dungeon.utilities.*;

	/**
	 * ...
	 * @author MM
	 */
	public class Creature extends Entity
	{
		// creature size, used for collision
		private const GRIDSIZE:int = 20;

		// Collision stats
		public var COLLISION:Array = [0, 0, 0, 0, 0];
		public var COLLISION_TYPE:int = GC.COLLISION_NONE;
		public var MOVE_DIR:int = 0;

		// all this does is populate all directions in which this creature is surrounded by entities
		public function checkCollision(collisionEntity:String, collisionConstant:int):void {
			if (collide(collisionEntity, x, y + GRIDSIZE)) {
				COLLISION[GC.DIR_DOWN] = collisionConstant;
				COLLISION_TYPE = collisionConstant;
			}
			if (collide(collisionEntity, x, y - GRIDSIZE)) {
				COLLISION[GC.DIR_UP] = collisionConstant;
				COLLISION_TYPE = collisionConstant;
			}
			if (collide(collisionEntity, x + GRIDSIZE, y)) {
				COLLISION[GC.DIR_RIGHT] = collisionConstant;
				COLLISION_TYPE = collisionConstant;
			}
			if (collide(collisionEntity, x - GRIDSIZE, y)){
				COLLISION[GC.DIR_LEFT] = collisionConstant;
				COLLISION_TYPE = collisionConstant;
			}			
		}
	}
}