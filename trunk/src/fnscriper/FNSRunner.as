package fnscriper
{
	import flash.display.Sprite;
	import flash.media.SoundChannel;
	import flash.utils.describeType;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.elements.BreakElement;
	import flashx.textLayout.elements.ListElement;
	
	import fnscriper.command.CommandBase;
	import fnscriper.command.DataCommand;
	import fnscriper.command.IgnoreCommand;
	import fnscriper.command.ImageCommand;
	import fnscriper.command.InteractiveCommand;
	import fnscriper.command.SoundCommand;
	import fnscriper.command.SystemCommand;
	import fnscriper.command.TextCommand;
	import fnscriper.util.FNSUtil;
	import fnscriper.util.OperatorUtil;

	public class FNSRunner
	{
		public var data:Array;
		public var commands:Object = {};
		public var commandParams:Object = {};
		
		/**
		 * 数值定义
		 */
		public var numalias:Object = {};
		
		/**
		 * 标签
		 */
		public var labels:Object = new Object();
		
		/**
		 * 函数
		 */
		public var defsubs:Object = new Object();
		
		/**
		 * 暂时不执行下面的指令 
		 */
		public var isWait:Boolean;
		
		public var isSkip:Boolean;
		
		private var _isLock:Boolean;

		/**
		 * 暂时锁定游戏
		 */
		public function get isLock():Boolean
		{
			return _isLock;
		}

		public function set isLock(value:Boolean):void
		{
			_isLock = value;
			FNSFacade.instance.mouseEnabled = FNSFacade.instance.mouseChildren = !value;
		}
		
		
		public function get model():FNSVO
		{
			return FNSFacade.instance.model;
		}
		
		public function get view():FNSView
		{
			return FNSFacade.instance.view;
		}
			
		public function FNSRunner()
		{
			this.initCommands();
		}
		
		protected function initCommands():void
		{
			commands = {
				"goto":goto,
				"game":game,
				"defsub":defsub,
				"return":defsubReturn,
				"reset":reset
			};
			regCommand(new IgnoreCommand());
			regCommand(new DataCommand());
			regCommand(new InteractiveCommand());
			regCommand(new ImageCommand());
			regCommand(new SoundCommand());
			regCommand(new TextCommand());
			regCommand(new SystemCommand());
		}
	
		public function regCommand(command:CommandBase):void
		{
			var xml:XML = describeType(command);
			for each (var method:XML in xml.method)
			{
				var name:String = method.@name;
				commands[name] = command[name];
				
				//获得命令参数限制，空格为不限制，T为限制为字符串，N为限制为数字,S为不转义
				var metadata:XMLList = method.metadata.(@name == "CMD").*;
				if (metadata.length())
				{ 
					var o:Object = {};
					for each (var arg:XML in metadata)
						o[arg.@key.toString()] = arg.@value.toString();
					
					commandParams[name] = o;
				}
			}
		}
		
		public function setData(v:String):void
		{
			v = v.replace(/\/\r?\n/,"");
			data = v.split(/\r?\n/);
			initData();
		}
		
		protected function initData():void
		{
			for (var i:int = 0;i < data.length;i++)
			{
				var line:String = data[i];
				line = line.replace(/;[^"]*$/,"");
				if (line.charAt(0) == "*")
				{
					var value:String = line.slice(1);
					labels[value] = i;
					continue;
				}
				
				var arr:Array = line.split(/\s+/);
				var cmd:String = arr.shift();
				value = arr.join();
				if (cmd)
				{
					var params:Array = FNSUtil.split(value,",");
					if (cmd == "defsub")
						defsubs[params[0]] = true;
					else if (cmd == "numalias")
						numalias[params[0]] = params[1];
				}
			}
		}
		
		public function run():void
		{
			var origin:String = data[model.step];
			trace(origin);
			origin = origin.replace(/;[^"]*$/,"");
			var lines:Array = FNSUtil.split(origin,":");
			for each (var line:String in lines)
			{
				if (line.length && line.charAt(0) != "*")
				{
					if (line.slice(0,3) == "if ") //条件判断
					{
						var ifBody:String = getIfBody(line);
						if (FNSUtil.decodeNumber(ifBody,false))
							line = line.slice(ifBody.length + 4);
						else
							break;//跳过此行
					}
					else if (line.slice(0,4) == "for ")//循环
					{
						forStart(line.slice(4));
						break;
					}
					
					var arr:Array = line.split(/\s+/);
					var cmd:String = arr.shift();
					var value:String = arr.join();
					if (cmd)
					{
						if (commands.hasOwnProperty(cmd))
						{
							//指令
							var params:Array;
							if (value == "")
								params = null;
							else
								params = decodeParams(cmd,FNSUtil.split(value,","));
							
							runCommand(cmd,params);
						}
						else if (defsubs.hasOwnProperty(cmd))
						{
							runDefsub(cmd,value);
							break;
						}
						else
						{
							runCommand("putText",[line]);
						}
					}
				}
			}
		}
		
		public function runCommand(cmd:String,params:Array = null):void
		{
			var fun:Function = commands[cmd];
			fun.apply(null,params);
		}
		
		public function decodeParams(cmd:String,params:Array):Array
		{
			var cmdParams:String = commandParams[cmd] ? commandParams[cmd].paramTypes : "";
			var result:Array = [];
			for (var i:int = 0;i < params.length;i++)
			{
				var v:String = params[i];
				var cmdParam:String = i < cmdParams.length ? cmdParams.charAt(i) : " ";
				if (v.charAt(0) == "*" || v.charAt(0) == "#")
					result[i] = params[i];
				else if (cmdParam == "S")
					result[i] = FNSUtil.decodeNumaliasReplace(params[i]);
				else if (cmdParam == "T" || v.indexOf("\"") != -1 || v.indexOf("$") != -1)
					result[i] = FNSUtil.decodeString(v);
				else
					result[i] = FNSUtil.decodeNumber(v);
			}
			return result;
		}
		
		private function getIfBody(value:String):String
		{
			var list:Array = value.split(" ");
			for (var i:int = 0;i < list.length;i++)
			{
				var v:String = list[i];
				if (commands.hasOwnProperty(v) || defsubs.hasOwnProperty(v))
					break;
			}
			return list.slice(1,i).join(" ");
		}
		
		public function doNext():void
		{
			while (!isWait && !isLock && model.step < data.length - 1)
			{
				model.step++;
				run();
			}
		}
		
		/**
		 * 游戏开始
		 * 
		 */
		public function startGame():void
		{
			goto("*define");
			doNext();
		}
		
		/*
		* 基本指令
		*/
		
		public function runDefsub(subName:String,value:String):void
		{
			model.callLayer.push(model.step);
			model.callLayerParam.push(value);
			goto("*"+subName);
		}
		
		public function defsubReturn():void
		{
			model.callLayerParam.pop();
			model.step = model.callLayer.pop();
		}
		
		
		public function defsub(v:String):void
		{
			defsubs[v] = true;
		}
		
		public function forStart(v:String):void
		{
			var arr:Array = v.split(" ");
			var max:int = arr.pop();
			if (arr.pop() != "to")
				return;
			arr = arr.join().split("=");
			var param:String = arr[0];
			var start:int = arr[1];
			
			model.vars[param] = start;
			model.forLayer.push(model.step);
			model.forLayerParam.push([param,max].join(","));
		}
		
		public function next():void
		{
			var params:Array = model.forLayerParam[model.forLayerParam.length - 1].toString().split(",");
			var index:int = model.vars[params[0]];
			var max:int = params[1];
			if (index < max)
			{
				model.vars[params[0]]++;
				model.step = model.forLayer[model.forLayer.length - 1];
			}
			else
			{
				model.forLayer.pop();
				params.pop();
			}
		}
		
		public function goto(v:String):void
		{
			model.step = int(labels[v.toString().slice(1)]);
		}
		
		public function game():void
		{
			goto("*start");
		}
		
		public function reset():void
		{
			model.clear();
			view.clear();
			
			isWait = false;
			game();
		}
	}
}