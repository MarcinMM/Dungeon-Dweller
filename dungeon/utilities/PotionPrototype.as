package dungeon.utilities 
{
    /**
     * Simple holder of weapon prototype data from XML
     * Used with actual Weapon class for generating weapons 
     * This is for pure reading of data, no logic in here as weapon generation is dependent on many factors
     * Names are unique; weapon generation can do a search based on that and return weapon vars
     * @author MM
     */
    public class PotionPrototype 
    {
        
        public var name:String;
        public var instant:String;
        public var lasting:String;
        public var duration:uint;
        public var value:uint;
        public var defaultColor:String;
                
        public function PotionPrototype() 
        {
            
        }
        
    }

}