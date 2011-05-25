package fnscriper.command
{
	import fnscriper.FNSAsset;
	import fnscriper.FNSFacade;
	import fnscriper.FNSRunner;
	import fnscriper.FNSVO;
	import fnscriper.FNSView;

	public class CommandBase
	{
		private var facade:FNSFacade;
		
		public function CommandBase(facade:FNSFacade):void
		{
			this.facade = facade;
		}
		
		public function get asset():FNSAsset
		{
			return facade.asset; 
		}
		
		public function get model():FNSVO
		{
			return facade.model;
		}
		
		public function get runner():FNSRunner
		{
			return facade.runner;
		}
		
		public function get view():FNSView
		{
			return facade.view;
		}
	}
}