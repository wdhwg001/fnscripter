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
		
		public static function decodeString(v:String):String
		{
			var arr:Array = split(v,"+");
			var result:String = "";
			for each (var text:String in arr)
			{
				if (text.charAt(0) == "\"" && text.charAt(text.length - 1) == "\"")
					result += text.slice(1,text.length - 1);
				else if (text.charAt(0) == "$")
					result += FNSFacade.instance.model.getVar(decodeNumaliasReplace(text)); 
				else
					result += decodeStraliasReplace(text);
			}
			return result;
		}
		
		public static function decodeNumber(v:String,errorReturnSource:Boolean = true):Object
		{
			v = decodeNumaliasReplace(v);
			var newstr:String = "";
			var index:int = 0;
			while (index < v.length)
			{
				var ch:String = v.charAt(index);
				if (ch == "%" || ch == "$" || ch == "?")
				{
					var num:String = readNumber(v,index + 1);
					if (ch == "?")
						num += readArrayBody(v,index + 1 + num.length)
					
					var r:Object = FNSFacade.instance.model.getVar(ch + num);
					if (r)
						newstr += r.toString();
					index += num.length + 1;
				}
				else
				{
					newstr += ch;
					index++;
				}
			}
			
			var result:Number = OperatorUtil.exec(newstr);
			if (isNaN(result))
				return errorReturnSource ? v : NaN;
			else
				return result;
		}
		
		public static function decodeNumaliasReplace(v:String):String
		{
			var result:String = v;
			var numalias:Object = FNSFacade.instance.runner.numalias;
			for (var p:String in numalias)
				result = result.replace(new RegExp("\\b" + p + "\\b","g"),numalias[p]);
			
			return result;
		}
		
		public static function decodeStraliasReplace(v:String):String
		{
			var result:String = v;
			var stralias:Object = FNSFacade.instance.runner.stralias;
			for (var p:String in stralias)
				result = result.replace(new RegExp("\\b" + p + "\\b","g"),stralias[p]);
			
			return result;
		}
		
		public static function getTextFilter(shadow:Number = NaN):Array
		{
			var vo:FNSVO = FNSFacade.instance.model;
			var x:int = vo.shadedistanceX;
			var y:int = vo.shadedistanceY;
			if (!isNaN(shadow))
				x = y = shadow;
			
			var l:Number = Math.sqrt(x * x + y * y);
			var r:Number = Math.atan2(y,x) / Math.PI * 180;
			return [new DropShadowFilter(l,r,0,0.5,0,0,255)];
		}
		
		public static function createTextFormat(o:Object):TextFormat
		{
			var tf:TextFormat = new TextFormat();
			for (var p:String in o)
				tf[p] = o[p];
			return tf;
		}
		
		public static function createSound(url:String,bufferTime:int = 1000):Sound
		{
			return new Sound(FNSFacade.instance.asset.getURLRequest(url),new SoundLoaderContext(bufferTime));
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
		
		private static function readArrayBody(s:String,startIndex:int):String
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