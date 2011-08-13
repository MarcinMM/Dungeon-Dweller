package net.flashpunk
{
	/**
	 * A signal class, inspired by Robert Penner's as3-signals, but lighter
	 * weight for use with FlashPunk.
	 * 
	 * <listing version="3.0">
	 * var onHurt:Signal = new Signal;
	 * onHurt.add(function(damage:Number):void {
	 * 	trace(damage, 'damage?! ouch!');
	 * });
	 * onHurt.dispatch(42);  // calls the listener
	 * </listing>
	 */
	public class Signal
	{
		/**
		 * Constructor.
		 */
		function Signal()
		{
			_dispatching = false;
			_listenerHead = null;
			_listenerTail = null;
			_removed = null;
		}
		
		/**
		 * Add a listener to this signal.
		 * @param	listener		Function to add.
		 */
		public function add(listener:Function):void
		{
			if (find(listener) === null)
			{
				var sl:SignalListener = new SignalListener;
				sl.added = true;
				sl.listener = listener;
				sl.prev = _listenerTail;
				sl.next = null;
				if (_listenerHead === null)
				{
					_listenerHead = sl;
					_listenerTail = sl;
				}
				else
				{
					_listenerTail.next = sl;
					_listenerTail = sl;
				}
			}
		}
		
		/**
		 * Find a the SignalListener for a listener function on this signal.
		 * @param	listener		Function to find.
		 * @return Matching SignalListener, or null if the function wasn't a listener on this signal.
		 */
		public function find(listener:Function):SignalListener
		{
			var sl:SignalListener = _listenerHead;
			while (sl !== null)
			{
				if (sl.listener === listener)
				{
					break;
				}
				sl = sl.next;
			}
			return sl;
		}
		
		/**
		 * Remove a listener from this signal.
		 * @param	listener		Function to remove.
		 */
		public function remove(listener:Function):void
		{
			var sl:SignalListener = find(listener);
			if (sl !== null) _remove(sl);
		}
		
		/**
		 * Remove all listeners from this signal.
		 */
		public function removeAll():void
		{
			var sl:SignalListener = _listenerHead;
			while (sl !== null)
			{
				var sln:SignalListener = sl.next;
				_remove(sl);
				sl = sln;
			}
			_listenerHead = _listenerTail = null;
		}
		
		/**
		 * Trigger this signal, invoking all of the listeners in the order they were added.
		 * @param	...args		Arguments to pass along to the listeners.
		 */
		public function dispatch(...args):void
		{
			try
			{
				_dispatching = true;
				var sl:SignalListener = _listenerHead;
				// This is split up for performance
				var numArgs:int = args.length;
				if (numArgs === 0)
				{
					while (sl !== null)
					{
						if (sl.added) sl.listener();
						sl = sl.next;
					}
				}
				else if (numArgs === 1)
				{
					var arg:Object = args[0];
					while (sl !== null)
					{
						if (sl.added) sl.listener(args[0]);
						sl = sl.next;
					}
				}
				else if (numArgs === 2)
				{
					var arg1:Object = args[0];
					var arg2:Object = args[1];
					while (sl !== null)
					{
						if (sl.added) sl.listener(arg1, arg2);
						sl = sl.next;
					}
				}
				else
				{
					while (sl !== null)
					{
						if (sl.added) sl.listener.apply(null, args);
						sl = sl.next;
					}
				}
			}
			finally
			{
				_dispatching = false;
				if (_removed && _removed.length > 0)
				{
					var il:uint = _removed.length;
					for (var i:uint = 0; i < il; ++i)
					{
						_remove(_removed[i]);
					}
					_removed.length = 0;
				}
			}
		}
		
		/**
		 * Remove a signal listener, or mark it for removal if a dispatch is in progress.
		 * @param	sl		Signal listener to remove from the linked list.
		 * @private
		 */
		protected function _remove(sl:SignalListener):void
		{
			if (sl !== null)
			{
				if (_dispatching && sl.added)
				{
					if (_removed == null) _removed = [sl];
					else _removed[_removed.length] = sl;
					sl.added = false;
				}
				else
				{
					if (sl === _listenerHead) _listenerHead = sl.next;
					if (sl === _listenerTail) _listenerTail = sl.prev;
					if (sl.prev) sl.prev.next = sl.next;
					if (sl.next) sl.next.prev = sl.prev;
					sl.next = sl.prev = null;
					sl.listener = null;
					sl.added = false;
				}
			}
		}
		
		/** @private */ protected var _dispatching:Boolean;
		/** @private */ protected var _listenerHead:SignalListener;
		/** @private */ protected var _listenerTail:SignalListener;
		/** @private */ protected var _removed:Array;
	}
}
