package gessie.geom;

#if openfl

typedef Point = openfl.geom.Point;

#else

class Point
{
    public var x:Float;
    public var y:Float;
	public var length(get, never):Float;
	
	public static function distance(p1:Point, p2:Point):Float
	{
		var dx = p1.x - p2.x;
		var dy = p1.y - p2.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
    
    public function new(x = .0, y = .0)
    {
        this.x = x;
        this.y = y;
    }
	
	public function subtract(other:Point)
		return new Point(x - other.x, y - other.y);
    
    public inline function clone()
        return new Point(x, y);
    
    public function toString():String
        return '($x, $y)';
		
	inline function get_length():Float
		return Math.sqrt(x * x + y * y);
}

#end