package  
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.*;
	import flash.utils.Timer;
	import flash.utils.ByteArray;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLStream;
	import mx.controls.Alert;

	import com.adobe.crypto.MD5;
	import com.adobe.crypto.MD5Stream;
	import com.adobe.serialization.json.JSON;
	//import ch.capi.net.CompositeMassLoader;


	/**
	 * メディア同期
	 *
	 * @author toru@loopsketch.com
	 */
	public class MediaSyncronizer extends EventDispatcher {

		private var _timer:Timer;
		private var _workDir:File = null;
		private var _address:String = null;
		private var _baseURL:String = null;
		private var _workspace:XML = null;
		private var _mediaSet:Array = null;
		private var _size:int = 0;

		//private var _cml:CompositeMassLoader;


		public function MediaSyncronizer(workDir:File, displays:XML, workspace:XML) {
			_workDir = workDir;
			_address = SwitchUtils.getEditDisplay(displays).address;
			_baseURL = SwitchUtils.baseURL(displays);
			_workspace = workspace;

			//_cml = new CompositeMassLoader();
			_timer = new Timer(100, 1);
			_timer.addEventListener(TimerEvent.TIMER, run);
			_timer.start();
		}

		/** 保存ファイル取得 */
		private final function getFile(path:String):File {
			return _workDir.resolvePath("datas/" + _address + "/" + path);			
		}

		public final function running():Boolean {
			return _timer.running || _workspace != null;
		}

		public final function run(event:TimerEvent):void {
			trace("thread start");
			var map:Object = new Object();
			var medias:XMLList = _workspace.medialist.item;
			for (var i:int = 0; i < medias.length(); i++) {
				var items:XMLList = medias[i].movie;
				items += medias[i].image;
				for (var j:int = 0; j < items.length(); j++) {
					map[items[j].text()] = "";
				}
			}
			_mediaSet = new Array();
			for (var name:String in map) {
				if (name.indexOf("switch-data:") == 0) {
					name = name.substr(12);
				}
				_mediaSet.push(name);
			}
			_size = _mediaSet.length;
			getFileStatus();
		}

		/** ファイル情報取得 */
		public final function getFileStatus():void {
			if (_mediaSet.length > 0) {
				var media:String = _mediaSet.shift();
				var status:String = "(" + (_size - _mediaSet.length) + "/" + _size + ") " + media + "チェック中...";
				dispatchEvent(new OperationStatusEvent(status));
				var loader:URLLoader = new URLLoader();
				var request:URLRequest = new URLRequest(_baseURL + "/files?path=" + media);
				request.useCache = false;
				loader.addEventListener(Event.COMPLETE, function(event:Event):void {
					var json:String = event.target.data;
					try {
						var result:Object = JSON.decode(json);
						// files.name/size/modified/md5
						trace("result: " + result.files.name);
						var file:File = getFile(result.path);
						var downloading:Boolean = false;
						if (file.exists) {
							// 存在する場合は比較する
							var size:int = parseInt(result.files.size);
							var modified:Date = SwitchUtils.parseSortedDate(result.files.modified);
							if (file.size != size) {
								// ファイルサイズが異なれば更新
								downloading = true;
							} else if (file.modificationDate < modified) {
								// リモートの方が更新日時が新しい
								if (false) {
									trace('check md5');
									var localMD5:String;
									var fs:FileStream = new FileStream();
									try {
										trace('load local file');
										fs.open(file, FileMode.READ);
										var buf:ByteArray = new ByteArray();
										fs.readBytes(buf);
										trace('calculate md5');
										var md5:MD5Stream = new MD5Stream();
										md5.update(buf);
										localMD5 = md5.complete();
										trace('match result: ' + (localMD5 == result.files.md5));
									} catch (error:Error) {
										trace('failed md5 check: ' + error.message);
									}
									fs.close();
									if (result.files.md5 != localMD5) {
										// ファイル内容が異なる場合ダウンロード
										downloading = true;
									}									
								} else {
									downloading = true;									
								}
							}
						} else {
							// 存在しない場合はダウンロード
							downloading = true;
						}
						if (downloading) {
							downloadFile(result.path);
						} else {
							getFileStatus();
						}
					} catch (error:Error) {
						trace(error.message + ":" + json);
					}
				});
				loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
					trace("I/O error: " + event);
					// Alert.show("error!");
					getFileStatus();
				});
				loader.load(request);
			} else {
				trace("complete transfer files");
				var deletes:XMLList = _workspace.deletes.file;
				if (deletes.length() > 0) {
					dispatchEvent(new OperationStatusEvent("不要ファイルの削除処理中..."));
					for (var i:int = 0; i < deletes.length(); i++) {
						var name:String = deletes[i].text();
						if (name.indexOf("switch-data:") == 0) {
							name = name.substr(12);
						}
						var file:File = getFile(name);
						try {
							if (file && file.exists) {
								file.deleteFile();
								trace("delete: " + file.nativePath);
							}
						} catch (error:Error) {
						}
					}
				}
				dispatchEvent(new OperationStatusEvent("同期完了しました"));
				_workspace = null;
			}
		}

			//try {
			//	trace("stored: " + path);
			//} catch (error:Error) {
			//	trace("failed write file: " + error.message);
			//}
		/** ファイルダウンロード */
		public final function downloadFile(path:String):void {
			var status:String = "(" + (_size - _mediaSet.length) + "/" + _size + ") " + path + "ダウンロード中...";
			dispatchEvent(new OperationStatusEvent(status));
			var stream:URLStream = new URLStream();
			var request:URLRequest = new URLRequest(_baseURL + "/download?path=" + path);
			var fs:FileStream = new FileStream();
			var file:File = _workDir.resolvePath("datas/" + _address + "/" + path);
			fs.open(file, FileMode.WRITE);
			stream.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void {
				var buf:ByteArray = new ByteArray();
				//buf.clear();
				if (stream.connected) stream.readBytes(buf);
				fs.writeBytes(buf);
			});
			stream.addEventListener(Event.COMPLETE, function(event:Event):void {
				stream.close();
				fs.close();
				getFileStatus();
			});
			stream.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
				trace("I/O error: " + event);
				var status:String = "!(" + (_size - _mediaSet.length) + "/" + _size + ") " + path + "ダウンロード中に異常が発生しました.";
				dispatchEvent(new OperationStatusEvent(status));
			});
			stream.load(request);
		}
	}
}
