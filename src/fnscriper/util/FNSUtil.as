package fnscriper.util
{
	import flash.filters.DropShadowFilter;
	
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
				else if (text.charAt(0) == "$" && FNSFacade.instance.model.vars.hasOwnProperty(text))
					result += FNSFacade.instance.model.vars[text] 
				else
					result += text;
			}
			return result;
		}
		
		public static function decodeNumber(v:String,errorReturnSource:Boolean = true):Object
		{
			v = decodeNumaliasReplace(v);
			var vars:Object = FNSFacade.instance.model.vars;
			for (var p:String in vars)
			{
				if (p.charAt(0) == "%")
					v = replaceAll(v,p,vars[p]);
			}
			var result:Number = OperatorUtil.exec(v);
			if (isNaN(result))
				return errorReturnSource ? v : NaN;
			else
				return result;
		}
		
		private static function replaceAll(str:String,oldValue:String,newValue:String):String
		{
			var newStr:String = str;
			do
			{
				str = newStr;
				newStr = str.replace(oldValue,newValue);
			}
			while (newStr != str)
			return newStr;
		}
		
		public static function decodeNumaliasReplace(v:String):String
		{
			var result:String = v;
			var nums:Object = FNSFacade.instance.runner.numalias;
			for (var p:String in nums)
				result = result.replace(new RegExp("\\b" + p + "\\b","g"),nums[p]);
			
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
	}
}