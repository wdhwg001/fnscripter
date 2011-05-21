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
	
	import fnscriper.util.OperatorUtil;

	public class FNSFacade extends Sprite
	{
		static public var instance:FNSFacade;
		
		public var charset:String = "utf-8";//gb2312
		public var gameurl:String = "";
		
		public var asset:FNSAsset;
		public var view:FNSView;
		public var runner:FNSRunner;
		public var model:FNSVO;
		public function FNSFacade()
		{
			FNSFacade.instance = this;
			
			this.loadParams();
			
			this.asset = new FNSAsset(gameurl);
			this.model = new FNSVO();
			
			this.view = new FNSView();
			addChild(this.view);
			
			this.runner = new FNSRunner();
			
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
		
		public function loadDatFile(url:URLRequest = null):void
		{
			if (!url)
				url = new URLRequest("0.txt");
			
			var loader:URLLoader = new URLLoader(url);
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,loadDatFileCompleteHandler);
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
		
		public function loadFontFile(url:URLRequest = null):void
		{
			if (!url)
				url = new URLRequest("default.swf");
			
			var loader:Loader = new Loader();
			loader.load(url,new LoaderContext(false,ApplicationDomain.currentDomain))
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadFontFileCompleteHandler);
		}
		
		protected function loadFontFileCompleteHandler(event:Event):void
		{
			this.model.embedFonts = true;
		}
	}
}