package dungeon.utilities 
{
	/**
	 * ...
	 * @author ...
	 */
	public class Step 
	{
		
		public var playerStep:uint;
		public var globalStep:uint;
		public var npcSteps:uint;
		
		public function Step() 
		{
			init();
		}
		
		public function init():void {
			playerStep = 0;
			globalStep = 0;
			npcSteps = 0;
		}
		
		public function setInitialNPCLength(npcLength:uint):void {
			npcSteps = npcLength;
		}
		
		public function reset():void {
			npcSteps = 0;
		}
		
		public function isReady():Boolean {
			var readyFlag:Boolean = true;
			var testLength:uint = Dungeon.level.NPCS.length;
			var npcAr:Array = Dungeon.level.NPCS;
			if (npcSteps < Dungeon.level.NPCS.length) {
				readyFlag = false;
			}
			if (playerStep != globalStep) {
				readyFlag = false;
			}
			return readyFlag;
		}
	}
}