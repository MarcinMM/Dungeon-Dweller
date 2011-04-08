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
		
		private var visibility:Boolean = false;
		
		public function StatusScreen() 
		{
			//background = new TextBox(10, 10, 3, 4.5);
			
/*			experienceDisplay = new DisplayText(GC.EXPERIENCE_STRING + ": ", 245, 40, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			strengthDisplay = new DisplayText(GC.STRENGTH_STRING + ": ", 245, 55, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
			agilityDisplay = new DisplayText(GC.AGILITY_STRING + ": ", 245, 70, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 500);
*/
			// we'll need a grid foreach here
			var hGridAr:Array = new Array(45);
			var vGridAr:Array = new Array(35);
			for (var i:uint = 0; i < 40; i++) {
				hGridAr[i] = new DisplayText((i.toString()), (i * 20) + 2, 20-8, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 20);
				displayTexts.push(hGridAr[i]);
			}

			for (i = 0; i < 40; i++) {
				vGridAr[i] = new DisplayText((i.toString()), 20 + 2, (i*20)-8, "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 20);
				displayTexts.push(vGridAr[i]);
			}

/*			displayTexts.push(experienceDisplay);
			displayTexts.push(strengthDisplay);
			displayTexts.push(agilityDisplay);
*/			
			//displayTexts.push(gridDisplay);
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
			//background.visible = _visible;
			for each (var d:DisplayText in displayTexts)
			{
				d.visible = _visible;	
			}
		}
		
		
	}

}