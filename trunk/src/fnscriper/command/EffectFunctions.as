package fnscriper.command
{
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import fnscriper.display.Image;

	/**
	 *0-依下一个显示命令显示……不太理解，总之尽量别用…… 
1 -瞬间显示 
2 -左快门 
3 -右快门 
4 -上快门 
5 -下快门 
6 -左窗帘 
7 -右窗帘 
8 -上窗帘 
9 -下窗帘 
10 -透明渐变 
11 -左卷动 
12 -右卷动 
13 -上卷动 
14 -下卷动 
15,18 -遮片/ALPHA遮片 
16,17 -马塞克效果
 
	 * @author flashyiyi
	 * 
	 */
	public final class EffectFunctions
	{
		private static const delta:int = 20;
		public static function effect2(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point());
			var len:int = Math.ceil(effectbmd.width / delta);
			for (var i:int = 0;i < len;i++)
				effectbmd.copyPixels(screen,new Rectangle((i + 1 - percent) * delta,0,delta * percent,effectbmd.height),new Point((i + 1 - percent) * delta,0));
		}
		public static function effect3(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point());
			var len:int = Math.ceil(effectbmd.width / delta);
			for (var i:int = 0;i < len;i++)
				effectbmd.copyPixels(screen,new Rectangle(i * delta,0,delta * percent,effectbmd.height),new Point(i * delta,0));
		}
		public static function effect4(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point());
			var len:int = Math.ceil(effectbmd.height / delta);
			for (var i:int = 0;i < len;i++)
				effectbmd.copyPixels(screen,new Rectangle(0,(i + 1 - percent) * delta,effectbmd.width,delta * percent),new Point(0,(i + 1 - percent) * delta));
		}
		public static function effect5(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point());
			var len:int = Math.ceil(effectbmd.height / delta);
			for (var i:int = 0;i < len;i++)
				effectbmd.copyPixels(screen,new Rectangle(0,i * delta,effectbmd.width,delta * percent),new Point(0,i * delta));
		}
		
		public static function effect6(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point());
			var len:int = Math.ceil(effectbmd.width / delta);
			for (var i:int = 0;i < len;i++)
			{
				var p:Number = percent * 2 - (len - i) / len;
				p = p < 0 ? 0 : p > 1 ? 1 : p;
				effectbmd.copyPixels(screen,new Rectangle((i + 1 - p) * delta,0,delta * p,effectbmd.height),new Point((i + 1 - p) * delta,0));
			}
		}
		public static function effect7(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point());
			var len:int = Math.ceil(effectbmd.width / delta);
			for (var i:int = 0;i < len;i++)
			{
				var p:Number = percent * 2 - i / len;
				p = p < 0 ? 0 : p > 1 ? 1 : p;
				effectbmd.copyPixels(screen,new Rectangle(i * delta,0,delta * p,effectbmd.height),new Point(i * delta,0));
			}
		}
		public static function effect8(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point());
			var len:int = Math.ceil(effectbmd.height / delta);
			for (var i:int = 0;i < len;i++)
			{
				var p:Number = percent * 2 - (len - i) / len;
				p = p < 0 ? 0 : p > 1 ? 1 : p;
				effectbmd.copyPixels(screen,new Rectangle(0,(i + 1 - p) * delta,effectbmd.width,delta * p),new Point(0,(i + 1 - p) * delta));
			}
		}
		public static function effect9(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point());
			var len:int = Math.ceil(effectbmd.height / delta);
			for (var i:int = 0;i < len;i++)
			{
				var p:Number = percent * 2 - i / len;
				p = p < 0 ? 0 : p > 1 ? 1 : p;
				effectbmd.copyPixels(screen,new Rectangle(0,i * delta,effectbmd.width,delta * p),new Point(0,i * delta));
			}
		}
		
		public static function effect10(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point());
			effectbmd.merge(screen,screen.rect,new Point(),percent * 255,percent * 255,percent * 255,percent * 255);
		}
		
		public static function effect11(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point(effectbmd.width * (0 - percent),0));
			effectbmd.copyPixels(screen,screen.rect,new Point(effectbmd.width * (1 - percent),0));
		}
		public static function effect12(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point(effectbmd.width * (percent - 0),0));
			effectbmd.copyPixels(screen,screen.rect,new Point(effectbmd.width * (percent - 1),0));
		}
		public static function effect13(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point(0,effectbmd.height * (0 - percent)));
			effectbmd.copyPixels(screen,screen.rect,new Point(0,effectbmd.height * (1 - percent)));
		}
		public static function effect14(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point(0,effectbmd.height * (percent - 0)));
			effectbmd.copyPixels(screen,screen.rect,new Point(0,effectbmd.height * (percent - 1)));
		}
		
		public static function effect15(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point());
			if (!mask || !mask.bitmapData)
				return;
			
			var bmd:BitmapData = new BitmapData(mask.bitmapData.width,mask.bitmapData.height,true,0);
			bmd.threshold(mask.bitmapData,mask.bitmapData.rect,new Point(),">",percent * 0xFF,0,0xFF,true);
			effectbmd.copyPixels(screen,screen.rect,new Point(),bmd,new Point());
				
			bmd.dispose();
		}
		
		public static function effect16(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			if (percent == 0)
				percent = 0.01;
			var dx:Number = effectbmd.width * percent / 5;
			var dy:Number = effectbmd.height * percent / 5;
			var bmd:BitmapData = new BitmapData(Math.ceil(effectbmd.width / dx),Math.ceil(effectbmd.height / dy));
			var m:Matrix = new Matrix();
//			m.translate(-effectbmd.width / 2,-effectbmd.height / 2);
			m.scale(1 / dx,1 / dy);
//			m.translate(effectbmd.width / 2,effectbmd.height / 2);
			bmd.draw(oldbmd,m);
			m.invert();
			effectbmd.draw(bmd,m);
			bmd.dispose();
		}
		
		public static function effect17(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			percent = 1 - percent;
			if (percent == 0)
				percent = 0.01;
			var dx:Number = effectbmd.width * percent / 5;
			var dy:Number = effectbmd.height * percent / 5;
			var bmd:BitmapData = effectbmd.clone();
			var m:Matrix = new Matrix();
//			m.translate(-effectbmd.width / 2,-effectbmd.height / 2);
			m.scale(1 / dx,1 / dy);
//			m.translate(effectbmd.width / 2,effectbmd.height / 2);
			bmd.draw(screen,m);
			m.invert();
			effectbmd.draw(bmd,m);
			bmd.dispose();
		}
		
		public static function effect18(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number,mask:Image):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point());
			if (!mask || !mask.bitmapData)
				return;
			
			var bmd:BitmapData = new BitmapData(mask.bitmapData.width,mask.bitmapData.height,true,0);
			bmd.copyPixels(mask.bitmapData,mask.bitmapData.rect,new Point());
			bmd.applyFilter(bmd,bmd.rect,new Point(),new ColorMatrixFilter([
				1,0,0,0,0,
				0,1,0,0,0,
				0,0,1,0,0,
				1/3,1/3,1/3,0,255 * percent * 2 - 255
			]));
			effectbmd.copyPixels(screen,screen.rect,new Point(),bmd,new Point());
			bmd.dispose();
		}
	}
}