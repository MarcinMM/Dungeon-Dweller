package net.flashpunk.pathfinding
{
	/**
	 * A linked list node path, as returned by Finder.find().
	 * @see Finder.find
	 */
	public class Path
	{
		static public var INCOMPLETE:Path = new Path(-1, -1, null, null);

		/**
		 * The X position of this path point.
		 */
		public var x:Number;

		/**
		 * The Y position of this path point.
		 */
		public var y:Number;

		/**
		 * The Node this item in the list points to (or null, if it doesn't have
		 * a corresponding node).
		 */
		public var node:Node;

		/**
		 * The next item in the list, or null if there aren't any more items.
		 */
		public var next:Path;

		/**
		 * If true, entities following this path should not try to skip past
		 * this path node, and should be forced to seek to it.
		 */
		public var important:Boolean;

		/**
		 * Create a new path object.
		 * 
		 * @param node The node this path item should point to.
		 * @param next The next path item in the list.
		 */
		function Path(x:Number, y:Number, node:Node, next:Path)
		{
			important = true;
			this.x = x;
			this.y = y;
			this.node = node;
			this.next = next;
		}
	}
}
