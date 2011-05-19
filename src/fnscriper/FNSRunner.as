package fnscriper
{
	import flash.display.Sprite;
	import flash.media.SoundChannel;
	import flash.net.drm.VoucherAccessInfo;
	import flash.utils.describeType;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.elements.BreakElement;
	import flashx.textLayout.elements.ListElement;
	
	import fnscriper.command.ButtonCommand;
	import fnscriper.command.CommandBase;
	import fnscriper.command.DataCommand;
	import fnscriper.command.EffectCommand;
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
		public var stralias:Object = {};
		
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
		public var isTextWait:Boolean;
		public var isSkip:Boolean;
		public var isBtnMode:Boolean;
		
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
				"skip":skip,
				"jumpb":jumpb,
				"jumpf":jumpf,
				"game":game,
				"defsub":defsub,
				"break":forbreak,
				"next":fornext,
				"return":subreturn,
				"reset":reset
			};
			regCommand(new IgnoreCommand());
			regCommand(new DataCommand());
			regCommand(new InteractiveCommand());
			regCommand(new ButtonCommand());
			regCommand(new ImageCommand());
			regCommand(new SoundCommand());
			regCommand(new TextCommand());
			regCommand(new SystemCommand());
			regCommand(new EffectCommand())
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
					{
						var key:String = arg.@key.toString();
						if (key == "") 
							key = "paramTypes";
						o[key] = arg.@value.toString();
					}
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
				line = line.replace(/^\s+/,"").replace(/;[^"]*$/,"");
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
					else if (cmd == "stralias")
						stralias[params[0]] = params[1].toString().slice(1,params[1].toString().length - 1);
					else if (cmd == "numalias")
						numalias[params[0]] = int(params[1]).toString();
				}
			}
		}
		
		public function run():void
		{
			var origin:String = data[model.step];
			trace(origin);
			origin = origin.replace(/^\s+/,"").replace(/;[^"]*$/,"");
			var lines:Array = FNSUtil.split(origin,":");
			for each (var line:String in lines)
			{
				if (line.length && line.charAt(0) != "*" && line.charAt(0) != "~")
				{
					if (line.slice(0,3) == "if ") //条件判断
					{
						var ifBody:String = getIfBody(line);
						if (FNSUtil.decodeNumber(ifBody,false))
							line = line.slice(ifBody.length + 3 + 1);
						else
							break;//跳过此行
					}
					else if (line.slice(0,6) == "notif ")
					{
						ifBody = getIfBody(line);
						if (!FNSUtil.decodeNumber(ifBody,false))
							line = line.slice(ifBody.length + 6 + 1);
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
							gosub(cmd,value);
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
					result[i] = FNSUtil.decodeStraliasReplace(FNSUtil.decodeNumaliasReplace(params[i]));
				else if (cmdParam != "N" && (cmdParam == "T" || v.indexOf("\"") != -1 || v.indexOf("$") != -1))/*不准确的判断字符串方式*/
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
			while (!isWait && !isTextWait && model.step < data.length - 1)
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
		
		public function gosub(subName:String,value:String = null):void
		{
			model.callLayer.push(model.step);
			model.callLayerParam.push(value);
			goto("*"+subName);
		}
		
		public function subreturn():void
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
			var end:int;
			var step:int = 1;
			var n:int = arr.pop();
			var sys:String = arr.pop();
			if (sys == "step")
			{
				step = n;
				n = arr.pop();
				sys = arr.pop();
				if (sys == "to")
					end = n;
				else
					return;
			}
			else if (sys == "to")
				end = n;
			else
				return;
			
			arr = arr.join().split("=");
			var param:String = arr[0];
			var start:int = arr[1];
			
			model.setVar(param,start);
			model.forLayer.push(model.step);
			model.forLayerParam.push([param,end,step].join(","));
		}
		
		public function fornext():void
		{
			var params:Array = model.forLayerParam[model.forLayerParam.length - 1].toString().split(",");
			var index:int = model.getNumVar(params[0]);
			var end:int = params[1];
			var step:int = params[2];
			if (int(step) > 0 ? (index <= end) : (index >= end))
			{
				model.setVar(params[0],index + int(step));
				model.step = model.forLayer[model.forLayer.length - 1];
			}
			else
			{
				model.forLayer.pop();
				params.pop();
			}
		}
		
		public function forbreak():void
		{
			model.forLayer.pop();
			var params:Array = model.forLayerParam[model.forLayerParam.length - 1].toString().split(",");
			params.pop();
			var depth:int = 1;
			do
			{
				model.step++;
				var line:String = data[model.step];
				if (line.slice(0,4) == "for ")
					depth++;
				if (line == "next")
					depth--;
			}
			while (depth > 0);
		}
		
		public function goto(v:String):void
		{
			model.step = int(labels[v.toString().slice(1)]);
		}
		
		public function game():void
		{
			goto("*start");
		}
		
		public function skip(v:int):void
		{
			model.step += v;
		}
		
		public function jumpf():void
		{
			do
			{
				model.step--
			}
			while (data[model.step].toString().charAt(0) == "~");
		}
		public function jumpb():void
		{
			do
			{
				model.step++
			}
			while (data[model.step].toString().charAt(0) == "~");
		}
		
		public function reset():void
		{
			model.clear();
			view.clear();
			
			isWait = isBtnMode = isTextWait = isSkip = false;
			game();
		}
	}
}