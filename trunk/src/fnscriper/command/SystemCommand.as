package fnscriper.command
{
	import flash.display.StageDisplayState;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import flashx.textLayout.elements.BreakElement;
	
	import fnscriper.FNSFacade;

	public class SystemCommand extends CommandBase
	{
		/**
		 * skip -快速略过 
		 * reset -游戏复位 
		 * save -储存档案 
		 * load -读取档案 
		 * lookback -回顾前一段文字 
		 * windowerase -屏蔽文字框
		 * 
		 */
		[CMD("S")]
		public function systemcall(v:String):void
		{
			switch(v)
			{
				case "skip":
					runner.isSkip = true;
					break;
				case "end":
				case "reset":
					runner.reset();
					runner.doNext();
					break;
				case "save":
					save();
					break;
				case "load":
					load();
					break;
				case "lookback":
					view.textWindow.showHistory();
					break;
				case "windowerase":
					view.textWindow.visible = false;
					break;
				case "fullscreen":
					if (view.stage.displayState != StageDisplayState.FULL_SCREEN)
						view.stage.displayState = StageDisplayState.FULL_SCREEN
					else
						view.stage.displayState = StageDisplayState.NORMAL
					break;
			}
		}
		

		private var menuCustomItems:Array;
		public function rmenu(...reg):void
		{
			var menu:ContextMenu = view.contextMenu;
			var cmds:Dictionary = new Dictionary();
			for (var i:int = 0;i < reg.length;i += 2)
			{
				var item:ContextMenuItem = new ContextMenuItem(reg[i],i == 0);
				item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,menuItemSelectHandler);
				menu.customItems.push(item);
				
				cmds[item] = reg[i + 1];
			}
			view.contextMenu = menu;
			
			this.menuCustomItems = menu.customItems;
			
			function menuItemSelectHandler(event:ContextMenuEvent):void
			{
				systemcall(cmds[event.currentTarget]);
			}
		}
		
		public function rmode(v:int):void
		{
			view.contextMenu.customItems = v == 1 ? menuCustomItems : [];
			view.contextMenu = view.contextMenu;
		}
		
		private function load():void
		{
			var file:FileReference = new FileReference();
			file.addEventListener(Event.SELECT,selectFileHandler);
			file.browse([new FileFilter("sav文件","*.sav")]);
			
			function selectFileHandler(event:Event):void
			{
				file.removeEventListener(Event.SELECT,selectFileHandler);
				file.addEventListener(Event.COMPLETE,result);
				file.load();
			}
			
			function result(e:Event):void
			{
				model.createFromByteArray(file.data);
				view.loadFromVO();
			}
		}
		
		private var tempsave:ByteArray;

		private function save():void
		{
			var file:FileReference = new FileReference();
			file.save(tempsave ? tempsave : model.getByteArray(),"game.sav");
		}
		
		
		public function saveon():void
		{
			model.saveon = true;
			tempsave = null;
		}
		
		public function saveoff():void
		{
			model.saveon = false;
			tempsave = model.getByteArray();
		}
		
		public function lookbackflush():void
		{
			view.textWindow.historyIndex = -1;
			view.textWindow.showText(view.textWindow.historyText[view.textWindow.historyText.length - 1]);
		}
		
		[CMD("SS")]
		public function clickpos(x:String,y:String):void
		{
			model.setVar(x,view.mouseX);
			model.setVar(y,view.mouseY);
		}
		
		public function skipoff():void
		{
			runner.isSkip = false;
		}
		
		public function resettimer():void
		{
			model.timer = getTimer();
		}
		
		public function menu_full():void
		{
			view.stage.displayState = StageDisplayState.FULL_SCREEN;
		}
		
		public function menu_window():void
		{
			view.stage.displayState = StageDisplayState.NORMAL;
		}
		
		[CMD("S")]
		public function gettimer(v:String):void
		{
			var t:int = getTimer() - model.timer;
			model.setVar(v,t);
		}
		[CMD("SSS")]
		public function date(y:String,m:String,d:String):void
		{
			var date:Date= new Date();
			model.setVar(y,date.fullYear);
			model.setVar(m,date.month + 1);
			model.setVar(d,date.day);
		}
		[CMD("SSS")]
		public function time(h:String,m:String,s:String):void
		{
			var date:Date= new Date();
			model.setVar(h,date.hours);
			model.setVar(m,date.minutes);
			model.setVar(s,date.seconds);
		}
	}
}