package  
{
	import dungeon.structure.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import dungeon.utilities.GC;
	/**
	 * ...
	 * @author MM
	 */
	public class NPC extends Entity
	{
		[Embed(source = 'assets/player.png')] private const NPCGraphic:Class;
		// some defaults and inits
		private const GRIDSIZE:int = 20;
		public var STEP:int = 0;
		public var SIGHT_RANGE:int = 1;
			
		public var ARMOR:Array = new Array();
		public var WEAPONS:Array = new Array();
		public var SCROLLS:Array = new Array();
		public var POTIONS:Array = new Array();
		public var JEWELRY:Array = new Array();
		// this must correspond to the constants 0,1,2,3,4 so we can assign items properly
		public var ITEMS:Array = [ARMOR, WEAPONS, SCROLLS, POTIONS, JEWELRY];
				
		// Stat Array
		public var STATS:Array = new Array();
		
		// pathing status
		private var PATHING:Boolean = false;
		private var ENGAGED:Boolean = false;
		private var ENGAGE_STATUS:uint = GC.NPC_STATUS_IDLE;
		
		public function NPC() 
		{
			graphic = new Image(NPCGraphic);
			x = 100;
			y = 100;
			setHitbox(20, 20);
			type = "npc";
			STEP = Dungeon.player.STEP;
		}
		
		// when no path request is being made, i.e. equivalent of idle animation
		public function idleMovement():Point {
			var impactsAllowed:Array = ["up","down","left","right"];
			// NPC considering a step, see what's allowed
			if (collide("npc", x, y + GRIDSIZE) || collide("player", x, y + GRIDSIZE) || collide("level", x, y + GRIDSIZE)) {
				impactsAllowed.splice(impactsAllowed.indexOf("down"),1);
			}
			if (collide("npc", x, y - GRIDSIZE) || collide("player", x, y + GRIDSIZE) || collide("level", x, y - GRIDSIZE)) {
				impactsAllowed.splice(impactsAllowed.indexOf("up"),1);
			}
			if (collide("npc", x + GRIDSIZE, y) || collide("player", x, y + GRIDSIZE) || collide("level", x + GRIDSIZE, y)) {
				impactsAllowed.splice(impactsAllowed.indexOf("right"),1);
			}
			if (collide("npc", x - GRIDSIZE, y) || collide("player", x, y + GRIDSIZE) || collide("level", x - GRIDSIZE, y)){
				impactsAllowed.splice(impactsAllowed.indexOf("left"),1);
			}

			// NPC movement
			// select random index then perform movement
			var rndMove = Math.round(Math.random() * impactsAllowed.length));
			switch (rndMove) {
				case "up":
				y -= GRIDSIZE;
				STEP++;
				break;
				case "down":
				y -= GRIDSIZE;
				STEP++;
				break;
				case "left":
				x -= GRIDSIZE;
				STEP++;
				break;
				case "right":
				x -= GRIDSIZE;
				STEP++;
				break;
			}		
		}
		
		// this can be used to achieve goals such as pickup item or attack another entity, or seek escape route
		public function pathedMovement(pointA:Point, pointB:Point):Point {

		}
		
		// swarm cohort check
		public function checkSwarmInRoom():Boolean {
			return false;
		}
		
		override public function update():void {
			if (Dungeon.player.STEP != STEP) {
				// Prototype basic NPC loop
				// 1. Check if an action is already being performed
				// 2. check NPC sight range if an enemy is within
				// 3. check NPC sight range if an item is within
				// 2,3a. Find path to enemy or item
				// 2.3b. Perform path
				// 2.3c. Perform item/enemy action (attack/check for item quality/equip)
				// 4. If attacking, flee check.
				// 4a. Flee.
				// 5. After item/attack succesful resume idling
				
				idleMovement();

				

				
				
				// finally sync NPC with player
				STEP = Dungeon.player.STEP;
			}
		}
		
	}

}