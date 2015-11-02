package gessie.gesture;
import gessie.core.Gessie;
import gessie.core.GestureEventType;
import gessie.core.GestureManager;
import gessie.core.GestureState;
import gessie.core.IGestureTargetAdapter;
import gessie.core.Touch;
import gessie.geom.Point;
import gessie.util.Emitter;
import gessie.util.Macros.*;
import gessie.util.Util;

/**
 * ...
 * @author Kevin
 */
@:allow(gessie)
class Gesture<T:{}>
{
	public static var DEFAULT_SLOP:Int = Math.round(20 / 252 * Util.SCREEN_DPI);
	
	public var target(get, set):T;
	public var state(default, null):GestureState = GSPossible;
	public var idle(default, null):Bool = true;
	public var enabled(default, set):Bool = true;
	public var targetAdapter:IGestureTargetAdapter<T>;
	public var touchesCount(default, null):Int = 0;
	public var location(default, null):Point = new Point();
	
	public var gestureShouldReceiveTouchCallback:Gesture<T>->Touch<T>->Bool;
	public var gestureShouldBeginCallback:Gesture<T>->Bool;
	public var gesturesShouldRecognizeSimultaneouslyCallback:Gesture<T>->Gesture<T>->Bool;
	
	var emitter:Emitter<GestureEventType> = new Emitter();
	var gestureManager:GestureManager<T> = cast Gessie.gestureManager;
	var touches:Map<Int, Touch<T>> = new Map();
	var centralPoint:Point = new Point();
	var gesturesToFail:Map<Gesture<T>, Bool> = new Map();
	var pendingRecognizedState:GestureState = GSNone;
	

	public function new(target:T = null) 
	{
		preinit();
		this.target = target;
		
		#if luxe
		gessie.impl.luxe.LuxeDisplayListAdapter.targets.push(cast target);
		#end
	}
	
	public inline function on<T>(event:GestureEventType, handler:T->Void)
	{
		emitter.on(event, handler);
	}
	
	public inline function off<T>(event:GestureEventType, handler:T->Void)
	{
		return emitter.off(event, handler);
	}
	
	public function isTrackingTouch(touchID:Int)
	{
		return touches[touchID] != null;
	}
	
	public function reset()
	{
		if (idle)
			return;// Do nothing as we are idle and there is nothing to reset
		
		location.x = 0;
		location.y = 0;
		for (key in touches.keys()) touches.remove(key);
		touchesCount = 0;
		idle = true;
		
		for (gestureToFail in gesturesToFail.keys())
		{
			gestureToFail.emitter.off(GEStateChange, gestureToFailstateChangeHandler);
		}
		pendingRecognizedState = GSNone;
		
		if (state == GSPossible)
		{
			// manual reset() call. Set to FAILED to keep our State Machine clean and stable
			setState(GSFailed);
		}
		else if (state == GSBegan || state == GSChanged)
		{
			// manual reset() call. Set to CANCELLED to keep our State Machine clean and stable
			setState(GSCancelled);
		}
		else
		{
			// reset from GesturesManager after reaching one of the 4 final states:
			// (state == GSRecognized ||
			// state == GestureState.ENDED ||
			// state == GSFailed ||
			// state == GSCancelled)
			setState(GSPossible);
		}
	}
	
	public function dispose()
	{
		#if luxe
		gessie.impl.luxe.LuxeDisplayListAdapter.targets.remove(cast target);
		#end
		
		//TODO
		reset();
		target = null;
		gestureShouldReceiveTouchCallback = null;
		gestureShouldBeginCallback = null;
		gesturesShouldRecognizeSimultaneouslyCallback = null;
		gesturesToFail = null;
	}
	
	public function requireGestureToFail(gesture:Gesture<T>)
	{
		assertNull(gesture);
		gesturesToFail[gesture] = true;
	}
	
	function preinit()
	{
		
	}
	
	function installTarget(target:T)
	{
		if (target != null)
			gestureManager.addGesture(this);
	}
	
	function uninstallTarget(target:T)
	{
		if (target != null)
			gestureManager.removeGesture(this);
	}
	
	function ignoreTouch(touch:Touch<T>)
	{
		if (touches.exists(touch.id))
		{
			touches.remove(touch.id);
			touchesCount--;
		}
	}
	
	function failOrIgnoreTouch(touch:Touch<T>)
	{
		if (state == GSPossible)
		{
			setState(GSFailed);
		}
		else
		{
			ignoreTouch(touch);
		}
	}
		
	function canBePreventedByGesture(preventingGesture:Gesture<T>):Bool
	{
		return true;
	}
	
	function canPreventGesture(preventedGesture:Gesture<T>):Bool
	{
		return true;
	}
	
	function setState_internal(state:GestureState)
	{
		setState(state);
	}
	
	function onTouchBegin(touch:Touch<T>)
	{
		
	}
	
	function onTouchMove(touch:Touch<T>)
	{
		
	}
	
	function onTouchEnd(touch:Touch<T>)
	{
		
	}
	
	function onTouchCancel(touch:Touch<T>)
	{
		
	}
	
	function setState(newState:GestureState):Bool
	{
		if (state == newState && state == GSChanged)
		{
			emitter.emit(GEStateChange, {newState:state, oldState:state});
			emitter.emit(GEChanged, {newState:state, oldState:state});
			resetNotificationProperties();
			
			return true;
		}
		
		if (!state.canTransitTo(newState))
		{
			throw 'You cannot change from state $state to state $newState.';
		}
		
		if (newState != GSPossible)
		{
			// in case instantly switch state in touchBeganHandler()
			idle = false;
		}
		
		
		if (newState == GSBegan || newState == GSRecognized)
		{
			// first we check if other required-to-fail gestures recognized
			// TODO: is this really necessary? using "requireGestureToFail" API assume that
			// required-to-fail gesture always recognizes AFTER this one.
			for (gestureToFail in gesturesToFail.keys())
			{
				if (!gestureToFail.idle &&
					gestureToFail.state != GSPossible &&
					gestureToFail.state != GSFailed)
				{
					// Looks like other gesture won't fail,
					// which means the required condition will not happen, so we must fail
					setState(GSFailed);
					return false;
				}
			}
			// then we check if other required-to-fail gestures are actually tracked (not IDLE)
			// and not still not recognized (e.g. POSSIBLE state)
			for (gestureToFail in gesturesToFail.keys())
			{
				if (gestureToFail.state == GSPossible)
				{
					// Other gesture might fail soon, so we postpone state change
					pendingRecognizedState = newState;
					
					for (other in gesturesToFail.keys())
					{
						other.emitter.on(GEStateChange, gestureToFailstateChangeHandler);
					}
					
					return false;
				}
				// else if gesture is in IDLE state it means it doesn't track anything,
				// so we simply ignore it as it doesn't seem like conflict from this perspective
				// (perspective of using "requireGestureToFail" API)
			}
			
			
			if (gestureShouldBeginCallback != null && !gestureShouldBeginCallback(this))
			{
				setState(GSFailed);
				return false;
			}
		}
			
		var oldState = state;	
		state = newState;
		
		if (state.isEndState)
		{
			gestureManager.scheduleGestureStateReset(this);
		}
		
		//TODO: what if RTE happens in event handlers?
		
		emitter.emit(GEStateChange, {newState:state, oldState:oldState});
		emitter.emit(state.toGestureEventType(), { newState:state, oldState:oldState } );
		
		resetNotificationProperties();
		
		if (state == GSBegan || state == GSRecognized)
		{
			gestureManager.onGestureRecognized(this);
		}
		
		return true;
	}
	
	
	function updateCentralPoint()
	{
		var x = .0;
		var y = .0;
		for (touch in touches)
		{
			var touchLocation = touch.location; 
			x += touchLocation.x;
			y += touchLocation.y;
		}
		centralPoint.x = x / touchesCount;
		centralPoint.y = y / touchesCount;
	}
		
	function updateLocation()
	{
		updateCentralPoint();
		location.x = centralPoint.x;
		location.y = centralPoint.y;
	}
		
	function resetNotificationProperties()
	{
		
	}
		
	function touchBeginHandler(touch:Touch<T>)
	{
		touches[touch.id] = touch;
		touchesCount++;
		
		onTouchBegin(touch);
		
		if (touchesCount == 1 && state == GSPossible)
		{
			idle = false;
		}
	}
		
		
	function touchMoveHandler(touch:Touch<T>)
	{
		touches[touch.id] = touch;
		onTouchMove(touch);
	}
		
		
	function touchEndHandler(touch:Touch<T>)
	{
		touches.remove(touch.id);
		touchesCount--;
		
		onTouchEnd(touch);
	}
		
		
	function touchCancelHandler(touch:Touch<T>)
	{
		touches.remove(touch.id);
		touchesCount--;
		
		onTouchCancel(touch);
		
		if (!state.isEndState)
		{
			if (state == GSBegan || state == GSChanged)
			{
				setState(GSCancelled);
			}
			else
			{
				setState(GSFailed);
			}
		}
	}
		
		
	function gestureToFailstateChangeHandler(data:GestureEventPayload)
	{
		if (pendingRecognizedState == GSNone || state != GSPossible)
			return;
		
		if (data.newState == GSFailed)
		{
			for (gestureToFail in gesturesToFail.keys())
			{
				if (gestureToFail.state == GSPossible)
				{
					// we're still waiting for some gesture to fail
					return;
				}
			}
			
			// at this point all gestures-to-fail are either in IDLE or in FAILED states
			setState(pendingRecognizedState);
		}
		else if (data.newState != GSPossible)
		{
			//TODO: need to re-think this over
			
			setState(GSFailed);
		}
	}
	
	
	
	
	
	
	inline function get_target():T
		return targetAdapter == null ? null : targetAdapter.target;
		
	function set_target(v:T):T
	{
		if (target != v)
		{
			uninstallTarget(target);
			if(targetAdapter != null) targetAdapter.dispose();
			targetAdapter = v != null ? Gessie.createGestureTargetAdapter(v) : null;
			installTarget(v);
		}
		return v;
	}
	
	inline function set_enabled(v:Bool):Bool
	{
		if (enabled != v)
		{
			enabled = v;
			if (!v)
			{
				if (state == GSPossible)
					setState(GSFailed);
				else if (state == GSBegan || state == GSChanged)
					setState_internal(GSCancelled);
			}
		}
		return v;
	}
	
}
