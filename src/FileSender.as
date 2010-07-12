package  
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	//import flash.events.TimerEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.*;
	//import flash.utils.Timer;
	//import flash.utils.ByteArray;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	//import flash.net.URLStream;
	import mx.controls.Alert;

	import com.adobe.serialization.json.JSON;


	/**
	 * ファイル送信
	 *
	 * @author toru@loopsketch.com
	 */
	public class FileSender extends EventDispatcher {

		private var FONT_FILE_PAT:RegExp = /ttf|ttc/i;

		private var _address:String = null;
		private var _file:File = null;
		private var _path:String = null;


		public function FileSender(address:String, file:File) {
			_address = address;
			_file = file;
		}

		public function exec():void {
			sendFile();
		}

		private final function sendFile():void {
			trace("send " + _address + " -> " + _file.name);
			var request:URLRequest = new URLRequest(SwitchUtils.baseURL(_address) + "/upload");
			request.method = URLRequestMethod.POST;
			var variables:URLVariables = new URLVariables();
			if (FONT_FILE_PAT.test(_file.extension)) {
				// フォント
				_path = "/fonts/" + _file.name;
			} else {
				_path = "/" + _file.name;
			}
			variables["path"] = _path;
			request.data = variables;
			_file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, function(event:DataEvent):void {
				var json:String = event.data;
				try {
					var result:Object = JSON.decode(json);
					if (result.upload) {
						// 正常終了
						addFont();
						return;
					} else {
						trace("feedback failed upload");
					}
				} catch (error:Error) {
					trace(error.message + ":" + json);
				}
				dispatchEvent(new OperationStatusEvent("!アップロード中に異常が発生しました.再生中か準備済みでないか確認してください"));
			});
			_file.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
				trace(event);
				dispatchEvent(new OperationStatusEvent("!アップロード中に異常が発生しました."));
			});
			_file.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void {
				var p:int = 100 * event.bytesLoaded / event.bytesTotal;
				dispatchEvent(new OperationStatusEvent(_file.name + "(" + p + "%)"));
			});
			dispatchEvent(new OperationStatusEvent(_file.name + "(0%)"));
			_file.upload(request, "file");
		}

		/** フォント追加 */
		private function addFont():void {
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(SwitchUtils.baseURL(_address) + "/download?path=workspace.xml");
			request.useCache = false;
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				var workspace:XML = new XML(event.target.data);
				if (FONT_FILE_PAT.test(_file.extension)) {
					// フォント追加
					var file:XML = <file />;
					file.setChildren("switch-data:" + _path);
					if (!workspace.hasOwnProperty('fonts')) {
						workspace.appendChild(<fonts/>);
					}
					workspace.fonts.appendChild(file);
					uploadWorkspace(workspace);
				} else {
					dispatchEvent(new OperationStatusEvent("送信完了しました"));
				}
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
				trace(event);
				dispatchEvent(new OperationStatusEvent("!ワークスペースダウンロード中に異常が発生しました."));
			});
			loader.load(request);
		}

		/** ワークスペースの送信 */
		private function uploadWorkspace(workspace:XML):void {
			var tmp:File = File.createTempFile();
			var fs:FileStream = new FileStream();
			try {
				fs.open(tmp, FileMode.WRITE);
				var s:String = '<?xml version="1.0" encoding="UTF-8" ?>\n'; 
				s += workspace.toXMLString();
				fs.writeUTFBytes(s);
			} catch (error:Error) {
				trace("<Error> " + error.message);
			} finally {
				fs.close();
			}
			if (tmp.exists) {
				trace("send workspace " + _address);
				var request:URLRequest = new URLRequest(SwitchUtils.baseURL(_address) + "/upload");
				request.method = URLRequestMethod.POST;
				var variables:URLVariables = new URLVariables();
				variables["path"] = "/workspace.xml";
				request.data = variables;
				tmp.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, function(event:DataEvent):void {
					tmp.deleteFile();
					var json:String = event.data;
					try {
						var result:Object = JSON.decode(json);
						if (result.upload) {
							// 正常終了
							dispatchEvent(new OperationStatusEvent("送信完了しました"));
							updateWorkspace();
							return;
						} else {
							trace("feedback failed upload");
						}
					} catch (error:Error) {
						trace(error.message + ":" + json);
					}
					dispatchEvent(new OperationStatusEvent("!ワークスペースアップロード中に異常が発生しました."));
				});
				tmp.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
					trace(event);
					dispatchEvent(new OperationStatusEvent("!ワークスペースアップロード中に異常が発生しました."));
				});
				//tmp.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void {
				//	var p:int = 100 * event.bytesLoaded / event.bytesTotal;
				//	var s:String = tmp.name + "(" + p + "%)";
				//	dispatchEvent(new OperationStatusEvent(s));
				//});
				tmp.upload(request, "file");
			}
		}

		/** ワークスペース更新 */
		private function updateWorkspace():void {
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				trace("update complete");
				var loader:URLLoader = URLLoader(event.currentTarget);
				var json:String = loader.data;
				try {
					var result:Object = JSON.decode(json);
					if (result.update) {
						dispatchEvent(new OperationStatusEvent("ワークスペースを更新しました"));
					} else {
						dispatchEvent(new OperationStatusEvent("!ワークスペースの更新に失敗しました"));
					}
				} catch (error:Error) {
					trace(error.message + ":" + json);
				}
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void {
				trace('remote display no result');
			});
			loader.load(new URLRequest(SwitchUtils.baseURL(_address) + "/update"));
		}
	}
}
