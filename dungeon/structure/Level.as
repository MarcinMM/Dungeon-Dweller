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
	import dungeon.utilities.Overlay;

	/**
	 * ...
	 * @author MM
	 */
	public class Level extends Entity
	{
		[Embed(source = '../../assets/tilemaps.png')] private const TILEMAP:Class;
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

		public var STAIRS_UP:Point;
		public var STAIRS_DOWN:Point;
		
		// Level game data
		public var dungeonDepth:uint = 1;
		public var decor:Decor;

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
		
		public var _step:int = 0;
				
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
				item = null;
			}
			ITEMS = new Array();
			
			// save creatures; these need to be copy methods
			for each (var npc:NPC in NPCS) {
				var npcCopy:NPC = npc.selfCopy();
				levelHolder.creatures.push(npcCopy);
				FP.world.remove(npc);
				// npc = null; TODO: to be added once NPCs create graphics based on type; currently, graphic is saved by reference
			}
			NPCS = new Array();
			
			// save decor
			levelHolder.decor = decor.selfCopy();
			decor.resetDecor();
			FP.world.remove(decor);
			
			// finally stairs; while technically a part of decor, we need them right away for player placement
			levelHolder.stairsDown = STAIRS_DOWN;
			levelHolder.stairsUp = STAIRS_UP;
			
			return levelHolder;
		}
		
		public function loadLevel(levelHolder:LevelInfoHolder, direction:String):void {
			
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
				item = null; // destructor?
			}
			levelHolder.items = new Array();
			// now creatures
			for each (var npc:NPC in levelHolder.creatures) {
				var npcCopy:NPC = npc.selfCopy();
				NPCS.push(npcCopy);
				FP.world.add(npcCopy);
				npc = null;
			}
			levelHolder.creatures = new Array();
			
			// load decor
			decor = levelHolder.decor.selfCopy();
			FP.world.add(decor);
			
			STAIRS_DOWN = levelHolder.stairsDown;
			STAIRS_UP = levelHolder.stairsUp;
			
			// now put player on the appropriate stairs
			if (direction == "UP") {
				Dungeon.player.setPlayerPosition(STAIRS_DOWN.x, STAIRS_DOWN.y);
			} else {
				Dungeon.player.setPlayerPosition(STAIRS_UP.x, STAIRS_UP.y);
			}
			
			levelHolder.decor = new Decor();
			
			// synchronize NPC global step with NPC size
			Dungeon.STEP.setInitialNPCLength(NPCS.length);
		}
		
		private function drawLevel():void {
			_roomsA = [];
			_rooms = 0;

			_dungeonmap = new Tilemap(TILEMAP, Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT);
			_dungeonmap.setRect(0,0,Dungeon.TILESX, Dungeon.TILESY, GC.DEBUG); 
			graphic = _dungeonmap;
			layer = GC.LEVEL_LAYER;
			
			_grid = new Grid(Dungeon.MAP_WIDTH, Dungeon.MAP_HEIGHT, Dungeon.TILE_WIDTH, Dungeon.TILE_HEIGHT,0,0);
			mask = _grid;
			type = "level";
			
			decor = new Decor();
			FP.world.add(decor);

			drawRooms();
			_nodemap = new Nodemap(_dungeonmap, _roomsA);
			
			// if we are drawing solid clutter here, we'll need to re-init the _nodemap
			
			drawGrid();

			createItems();
			
			placeItems();
			
			createAndPlaceNPCs();
			
			placeDecor(decor);

			// now we need to handle the semi-random stuff
			// like generating non-random levels
			// or prebuilds (except that needs to go before drawRooms, or maybe part of it)
			// randomChance < 10% { executePrebuilt(); } or something

			// and now uniques, like the boss
			if (dungeonDepth == 10) {
				createAndPlaceBoss();
			}

			Dungeon.player.setPlayerPosition(STAIRS_UP.x, STAIRS_UP.y);
			
			// synchronize global NPC step with # of NPCs on level
			Dungeon.STEP.setInitialNPCLength(NPCS.length);
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

		// this is the non-NPC (pick-uppable) Entity adding code	
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
		
		// and this one is for decor, i.e. non-pickuppable items; stairs, chairs, tables, fountains
		// there may be other actions on them though, and some may be solid (statues)
		public function placeDecor(decor:Decor):void {

// need to rewrite this as
// 1. decorReturnAr = decor.generateDecor();
// 2. STAIRS_DOWN = decorReturnAr.STAIRS_DOWN;
// 3. STAIRS_UP = decorReturnAr.STAIRS_UP;
// rest of work should happen in Decor class

			// hardcode 5 items of decor, plus 2 stairs
			var decorToAdd:Array = new Array();
			var decorIndex:uint = 0;
			
			for (var i:uint = 0; i < 3; i++)
			{
				decorIndex = Math.round(Math.random() * GC.DECOR_SIZE); 
				decorToAdd.push(GC.DECOR_OFFSET + decorIndex);
			}
			decorToAdd.push(GC.DECOR_STAIRS_DOWN);
			decorToAdd.push(GC.DECOR_STAIRS_UP);
				
			// now iterate through desired decor items and assign them to random rooms on level
			var roomIndex:uint = 0;
			var decorLocation:Point;
			for each (decorIndex in decorToAdd) {
				roomIndex = Math.round(Math.random() * (_roomsA.length - 1));
				decorLocation = _roomsA[roomIndex].addDecor(decor, decorIndex);
				if (decorIndex == GC.DECOR_STAIRS_DOWN) {
					STAIRS_DOWN = decorLocation;
				}
				if (decorIndex == GC.DECOR_STAIRS_UP) {
					STAIRS_UP = decorLocation;
				}
			}
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

		private function createAndPlaceNPCs():void {
			// TODO:
			// need a way to determine random number of NPCs
			var x:uint = 0;
			var y:uint = 0;
			var roomIndex:uint = 0;
			
			// we need a way to keep track of used points on the grid for placement
			// but we don't really want to iterate through the NPC array for each new placement
			// so let's just use a new local array here and store points in it
			var usedPoints:Array = [];
			var pickedPoint:Point;
			
			// let's grab creatures that fall into this level range
			var levelCreatures:Array = Dungeon.dataloader.retrieveLevelCreatureList(dungeonDepth);
			
			// TODO here - instead of passing the name, just pass in the entire creature object
			for each (var i:Object in levelCreatures) {
				var newNPC:NPC = new NPC(i.creature);
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

		// TODO: just realized we'll need single creature spawning code, for adding critters over time
		private function createAndPlaceSingleNPC():void {
			
		}

		// TODO: we'll need to reuse this based on trigger for immortal bosses
		private function createAndPlaceBoss():void {
			
		}

		// since summoning adds creature to Level, it makes most sense to put it here. I think.
		public function summonNPC(npcName:String, origin:Point):void
		{
			// get creatureXML from npcName
			var creatureXML:XML = Dungeon.dataloader.npcDataXML.npcs.npc.(@name == npcName);

			var newNPC:NPC = new NPC(creatureXML);
			// find a nearby unoccupied location, might be able to coopt the code from overlay that queries tiles
			var newLocation:Point = newNPC.findTileNear(origin);
			if (!newLocation.equals(origin)) {
				newNPC.x = newLocation.x; // now is this tile X or absolute X?
				newNPC.y = newLocation.y;
				NPCS.push(newNPC);
				FP.world.add(newNPC);
				Dungeon.statusScreen.updateCombatText("The creature summons help!");
			} else {
				Dungeon.statusScreen.updateCombatText("It tries to summon help ... but nothing happens.");
			}
		}

		// another adding things to level (and then removing them) utility class
		// "item" is either weapon or spell
		public function throwItem(path:Array, item:Item):void {
			item.x = path[0].x * GC.GRIDSIZE; // now is this tile X or absolute X?
			item.y = path[0].y * GC.GRIDSIZE;
			// actually we dont' need traverse path do we? just need start and end, then tween the two
			// TODO: this bears examining
			// we'll also need some way to notify the level that STEP is done once item hits
			item.move(path[(path.length - 1)].x * GC.GRIDSIZE, path[(path.length - 1)].y * GC.GRIDSIZE);
			var removalChance:Number = Math.random() * 100;
			if (removalChance < 90 || !(item is Weapon)) {
				// I am hardcoding weapon breakage chance (when thrown) at 90%
				// everything else (non weapons) always breaks
				FP.world.remove(item);
			}
		}
		
		override public function update():void {
			// synchronize updates with player turn
			// handle things like open doors, triggered traps, dried up fountains, etc.
			if (_step != Dungeon.STEP.playerStep) {
				//FP.watch(_roomsA.length);
				_nodemap.update();
				_step = Dungeon.STEP.playerStep;
			}
			// the following functions need "am I on correct stair tile" detection
			var tempCounter:uint = Dungeon.LevelHolderCounter;
			var tempLevelHolder:Vector.<LevelInfoHolder> = Dungeon.LevelHolder;
			if (Input.pressed("DownLevel")) {
				// blibli
				trace(" ");
				var playerX:int = Dungeon.player.x;
				var playerY:int = Dungeon.player.y;
			}
			if (Input.pressed("DownLevel") && ((STAIRS_DOWN.x * GC.GRIDSIZE) == Dungeon.player.x) && ((STAIRS_DOWN.y * GC.GRIDSIZE) == Dungeon.player.y)) {
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
					loadLevel(Dungeon.LevelHolder[Dungeon.LevelHolderCounter], "DOWN");
				}
				Dungeon.statusScreen.depthUpdate();
			}
			if (Input.pressed("UpLevel") && ((STAIRS_UP.x * GC.GRIDSIZE) == Dungeon.player.x) && ((STAIRS_UP.y * GC.GRIDSIZE) == Dungeon.player.y)) {
				if (Dungeon.LevelHolderCounter > 0) {
					Dungeon.LevelHolder[Dungeon.LevelHolderCounter] = saveLevel();
					Dungeon.LevelHolderCounter--;
					// load level from storage and redraw, if below 0
					var level:int = Dungeon.LevelHolderCounter;
					loadLevel(Dungeon.LevelHolder[Dungeon.LevelHolderCounter], "UP");
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