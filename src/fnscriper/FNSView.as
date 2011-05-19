package fnscriper
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.elements.BreakElement;
	
	import fnscriper.command.EffectFuns;
	import fnscriper.display.GVideo;
	import fnscriper.display.Image;
	import fnscriper.display.TextWindow;
	import fnscriper.events.TickEvent;
	import fnscriper.events.ViewEvent;
	import fnscriper.util.Tick;
	import fnscriper.util.TweenUtil;
	
	[Event(name="view_click", type="fnscriper.events.ViewEvent")]
	public class FNSView extends Sprite
	{
		public var contentWidth:int;
		public var contentHeight:int;
		
		public var screen:BitmapData;
		public var screenbm:Bitmap;
		public var spCanvas:Array = [];
		
		public var background:Image;
		public var textWindow:TextWindow;
		
		public var sp:Object = {};
		public var btndef:Loader;
		public var btn:Object = {};
		public var blt:Image;
		
		public var bgmSound:Sound;
		public var bgmChannel:SoundChannel;
		
		public var dwaveSound:Object = {};
		public var dwaveChannel:Object= {};
		
		public var handlers:Dictionary = new Dictionary();
		
		private var skipTimer:Timer;
		private var renderTimer:int;
		private var refreshDirty:Boolean;
		
		public function get facade():FNSFacade
		{
			return FNSFacade.instance;
		}
		
		public function FNSView(w:int = 800,h:int = 600)
		{
			super();
			
			this.contentWidth = w;
			this.contentHeight = h;
			
			this.graphics.beginFill(0);
			this.graphics.drawRect(0,0,w,h);
			this.graphics.endFill();
			
			this.screen = new BitmapData(w,h,false,0x0)
			this.screenbm = new Bitmap(this.screen	,"auto",true);
			this.addChild(this.screenbm);
			
			this.textWindow = new TextWindow();
			this.addChild(this.textWindow)
			
			this.background = new Image();
			this.background.transparenceMode = "c";
			
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
			if (event.keyCode == Keyboard.SPACE)
				dispatchViewEvent();
			
			if (event.ctrlKey)
				facade.runner.isSkip = true;
			else
				facade.runner.isSkip = false;
		}
		
		protected function keyUpHandler(event:KeyboardEvent):void
		{
			facade.runner.isSkip = false;
		}
		
		protected function mouseOverHandler(event:MouseEvent):void
		{
			if (facade.runner.isBtnMode)
			{
				for (var p:* in btn)
				{
					var child:Image = btn[p];
					if (child)
						child.cellIndex = child.mouseOver ? 1 : 0;
				}
			}
		}
		
		protected function clickHandler(event:MouseEvent):void
		{
			this.textWindow.visible = facade.model.texton;
			facade.runner.isSkip = false;
			
			if (facade.runner.isBtnMode)
			{
				for (var p:* in btn)
				{
					var child:Image = btn[p];
					if (child && child.mouseOver)
					{
						dispatchViewEvent(int(p));
						return;
					}
				}
			}
			dispatchViewEvent();
		}
		
		protected function skipHandler(event:TimerEvent):void
		{
			if (FNSFacade.instance.runner.isSkip && !facade.runner.isBtnMode)
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
		
		public function invalidateRender():void
		{
			if (refreshDirty)
				return;
			
			refreshDirty = true;
			renderTimer = setTimeout(render,0);
		}
		
		public function render():void
		{
			clearTimeout(renderTimer);
			refreshDirty = false;
			
			screen.fillRect(screen.rect,0);
			background.renderToBitmapData(screen);
			
			for each (var img:Image in sp)
			{
				if (img && img.visible)
					img.renderToBitmapData(screen);
			}
		}
		
		public function loadFromVO():void
		{
			clear();
			
			var model:FNSVO = facade.model;
			var p:*
			
			if (model.btndef)
				loadBtndef(model.btndef);
			
			if (model.bgm)
				bgm(model.bgm,model.bgmloops);
			
			for (p in model.dwaveload)
				dwaveload(p,model.dwaveload[p]);
			
			for (p in model.dwaveloop)
				dwave(p,model.dwaveloop[p],int.MAX_VALUE);
			
			for (p in model.sp)
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
					addBtn(p,o)
			}
			
			if (model.blt)
				addBlt(model.blt);
			
			background.source = model.bg;
			textWindow.setWindow(model.textwindow);
			textWindow.visible = model.texton;
			
			screenfilter(model.monocro,model.nega);
			
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
			screenbm.filters = [];
			
			stop();
		}
		
		public function print(effect:int,len:int = 0,img:String = ""):void
		{
			if (facade.runner.isSkip)
				effect = 1;
			
			switch (effect)
			{
				case 0:
					render();
				case 1:
					render();
					break;
				case 2:
					showEffect(EffectFuns.effect10,len,img);
					break;
				case 3:
					showEffect(EffectFuns.effect10,len,img);
					break;
				case 4:
					showEffect(EffectFuns.effect10,len,img);
					break;
				case 5:
					showEffect(EffectFuns.effect10,len,img);
					break;
				case 6:
					showEffect(EffectFuns.effect10,len,img);
					break;
				case 7:
					showEffect(EffectFuns.effect10,len,img);
					break;
				case 8:
					showEffect(EffectFuns.effect10,len,img);
					break;
				case 9:
					showEffect(EffectFuns.effect10,len,img);
					break;
				case 10:
					showEffect(EffectFuns.effect10,len,img);
					break;
				case 12:
					showEffect(EffectFuns.effect10,len,img);
					break;
				case 13:
					showEffect(EffectFuns.effect10,len,img);
					break;
				case 14:
					showEffect(EffectFuns.effect10,len,img);
					break;
				case 15:
					showEffect(EffectFuns.effect10,len,img);
					break;
				case 16:
					showEffect(EffectFuns.effect10,len,img);
					break;
			}
		}
		
		private function showEffect(renderFun:Function,len:int,img:String = ""):void
		{
			facade.runner.isWait = true;
			
			var oldbmd:BitmapData = screen.clone();
			var effectbmd:BitmapData = screen.clone();
			screenbm.bitmapData = effectbmd;
			
			var t:int = getTimer();
			addEventListener(Event.ENTER_FRAME,tickHandler);
			
			function tickHandler(e:Event):void
			{
				var percent:Number = (getTimer() - t) / len;
				if (percent > 1.0)
					percent = 1.0;
				
				renderFun(effectbmd,oldbmd,screen,percent);
				
				if (getTimer() - t > len + facade.model.effectblank)
				{
					screenbm.bitmapData = screen;
					oldbmd.dispose();
					effectbmd.dispose();
					removeEventListener(Event.ENTER_FRAME,tickHandler);
					
					facade.runner.isWait = false;
					facade.runner.doNext();
				}
			}
		}
		
		public function quake(num:int,len:int,type:int = 0):void
		{
			facade.runner.isWait = true;
			
			var t:int = getTimer();
			addEventListener(Event.ENTER_FRAME,tickHandler);
			
			function tickHandler(e:Event):void
			{
				if (type == 0)
				{
					screenbm.x = (Math.random() * 2 - 1) * num;
					screenbm.y = (Math.random() * 2 - 1) * num;
				}
				else
				{
					var n:Number = Math.sin((getTimer() - t) / (len / num) * Math.PI * 2);
					if (type == 1)
					{
						screenbm.x = n * 10;
					}
					else if (type == 2)
					{
						screenbm.y = n * 10;
					}
				}
				
				if (getTimer() - t > len)
				{
					screenbm.x = screenbm.y = 0;
					removeEventListener(Event.ENTER_FRAME,tickHandler);
					
					facade.runner.isWait = false;
					facade.runner.doNext();
				}
			}
		}
		
		public function screenfilter(monocro:String,nega:int):void
		{
			var list:Array = [];
			if (monocro && monocro.charAt(0) == "#")
			{
				var r:Number = parseInt(monocro.slice(1,3),16) / 0xFF / 3;
				var g:Number = parseInt(monocro.slice(3,5),16) / 0xFF / 3;
				var b:Number = parseInt(monocro.slice(5,7),16) / 0xFF / 3;
				list = [new ColorMatrixFilter([
					r,r,r,0,0,
					g,g,g,0,0,
					b,b,b,0,0,
					0,0,0,1,0,
				])];
			}
			
			if (nega)
			{
				var fnega:ColorMatrixFilter = new ColorMatrixFilter([
					-1,0,0,0,255,
					0,-1,0,0,255,
					0,0,-1,0,255,
					0,0,0,1,0]);
				
				if (nega == 1)
					list.unshift(fnega)
				else if (nega == 2)
					list.push(fnega)
			}
			
			this.screenbm.filters = list;
		}
		
		public function lsp(index:String,url:String,x:int = 0,y:int = 0,alpha:int = 100):void
		{
			var image:Image = new Image();
			image.source = url;
			sp[index] = image;
			
			image.x = x;
			image.y = y;
			image.id = index;
			image.alpha = alpha / 100;
			spCanvas.push(image);
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
			
			for each (var img:Image in btn)
			{
				if (img)
					img.destory();
			}
			
			if (blt)
				blt.destory();
			
			btn = {};
		}
		
		public function addBtn(btnIndex:String,o:Object):void
		{
			var image:Image = new Image();
			image.loadBtndef(btndef,o.x,o.y,o.w,o.h,o.ox,o.oy);
			spCanvas.push(image);
			btn[btnIndex] = image;
		}
		
		public function addBlt(o:Object):void
		{
			if (blt)
				blt.destory();
			
			blt = new Image();
			blt.loadBlt(btndef,o.x,o.y,o.w,o.h,o.sx,o.sy,o.sw,o.sh);
			spCanvas.push(blt);
		}
		
		public function addSpBtn(btnIndex:String,index:String):void
		{
			btn[btnIndex] = getsp(index);
		}
		
		public function getsp(index:String):Image
		{
			return sp[index] as Image;
		}
		
		public function bg(url:String):void
		{
			this.background.source = url;
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
		
		public function dwaveload(index:int,url:String):void
		{
			dwavestop(index);
			
			var sound:Sound = new Sound(facade.asset.getURLRequest(url),new SoundLoaderContext(0));
			sound.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			dwaveSound[index] = sound;
		}
		
		public function dwaveplay(index:int,loops:int = 1):void
		{
			var sound:Sound = dwaveSound[index];
			dwaveChannel[index] = sound.play(0,loops);
		}
		
		public function dwave(index:int,url:String,loops:int = 1):void
		{
			dwaveload(index,url);
			dwaveplay(index);
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
		
		public function mpegplay(url:String,haltable:int):void
		{
			var video:GVideo = new GVideo(contentWidth,contentHeight);
			video.load(FNSFacade.instance.asset.getURLRequest(url).url);
			video.addEventListener(Event.COMPLETE,completeHandler);
			video.play();
			addChild(video);
			
			if (haltable)
				addViewHandler(completeHandler);
			
			function completeHandler(event:Event):void
			{
				removeViewHandler(completeHandler);
				video.removeEventListener(Event.COMPLETE,completeHandler);
				removeChild(video);
				
				FNSFacade.instance.runner.isWait = false;
				FNSFacade.instance.runner.doNext();
			}
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			trace(e);
		}
	}
}