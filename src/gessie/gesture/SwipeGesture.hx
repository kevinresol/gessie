package gessie.gesture;
import gessie.core.Touch;
import gessie.geom.Point;
import gessie.util.Timer;

using gessie.util.Util;
/**
 * TODO: also tell the swipe direction when recongized
 * @author Kevin
 */
class SwipeGesture<T:{}> extends Gesture<T>
{
	private static inline var ANGLE:Float = 40.degreeToRadian();
	private static inline var MAX_DURATION:Int = 500;
	private static var MIN_OFFSET:Float = Util.SCREEN_DPI / 6;
	private static var MIN_VELOCITY:Float = 2 * MIN_OFFSET / MAX_DURATION;
	
	/**
	 * "Dirty" region around touch begin location which is not taken into account for
	 * recognition/failing algorithms.
	 * 
	 * @default Gesture.DEFAULT_SLOP
	 */
	public var slop:Float = Gesture.DEFAULT_SLOP;
	public var numTouchesRequired:Int = 1;
	public var direction:SwipeGestureDirection = ORTHOGONAL;
	
	/**
	 * The duration of period (in milliseconds) in which SwipeGesture must be recognized.
	 * If gesture is not recognized during this period it fails. Default value is 500 (half a
	 * second) and generally should not be changed. You can change it though for some special
	 * cases, most likely together with <code>minVelocity</code> and <code>minOffset</code>
	 * to achieve really custom behavior. 
	 * 
	 * @default 500
	 * 
	 * @see #minVelocity
	 * @see #minOffset
	 */
	public var maxDuration = MAX_DURATION;
	
	/**
	 * Minimum offset (in pixels) for gesture to be recognized.
	 * Default value is <code>Capabilities.screenDPI / 6</code> and generally should not
	 * be changed.
	 */
	public var minOffset:Point = new Point(MIN_OFFSET, MIN_OFFSET);
	
	/**
	 * Minimum velocity (in pixels per millisecond) for gesture to be recognized.
	 * Default value is <code>2 * minOffset / maxDuration</code> and generally should not
	 * be changed.
	 * 
	 * @see #minOffset
	 * @see #minDuration
	 */
	public var minVelocity:Point = new Point(MIN_VELOCITY, MIN_VELOCITY);
	
	var _offset:Point = new Point();
	var _startTime:Int;
	var _noDirection:Bool;
	var _avrgVel:Point = new Point();
	var _timer:Timer;
	
	
	public function new(target:T = null)
	{
		super(target);
	}
	
	public var offsetX(get, never):Float;
	private inline function get_offsetX():Float
	{
		return _offset.x;
	}
	
	
	public var offsetY(get, never):Float;
	private inline function get_offsetY():Float
	{
		return _offset.y;
	}
	
	
	
	
	// --------------------------------------------------------------------------
	//
	// Public methods
	//
	// --------------------------------------------------------------------------
	
	override public function reset()
	{
		_startTime = 0;
		_offset.x = 0;
		_offset.y = 0;
		_timer.reset();
		
		super.reset();
	}
	
	
	
	
	// --------------------------------------------------------------------------
	//
	// Protected methods
	//
	// --------------------------------------------------------------------------
	
	override function preinit()
	{
		super.preinit();
		
		_timer = new Timer(maxDuration, 1);
		_timer.on(TComplete, timer_timerCompleteHandler);
	}
	
	
	override function onTouchBegin(touch:Touch<T>)
	{
		if (touchesCount > numTouchesRequired)
		{
			failOrIgnoreTouch(touch);
			return;
		}
		
		if (touchesCount == 1)
		{
			// Because we want to fail as quick as possible
			_startTime = touch.time;
			
			_timer.reset();
			_timer.delay = maxDuration;
			_timer.start();
		}
		if (touchesCount == numTouchesRequired)
		{
			updateLocation();
			_avrgVel.x = _avrgVel.y = 0;
			
			// cache direction condition for performance
			_noDirection = (SwipeGestureDirection.ORTHOGONAL & direction) == 0;
		}
	}
	
	
	override function onTouchMove(touch:Touch<T>)
	{
		if (touchesCount < numTouchesRequired)
			return;
		
		var totalTime = touch.time - _startTime;
		if (totalTime == 0)
			return;//It was somehow THAT MUCH performant on one Android tablet
		
		var prevCentralPointX = centralPoint.x;
		var prevCentralPointY = centralPoint.y;
		updateCentralPoint();
		
		_offset.x = centralPoint.x - location.x;
		_offset.y = centralPoint.y - location.y;
		var offsetLength = _offset.length;
		
		// average velocity (total offset to total duration)
		_avrgVel.x = _offset.x / totalTime;
		_avrgVel.y = _offset.y / totalTime;
		var avrgVel = _avrgVel.length;
		
		if (_noDirection)
		{
			if ((offsetLength > slop || slop != slop) &&
				((avrgVel >= minVelocity.x || avrgVel >= minVelocity.y) && 
				(offsetLength >= minOffset.x || offsetLength >= minOffset.y)))
			{
				setState(GSRecognized);
			}
		}
		else
		{
			var recentOffsetX = centralPoint.x - prevCentralPointX;
			var recentOffsetY = centralPoint.y - prevCentralPointY;
			//faster Math.abs()
			var absVelX = _avrgVel.x > 0 ? _avrgVel.x : -_avrgVel.x;
			var absVelY = _avrgVel.y > 0 ? _avrgVel.y : -_avrgVel.y;
			
			if (absVelX > absVelY)
			{
				var absOffsetX = _offset.x > 0 ? _offset.x : -_offset.x;
				
				if (absOffsetX > slop || slop != slop)//faster isNaN()
				{
					if ((recentOffsetX < 0 && (direction & SwipeGestureDirection.LEFT) == 0) ||
						(recentOffsetX > 0 && (direction & SwipeGestureDirection.RIGHT) == 0) ||
						Math.abs(Math.atan(_offset.y/_offset.x)) > ANGLE)
					{
						// movement in opposite direction
						// or too much diagonally
						
						setState(GSFailed);
					}
					else if (absVelX >= minVelocity.x || absOffsetX >= minOffset.x)
					{
						_offset.y = 0;
						setState(GSRecognized);
					}
				}
			}
			else if (absVelY > absVelX)
			{
				var absOffsetY = _offset.y > 0 ? _offset.y : -_offset.y;
				if (absOffsetY > slop || slop != slop)//faster isNaN()
				{
					if ((recentOffsetY < 0 && (direction & SwipeGestureDirection.UP) == 0) ||
						(recentOffsetY > 0 && (direction & SwipeGestureDirection.DOWN) == 0) ||
						Math.abs(Math.atan(_offset.x/_offset.y)) > ANGLE)
					{
						// movement in opposite direction
						// or too much diagonally
						
						setState(GSFailed);
					}
					else if (absVelY >= minVelocity.y || absOffsetY >= minOffset.y)
					{
						_offset.x = 0;
						setState(GSRecognized);
					}
				}
			}
			// Give some tolerance for accidental offset on finger press (slop)
			else if (offsetLength > slop || slop != slop)//faster isNaN()
			{
				setState(GSFailed);
			}
		}
	}
	
	
	override function onTouchEnd(touch:Touch<T>)
	{
		if (touchesCount < numTouchesRequired)
		{
			setState(GSFailed);
		}
	}
	
	
	override function resetNotificationProperties()
	{
		super.resetNotificationProperties();
		
		_offset.x = _offset.y = 0;
	}
	
	
	
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	function timer_timerCompleteHandler(_)
	{
		if (state == GSPossible)
		{
			setState(GSFailed);
		}
	}
}

@:enum
abstract SwipeGestureDirection(Int) from Int to Int
{
	var RIGHT = 1 << 0;
	var LEFT = 1 << 1;
	var UP = 1 << 2;
	var DOWN = 1 << 3;
	var NO_DIRECTION = 0;
	var HORIZONTAL = 1 << 0 | 1 << 1;
	var VERTICAL = 1 << 2 | 1 << 3;
	var ORTHOGONAL = 1 << 0 | 1 << 1 | 1 << 2 | 1 << 3;
}