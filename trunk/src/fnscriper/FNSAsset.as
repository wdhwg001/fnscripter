package fnscriper
{
	import flash.net.URLRequest;

	public class FNSAsset
	{
		public var baseUrl:String = "arc/";
		public function FNSAsset()
		{
		}
		
		public function getURLRequest(v:String):URLRequest
		{
			return new URLRequest(baseUrl + v.replace(/\\/g,"/"));
		}
	}
}