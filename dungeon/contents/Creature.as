package dungeon.contents
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
		private const GRIDSIZE:int = GC.GRIDSIZE;
		
		// unique ID, used for path targets? and who knows what else
		public var UNIQID:uint = 0;

		// Collision stats
		// Both collision array and type need to be arrays so that collisions can stack.
		// Currently whatever is checked for collision last overrides other values.
		// Since nothing can really stack (creature on creature or creature on wall) that is ok for COLLISION
		// but CCOLLISION_TYPE is a scalar so will only count for the most recent collision check
		// Why am I using it again? Too sleepy to figure it out, but progress!
		public var COLLISION:Array = [0, 0, 0, 0, 0];
		public var COLLISION_TYPE:Array = [];
		public var MOVE_DIR:int = 0;
		public var COLLISION_STORE:Array = [];

		public var ARMOR:Array = new Array();
		public var WEAPONS:Array = new Array();
		public var SCROLLS:Array = new Array();
		public var POTIONS:Array = new Array();
		public var JEWELRY:Array = new Array();
		// this must correspond to the constants 0,1,2,3,4 so we can assign items properly
		public var ITEMS:Array = [ARMOR, WEAPONS, SCROLLS, POTIONS, JEWELRY];

		// Stat Array
		public var STATS:Array = new Array();		
		public var ALIGNMENT:String = 'neutral'; // hardcoding for now
		
		// # of Actions a creature can take per turn  and their counter
		public var ACTIONS:uint;
		public var ACTION_COUNTER:uint;
		
		// very basic constructor here ... 
		public function Creature() {
			var uniqidSeed:Number = Math.random() * 10000000000;
			UNIQID = uint (uniqidSeed);			
		}
		
		// regen health if appropriate timestep and health < max
		public function processRegen():void {
			STATS[GC.STATUS_HEALSTEP]++;
			if ((STATS[GC.STATUS_HEALSTEP] >= STATS[GC.STATUS_HEALRATE]) &&
			   (STATS[GC.STATUS_HP] < STATS[GC.STATUS_HPMAX])) {
				STATS[GC.STATUS_HP]++;
				STATS[GC.STATUS_HEALSTEP] = 0;
			}
		}
		
		// all this does is populate all directions in which this creature is surrounded by entities
		public function checkCollision(collisionEntity:String, collisionConstant:int):void {
			if (collide(collisionEntity, x, y + GRIDSIZE)) {
				COLLISION[GC.DIR_DOWN] = collisionConstant;
				COLLISION_TYPE.push(collisionConstant);
			}
			if (collide(collisionEntity, x, y - GRIDSIZE)) {
				COLLISION[GC.DIR_UP] = collisionConstant;
				COLLISION_TYPE.push(collisionConstant);
			}
			if (collide(collisionEntity, x + GRIDSIZE, y)) {
				COLLISION[GC.DIR_RIGHT] = collisionConstant;
				COLLISION_TYPE.push(collisionConstant);
			}
			if (collide(collisionEntity, x - GRIDSIZE, y)){
				COLLISION[GC.DIR_LEFT] = collisionConstant;
				COLLISION_TYPE.push(collisionConstant);
			}			
		}

		// utility functions for quick equipment retrieval
		// should this return an array for multi-weapons
		public function getEquippedItemByItem(newItem:*):resultItem {
			var returnVal:resultItem = new resultItem(false);
			for each (var item:* in ITEMS[newItem.ITEM_TYPE]) {
				if (item.EQUIPPED == true && item.slot == newItem.slot) {
					returnVal.item = item;
					returnVal.found = true;
				}
			}			
			return returnVal;
		}

		public function getEquippedItem(itemType:uint, itemSlot:uint):resultItem {
			var returnVal:resultItem = new resultItem(false);
			for each (var item:* in ITEMS[itemType]) {
				if (item.EQUIPPED == true && item.slot == itemSlot) {
					returnVal.item = item;
					returnVal.found = true;
				}
			}			
			return returnVal;
		}

		// TODO: armor doesn't seem to be working for PLAYER
		// stats are a combination of intrinsics, equipped items and special effects (potion with temporary boosts, being on fire, wet, hungry, etc)
		// the first two are relatively easy to calculate, the last will require iterating through a stack of "effects" currently on creature
		public function updateDerivedStats(init:Boolean=false):void {
			// this will vary by class and equipment type later
			// we need code in here that deals with the fact that not all slot are filled
			var weapon:Weapon = new Weapon();
			// unarmed defaults
			weapon.attack = 3;
			weapon.defense = 3;
			weapon.pen = 0.3;
			var headSlot:Armor = new Armor();
			var chestSlot:Armor = new Armor();
			var legSlot:Armor = new Armor();
			var handSlot:Armor = new Armor();
			var feetSlot:Armor = new Armor();
			
			// also, this needs to pull in all current armor and weapons, not to mention enchantments etc.
			for each (var itemAr:Array in ITEMS) {
				for each (var item:* in itemAr) {
					if (item.EQUIPPED) {
						switch(item.ITEM_TYPE) {
							case GC.C_ITEM_ARMOR:
								switch(item.slot) {
									case "LEGS":
										legSlot = item;
									break;
									case "HEAD":
										headSlot = item;
									break;
									case "CHEST":
										chestSlot = item;
									break;
									case "HANDS":
										handSlot = item;
									break;
									case "FEET":
										feetSlot = item;
									break;
								}
							break;
							case GC.C_ITEM_JEWELRY:
							break;
							case GC.C_ITEM_POTIONS:
							break;
							case GC.C_ITEM_SCROLLS:
							break;
							case GC.C_ITEM_WEAPON:
								weapon = item;
							break;
						}
					}
				}
			}

			// weapon and stat for att and def are averaged, then armor is added
			// I am not sure if that makes sense, but it comes out to a sword having def. about equal to a chain chestplate
			// I guess natural stat max is 20
			// New idea: everything that relies on stats for boosts should only do so above 10pts of said stat, as 10pts is the baseline
			// New idea 2: strength and agility are %-based (of 10) multipliers on weapon attack and defence. Armor attack and defence is unaffected by stats.
			// New idea 3: weapon attack modifier should max out at 70% if str is 20. So every pt should be an extra 7%
			var attStatModifier:Number = 1 + ((STATS[GC.STATUS_STR] - 10) * 0.07) + (0.02 * (STATS[GC.STATUS_AGI] - 10));
			var defStatModifier:Number = 1 + ((STATS[GC.STATUS_AGI] - 10) * 0.7) + (0.02 * (STATS[GC.STATUS_STR] - 10));
			STATS[GC.STATUS_ATT] = Math.floor((attStatModifier * weapon.attack) + headSlot.attack + chestSlot.attack + legSlot.attack + handSlot.attack + feetSlot.attack); // plus items
			//STATS[GC.STATUS_ATT] = Math.floor(((STATS[GC.STATUS_STR] - 10) + weapon.attack + (0.2 * (STATS[GC.STATUS_AGI] - 10))) + headSlot.attack + chestSlot.attack + legSlot.attack + handSlot.attack + feetSlot.attack); // plus items
			STATS[GC.STATUS_ATT_MIN] = Math.ceil(STATS[GC.STATUS_ATT] / 2); // upper limit of half of calculated
			STATS[GC.STATUS_DEF] = Math.floor((defStatModifier * weapon.defense) + headSlot.defense + chestSlot.defense + legSlot.defense + handSlot.defense + feetSlot.defense); // plus items
			//STATS[GC.STATUS_DEF] = Math.floor(((STATS[GC.STATUS_AGI] - 10) + (0.2 * (STATS[GC.STATUS_STR] - 10)) + weapon.defense) + headSlot.defense + chestSlot.defense + legSlot.defense + handSlot.defense + feetSlot.defense); // plus items
			STATS[GC.STATUS_CRITDEF] = Math.floor((STATS[GC.STATUS_AGI] * 0.2) + headSlot.crit + chestSlot.crit + legSlot.crit + handSlot.crit + feetSlot.crit);
			STATS[GC.STATUS_PEN] = weapon.pen + (0.02 * (STATS[GC.STATUS_STR] - 10));
			STATS[GC.STATUS_PER] = STATS[GC.STATUS_CHA] / 20 + (0.01 * (STATS[GC.STATUS_STR] + STATS[GC.STATUS_WIS] - 20));
			STATS[GC.STATUS_SPPOWER] = Math.floor(STATS[GC.STATUS_INT]/10); // straight dmg multiplier for spells, plus items; items should have % boosts, maybe lesser and greater spellpower being 5 and 10% boosts each?
			STATS[GC.STATUS_SPLEVEL] = STATS[GC.STATUS_LEVEL]; // TODO plus items. should this be alterable?
			STATS[GC.STATUS_HPMAX] = STATS[GC.STATUS_HPMAX]; // TODO + items and FX, * level multiplier 
			if (init) {
				STATS[GC.STATUS_HP] = STATS[GC.STATUS_CON]; // plus items
				STATS[GC.STATUS_MANA] = STATS[GC.STATUS_WIS] * 10; // plus items
				STATS[GC.STATUS_HPMAX] = STATS[GC.STATUS_CON]; // + items and FX
			}
		}		
	}
}