package fnscriper.command
{
	import fnscriper.FNSAsset;
	import fnscriper.FNSFacade;
	import fnscriper.FNSRunner;
	import fnscriper.FNSVO;
	import fnscriper.FNSView;

	public class CommandBase
	{
		public function get asset():FNSAsset
		{
			return FNSFacade.instance.asset; 
		}
		
		public function get facade():FNSFacade
		{
			return FNSFacade.instance;
		}
		
		public function get model():FNSVO
		{
			return FNSFacade.instance.model;
		}
		
		public function get runner():FNSRunner
		{
			return FNSFacade.instance.runner;
		}
		
		public function get view():FNSView
		{
			return FNSFacade.instance.view;
		}
	}
}