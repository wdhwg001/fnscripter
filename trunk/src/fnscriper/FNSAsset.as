package fnscriper
{
	import flash.net.URLRequest;

	public class FNSAsset
	{
		public var baseurl:String = "";
		
		public function get model():FNSVO
		{
			return FNSFacade.instance.model;
		}
		
		public function FNSAsset(baseurl:String)
		{
			this.baseurl = baseurl;
		}
		
		public function getURLRequest(v:String):URLRequest
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
	}
}