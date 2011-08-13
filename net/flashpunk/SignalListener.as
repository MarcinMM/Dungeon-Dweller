package net.flashpunk
{
	/**
	 * Wrapper class for signal listener linked list.
	 * @private
	 */
	public final class SignalListener
	{
		public var added:Boolean = true;
		public var listener:Function = null;
		public var next:SignalListener = null;
		public var prev:SignalListener = null;
	}
}
