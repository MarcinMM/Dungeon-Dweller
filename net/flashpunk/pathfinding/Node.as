package net.flashpunk.pathfinding
{
	/**
	 * A node in the map, used for pathfinding. The game needs to create one of
	 * these for each meaningful node in the world (e.g. each tile in the grid),
	 * and set the appropriate neighbors.
	 * 
	 * Implements Prioritizable so it can be used with Finder's PriorityQueue.
	 */
	public class Node
	{
		/**
		* Grid that this node belongs to.
		*/
		public var grid:PathGrid;

		/**
		* Grid column of this node.
		*/
		public var column:int;

		/**
		* Grid row of this node.
		*/
		public var row:int;

		/**
		* X coordinate of the node.
		*/
		public var x:Number;

		/**
		* Y coordinate of the node.
		*/
		public var y:Number;

		/**
		* Neighboring nodes.
		*/
		public var neighbors:Array;

		/**
		* True if this node is impassable.
		* FIXME: maybe set a numeric movement cost value to Infinity instead?
		*/
		public var solid:Boolean;

		/**
		* If set, map.findPath() will only see the node as passable if the
		* entity has matching flags.
		*/
		public var flags:int;

		/**
		* Unique identifier for this node, within the grid. This is used by the
		* finder's hash.
		*/
		public var id:int;

		// These are used for searching and should not be modified directly.
		/** @private */ public var _parent:Node;
		/** @private */ public var _priority:Number;  // a* f(n)
		/** @private */ public var _cost:Number;      // a* g(n)

		/**
		* Create a new node.
		*/
		function Node(grid:PathGrid, column:int, row:int)
		{
			solid = false;
			flags = 0;
			this.grid = grid;
			this.column = column;
			this.row = row;
			x = column * grid.tileWidth + (grid.tileWidth / 2);
			y = row * grid.tileHeight + (grid.tileHeight / 2);
			id = grid.getNextNodeId();
			neighbors = [];
			solid = grid.getTile(column, row);
		}

		public function createNeighbors():void
		{
			var n:Node
			var i:uint = 0;
			if ((n = grid.getNode(column - 1, row, false)) != null) neighbors[i++] = n;
			if ((n = grid.getNode(column + 1, row, false)) != null) neighbors[i++] = n;
			if ((n = grid.getNode(column, row - 1, false)) != null) neighbors[i++] = n;
			if ((n = grid.getNode(column, row + 1, false)) != null) neighbors[i++] = n;
			neighbors.length = i;
		}
	}
}
