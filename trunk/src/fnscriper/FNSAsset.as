package fnscriper
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import fnscriper.util.FNSUtil;

	public class FNSAsset
	{
		public var MAX_LOAD:int = 500;
		
		public var baseurl:String = "";
		public var urls:Object = {};

		private var startIndex:int;
		private var endIndex:int;
		
		public var paused:Boolean = true;
		
		private var facade:FNSFacade;
		
		public function get model():FNSVO
		{
			return facade.model;
		}
		
		public function get runner():FNSRunner
		{
			return facade.runner;
		}
		
		public function FNSAsset(facade:FNSFacade)
		{
			this.facade = facade;
		}
		
		public function getURLRequest(v:String):URLRequest
		{
			return _getURLRequest(v);
		}
		
		private function _getURLRequest(v:String):URLRequest
		{
			var url:String = baseurl;
			if (url && url.charAt(url.length - 1) != "/" && url.charAt(url.length - 1) != "\\")
				url += "/"
					
			if (model.nsadir)
			{
				url += model.nsadir;
				if (url && url.charAt(url.length - 1) != "/" && url.charAt(url.length - 1) != "\\")
					url += "/";
			}		
			url += v;
			return new URLRequest(url.replace(/\\/g,"/"));
		}
		
		public function createSound(url:String,bufferTime:int = 1000):Sound
		{
			if (url && url.charAt(0) == "*")
			{
				var num:String = int(url.slice(1)).toString();
				if (num.length == 1)
					num = "0" + num;
				url = "cd\Track" + num + ".mp3";
			}
			return new Sound(getURLRequest(url),new SoundLoaderContext(bufferTime));
		}
		
		public function startLoad():void
		{
			if (paused)
			{
				paused = false;
				findUrls();
			}
			else
			{
				refreshIndex();
			}
		}
		
		private function refreshIndex():void
		{
			if (model.callStack.length == 0 && (model.step < startIndex || model.step > endIndex))
				startIndex = endIndex = model.step;
		}
		
		private function findUrls():void
		{
			const FILENAMES:Array = [".png",".jpg",".gif",".bmp"]
			
			refreshIndex();
			do 
			{
				if (endIndex + 1 >= runner.data.length || endIndex - startIndex > MAX_LOAD)
				{
					this.paused = true;
					return;
				}
				
				endIndex++;
				
				var lines:Array = runner.data[endIndex];
				for each (var line:String in lines)
				{
					var list:Array = line.match(/".+?"/);
					var result:Array = [];
					if (list)
					{
						for (var i:int = 0;i < list.length;i++)
						{
							var v:String = list[i];
							v = v.slice(1,v.length - 1);
							var index:int = v.indexOf(";");
							if (index != -1)
								v = v.slice(index + 1);
							
							if (FILENAMES.indexOf(v.slice(v.length - 4,v.length)) != -1)
								result.push(v);
						}
					}
				}
			}
			while (result.length == 0);
			
			this.pLoad(result);
		}
		
		private function pLoad(urls:Array):void
		{
			var total:int = urls.length;
//			trace(urls);
			
			for each (var url:String in urls)
			{
				var loader:URLLoader = new URLLoader(_getURLRequest(url));
				loader.addEventListener(Event.COMPLETE,completeHandler);
				loader.addEventListener(IOErrorEvent.IO_ERROR,completeHandler);
			}
			
			function completeHandler(e:Event):void
			{
				total--;
				if (total == 0)
					findUrls();
			}
		}
	}
}