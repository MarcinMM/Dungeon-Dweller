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
			FP.world = new MyWorld;
		}
		
		override public function init():void 
		{
			FP.console.enable();
			trace("Houston we have Flashpunk?");
		}
	}
	
}