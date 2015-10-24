package gessie.core;

import gessie.core.ITouchHandler.ITouchHitTester;
import gessie.geom.Point;
import gessie.util.Macros.*;
import gessie.util.Util.*;

@:allow(gessie)
class TouchManager<T:{}>
{
	var gestureManager:GestureManager<T>;
	var touches:Map<Int, Touch<T>> = new Map();
	var hitTesters:Array<ITouchHitTester<T>> = [];
	var hitTesterPrioritiesMap:Map<ITouchHitTester<T>, Int> = new Map();
	
	var activeTouchesCount(default, null):Int;
	
	
    public function new(gestureManager:GestureManager<T>)
	{
		this.gestureManager = gestureManager;
	}
	
	public function getTouches(target:T):Array<Touch<T>>
	{
		if (target == null /* TODO || target is Stage*/)
			return [for (t in touches) t];
		else
			return null;
	}
	
	function addTouchHitTester(touchHitTester:gessie.core.ITouchHitTester<T>, priority:Int = 0)
	{
		assertNull(touchHitTester);
		
		if (hitTesters.indexOf(touchHitTester) == -1)
			hitTesters.push(touchHitTester);
			
		hitTesterPrioritiesMap[touchHitTester] = priority;
		hitTesters.sort(hitTestersSorter);
	}
	
	function removeInputAdapter(touchHitTester:ITouchHitTester<T>)
	{
		assertNull(touchHitTester);
		
		var index = hitTesters.indexOf(touchHitTester);
		if (index == -1)
			throw "This touchHitTester is not registered.";
		
		hitTesters.splice(index, 1);
		hitTesterPrioritiesMap.remove(touchHitTester);
	}
	
	function onTouchBegin(touchID:Int, x:Float, y:Float, possibleTarget:T = null):Bool
	{
		if (touches.exists(touchID))
			return false;// touch with specified ID is already registered and being tracked
		
		var location = new Point(x, y);
		
		for (registeredTouch in touches)
		{
			// Check if touch at the same location exists.
			// In case we listen to both TouchEvents and MouseEvents, one of them will come first
			// (right now looks like MouseEvent dispatched first, but who know what Adobe will
			// do tomorrow). This check helps to filter out the one comes after.
			
			// NB! According to the tests with some IR multitouch frame and Windows computer
			// TouchEvent comes first, but the following MouseEvent has slightly offset location
			// (1px both axis). That is why Point#distance() used instead of Point#equals()
			
			if (Point.distance(registeredTouch.location, location) < 2)
				return false;
		}
		
		var touch = createTouch();
		touch.id = touchID;
		
		var target = null;
		var altTarget = null;
		for(hitTester in hitTesters)
		{
			target = hitTester.hitTest(location, possibleTarget);
			if (target != null)
			{
				if (false /* TODO target is Stage*/)
				{
					// NB! Target is flash.display::Stage is a special case. If it is true, we want
					// to give a try to a lower-priority (Stage3D) hit-testers. 
					altTarget = target;
					continue;
				}
				else
				{
					// We found a target.
					break;
				}
			}
		}
		if (target == null && altTarget == null)
		{
			throw "Not touch target found (hit test). Something is wrong, at least flash.display::Stage should be found. See Gestouch#addTouchHitTester() and Gestouch#inputAdapter.";
		}
		
		touch.target = target != null ? target : altTarget;
		touch.setLocation(x, y, getTimer());
		
		touches[touchID] = touch;
		activeTouchesCount++;
		
		gestureManager.onTouchBegin(touch);
		
		return true;
	}
	
	function onTouchMove(touchID:Int, x:Float, y:Float):Void
	{
		var touch = touches[touchID];
		if (touch == null)
			return;// touch with specified ID isn't registered
		
		if (touch.updateLocation(x, y, getTimer()))
		{
			// NB! It appeared that native TOUCH_MOVE event is dispatched also when
			// the location is the same, but size has changed. We are only interested
			// in location at the moment, so we shall ignore irrelevant calls.
			
			gestureManager.onTouchMove(touch);
		}
	}
	
	
	function onTouchEnd(touchID:Int, x:Float, y:Float):Void
	{
		var touch = touches[touchID];
		if (touch == null)
			return;// touch with specified ID isn't registered
		
		touch.updateLocation(x, y, getTimer());
		
		touches.remove(touchID);
		activeTouchesCount--;
		
		gestureManager.onTouchEnd(touch);
		
		touch.target = null;
	}
	
	
	function onTouchCancel(touchID:Int, x:Float, y:Float):Void
	{
		var touch = touches[touchID];
		if (touch == null)
			return;// touch with specified ID isn't registered
		
		touch.updateLocation(x, y, getTimer());
		
		touches.remove(touchID);
		activeTouchesCount--;
		
		gestureManager.onTouchCancel(touch);
		
		touch.target = null;
	}
	
	
	inline function createTouch():Touch<T>
	{
		//TODO: pool
		return new Touch();
	}
	
	
	/**
	 * Sorts from higher priority to lower. Items with the same priority keep the order
	 * of addition, e.g.:
	 * add(a), add(b), add(c, -1), add(d, 1) will be ordered to
	 * d, a, b, c
	 */
	function hitTestersSorter(x:ITouchHitTester<T>, y:ITouchHitTester<T>):Int
	{
		var d = hitTesterPrioritiesMap[x] - hitTesterPrioritiesMap[y];
		if (d > 0)
			return -1;
		else if (d < 0)
			return 1;
		
		return hitTesters.indexOf(x) > hitTesters.indexOf(y) ? 1 : -1;
	}
	
}
