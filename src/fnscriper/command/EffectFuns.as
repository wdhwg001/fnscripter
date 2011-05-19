package fnscriper.command
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Point;

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
	public final class EffectFuns
	{
		public static function effect10(effectbmd:BitmapData,oldbmd:BitmapData,screen:BitmapData,percent:Number):void
		{
			effectbmd.copyPixels(oldbmd,oldbmd.rect,new Point());
			effectbmd.merge(screen,screen.rect,new Point(),percent * 255,percent * 255,percent * 255,percent * 255);
		}
	}
}