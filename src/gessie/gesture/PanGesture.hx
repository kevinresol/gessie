package gessie.gesture;
import gessie.core.Touch;

/**
 * ...
 * @author Kevin
 */
class PanGesture<T:{}> extends Gesture<T>
{
	public var slop:Float = Gesture.DEFAULT_SLOP;
	/**
	 * Used for initial slop overcome calculations only.
	 */
	public var direction:PanGestureDirection = ANY_DIRECTION;
	
	
	public function new(target:T = null)
	{
		super(target);
	}
	
	
	/** @private */
	public var maxNumTouchesRequired(default, set):Int = 9999;
	
	public function set_maxNumTouchesRequired(v:Int):Int
	{
		if (maxNumTouchesRequired == v)
			return v;
		
		if (v < minNumTouchesRequired)
			throw "maxNumTouchesRequired must be not less then minNumTouchesRequired";
		
		return maxNumTouchesRequired = v;
	}
	
	
	/** @private */
	public var minNumTouchesRequired(default, set):Int = 1;
	
	public function set_minNumTouchesRequired(v:Int):Int
	{
		if (minNumTouchesRequired == v)
			return v;
		
		if (v > maxNumTouchesRequired)
			throw "minNumTouchesRequired must be not greater then maxNumTouchesRequired";
		
		return minNumTouchesRequired = v;
	}
	
	
	public var _offsetX(default, null):Float = 0;
	public var _offsetY(default, null):Float = 0;
	
	
	
	
	// --------------------------------------------------------------------------
	//
	// Protected methods
	//
	// --------------------------------------------------------------------------
	
	override function onTouchBegin(touch:Touch<T>)
	{
		if (touchesCount > maxNumTouchesRequired)
		{
			failOrIgnoreTouch(touch);
			return;
		}
		
		if (touchesCount >= minNumTouchesRequired)
		{
			updateLocation();
		}
	}
	
	
	override function onTouchMove(touch:Touch<T>)
	{
		if (touchesCount < minNumTouchesRequired)
			return;
		
		var prevLocationX;
		var prevLocationY;
		
		if (state == GSPossible)
		{
			prevLocationX = location.x;
			prevLocationY = location.y;
			updateLocation();
			
			// Check if finger moved enough for gesture to be recognized
			var locationOffset = touch.locationOffset;
			
			if (direction == PanGestureDirection.VERTICAL)
			{
				locationOffset.x = 0;
			}
			else if (direction == PanGestureDirection.HORIZONTAL)
			{
				locationOffset.y = 0;
			}
			
			if (locationOffset.length > slop || Math.isNaN(slop))//slop != slop
			{
				// NB! += instead of = for the case when this gesture recognition is delayed via requireGestureToFail
				_offsetX += location.x - prevLocationX;
				_offsetY += location.y - prevLocationY;
				
				setState(GSBegan);
			}
		}
		else if (state == GSBegan || state == GSChanged)
		{
			prevLocationX = location.x;
			prevLocationY = location.y;
			updateLocation();
			_offsetX = location.x - prevLocationX;
			_offsetY = location.y - prevLocationY;
			
			setState(GSChanged);
		}
	}
	
	
	override function onTouchEnd(touch:Touch<T>)
	{
		if (touchesCount < minNumTouchesRequired)
		{
			if (state == GSPossible)
			{
				setState(GSFailed);
			}
			else
			{
				setState(GSEnded);
			}
		}
		else
		{
			updateLocation();
		}
	}
	
	
	override function resetNotificationProperties()
	{
		super.resetNotificationProperties();
		
		_offsetX = _offsetY = 0;
	}
	
}

@:enum
abstract PanGestureDirection(Int) from Int to Int
{
	var NO_DIRECTION = 0;
	var VERTICAL = 1 << 0;
	var HORIZONTAL = 1 << 1;
	var ANY_DIRECTION = 1 << 0 | 1 << 1;
}
