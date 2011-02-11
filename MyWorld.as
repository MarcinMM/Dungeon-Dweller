package  
{
	import net.flashpunk.World;
	/**
	 * ...
	 * @author MM
	 */
	public class MyWorld extends World
	{
		public static var player:Player;
		public function MyWorld() 
		{
			MyWorld.player = new Player;
			add(player);
			add(new Level);
			add(new AnotherShip);
		}
		
	}

}