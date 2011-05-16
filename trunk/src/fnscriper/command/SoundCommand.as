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
			view.bgm(url);
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
	}
}