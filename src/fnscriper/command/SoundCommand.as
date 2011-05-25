package fnscriper.command
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import fnscriper.util.FNSUtil;
	
	import fnscriper.FNSFacade;

	public class SoundCommand extends CommandBase
	{
		public function SoundCommand(facade:FNSFacade):void
		{
			super(facade);
		}
		
		public function defvoicecol(v:int):void
		{
			model.defvoicecol = v;
		}
		public function defsevol(v:int):void
		{
			model.defsevol = v;
		}
		public function defmp3vol(v:int):void
		{
			model.defmp3vol = v;
		}
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
		
		public function play(url:String):void
		{
			bgm(url);
		}
		public function playonce(url:String):void
		{
			bgmonce(url);
		}
		public function playstop(url:String):void
		{
			bgmstop()
		}
		
		public function wave(url:String):void
		{
			bgmonce(url);
		}
		public function waveloop(url:String):void
		{
			bgm(url);
		}
		public function wavestop(url:String):void
		{
			bgmstop()
		}
		
		public function mp3(url:String):void
		{
			bgm(url);
		}
		public function mp3once(url:String):void
		{
			bgmonce(url);
		}
		public function mp3stop(url:String):void
		{
			bgmstop()
		}
		
		public function dwave(index:int,url:String):void
		{
			view.dwave(index,url,1);
		}
		
		public function dwaveloop(index:int,url:String):void
		{
			model.dwaveloop[index] = url;
			view.dwave(index,url,uint.MAX_VALUE);
		}
		
		public function dwavestop(index:int):void
		{
			view.dwavestop(index);
		}
		
		public function dwaveload(index:int,url:String):void
		{
			model.dwaveload[index] = url;
			view.dwaveload(index,url);
		}
		
		public function dwaveplay(index:int):void
		{
			delete model.dwaveload[index];
			view.dwaveplay(index,1);
		}
		
		public function dwaveplayloop(index:int):void
		{
			delete model.dwaveload[index];
			model.dwaveloop[index] = model.dwaveload[index];
			view.dwaveplay(index,uint.MAX_VALUE);
		}
		
		public function chvol(index:int,vol:int):void
		{
			var channel:SoundChannel = view.dwaveChannel[index] as SoundChannel;
			channel.soundTransform = new SoundTransform(vol / 100);
		}
	}
}