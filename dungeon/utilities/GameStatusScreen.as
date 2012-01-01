package dungeon.utilities
{
	import dungeon.contents.Player;
	import dungeon.utilities.DisplayText;
	import dungeon.utilities.TextBox;
	import flash.utils.IDataInput;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	
	/**
	 * ...
	 * @author MM
	 */
	public class GameStatusScreen
	{
		public var background:TextBox;

		// text for game end and start
		public var gameStartDisplay1:DisplayText;
		public var gameStartDisplay2:DisplayText;
		public var gameStartDisplay3:DisplayText;
		public var gameStartDisplay4:DisplayText;
		public var gameEndDisplay:DisplayText;
		
		// text display holders
		public var startTexts:Array = new Array();
		public var endTexts:Array = new Array();
		
		// character selection array
		public var characterSelect:Array = [];
		
		public function GameStatusScreen() 
		{
			background = new TextBox(0, 0, Dungeon.TILESX, Dungeon.TILESY); // full width cover
			background.visible = false;
			
			// intro and game end texts
			gameStartDisplay1 = new DisplayText( "The story so far:", 10, (GC.VIEW_HEIGHT / 3) - 44, "default", 34, 0xFFFFFF, 60);
			gameStartDisplay2 = new DisplayText( "You are a noble creature, hired to protect this castle from wandering heroes and curious nobodies alike. \nHowever, the one in charge of this place has fallen on slightly hard times and you've heard \n'the check is in the mail' one too many times. It's time to do something about it. It's time for the hired help \nto demand something better. It's a time when ...", 10, (GC.VIEW_HEIGHT / 3) + 45, "default", 24, 0xFFFFFF, 60);
			gameStartDisplay3 = new DisplayText( "Dungeon Contractor Strikes Back", 44, (GC.VIEW_HEIGHT / 3) + 155, "default", 44, 0xFFFFFF, 60);
			gameStartDisplay4 = new DisplayText( "Select character:", 15, 15, "default", 24, 0xFFFFFF, 60);
			var creatureAr:Array = new Array(); var i:uint = 1;
			for each (var pc:XML in Dungeon.dataloader.pcs) {
				var charItem:String = i + " - " + pc.@name;
				creatureAr[i] = new DisplayText(charItem, 15, (15 + 45 * i), "default", 34, 0xFF0000, 60);
				characterSelect.push(creatureAr[i]);
				i++;
			}
			gameEndDisplay = new DisplayText( "You dead. Soon you will see some stats for game end. \n\nPress any key to restart game.", 40, (GC.VIEW_HEIGHT/2), "default", 34, 0xFF0000, 60);

			endTexts.push(gameEndDisplay);
			startTexts.push(gameStartDisplay1);
			startTexts.push(gameStartDisplay2);
			startTexts.push(gameStartDisplay3);
			startTexts.push(gameStartDisplay4);
			
			for each (var d:DisplayText in endTexts)
			{
				//d.visible = true;
			}
			for each (d in startTexts)
			{
				d.visible = true;
			}
			for each (d in characterSelect)
			{
				d.visible = true;
			}
		}

		public function select(selectedClass:int):Number {
			if (typeof(selectedClass) == "number") {
				var actualCharacterPointer:uint = uint (selectedClass) - 1;
				if (actualCharacterPointer < characterSelect.length) {
					for each (var d:DisplayText in characterSelect) {
						d.displayText.color = 0xFF0000;
					}
					characterSelect[actualCharacterPointer].displayText.color = "0xFFFFFF";
					return actualCharacterPointer;
				}
			}
			return 0;
		}
		
		public function confirm(actualCharacterPointer):void {
			// pass current back to dungeon somehow and load player stats from XML into Player
			// then close start screen and resume game
			// do nothing if no class is selected
			if (actualCharacterPointer != 0) {
				visibleStart = false;
			}
			
		}
		
		public function get visibleEnd():Boolean {
			return Dungeon.player.END_SCREEN;
		}
		
		public function get visibleStart():Boolean {
			return Dungeon.player.START_SCREEN;
		}
		
		public function set visibleEnd(_visible:Boolean):void {
			for each (var d:DisplayText in endTexts)
			{
				d.visible = _visible;	
			}
			background.visible = _visible;
			Dungeon.player.END_SCREEN = _visible;
		}
		
		public function set visibleStart(_visible:Boolean):void {
			for each (var d:DisplayText in startTexts)
			{
				d.visible = _visible;	
			}
			background.visible = _visible;
			for each (d in characterSelect)
			{
				d.visible = _visible;	
			}
			Dungeon.player.START_SCREEN = _visible;
		}

	}
}