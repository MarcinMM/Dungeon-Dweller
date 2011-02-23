package 
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author MM
	 */
	public class Main extends Engine 
	{
				
		public function Main() 
		{
			super(800, 600, 60, false);
			FP.world = new Dungeon;
		}
		
		override public function init():void 
		{
			FP.console.enable();
		}
	}
	
}