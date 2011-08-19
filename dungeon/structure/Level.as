package dungeon.structure
{
	import dungeon.contents.Armor;
	import dungeon.contents.Item;
	import dungeon.contents.Weapon;
	import dungeon.contents.Potion;
	import dungeon.contents.NPC;
	import dungeon.utilities.LevelInfoHolder;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.utils.Draw;	
	import dungeon.structure.Room;
	import dungeon.structure.Door;
	import dungeon.structure.Point;
	import dungeon.structure.Utils;
	import dungeon.structure.Node;
	import dungeon.structure.Nodemap;
	import dungeon.utilities.GC;

	/**
	 * ...
	 * @author MM
	 */
	public class Level extends Entity
	{
		[Embed(source = '../../assets/tilemap.png')] private const TILEMAP:Class;
		public var _dungeonmap:Tilemap;
		public var _nodemap:Nodemap;
		public var _grid:Grid;

		private const _roomsMax:int = 20;
		private const _roomsBigChance:int = 2; // 20% chance, 2 out of 10
		private const _roomsBigMax:int = 2;
		private const _roomLimitMax:int = 10;
		private const _roomLimitNormal:int = 6;
		Input.define("DownLevel", Key.PAGE_DOWN);
		Input.define("UpLevel", Key.PAGE_UP);
		Input.define("L", Key.L);

		public var _roomsA:Array = [];
		private var _rooms:int = 0;
		public var ITEMS:Array = [];
		public var NPCS:Array = [];

		// Level game data
		public var dungeonDepth:uint = 1;

		// frequency array for levels; will probably need to be dynamic
		// this rudimentary distribution array should work for now
		public var ITEM_GEN:Object = {
			0: generateWeapon,
			1: generateWeapon,
			2: generateArmor,
			3: generateArmor,
			4: generatePotion,
			5: generatePotion,
			6: generatePotion
			/*
			7: generateScroll,
			8: generateScroll,
			9: generateScroll,
			10: generateJewelry,
			11: generateWand,
			12: generateGem,
			13: generateMoney,
			14: generateUnique */
		}
		
        public static const FLOOR:int = 7;
		public static const HALL:int = 3;
        public static const NWALL:int = 8;
        public static const SWALL:int = 10;
        public static const WWALL:int = 11;
        public static const EWALL:int = 9;
		// top right bottom left
		public static const DEBUG:int = 2;

		public static const WALLS:Object = {left:11, right:9, top:8, bottom:10};
		public static const DOORS:Object = {left:15, right:13, top:12, bottom:14};
		public static const CORNERS:Object = {TL:19, TR:16, BL:18, BR:17};
		
		// nonsolids
		public static const NONSOLIDS:Array = [7,3,12,13,14,15]; // doors and floor
		public static const DOORSA:Array = [12,13,14,15];
		
		public static const DEBUGR:int = 5;
		public static const DEBUGG:int = 6;

		
		public var _step:int = 0;
		
		// temporary monster generation
		public static var MONSTARS:Array = ["paladin","rogue","warrior","monk","mage","fighter","sorcerer","wizard","shapeshifter","teleporter","ranger","vampire","archer"];
		
		public function Level() 
		{
			FP.console.enable();
			drawLevel();
			// init level tilemap and collision grid mask
			
			// TEH LOGIK
			
			/* This is going to be an attempt at creating an Architect type level-builder,
			 * in which the level is created organically by an "agent" that would start out
			 * in a room, hollow out a corridor to the next room, create the next room, and so on,
			 * returning to connect this and that room according to random whim. No quadrants or
			 * level division will be used.
			 * There are some assumptions/wishes:
			 * - not necessarily looped levels
			 * - dead ends are allowed but not too many for playability
			 * - only one or two BIG rooms, this is a dungeon afterall
			 * - FUTURE: dungeons can be irregular shapes, but only 2 or 3 pixels out (or in) from rectangular
			 * - FUTURE: there will be some premades
			 * - FUTURE: there will be hidden passages to secret rooms (right now algorithm will try to connect all, so this will be a post-generation thing)
			 */	
		}

		public function saveLevel():LevelInfoHolder {
			var levelHolder:LevelInfoHolder = new LevelInfoHolder();
			
			// save dungeonmap
			levelHolder.structure = _dungeonmap.saveToString();
			
			// save grid
			levelHolder.collisions = _grid.saveToString();
			
			// save nodemap
			
			// world remove first, clear array second
			for each (var item:Item in ITEMS) {
				if (item is Weapon) {
					var weaponItem:Weapon =  item as Weapon;
					var weaponCopy:Weapon = weaponItem.selfCopy();
					levelHolder.items.push(weaponCopy);
				} else if (item is Armor) {
					var armorItem:Armor = item as Armor;
					var armorCopy:Armor = armorItem.selfCopy();
					levelHolder.items.push(armorCopy);
				}
				FP.world.remove(item);
			}
			ITEMS = new Array();
			
			// save creatures; these need to be copy methods
			for each (var npc:NPC in NPCS) {
				var npcCopy:NPC = npc.selfCopy();
				levelHolder.creatures.push(npcCopy);
				FP.world.remove(npc);
			}
			NPCS = new Array();
			
			// save decor
			
			return levelHolder;
		}
		
		public function loadLevel(levelHolder:LevelInfoHolder):void {
			
			_dungeonmap.loadFromString(levelHolder.structure);
			graphic = _dungeonmap;
			
			_grid.loadFromString(levelHolder.collisions);
			mask = _grid;

			layer = GC.LEVEL_LAYER;
			type = "level";
			
			_nodemap.load(_dungeonmap);
			
			// item load
			ITEMS = new Array();
			
			// world-remove first, array removal second
			for each (var item:Item in levelHolder.items) {
				if (item is Weapon) {
					var weaponItem:Weapon = item as Weapon;					
					var weaponCopy:Weapon = weaponItem.selfCopy();
					ITEMS.push(weaponCopy);
					FP.world.add(weaponCopy);
				} else if (item is Armor) {
					var armorItem:Armor = item as Armor;
					var armorCopy:Armor = armorItem.selfCopy();
					ITEMS.push(armorCopy);
					FP.world.add(armorCopy);
				}
			}
			levelHolder.items = new Array();
			// now creatures
			for each (var npc:NPC in levelHolder.creatures) {
				var npcCopy:NPC = npc.selfCopy();
				NPCS.push(npcCopy);
				FP.world.add(npcCopy);
			}
			levelHolder.creatures = new Array();
		}
		
		private function drawLevel():void {
			_roomsA = [];
			_rooms = 0;

			_dungeonmap = new Tilemap(TILEMAP, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
			_dungeonmap.setRect(0,0,Dungeon.TILESX, Dungeon.TILESY, DEBUG); 
			graphic = _dungeonmap;
			layer = GC.LEVEL_LAYER;
			
			_grid = new Grid(Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT,0,0);
			mask = _grid;
			type = "level";
			
			drawRooms();
			_nodemap = new Nodemap(_dungeonmap, _roomsA);
			
			// if we are drawing solid clutter here, we'll need to re-init the _nodemap
			
			drawGrid();

			createItems();
			
			placeItems();
			
			placePlayer();
			
			createAndPlaceNPCs();
		}
		
		private function drawRooms():void {
			var _bigRoomCount:int = 0;
			var width:int = 0;
			var height:int = 0;
			var _bigRoomRand:int = 0;
			var x:int = 0;
			var y:int = 0;

			for (var i:int = 0; i < _roomsMax; i++) {
				_bigRoomRand = Math.round(Math.random() * 10);
				if ((_bigRoomRand < _roomsBigChance) && (_bigRoomCount < _roomsBigChance)) {
					width = Math.round(Math.random() * _roomLimitMax + 3);
					height = Math.round(Math.random() * _roomLimitMax + 3);
					_bigRoomCount++;
				} else {
					width = Math.round(Math.random() * _roomLimitNormal + 3);
					height = Math.round(Math.random() * _roomLimitNormal + 3);				
				}
				x = Math.round(Math.random() * Dungeon.TILESX);
				y = Math.round(Math.random() * Dungeon.TILESY);
				var newRoom:Room = new Room(x, y, width, height);
				_roomsA = newRoom.draw(_dungeonmap, _roomsA);
				if (_roomsA.length > _rooms) {
					_rooms++;
					// means room was added successfully
				} else {
					//trace('no room added');
				}
			}			
		}

		// this will not only draw items but extra clutter
		// probably monsters
		// stairs
		// add interesting room features
		// etc
		public function placeItems():void {
			var x:uint = 0;
			var y:uint = 0;
			var roomIndex:uint = 0;
			
			trace("pre draw level: " + ITEMS.length);
			for each (var item:* in ITEMS) {
				roomIndex = Math.max(0, (Math.round(Math.random() * _roomsA.length) - 1));
				x = (_roomsA[roomIndex].x + Math.max(1, Math.round(Math.random() * (_roomsA[roomIndex].width - 1)))) * GC.GRIDSIZE;
				y = (_roomsA[roomIndex].y + Math.max(1, Math.round(Math.random() * (_roomsA[roomIndex].height - 1)))) * GC.GRIDSIZE;
				item.x = x;
				item.y = y;
				FP.world.add(item);
			}
		}
		
		public function createItems():void {
			// generate items for the level and handle drawing them as well
			for (var i:uint = 0; i < 2; i++) {
				var itemGen:uint = Math.round(Math.random() * 3);
				var callback:Function = ITEM_GEN[itemGen];
				callback();
			}
			// now draw the items from ITEMS array
			//ITEMS.forEach(drawItem);
		}
		
		// handlers for generating new items and pushing them to the level item collection
		private function generateWeapon():void {
			var weapon:Weapon = new Weapon();
			ITEMS.push(weapon);
		}

		private function generateArmor():void {
			var armor:Armor = new Armor();
			ITEMS.push(armor);
		}		
		
		private function generatePotion():void {
			var potion:Potion = new Potion();
			ITEMS.push(potion);
		}		

		// create collision grid from nodemap objects
		private function drawGrid():void {
			//trace("nodemap size: " + _nodemap.length);
			for each (var node:Node in _nodemap._nodes) {
				_grid.setRect(node.x, node.y, 1, 1, node.solid);
			}
		}

		// find a random, non-trapped, non-monstered, non-stair position in 1st room
		private function placePlayer():void {
			var startingX:uint = 0;
			var startingY:uint = 0;
			var i:uint = 0;
			
			while ((_nodemap._nodes[(startingY * Dungeon.TILESX) + startingX].solid) && (i < 10)) {
				startingX = (Math.round(Math.random() * _roomsA[0].width)) + _roomsA[0].x;
				startingY = (Math.round(Math.random() * _roomsA[0].height)) + _roomsA[0].y;
				//trace("plr plc:" + startingX + "-" + startingY);
				i++;
			}
			// TODO: now we have a non-wall (pillar, statue) location in room, check for
			// other obstructions
			Dungeon.player.setPlayerStartingPosition(startingX, startingY);
		}

		private function createAndPlaceNPCs():void {
			// TODO:
			// need a way to determine random number of NPCs
			// need a way to adjust their level (+/-1 of actual dungeon maybe?)
			// need a way to draw from pool of possible NPCs, level appropriate
			// NPCs should have level ranges just like weapons/armor
			var x:uint = 0;
			var y:uint = 0;
			var roomIndex:uint = 0;
			
			// we need a way to keep track of used points on the grid for placement
			// but we don't really want to iterate through the NPC array for each new placement
			// so let's just use a new local array here and store points in it
			var usedPoints:Array = [];
			var pickedPoint:Point;
			
			for (var j:int = 0; j < 4; j++) {
				var newNPC:NPC = new NPC();
				newNPC.NPCType = MONSTARS.pop();
				NPCS.push(newNPC);
			}
			
			for each (var npc:* in NPCS) {
				roomIndex = Math.max(0, (Math.round(Math.random() * _roomsA.length) - 1));
				x = (_roomsA[roomIndex].x + Math.max(1, Math.round(Math.random() * (_roomsA[roomIndex].width - 1)))) * GC.GRIDSIZE;
				y = (_roomsA[roomIndex].y + Math.max(1, Math.round(Math.random() * (_roomsA[roomIndex].height - 1)))) * GC.GRIDSIZE;
				pickedPoint = new Point(x, y);
				while (pickedPoint.foundInArray(usedPoints) == true) {
					x = (_roomsA[roomIndex].x + Math.max(1, Math.round(Math.random() * (_roomsA[roomIndex].width - 1)))) * GC.GRIDSIZE;
					y = (_roomsA[roomIndex].y + Math.max(1, Math.round(Math.random() * (_roomsA[roomIndex].height - 1)))) * GC.GRIDSIZE;
					pickedPoint = new Point(x, y);
					usedPoints.push(pickedPoint);
				}
				npc.x = x;
				npc.y = y;
				FP.world.add(npc);
			}
			
		}
		
		override public function update():void {
			// synchronize updates with player turn
			// handle things like open doors, triggered traps, dried up fountains, etc.
			if (_step != Dungeon.player.STEP) {
				//FP.watch(_roomsA.length);
				_nodemap.update();
				_step = Dungeon.player.STEP;
			}
			// the following functions need "am I on correct stair tile" detection
			var tempCounter:uint = Dungeon.LevelHolderCounter;
			var tempLevelHolder:Vector.<LevelInfoHolder> = Dungeon.LevelHolder;
			
			if (Input.pressed("DownLevel")) {
				if (Dungeon.LevelHolder.length <= Dungeon.LevelHolderCounter) {
					Dungeon.LevelHolder.push(saveLevel());
				} else {
					Dungeon.LevelHolder[Dungeon.LevelHolderCounter] = saveLevel();
				}
				Dungeon.LevelHolderCounter++;
				// only if no downward level exists in dungeon array of levelholders
				if (Dungeon.LevelHolder.length <= Dungeon.LevelHolderCounter) {
					drawLevel();
				} else {
					// otherwise load lower level from storage and redraw
					loadLevel(Dungeon.LevelHolder[Dungeon.LevelHolderCounter]);
				}
				Dungeon.statusScreen.depthUpdate();
			}
			if (Input.pressed("UpLevel")) {
				if (Dungeon.LevelHolderCounter > 0) {
					Dungeon.LevelHolder[Dungeon.LevelHolderCounter] = saveLevel();
					Dungeon.LevelHolderCounter--;
					// load level from storage and redraw, if below 0
					var level:int = Dungeon.LevelHolderCounter;
					loadLevel(Dungeon.LevelHolder[Dungeon.LevelHolderCounter]);
				}
				else {
					Dungeon.LevelHolderCounter = 0;
					// at some point, add a "do you wish to leave the dungeon?" msg for game over
				}
				Dungeon.statusScreen.depthUpdate();
			}
		}
	}
}