package dungeon.utilities 
{
    /**
     * Function result 
     * @author MM
     */
    public class resultItem 
    {
        
        public var found:Boolean;
        public var item:Item;
                
        public function resultItem(initFound:Boolean, initItem:Item) 
        {
            found = initFound;

            if (initItem != null) {
                item = initItem;
            } 
        }
    }
}