package dungeon.contents 
{
    import dungeon.structure.Point;
    import net.flashpunk.Entity;
    import net.flashpunk.graphics.*;
    import dungeon.utilities.GC;
	import dungeon.utilities.PotionPrototype;

    /**
     * ...
     * @author MM
     */
    public class Potion extends Item 
    {
        [Embed(source = '../../assets/potion.png')] private const POTION:Class;

        public const TILE_INDEX:uint = 0;

        // now vars
        public var name:String;
		public var modifier:Number;
		public var effect:String;
        public var instant:uint;
        public var lasting:uint;
        public var duration:uint;
		public var fumeDuration:uint;
        public var value:uint;
        
        private var potionColors:Array = 
            [
                "Black", 
                "Violet", 
                "Yellow", 
                "Blue", 
                "Red", 
                "Green", 
                "White", 
                "Silver", 
                "Clear"
            ];
        private var potionFX:Array = 
            [
                "Smoky",
                "Cloudy",
                "Oily",
                "Swirling",
                "Clear",
                "Glowing",
                "Fizzy"
            ];
                
        public function Potion() 
        {
            var randPotion:uint = Math.round(Math.random() * (Dungeon.dataloader.potions.length - 1));
            var randFX:String = potionFX[Math.round(Math.random() * potionFX.length)];
            var potionPrototype:PotionPrototype = Dungeon.dataloader.potions[randPotion];

            var randColor:String;
            
            instant = potionPrototype.instant;
            lasting = potionPrototype.lasting;
            duration = potionPrototype.duration;
            fumeDuration = Math.round(duration / 5);
            value = potionPrototype.value;

            if (potionPrototype.defaultColor != "FALSE") {
                randColor = potionPrototype.defaultColor;
            } else {
                randColor = potionColors[Math.round(Math.random() * potionColors.length)];
            }

            super();
            
            // set which tile this weapon is, based on type probably
            // this will be used for overlaying the player character to show equipment
            // at the moment defaulting to 0
            tileIndex = TILE_INDEX;
            DESCRIPTION = randFX + " " + randColor + " potion";
            ITEM_TYPE = GC.C_ITEM_POTIONS;

            graphic = new Image(POTION);
        }
        
    }

}