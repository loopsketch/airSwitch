package  
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.*;
	import flash.utils.Timer;
	import flash.utils.ByteArray;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	import mx.controls.Alert;

	import com.adobe.crypto.MD5;
	import com.adobe.crypto.MD5Stream;
	import com.adobe.serialization.json.JSON;
	//import ch.capi.net.CompositeMassLoader;


	/**
	 * メディア同期
	 * @author toru@loopsketch.com
	 */
	public class MediaSyncronizer extends Timer {

		private var _display:XML = null;
		private var _media:XMLList;
		private var _mediaSet:Array;

		//private var _cml:CompositeMassLoader;


		public function MediaSyncronizer(display:XML, media:XMLList) {
			super(500, 1);
			_display = display;
			_media = media;

			//_cml = new CompositeMassLoader();
			addEventListener(TimerEvent.TIMER, run);
			start();
		}

		/** ディスプレイへのベースURL取得 */
		private final function baseURL():String {
			var address:String = "127.0.0.1";
			if (_display) address = _display.address.text();
			return "http://" + address + ":9090";
		}

		/** 保存ファイル取得 */
		private final function getFile(path:String):File {
			return new File("app-storage:/datas/" + _display.address + "/" + path);			
		}

		public final function run(event:TimerEvent):void {
			trace("thread start");
			var map:Object = new Object();
			for (var i:int = 0; i < _media.length(); i++) {
				var items:XMLList = _media[i].movie;
				items += _media[i].image;
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
			getFileStatus();
		}

		/** ファイル情報取得 */
		public final function getFileStatus():void {
			if (_mediaSet.length > 0) {
				var media:String = _mediaSet.shift();
				var loader:URLLoader = new URLLoader();
				var request:URLRequest = new URLRequest(baseURL() + "/files?path=" + media);
				request.useCache = false;
				loader.addEventListener(Event.COMPLETE, function(event:Event):void {
					var json:String = event.target.data;
					try {
						var result:Object = JSON.decode(json);
						// files.name/size/modified/md5
						trace("result: " + result.files.name);
						var file:File = getFile(result.path);
						var doDownloading:Boolean = true;
						if (file.exists) {
							if (file.size != parseInt(result.files.size)) {
								downloadFile(result.path);
							} else {
								getFileStatus();
							}
						} else {
							downloadFile(result.path);
						}
					} catch (error:Error) {
						trace(error.message + ":" + json);
					}
				});
				loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
					trace("I/O error: " + event);
					//Alert.show("ワークスペースが読込めません.ディスプレイの設定を確認してください.");
					getFileStatus();
				});
				loader.load(request);
			} else {
				trace("cpmplete files");
			}
		}

		/** ファイルダウンロード */
		public final function downloadFile(path:String):void {
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			var request:URLRequest = new URLRequest(baseURL() + "/download?path=" + path);
			request.useCache = false;
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				var fs:FileStream = new FileStream();
				var file:File = new File("app-storage:/datas/" + _display.address + "/" + path);
				try {
					fs.open(file, FileMode.WRITE);
					fs.writeBytes(event.target.data);
					fs.close();
					trace("download: " + path);
				} catch (error:Error) {
					trace(error.message);
				}
				getFileStatus();
			});
			loader.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void {
				// trace(event.bytesLoaded + "/" + event.bytesTotal);
			});

			loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
				trace("I/O error: " + event);
			});
			loader.load(request);
		}
	}
}
