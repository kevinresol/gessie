package gessie.gesture;
import gessie.geom.Point;
import gessie.core.Touch;

/**
 * ...
 * @author josu igoa
 */
class ZoomGesture<T:{}> extends Gesture<T>
{
	public var slop:Float = Gesture.DEFAULT_SLOP;
	public var lockAspectRatio:Bool = true;
	
	var _touch1:Touch<T>;
	var _touch2:Touch<T>;
	var _transformVector:Point;
	var _initialDistance:Float;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;

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
		{
			_touch1 = touch;
		}
		else// == 2
		{
			_touch2 = touch;
			
			_transformVector = _touch2.location.subtract(_touch1.location);
			_initialDistance = _transformVector.length;
		}
	}
	
	override function onTouchMove(touch:Touch<T>)
	{
		super.onTouchMove(touch);
		
		if (touchesCount < 2)
			return;
		
		var currTransformVector:Point = _touch2.location.subtract(_touch1.location);
		
		if (state == GSPossible)
		{
			var d:Float = currTransformVector.length - _initialDistance;
			var absD:Float = d >= 0 ? d : -d;
			if (absD < slop)
			{
				// Not recognized yet
				return;
			}
			
			if (slop > 0)
			{
				// adjust _transformVector to avoid initial "jump"
				var slopVector:Point = currTransformVector.clone();
				slopVector.normalize(_initialDistance + (d >= 0 ? slop : -slop));
				_transformVector = slopVector;
			}
		}
		
		if (lockAspectRatio)
		{
			scaleX *= currTransformVector.length / _transformVector.length;
			scaleY = scaleX;
		}
		else
		{
			scaleX *= currTransformVector.x / _transformVector.x;
			scaleY *= currTransformVector.y / _transformVector.y;
		}
		
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
		else//== 1
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
		
		scaleX = scaleY = 1;
	}
}