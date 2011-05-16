package fnscriper.command
{
	import fnscriper.FNSFacade;
	import fnscriper.FNSRunner;
	import fnscriper.FNSVO;
	import fnscriper.util.FNSUtil;
	import fnscriper.util.OperatorUtil;

	public class DataCommand extends CommandBase
	{
		/**
		 * 设置数值常量 
		 * @param v
		 * 
		 */
		[CMD(paramTypes="S")]
		public function numalias(key:String,value:Object):void
		{
			runner.numalias[key] = value;
		}
		
		/**
		 * 变量赋值 
		 * @param v
		 * 
		 */
		[CMD(paramTypes="S")]
		public function mov(key:String,value:Object):void
		{
			model.setVar(key,value);
		}
		
		/**
		 * 获得函数参数 
		 * @param v
		 * 
		 */
		[CMD(paramTypes="SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS")]
		public function getparam(...arr):void
		{
			var params:Array = FNSUtil.split(model.callLayerParam[model.callLayerParam.length - 1],",");
			params = runner.decodeParams(null,params)
			for (var i:int = 0;i < arr.length;i++)
				model.setVar(arr[i],params[i]);
		}
	}
}