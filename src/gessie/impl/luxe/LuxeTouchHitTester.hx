package gessie.impl.luxe;
import gessie.core.ITouchHandler.ITouchHitTester;
import gessie.geom.Point;
import luxe.Vector;
import luxe.Visual;

/**
 * ...
 * @author Kevin
 */
class LuxeTouchHitTester implements ITouchHitTester<Visual>
{
	var helperVector:Vector;

	public function new() 
	{
		helperVector = new Vector();
	}
	
	/* INTERFACE gessie.core.ITouchHandler.ITouchHitTester<T> */
	
	public function hitTest(point:Point, possibleTarget:Visual):Visual
	{
		if (possibleTarget != null) return possibleTarget;
		
		helperVector.set_xy(point.x, point.y);
		
		return null;
		//return Luxe.utils.geometry.point_in_geometry(helperVector, possibleTarget.geometry);
	}
	
}