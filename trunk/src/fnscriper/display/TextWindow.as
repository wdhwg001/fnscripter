package fnscriper.display
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import fnscriper.FNSFacade;
	import fnscriper.FNSRunner;
	import fnscriper.events.TickEvent;
	import fnscriper.events.ViewEvent;
	import fnscriper.util.FNSUtil;
	import fnscriper.util.Tick;

	public class TextWindow extends Sprite
	{
		public var textField:TextField;
		public var enabled:Boolean = true;
		public var selectedMode:Boolean;
		
		public var background:Image;
		
		public var speed:int;
		
		private var historyText:Array = [];
		private var historyIndex:int = -1;
		
		public function get facade():FNSFacade
		{
			return FNSFacade.instance;
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
			
			this.addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		public function clear():void
		{
			textField.text = "";
			
			background.source = "";
			selectedMode = false;
			enabled = true;
			
			historyText = [];
			historyIndex = -1;
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
			if (historyText.length <= 1)
				return;
			
			if (!isDown)
			{
				if (historyIndex == -1)
					historyIndex = historyText.length - 2;
				else
					historyIndex--;
			}
			else
			{
				if (historyIndex != -1)
					historyIndex++;
			}
			
			if (historyIndex > historyText.length - 1)
				historyIndex = historyText.length - 1
			
			if (historyIndex < 0)
				historyIndex = 0;
			
			showText(historyText[historyIndex],true);
		}
		
		protected function tickHandler(event:TickEvent):void
		{
			if (selectedMode && historyIndex == -1)
			{
				var line:int = textField.getLineIndexAtPoint(textField.mouseX,textField.mouseY);
				var len:int = textField.numLines;
				for (var i:int = 0;i < len;i++)
				{
					var start:int = textField.getLineOffset(i);
					var end:int = start + textField.getLineLength(i);
					textField.setTextFormat(new TextFormat(null,null,facade.model.selectcolor[i == line ? 0 : 1]),start,end);
				}
			}
		}
		
		protected function clickHandler(event:MouseEvent):void
		{
			if (!visible || !enabled)
				return;
				
			if (selectedMode && historyIndex == -1)
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
			if (!visible || !enabled)
				return;
			
			if (!selectedMode)
			{
				facade.runner.isWait = false;
				facade.runner.doNext();
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
			
			this.speed = data.speed;
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
		
		public function showText(v:String,isHistory:Boolean = false):void
		{
			textField.embedFonts = facade.model.embedFonts;
			textField.defaultTextFormat = new TextFormat(facade.model.defaultfont,null,isHistory ? 0xFFFF00 : facade.model.defaultcolor);
			textField.text = v;
		}
		
		public function select(list:Array):void
		{
			putText(list.join("\n"));
			selectedMode = true;
		}
	}
}