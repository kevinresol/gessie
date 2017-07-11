package gessie.gesture;
import gessie.geom.Point;
import gessie.core.GestureState;
import gessie.core.Touch;

/**
 * ...
 * @author josu igoa
 */
class RotateGesture<T:{}> extends Gesture<T>
{
	public var slop:Float = Gesture.DEFAULT_SLOP;
	
	var _touch1:Touch<T>;
	var _touch2:Touch<T>;
	var _transformVector:Point;
	var _thresholdAngle:Float;
	/** rotation: in radians */
	public var rotation:Float = 0;

	public function new(target:T = null)
	{
		super(target);
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
			// @see chord length formula
			_thresholdAngle = Math.asin(slop / (2 * _transformVector.length)) * 2;
		}
	}
	
	
	override function onTouchMove(touch:Touch<T>)
	{
		super.onTouchMove(touch);
		
		if (touchesCount < 2)
			return;
		
		var currTransformVector:Point = _touch2.location.subtract(_touch1.location);
		var cross:Float = (_transformVector.x * currTransformVector.y) - (currTransformVector.x * _transformVector.y);
		var dot:Float = (_transformVector.x * currTransformVector.x) + (_transformVector.y * currTransformVector.y);
		var rot:Float = Math.atan2(cross, dot);
		
		if (state == GSPossible)
		{
			var absRotation:Float = rot >= 0 ? rot : -rot;
			if (absRotation < _thresholdAngle)
			{
				// not recognized yet
				return;
			}
			
			// adjust angle to avoid initial "jump"
			rotation = rot > 0 ? rot - _thresholdAngle : rot + _thresholdAngle;
		}
		
		//_transformVector.x = currTransformVector.x;
		//_transformVector.y = currTransformVector.y;
		rotation = rot;
		
		updateLocation();
		
		if (state == GSPossible)
			setState(GSBegan);
		else
			setState(GSChanged);
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
			{
				_touch1 = _touch2;
			}
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
		
		rotation = 0;
	}
}