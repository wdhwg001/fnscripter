package fnscriper.command
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import fnscriper.display.Image;
	import fnscriper.events.TickEvent;
	import fnscriper.events.ViewEvent;
	import fnscriper.util.FNSUtil;
	import fnscriper.util.Tick;

	public class InteractiveCommand extends CommandBase
	{
		public function waittimer(v:int):void
		{
			wait(v);
		}
		public function wait(v:int):void
		{
			if (runner.isSkip)
				return;
			
			this.runner.isWait = true;
			setTimeout(completeHandler,v);
			
			function completeHandler():void
			{
				runner.isWait = false;
				runner.doNext();
			}
		}
		
		public function delay(v:int):void
		{
			autoclick(v);
		}
		
		public function click():void
		{
			autoclick(0);
		}
		
		public function autoclick(t:int):void
		{
			if (runner.isSkip)
				return;
			
			this.runner.isWait = true;
			view.addViewHandler(completeHandler);
			
			if (t)
				setTimeout(completeHandler,t);
			
			function completeHandler(e:ViewEvent = null):void
			{
				view.removeViewHandler(completeHandler);
				
				runner.isWait = false;
				runner.doNext();
			}
		}
		
		public function spwait(v:String):void
		{
			this.runner.isWait = true;
			var image:Image = view.getsp(v);
			image.addEventListener(Event.ENTER_FRAME,tickHandler);
			
			var oldCell:int = image.cellIndex;
			function tickHandler(e:Event):void
			{
				if (image.cellIndex < oldCell || image.cellIndex >= image.animLength - 1)
				{
					image.removeEventListener(Event.ENTER_FRAME,tickHandler);
					
					runner.isWait = false;
					runner.doNext();
				}
				oldCell = image.cellIndex;
			}
		}
	}
}