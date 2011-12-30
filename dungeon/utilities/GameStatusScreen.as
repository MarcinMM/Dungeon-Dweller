package dungeon.utilities
{
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
		public var gameStartDisplay:DisplayText;
		public var gameEndDisplay:DisplayText;
		
		// text display holders
		public var startTexts:Array = new Array();
		public var endTexts:Array = new Array();
		
		// character selection array
		public var characterSelect:Array = [];
		
		public function GameStatusScreen() 
		{
			background = new TextBox(0,0, Dungeon.TILESX, Dungeon.TILESY); // full width cover
			
			// intro and game end texts
			gameStartDisplay = new DisplayText( "Welcome to GAEM! You are ORK. (one day you will be more, I hope soon)\nblah", 10, (GC.VIEW_HEIGHT / 2), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 60);
			gameEndDisplay = new DisplayText( "You dead. Soon you will see some stats for game end. \n\nPress any key to restart game.", 40, (GC.VIEW_HEIGHT/2), "default", 34, 0xFF0000, 60);

			// setup for character select, should work like inventory
			// textDisplay8 = new DisplayText( "", 10, (GC.VIEW_HEIGHT - 90), "default", GC.STATUS_SCREEN_DEFAULT_FONT_SIZE, 0xFFFFFF, 600);
			// textDisplaysArray = new Array(textDisplay1, textDisplay2, textDisplay3, textDisplay4, textDisplay5, textDisplay6, textDisplay7, textDisplay8);
			
			endTexts.push(gameEndDisplay);
			
			startTexts.push(gameStartDisplay);
			
			for each (var d:DisplayText in gameEndDisplay)
			{
				d.visible = true;
			}
			for each (d in gameStartDisplay)
			{
				d.visible = true;
			}
		}
		
		public function get visibleEnd():Boolean {
			return gameEndDisplay.visible;
		}
		
		public function get visibleStart():Boolean {
			return gameStartDisplay.visible;
		}
		
		public function set visibleEnd(_visible:Boolean):void {
			gameEndDisplay.visible = _visible;
			background.visible = _visible;
		}
		
		public function set visibleStart(_visible:Boolean):void {
			gameStartDisplay.visible = _visible;
			background.visible = _visible;
		}

	}
}