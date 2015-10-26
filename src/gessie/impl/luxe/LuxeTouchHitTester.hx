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
	
	public function hitTest(point:Point, possibleTarget:Visual):Visual
	{
		/* since the touch begin event is only triggered when there is a target
		 * (see LuxeInputAdapter#ontouchdown), we don't need to find target from a point here
		 */
		return possibleTarget;
	}
	
}