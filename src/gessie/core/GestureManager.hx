package gessie.core;
import gessie.gesture.Gesture;
import gessie.util.Macros.*;
import haxe.ds.ObjectMap;

@:allow(gessie)
class GestureManager<T:{}>
{
	var gesturesMap:Map<Gesture<T>, Bool> = new Map();
	var gesturesForTouchMap:Map<Touch<T>, Array<Gesture<T>>> = new Map();
	var gesturesForTargetMap:ObjectMap<T, Array<Gesture<T>>> = new ObjectMap();
	var dirtyGesturesCount:Int = 0;
	var dirtyGesturesMap:Map<Gesture<T>, Bool> = new Map();
	var root:Root;
	
    public function new()
	{
		
	}
	
	function onRootAvailable(root:Root)
	{
		this.root = root;
		
		/*Gestouch.inputAdapter ||= new NativeInputAdapter(stage);
		Gestouch.addTouchHitTester(new NativeTouchHitTester(stage));*/
	}
	
	function resetDirtyGestures()
	{
		for (gesture in dirtyGesturesMap.keys())
		{
			gesture.reset();
		}
		dirtyGesturesCount = 0;
		for (key in dirtyGesturesMap.keys()) dirtyGesturesMap.remove(key);
		Gessie.emitter.off(GEnterFrame, enterFrameHandler);
	}
	
	function addGesture(gesture:Gesture<T>)
	{
		assertNull(gesture);
		
		var target = gesture.target;
		
		if (target == null)
			throw "Gesture must have target.";
		
		var targetGestures = gesturesForTargetMap.get(target);
		if (targetGestures != null)
		{
			if (targetGestures.indexOf(gesture) == -1)
				targetGestures.push(gesture);
		}
		else
		{
			targetGestures = [gesture];
			gesturesForTargetMap.set(target, targetGestures);
		}
		
		gesturesMap[gesture] = true;
	}
	
	function removeGesture(gesture:Gesture<T>)
	{
		assertNull(gesture);
		
		var target = gesture.target;
		// check for target because it could be already GC-ed (since target reference is weak)
		if (target != null)
		{
			var targetGestures = gesturesForTargetMap.get(target);
			if (targetGestures.length > 1)
			{
				targetGestures.splice(targetGestures.indexOf(gesture), 1);
			}
			else
			{
				gesturesForTargetMap.remove(target);
			}
		}
		
		gesturesMap.remove(gesture);
		
		gesture.reset();
	}
	
	function scheduleGestureStateReset(gesture:Gesture<T>)
	{
		if (dirtyGesturesMap[gesture] != true)
		{
			dirtyGesturesMap[gesture] = true;
			dirtyGesturesCount++;
			Gessie.emitter.on(GEnterFrame, enterFrameHandler);
		}
	}
	
	function onGestureRecognized(gesture:Gesture<T>)
	{
		var target = gesture.target;
		
		for (otherGesture in gesturesMap.keys())
		{
			var otherTarget = otherGesture.target;
			
			// conditions for otherGesture "own properties"
			if (otherGesture != gesture &&
				target != null && otherTarget != null &&//in case GC worked half way through
				otherGesture.enabled &&
				otherGesture.state == GSPossible)
			{
				if (otherTarget == target ||
					gesture.targetAdapter.contains(otherTarget) ||
					otherGesture.targetAdapter.contains(target)
					)
				{
					// conditions for gestures relations
					if (gesture.canPreventGesture(otherGesture) &&
						otherGesture.canBePreventedByGesture(gesture) &&
						(gesture.gesturesShouldRecognizeSimultaneouslyCallback == null ||
						 !gesture.gesturesShouldRecognizeSimultaneouslyCallback(gesture, otherGesture)) &&
						(otherGesture.gesturesShouldRecognizeSimultaneouslyCallback == null ||
						 !otherGesture.gesturesShouldRecognizeSimultaneouslyCallback(otherGesture, gesture)))
					{
						otherGesture.setState_internal(GSFailed);
					}
				}
			}
		}
	}
	
	function onTouchBegin(touch:Touch<T>)
	{
		var gesture;
		
		// This vector will contain active gestures for specific touch during all touch session.
		var gesturesForTouch = gesturesForTouchMap[touch];
		if (gesturesForTouch == null)
		{
			gesturesForTouch = [];
			gesturesForTouchMap[touch] = gesturesForTouch;
		}
		else
		{
			// touch object may be pooled in the future
			gesturesForTouch = [];
		}
		
		var target = touch.target;
		var displayListAdapter = Gessie.getDisplayListAdapter(target);
		if (displayListAdapter == null)
		{
			throw "Display list adapter not found for target of type '" + Type.getClassName(Type.getClass(target)) + "'.";
		}
		var hierarchy = displayListAdapter.getHierarchy(target);
		var hierarchyLength = hierarchy.length;
		if (hierarchyLength == 0)
		{
			throw "No hierarchy build for target '" + target +"'. Something is wrong with that IDisplayListAdapter.";
		}
		if (Gessie.root != null && (hierarchy[hierarchyLength - 1] != Gessie.root))
		{
			// Looks like some non-native (non DisplayList) hierarchy
			// but we must always handle gestures with Stage target
			// since Stage is anyway the top-most parent
			hierarchy[hierarchyLength] = Gessie.root;
		}
		
		// Create a sorted(!) list of gestures which are interested in this touch.
		// Sorting priority: deeper target has higher priority, recently added gesture has higher priority.
		var gesturesForTarget;
		for (target in hierarchy)
		{
			gesturesForTarget = gesturesForTargetMap.get(target);
			if (gesturesForTarget != null)
			{
				var i = gesturesForTarget.length;
				while (i-- > 0)
				{
					gesture = gesturesForTarget[i];
					if (gesture.enabled &&
						(gesture.gestureShouldReceiveTouchCallback == null ||
						 gesture.gestureShouldReceiveTouchCallback(gesture, touch)))
					{
						//TODO: optimize performance! decide between unshift() vs [i++] = gesture + reverse()
						gesturesForTouch.unshift(gesture);
					}
				}
			}
		}
		
		// Then we populate them with this touch and event.
		// They might start tracking this touch or ignore it (via Gesture#ignoreTouch())
		var i = gesturesForTouch.length;
		while (i-- > 0)
		{
			gesture = gesturesForTouch[i];
			
			// Check for state because previous (i+1) gesture may already abort current (i) one
			if (dirtyGesturesMap[gesture] != true)
			{
				gesture.touchBeginHandler(touch);
			}
			else
			{
				gesturesForTouch.splice(i, 1);
			}
		}
	}
	
	function onTouchMove(touch:Touch<T>)
	{
		var gesturesForTouch = gesturesForTouchMap[touch];
		var gesture;
		var i = gesturesForTouch.length;
		while (i-- > 0)
		{
			gesture = gesturesForTouch[i];
			
			if (dirtyGesturesMap[gesture] != true && gesture.isTrackingTouch(touch.id))
			{
				gesture.touchMoveHandler(touch);
			}
			else
			{
				// gesture is no more interested in this touch (e.g. ignoreTouch was called)
				gesturesForTouch.splice(i, 1);
			}
		}
	}
	
	function onTouchEnd(touch:Touch<T>)
	{
		var gesturesForTouch = gesturesForTouchMap[touch];
		var gesture;
		var i = gesturesForTouch.length;
		while (i-- > 0)
		{
			gesture = gesturesForTouch[i];
			
			if (dirtyGesturesMap[gesture] != true && gesture.isTrackingTouch(touch.id))
			{
				gesture.touchEndHandler(touch);
			}
		}
		
		gesturesForTouch = [];// release for GC
		
		gesturesForTouchMap.remove(touch);//TODO: remove this once Touch objects are pooled
	}
	
	function onTouchCancel(touch:Touch<T>)
	{
		var gesturesForTouch = gesturesForTouchMap[touch];
		var gesture;
		var i = gesturesForTouch.length;
		while (i-- > 0)
		{
			gesture = gesturesForTouch[i];
			
			if (dirtyGesturesMap[gesture] != true && gesture.isTrackingTouch(touch.id))
			{
				gesture.touchCancelHandler(touch);
			}
		}
		
		gesturesForTouch = [];// release for GC
		
		gesturesForTouchMap.remove(touch);//TODO: remove this once Touch objects are pooled
	}
	
	function enterFrameHandler(_)
	{
		resetDirtyGestures();
	}
}
