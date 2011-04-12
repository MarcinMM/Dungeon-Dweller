package dungeon.utilities
{
	import dungeon.utilities.DisplayText;
	import dungeon.utilities.TextBox;
	import net.flashpunk.Entity;
	
	/**
	 * ...
	 * @author dolgion
	 */
	public class StatusScreen
	{
		public var background:TextBox;
		public var displayTexts:Array = new Array();
/*		public var experienceDisplay:DisplayText;
		public var strengthDisplay:DisplayText;
		public var agilityDisplay:DisplayText;
*/		// only worried about this for now
		public var gridDisplay:DisplayText;
		// non-equipped items, listed below 
		public var inventoryTexts:Array = new Array();
		// equipped items, listed first
		public var inventoryEquippedTexts:Array = new Array();
		
		private var invPointer:uint = 0;
		private var invPointerColor:String = "0xFF0000"; 
		private var invLabels:Array = ["- Armor", "- Weapons"];
			
		private var visibility:Boolean = false;
		
		public function StatusScreen() 
		{
			background = new TextBox((Dungeon.MAP_WIDTH/2), 20, (Dungeon.TILESX/2), Dungeon.TILESY);
			background.visible = false;
/*			experienceDisplay = new DisplayText(GC.EXPERIENCE_STRING + ": ", 245, 40, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			strengthDisplay = new DisplayText(GC.STRENGTH_STRING + ": ", 245, 55, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			agilityDisplay = new DisplayText(GC.AGILITY_STRING + ": ", 245, 70, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
*/
			// we'll need a grid foreach here
			var hGridAr:Array = new Array(45);
			var vGridAr:Array = new Array(35);
			var itemAr:Array = new Array();
			var i:uint = 0;

			/*
			for (var i:uint = 0; i < 40; i++) {
				hGridAr[i] = new DisplayText((i.toString()), (i * 20) + 2, 20-8, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 20);
				displayTexts.push(hGridAr[i]);
			}

			for (i = 0; i < 40; i++) {
				vGridAr[i] = new DisplayText((i.toString()), 20 + 2, (i*20)-8, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 20);
				displayTexts.push(vGridAr[i]);
			}
			*/
			// we need a line of text that spans the screen that can be updated later
			for (i = 0; i < 36; i++) {
				itemAr[i] = new DisplayText("", (Dungeon.MAP_WIDTH/2) + 5, ((i+1)*15), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, (Dungeon.MAP_WIDTH/2));
				inventoryTexts.push(itemAr[i]);
			}

/*			displayTexts.push(experienceDisplay);
			displayTexts.push(strengthDisplay);
			displayTexts.push(agilityDisplay);
*/			
			//displayTexts.push(gridDisplay);
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
		
		public function set stats(_stats:Array):void
		{
/*			healthDisplay.displayText.text = GC.HEALTH_STRING + ": " + _stats[GC.STATUS_HEALTH] + "/" + _stats[GC.STATUS_MAX_HEALTH];
			manaDisplay.displayText.text = GC.MANA_STRING + ": " + _stats[GC.STATUS_MANA] + "/" + _stats[GC.STATUS_MAX_MANA];
			strengthDisplay.displayText.text = GC.STRENGTH_STRING + ": " + _stats[GC.STATUS_STRENGTH];
			agilityDisplay.displayText.text = GC.AGILITY_STRING + ": " + _stats[GC.STATUS_AGILITY];
			spiritualityDisplay.displayText.text = GC.SPIRITUALITY_STRING + ": " + _stats[GC.STATUS_SPIRITUALITY];
			experienceDisplay.displayText.text = GC.EXPERIENCE_STRING + ": " + _stats[GC.STATUS_EXPERIENCE];
			
			damageRatingDisplay.displayText.text = GC.DAMAGE_STRING + ": " + _stats[GC.STATUS_DAMAGE];
			damageTypeDisplay.displayText.text = GC.DAMAGE_TYPE_STRING + ": " + Weapon.getDamageType(_stats[GC.STATUS_DAMAGE_TYPE]);
			attackTypeDisplay.displayText.text = GC.ATTACK_TYPE_STRING + ": " + Weapon.getAttackType(_stats[GC.STATUS_ATTACK_TYPE]);
			armorRatingDisplay.displayText.text = GC.ARMOR_STRING + ": " + _stats[GC.STATUS_ARMOR];
*/		}
		
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
			for each (d in displayTexts)
			{
				//d.visible = _visible;	
			}
		}
		
		
	}

}