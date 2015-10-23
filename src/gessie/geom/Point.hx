package gessie.geom;

class Point
{
    public var x:Float;
    public var y:Float;
    
    public function new(x = .0, y = .0)
    {
        this.x = x;
        this.y = y;
    }
    
    public inline function clone()
        return new Point(x, y);
    
    public function toString():String
        return '($x, $y)';
}
