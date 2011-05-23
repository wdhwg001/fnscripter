package fnscriper
{
	import avmplus.getQualifiedClassName;
	
	import flash.geom.Point;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	
	import flashx.textLayout.elements.BreakElement;
	
	import fnscriper.display.Image;

	public class FNSVO
	{
		/**
		 * 字符串变量
		 */
		public var strs:Object = {};
		/**
		 * 数值变量
		 */
		public var nums:Object = {};
		/**
		 * 数组变量
		 */
		public var arrays:Object = {};
		/**
		 * 变量最小范围
		 */
		public var intlimitmin:Object = {};
		/**
		 * 变量最大范围
		 */
		public var intlimitmax:Object = {};
		/**
		 * 当前位标
		 */
		public var step:int = 0;
		/**
		 * 缓存返回时候的横向位标
		 */
		public var step2:int = 0;
		/**
		 * 调用堆
		 */
		public var callStack:Array = [];//{step,step2,params}
		
		/**
		 * 循环堆
		 */
		public var forStack:Array = [];//{step,step2,param,end,forstep}
		
		/**
		 * 字体 
		 */
		public var defaultfont:String = "default";
		
		/**
		 * 字体颜色 
		 */
		public var defaultcolor:uint = 0xFFFFFF;
		
		/**
		 * 默认阴影偏移X
		 */
		public var shadedistanceX:int = 1;
		
		/**
		 * 默认阴影偏移Y
		 */
		public var shadedistanceY:int = 1;
		
		
		/**
		 * 使用嵌入字体
		 */
		public var embedFonts:Boolean;
		
		/**
		 * 背景
		 */
		public var bg:String = "";
		
		/**
		 * 背景尺寸
		 */
		public var bgalia:Object = null;//{x,y,w,h}
		
		/**
		 * 图片
		 */
		public var sp:Object = {};//{url,x,y,alpha,visible};
		
		/**
		 * 背景音乐
		 */
		public var bgm:String = "";
		
		/**
		 * 背景音乐重复
		 */
		public var bgmloops:int = int.MAX_VALUE;
		
		public var dwaveloop:Object = {};
		
		public var dwaveload:Object = {};
		
		/**
		 * 点击音效
		 */
		public var clickvoice:Array = ["",""]
		
		/**
		 * 按钮定义
		 */
		public var btn:Object = {};//{x,y,w,h,ox,oy};或者图片id
		
		/**
		 * 快速显示图片 
		 */
		public var blt:Object = {};//{x,y,w,h,sx,sy,sw,sh};显示区域左上角x坐标,y坐标,显示区域宽,高,预载图像截取左上角x坐标,y坐标,截取部分宽,高
		
		/**
		 * 按钮预载图片
		 */
		public var btndef:String = "";
		
		/**
		 * 文本是否显示
		 */
		public var texton:Boolean;
		
		/**
		 * 每页只显示一行文本
		 */
		public var linepage:Boolean;
		
		/**
		 * 其他效果时文本框是否显示
		 */
		public var erasetextwindow:int;
		
		/**
		 * 文本框参数 
		 */
		public var textwindow:Object = {};//{tx,ty,tw,th,fw,fh,fg,lg,speed,bold,shadow,skin,wx,wy,wr,wb}
											//头文字左上角x坐标,y坐标,每行字数,行数,字宽,字高,字间距,行间距,单字显示速度毫秒数,粗体状态,阴影状态,窗体颜色,窗体左上角x坐标,y坐标,右下角x坐标,y坐标;
		
		/**
		 * 指定选项文字的颜色
		 */
		public var selectcolor:Array = [0xffffff,0x999999];
		
		/**
		 * 指定选项的音效 
		 */
		public var selectvoice:Array = ["",""]; 
		
		/**
		 * 自动等待文本
		 */
		public var clickstr:String = "";
		
		/**
		 * 资源目录 
		 */
		public var nsadir:String = "";
		
		/**
		 * 默认速度
		 */
		public var defaultspeed:Array = [10,5,1];
		
		/**
		 * 选择的默认速度（用!sd设置）
		 */
		public var defaultspeedIndex:int = 1;
		
		/**
		 * 回顾颜色 
		 */
		public var lookbackcolor:uint = 0xFFFF00;
		
		/**
		 * 文字速度
		 */
		public var textspeed:int = 5;
		
		/**
		 * 透明方式 leftup,copy,alpha
 		 */
		public var transmode:String = "leftup";
		
		/**
		 * 人物站立图片底端坐标  
		 */
		public var underline:int = 479;
		
		/**
		 * 使文字框与站立图位于同一遮挡顺位 
		 */
		public var windowback:Boolean;
		
		/**
		 * 站立图相对其他对象遮挡的优先顺序
		 */
		public var humanz:int = 500;
		
		/**
		 * 是否允许保存
		 */
		public var saveon:Boolean = true;
		
		/**
		 * 内部计时
		 */
		public var timer:int;
		
		/**
		 * 效果定义
		 */
		public var effect:Object = {};
		
		/**
		 * 效果定义长度
		 */
		public var effectlen:Object = {};
		/**
		 * 效果定义图片
		 */
		public var effectimg:Object = {};
		
		/**
		 * 效果延迟时间
		 */
		public var effectblank:int;
		
		/**
		 * 单色效果
		 */
		public var monocro:String = "";
		
		/**
		 * 反色效果 1:先于单色,2,后于单色
		 */
		public var nega:int;
		
		public var allsphide:Boolean;
		
		public var cursor:Array = [null,null];//{url,x,y,absset};
		public var mousecursor:String = "";
		
		public var mode_saya:Boolean;
		
		public var defvoicecol:int = 100;
		public var defsevol:int = 100;
		public var defmp3vol:int = 100;
		
		/**
		 * 图片缩放 
		 */
		public var imgscale:Number = 1.0;
		
		/**
		 * 执行getspsize是否中断游戏
		 */
		public var getspsizewait:int;
		
		public function setVar(key:String,v:Object):void
		{
			var type:String = key.charAt(0);
			var index:int;
			switch (type)
			{
				case "%":
					index = int(key.slice(1));
					if (intlimitmin.hasOwnProperty(index) && v < intlimitmin[index])
						v = intlimitmin[index];
					
					if (intlimitmax.hasOwnProperty(index) && v > intlimitmax[index])
						v = intlimitmax[index];
					
					nums[index] = int(v);
					break;
				case "$":
					index = int(key.slice(1));
					strs[index] = v.toString();
					break;
				case "?":
					var arr:Array = key.slice(1).split(/[\[\]]+/);
					if (arr[arr.length - 1] == "")
						arr.pop();
					var result:Object = arrays;
					do
					{
						index = arr.shift();
						if (arr.length == 0)
						{
							result[index] = int(v);
						}
						else 
						{
							if (!result.hasOwnProperty(index) || result[index] is Number)
								result[index] = {};
							result = result[index];
						}
					}
					while (arr.length > 0)
					break;
			}
		}
		
		public function getVar(key:String):Object
		{
			var type:String = key.charAt(0);
			var index:int;
			switch (type)
			{
				case "%":
					index = int(key.slice(1));
					return nums[index];
				case "$":
					index = int(key.slice(1));
					return strs[index];
				case "?":
					var arr:Array = key.slice(1).split(/[\[\]]+/);
					if (arr[arr.length - 1] == "")
						arr.pop();
					var result:Object = arrays;
					do
					{
						result = result[arr.shift()];
					}
					while (arr.length > 0)
					return result;
			}
			return key;
		}
		
		public function getNumVar(key:String):int
		{
			return int(getVar(key));
		}
		
		public function getByteArray():ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(this);
			bytes.compress();
			return bytes;
		}
		
		public function createFromByteArray(bytes:ByteArray):void
		{
			bytes.position = 0;
			try
			{
				bytes.uncompress();
			} 
			catch(error:Error) 
			{}
			var obj:Object = bytes.readObject();
			
			for (var p:String in obj)
			{
//				if (p == "nums" || p == "strs" || p == "arrays")
//				{
//					for (var p2:String in obj.vars)
//					{
//						if (int(p2) < 200 || obj[p][p2])
//							this[p][p2] = obj[p][p2];
//					}
//				}
//				else
				{
					this[p] = obj[p];
				}
			}
			
		}
		
		public function clear():void
		{
			var p:String;
			for (p in nums)
			{
				if (int(p) < 200)
					delete nums[int(p)];
			}
			for (p in strs)
			{
				if (int(p) < 200)
					delete strs[int(p)];
			}
			for (p in arrays)
			{
				if (int(p) < 200)
					delete arrays[int(p)];
			}
			
			sp = {};
			bg = "";
			
			btndef = "";
			btn = {};
			blt = null;
			
			bgm = "";
			bgmloops = uint.MAX_VALUE;
			dwaveload = {};
			dwaveloop = {};
			
			effect = {};
			effectlen = {};
			monocro = "";
			nega = 0;
		}
		
	}
}