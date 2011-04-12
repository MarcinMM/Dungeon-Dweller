package dungeon.utilities 
{
	/**
	 * Simple holder of weapon prototype data from XML
	 * Used with actual Weapon class for generating weapons 
	 * This is for pure reading of data, no logic in here as weapon generation is dependent on many factors
	 * Names are unique; weapon generation can do a search based on that and return weapon vars
	 * @author MM
	 */
	public class WeaponPrototype 
	{
		
		public var name:String;
		public var attack:uint;
		public var defense:uint;
		public var pen:Number;
		public var hands:uint;
		public var offhand:Boolean;
		public var offhandRating:Number;
		public var crit:Number;
		public var strengthReq:uint;
		public var type:String;
				
		public function WeaponPrototype() 
		{
			
		}
		
	}

}