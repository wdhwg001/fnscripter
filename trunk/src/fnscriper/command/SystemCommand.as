package fnscriper.command
{
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
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
		[CMD(paramTypes="S")]
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
			}
		}
		

		public function rmenu(...reg):void
		{
			var menu:ContextMenu = view.contextMenu;
			var cmds:Dictionary = new Dictionary();
			for (var i:int = 0;i < reg.length;i+=2)
			{
				var item:ContextMenuItem = new ContextMenuItem(reg[i],i == 0);
				item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,menuItemSelectHandler);
				menu.customItems.push(item);
				
				cmds[item] = reg[i + 1];
			}
			view.contextMenu = menu;
			
			function menuItemSelectHandler(event:ContextMenuEvent):void
			{
				systemcall(cmds[event.currentTarget]);
			}
		}
		
		private function load():void
		{
			var file:FileReference = new FileReference();
			file.addEventListener(Event.SELECT,selectFileHandler);
			file.addEventListener(Event.CANCEL,fault);
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
			
			function fault(e:Event):void
			{
			}
		}
		
		private function save():void
		{
			var file:FileReference = new FileReference();
			file.addEventListener(Event.SELECT,selectFileHandler);
			file.addEventListener(Event.CANCEL,fault);
			file.save(model.getByteArray(),"game.sav");
			
			function selectFileHandler(event:Event):void
			{
			}
			
			function fault(e:Event):void
			{
			}
		}
	}
}