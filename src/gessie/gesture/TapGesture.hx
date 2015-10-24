package gessie.gesture;
import gessie.core.Touch;
import gessie.geom.Point;
import gessie.util.Timer;

/**
 * ...
 * @author Kevin
 */
class TapGesture<T:{}> extends Gesture<T>
{
	public var numTouchesRequired:Int = 1;
	public var numTapsRequired:Int = 1;
	public var slop:Float = Gesture.DEFAULT_SLOP << 2;//iOS has 45px for 132 dpi screen
	public var maxTapDelay:Int = 400;
	public var maxTapDuration:Int = 1500;
	public var maxTapDistance:Float = Gesture.DEFAULT_SLOP << 2;
	
	var timer:Timer;
	var numTouchesRequiredReached:Bool;
	var tapCounter:Int = 0;
	var touchBeginLocations:Array<Point> = [];

	public function new(target:T = null) 
	{
		super(target);
	}
	
	override public function reset()
	{
		numTouchesRequiredReached = false;
		tapCounter = 0;
		timer.reset();
		touchBeginLocations = [];
		super.reset();
	}
	
	override function canPreventGesture(preventedGesture:Gesture<T>):Bool
	{
		var otherTapGesture = Std.instance(preventedGesture, TapGesture);
		
		return otherTapGesture == null || otherTapGesture.numTapsRequired <= numTapsRequired;
	}
	
	override function preinit()
	{
		super.preinit();
		timer = new Timer(maxTapDelay, 1);
		timer.on(TComplete, timer_timerCompleteHandler);
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
			timer.reset();
			timer.delay = maxTapDuration;
			timer.start();
		}
		
		if (numTapsRequired > 1)
		{
			if (tapCounter == 0)
			{
				touchBeginLocations.push(touch.location);
			}
			else
			{
				var found = false;
				for (loc in touchBeginLocations)
				{
					if (Point.distance(touch.location, loc) <= maxTapDistance)
					{
						found = true;
						break;
					}
				}
				
				if (!found)
				{
					setState(GSFailed);
					return;
				}
			}
		}
		
		if (touchesCount == numTouchesRequired)
		{
			numTouchesRequiredReached = true;
			updateLocation();
		}
	}
	
	override function onTouchMove(touch:Touch<T>)
	{
		if (slop >= 0 && touch.locationOffset.length > slop)
		{
			setState(GSFailed);
		}
	}
	
	override function onTouchEnd(touch:Touch<T>)
	{
		if (!numTouchesRequiredReached)
		{
			setState(GSFailed);
		}
		else if (touchesCount == 0)
		{
			// reset flag for the next "full press" cycle
			numTouchesRequiredReached = false;
			
			tapCounter++;
			timer.reset();
			
			if (tapCounter == numTapsRequired)
			{
				setState(GSRecognized);
			}
			else
			{
				timer.delay = maxTapDelay;
				timer.start();
			}
		}
	}
	
	function timer_timerCompleteHandler(_)
	{
		if (state == GSPossible)
		{
			setState(GSFailed);
		}
	}
}