package {
	import flash.events.Event;
	
	/**
	 * ワークスペースの更新終了イベント
	 * @author toru@loopsketch.com
	 */
	public class UpdatedWorkspaceEvent extends Event {
		
		public static const COMPLETE:String = "updated_complete_workspace";

		public function UpdatedWorkspaceEvent(type:String = COMPLETE, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new UpdatedWorkspaceEvent(type, bubbles, cancelable);
		} 

		public override function toString():String { 
			return formatToString("UpdatedWorkspaceEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}	
}
