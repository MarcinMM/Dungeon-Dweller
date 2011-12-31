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
		public var gameStartDisplay:DisplayText;
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
			gameStartDisplay = new DisplayText( "Welcome to GAEM! You are ORK. (one day you will be more, I hope soon)\nblah", 10, (GC.VIEW_HEIGHT / 2), "default", 34, 0xFFFFFF, 60);
			var creatureAr:Array = new Array(); var i:uint = 1;
			for each (var pc:XML in Dungeon.dataloader.pcs) {
				var charItem:String = i + " - " + pc.@name;
				creatureAr[i] = new DisplayText(charItem, 50, 50, "default", 34, 0xFF0000, 60);
				characterSelect.push(creatureAr[i]);
			}
			gameEndDisplay = new DisplayText( "You dead. Soon you will see some stats for game end. \n\nPress any key to restart game.", 40, (GC.VIEW_HEIGHT/2), "default", 34, 0xFF0000, 60);

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
			for each (d in characterSelect)
			{
				d.visible = true;
			}
		}

		public function select(letter:String):void {
			
		}
		
		public function confirm():void {
			
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
			for each (var d:DisplayText in characterSelect)
			{
				d.visible = _visible;	
			}
		}

	}
}