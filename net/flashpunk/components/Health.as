package net.flashpunk.components
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import net.flashpunk.components.AlarmComponent;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.Signal;
	
	/**
	 * A health component, which handles hurting an death, with signals.
	 */
	public class Health extends AlarmComponent
	{
		/**
		 * Entity should be healed by this much every second.
		 */ 
		public var healPerSecond:Number = 0;
		
		/**
		 * This signal is dispatched whenever the entity is hurt.
		 *
		 * <listing version="3.0">
		 * health.onHurt.add(function(damage:Number, hurter:Entity, ):void {
		 * 	trace("ow! hurt for", damage, "damage!");
		 * });
		 * </listing>
		 */
		public var onHurt:Signal = new Signal;
		
		/**
		 * This signal is dispatched whenever the entity is killed.
		 * 
		 * <listing version="3.0">
		 * health.onKilled.add(function(killer:Entity):void {
		 * 	trace("ugh! i'm dead ;_;");
		 * });
		 * </listing>
		 */
		public var onKilled:Signal = new Signal;
		
		/**
		 * If true, the entity will be recycled when it is killed.
		 */
		public var recycleKilled:Boolean = true;
		
		/**
		 * Constructor.
		 * @param	maxHealth		Maximum amount of health the entity can have.
		 * @param	recycledKilled		True if the entity should be recycled when it is killed.
		 */
		function Health(maxHealth:Number=1, recycleKilled:Boolean=true)
		{
			this.recycleKilled = recycleKilled;
			_maxHealth = maxHealth;
			super(1);
		}
		
		/** @private */
		override public function alarm():void
		{
			if (alive) health += healPerSecond;
		}
		
		/**
		 * True if the entity's health is greater than zero.
		 */
		public function get alive():Boolean
		{
			return _health > 0;
		}
		
		/**
		 * True if the entity's health is zero.
		 */
		public function get dead():Boolean
		{
			return _health <= 0;
		}
		
		/**
		 * Amount of health. Note that setting this to zero will NOT dispatch
		 * onHurt or onKilled. You must use hurt() or kill() for that.
		 */
		public function get health():Number { return _health; }
		public function set health(value:Number):void
		{
			_health = FP.clamp(value, 0, _maxHealth);
			if (_text) _text.text = String(int(_health));
		}
		
		/**
		 * Percentage of health, from 0 to 1.
		 */
		public function get healthPercent():Number
		{
			return FP.clamp(_health / _maxHealth, 0, 1);
		}
		
		/**
		 * Like healthPercent, but takes healPerSecond into account to give a
		 * smooth value between heal ticks.
		 */
		public function get smoothedHealthPercent():Number
		{
			return FP.clamp((_health + alarmPercent * healPerSecond) / _maxHealth, 0, 1);
		}
		
		/**
		 * Hurt this entity. This dispatches onHurt. If damage is greater than
		 * or equal to its remaining health, it will be killed.
		 * @param	damage		Amount of damage to deal to the entity.
		 * @param	hurter		Entity that is hurting this entity, or null.
		 */
		public function hurt(damage:Number, hurter:Entity=null):void
		{
			_timer = duration;
			if (alive)
			{
				if (damage > 0)
				{
					damage = damage < _health ? damage : _health;
					health -= damage;
				}
				onHurt.dispatch(damage, hurter);
				if (dead) kill(hurter);
			}
		}
		
		/**
		 * Kill the entity, zeroing the health. This dispatches onKilled, and
		 * will recycle the entity if recycleKilled is true.
		 * @param	killer		Entity that killed this entity, or null.
		 */
		public function kill(killer:Entity=null):void
		{
			health = 0;
			onKilled.dispatch(killer);
			if (recycleKilled && entity && entity.world)
			{
				entity.world.recycle(entity);
			}
		}
		
		/**
		 * Maximum amount of health that the entity can have.
		 */
		public function get maxHealth():Number { return _maxHealth; }
		public function set maxHealth(value:Number):void
		{
			_maxHealth = value;
			_health = FP.clamp(_health, 0, value);
		}
		
		/**
		 * Renders a health number next to the entity, if text is visible.
		 */
		override public function render(target:BitmapData, point:Point, camera:Point):void
		{
			if (_text && _text.visible) _text.render(target, point, camera);
		}
		
		/**
		 * Resets the health back to maximum.
		 */
		override public function reset():void
		{
			super.reset();
			_health = _maxHealth;
		}
		
		/**
		 * The text object for displaying health. Defaults to hidden. Set
		 * health.text.visible = true to render.
		 */
		public function get text():Text
		{
			if (!_text)
			{
				_text = new Text(String(int(_health)), 0, 0, 20, 20);
				_text.size = 8;
				_text.x = 0;
			}
			return _text;
		}
		
		public function set text(value:Text):void
		{
			_text = value;
		}
		
		/** @private */ protected var _health:Number = 0;
		/** @private */ protected var _maxHealth:Number = 1;
		/** @private */ protected var _text:Text;
	}
}
