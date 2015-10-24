package gessie.util;
import haxe.Timer;

/**
 * ...
 * @author Kevin
 */
class Util
{

	public static inline function getTimer() 
	{
		return Std.int(Timer.stamp() * 1000);
	}
	
}