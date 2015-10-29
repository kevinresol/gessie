package gessie.impl.luxe;
import gessie.core.ITouchHitTester;
import gessie.geom.Point;
import luxe.Scene;
import luxe.Vector;
import luxe.Visual;

/**
 * ...
 * @author Kevin
 */
class LuxeTouchHitTester implements ITouchHitTester<Visual>
{
	public static var scenes:Array<Scene> = [];
	

	public function new() 
	{
		
	}
	
	public function hitTest(point:Point, possibleTarget:Visual, ?ofClass:Class<Dynamic>, ?exclude:Array<Visual>):Visual
	{
		if(possibleTarget != null)
			return possibleTarget;
		
		var worldPos = Luxe.camera.screen_point_to_world(new Vector(point.x, point.y));
		
		var result = null;
		var depth = -1.;
		for (scene in scenes) for (en in scene.entities)
		{
			var v = Std.instance(en, Visual);
			if (v != null && v.depth >= depth 
				&& Luxe.utils.geometry.point_in_geometry(worldPos, v.geometry) 
				&& (ofClass == null || Std.is(v, ofClass))
				&& (exclude == null || exclude.indexOf(v) == -1)
			)
			{
				result = v;
				depth = v.depth;
			}
		}
		//trace("hitTest " + (result != null ? result.name : "null"));
		return result;
		
	}
	
}
