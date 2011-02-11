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