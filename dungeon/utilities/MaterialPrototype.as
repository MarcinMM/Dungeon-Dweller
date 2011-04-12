package dungeon.utilities 
{
	/**
	 * Simple holder of weapon prototype data from XML
	 * Used with actual Weapon class for generating weapons 
	 * This is for pure reading of data, no logic in here as weapon generation is dependent on many factors
	 * Names are unique; weapon generation can do a search based on that and return weapon vars
	 * @author MM
	 */
	public class MaterialPrototype 
	{
		
		public var name:String;
		public var modifier:Number;
		public var rarity:Number;
		public var upperRarityThreshold:uint;
		public var upperRarityIncrement:Number;
		public var lowerRarityThreshold:uint;
		public var lowerRarityIncrement:Number;
		public var shatter:Number;
		public var burn:Number;
		public var rust:Number;
		public var specialAgainst:String;
		public var specialModifier:Number;
				
		public function MaterialPrototype() 
		{
			
		}
		
	}

}