package gessie.util;
import haxe.Timer;

/**
 * ...
 * @author Kevin
 */
class Util
{
	public static var SCREEN_DPI = #if openfl openfl.system.Capabilities.screenDPI #else 160 #end;
	
	static var DEGREE_TO_RADIAN = Math.PI / 180;
	static var RADIAN_TO_DEGREE = 180 / Math.PI;

	public static inline function getTimer() 
	{
		return Std.int(Timer.stamp() * 1000);
	}
	
	public static inline function degreeToRadian(v:Float):Float
	{
		return v * DEGREE_TO_RADIAN;
	}
	
	public static inline function radianToDegree(v:Float):Float
	{
		return v * RADIAN_TO_DEGREE;
	}
	
}