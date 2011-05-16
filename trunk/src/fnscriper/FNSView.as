package fnscriper
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import fnscriper.display.Image;
	import fnscriper.display.TextWindow;
	import fnscriper.events.ViewEvent;
	import fnscriper.util.FNSUtil;
	
	[Event(name="view_click", type="fnscriper.events.ViewEvent")]
	public class FNSView extends Sprite
	{
		public var contentWidth:int;
		public var contentHeight:int;
		
		public var background:Image;
		public var textWindow:TextWindow;
		
		public var spCanvas:Sprite;
		public var sp:Object = {};
		public var btndef:Loader;
		public var btn:Object = {};
		
		public var bgmSound:Sound;
		public var bgmChannel:SoundChannel;
		
		public var dwaveSound:Object = {};
		public var dwaveChannel:Object= {};
		
		public var handlers:Dictionary = new Dictionary();
		
		private var skipTimer:Timer;
		
		public function get facade():FNSFacade
		{
			return FNSFacade.instance;
		}
		
		public function FNSView(w:int = 800,h:int = 600)
		{
			super();
			
			this.contentWidth = w;
			this.contentHeight = h;
			
			this.graphics.beginFill(0xFFFFFF);
			this.graphics.drawRect(0,0,w,h);
			this.graphics.endFill();
			
			this.background = new Image();
			this.background.transparenceMode = "c";
			this.addChild(this.background);
			this.spCanvas = new Sprite();
			this.addChild(this.spCanvas);
			this.textWindow = new TextWindow();
			this.addChild(this.textWindow)
			
			var menu:ContextMenu = new ContextMenu();
			menu.hideBuiltInItems();
			var menuItem:ContextMenuItem = new ContextMenuItem("FNScripter 1.0.0");
			menuItem.addEventListener(ContextMenuEvent.MENU_SELECT,copyrightHandler);
			menu.customItems = [menuItem];
			this.contextMenu = menu;
			
			this.skipTimer = new Timer(0,int.MAX_VALUE);
			this.skipTimer.addEventListener(TimerEvent.TIMER,skipHandler);
			this.skipTimer.start();
				
			this.addEventListener(Event.ADDED_TO_STAGE,initHandler);
		}
		
		private function initHandler(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,initHandler);
			
			stage.addEventListener(MouseEvent.CLICK,clickHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseOverHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
		}
		
		private function copyrightHandler(e:ContextMenuEvent):void
		{
			navigateToURL(new URLRequest("http://fnscripter.googlecode.com/"),"_blank");
		}
		
		
		protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (facade.runner.isLock || !facade.runner.isWait)
				return;
			
			if (event.keyCode == Keyboard.SPACE)
				dispatchViewEvent();
			
			if (event.ctrlKey)
				facade.runner.isSkip = true;
			else
				facade.runner.isSkip = false;
		}
		
		protected function keyUpHandler(event:KeyboardEvent):void
		{
			if (facade.runner.isLock || !facade.runner.isWait)
				return;
			
			facade.runner.isSkip = false;
		}
		
		protected function mouseOverHandler(event:MouseEvent):void
		{
			if (facade.runner.isLock || !facade.runner.isWait)
				return;
			
			for (var p:* in btn)
			{
				var child:Image = btn[p];
				if (child)
					child.cellIndex = child.mouseOver ? 1 : 0;
			}
		}
		
		protected function clickHandler(event:MouseEvent):void
		{
			this.textWindow.visible = facade.model.texton;
			facade.runner.isSkip = false;
			
			if (facade.runner.isLock || !facade.runner.isWait)
				return;
			
			for (var p:* in btn)
			{
				var child:Image = btn[p];
				if (child && child.mouseOver)
				{
					dispatchViewEvent(int(p));
					return;
				}
			}
			dispatchViewEvent();
		}
		
		protected function skipHandler(event:TimerEvent):void
		{
			if (FNSFacade.instance.runner.isSkip)
				dispatchViewEvent(-1,true);
		}
		
		public function addViewHandler(e:Function):void
		{
			handlers[e] = true;
		}
		
		public function removeViewHandler(e:Function):void
		{
			delete handlers[e];
		}
		
		public function dispatchViewEvent(btnIndex:int = -1,isSkip:Boolean = false):void
		{
			var e:ViewEvent = new ViewEvent(ViewEvent.VIEW_CLICK);
			e.btnIndex = btnIndex;
			e.isSkip = isSkip;
			
			for (var handler:* in handlers)
				handler(e);
			
			if (btnIndex == -1)
				textWindow.next();
		}
		
		public function loadFromVO():void
		{
			clear();
			
			var model:FNSVO = facade.model;
			for (var p:* in model.sp)
			{
				var o:* = model.sp[p];
				lsp(p,o.url,o.x,o.y,o.alpha);
			}
			
			for (p in model.btn)
			{
				o = model.btn[p];
				if (o is Number || o is String)
					addSpBtn(p,o);
				else
					addBtn(p,o.x,o.y,o.w,o.h,o.ox,o.oy)
			}
			
			background.source = model.bg;
			textWindow.setWindow(model.textwindow);
			textWindow.visible = model.texton;
			
			if (model.btndef)
				loadBtndef(model.btndef);
			
			if (model.bgm)
				bgm(model.bgm,model.bgmloops);
			
			facade.model.step--;
			facade.runner.isWait = false;
			facade.runner.doNext();
		}
		
		public function clear():void
		{
			for each (var img:Image in sp)
			{
				if (img)
					img.destory();
			}
			sp = {};
			background.source = "";
			textWindow.clear();
			btnclear();
			
			handlers = new Dictionary();
			
			stop();
		}
		
		public function lsp(index:String,url:String,x:int = 0,y:int = 0,alpha:int = 100):void
		{
			var image:Image = new Image();
			image.source = url;
			sp[index] = image;
			
			image.x = x;
			image.y = y;
			image.alpha = alpha / 100;
			spCanvas.addChild(image);
		}
		
		public function loadBtndef(v:String):void
		{
			btndef = new Loader();
			btndef.load(facade.asset.getURLRequest(v));
		}
		
		public function btnclear():void
		{
			if (btndef)
			{
				(btndef.content as Bitmap).bitmapData.dispose();
				btndef.unload();
				btndef = null;
			}
			
			btn = {};
		}
		
		public function addBtn(btnIndex:String,x:int,y:int,w:int,h:int,ox:int,oy:int):void
		{
			var image:Image = new Image();
			image.loadBtndef(btndef,x,y,w,h,ox,oy);
			spCanvas.addChild(image);
		}
		
		public function addSpBtn(btnIndex:String,index:String):void
		{
			btn[btnIndex] = getsp(index);
		}
		
		public function getsp(index:String):Image
		{
			return sp[index] as Image;
		}
		
		public function bg(url:String,effect:int = 0,length:int = 0):void
		{
			this.background.source = url;
		}
		
		public function print(effect:int,length:int = 0):void
		{
			
		}
		
		public function stop():void
		{
			bgmstop();
			for (var index:* in dwaveChannel)
				dwavestop(index);
		}
		
		public function bgm(url:String,loops:int):void
		{
			bgmstop();
			
			var sound:Sound = new Sound(facade.asset.getURLRequest(url),new SoundLoaderContext(1000));
			sound.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			bgmSound = sound;
			bgmChannel = sound.play(0,loops);
		}
		
		public function bgmstop():void
		{
			if (bgmSound)
			{
				try
				{
					bgmSound.close();
				} 
				catch(error:Error){}
			}
			
			if (bgmChannel)
			{
				bgmChannel.stop();
				bgmChannel = null;
			}
		}
		
		public function dwave(index:int,url:String):void
		{
			dwavestop(index);
			
			var sound:Sound = new Sound(facade.asset.getURLRequest(url),new SoundLoaderContext(0));
			sound.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			dwaveSound[index] = sound;
			dwaveChannel[index] = sound.play(0,1);
		}
		
		public function dwavestop(index:int):void
		{
			if (dwaveSound[index])
			{
				try
				{
					Sound(dwaveSound[index]).close();
				} 
				catch(error:Error){}
			}
			if (dwaveChannel[index])
			{
				dwaveChannel[index].stop();
				delete dwaveChannel[index];
			}
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			trace(e);
		}
	}
}