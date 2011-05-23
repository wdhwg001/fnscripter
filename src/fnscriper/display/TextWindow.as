package fnscriper.display
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import fnscriper.FNSFacade;
	import fnscriper.FNSRunner;
	import fnscriper.FNSVO;
	import fnscriper.events.ViewEvent;
	import fnscriper.util.FNSUtil;
	
	public class TextWindow extends Sprite
	{
		public var textField:TextField;
		public var selectedMode:Boolean;
		
		public var background:Image;
		public var cursorimg:Image;
		
		public var historyList:Array = [];
		public var historyIndex:int = -1;
		
		/**
		 * 下面的文字为新页 
		 */
		private var isNewPage:Boolean;
		private var isIgnoreClickStr:Boolean;
		
		public function get facade():FNSFacade
		{
			return FNSFacade.instance;
		}
		
		public function get model():FNSVO
		{
			return FNSFacade.instance.model;
		}
		
		public function TextWindow()
		{
			this.background = new Image();
			this.addChild(this.background);
			
			this.textField = new TextField();
			this.textField.wordWrap = true;
			this.textField.selectable = false;
			this.textField.defaultTextFormat = new TextFormat(facade.model.defaultfont,12,0xFFFFFF);
			this.addChild(this.textField);
			
			this.cursorimg = new Image();
			this.addChild(this.cursorimg);
			
			this.addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		public function clear():void
		{
			textField.text = "";
			
			background.source = "";
			selectedMode = false;
			
			historyList = [];
			historyIndex = -1;
			
			stopTween();
		}
		 
		private function init(e:Event):void
		{
			this.addEventListener(Event.ENTER_FRAME,tickHandler);
			this.addEventListener(MouseEvent.CLICK,clickHandler);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
		}
		
		protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.UP)
			{
				showHistory();
			}
			else if (event.keyCode == Keyboard.DOWN)
			{
				if (historyIndex != -1)
					showHistory(true);
				else
					facade.view.dispatchViewEvent();
			}
		}
		
		protected function mouseWheelHandler(event:MouseEvent):void
		{
			if (event.delta > 0)
			{
				showHistory();
			}
			else
			{
				if (historyIndex != -1)
					showHistory(true);
				else
					facade.view.dispatchViewEvent();
			}
		}
		
		private var historyCache:Object = {};
		
		public function showHistory(isNext:Boolean = false):void
		{
			if (historyList.length == 0 || selectedMode)
				return;
			
			if (isNext)
			{
				historyIndex--;
				if (historyIndex < 0)
				{
					//退出回顾
					textField.htmlText = historyCache.textField;
					tweenIndex = historyCache.tweenIndex;
					text = historyCache.text;
					
					tween();
				}
			}
			else
			{
				if (historyIndex == -1)
				{
					//进入回顾
					historyCache.textField = textField.htmlText;
					historyCache.tweenIndex = tweenIndex;
					historyCache.text = text;
				}
				historyIndex++;
				if (historyIndex > historyList.length - 1)
					historyIndex = historyList.length - 1;
			}
			
			
			if (historyIndex >= 0)
			{
				textField.text = "";
				tweenIndex = 0;
					
				text = historyList[historyIndex];
					
				stopTween();
				tweenToEnd();
			}
		}
		
		protected function tickHandler(event:Event):void
		{
			if (selectedMode && historyIndex == -1 && facade.runner.isBtnMode)
			{
				var line:int = textField.getLineIndexAtPoint(textField.mouseX,textField.mouseY);
				var len:int = textField.numLines;
				for (var i:int = 0;i < len;i++)
				{
					var start:int = textField.getLineOffset(i);
					var end:int = start + textField.getLineLength(i);
					
					try
					{
						textField.setTextFormat(new TextFormat(null,null,facade.model.selectcolor[i == line ? 0 : 1]),start,end);
					} 
					catch(error:Error) 
					{
					}
				}
			}
		}
		
		protected function clickHandler(event:MouseEvent):void
		{
			if (!visible)
				return;
				
			if (selectedMode && historyIndex == -1 && facade.runner.isBtnMode)
			{
				var line:int = textField.getLineIndexAtPoint(textField.mouseX,textField.mouseY);
				if (line != -1)
				{
					selectedMode = false;
					facade.view.dispatchViewEvent(line);
				}
			}
		}
		
		/**
		 * 显示下一段文本 
		 * 
		 */
		public function next():void
		{
			if (!visible || facade.runner.isWait)
				return;
			
			if (waitTimer)
				clearTimeout(waitTimer);
			
			if (isNewPage)
			{
				isNewPage = false;
				
				var newText:String = text.slice(tweenIndex);
				text = text.slice(0,tweenIndex);
				nextPage();
				text = newText;
			}
			
			if (!selectedMode)
			{
				if (tweenTimer)
				{
					tweenToEnd();
				}
				else
				{
					if (tweenIndex < text.length)
					{
						tween();
						if (model.clickvoice[0])
							FNSUtil.createSound(model.clickvoice[0],0).play();
					}
					else
					{
						facade.runner.isTextWait = false;
						facade.runner.doNext();
						
						if (model.clickvoice[1])
							FNSUtil.createSound(model.clickvoice[1],0).play();
					}
				}
			}
		}
		
		public function setWindow(data:Object):void
		{
			textField.x = data.tx;
			textField.y = data.ty;
			textField.width = data.tw * (data.fw + data.fg) + 6;
			textField.height = data.th * (data.fh + data.lg) + 5;
			var tf:TextFormat = new TextFormat(null,data.fw,null,data.bold);
			tf.leading = data.lg;
			tf.letterSpacing = data.fg;
			textField.defaultTextFormat = tf;
			textField.filters = FNSUtil.getTextFilter(data.shadow);
			
			facade.model.textspeed = data.speed;
			this.setSkin(data.skin,data.wx,data.wy,data.wr,data.wb);
		}
		
		public function setSkin(v:String,x:int,y:int,r:int,b:int):void
		{
			background.x = x;
			background.y = y;
			if (v.charAt(0)=="#")
				background.loadRect(r - x,b - y,parseInt(v.slice(1),16))
			else
				background.source = v;
		}
		
		public function nextPage():void
		{
			if (text)
				historyList.unshift(text);
			
			textField.text = "";
			tweenIndex = 0;
			
			text = "";
		}
		
		public function putText(v:String):void
		{
			textField.embedFonts = model.embedFonts;
			
			historyIndex = -1;
			if (model.linepage)
				nextPage();
			
			if (text)
				text += "\n";
			
			text += v;
			
			tween();
		}
		
		public function select(list:Array):void
		{
			putText(list.join("\n"));
			selectedMode = true;
		}
		
		public function textclear():void
		{
			textField.text = "";
			tweenIndex = 0;
			
			tween();
		}
		
		public function locate(x:int = 0,y:int = 0):void
		{
			for (var i:int = 0;i < x;i++)
				text += " ";
			for (i = 0;i < y;i++)
				text += "\n";
			
			tween();
		}
		public function br():void
		{
			text += "\n";
			tween();
		}
		
		private var tweenTimer:Timer;
		private var text:String = "";
		private var tweenIndex:int;
		private var waitTimer:int;
		
		public function tween():void
		{
			stopTween();
			
			var sp:int = facade.model.textspeed;
			if (historyIndex != -1 || facade.runner.isSkip || selectedMode)
				sp = 0;
			
			if (sp)
			{
				tweenTimer = new Timer(sp,int.MAX_VALUE)
				tweenTimer.addEventListener(TimerEvent.TIMER,tweenUpdateHandler);
				tweenTimer.start();
			}
			else
			{
				tweenToEnd();
			}
		}
		
		public function tweenToEnd():void
		{
			while (tweenIndex < text.length)
				tweenUpdateHandler();
		}
		
		private function tweenUpdateHandler(e:TimerEvent = null):void
		{
			cursorimg.visible = false;
			
			var a:String = text.charAt(tweenIndex);
			if (a == "&")
			{
				if (historyIndex == -1)
					model.defaultcolor = 0;
				tweenIndex++;
			}
			else if (a == "#")
			{
				s = text.slice(tweenIndex + 1,tweenIndex + 7);
				if (historyIndex == -1)
					model.defaultcolor = parseInt(s,16);
				tweenIndex += s.length + 1;
			}
			else if (text.slice(tweenIndex,tweenIndex + 2) == "!s")
			{
				var s:String;
				if (text.slice(tweenIndex,tweenIndex + 3) == "!sd")
				{
					s = "d";
					if (historyIndex == -1)
						model.textspeed = facade.model.defaultspeed[facade.model.defaultspeedIndex];
				}
				else
				{
					s = FNSUtil.readNumber(text,tweenIndex + 2);
					if (historyIndex == -1)
						model.textspeed = int(s);
				}
				if (tweenTimer)
					tweenTimer.delay = model.textspeed;
				tweenIndex += s.length + 2;
			}
			else if (text.slice(tweenIndex,tweenIndex + 2) == "!w")
			{
				s = FNSUtil.readNumber(text,tweenIndex + 2);
				tweenIndex += s.length + 2;
				if (historyIndex == -1 && !facade.runner.isSkip)
				{
					stopTween();
					facade.runner.isWait = true;
					waitTimer = setTimeout(function ():void{
						facade.runner.isWait = false;
						next();
					},int(s));
				}
			}
			else if (text.slice(tweenIndex,tweenIndex + 2) == "!d")
			{
				s = FNSUtil.readNumber(text,tweenIndex + 2);
				tweenIndex += s.length + 2;
				if (historyIndex == -1 && !facade.runner.isSkip)
				{
					stopTween();
					waitTimer = setTimeout(next,int(s));
				}
			}
			else if (a == "@")
			{
				tweenIndex++;
				if (historyIndex == -1 && !facade.runner.isSkip)
				{
					showCursor(0);
					stopTween();
				}
			}
			else if (a == "\\")
			{
				tweenIndex++;
				if (historyIndex == -1)
					isNewPage = true;
				if (historyIndex == -1 && !facade.runner.isSkip)
				{
					showCursor(1);
					stopTween();
				}
			}
			else if (a == "_")
			{
				tweenIndex++;
				if (historyIndex == -1)
					isIgnoreClickStr = true;
			}
			else
			{
				if (historyIndex == -1)
					isIgnoreClickStr = false;
				
				textField.appendText(a);
				textField.setTextFormat(new TextFormat(model.defaultfont,null,historyIndex != -1 ? model.lookbackcolor : model.defaultcolor),textField.text.length - 1,textField.text.length);
				tweenIndex++;
				
				if (historyIndex == -1 && model.clickstr.indexOf(a) != -1)
					stopTween();
			}
			
			if (historyIndex == -1 && tweenIndex >= text.length && tweenTimer)
			{
				stopTween();
				if (model.linepage) //未被中断的行末自动读取下一条
					showCursor(1);	
				else
					next();
			}
		}
		
		public function stopTween():void
		{
			if (tweenTimer)
			{
				tweenTimer.removeEventListener(TimerEvent.TIMER,tweenUpdateHandler);
				tweenTimer.stop();
				
				tweenTimer = null;
			}
		}
		
		public function showCursor(type:int):void
		{
			var o:Object = model.cursor[type];
			if (o)
			{
				var rect:Rectangle = textField.getCharBoundaries(textField.text.length - 1);
				if (rect)
				{
					cursorimg.visible = true;
					cursorimg.source = o.url;
					cursorimg.x = int(o.x);
					cursorimg.y = int(o.y);
					if (o.absset != 1)
					{
						cursorimg.x += int(o.x) + rect.x + textField.x + int(textField.defaultTextFormat.size);
						cursorimg.y += int(o.y) + rect.y + textField.y;
					}
				}
			}
			else
			{
				cursorimg.visible = false;
			}
		}
	}
}