package dungeon.utilities
{
	import net.flashpunk.FP;

	/**
	 * ...
	 * @author dolgion
	 */
	public class GC
	{
		/*
		 *  Game Constants 
		 */
		
		public static const FOGOFWAR_LAYER:uint = 5;
		public static const TEXTBOXES_LAYER:uint = 15;
		public static const OVERlAY_LAYER:uint = 17;
		public static const NPC_LAYER:uint = 20;
		public static const PLAYER_LAYER:uint = 20;
		public static const ITEM_LAYER:uint = 25;
		public static const DECOR_LAYER:uint = 27;
		public static const LEVEL_LAYER:uint = 50;

		// World constants like map (dungeon) size, view width, gridsize, gravity, speed of light ... etc.
		public static const GRIDSIZE:uint = 32;
		public static const CAMERA_OFFSET:uint = 8 * GRIDSIZE;
		public static const PLAYER_MOVEMENT_SPEED:uint = 32;
		public static const MAP_WIDTH:uint = 1216; // actual map size
		public static const MAP_HEIGHT:uint = 800;
		public static const VIEW_WIDTH:uint = 1216;
		public static const VIEW_HEIGHT:uint = 800;
		
		// Tilemap tile location constants
        public static const FLOOR:uint = 7;
		public static const HALL:uint = 3;
        public static const NWALL:uint = 8;
        public static const SWALL:uint = 10;
        public static const WWALL:uint = 11;
        public static const EWALL:uint = 9;

		// Walls
		public static const LEFTWALL:uint = 11;
		public static const RIGHTWALL:uint = 9;
		public static const TOPWALL:uint = 8;
		public static const BOTTOMWALL:uint = 10;

		// Doors
		public static const LEFTDOOR:uint = 15;
		public static const RIGHTDOOR:uint = 13;
		public static const TOPDOOR:uint = 12;
		public static const BOTTOMDOOR:uint = 14;

		//  Corners
		public static const TOPLEFTCORNER:uint = 19;
		public static const TOPRIGHTCORNER:uint = 16;
		public static const BOTTOMLEFT:uint = 18;
		public static const BOTTOMRIGHT:uint = 17;
				
		public static const DEBUG:uint = 2;
		public static const DEBUGRED:uint = 5;
		public static const DEBUGGREEN:uint = 6;		
		
		// Status Screen constants
		public static const STATUS_SCREEN_DEFAULT_FONT_SIZE:int = 12;

		// item types
		public static const C_ITEM_ARMOR:uint = 0;
		public static const C_ITEM_WEAPON:uint = 1;
		public static const C_ITEM_JEWELRY:uint = 2;
		public static const C_ITEM_SCROLLS:uint = 3;	
		public static const C_ITEM_POTIONS:uint = 4;

		// item slots
		public static const SLOT_PRIMARY_WEAPON:uint = 1;
		public static const SLOT_SECONDARY_WEAPON:uint = 2;
		public static const SLOT_HEAD:uint = 3;
		public static const SLOT_CHEST:uint = 4;
		public static const SLOT_LEGS:uint = 5;
		public static const SLOT_HANDS:uint = 6;
		public static const SLOT_WAIST:uint = 7;
		public static const SLOT_FEET:uint = 8;
		public static const SLOT_SHOULDERS:uint = 9;
		public static const SLOT_SPECIAL:uint = 10;
		
		public static const SLOT_DESCRIPTIONS:Object = 
		{
			SLOT_PRIMARY_WEAPON: "Primary Weapon",
			SLOT_SECONDARY_WEAPON: "Secondary Weapon",
			SLOT_HEAD: "Helmet",
			SLOT_CHEST: "Chestpiece",
			SLOT_LEGS: "Greaves",
			SLOT_HANDS: "Gloves",
			SLOT_WAIST: "Belt",
			SLOT_FEET: "Boots",
			SLOT_SHOULDERS: "Shoulders",
			SLOT_SPECIAL: "Special"
		};
		
		// Directions
		public static const DIR_UP:int = 1;
		public static const DIR_RIGHT:int = 2;
		public static const DIR_DOWN:int = 3;
		public static const DIR_LEFT:int = 4;
		public static const DIR_UP_TEXT:String = "Up";
		public static const DIR_RIGHT_TEXT:String = "Right";
		public static const DIR_DOWN_TEXT:String = "Down";
		public static const DIR_LEFT_TEXT:String = "Left";
		public static const NOOP:String = "Space";
		
		// Direction modifiers
		public static const DIR_MOD_X:Array = [0, 0, 1, 0, -1];
		public static const DIR_MOD_Y:Array = [0, -1, 0, 1, 0];
		
		// Collisions
		public static const COLLISION_NONE:int = 0;
		public static const COLLISION_WALL:int = 1;
		public static const COLLISION_DOOR:int = 2;
		public static const COLLISION_NPC:int = 3;
		public static const COLLISION_PLAYER:int = 4;

		// Layer types
		public static const LAYER_NPC:int = 1;
		public static const LAYER_LEVEL:int = 2;
		public static const LAYER_PLAYER:int = 3;
		public static const LAYER_ITEM:int = 4;
		public static const LAYER_NPC_TEXT:String = "npc";
		public static const LAYER_LEVEL_TEXT:String = "level";
		public static const LAYER_PLAYER_TEXT:String = "player";
		
		// Stat constants for arrays
		public static const STATUS_LEVEL:uint = 0;
		public static const STATUS_XP:uint = 1;
		public static const STATUS_HP:uint = 2; // CON + bit of STR + bit of AGI
		public static const STATUS_STR:uint = 3; // attack modifier, small defense modifier, small persuasion
		public static const STATUS_AGI:uint = 4; // small attack and big defense modifier
		public static const STATUS_INT:uint = 5; // spell attack and allowed spell memorization
		public static const STATUS_WIS:uint = 6; // mana pool and spell defense and small persuasion
		public static const STATUS_CHA:uint = 7; // persuasion success chance modifier
		public static const STATUS_CON:uint = 8; // HP
		public static const STATUS_MANA:uint = 9;
		public static const STATUS_HEALRATE:uint = 17;
		public static const STATUS_HEALSTEP:uint = 18;
		public static const STATUS_HPMAX:uint = 19;

		// derived constants for arrays
		public static const STATUS_ATT:uint = 10; // mostly strength + bit of agi + item stat attack
		public static const STATUS_ATT_MIN:uint = 17; // minimum attack value for RNG
		public static const STATUS_DEF:uint = 11; // mostly agi + bit of str + item stat
		public static const STATUS_CRITDEF:uint = 12; // bit of agi + armor, not sure how this works yet
		public static const STATUS_PER:uint = 13; // persuasion, cha + bit of str + bit of wis
		public static const STATUS_PEN:uint = 14; // armor + bit of str
		public static const STATUS_SPPOWER:uint = 15; // int
		public static const STATUS_SPLEVEL:uint = 16; // locked to level
		
		public static const KEYS:Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
		
		// NPC statuses
		public static const NPC_STATUS_IDLE:uint = 0;
		public static const NPC_STATUS_SEEKING_OBJECT:uint = 1;
		public static const NPC_STATUS_EQUIPPING_ITEM:uint = 2;
		public static const NPC_STATUS_USING_ITEM:uint = 3;
		public static const NPC_STATUS_ATTACKING_NPC:uint = 4;
		public static const NPC_STATUS_ATTACKING_PLAYER:uint = 5;
		public static const NPC_STATUS_FLEEING:uint = 6;
		
		public static const ALIGNMENTS:Array = ['neutral', 'good', 'evil'];
		
		public function GC() {}
	}

}
