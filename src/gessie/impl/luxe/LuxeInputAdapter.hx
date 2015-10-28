package gessie.impl.luxe;
import gessie.core.Gessie;
import gessie.core.IInputAdapter;
import gessie.core.TouchManager;
import luxe.Input.MouseEvent;
import luxe.Input.TouchEvent;
import luxe.Visual;

using luxe.utils.GeometryUtils;
/**
 * ...
 * @author Kevin
 */
class LuxeInputAdapter implements IInputAdapter<Visual>
{
	static inline var MOUSE_TOUCH_POINT_ID:Int = 0;
	var mousePressed = false;
	
	
	@:isVar
	public var touchManager(get, set):TouchManager<Visual>;

	public function new() 
	{
		
	}
	
	public function init():Void
	{
		Luxe.on(Luxe.Ev.update, function(_) Gessie.update());
		Luxe.on(Luxe.Ev.touchdown, ontouchdown);
		Luxe.on(Luxe.Ev.touchup, ontouchup);
		Luxe.on(Luxe.Ev.touchmove, ontouchmove);
		Luxe.on(Luxe.Ev.mousedown, onmousedown);
		Luxe.on(Luxe.Ev.mouseup, onmouseup);
		Luxe.on(Luxe.Ev.mousemove, onmousemove);
	}
	
	function onmousedown(e:MouseEvent)
	{
		var target = null; // = getVisualUnderPoint();
		var depth = -1.;
		var pos = Luxe.camera.screen_point_to_world(e.pos);
		for(en in LuxeDisplayListAdapter.targets)
		{
			var v = Std.instance(en, Visual);
			if (v != null && v.depth >= depth && Luxe.utils.geometry.point_in_geometry(pos, v.geometry) )
			{
				target = v;
				depth = v.depth;
			}
		}
		
		if (target != null)
			touchManager.onTouchBegin(MOUSE_TOUCH_POINT_ID, e.x, e.y, target);
		
		mousePressed = true;
	}
	
	function onmouseup(e:MouseEvent)
	{
		if (mousePressed)
			touchManager.onTouchEnd(MOUSE_TOUCH_POINT_ID, e.x, e.y);
		
		mousePressed = false;
	}
	
	function onmousemove(e:MouseEvent)
	{
		if (mousePressed)
			touchManager.onTouchMove(MOUSE_TOUCH_POINT_ID, e.x, e.y);
	}
	
	function ontouchdown(e:TouchEvent)
	{
		var target = null; // = getVisualUnderPoint();
		var depth = -1.;
		
		for (e in Luxe.scene.entities)
		{
			var v = Std.instance(e, Visual);
			if (v != null && v.depth > depth && Luxe.utils.geometry.point_in_geometry(e.pos, v.geometry) )
			{
				target = v;
				depth = v.depth;
			}
		}
		
		if(target != null)
			touchManager.onTouchBegin(e.touch_id, e.x, e.y, target);
	}
	
	function ontouchup(e:TouchEvent)
	{
		touchManager.onTouchEnd(e.touch_id, e.x, e.y);
	}
	
	function ontouchmove(e:TouchEvent)
	{
		touchManager.onTouchMove(e.touch_id, e.x, e.y);
	}

	
	inline function get_touchManager()
		return touchManager;
		
		
	inline function set_touchManager(v)
		return touchManager = v;
}
