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
		/* TODO: change these to objects with types as keys, ex.:
		 * const FLOOR:Object = { forest: 40, stone: 240, brick: 440, marble: 640 }
		 * We'll need a global for location type at Dungeon level that will get updated from another object such as:
		 * const LOCATION_THRESHOLDS:Object { 4: forest, 8: cave, 12: brick, 16: marble } which does a level comparison and applies 
		 * appropriate location string to the tile objects
		*/
        public static const FLOOR:uint = 40;
		public static const HALL:uint = 41;
        public static const NWALL:uint = 60;
        public static const SWALL:uint = 80;
        public static const WWALL:uint = 100;
        public static const EWALL:uint = 120;

		// Walls
		public static const TOPWALL:uint = 60;
		public static const BOTTOMWALL:uint = 80;
		public static const LEFTWALL:uint = 100;
		public static const RIGHTWALL:uint = 120;

		// Doors
		public static const LEFTDOOR:uint = 180;
		public static const RIGHTDOOR:uint = 180;
		public static const TOPDOOR:uint = 180;
		public static const BOTTOMDOOR:uint = 180;

		//  Corners
		public static const TOPLEFTCORNER:uint = 140;
		public static const TOPRIGHTCORNER:uint = 160;
		public static const BOTTOMLEFTCORNER:uint = 140;
		public static const BOTTOMRIGHTCORNER:uint = 160;
				
		public static const DEBUG:uint = 20;
		public static const DEBUGRED:uint = 5;
		public static const DEBUGGREEN:uint = 6;		

		public static const WALLS:Object = {left:GC.LEFTWALL, right:GC.RIGHTWALL, top:GC.TOPWALL, bottom:GC.BOTTOMWALL};
		public static const DOORS:Object = {left:GC.LEFTDOOR, right:GC.RIGHTDOOR, top:GC.TOPDOOR, bottom:GC.BOTTOMDOOR};
		public static const CORNERS:Object = {TL:GC.TOPLEFTCORNER, TR:GC.TOPRIGHTCORNER, BL:GC.BOTTOMLEFTCORNER, BR:GC.BOTTOMRIGHTCORNER};
		
		// nonsolids
		public static const NONSOLIDS:Array = [GC.BOTTOMDOOR,GC.TOPDOOR,GC.LEFTDOOR,GC.BOTTOMDOOR, GC.FLOOR, GC.HALL]; // doors and floor
		public static const DOORSA:Array = [GC.BOTTOMDOOR,GC.TOPDOOR,GC.LEFTDOOR,GC.BOTTOMDOOR];
		
		// Status Screen constants
		public static const STATUS_SCREEN_DEFAULT_FONT_SIZE:int = 12;

		// item types
		public static const C_ITEM_ARMOR:uint = 0;
		public static const C_ITEM_WEAPON:uint = 1;
		public static const C_ITEM_JEWELRY:uint = 2;
		public static const C_ITEM_SCROLLS:uint = 3;	
		public static const C_ITEM_POTIONS:uint = 4;

		// item slots
		public static const SLOT_PRIMARY_WEAPON:String = 'PRIMARY_WEAPON';
		public static const SLOT_SECONDARY_WEAPON:String = 'SECONDARY_WEAPON';
		public static const SLOT_HEAD:String = 'SLOT_HEAD';
		public static const SLOT_BODY:String = 'SLOT_BODY';
		public static const SLOT_CHEST:String = 'SLOT_CHEST'; // deprecated
		public static const SLOT_LEGS:String = 'SLOT_LEGS'; // deprecated
		public static const SLOT_HANDS:String = 'SLOT_HANDS'; // deprecated
		public static const SLOT_WAIST:String = 'SLOT_WAIST'; // deprecated
		public static const SLOT_FEET:String = 'SLOT_FEET'; // deprecated
		public static const SLOT_SHOULDERS:String = 'SLOT_SHOULDERS'; // deprecated
		public static const SLOT_SPECIAL:String = 'SLOT_SPECIAL';
		
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
		public static const STATUS_STR:String = 'STR'; // attack modifier, small defense modifier, small persuasion
		public static const STATUS_AGI:String = 'AGI'; // small attack and big defense modifier
		public static const STATUS_INT:String = 'INT'; // spell attack and allowed spell memorization
		public static const STATUS_WIS:String = 'WIS'; // mana pool and spell defense and small persuasion
		public static const STATUS_CHA:String = 'CHA'; // persuasion success chance modifier
		public static const STATUS_CON:String = 'CON'; // HP
		public static const STATUS_MANA:uint = 9;
		public static const STATUS_HEALRATE:uint = 17;
		public static const STATUS_HEALSTEP:uint = 18;
		public static const STATUS_HPMAX:uint = 19;
		
		public static const STATUS_ATTRIBUTES:Array = [STATUS_STR, STATUS_AGI, STATUS_INT, STATUS_WIS, STATUS_CHA, STATUS_CON];

		// derived constants for arrays
		public static const STATUS_ATT:uint = 10; // mostly strength + bit of agi + item stat attack
		public static const STATUS_ATT_MIN:uint = 17; // minimum attack value for RNG
		public static const STATUS_DEF:uint = 11; // mostly agi + bit of str + item stat
		public static const STATUS_CRITDEF:uint = 12; // bit of agi + armor, not sure how this works yet
		public static const STATUS_PER:uint = 13; // persuasion, cha + bit of str + bit of wis
		public static const STATUS_PEN:uint = 14; // armor + bit of str
		public static const STATUS_SPPOWER:uint = 15; // int
		public static const STATUS_SPLEVEL:uint = 16; // locked to level
		public static const STATUS_DGLEVEL:uint = 17; // dungeon level
		
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
		
		// weapons for rendering
		public static const WEAPON_TILES:Object = 
		{
			DART: 1,
			SHURIKEN: 2,
			BOOMERANG: 3,
			WAND1: 4,
			WAND2: 5,
			WAND3: 6, 
			WAND4: 7,
			BO: 8,
			BO2: 9, 
			TRIDENT: 10,
			DAGGER: 11,
			MAIN_GAUCHE: 12,
			STILETTO: 13,
			MISERICORDE: 14,
			ROD: 15,
			KNIFE: 16,
			KNIFE2: 17, 
			THROWING_KNIFE: 18,
			KNIFE3: 19,
			AXE: 20,
			TWO_HEADED_AXE: 21,
			SHORTSWORD: 22,
			LONGSWORD: 23,
			RAPIER: 24,
			GLADIUS: 25,
			H1SWORD: 26, 
			SCIMITAR: 27,
			SHAMSHIR: 28,
			BROADSWORD: 29,
			BASTARDSWORD: 30,
			H2SWORD: 31,
			CLAYMORE: 32,
			NODACHI: 33,
			KATANA: 34,
			LAZERSWORD: 35,
			SPEAR: 36,
			SPEAR2: 37,
			BARDICHE: 38,
			SPEAR4: 39, // row 2 stars below
			FLAMBERGE: 40,
			MAUL: 41,
			GLAIVE: 42, 
			HALBERD: 43,
			PICKAXE: 44,
			SICKLE: 45,
			HOOK1: 46,
			HOOK2: 47,
			BATTLEAXE: 48,
			THROWING_AXE: 49,
			MACE: 50,
			MORNINGSTAR: 51,
			WARHAMMER: 52,
			CLUB: 53,
			WHIP: 54,
			STICK: 55,
			STICK2: 56, 
			MUSKET: 57,
			WHIP2: 58,
			BOW: 59,
			LONGBOW: 60,
			SHORTBOW: 61,
			COMPOUNDBOW: 62,
			SLING: 63,
			CROSSBOW: 64
		}
		
		// armor for rendering
		public static const ARMOR_TILES:Object = 
		{
			JACKET: 30,
			ARMOR_JACKET: 25, 
			CHAIN_MAIL: 23,
			SCALE_MAIL: 22,
			PLATE_MAIL: 16,
			ROBE: 35,
			HAT: 55,
			SKULLCAP: 53,
			HELMET: 59
		}
		
		// offset will always be GRIDSIZE by default
		public static const SPLAT_OFFSET:uint = GRIDSIZE;
		public static const SPLAT_BLOOD:uint = GRIDSIZE;

		// DECOR
		public static const DECOR_STATUE:String = 'STATUE';
		public static const DECOR_STAIRS_UP:String = 'STAIRS_UP';
		public static const DECOR_STAIRS_DOWN:String = 'STAIRS_DOWN';
		public static const DECOR_THRONE:String = 'THRONE';
		public static const DECOR_TABLE:String = 'TABLE';

		// DECOR SOLIDS
		public static const DECOR_SOLIDS:Object = 
		{
			STATUE: true,
			STAIRS_UP: false,
			STAIRS_DOWN: false,
			THRONE: false,
			TABLE: true
		}
		
		public function GC() {}
	}

}
