package
{
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	
	import fnscriper.FNSFacade;
	
	import org.osmf.layout.ScaleMode;
	
	[SWF(width="800",height="600",frameRate="60",backgroundColor="0x0")]
	public class FNScripter extends fnscriper.FNSFacade
	{
		public function FNScripter():void
		{
			this.scrollRect = new Rectangle(0,0,800,600);
//			this.scaleX = this.scaleY = 0.5;
		}
	}
}