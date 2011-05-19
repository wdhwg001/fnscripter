package fnscriper.display
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
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
	import fnscriper.events.TickEvent;
	import fnscriper.events.ViewEvent;
	import fnscriper.util.FNSUtil;
	import fnscriper.util.Tick;
	
	public class TextWindow extends Sprite
	{
		public var textField:TextField;
		public var selectedMode:Boolean;
		
		public var background:Image;
		
		public var historyText:Array = [];
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
			this.textField.antiAliasType = AntiAliasType.ADVANCED;
			this.textField.gridFitType = GridFitType.NONE;
			this.textField.defaultTextFormat = new TextFormat(facade.model.defaultfont,12,0xFFFFFF);
			this.addChild(this.textField);
			
			this.addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		public function clear():void
		{
			textField.text = "";
			
			background.source = "";
			selectedMode = false;
			
			historyText = [];
			historyIndex = -1;
			
			stopTween();
		}
		 
		private function init(e:Event):void
		{
			Tick.instance.addEventListener(TickEvent.TICK,tickHandler);
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
				if (historyIndex != -1 && historyIndex < historyText.length - 1)
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
			}
		}
		
		public function showHistory(isDown:Boolean = false):void
		{
			if (historyText.length <= 1 || selectedMode)
				return;
			
			if (!isDown)
			{
				if (historyIndex == -1)
					historyIndex = historyText.length - 2;//进入回顾
				else
					historyIndex--;
			}
			else
			{
				if (historyIndex != -1)
					historyIndex++;
			}
			
			if (historyIndex > historyText.length - 1)
				historyIndex = historyText.length - 1;
			
			if (historyIndex < 0)
				historyIndex = 0;
			
			if (historyIndex == historyText.length - 1)
			{
				historyIndex = -1;//取消回顾
				showText(historyText[historyText.length - 1]);
			}
			else
			{
				showText(historyText[historyIndex]);
			}
		}
		
		protected function tickHandler(event:TickEvent):void
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
				textField.text = "";
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
					}
					else
					{
						facade.runner.isTextWait = false;
						facade.runner.doNext();
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
			{
				var c:uint = parseInt(v.slice(1),16);
				var bmd:BitmapData = new BitmapData(r - x,b - y,false,c);
				background.loadBitmapData(bmd);
			}
			else
			{
				background.source = v;
			}
		}
		
		public function putText(v:String):void
		{
			historyIndex = -1;
			historyText.push(v);
			if (historyText.length > 100)
				historyText.shift();
		
			showText(v);
		}
		
		public function select(list:Array):void
		{
			putText(list.join("\n"));
			selectedMode = true;
		}
		
		public function textclear():void
		{
			showText("");
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
		
		public function showText(v:String):void
		{
			textField.embedFonts = facade.model.embedFonts;
			text = v;
			
			textField.text = "";
			tweenIndex = 0;
			
			tween();
		}
		
		private var tweenTimer:Timer;
		private var text:String;
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
			var a:String = text.charAt(tweenIndex);
			if (a == "&")
			{
				model.defaultcolor = 0;
				tweenIndex++;
			}
			else if (a == "#")
			{
				s = text.slice(tweenIndex + 1,tweenIndex + 7);
				model.defaultcolor = parseInt(s,16);
				tweenIndex += s.length + 1;
			}
			else if (text.slice(tweenIndex,tweenIndex + 2) == "!s")
			{
				var s:String;
				if (text.slice(tweenIndex,tweenIndex + 3) == "!sd")
				{
					s = "d";
					model.textspeed = facade.model.defaultspeed[facade.model.defaultspeedIndex];
				}
				else
				{
					s = FNSUtil.readNumber(text,tweenIndex + 2);
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
				if (!facade.runner.isSkip)
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
				if (!facade.runner.isSkip)
				{
					stopTween();
					waitTimer = setTimeout(next,int(s));
				}
			}
			else if (a == "@")
			{
				tweenIndex++;
				if (!facade.runner.isSkip)
					stopTween();
			}
			else if (a == "\\")
			{
				tweenIndex++;
				isNewPage = true;
				if (!facade.runner.isSkip)
					stopTween();
			}
			else if (a == "_")
			{
				tweenIndex++;
				isIgnoreClickStr = true;
			}
			else
			{
				isIgnoreClickStr = false;
				
				textField.appendText(a);
				textField.setTextFormat(new TextFormat(model.defaultfont,null,historyIndex != -1 ? 0xFFFF00 : model.defaultcolor),textField.text.length - 1,textField.text.length);
				tweenIndex++;
				
				if (model.clickstr.indexOf(a) != -1)
					stopTween();
			}
			
			if (tweenIndex >= text.length)
				stopTween();
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
	}
}