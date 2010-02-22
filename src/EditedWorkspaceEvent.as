package {
	import flash.events.Event;
	
	/**
	 * ワークスペースの編集イベント
	 * @author toru@loopsketch.com
	 */
	public class EditedWorkspaceEvent extends Event {
		
		public static const EDITED:String = "edited_workspace";

		public function EditedWorkspaceEvent(type:String = EDITED, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);			
		} 
		
		public override function clone():Event { 
			return new EditedWorkspaceEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("WorkspaceEditedEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}	
	}	
}
