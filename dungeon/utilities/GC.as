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
		
		// Status Screen constants
		public static const STATUS_SCREEN_DEFAULT_FONT_SIZE:int = 12;
		// item types
		public static const C_ITEM_ARMOR:uint = 0;
		public static const C_ITEM_WEAPON:uint = 1;
		public static const C_ITEM_JEWELRY:uint = 2;
		public static const C_ITEM_SCROLLS:uint = 3;	
		public static const C_ITEM_POTIONS:uint = 4;
		
		// Need to stick all the constants in here
		
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

		// derived constants for arrays
		public static const STATUS_ATT:uint = 10; // mostly strength + bit of agi + item stat attack
		public static const STATUS_ATT_MIN:uint = 17; // minimum attack value for RNG
		public static const STATUS_DEF:uint = 11; // mostly agi + bit of str + item stat
		public static const STATUS_CRITDEF:uint = 12; // bit of agi + armor, not sure how this works yet
		public static const STATUS_PER:uint = 13; // persuasion, cha + bit of str + bit of wis
		public static const STATUS_PEN:uint = 14; // armor + bit of str
		public static const STATUS_SPPOWER:uint = 15; // int
		public static const STATUS_SPLEVEL:uint = 16; // locked to level
		
	public function GC() {}

	}

}
