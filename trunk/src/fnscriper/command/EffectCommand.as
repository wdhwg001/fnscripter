package fnscriper.command
{
	public class EffectCommand extends CommandBase
	{
		public function effect(index:int,effect:int,len:int = 1000,img:String = ""):void
		{
			model.effect[index] = effect;
			model.effectlen[index] = len;
			model.effectimg[index] = img;
		}
		
		public function effectblank(v:int):void
		{
			model.effectblank = v;
		}
		
		public function quake(num:int,len:int):void
		{
			view.quake(num,len,0);
		}
		
		public function quakex(num:int,len:int):void
		{
			view.quake(num,len,1);
		}
		
		public function quakey(num:int,len:int):void
		{
			view.quake(num,len,2);
		}
		
		public function monocro(v:String):void
		{
			model.monocro = v;
			view.screenfilter(model.monocro,model.nega);
		}
		
		public function nega(v:int):void
		{
			model.nega = v;
			view.screenfilter(model.monocro,model.nega);
		}
	}
}