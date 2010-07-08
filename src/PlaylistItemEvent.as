package {
	import flash.events.Event;
	
	/**
	 * プレイリストアイテムイベント
	 * @author toru@loopsketch.com
	 */
	public class PlaylistItemEvent extends Event {
		
		public static const ADD_PLAYLIST_ITEM:String = "add_playlist_item";

		public function PlaylistItemEvent(type:String = ADD_PLAYLIST_ITEM, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);			
		} 
		
		public override function clone():Event { 
			return new PlaylistItemEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("AddPlaylistItemEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}	
	}	
}
