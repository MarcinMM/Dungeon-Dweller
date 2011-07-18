package 
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	import flash.events.Event;
	import dungeon.utilities.GC;
	
	/**
	 * ...
	 * @author MM
	 */
	public class Main extends Engine 
	{
				
		public function Main() 
		{
			super(GC.VIEW_WIDTH, GC.VIEW_HEIGHT, 60, false);
			FP.world = new Dungeon;
		}
		
		override public function init():void 
		{
			FP.console.enable();
		}
	}
	
}