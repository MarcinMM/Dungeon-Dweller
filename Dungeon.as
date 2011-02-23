package  
{
	import net.flashpunk.World;
	/**
	 * ...
	 * @author MM
	 */
	public class Dungeon extends World
	{
		public static var player:Player;

		public static const MAP_WIDTH:Number = 800;
		public static const MAP_HEIGHT:Number = 600;
		public static const TILE_WIDTH:Number = 20;
		public static const TILE_HEIGHT:Number = 20;
		public static const TILESX:Number = MAP_WIDTH/TILE_WIDTH;
		public static const TILESY:Number = MAP_HEIGHT/TILE_HEIGHT;
		
		public function Dungeon() 
		{
			Dungeon.player = new Player;
			add(player);
			add(new Level);
			add(new LevelMask);
			add(new AnotherShip);
		}
		
	}

}