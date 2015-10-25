package gessie.core;

import gessie.geom.Point;

@:allow(gessie)
class Touch<T>
{
    public var id:Int;
    
    public var target:T;
		
	public var sizeX:Float;
	public var sizeY:Float;
	public var pressure:Float;
	
	public var time:Int;
	public var beginTime:Int;
	
    var location(default, null):Point;
    var locationOffset(get, never):Point;
    var beginLocation(default, null):Point;
    var prevLocation(default, null):Point;
    
    public function new(id = 0)
    {
        this.id = id;
    }
    
    
	function setLocation(x:Float, y:Float, time:Int):Void
	{
		location = new Point(x, y);
		beginLocation = location.clone();
		prevLocation = location.clone();
		
		this.time = beginTime = time;
	}
	
    function updateLocation(x:Float, y:Float, time:Int):Bool
	{
		if(location != null)
		{
			if(location.x == x && location.y == y)
				return false;
			
			prevLocation.x = location.x;
			prevLocation.y = location.y;
			location.x = x;
			location.y = y;
			this.time = time;
		}
		else
		{
			setLocation(x, y, time);
		}
		
		return true;
	}
	
	
	public function clone()
	{
		var touch = new Touch(id);
		touch.location = location.clone();
		touch.beginLocation = beginLocation.clone();
		touch.target = target;
		touch.sizeX = sizeX;
		touch.sizeY = sizeY;
		touch.pressure = pressure;
		touch.time = time;
		touch.beginTime = beginTime;
		
		return touch;
	}
	
	public function toString():String
		return "Touch [id:" + id + ", location:" + location + ", ...]";
		
	inline function get_locationOffset():Point
		return location.subtract(beginLocation);
}
