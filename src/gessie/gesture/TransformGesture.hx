package gessie.gesture;
import gessie.geom.Point;
import gessie.core.GestureState;
import gessie.core.Touch;

/**
 * ...
 * @author josu igoa
 */
class TransformGesture<T:{}> extends Gesture<T>
{
	public var slop:Float = Gesture.DEFAULT_SLOP;
	var _touch1:Touch<T>;
	var _touch2:Touch<T>;
	var _transformVector:Point;
	
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var rotation:Float = 0;
	public var scale:Float = 1;

	public function new(target:T = null)
	{
		super(target);
	}
	
	override public function reset()
	{
		_touch1 = null;
		_touch2 = null;
		
		super.reset();
	}
	
	// --------------------------------------------------------------------------
	//
	// methods
	//
	// --------------------------------------------------------------------------
	override function onTouchBegin(touch:Touch<T>)
	{
		super.onTouchBegin(touch);
		
		if (touchesCount > 2)
		{
			failOrIgnoreTouch(touch);
			return;
		}
		
		if (touchesCount == 1)
			_touch1 = touch;
		else
		{
			_touch2 = touch;
			_transformVector = _touch2.location.subtract(_touch1.location);
		}
		
		updateLocation();
		
		if (state == GSBegan || state == GSChanged)
		{
			// notify that location (and amount of touches) has changed
			setState(GSChanged);
		}
	}
	
	override function onTouchMove(touch:Touch<T>)
	{
		super.onTouchMove(touch);
		
		var prevLocation = location.clone();
		updateLocation();
		
		if (state == GSPossible)
		{
			if (slop > 0 && touch.locationOffset.length < slop)
			{
				// Not recognized yet
				if (_touch2 != null)
				{
					// Recalculate _transformVector to avoid initial "jump" on recognize
			        _transformVector = _touch2.location.subtract(_touch1.location);
				}
				return;
			}
		}
		
		offsetX = location.x - prevLocation.x;
		offsetY = location.y - prevLocation.y;
		if (_touch2 != null)
		{
			var currTransformVector = _touch2.location.subtract(_touch1.location);
			rotation = Math.atan2(currTransformVector.y, currTransformVector.x) - Math.atan2(_transformVector.y, _transformVector.x);
			scale = currTransformVector.length / _transformVector.length;
		}
		
		setState(state == GSPossible ? GSBegan : GSChanged);
	}
	
	override function onTouchEnd(touch:Touch<T>)
	{
		super.onTouchEnd(touch);
		
		if (touchesCount == 0)
		{
			if (state == GSBegan || state == GSChanged)
				setState(GSEnded);
			else if (state == GSPossible)
				setState(GSFailed);
		}
		else// == 1
		{
			if (touch == _touch1)
				_touch1 = _touch2;
			
			_touch2 = null;
			
			if (state == GSBegan || state == GSChanged)
			{
				updateLocation();
				setState(GSChanged);
			}
		}
	}
	
	override function resetNotificationProperties()
	{
		super.resetNotificationProperties();
		
		offsetX = offsetY = 0;
		rotation = 0;
		scale = 1;
	}
}