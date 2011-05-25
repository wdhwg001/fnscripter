package fnscriper.command
{	
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import fnscriper.FNSFacade;
	import fnscriper.events.ViewEvent;

	public class ButtonCommand extends CommandBase
	{
		public function ButtonCommand(facade:FNSFacade):void
		{
			super(facade);
		}
		
		[CMD("S")]
		public function btnwait(v:String,isClear:Boolean = true):void
		{
			view.invalidateRender();
			runner.isWait = runner.isBtnMode = true;
			view.addViewHandler(completeHandler);
			
			model.getbtntimer = getTimer();
			
			if (model.btntimer)
				setTimeout(completeHandler,model.btntimer);
			
			function completeHandler(e:ViewEvent = null):void
			{
				if (e && e.btnIndex == -1)
					return;
				
				model.btntimer = 0;
				view.removeViewHandler(completeHandler);
				
				model.setVar(v,e ? e.btnIndex : -1);
				if (isClear)
					btnclear();
				
				runner.isWait = runner.isBtnMode = false;
				runner.doNext();
			}
		}
		
		[CMD("S")]
		public function btnwait2(v:String):void
		{
			btnwait(v,false);
		}
		
		[CMD("S")]
		public function getbtntimer(key:String):void
		{
			model.setVar(key,getTimer() - model.getbtntimer);
		}
		
		public function btntimer(t:int):void
		{
			model.btntimer = t;
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
			model.blt = "";
			model.exbtn = {};
			model.exbtn_d = "";
			view.btnclear();
		}
		
		public function btn(bnIndex:String,x:int,y:int,w:int,h:int,ox:int,oy:int):void
		{
			model.btn[bnIndex] = {x:x,y:y,w:int,h:int,ox:int,oy:int};
			view.addBtn(bnIndex,model.btn[bnIndex]);
		}
		
		public function spbtn(index:String,bnIndex:String):void
		{
			model.btn[bnIndex] = index;
			view.addSpBtn(bnIndex,index);
		}
		
		/**
		 * 快速显示图像指令
		 * 显示区域左上角x坐标,y坐标,显示区域宽,高,预载图像截取左上角x坐标,y坐标,截取部分宽,高
		 * @return 
		 * 
		 */
		public function blt(x:int,y:int,w:int,h:int,sx:int,sy:int,sw:int,sh:int):void
		{
			model.blt = {x:x,y:y,w:w,h:h,sx:sx,sy:sy,sw:sw,sh:sh};
			view.addBlt(model.blt);
		}
		
		/**
		 * 清除blt
		 * 
		 */
		public function ofscpy():void
		{
			//
		}
		
		public function exbtn(index:int,btnIndex:int,value:String):void
		{
			model.exbtn[btnIndex] = {index:index,value:value}
		}
		public function exbtn_d(v:String):void
		{
			model.exbtn_d = v;
		}
	}
}