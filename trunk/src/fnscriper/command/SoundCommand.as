package fnscriper.command
{
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	
	import fnscriper.util.FNSUtil;

	public class SoundCommand extends CommandBase
	{
		public function stop():void
		{
			view.stop();
		}
		
		public function bgm(url:String):void
		{
			model.bgm = url;
			model.bgmloops = int.MAX_VALUE;
			view.bgm(url,model.bgmloops);
		}
		
		public function bgmonce(url:String):void
		{
			model.bgm = url;
			model.bgmloops = 1;
			view.bgm(url,model.bgmloops);
		}
		
		public function bgmstop():void
		{
			model.bgm = "";
			view.bgmstop();
		}
		
		public function dwave(index:int,url:String):void
		{
			view.dwave(index,url);
		}
		
		public function dwavestop(index:int):void
		{
			view.dwavestop(index);
		}
		
		public function clickvoice(v1:String,v2:String):void
		{
			model.clickvoice = [v1,v2];
		}
	}
}