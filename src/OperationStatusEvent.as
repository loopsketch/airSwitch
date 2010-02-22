package {
	import flash.events.Event;
	
	/**
	 * ステータスイベント
	 * @author toru@loopsketch.com
	 */
	public class OperationStatusEvent extends Event {
		
		public static const OPERATION_STATUS:String = "operation_status";

		private var _text:String;

		public function OperationStatusEvent(text:String, type:String = OPERATION_STATUS, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
			_text = text;
		} 

		public final function get text():String {
			return _text;
		}

		public final function set text(text:String):void {
			_text = text;
		}

		public override function clone():Event { 
			return new OperationStatusEvent(_text, type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("OperationStatusEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}	
	}	
}
