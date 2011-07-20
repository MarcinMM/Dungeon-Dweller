package dungeon.utilities
{
	import dungeon.utilities.DisplayText;
	import dungeon.utilities.TextBox;
	import flash.utils.IDataInput;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class StatusScreen
	{
		public var background:TextBox;

		// intrinsic stats display
		public var levelDisplay:DisplayText;
		public var xpDisplay:DisplayText;
		public var hpDisplay:DisplayText;
		public var strDisplay:DisplayText;
		public var agiDisplay:DisplayText;
		public var intDisplay:DisplayText;
		public var wisDisplay:DisplayText;
		public var chaDisplay:DisplayText;
		public var conDisplay:DisplayText;
		public var manaDisplay:DisplayText;
		
		// derived stats display, only for alpha/beta etc.
		public var attDisplay:DisplayText;
		public var defDisplay:DisplayText;
		public var critdefDisplay:DisplayText;
		public var perDisplay:DisplayText;
		public var penDisplay:DisplayText;
		public var sppowerDisplay:DisplayText;
		public var splevelDisplay:DisplayText;
		
		// combat text/stuff
		public var textDisplay1:DisplayText;
		public var textDisplay2:DisplayText;
		public var textDisplay3:DisplayText;
		public var textDisplay4:DisplayText;
		public var textDisplay5:DisplayText;
		public var textDisplay6:DisplayText;
		public var textDisplay7:DisplayText;
		public var textDisplay8:DisplayText;
		public var textDisplaysArray:Array;
		public var textDisplaysPointer:uint;

		// only worried about this for now
		public var gridDisplay:DisplayText;
		// non-equipped items, listed below 
		public var inventoryTexts:Array = new Array();
		// stats display texts
		public var displayTexts:Array = new Array();
		// combat texts

		// equipped items, listed first
		public var inventoryEquippedTexts:Array = new Array();
		
		private var invPointer:uint = 0;
		private var invPointerColor:String = "0xFF0000"; 
		private var invLabels:Array = ["- Armor", "- Weapons"];
			
		private var visibility:Boolean = false;
		
		public function StatusScreen() 
		{
			background = new TextBox((GC.VIEW_WIDTH/2), 20, (Dungeon.TILESX/2), Dungeon.TILESY);
			background.visible = false;
			
			levelDisplay = new DisplayText("Lvl: ", 0, (GC.VIEW_HEIGHT - 70), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			xpDisplay = new DisplayText("XP: ", 60, (GC.VIEW_HEIGHT - 70), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			hpDisplay = new DisplayText( "HP: ", 120, (GC.VIEW_HEIGHT - 70), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			manaDisplay = new DisplayText( "MAN: ", 180, (GC.VIEW_HEIGHT - 70), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			strDisplay = new DisplayText( "STR: ", 240, (GC.VIEW_HEIGHT - 70), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			agiDisplay = new DisplayText( "AGI: ", 300, (GC.VIEW_HEIGHT - 70), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			intDisplay = new DisplayText( "INT: ", 360, (GC.VIEW_HEIGHT - 70), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			wisDisplay = new DisplayText( "WIS: ", 420, (GC.VIEW_HEIGHT - 70), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			chaDisplay = new DisplayText( "CHA: ", 480, (GC.VIEW_HEIGHT - 70), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			conDisplay = new DisplayText( "CON: ", 540, (GC.VIEW_HEIGHT - 70), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);

			// derived
			attDisplay = new DisplayText( "ATT: ", 0, (GC.VIEW_HEIGHT - 80), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			defDisplay = new DisplayText( "DEF: ", 60, (GC.VIEW_HEIGHT - 80), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			critdefDisplay = new DisplayText( "CRD: ", 120, (GC.VIEW_HEIGHT - 80), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			perDisplay = new DisplayText( "PER: ", 180, (GC.VIEW_HEIGHT - 80), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			penDisplay = new DisplayText( "PEN: ", 240, (GC.VIEW_HEIGHT - 80), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			sppowerDisplay = new DisplayText( "SPR: ", 300, (GC.VIEW_HEIGHT - 80), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			splevelDisplay = new DisplayText( "SPL: ", 360, (GC.VIEW_HEIGHT - 80), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			
			// status combat text + debug text while in alpha/beta/LOLZ
			textDisplay1 = new DisplayText( "TXT: ", 10, (GC.VIEW_HEIGHT - 160), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 600);
			textDisplay2 = new DisplayText( "TXT: ", 10, (GC.VIEW_HEIGHT - 150), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 600);
			textDisplay3 = new DisplayText( "TXT: ", 10, (GC.VIEW_HEIGHT - 140), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 600);
			textDisplay4 = new DisplayText( "TXT: ", 10, (GC.VIEW_HEIGHT - 130), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 600);
			textDisplay5 = new DisplayText( "TXT: ", 10, (GC.VIEW_HEIGHT - 120), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 600);
			textDisplay6 = new DisplayText( "TXT: ", 10, (GC.VIEW_HEIGHT - 110), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 600);
			textDisplay7 = new DisplayText( "TXT: ", 10, (GC.VIEW_HEIGHT - 100), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 600);
			textDisplay8 = new DisplayText( "TXT: ", 10, (GC.VIEW_HEIGHT - 90), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 600);
			textDisplaysArray = new Array(textDisplay1, textDisplay2, textDisplay3, textDisplay4, textDisplay5, textDisplay6, textDisplay7, textDisplay8);
			
			// we'll need a grid foreach here
			var hGridAr:Array = new Array(45);
			var vGridAr:Array = new Array(35);
			var itemAr:Array = new Array();
			var i:uint = 0;

			// pathfinding grids
			for (i = 0; i < 60; i++) {
				hGridAr[i] = new DisplayText((i.toString()), (i * GC.GRIDSIZE) + 2, GC.GRIDSIZE - 8, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, GC.GRIDSIZE);
				displayTexts.push(hGridAr[i]);
			}

			for (i = 0; i < 40; i++) {
				vGridAr[i] = new DisplayText((i.toString()), GC.GRIDSIZE + 2, (i * GC.GRIDSIZE)-8, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, GC.GRIDSIZE);
				displayTexts.push(vGridAr[i]);
			}
			
			// we need a line of text that spans the screen that can be updated later
			for (i = 0; i < 36; i++) {
				itemAr[i] = new DisplayText("", (GC.VIEW_WIDTH/2) + 5, ((i+1)*15), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, (GC.VIEW_WIDTH/2));
				inventoryTexts.push(itemAr[i]);
			}

			displayTexts.push(xpDisplay);
			displayTexts.push(levelDisplay);
			displayTexts.push(hpDisplay);
			displayTexts.push(manaDisplay);
			displayTexts.push(hpDisplay);
			displayTexts.push(strDisplay);
			displayTexts.push(agiDisplay);
			displayTexts.push(wisDisplay);
			displayTexts.push(chaDisplay);
			displayTexts.push(conDisplay);
			displayTexts.push(intDisplay);
			
			displayTexts.push(attDisplay);
			displayTexts.push(defDisplay);
			displayTexts.push(critdefDisplay);
			displayTexts.push(perDisplay);
			displayTexts.push(penDisplay);
			displayTexts.push(sppowerDisplay);
			displayTexts.push(splevelDisplay);
			
			displayTexts.push(textDisplay1);
			displayTexts.push(textDisplay2);
			displayTexts.push(textDisplay3);
			displayTexts.push(textDisplay4);
			displayTexts.push(textDisplay5);
			displayTexts.push(textDisplay6);
			displayTexts.push(textDisplay7);
			displayTexts.push(textDisplay8);
			
			for each (var d:DisplayText in displayTexts)
			{
				d.visible = true;
			}
		}
		
		// traversal of inventory
		public function up():void {
			if (invPointer == 1) {
				invPointer = 1;
			} else {
				if ( (invLabels.indexOf(inventoryTexts[invPointer-1].displayText.text) != -1) && (invPointer - 2 > 0) ){
					inventoryTexts[invPointer].displayText.color = invPointerColor;
					invPointer = invPointer - 2;
					invPointerColor = inventoryTexts[invPointer].displayText.color;
					inventoryTexts[invPointer].displayText.color = "0x00FF00";
				} else if (invLabels.indexOf(inventoryTexts[invPointer-1].displayText.text) == -1) {
					inventoryTexts[invPointer].displayText.color = invPointerColor;
					invPointer--;
					invPointerColor = inventoryTexts[invPointer].displayText.color;
					inventoryTexts[invPointer].displayText.color = "0x00FF00";
				}
			}
		}
		
		public function down():void {
			inventoryTexts[invPointer].displayText.color = invPointerColor;
			invPointer++;
			var itemLength:uint = Dungeon.player.INVENTORY_SIZE + invLabels.length;
			if (invPointer >= itemLength) {
				invPointer = (itemLength - 1);
				inventoryTexts[invPointer].displayText.color = "0x00FF00";
			} else {
				if ( (invLabels.indexOf(inventoryTexts[invPointer].displayText.text) != -1) && (invPointer + 1 < itemLength) ) {
					invPointer = invPointer + 1;
					invPointerColor = inventoryTexts[invPointer].displayText.color;
					inventoryTexts[invPointer].displayText.color = "0x00FF00";
				} else if (invLabels.indexOf(inventoryTexts[invPointer-1].displayText.text) == -1) {
					invPointerColor = inventoryTexts[invPointer].displayText.color;
					inventoryTexts[invPointer].displayText.color = "0x00FF00";
				}
			}
		}
		
		public function updateInventory():void {
			var itemText:DisplayText;
			var i:uint = 1;
			inventoryTexts[0].displayText.color = "0xFF0000";
			inventoryTexts[0].displayText.text = "- Armor";

			for (var j:uint = 0; j < Dungeon.player.ITEMS[GC.C_ITEM_ARMOR].length; j++) {
				if (Dungeon.player.ITEMS[GC.C_ITEM_ARMOR][j].EQUIPPED) {
					inventoryTexts[i].displayText.text = "(*) " + Dungeon.player.ITEMS[GC.C_ITEM_ARMOR][j].invLetter + " - " + Dungeon.player.ITEMS[GC.C_ITEM_ARMOR][j].DESCRIPTION;
					inventoryTexts[i].displayText.color = "0x0000FF";					
				} else {
					inventoryTexts[i].displayText.text = Dungeon.player.ITEMS[GC.C_ITEM_ARMOR][j].invLetter + " - " + Dungeon.player.ITEMS[GC.C_ITEM_ARMOR][j].DESCRIPTION;
					inventoryTexts[i].displayText.color = "0xFFFFFF";
				}
				i++;
			}

			inventoryTexts[i].displayText.color = "0xFF0000";
			inventoryTexts[i].displayText.text = "- Weapons";
			i++;

			for (j = 0; j < Dungeon.player.ITEMS[GC.C_ITEM_WEAPON].length; j++) {
				if (Dungeon.player.ITEMS[GC.C_ITEM_WEAPON][j].EQUIPPED) {
					inventoryTexts[i].displayText.text = "(*) " + Dungeon.player.ITEMS[GC.C_ITEM_WEAPON][j].invLetter + " - " + Dungeon.player.ITEMS[GC.C_ITEM_WEAPON][j].DESCRIPTION;
					inventoryTexts[i].displayText.color = "0x0000FF";
				} else {
					inventoryTexts[i].displayText.text = Dungeon.player.ITEMS[GC.C_ITEM_WEAPON][j].invLetter + " - " + Dungeon.player.ITEMS[GC.C_ITEM_WEAPON][j].DESCRIPTION;
					inventoryTexts[i].displayText.color = "0xFFFFFF";
				}
				i++;
			}
		}
		
		public function updateCombatText(text:String):void {
			for (var i:uint = (textDisplaysArray.length-1); i >= 1; i--) {
			  textDisplaysArray[i].displayText.text = textDisplaysArray[i-1].displayText.text;
			}
			textDisplaysArray[0].displayText.text = text;
		}
		
		public function statUpdate(_stats:Array):void
		{
			levelDisplay.displayText.text = "LVL: " + _stats[GC.STATUS_LEVEL];
			xpDisplay.displayText.text = "XP: " + _stats[GC.STATUS_XP];
			hpDisplay.displayText.text = "HP: " + _stats[GC.STATUS_HP];
			strDisplay.displayText.text = "STR: " + _stats[GC.STATUS_STR];
			agiDisplay.displayText.text = "AGI: " + _stats[GC.STATUS_AGI];
			intDisplay.displayText.text = "INT: " + _stats[GC.STATUS_INT];
			wisDisplay.displayText.text = "WIS: " + _stats[GC.STATUS_WIS];
			chaDisplay.displayText.text = "CHA: " + _stats[GC.STATUS_CHA];
			conDisplay.displayText.text = "CON: " + _stats[GC.STATUS_CON];
			manaDisplay.displayText.text = "MNA: " + _stats[GC.STATUS_MANA];
			
			attDisplay.displayText.text = "ATT: " + _stats[GC.STATUS_ATT];
			defDisplay.displayText.text = "DEF: " + _stats[GC.STATUS_DEF];
			critdefDisplay.displayText.text = "CRD: " + _stats[GC.STATUS_CRITDEF];
			perDisplay.displayText.text = "PER: " + _stats[GC.STATUS_PER].toFixed(2);
			penDisplay.displayText.text = "PEN: " + _stats[GC.STATUS_PEN].toFixed(2);
			sppowerDisplay.displayText.text = "SPP: " + _stats[GC.STATUS_SPPOWER];
			splevelDisplay.displayText.text = "SPL: " + _stats[GC.STATUS_SPLEVEL];
		}
		
		public function get visible():Boolean
		{
			return visibility;
		}
		
		public function set visible(_visible:Boolean):void
		{
			visibility = _visible;
			background.visible = _visible;
			for each (var d:DisplayText in inventoryTexts)
			{
				d.visible = _visible;	
			}
		}
		
		
	}

}