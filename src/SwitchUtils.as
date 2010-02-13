package  
{
	import flash.filesystem.*;

	import com.adobe.utils.NumberFormatter;


	/**
	 * ユーティリティクラス
	 * @author toru@loopsketch.com
	 */
	public class SwitchUtils {		

		private static function format(num:int, width:int):String {
			var zero:String = Math.pow(10, width - 1).toString().substr(1);
			return (zero + num.toString()).substr(-width);
		}

		public static function formatDate(date:Date):String {
			var d:String = format(date.fullYear, 4) + "-" + format(date.month + 1, 2) + "-" + format(date.date, 2);
			var t:String = format(date.hours, 2) + ":" + format(date.minutes, 2) + ":" + format(date.seconds, 2);
			var tz:String = (-date.timezoneOffset >= 0?"+":"") + format(-date.timezoneOffset / 60, 2) + ":" + format(-date.timezoneOffset % 60, 2);
			return d + "T" + t + tz;
		}

		/** ディスプレイ情報保存 */
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
			var s:String = null;
			var id:int = 1;
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

		public static function checkImageFileExt(path:String):Boolean {
			var allows:Array = [".png", ".jpg", ".bmp"];
			for (var i:int = 0; i < allows.length; i++) {
				if (path.toLocaleLowerCase().substr(path.length - allows[i].length) == allows[i]) return true;
			}
			return false;
		}

		public static function checkMovieFileExt(path:String):Boolean {
			var allows:Array = [".mp4", ".mpg", ".mov", ".wmv", ".avi"];
			for (var i:int = 0; i < allows.length; i++) {
				if (path.toLocaleLowerCase().substr(path.length - allows[i].length) == allows[i]) return true;
			}
			return false;
		}
	}
}