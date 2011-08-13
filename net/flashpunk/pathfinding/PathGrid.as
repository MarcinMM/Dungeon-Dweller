package net.flashpunk.pathfinding
{
	import net.flashpunk.Entity;
	import net.flashpunk.masks.Grid;

	/**
	 * Creates and manages pathfinding nodes for a FlashPunk Grid object.
	 * 
	 * @example Find a path in a grid from 0,0 to 64,64 (world coordinates).
	 * <listing version="3.0">
	 *  var path:Path = grid.finder.find(grid.getNode(0, 0), grid.getNode(64, 64));
	 *  while (path) {
	 *     trace("path node: " + path.node.x, path.node.y);
	 *     path = path.next;
	 *  }
	 * </listing>
	 */
	public class PathGrid extends Grid
	{
		public var finder:Finder;
		public var nodes:Vector.<Node>;
		private var _nextNodeId:int;

		function PathGrid(width:int, height:int, tileWidth:int, tileHeight:int, x:int = 0, y:int = 0)
		{
			super(width, height, tileWidth, tileHeight, x, y);
			finder = new Finder();
			createNodes();
		}

		override public function clearTile(column:uint = 0, row:uint = 0):void
		{
			super.clearTile(column, row);
			var node:Node = getNode(column, row, usePositions);
			if (node != null) node.solid = false;
		}

		/**
		 * Build the list of nodes and neighbors. This should be called if the
		 * grid is changed after creating the graph.
		 * 
		 * @private
		 */
		private function createNodes():void
		{
			var node:Node;
			nodes = new Vector.<Node>();
			for (var row:uint = 0; row < rows; ++row)
			{
				for (var column:uint = 0; column < columns; ++column)
				{
					node = new Node(this, column, row);
					nodes[node.id] = node;
				}
			}
			for each (node in nodes)
			{
				node.createNeighbors();
			}
		}

		/**
		 * Find a path from x1,y1, to x2,y2.
		 * 
		 * @param x1 X coordinate of the starting node.
		 * @param y1 Y coordinate of the starting node.
		 * @param x2 X coordinate of the destination node.
		 * @param y2 Y coordinate of the destination node.
		 * @param allowSolid True to allow the path to include solid nodes.
		 * @param usePositions True if x1, y1, x2, and y2 are world coordinates.
		 * @return A linked list of Path objects, or null if a path to the goal
		 *   node couldn't be found.
		 */
		public function findPath(x1:Number, y1:Number, x2:Number, y2:Number, allowSolid:Boolean = false, usePositions:Boolean = true):Path
		{
			var node1:Node = getNode(int(x1), int(y1), usePositions);
			var node2:Node = getNode(int(x2), int(y2), usePositions);
			if (node1 != null && node2 != null)
			{
				return finder.find(node1, node2, x2, y2, allowSolid);
			}
			else return null;
		}

		/**
		 * Get the node at the given row and column.
		 * 
		 * @param x Column in the grid.
		 * @param y Row in the grid.
		 * @param usePositions True if column and row are world coordinates.
		 * @return The matching node, or null if the coordinates are invalid.
		 */
		public function getNode(column:int, row:int, usePositions:Boolean = true):Node
		{
			if (usePositions)
			{
				column = int(column / tileWidth);
				row = int(row / tileHeight);
			}
			if (column >= 0 && row >= 0 && column < columns && row < rows)
			{
				return nodes[row * columns + column];
			}
			else return null;
		}

		/**
		 * Get the next available node ID for this grid.
		 */
		public function getNextNodeId():int
		{
			return _nextNodeId++;
		}

		override public function setRect(column:uint = 0, row:uint = 0, width:int = 1, height:int = 1, solid:Boolean = true):void
		{
			super.setRect(column, row, width, height, solid);
			if (usePositions)
			{
				column = int(column / tileWidth);
				row = int(row / tileHeight);
				width = int(width / tileWidth);
				height = int(height / tileHeight);
			}
			width += column;
			height += row;
			var y:uint = row;
			while (y < height)
			{
				var x:uint = column;
				while (x < width)
				{
					var node:Node = getNode(x, y, false);
					if (node != null) node.solid = solid;
					++x;
				}
				++y;
			}
		}

		override public function setTile(column:uint = 0, row:uint = 0, solid:Boolean = true):void
		{
			super.setTile(column, row, solid);
			var node:Node = getNode(column, row, usePositions);
			if (node != null) node.solid = solid;
		}
	}
}
