package skins 
{
	import flash.display.Graphics;
	import mx.skins.ProgrammaticSkin;
	
	/**
	 * ...
	 * @author ...
	 */
	public final class ListDropIndicator extends ProgrammaticSkin
	{
		
		public function ListDropIndicator() 
		{
			super();
		}

		/**
         *  @private
         */
        override protected function updateDisplayList(w:Number, h:Number):void
        {	
            super.updateDisplayList(w, h);
 
            var g:Graphics = graphics;
 
            g.clear();
            g.beginFill(0xcccccc, 1.0);
            g.drawRect(0, -2, w, 2);
        }
		
	}

}