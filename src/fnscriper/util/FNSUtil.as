package fnscriper.util
{
	import flash.filters.DropShadowFilter;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.text.TextFormat;
	
	import flashx.textLayout.elements.BreakElement;
	
	import fnscriper.FNSFacade;
	import fnscriper.FNSVO;

	final public class FNSUtil
	{
		public static function split(str:String,delim:String):Array
		{
			var result:Array = [];
			var start:int;
			var end:int;
			while (end < str.length)
			{
				if (str.charAt(end) == "\"")
				{
					end++;
					while (str.charAt(end) != "\"" && end < str.length)
						end++;//引号内
					
					end++;
				}
				if (str.charAt(end) == delim)
				{
					result.push(str.slice(start,end))
					while (str.charAt(end) == delim && end < str.length)
						end++;//忽略重复空位
					
					start = end;
				}
				else
				{
					end++;
				}
			}
			result.push(str.slice(start,end));
			return result;
		}
		
		public static function createTextFormat(o:Object):TextFormat
		{
			var tf:TextFormat = new TextFormat();
			for (var p:String in o)
				tf[p] = o[p];
			return tf;
		}
		
		public static function readNumber(s:String,startIndex:int):String
		{
			var result:String = "";
			var ch:String = s.charAt(startIndex);
			while (startIndex < s.length && (ch >= "0" && ch <= "9" || ch == "."))
			{
				result += s.charAt(startIndex);
				startIndex++;
				ch = s.charAt(startIndex);
			}
			return result;
		}
		
		public static function readArrayBody(s:String,startIndex:int):String
		{
			var index:int = startIndex;
			while (index < s.length)
			{
				var ch:String = s.charAt(index);
				index++;
				if (ch != "[")
					break;
				var num:String = readNumber(s,index);
				index+=num.length;
				ch = s.charAt(index);
				index++;
			}
			return s.slice(startIndex,index)
		}
		
		public static function readLine(line:String):String
		{
			var p:int = 0;
			var result:String = "";
			while (p < line.length && (line.charAt(p) == " " || line.charAt(p) == "\t"))
				p++;
			
			var inQ:Boolean;
			while (p < line.length)
			{
				var ch:String = line.charAt(p);
				if (!inQ && ch == ";")
					break;
				
				if (ch == "\"")
					inQ = !inQ;
					
				result += line.charAt(p);
				p++;
			}
			return result;
		}
	}
}