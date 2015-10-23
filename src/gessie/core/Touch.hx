package gessie.core;

import gessie.geom.Point;

class Touch<T>
{
    public var id:Int;
    
    public var target:T;
		
	public var sizeX:Float;
	public var sizeY:Float;
	public var pressure:Float;
	
	public var time:Int
	public var beginTime:Int;
    
    var location(get, null):Point;
    var beginLocation(get, null):Point;
    var prevLocation(get, null):Point;
    
    public function new(id)
    {
        this.id = id;
    }
    
    
	function setLocation(x:Float, y:Float, time:Int):Void
	{
		location = new Point(x, y);
		beginLocation = location.clone();
		previousLocation = location.clone();
		
		this.time = beginTime = time;
	}
	
    function updateLocation(x:Float, y:Float, time:Int):Bool
	{
		if(location ! =  null)
		{
			if(location.x == x && location.y == y)
				return false;
			
			previousLocation.x = location.x;
			previousLocation.y = location.y;
			location.x = x;
			location.y = y;
			time = time;
		}
		else
		{
			setLocation(x, y, time);
		}
		
		return true;
	}
	
	
	public function clone():Touch
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
        
        
    
	function get_location():Point
		return location.clone();
        
	function get_beginLocation():Point
		return beginLocation.clone();
        
	function get_prevLocation():Point
		return prevLocation.clone();
}
