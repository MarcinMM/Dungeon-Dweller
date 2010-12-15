package 
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	import flash.events.Event;
	import nl.demonsters.debugger.MonsterDebugger;
	
	/**
	 * ...
	 * @author MM
	 */
	public class Main extends Engine 
	{
		
		private var debugger:MonsterDebugger;
		
		public function Main() 
		{
			// Init the debugger
			debugger = new MonsterDebugger(this);
			
			// Send a simple trace
			MonsterDebugger.trace(this, "We have monster!")

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