package fnscriper
{
	import avmplus.getQualifiedClassName;
	
	import flash.geom.Point;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;

	public class FNSVO
	{
		/**
		 * 变量
		 */
		public var vars:Object = {};
		/**
		 * 当前位标
		 */
		public var step:int = 0;
		/**
		 * 调用堆
		 */
		public var callLayer:Array = [];
		/**
		 * 调用堆参数
		 */
		public var callLayerParam:Array = [];
		
		/**
		 * 循环堆
		 */
		public var forLayer:Array = [];
		/**
		 * 循环堆参数
		 */
		public var forLayerParam:Array = [];
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
		 * 图片
		 */
		public var sp:Object = {};
		
		/**
		 * 背景音乐
		 */
		public var bgm:String = "";
		
		/**
		 * 按钮定义
		 */
		public var btn:Object = {};
		
		/**
		 * 按钮预载图片
		 */
		public var btndef:String = "";
		
		/**
		 * 文本是否显示
		 */
		public var texton:Boolean;
		
		/**
		 * 其他效果时文本框是否显示
		 */
		public var erasetextwindow:int;
		
		/**
		 * 文本框参数 
		 */
		public var textwindow:Object = {};
		
		/**
		 * 指定选项文字的颜色
		 */
		public var selectcolor:Array = [0xffffff,0x999999];
		
		/**
		 * 指定选项的音效 
		 */
		public var selectvoice:Array = ["",""]; 
		
		/**
		 * 默认速度
		 */
		public var defaultspeed:Array;
		
		/**
		 * 透明方式 leftup,copy,alpha
 		 */
		public var transmode:String = "leftup";
		
		/**
		 * 人物站立图片底端坐标  
		 */
		public var underline:int;
		
		/**
		 * 使文字框与站立图位于同一遮挡顺位 
		 */
		public var windowback:Boolean;
		
		/**
		 * 站立图相对其他对象遮挡的优先顺序
		 */
		public var humanz:int = 500;
		
		public function getVar(v:Object):Object
		{
			if (vars.hasOwnProperty(v))
				return vars[v];
			else
				return v;
		}
		
		public function setVar(key:String,v:Object):void
		{
			vars[key] = v;
		}
		
		public function getByteArray():ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(this);
			return bytes;
		}
		
		public function createFromByteArray(bytes:ByteArray):void
		{
			bytes.position = 0;
			var obj:Object = bytes.readObject();
			for (var p:String in obj)
				this[p] = obj[p];
		}
		
		public function clear():void
		{
			sp = {};
			bg = "";
			
			btndef = "";
			btn = {};
			
			bgm = "";
		}
		
	}
}