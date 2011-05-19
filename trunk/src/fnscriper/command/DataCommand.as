package fnscriper.command
{
	import flash.utils.ByteArray;
	
	import fnscriper.FNSFacade;
	import fnscriper.FNSRunner;
	import fnscriper.FNSVO;
	import fnscriper.util.FNSUtil;
	import fnscriper.util.OperatorUtil;

	public class DataCommand extends CommandBase
	{
		[CMD("S")]
		public function stralias(key:String,value:String):void
		{
			runner.stralias[key] = value;
		}
		
		/**
		 * 设置数值常量 
		 * @param v
		 * 
		 */
		[CMD("S")]
		public function numalias(key:String,value:Object):void
		{
			runner.numalias[key] = value;
		}
		
		[CMD("S")]
		public function mov(key:String,value:Object):void
		{
			model.setVar(key,value);
		}
		
		[CMD("S")]
		public function movl(key:String,...reg):void
		{
			mov(key,reg);
		}
		
		[CMD("S")]
		public function dim(key:String,...reg):void
		{
			mov(key,createArray(reg));
		}
		
		private function createArray(len:Array):Array
		{
			len = len.concat();
			
			var arr:Array = [];
			var l:int = len.shift();
			for (var i:int = 0; i < l; i++)
			{
				if (len.length)
					arr[i] = createArray(len);
				else
					arr[i] = 0;
			}	
			return arr;
		}
		
		[CMD("S")]
		public function add(key:String,value:Number):void
		{
			model.setVar(key,model.getNumVar(key) + value);
		}		
		[CMD("S")]
		public function sub(key:String,value:Number):void
		{
			model.setVar(key,model.getNumVar(key) - value);
		}
		[CMD("S")]
		public function mul(key:String,value:Number):void
		{
			model.setVar(key,model.getNumVar(key) * value);
		}
		[CMD("S")]
		public function div(key:String,value:Number):void
		{
			model.setVar(key,int(model.getNumVar(key) / value));
		}
		[CMD("S")]
		public function mod(key:String,value:Number):void
		{
			model.setVar(key,model.getNumVar(key) % value);
		}
		[CMD("S")]
		public function inc(key:String):void
		{
			add(key,1);
		}
		[CMD("S")]
		public function dec(key:String):void
		{
			add(key,-1);
		}
		[CMD("S")]
		public function len(key:String,v:String):void
		{
			var byte:ByteArray = new ByteArray();
			byte.writeMultiByte(v,"gb2312");
			model.setVar(key,byte.length);
		}
		[CMD("S")]
		public function mid(key:String,v:String,start:int,len:int):void
		{
			var byte:ByteArray = new ByteArray();
			byte.writeMultiByte(v,"gb2312");
			byte.position = start;
			v = byte.readMultiByte(len,"gb2312");
			model.setVar(key,v);
		}
		[CMD("S")]
		public function rnd(key:String,max:int):void
		{
			rnd2(key,0,max);
		}
		[CMD("S")]
		public function rnd2(key:String,min:int,max:int):void
		{
			model.setVar(key,int(Math.random() * (max - min)) + min);	
		}		
		[CMD("S")]
		public function itoa(key:String,v:int):void
		{
			mov(key,v);
		}
		[CMD("S")]
		public function atoi(key:String,v:String):void
		{
			mov(key,v);
		}
		[CMD("S")]
		public function intlimit(key:String,min:int,max:int):void
		{
			model.intlimitmin[int(key.slice(1))] = min
			model.intlimitmax[int(key.slice(1))] = max;
		}
		
		/**
		 * 获得函数参数 
		 * @param v
		 * 
		 */
		[CMD("SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS")]
		public function getparam(...arr):void
		{
			var params:Array = FNSUtil.split(model.callLayerParam[model.callLayerParam.length - 1],",");
			params = runner.decodeParams(null,params)
			for (var i:int = 0;i < arr.length;i++)
				model.setVar(arr[i],params[i]);
		}
	}
}