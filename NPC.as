package  
{
	import dungeon.Creature;
	import dungeon.structure.Node;
	import dungeon.structure.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import dungeon.utilities.GC;
	/**
	 * ...
	 * @author MM
	 */
	public class NPC extends Creature
	{
		[Embed(source = 'assets/npc1.png')] private const NPCGraphic:Class;
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
		
		// What is this thing? And what type of descriptors do we need? Let's start simple.
		public var NPCType:String;
		public var NPCLevel:uint;
		
		// Stat Array
		public var STATS:Array = new Array();
		
		// pathing status
		private var POSITION:Point;
		private var PATHING:Boolean = false;
		private var ENGAGED:Boolean = false;
		private var ENGAGE_STATUS:uint = GC.NPC_STATUS_IDLE;
		private var PATH:Array = new Array();
		
		public function NPC() 
		{
			super();
			graphic = new Image(NPCGraphic);
			setHitbox(20, 20);
			type = "npc";
			STEP = Dungeon.player.STEP;
			POSITION = new Point(x, y);
			
			// now, what shall this critter be?
			determineNPCType();
			
			// TODO: what shall it wear/wield?
			// determineNPCEquipment();
			
			// and what kind of stats does it have?
			setNPCStats(NPCType, NPCLevel);
			setNPCDerivedStats(NPCType, NPCLevel);
			
			layer = 20;
		}
		
		// when no path request is being made, i.e. equivalent of idle animation
		public function idleMovement():void {
			var impactsAllowed:Array = ["up","down","left","right"];
			// NPC considering a step, see what's allowed
			if (collide("npc", x, y + GRIDSIZE) || collide("player", x, y + GRIDSIZE) || collide("level", x, y + GRIDSIZE)) {
				impactsAllowed.splice(impactsAllowed.indexOf("down"),1);
			}
			if (collide("npc", x, y - GRIDSIZE) || collide("player", x, y - GRIDSIZE) || collide("level", x, y - GRIDSIZE)) {
				impactsAllowed.splice(impactsAllowed.indexOf("up"),1);
			}
			if (collide("npc", x + GRIDSIZE, y) || collide("player", x + GRIDSIZE, y) || collide("level", x + GRIDSIZE, y)) {
				impactsAllowed.splice(impactsAllowed.indexOf("right"),1);
			}
			if (collide("npc", x - GRIDSIZE, y) || collide("player", x - GRIDSIZE, y) || collide("level", x - GRIDSIZE, y)){
				impactsAllowed.splice(impactsAllowed.indexOf("left"),1);
			}

			// NPC movement
			// select random index then perform movement
			// TODO: use array constants here instead of the clumsy assign
			var rndMove:uint = Math.round(Math.random() * (impactsAllowed.length - 1));
			var rndMoveString:String = impactsAllowed[rndMove];
			switch (rndMoveString) {
				case "up":
				y -= GRIDSIZE;
				STEP++;
				break;
				case "down":
				y += GRIDSIZE;
				STEP++;
				break;
				case "left":
				x -= GRIDSIZE;
				STEP++;
				break;
				case "right":
				x += GRIDSIZE;
				STEP++;
				break;
			}
		}
		
		// this can be used to achieve goals such as pickup item or attack another entity, or seek escape route
		public function initPathedMovement(pointA:Point, pointB:Point):void {
			var source:Node = new Node(pointA.x, pointA.y, -1);
			var destNode:Node = new Node(pointB.x, pointB.y, -1);
			PATH = source.findPath(destNode, 'creature');
			PATH.reverse();
			trace("path size:" + PATH.length);
		}
		
		// get next point in the path
		// continue until depleted
		public function pathedMovementStep():Boolean {
			if (PATH.length != 0) {
				var newLoc:Node = PATH.pop();
				x = newLoc.x;
				y = newLoc.y;
				return true;
			} else {
				// path ended, now what?
				// something must be able to read the return here and act appropriately
				return false;
			}
		}
		
		// swarm cohort check
		public function checkSwarmInRoom():Boolean {
			return false;
		}
		
		// TODO: Monster Library
		// This needs to pull from some library of monsters, just like items do. 
		public function determineNPCType():void {
			NPCType = "orc";
			NPCLevel = 1;
		}
		
		// we might need this to be available for the player, when morphed
		public function setNPCStats(npcType:String, npcLevel:uint):void {
			// TODO: use Creature level class
			STATS[GC.STATUS_STR] = 14;
			STATS[GC.STATUS_AGI] = 10;
			STATS[GC.STATUS_INT] = 10;
			STATS[GC.STATUS_WIS] = 10;
			STATS[GC.STATUS_CHA] = 10;
			STATS[GC.STATUS_CON] = 14;			
		}
		
		
		public function setNPCDerivedStats(npcType:String, npcLevel:uint):void {
			// TODO: use Creature level class
			STATS[GC.STATUS_ATT] = 7;
			STATS[GC.STATUS_DEF] = 7;
			STATS[GC.STATUS_HP] = 15;
		}
		
		public function processCombat():void {
			// TODO: detect if foes are in adjacent tile based on collision
			// then pick one either randomly or based on previous picks
			// or perhaps even some form of 'threat' management
			// then smack!
			Dungeon.statusScreen.updateCombatText("The enemy hits for " + STATS[GC.STATUS_ATT] + " damage! (but not really)");
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
				checkCollision(GC.LAYER_NPC_TEXT,GC.COLLISION_NPC);
				checkCollision(GC.LAYER_NPC_TEXT,GC.COLLISION_PLAYER);
				checkCollision(GC.LAYER_LEVEL_TEXT, GC.COLLISION_WALL);

				
				// perform checks or check for events that would cause a path
				// let's start with player location check
				// perhaps if less than 10 in combined x+y direction, we make a path
				// unless a path length is already existing
				// this means that only one path can be running at a time
				// so we'll need another type of check
				

				// finally sync NPC with player
				STEP = Dungeon.player.STEP;
			}
		}
		
	}

}