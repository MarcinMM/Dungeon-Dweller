package net.flashpunk.components
{
	import net.flashpunk.Component;
	import net.flashpunk.FP;
	
	/**
	 * Component that calls its alarm() function at a regular interval.
	 */
	public class AlarmComponent extends Component
	{
		/**
		 * Delay between calls to alarm().
		 */
		public var duration:Number;
		
		/**
		 * Constructor.
		 * @param	duration	Duration of the alarm.
		 */
		function AlarmComponent(duration:Number)
		{
			this.duration = duration;
		}
		
		/**
		 * Override this, called when the timer has run out.
		 */
		public function alarm():void
		{
			
		}
		
		/**
		 * Percentage until the next alarm (from 0 to 1).
		 */
		public function get alarmPercent():Number
		{
			return FP.clamp(1 - _timer / duration, 0, 1);
		}
		
		override public function update():void
		{
			_timer -= FP.elapsed;
			if (_timer <= 0)
			{
				_timer = duration;
				alarm();
			}
		}
		
		/** @private */ protected var _timer:Number = 0;
	}
}
