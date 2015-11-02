package gessie.gesture;
import gessie.core.Touch;
import gessie.util.Timer;

/**
 * ...
 * @author Kevin
 */
class LongPressGesture<T:{}> extends Gesture<T>
{
	
	public var numTouchesRequired:Int = 1;
	/**
	 * The minimum time interval in millisecond fingers must press on the target for the gesture to be recognized.
	 * 
	 * @default 500
	 */
	public var minPressDuration:Int = 500;
	public var slop:Float = Gesture.DEFAULT_SLOP;
	
	var timer:Timer;
	var numTouchesRequiredReached:Bool;
	
	
	public function new(target:T = null)
	{
		super(target);
	}
	
	
	
	
	// --------------------------------------------------------------------------
	//
	// Public methods
	//
	// --------------------------------------------------------------------------
	
	
	
	override public function reset():Void
	{
		super.reset();
		
		numTouchesRequiredReached = false;
		timer.reset();
	}
	
	
	
	
	// --------------------------------------------------------------------------
	//
	// Protected methods
	//
	// --------------------------------------------------------------------------
	
	override function preinit():Void
	{
		super.preinit();
		timer = new Timer(minPressDuration, 1);
		timer.on(TComplete, timer_timerCompleteHandler);
	}
	
	
	override function onTouchBegin(touch:Touch<T>):Void
	{
		if (touchesCount > numTouchesRequired)
		{
			failOrIgnoreTouch(touch);
			return;
		}
		
		if (touchesCount == numTouchesRequired)
		{
			numTouchesRequiredReached = true;
			timer.reset();
			timer.delay = minPressDuration == 0 ? 1 : minPressDuration;
			timer.start();
		}
	}
	
	
	override function onTouchMove(touch:Touch<T>):Void
	{
		if (state == GSPossible && slop > 0 && touch.locationOffset.length > slop)
		{
			setState(GSFailed);
		}
		else if (state == GSBegan || state == GSChanged)
		{
			updateLocation();
			setState(GSChanged);
		}
	}
	
	
	override function onTouchEnd(touch:Touch<T>):Void
	{
		if (numTouchesRequiredReached)
		{
			if (state == GSBegan || state == GSChanged)
			{
				updateLocation();
				setState(GSEnded);
			}
			else
			{
				setState(GSFailed);
			}
		}
		else
		{
			setState(GSFailed);
		}
	}
	
	
	
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	function timer_timerCompleteHandler(_):Void
	{
		if (state == GSPossible)
		{
			updateLocation();
			setState(GSBegan);
		}
	}
}