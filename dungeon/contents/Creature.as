package dungeon.contents
{
	import dungeon.contents.Armor;
	import dungeon.contents.Item;
	import dungeon.contents.Weapon;
	import flash.utils.Dictionary;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.tweens.motion.LinearMotion;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import dungeon.utilities.*;
	import dungeon.structure.Point;
	import dungeon.structure.Utils;

	/**
	 * ...
	 * @author MM
	 */
	public class Creature extends Entity
	{
		// creature size, used for collision
		private const GRIDSIZE:int = GC.GRIDSIZE;
		public var POSITION:Point = new Point(0,0);

		// unique ID, used for path targets? and who knows what else
		public var UNIQID:uint = 0;
		public var creatureXML:XML;

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

		public var SKILLS:Array = new Array();
		
		public var ARMOR:Array = new Array();
		public var WEAPONS:Array = new Array();
		public var SCROLLS:Array = new Array();
		public var POTIONS:Array = new Array();
		public var JEWELRY:Array = new Array();
		// this must correspond to the constants 0,1,2,3,4 so we can assign items properly
		public var ITEMS:Array = [ARMOR, WEAPONS];

		// Stat Array
		public var STATS:Array = new Array();		
		public var PREFERRED_STATS:Array = new Array();
		public var ALIGNMENT:String = 'neutral'; // hardcoding for now
		
		// # of Actions a creature can take per turn  and their counter, 1 by default, increased by special abilities and items
		public var ACTIONS_ALLOWED:uint = 1;
		public var ACTIONS_TAKEN:uint;
		public var SINGLE_USE_ACTIONS:Dictionary = new Dictionary();
		
		// motion FX
		private var _motionTween:LinearMotion;
		
		// very basic constructor here ... 
		public function Creature() {
			var uniqidSeed:Number = Math.random() * 10000000000;
			UNIQID = uint (uniqidSeed);	
			
			_motionTween = new LinearMotion(onMotionComplete);
			addTween(_motionTween);
		}
		
		public function onMotionComplete():void {
			x = _motionTween.x;
			y = _motionTween.y;	
			if (this is Player) {
				// completion of player movement advances the world
				Dungeon.STEP.globalStep++;
			} else if (this is NPC) {
				Dungeon.STEP.npcSteps++;
			}
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

		public function getEquippedItem(itemType:uint, itemSlot:String):resultItem {
			var returnVal:resultItem = new resultItem(false);
			for each (var item:* in ITEMS[itemType]) {
				if (item.EQUIPPED == true && item.slot == itemSlot) {
					returnVal.item = item;
					returnVal.found = true;
				}
			}			
			return returnVal;
		}

		public function move(newX:Number, newY:Number):void {
			if (!_motionTween.active) {
				_motionTween.setMotion(x, y, newX, newY, 0.03);
			}
		}
		
		// we may want callbacks and such, so put this on creature
		public function throwItem(path:Array, item:*):void {
			Dungeon.level.throwItem(path, item);
			// now we increase STEP?
		}
		
		/**
		 * Original plan: skills iterate through skill array and execute as needed. Everyone starts off with 'regen' skill which calls regen.
		 * Each skill will have its own function; skills may or may not break off into own class, maybe static? Thing is, skills will interact 
		 * so closely with Creature, they'll probably need access to creature properties A LOT. Something to think about later; for now, all will be 
		 * in Creature class itself.
		 * 
		 * Now, how did this work again? :/
		 * 
		 * Actually, some creatures won't regen. This is actually immediately in our favor - they simply won't have 'regen' in their skill array. I'm brilliant!
		 */
		public function processSkills():void {
			// foreach passive skill
			// foreach active skill, make a choice (or don't) to act - behavior should however be contained to that action, since it hinges on potentially many 
			// different factors, which would be a truly heinous IF statement over time
			// as it is, we'll call ALL the skills, but skip the actives if all available actions taken was already done
			// the downside to this is that creatures may not make the optimal choice for their situation, so we'll need some sort of weight added in advance
			for each (var skill:String in SKILLS) {
				var skillFn:String = "process" + skill;
				this[skillFn]();
			}
		}
			
		public function processSummonSelf():void {
			if (!amIDone()) {
				//Dungeon.level.summonNPC(String(creatureXML.specialModifier), POSITION);
			}
		}
		
		public function processMoveAgain():void {
			if (SINGLE_USE_ACTIONS['moveAgain'] != true) {
				ACTIONS_ALLOWED++;
				SINGLE_USE_ACTIONS['moveAgain'] = true;
			}
		}
		
		public function processCastFireball():void {
			if (!amIDone()) {
				//processRangedCombat(Fireball); // Fireball will need to be a prefetched magic item type
			}
		}
		
		public function processThrowItem():void {
			if (!amIDone()) {
				//processRangedCombat(item); // item will need to be a prefetched physical item type
			}			
		}
		
		public function processThrowPotion():void {
			if (!amIDone()) {
				//processRangedCombat(potion); // potion will need to be a prefetched potion type
			}
		}
		
		public function processThrowWeapon():void {
			if (!amIDone()) {
				var thrownWeapon:Weapon = iHaveThrownWeapon();
				if (thrownWeapon != null) {
					processRangedCombat(thrownWeapon);
				}
			}
		}

		// this isn't quite right; passives (or is it reactives?) have to act differently (?)
		public function processTough():void {
			
		}
		
		public function processCastPoisonBreath():void {
			if (!amIDone()) {
				//processRangedCombat(poisonBreath); // poisonBreath will be prefetched magic type
			}
		}
		
		public function processSquad():void {
			
		}
		
		/**
		 * rangedItemType determines what sort of projectile to throw, 
		 * since this will be the combats for magic (fireballs etc), firebreathing, etc.
		 * @param	rangedItemType
		 */
		public function processRangedCombat(rangedItemType:Item):void {
			var shortestDistance:Number = 1000;
			var currentDistance:Number = 0;
			var nearestNPC:NPC;
			for each (var creature:NPC in Dungeon.level.NPCS) {
				// TODO: we need an alignment check
				currentDistance = distanceToPoint(creature.x, creature.y);
				if (
					(creature.x != x && creature.y != y) && 
					(currentDistance < shortestDistance)) 
				{
					nearestNPC = creature;
					shortestDistance = currentDistance;
					Dungeon.statusScreen.updateCombatText(creatureXML.@name + " thinks " + nearestNPC.npcType + " is closest.");
					var freeToFire:Object = Utils.traceLine(x, y, nearestNPC.x, nearestNPC.y);
					
					if (freeToFire.success) {
						//Dungeon.statusScreen.updateCombatText(npcType + " is clear to fire on " + nearestNPC.npcType + ".");
						// actually process the throw and damage done
						throwItem(freeToFire.path, rangedItemType); // this will take an itemType at some point?
						ACTIONS_TAKEN++;
						Dungeon.STEP.npcSteps++;
						break;
					}
				} else {
					Dungeon.statusScreen.updateCombatText(creatureXML.@name + " doesn't see anything in range.");
				}
			}
		}
		
		/**
		 * TODO: test all this :D
		 * TODO: consider moving to Player class, since creatures will not have leveling; we could then throw out all the player checks
		 * TODO: maybe consider changing creatureXML to be playerXML and npcXML, too. they're starting to diverge more and more
		 */
		public function updateIntrinsicStats(player:Boolean=false):void
		{
			// TODO: calculate level scale somehow. canned from XML? Algorithm?
			// TODO AGAIN: throw out leveling entirely; skill-based advancement only
			var expectedLevel:uint = 1;
			var levelOne:uint = 20;
			var calculatedXP:uint = levelOne;

			while (calculatedXP < STATS[GC.STATUS_XP]) {
				calculatedXP = calculatedXP * 2;
				expectedLevel += 1;
			}
				
			if (STATS[GC.STATUS_LEVEL] < expectedLevel)
			{
				var preferredStats:Array = creatureXML.preferredStats.split(",");
				var defaultIncreaseChance:uint = 25;
				var chances:Dictionary = new Dictionary();
				chances[GC.STATUS_STR] = defaultIncreaseChance;
				chances[GC.STATUS_AGI] = defaultIncreaseChance;
				chances[GC.STATUS_CON] = defaultIncreaseChance;
				chances[GC.STATUS_INT] = defaultIncreaseChance;
				chances[GC.STATUS_WIS] = defaultIncreaseChance;
				chances[GC.STATUS_CHA] = defaultIncreaseChance;
				for each (var stat:String in preferredStats) {
					chances[stat] = 2;
				}
				
				// Ding!
				STATS[GC.STATUS_LEVEL]++;

				if (player) {
					Dungeon.statusScreen.updateCombatText("Welcome to level " + expectedLevel + "!");
				}
				// TODO: check if an "attributes" array in GC that will collect these would be useful
				for each (var att:String in GC.STATUS_ATTRIBUTES) {
					if ((Math.random() * 100) < chances[att])
						STATS[att] += 1;
				}

				updateDerivedStats();
			}
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
									case "SLOT_LEGS":
										legSlot = item;
									break;
									case "SLOT_HEAD":
										headSlot = item;
									break;
									case "SLOT_CHEST":
										chestSlot = item;
									break;
									case "SLOT_HANDS":
										handSlot = item;
									break;
									case "SLOT_FEET":
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
			// STATS[GC.STATUS_HPMAX] = STATS[GC.STATUS_HPMAX]; // TODO + items and FX, * level multiplier 
			if (init) {
				STATS[GC.STATUS_HP] = STATS[GC.STATUS_CON]; // plus items
				STATS[GC.STATUS_MANA] = STATS[GC.STATUS_WIS] * 10; // plus items
				STATS[GC.STATUS_HPMAX] = STATS[GC.STATUS_CON]; // + items and FX
			}
		}	
		
		// convenience handler for being done with this turn
		public function amIDone():Boolean {
			if (ACTIONS_TAKEN == ACTIONS_ALLOWED) return true;
			else return false;
		}
		
		/**
		 * Gets lowest attack value weapon for throwing, if available. otherwise null.
		 * @return
		 */
		public function iHaveThrownWeapon():Weapon {
			if (WEAPONS.length <= 1) {
				// do not throw away your last weapon
				return null;
			}
			var returnedWeapon:Weapon;
			var attack:Number = 9000;
			for each (var weapon:Weapon in WEAPONS) {
				// TODO: implement ranged weapons
				// currently retrieves weapon with lowest attack to throw
				if (weapon.attack < attack) {
					returnedWeapon = weapon;
					attack = weapon.attack;
				}
				return returnedWeapon;
			}
			return null;
		}
		
		/**
		 * TODO: get potion by dmg amount, I suppose
		 * @return
		 */
		public function iHaveThrowingPotion():Potion {
			return null;
		}
		
		override public function update():void {
			if (_motionTween.active) {
				x = _motionTween.x;
				y = _motionTween.y;
			}			
		}
		
	}
}