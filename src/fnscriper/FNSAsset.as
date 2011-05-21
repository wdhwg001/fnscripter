package fnscriper
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
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
		
		public function get model():FNSVO
		{
			return FNSFacade.instance.model;
		}
		
		public function get runner():FNSRunner
		{
			return FNSFacade.instance.runner;
		}
		
		public function FNSAsset(baseurl:String)
		{
			this.baseurl = baseurl;
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
			if (model.callLayer.length == 0 && (model.step < startIndex || model.step > endIndex))
				startIndex = endIndex = model.step;
		}
		
		private function findUrls():void
		{
			const FILENAMES:Array = [".png",".jpg",".gif",".bmp"]
			
			refreshIndex();
			do 
			{
				if (endIndex >= runner.data.length - 1 || endIndex - startIndex > MAX_LOAD)
				{
					this.paused = true;
					return;
				}
				
				endIndex++;
				
				var line:String = FNSUtil.readLine(runner.data[endIndex]);
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
			while (result.length == 0);
			
			this.pLoad(result);
		}
		
		private function pLoad(urls:Array):void
		{
			var total:int = urls.length;
			
			for each (var url:String in urls)
			{
				var loader:URLLoader = new URLLoader(_getURLRequest(url));
				loader.addEventListener(Event.COMPLETE,completeHandler);
				loader.addEventListener(IOErrorEvent.IO_ERROR,completeHandler);
			}
			
			trace(urls);
			
			function completeHandler(e:Event):void
			{
				total--;
				if (total == 0)
					findUrls();
			}
		}
	}
}