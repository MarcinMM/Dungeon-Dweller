package dungeon.utilities 
{
	import dungeon.contents.Item;
    /**
     * Function result 
     * @author MM
     */
    public class resultItem 
    {
        
        public var found:Boolean;
        public var item:Item;
                
        public function resultItem(initFound:Boolean, initItem:Item=null) 
        {
            found = initFound;

            if (initItem != null) {
                item = initItem;
            } 
        }
    }
}