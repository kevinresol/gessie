package gessie.impl.heaps;

import gessie.core.ITouchHitTester;
import gessie.geom.Point;
import h2d.Scene;
import h2d.Object;

/**
 * @author josu igoa
 */
class HeapsTouchHitTester implements ITouchHitTester<Object>
{
	public var s2d:Scene;

	public function new(s2d:Scene) 
	{
        gessie.util.Macros.assertNull(s2d);
		
        this.s2d = s2d;
	}
	
	public function hitTest(point:Point, possibleTarget:Object, ?ofClass:Class<Dynamic>, ?exclude:Array<Object>):Object
	{
		if(possibleTarget != null)
			return possibleTarget;

        var ret = null;
        var pt = new h2d.col.Point(point.x, point.y);
        for (c in s2d.iterator()) {
            if (c.getBounds().contains(pt)) ret = c;
        }

        if (ret != null && 
            (ofClass == null || Std.is(ret, ofClass)) &&
			(exclude == null || exclude.indexOf(ret) == -1))
                return ret;
        
        return null;
	}
	
}
