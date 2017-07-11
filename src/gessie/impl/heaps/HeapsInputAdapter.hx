package gessie.impl.heaps;

import gessie.core.Gessie;
import gessie.core.IInputAdapter;
import gessie.core.TouchManager;

import h2d.Sprite;
import hxd.Event;
/**
 * ...
 * @author josu igoa
 */
class HeapsInputAdapter implements IInputAdapter<Sprite>
{
    var mousePressed = false;

	@:isVar
	public var touchManager(get, set):TouchManager<Sprite>;
	
    var s2d:h2d.Scene;
    var catchSceneInput:Bool;

	public function new(s2d:h2d.Scene, catchSceneInput:Bool = true) 
	{
        gessie.util.Macros.assertNull(s2d);
        this.s2d = s2d;
        this.catchSceneInput = catchSceneInput;
	}
	
	public function init():Void
	{
        // var t = new haxe.Timer(Std.int(1000/hxd.Timer.wantedFPS));
        // t.run = Gessie.update;
        @:privateAccess s2d.stage.addEventTarget(onEvent);
	}

    function onEvent(e:Event)
    {
        switch e.kind {
            case EventKind.EPush: onPush(e);
            case EventKind.EMove: onMove(e);
            case EventKind.ERelease: onRelease(e);
            case _:
        }
    }

    function onPush(e:Event)
    {
        var target:h2d.Sprite = (catchSceneInput) ? s2d : null;
        var pt = new h2d.col.Point(e.relX, e.relY);
        for(c in s2d.iterator())
            if (c != null && c.getBounds().contains(pt)) target = c;

        if (target != null)
			touchManager.onTouchBegin((e.touchId!=null)?e.touchId:e.button, e.relX, e.relY, target);
        
        mousePressed = e.touchId == null;
    }

    function onMove(e:Event)
    {
        if (mousePressed || e.touchId != null)
            touchManager.onTouchMove((e.touchId!=null)?e.touchId:e.button, e.relX, e.relY);
    }
	
	function onRelease(e:Event)
    {
        if (mousePressed || e.touchId != null)
            touchManager.onTouchEnd((e.touchId!=null)?e.touchId:e.button, e.relX, e.relY);
        
        mousePressed = false;
    }

    inline function get_touchManager()
		return touchManager;
		
	inline function set_touchManager(v)
		return touchManager = v;
}
