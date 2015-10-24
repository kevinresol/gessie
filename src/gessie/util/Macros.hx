package gessie.util;
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.ExprTools;

/**
 * ...
 * @author Kevin
 */
class Macros
{

	public static macro function assertNull(e:Expr, ?msg:String) 
	{
		if (msg == null) msg = '${e.toString()} is null';
		return  macro @:pos(Context.currentPos()) if($e == null) throw $v{msg};
	}
	
}