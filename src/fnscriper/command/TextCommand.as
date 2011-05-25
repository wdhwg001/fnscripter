package fnscriper.command
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import fnscriper.display.Image;
	import fnscriper.events.ViewEvent;
	
	import fnscriper.FNSFacade;

	public class TextCommand extends CommandBase
	{
		public function TextCommand(facade:FNSFacade):void
		{
			super(facade);
		}
		
		public function defaultspeed(low:int,middle:int,high:int):void
		{
			model.defaultspeed = [low,middle,high];
			model.textspeed = middle;
		}
		
		public function defaultfont(v:String):void
		{
			model.defaultfont = v;
		}
		
		public function shadedistance(x:int,y:int):void
		{
			model.shadedistanceX = x;
			model.shadedistanceY = y;
		}
		
		public function linepage():void
		{
			model.linepage = true;
		}
		
		public function texton():void
		{
			view.textWindow.visible = model.texton = true;
			if (model.mode_saya)
			{
				for (var i:int = 1;i <= 9;i++)
				{
					var p:Image = view.getsp(i.toString());
					if (p)
						p.visible = true;
				}
			}
		}
		
		public function textoff():void
		{
			view.textWindow.visible = model.texton = false;
			if (model.mode_saya)
			{
				for (var i:int = 1;i <= 9;i++)
				{
					var p:Image = view.getsp(i.toString());
					if (p)
						p.visible = false;
				}
			}
		}
		
		public function erasetextwindow(v:int):void
		{
			model.erasetextwindow = v;
		}
		
		/**
		 * 头文字左上角x坐标,y坐标,每行字数,行数,字宽,字高,字间距,行间距,单字显示速度毫秒数,粗体状态,阴影状态,窗体颜色,窗体左上角x坐标,y坐标,右下角x坐标,y坐标
		 * @return 
		 * 
		 */
		public function setwindow(tx:int,ty:int,tw:int,th:int,fw:int,fh:int,fg:int,lg:int,speed:int,bold:int,shadow:int,skin:String,wx:int,wy:int,wr:int = 0,wb:int = 0):void
		{
			model.textwindow = {tx:tx,ty:ty,tw:tw,th:th,fw:fw,fh:fh,fg:fg,lg:lg,speed:speed,bold:bold,shadow:shadow,skin:skin,wx:wx,wy:wy,wr:wr,wb:wb};
			view.textWindow.setWindow(model.textwindow);
			
			texton();
		}
		
		public function setwindow2(skin:String):void
		{
			var obj:Object = model.textwindow;
			obj.skin = skin;
			view.textWindow.setSkin(skin,obj.wx,obj.wy,obj.wr,obj.wb);
		}
		
		public function putText(v:String):void
		{
			runner.isTextWait = true;
			view.textWindow.putText(v);
		}
		
		public function textclear():void
		{
			view.textWindow.textclear();	
		}
		
		public function locate(x:int = 0,y:int = 0):void
		{
			view.textWindow.locate();	
		}
		
		public function br():void
		{
			view.textWindow.br();	
		}
		
		public function textspeed(s:int):void
		{
			model.textspeed = s;
		}
		
		public function selectcolor(c1:uint,c2:uint):void
		{
			model.selectcolor = [c1,c2];
		}
		
		public function selectvoice(v1:String,v2:String):void
		{
			model.selectvoice = [v1,v2];
		}
		
		public function clickstr(str:String,num:int = 0):void
		{
			model.clickstr = str;
		}
		
		public function clickvoice(v1:String = "",v2:String = ""):void
		{
			model.clickvoice = [v1,v2];
		}
		
		public function select(...reg):void
		{
			runner.isWait = runner.isBtnMode = true;
			
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
				
				runner.goto(gotoList[e.btnIndex]);
				runner.isWait = runner.isBtnMode = false;
				runner.doNext();
			}
		}
		public function selgosub(...reg):void
		{
			runner.isWait = runner.isBtnMode = true;
			
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
				
				runner.gosub(gotoList[e.btnIndex]);
				runner.isWait = runner.isBtnMode = false;
				runner.doNext();
			}
		}
		[CMD("S")]
		public function selnum(key:String,...reg):void
		{
			runner.isWait = runner.isBtnMode = true;
			
			var textList:Array = [];
			for (var i:int = 0;i < reg.length;i ++)
				textList.push(reg[i]);
			
			view.textWindow.select(textList);
			view.addViewHandler(completeHandler);
			
			function completeHandler(e:ViewEvent):void
			{
				if (e.btnIndex == -1 || !runner.isWait)
					return;
				
				view.removeViewHandler(completeHandler);
				
				model.setVar(key,e.btnIndex);
				runner.isWait = runner.isBtnMode = false;
				runner.doNext();
			}
		}
		[CMD("SS")]
		public function getcursorpos(x:String,y:String):void
		{
			var p:Point = view.textWindow.textField.getCharBoundaries(view.textWindow.textField.caretIndex).topLeft;
			p = view.globalToLocal(view.textWindow.textField.localToGlobal(p));
			model.setVar(x,p.x);
			model.setVar(y,p.y);
		}
		
		public function lookbackcolor(v:String):void
		{
			if (v.charAt(0) == "#")
				model.lookbackcolor = parseInt(v.slice(1),16);
		}
		
		public function setcursor(type:int,url:String,x:int = 0,y:int = 0):void
		{
			model.cursor[type] = {url:url,x:int,y:int,absset:0};
		}
		public function abssetcursor(type:int,url:String,x:int = 0,y:int = 0):void
		{
			model.cursor[type] = {url:url,x:int,y:int,absset:1}
		}
		
		public function mode_saya():void
		{
			model.mode_saya = true;
		}
	}
}