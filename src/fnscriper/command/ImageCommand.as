package fnscriper.command
{
	import fnscriper.display.Image;
	import fnscriper.util.FNSUtil;

	public class ImageCommand extends CommandBase
	{
		public function underline(v:int):void
		{
			model.underline = v;
		}
		
		public function transmode(v:String):void
		{
			model.transmode = v;
		}
		
		public function windowback():void
		{
			model.windowback = true;
		}
		
		public function humanz(v:int):void
		{
			model.humanz = v;
		}
		
		public function print(effect:int = 0,length:int = 0,img:String = ""):void
		{
			view.print(effect,length,img);
		}
		
		/**
		 * 背景 
		 * @param url
		 * @param effect
		 * @param length
		 * 
		 */
		public function bg(url:String,effect:int = -1,len:int = 0,img:String = ""):void
		{
			model.bg = url;
			view.bg(url);
			if (effect != -1)
				print(effect,len,img);
		}
		
		/**
		 * 显示站立图  
		 * @param index
		 * @param url
		 * @param effect
		 * 
		 */
		public function ld(index:String,url:String,effect:int = -1, len:int = 0,img:String = ""):void
		{
			lsp(index,url);
			if (effect != -1)
				print(effect,len,img);
		}
			
		/**
		 * 清除站立图 
		 * @param index
		 * 
		 */
		public function cl(index:String):void
		{
			if (index == "a")
			{
				cl("l");
				cl("c");
				cl("r");
			}
			else
			{
				csp(index);
			}	
		}

		/**
		 * 改变站立图的透明度 
		 * @param index
		 * @param alpha
		 * 
		 */
		public function tal(index:String,alpha:int):void
		{
			if (index == "a")
			{
				tal("l",alpha);
				tal("c",alpha);
				tal("r",alpha);
			}
			else
			{
				tasp(index,alpha);
			}
		}
		
		/**
		 * 显示 
		 * @param index
		 * @param url
		 * @param x
		 * @param y
		 * @param alpha
		 * 
		 */
		public function lsp(index:String,url:String,x:int = 0,y:int = 0,alpha:int = 100):void
		{
			if (model.sp[index])
				csp(index);
			
			model.sp[index] = {url:url,x:x,y:y,alpha:alpha,visible:1};
			view.lsp(index,url,x,y,alpha);
		}
		
		/**
		 * 显示并隐藏 
		 * @param index
		 * @param url
		 * 
		 */
		public function lsph(index:String,url:String):void
		{
			lsp(index,url);
			vsp(index,0);
		}
		
		/**
		 * 隐藏
		 * @param index
		 * @param visible
		 * 
		 */
		public function vsp(index:String,visible:int):void
		{
			model.sp[index].visible = visible;
			view.getsp(index).visible = visible == 1;
		}
		
		/**
		 * 销毁
		 * @param v
		 * 
		 */
		public function csp(index:String):void
		{
			if (int(index) == -1)
			{
				for (var p:String in model.sp)
					csp(p);
			}
			else
			{
				var sp:Image = view.getsp(index);
				if (sp)
					sp.destory();
				delete model.sp[index];
			}
		}
		
		/**
		 * 透明度 
		 * @param index
		 * @param alpha
		 * 
		 */
		public function tasp(index:String,alpha:int):void
		{
			model.sp[index].alpha = alpha;
			view.getsp(index).alpha = alpha / 100;
		}
		
		/**
		 * 设置帧 
		 * @param index
		 * @param cell
		 * 
		 */
		public function cell(index:String,cell:int):void
		{
			model.sp[index].cellIndex = cell;
			view.getsp(index).cellIndex = cell;
		}
		
		/**
		 * 组合命令 
		 * @param v
		 * 
		 */
		public function spstr(v:String):void
		{
			var start:int = 0;
			var end:int = 1;
			while (end < v.length)
			{
				var ch:String = v.charAt(end);
				if (ch == "C" || ch == "P" || end == v.length - 1)
				{
					var cmd:String = v.charAt(start);
					var params:Array = v.slice(start + 1,end).split(",");
					if (cmd == "C")
						vsp(params[0],0);
					else
					{
						vsp(params[0],1)
						if (params.length > 1)
							cell(params[0],params[1]);
					}
					start = end;
				}
			}
		}
		
		/**
		 * 相对位移
		 * @param index
		 * @param x
		 * @param y
		 * @param alpha
		 * 
		 */
		public function msp(index:String,x:int,y:int,alpha:int = 100):void
		{
			var v:Object = model.sp[index];
			if (!v)
				return;
			
			v.x += x;
			v.y += y;
			v.alpha += alpha;
			amsp(index,v.x,v.y,v.alpha);
		}
		
		/**
		 * 绝对位移 
		 * @param index
		 * @param x
		 * @param y
		 * @param alpha
		 * 
		 */
		public function amsp(index:String,x:int,y:int,alpha:int = 100):void
		{
			var v:Object = model.sp[index];
			if (!v)
				return;
			
			v.x = x;
			v.y = y;
			v.alpha = alpha;
			var image:Image = view.getsp(index);
			image.x = x;
			image.y = y;
			image.alpha = alpha / 100;
		}
		
		[CMD(" SS")]
		public function getspsize(index:String,wField:String,hField:String):void
		{
			var v:Image = view.sp[index];
			if (!v)
				return;
			
			model.setVar(wField,v.width);
			model.setVar(hField,v.height);
		}
		
		public function avi(v:String,haltable:int):void
		{
			mpegplay(v,haltable);
		}
		
		public function mpegplay(v:String,haltable:int):void
		{
			runner.isWait = true;
			view.mpegplay(v,haltable);
		}
		
		public function repaint():void
		{
			view.loadFromVO();
		}
		
		public function allsphide():void
		{
			view.screenbm.visible = false;
		}
		
		public function allspresume():void
		{
			view.screenbm.visible = true;
		}
	}
}