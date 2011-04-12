package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	/**
	 * ...
	 * @author MM
	 */
	public class NPC extends Entity
	{
		[Embed(source = 'assets/player.png')] private const NPCGraphic:Class;
		
		public function NPC() 
		{
			graphic = new Image(NPCGraphic);
			x = 100;
			y = 100;
			setHitbox(20, 20);
			type = "npc";
		}
		
		override public function update():void {
		}
		
	}

}