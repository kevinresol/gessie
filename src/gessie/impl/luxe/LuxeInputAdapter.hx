package gessie.impl.luxe;
import gessie.core.Gessie;
import gessie.core.IInputAdapter;
import gessie.core.TouchManager;
import luxe.Input.MouseEvent;
import luxe.Input.TouchEvent;
import luxe.Vector;
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
	
	var helperVector:Vector;

	public function new() 
	{
		helperVector = new Vector();
	}
	
	public function init():Void
	{
		Luxe.on(Luxe.Ev.update, function(_) Gessie.update());
		#if mobile
		Luxe.on(Luxe.Ev.touchdown, ontouchdown);
		Luxe.on(Luxe.Ev.touchup, ontouchup);
		Luxe.on(Luxe.Ev.touchmove, ontouchmove);
		#else
		Luxe.on(Luxe.Ev.mousedown, onmousedown);
		Luxe.on(Luxe.Ev.mouseup, onmouseup);
		Luxe.on(Luxe.Ev.mousemove, onmousemove);
		#end
	}
	
	function onmousedown(e:MouseEvent)
	{
		var target = null; // = getVisualUnderPoint();
		var depth = -1.;
		var pos = Luxe.camera.screen_point_to_world(e.pos);
		for(en in LuxeDisplayListAdapter.targets)
		{
			var v = Std.instance(en, Visual);
			if (v != null && v.visible && v.depth >= depth && Luxe.utils.geometry.point_in_geometry(pos, v.geometry))
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
		var pos = Luxe.camera.screen_point_to_world(translateTouchPos(e.pos,helperVector));
		for(en in LuxeDisplayListAdapter.targets)
		{
			var v = Std.instance(en, Visual);
			if (v != null && v.visible && v.depth >= depth && Luxe.utils.geometry.point_in_geometry(pos, v.geometry))
			{
				target = v;
				depth = v.depth;
			}
		}
		
		if (target != null)
			touchManager.onTouchBegin(e.touch_id, helperVector.x, helperVector.y, target);
	}
	
	function ontouchup(e:TouchEvent)
	{
		var pos = translateTouchPos(e.pos, helperVector);
		touchManager.onTouchEnd(e.touch_id, pos.x, pos.y);
	}
	
	function ontouchmove(e:TouchEvent)
	{
		var pos = translateTouchPos(e.pos, helperVector);
		touchManager.onTouchMove(e.touch_id, pos.x, pos.y);
	}
	
	function translateTouchPos(inPos:Vector, ?outPos:Vector):Vector
	{
		if (outPos == null) outPos = new Vector();
		outPos.x = inPos.x * Luxe.screen.width;
		outPos.y = inPos.y * Luxe.screen.height;
		return outPos;
	}

	
	inline function get_touchManager()
		return touchManager;
		
		
	inline function set_touchManager(v)
		return touchManager = v;
}
