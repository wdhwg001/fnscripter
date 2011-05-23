package fnscriper
{
	import flash.display.Sprite;
	import flash.media.SoundChannel;
	import flash.net.drm.VoucherAccessInfo;
	import flash.utils.describeType;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.debug.assert;
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
				"gosub":gosub,
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
			for (var i:int = 0;i < data.length;i++)
			{
				var line:String = FNSUtil.readLine(data[i]);
				if (line.charAt(0) == "*")
					labels[line.slice(1)] = i;
				
				data[i] = FNSUtil.split(line,":");
			}
		}
		
		public function run():void
		{
			FNSFacade.instance.asset.startLoad();
			
			var lines:Array = data[model.step];
			var line:String = lines[model.step2];
//			trace(line);
			if (line.length && line.charAt(0) != "*" && line.charAt(0) != "~")
			{
				if (line.slice(0,3) == "if ") //条件判断
				{
					var ifBody:String = getIfBody(line);
					if (FNSUtil.decodeNumber(ifBody,false))
					{
						line = line.slice(ifBody.length + 3 + 1);
					}
					else
					{
						model.step2 = lines.length - 1;
						return;//跳过此行
					}
				}
				else if (line.slice(0,6) == "notif ")
				{
					ifBody = getIfBody(line);
					if (!FNSUtil.decodeNumber(ifBody,false))
					{
						line = line.slice(ifBody.length + 6 + 1);
					}
					else
					{
						model.step2 = lines.length - 1;
						return;//跳过此行
					}
				}
				else if (line.slice(0,4) == "for ")//循环
				{
					forStart(line.slice(4));
					return;
				}
				
				var arr:Array = FNSUtil.split(line," ");
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
						gosub("*" + cmd,value);
					}
					else
					{
						runCommand("putText",[line]);
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
			while (!isWait && !isTextWait)
			{
				model.step2++;
				if (model.step2 >= data[model.step].length)
				{
					model.step++;
					model.step2 = 0;
				}
				if (model.step >= data.length)
					return;
				
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
			model.callStack.push({step:model.step,step2:model.step2,params:value});
			goto(subName);
		}
		
		public function subreturn():void
		{
			var o:Object = model.callStack.pop();
			model.step = o.step;
			model.step2 = o.step2;
		}
		
		
		public function defsub(v:String):void
		{
			defsubs[v] = true;
		}
		
		public function forStart(v:String):void
		{
			var arr:Array = v.split(" ");
			var end:int;
			var forstep:int = 1;
			var n:int = int(FNSUtil.decodeNumber(arr.pop()));
			var sys:String = arr.pop();
			if (sys == "step")
			{
				forstep = n;
				n = int(FNSUtil.decodeNumber(arr.pop()));
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
			var start:int = int(FNSUtil.decodeNumber(arr[1]));
			
			model.setVar(param,start);
			model.forStack.push({step:model.step,step2:model.step2,param:param,end:end,forstep:forstep});
		}
		
		public function fornext():void
		{
			var params:Object = model.forStack[model.forStack.length - 1];
			var index:int = model.getNumVar(params.param);
			var end:int = params.end;
			var forstep:int = params.forstep;
			if (int(forstep) > 0 ? (index <= end) : (index >= end))
			{
				model.setVar(params.param,index + int(forstep));
				model.step = params.step;
				model.step2 = params.step2;
			}
			else
			{
				model.forStack.pop();
			}
		}
		
		public function forbreak():void
		{
			model.forStack.pop();
			var depth:int = 1;
			do
			{
				model.step++;
				model.step2 = 0;
				var lines:Array = data[model.step];
				for (var line:String in lines)
				{
					if (line.slice(0,4) == "for ")
						depth++;
					if (line == "next")
						depth--;
				}
			}
			while (depth > 0);
		}
		
		public function goto(v:String):void
		{
			model.step = int(labels[v.toString().slice(1)]);
			model.step2 = 0;
		}
		
		public function game():void
		{
			goto("*start");
		}
		
		public function skip(v:int):void
		{
			model.step += v;
			model.step2 = 0;
		}
		
		public function jumpf():void
		{
			model.step2 = 0;
			do
			{
				model.step--
			}
			while (model.step >= 0 && data[model.step][0] && data[model.step][0].charAt(0) == "~");
		}
		public function jumpb():void
		{
			model.step2 = 0;
			do
			{
				model.step++
			}
			while (model.step < data.length && data[model.step][0] && data[model.step][0].charAt(0) == "~");
		}
		
		public function reset():void
		{
			model.clear();
			view.clear();
			
			isWait = isBtnMode = isTextWait = isSkip = false;
			goto("*define");
		}
	}
}