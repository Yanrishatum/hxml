package hxml;

import haxe.macro.Context;
import haxe.macro.Expr;

class ArgMacro
{
    static var output : String;
    //#if !display
    macro public static function createArgArray() : ExprOf<Array<String>>
    {
        var regex = ~/(?:,\s|^\s\s)(-?-*[\w;-]*)/gm;
        var args = [];
        
        callHaxe();
        var out = output;
        var argList:Array<String> = new Array();
        
        inline function addArg(arg:String):Void
        {
            if (arg.indexOf("--") == 0)
            {
                argList.push(arg.substr(1));
                args.push(macro $v{arg.substr(1)});
            }
            else 
            {
                argList.push("-" + arg);
                args.push(macro $v{"-" + arg});
            }
            argList.push(arg);
            args.push(macro $v{arg});
        }
        
        inline function legacy(arg:String):Void
        {
            if (argList.indexOf(arg) == -1) addArg(arg);
        }
        
        while (regex.match(out)) {
            addArg(regex.matched(1));
            out = regex.matchedRight();
        }
        legacy("-cp");
        legacy("-lib");
        legacy("-main");
        
        return macro $a{args};
    }
    
    macro public static function createTargetArray() : ExprOf<Array<String>>
    {
        var targetReg:EReg = ~/Target\r?\n((?:.*\r?\n)+)Compilation\r?\n/gm;
        var regex = ~/(?:,\s|^\s\s)(-?-*[\w;-]*)/gm;
        var targets = [];
        
        callHaxe();
        targetReg.match(output);
        var out = targetReg.matched(1);
        
        while (regex.match(out)) {
            targets.push(macro $v{regex.matched(1)}); // --target
            targets.push(macro $v{regex.matched(1).substr(1)}); // -target
            out = regex.matchedRight();
        }
        return macro $a{targets};
    }
    
    #if macro
    static function callHaxe() : Void
    {
        if (output == null) {
            
            var help = new sys.io.Process("haxe", ["--help"]);
            output = help.stdout.readAll().toString();
            help.kill();
        }
    }
    
    #end
    //#end
}
