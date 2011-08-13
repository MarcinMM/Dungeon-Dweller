package net.flashpunk
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import net.flashpunk.Entity;
	
	public class Component
	{
		/**
		 * If the Component should update.
		 */
		public var active:Boolean = true;
		
		/**
		 * The Component's parent Entity.
		 */
		public var entity:Entity = null;
		
		/**
		 * If the Component should render at its position relative to its parent Entity's position.
		 */
		public var relative:Boolean = true;
		
		/**
		 * If the Component should render.
		 */
		public var visible:Boolean = true;
		
		function Component()
		{
			reset();
		}
		
		/**
		 * Override this, called when the Component is added to an entity.
		 */
		public function added():void
		{
			
		}
		
		/**
		 * Override this, called when the parent Entity is added to the world.
		 */
		public function addedToWorld():void
		{
			
		}
		
		/**
		 * Override this, called when the Component is removed from an Entity.
		 */
		public function removed(entity:Entity):void
		{
			
		}
		
		/**
		 * Override this, called when the parent Entity is removed from the world.
		 */
		public function removedFromWorld(world:World):void
		{
			
		}
		
		/**
		 * Render the Component to the screen buffer.
		 * @param	target		The bitmap to render into.
		 * @param	point		The position to draw the graphic.
		 * @param	camera		The camera offset.
		 */
		public function render(target:BitmapData, point:Point, camera:Point):void
		{
			
		}
		
		/**
		 * Override this, called when the Component should reset itself back to
		 * a default state. Called by Entity.created().
		 */
		public function reset():void
		{
			
		}
		
		/**
		 * Updates the Component,
		 */
		public function update():void
		{
			
		}
	}
}
