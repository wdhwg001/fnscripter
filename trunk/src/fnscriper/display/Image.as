package fnscriper.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.sensors.Accelerometer;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.engine.FontWeight;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import flashx.textLayout.elements.BreakElement;
	
	import fnscriper.FNSAsset;
	import fnscriper.FNSFacade;
	import fnscriper.FNSVO;
	import fnscriper.FNSView;
	import fnscriper.util.FNSUtil;

	public class Image extends Bitmap
	{
		public var id:String;
		public var url:String;
		/**
		 * 透明方式：
		 * s -文本模式
		 * a -alpha透明；
		 * l -以图像左上角像素颜色为透明色；
		 * r -以图像右上角像素颜色为透明色；
		 * c -无透明；
		 * #rrggbb -真彩色图片指定透明色；
		 * !pal -索引色图片指定透明色（色板位置） 
		 */
		public var transparenceMode:String;
		public var animLength:int = 1;
		public var animFrameTime:int;
		public var isLoading:Boolean;
		private var _animMode:int = 3;
		
		public function get view():FNSView
		{
			return FNSFacade.instance.view;
		}
		public function get facade():FNSFacade
		{
			return FNSFacade.instance;
		}

		/**
		 * 1 -播放一次；2 -循环播放；3 -不播放 
		 */
		public function get animMode():int
		{
			return _animMode;
		}
		
		public function set animMode(value:int):void
		{
			if (value != 3 && _animMode == 3)
			{
				prevTime = getTimer();
				addEventListener(Event.ENTER_FRAME,tickHandler);
			}
			else if (value == 3 && _animMode != 3)
			{
				prevTime = 0;
				removeEventListener(Event.ENTER_FRAME,tickHandler);
			}
			_animMode = value;
		}
		
		public var fontWidth:int;
		public var fontHeight:int;
		public var fontGap:int;
		public var text:String;
		public var color:uint;
		public var color2:uint;
		
		private var _cellIndex:int;

		public var bitmapDataSource:Array;
		
		private var _source:String;

		public function get source():String
		{
			return _source;
		}

		public function set source(value:String):void
		{
			if (_source == value)
				return;
			
			_source = value;
			this.scaleX = this.scaleY = 1.0;
			
			if (_source.charAt(0) == ":")
			{
				var arr:Array = value.slice(1).split(";");
				url = arr[1];
				arr = arr[0].split(",");
				var mode:Array = arr[0].split("/");
				this.transparenceMode = mode[0];
				if (this.transparenceMode == "s")
				{
					if (mode.length > 1) this.fontWidth = mode[1];
					if (arr.length > 1) this.fontHeight = arr[1];
					if (arr.length > 2) this.fontGap = arr[2];
					
					if (url.charAt(0) == "#")
					{
						this.color = this.color2 = parseInt(url.slice(1,7),16);
						this.animLength = 1;
						url = url.slice(7);
					}
					
					if (url.charAt(0) == "#")
					{
						this.color2 = parseInt(url.slice(1,7),16);
						this.animLength = 2;
						url = url.slice(7);
					}
					this.text = url;
				}
				else
				{
					if (mode.length > 1) this.animLength = mode[1];
					if (arr.length > 1) this.animFrameTime = arr[1];
					if (arr.length > 2) this.animMode = arr[2];
				}
			}
			else
			{
				url = value;
			}
			
			if (transparenceMode == "s")
				loadText();
			else
				load(url);
		}
		
		public function get mouseOver():Boolean
		{
			return view.screenbm.mouseX - this.x >= 0 && view.screenbm.mouseX - this.x < this.width && 
				view.screenbm.mouseY - this.y > 0 && view.screenbm.mouseY - this.y < this.height;
		}
		
		public function get cellIndex():int
		{
			return _cellIndex;
		}
		
		public function set cellIndex(value:int):void
		{
			if (this.bitmapDataSource)
				this.bitmapData = this.bitmapDataSource[value > bitmapDataSource.length - 1 ? bitmapDataSource.length - 1 : value];
			else
				this.bitmapData = null;
			
			if (_cellIndex == value)
				return;
				
			_cellIndex = value;
			view.invalidateRender();
		}
					
		public function Image()
		{
			super();
			this.transparenceMode = FNSFacade.instance.model.transmode.charAt(0);
		}
		
		private var loader:Loader;
		private function haltLoad():void
		{
			if (loader)
			{
				try
				{
					loader.close();
				} 
				catch(error:Error) 
				{
				}
			}
		}
		public function load(v:String):void
		{
			this.haltLoad();
			this.disposeBitmapDataSource();
			
			if (!v)
				return;
			
			if (v.charAt(0) == "#")
			{
				loadRect(FNSFacade.instance.view.contentWidth,FNSFacade.instance.view.contentHeight,parseInt(v.slice(1),16));
			}
			else
			{
				_cellIndex = -1;
				isLoading = true;
				
				loader = new Loader();
				loader.load(FNSFacade.instance.asset.getURLRequest(v));
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadCompleteHandler);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadCompleteHandler);
			}
		}
		private function loadCompleteHandler(event:Event):void
		{
			isLoading = false;
			if (!loader.content)
				return;
				
			var source:BitmapData = (loader.content as Bitmap).bitmapData;
			source = transparenceBitmapData(source);
			if (animLength == 1)
			{
				this.bitmapDataSource = [source];
			}
			else
			{
				this.bitmapDataSource = [];
				var w:int = source.width / animLength;
				for (var i:int = 0;i < animLength;i++)
				{
					var bmd:BitmapData = new BitmapData(w,source.height,true,0);
					bmd.copyPixels(source,new Rectangle(w * i,0,w,source.height),new Point());
					this.bitmapDataSource[i] = bmd;
				}
				source.dispose();
			}
			loader.unload();
			loader = null;
			
			this.cellIndex = 0;
			this.autoScale();
			this.autoLayout();
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function loadRect(w:int,h:int,c:uint):void
		{
			this.disposeBitmapDataSource();
			
			var bmd:BitmapData = new BitmapData(w,h,false,c);
			this.bitmapDataSource = [bmd];
			this.cellIndex = 0;
			this.autoLayout();
		}
		
		public function loadText():void
		{
			this.disposeBitmapDataSource();
			
			this.bitmapDataSource = [];
			
			for (var i:int = 0;i < animLength;i++)
			{
				var textField:TextField = new TextField();
				textField.defaultTextFormat = new TextFormat(FNSFacade.instance.model.defaultfont,fontWidth,i == 0 ? color : color2);
				textField.autoSize = TextFieldAutoSize.LEFT;
				textField.embedFonts = FNSFacade.instance.model.embedFonts;
				textField.text = text;
				textField.filters = FNSUtil.getTextFilter();
//				textField.height = fontHeight;
				var bmd:BitmapData = new BitmapData(textField.textWidth + 3,textField.textHeight + 3,true,0);
				bmd.draw(textField);
				this.bitmapDataSource[i] = bmd;
			}
			this.cellIndex = 0;
			this.autoLayout();
		}
		
		public function loadBtndef(btndef:Loader,x:int,y:int,w:int,h:int,ox:int,oy:int):void
		{
			this.disposeBitmapDataSource();
			
			if (btndef.content is Bitmap)
			{
				completeHandler(null);
			}
			else
			{
				_cellIndex = -1;
				isLoading = true;
				btndef.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
			}
			function completeHandler(e:Event):void
			{
				isLoading = false;
				if (!loader.content)
					return;
				
				var bmd:BitmapData = (btndef.content as Bitmap).bitmapData;
				var bmd1:BitmapData = new BitmapData(w,h,true,0);
				bmd1.copyPixels(bmd,new Rectangle(x,y,w,h),new Point());
				var bmd2:BitmapData = new BitmapData(w,h,true,0);
				bmd1.copyPixels(bmd,new Rectangle(ox,oy,w,h),new Point());
				
				bitmapDataSource = [bmd1,bmd2];
				animLength = 2;
				cellIndex = 0;
				
				autoScale();
				autoLayout();
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function loadBlt(btndef:Loader,x:int,y:int,w:int,h:int,sx:int,sy:int,sw:int,sh:int):void
		{
			this.disposeBitmapDataSource();
			
			if (btndef.content is Bitmap)
			{
				completeHandler(null);
			}
			else
			{
				_cellIndex = -1;
				isLoading = true;
				btndef.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
			}
			function completeHandler(e:Event):void
			{
				isLoading = false;
				if (!btndef.content)
					return;
					
				var source:BitmapData = (btndef.content as Bitmap).bitmapData;
				var bmd:BitmapData = new BitmapData(w,h,true,0);
				bmd.copyPixels(source,new Rectangle(sx,sy,sw,sh),new Point());
				bitmapDataSource = [bmd];
				animLength = 1;
				cellIndex = 0;
			
				x = x;
				y = y;
				width = w;
				height = h;
				
				autoLayout();
				
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private var frameTime:int;
		private var prevTime:int;
		protected function tickHandler(event:Event):void
		{
			var interval:int = getTimer() - prevTime;
			prevTime = getTimer();
			
			frameTime += interval;
			while (frameTime > 0)
			{
				if (cellIndex < animLength)
					cellIndex++;
				else
				{
					if (animMode == 2)
					{
						cellIndex = 0;
					}
					else
					{
						animMode = 3;
						frameTime = 0;
					}
				}
				frameTime -= animFrameTime;
			}
		}
		
		public function transparenceBitmapData(bmd:BitmapData):BitmapData
		{
			if (bmd.transparent || transparenceMode == "c")
				return bmd;
			
			var result:BitmapData;
			if (transparenceMode == "a")
			{
				result = new BitmapData(bmd.width / 2,bmd.height,true,0);
				result.copyPixels(bmd,new Rectangle(bmd.width / 2,0,bmd.width / 2,bmd.height),new Point())
				result.applyFilter(result,result.rect,new Point(),new ColorMatrixFilter([0,0,0,0,0,
					0,0,0,0,0,
					0,0,0,0,0,
					-1/3,-1/3,-1/3,1,0]));
				result.copyPixels(bmd,new Rectangle(0,0,bmd.width / 2,bmd.height),new Point(),result,new Point())
				bmd.dispose();
			}
			else
			{
				var transparentColor:uint = 0;
				if (transparenceMode == "l")
					transparentColor = bmd.getPixel(0,0);
				else if (transparenceMode == "r")
					transparentColor = bmd.getPixel(0,bmd.width - 1)
				else if (transparenceMode.charAt(0) == "#")
					transparentColor = parseInt(transparenceMode.slice(1),16);
				
				result = new BitmapData(bmd.width,bmd.height,true,0);
				result.threshold(bmd,bmd.rect,new Point(),"==",transparentColor,0,0xFFFFFFFF,true);
				bmd.dispose();
			}
			return result;
		}
		
		public function renderToBitmapData(bmd:BitmapData):void
		{
			try
			{
				if (bitmapData)
				{
					if (this.scaleX == 1 && this.scaleY == 1)
						bmd.copyPixels(bitmapData,bitmapData.rect,new Point(x,y));
					else
						bmd.draw(bitmapData,transform.matrix,null,null,null,true);
				}
			} 
			catch(error:Error) 
			{
			}
		}
		
		private function autoScale():void
		{
			this.scaleX *= facade.model.imgscale;
			this.scaleY *= facade.model.imgscale; 
		}
		
		private function autoLayout():void
		{
			var underline:int = FNSFacade.instance.model.underline;
			switch (id)
			{
				case "l":
					x = 0;
					y = underline - height;
					break;
				case "c":
					x = (view.contentWidth - width) / 2;
					y = underline - height;
					break;
				case "r":
					x = view.contentWidth - width;
					y = underline - height;
					break;
				case "b":
					if (facade.model.bgalia)
					{
						x = facade.model.bgalia.x;
						y = facade.model.bgalia.y;
						width = facade.model.bgalia.w;
						height = facade.model.bgalia.h;
					}
					break;
			}
		}
		
		public function disposeBitmapDataSource():void
		{
			if (!bitmapDataSource)
				return;
			
			for each (var bmd:BitmapData in bitmapDataSource)
				bmd.dispose();
		}
		
		public function destory():void
		{
			disposeBitmapDataSource();
			animMode = 3;
			
			var list:Array = view.spCanvas;
			var i:int = list.indexOf(this)
			if (i != -1)
				list.splice(i,1);
			
			delete view.sp[id]
		}
	}
}