package dungeon.utilities
{
	import dungeon.structure.Decor;
	import dungeon.structure.Nodemap;
	
	/**
	 * ...
	 * @author MM
	 */
	public class LevelInfoHolder
	{
		public var structure:String;
		public var collisions:String;
		public var nodes:Nodemap;
		public var decor:Decor;
		public var items:Array;
		public var creatures:Array;

		public function LevelInfoHolder() {
			items = new Array();
			creatures = new Array();
		}

	}
}