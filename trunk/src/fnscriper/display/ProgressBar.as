package fnscriper.display
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class ProgressBar extends Sprite
	{
		public var textField:TextField;
		private var _target:IEventDispatcher;

		
		public function ProgressBar(target:IEventDispatcher)
		{
			super();
			
			this.target = target;
			
			this.textField = new TextField();
			this.textField.selectable = false;
			this.textField.autoSize = TextFieldAutoSize.LEFT;
			this.textField.defaultTextFormat = new TextFormat(null,null,0xFFFFFF)
			this.addChild(this.textField);
		}
		
		
		public function get target():IEventDispatcher
		{
			return _target;
		}
		
		public function set target(value:IEventDispatcher):void
		{
			_target = value;
			if (_target)
			{
				_target.addEventListener(ProgressEvent.PROGRESS,progressHandler);
				_target.addEventListener(Event.COMPLETE,completeHandler);
			}
		}
		
		private function completeHandler(e:Event):void
		{
			if (_target)
			{
				_target.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
				_target.removeEventListener(Event.COMPLETE,completeHandler);
			
				if (this.parent)
					this.parent.removeChild(this);
			}
		}
		
		private function progressHandler(e:ProgressEvent):void
		{
			textField.text = (e.bytesLoaded / e.bytesTotal * 100).toFixed(0);
			textField.x = -textField.width / 2;
			textField.y = -textField.height / 2;
			
			graphics.clear();
			graphics.lineStyle(0,0xFFFFFF);
			graphics.moveTo(10,0);
			drawCurve(0,0,10,10,0,360 * e.bytesLoaded / e.bytesTotal);
		}
		
		private function drawCurve(x:Number,y:Number,wradius:Number,hradius:Number,fromAngle:Number,toAngle:Number):void
		{
			var start:Number = fromAngle / 180 * Math.PI;
			var angle:Number = (toAngle - fromAngle) / 180 * Math.PI;
			var n:Number = Math.ceil(Math.abs(angle) / (Math.PI / 4));
			var angleS:Number = angle / n;
			for (var i:int = 1;i <= n;i++)
			{
				start += angleS;
				var angleMid:Number = start - angleS / 2;
				var bx:Number = x + wradius / Math.cos(angleS / 2) * Math.cos(angleMid);
				var by:Number = y + hradius / Math.cos(angleS / 2) * Math.sin(angleMid);
				var cx:Number = x + wradius * Math.cos(start);
				var cy:Number = y + hradius * Math.sin(start);
				graphics.curveTo(bx,by,cx,cy);
			}
		}
	}
}