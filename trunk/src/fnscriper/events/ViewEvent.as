package fnscriper.events
{
	import flash.events.Event;
	
	public class ViewEvent extends Event
	{
		public static const VIEW_CLICK:String = "view_click";
		public var btnIndex:int = -1;
		public var isSkip:Boolean;
		public function ViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}