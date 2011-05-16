package fnscriper.command
{
	import flash.geom.Point;

	public class TextCommand extends CommandBase
	{
		public function defaultspeed(low:int,middle:int,high:int):void
		{
			model.defaultspeed = [low,middle,high];
			model.textspeed = middle;
		}
		
		public function textspeed(s:int):void
		{
			model.textspeed = s;
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
		
		public function texton():void
		{
			view.textWindow.visible = model.texton = true;
		}
		
		public function textoff():void
		{
			view.textWindow.visible = model.texton = false;
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
			view.textWindow.putText(v);
			runner.isWait = true;
		}
		
		public function selectcolor(c1:uint,c2:uint):void
		{
			model.selectcolor = [c1,c2];
		}
		
		public function selectvoice(v1:String,v2:String):void
		{
			model.selectvoice = [v1,v2];
		}
	}
}