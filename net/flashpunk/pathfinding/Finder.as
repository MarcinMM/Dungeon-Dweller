package net.flashpunk.pathfinding
{
	import flash.utils.Dictionary;
	import net.flashpunk.Entity;

	/**
	 * Provides methods for finding paths from one node to another, using A*.
	 * See: http://theory.stanford.edu/~amitp/GameProgramming/
	 */
	public class Finder
	{
		static public const MOVEMENT_COST:Number = 1.0;
		static public const STRAIGHT_COST:Number = 1.0;
		static public const DIAGONAL_COST:Number = Math.sqrt(2.0);

		/**
		 * A priority queue of nodes which we are actively evaluating for the path.
		 */
		private var _open:Array;

		/**
		 * A set of nodes which we have rejected for the path.
		 */
		private var _closed:Dictionary;

		function Finder()
		{
			_open = [];
		}
		
		/**
		 * Find a path from one node to another.
		 * 
		 * @param start The starting node for the path.
		 * @param goal The node we're trying to get to.
		 * @param allowSolid True to allow the path to include solid nodes.
		 * @return A linked list of Path objects, or null if a path to the goal
		 *   node couldn't be found.
		 */
		public function find(start:Node, goal:Node, goalX:Number, goalY:Number, allowSolid:Boolean = false):Path
		{
			_open.length = 0;
			_closed = new Dictionary();
			var current:Node = start;
			current._cost = 0;
			current._priority = heuristic(start, goal);
			while (current != goal)
			{
				_closed[current] = true;
				// Add each neighbor to the open queue, if it's not already there
				for each (var neighbor:Node in current.neighbors)
				{
					if (neighbor == current || (!allowSolid && neighbor.solid && neighbor != goal))
					{
						continue;
					}
					var closed:Boolean = neighbor in _closed;
					if (!closed)
					{
						var cost:Number = current._cost + movementCost(current, neighbor);
						var priority:Number = cost + heuristic(neighbor, goal);
						var opened:Boolean = _open.indexOf(neighbor) !== -1;
						// Even if it's already in the open list, we still want to add
						// update it if the cost is better than the old cost
						if (!opened || cost < neighbor._cost)
						{
							neighbor._cost = cost;
							neighbor._parent = current;
							neighbor._priority = priority;
							if (!opened)
							{
								_open[_open.length] = neighbor;
							}
						}
					}
				}
				if (_open.length === 0)
				{
					// couldn't find a path
					break;
				}
				else
				{
					_open.sortOn('_priority', Array.NUMERIC);
					current = _open.shift();
				}
			}
			return current == goal ? path(start, goal, goalX, goalY) : null;
		}

		/**
		 * Estimate a cost from the given node to the goal. Note that there is some
		 * loss of precision, as this value ends up as an integer due to the limits
		 * of PriorityQueue.
		 * 
		 * This function is currently using a diagonal heuristic, as defined by: 
		 * http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html#S9
		 * 
		 * @param n The node to start from (usually a midpoint along the path)
		 * @param goal The node we're trying to get to.
		 * @return Cost estimate, as a number.
		 */
		public function heuristic(n:Node, goal:Node):Number
		{
			var dx:Number = Math.abs(n.x - goal.x);
			var dy:Number = Math.abs(n.y - goal.y);
			var diagonal:Number = Math.min(dx, dy);
			var straight:Number = dx + dy;
			return DIAGONAL_COST * diagonal + STRAIGHT_COST * (straight - 2 * diagonal);
		}

		/**
		 * Return the cost of moving from one node to another. This is used to
		 * calculate the direct cost between neighbor nodes, and could be used to
		 * figure out a dynamic cost (e.g. based on terrain types), but I am just
		 * returning a constant for now.
		 */
		public function movementCost(n1:Node, n2:Node):Number
		{
			return MOVEMENT_COST;
		}

		/**
		 * Build a linked list of path nodes by traversing the parent nodes in
		 * reverse until we get back to the start node.
		 */
		public function path(start:Node, end:Node, endX:Number, endY:Number):Path
		{
			var path:Path = null;
			if (end.x != endX || end.y != endY)
			{
				// Make sure we get right to our goal coordinates, instead of
				// just to the center of the nearest grid node
				path = new Path(endX, endY, end, null);
			}
			path = new Path(end.x, end.y, end, path);
			var current:Node = end;
			while (current != start)
			{
				current = current._parent;
				path = new Path(current.x, current.y, current, path);
			}
			return path;
		}
	}
}
