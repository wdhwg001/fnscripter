package fnscriper
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	
	import fnscriper.display.ProgressBar;
	import fnscriper.util.OperatorUtil;

	public class FNSFacade extends Sprite
	{
		public var charset:String = "gb2312";
		public var gameurl:String = "";
		
		public var asset:FNSAsset;
		public var view:FNSView;
		public var runner:FNSRunner;
		public var model:FNSVO;
		public function FNSFacade()
		{
			this.addEventListener(Event.ADDED_TO_STAGE,initHandler);
		}
		
		protected function initHandler(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,initHandler);
			
			this.loadParams();
			
			this.asset = new FNSAsset(this);
			this.asset.baseurl = gameurl;
			
			this.model = new FNSVO();
			
			this.view = new FNSView(this);
			addChild(this.view);
			
			this.runner = new FNSRunner(this);
			
			this.loadDatFile();
			this.loadFontFile();	
		}
		
		private function loadParams():void
		{
			for (var p:String in this.loaderInfo.parameters)
			{
				if (this.hasOwnProperty(p))
					this[p] = this.loaderInfo.parameters[p];
			}
		}
		
		public function loadDatFile():void
		{
			var url:String = gameurl;
			if (url && url.charAt(url.length - 1) != "/" && url.charAt(url.length - 1) != "\\")
				url += "/"
			
			url += "0.txt";
			
			var loader:URLLoader = new URLLoader(new URLRequest(url));
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loadDatFileCompleteHandler);
			
			var progressBar:ProgressBar = new ProgressBar(loader);
			progressBar.x = stage.stageWidth / 2;
			progressBar.y = stage.stageHeight / 2;
			addChild(progressBar);
		}
		
		protected function loadDatFileCompleteHandler(event:Event):void
		{
			var loader:URLLoader = event.currentTarget as URLLoader;
			var bytes:ByteArray = loader.data;
			try
			{
				bytes.uncompress();
			} 
			catch(error:Error) 
			{
			}
			
			this.runner.setData(bytes.readMultiByte(bytes.bytesAvailable,charset));
			this.runner.startGame();
		}
		
		public function loadFontFile():void
		{
			var url:String = gameurl;
			if (url && url.charAt(url.length - 1) != "/" && url.charAt(url.length - 1) != "\\")
				url += "/"
			
			url += "default.swf";
			
			var loader:Loader = new Loader();
			loader.load(new URLRequest(url),new LoaderContext(false,ApplicationDomain.currentDomain))
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadFontFileCompleteHandler);
		}
		
		protected function loadFontFileCompleteHandler(event:Event):void
		{
			this.model.embedFonts = true;
		}
	}
}