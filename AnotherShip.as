package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	/**
	 * ...
	 * @author MM
	 */
	public class AnotherShip extends Entity
	{
		[Embed(source = 'assets/player.png')]
		private const SHIP:Class;
		
		public function AnotherShip() 
		{
			graphic = new Image(SHIP);
			x = 100;
			y = 100;
			setHitbox(42, 21);
			type = "npcShip";
		}
		
		override public function update():void {
		}
		
	}

}