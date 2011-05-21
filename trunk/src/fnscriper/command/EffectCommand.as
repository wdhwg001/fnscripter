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
		
		public function print(effect:int = 0):void
		{
			if (effect <= 1)
			{
				view.print(effect);
			}
			else
			{
				var index:int = effect;
				view.print(model.effect[index],model.effectlen[index],model.effectimg[index]);
			}
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
		}
		
		public function nega(v:int):void
		{
			model.nega = v;
		}
	}
}