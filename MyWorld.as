package  
{
	import net.flashpunk.World;
	/**
	 * ...
	 * @author MM
	 */
	public class MyWorld extends World
	{
		
		public function MyWorld() 
		{
			add(new MyEntity);
			add(new AnotherShip);
		}
		
	}

}