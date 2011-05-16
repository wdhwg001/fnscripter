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
			Tick.instance.addEventListener(TickEvent.TICK,tickHandler);
			
			var oldCell:int = image.cellIndex;
			function tickHandler(e:TickEvent):void
			{
				if (image.cellIndex < oldCell || image.cellIndex >= image.animLength - 1)
				{
					Tick.instance.removeEventListener(TickEvent.TICK,tickHandler);
					
					runner.isWait = false;
					runner.doNext();
				}
				oldCell = image.cellIndex;
			}
		}
		
		[CMD(paramTypes="S")]
		public function btnwait(v:String,isClear:Boolean = true):void
		{
			this.runner.isWait = true;
			view.addViewHandler(completeHandler);
			
			function completeHandler(e:ViewEvent):void
			{
				if (e.btnIndex == -1 || !runner.isWait)
					return;
				
				view.removeViewHandler(completeHandler);
				
				model.setVar(v,e.btnIndex);
				if (isClear)
					btnclear();
				
				runner.isWait = false;
				runner.doNext();
			}
		}
		
		[CMD(paramTypes="S")]
		public function btnwait2(v:String):void
		{
			btnwait(v,false);
		}
		
		/**
		 * 加载缓存按钮图片 
		 * @param v
		 * 
		 */
		public function btndef(v:String):void
		{
			btnclear();
			if (v != "clear")
			{
				model.btndef = v;
				view.loadBtndef(v);
			}
		}
		
		public function btnclear():void
		{
			model.btndef = "";
			model.btn = {};
			view.btnclear();
		}
		
		public function btn(bnIndex:String,x:int,y:int,w:int,h:int,ox:int,oy:int):void
		{
			model.btn[bnIndex] = {x:x,y:y,w:int,h:int,ox:int,oy:int};
			view.addBtn(bnIndex,x,y,w,h,ox,oy)
		}
		
		public function spbtn(index:String,bnIndex:String):void
		{
			model.btn[bnIndex] = index;
			view.addSpBtn(bnIndex,index);
		}
		
		public function select(...reg):void
		{
			runner.isWait = true;
			
			var textList:Array = [];
			var gotoList:Array = [];
			for (var i:int = 0;i < reg.length;i += 2)
			{
				textList.push(reg[i]);
				gotoList.push(reg[i + 1]);
			}
			view.textWindow.select(textList);
			view.addViewHandler(completeHandler);
			
			function completeHandler(e:ViewEvent):void
			{
				if (e.btnIndex == -1 || !runner.isWait)
					return;
				
				view.removeViewHandler(completeHandler);
				
				runner.runCommand("goto",[gotoList[e.btnIndex]]);
				runner.isWait = false;
				runner.doNext();
			}
		}
		
	}
}