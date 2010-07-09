package  
{
	import flash.filesystem.*;

	import com.adobe.utils.NumberFormatter;
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;


	/**
	 * ユーティリティクラス
	 * @author toru@loopsketch.com
	 */
	public final class SwitchUtils {		

		[Bindable]
		public static var SCHEDULE_TYPES:ArrayCollection = new ArrayCollection([
			{id:0, label:"毎日", regexp:"\\*\\s+\\*\\s+\\*\\s+\\d+\\s+\\d+\\s+\\*"}, // * * * n n *
			{id:1, label:"毎週", regexp:"\\*\\s+\\*\\s+\\*\\s+\\d+\\s+\\d+\\s+\\d+"}, // * * * n n n
			{id:2, label:"指定日", regexp:"\\d+\\s+\\d+\\s+\\d+\\s+\\d+\\s+\\d+\\s+\\*"} // n n n n n *
		]);

		[Bindable]
		public static var SCHEDULE_WEEKS:ArrayCollection = new ArrayCollection([
			{id:0, label:"日曜日", week:0}, // to 6, where 0 = Sunday, 1 = Monday, ..., 6 = Saturday)
			{id:1, label:"月曜日", week:1},
			{id:2, label:"火曜日", week:2},
			{id:3, label:"水曜日", week:3},
			{id:4, label:"木曜日", week:4},
			{id:5, label:"金曜日", week:5},
			{id:6, label:"土曜日", week:6}
		]);

		[Bindable]
		public static var SCHEDULE_COMMANDS:ArrayCollection = new ArrayCollection([
			{label:"プレイリスト移動", command:"playlist"},
			{label:"輝度変更", command:"luminance"}
		]);


		// ローカルモードのdisplayかどうか
		public static function isLocalMode(display:XML):Boolean {
			return (display && display.address.text().indexOf("127.0.0.") == 0);
		}

		/** 編集ディスプレイの取得 */
		public static function getEditDisplay(displays:XML):XML {
			if (displays) {
				for (var i:int = 0; i < displays.display.length(); i++) {
					if (displays.display[i].edit == 'true') {
						return displays.display[i];
					}
				}
			}
			return null;
		}

		/** ベースURL生成 */
		public static function selectedDisplayToBaseURL(displays:XML):String {
			var address:String = "127.0.0.1";
			var display:XML = getEditDisplay(displays);
			if (display) address = display.address.text();
			return baseURL(address);
		}

		/** ベースURL生成 */
		public static function baseURL(address:String):String {
			if (address.indexOf(":") == -1) address = address + ":9090";
			var id:String = address.replace(/\.|:/g, "_");
			return "http://" + address + "/" + id;
		}

		public static function format(num:int, width:int):String {
			var zero:String = Math.pow(10, width - 1).toString().substr(1);
			return (zero + num.toString()).substr(-width);
		}

		/** 日付時刻を文字列にフォーマット */
		public static function formatDate(date:Date):String {
			var d:String = format(date.fullYear, 4) + "-" + format(date.month + 1, 2) + "-" + format(date.date, 2);
			var t:String = format(date.hours, 2) + ":" + format(date.minutes, 2) + ":" + format(date.seconds, 2);
			var tz:String = (-date.timezoneOffset >= 0?"+":"") + format(-date.timezoneOffset / 60, 2) + ":" + format(-date.timezoneOffset % 60, 2);
			return d + "T" + t + tz;
		}

		/** 日付時刻文字列からDate生成 */
		// 2005-01-01 12:00:00
		public static function parseSortedDate(s:String):Date {
			var data:Array = StringUtil.trim(s).split(/-|\s+|T|:/);
			if (data.length >= 6) {
				return new Date(parseInt(data[0]), parseInt(data[1]) - 1, parseInt(data[2]), parseInt(data[3]), parseInt(data[4]), parseInt(data[5]))
			}
			return null;
		}

		/** xmlをファイル保存 */
		public static function saveXML(xml:XML, file:File):Boolean {
			var fs:FileStream = new FileStream();
			try {
				fs.open(file, FileMode.WRITE);
				var s:String = '<?xml version="1.0" encoding="UTF-8" ?>\n'; 
				s += xml.toXMLString();
				fs.writeUTFBytes(s); 
				trace('xml saved: ' + file.nativePath);
				return true;
			} catch (error:Error) {
				trace("<Error> " + error.message);
			} finally {
				fs.close();		
			}
			return false;
		}

		/** 空きIDをサーチしてIDを生成して返します */
		public static function createNewID(xml:XMLList, prefix:String):String {
			var id:int = 1;
			var s:String = createID(prefix, id);
			try {
				while ((xml.(@id == (s = createID(prefix, id)))).length() > 0) {
					// 空きIDサーチ
					id++;
				}
			} catch (error:Error) {
				trace(error.message);
				// s = createID(prefix, id);
			}
			return s;
		}

		/** ID生成 */
		public static function createID(prefix:String, id:int):String {
			var s:String = "00000" + id;
			if (id > 99999) {
				s = id.toString();
			}
			return prefix + s.substr(-5);
		}

		/** 拡張子チェック */
		public static function checkFileExt(path:String):Boolean {
			if (checkImageFileExt(path) || checkMovieFileExt(path)) return true;
			return false;
		}

		/**　静止画ファイルの拡張子チェック　*/
		public static function checkImageFileExt(path:String):Boolean {
			var allows:Array = [".png", ".jpg", ".bmp"];
			for (var i:int = 0; i < allows.length; i++) {
				if (path.toLocaleLowerCase().substr(path.length - allows[i].length) == allows[i]) return true;
			}
			return false;
		}

		/**　動画ファイルの拡張子チェック　*/
		public static function checkMovieFileExt(path:String):Boolean {
			var allows:Array = [".mp4", ".mpg", ".mov", ".wmv", ".avi"];
			for (var i:int = 0; i < allows.length; i++) {
				if (path.toLocaleLowerCase().substr(path.length - allows[i].length) == allows[i]) return true;
			}
			return false;
		}

		/** スケジュールをスケジュールタイプに変換 */
		public static function scheduleToType(s:XML):Object {
			for each (var m:Object in SwitchUtils.SCHEDULE_TYPES) {
				var pat:RegExp = new RegExp(m.regexp);
				if (pat.test(s.@time)) return m;
			}
			return null;
		}

		public static function scheduleToWeek(s:XML):Object {
			var data:Array = s.@time.split(/\s+/, 6);
			if (data[5] != '*') {
				return SCHEDULE_WEEKS[parseInt(data[5])];
			}
			return null;
		}

		/** スケジュール文字列をスケジュールタイプに変換 */
		public static function scheduleToCommand(s:XML):Object {
			if (s.text().length() > 0) {
				var c:Array = s.text().split(/\s+/, 2);
				if (c.length == 2) {
					for each (var m:Object in SwitchUtils.SCHEDULE_COMMANDS) {
						if (c[0] == m.command) {
							m.data = c[1];
							return m;
						}
					}
				}				
			}
			return null;
		}
	}
}