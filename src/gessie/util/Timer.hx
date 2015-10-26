package gessie.util;

#if openfl

@:forward(reset, start, delay, on, off)
abstract Timer(TimerImpl)
{
	public inline function new(delay:Float, repeatCount:Int = 0) 
		this = new TimerImpl(delay, repeatCount);
}

private class TimerImpl extends openfl.utils.Timer
{
	public var emitter:Emitter<TimerEventType> = new Emitter();
	
	public function new(delay:Float, repeatCount:Int = 0)
	{
		super(delay, repeatCount);
		addEventListener(openfl.events.TimerEvent.TIMER_COMPLETE, function(_) emitter.emit(TComplete));
	}
	
	public inline function on<T>(event:TimerEventType, handler:T->Void)
	{
		emitter.on(event, handler);
	}
	
	public inline function off<T>(event:TimerEventType, handler:T->Void)
	{
		return emitter.off(event, handler);
	}
}

#else


class Timer
{
	var emitter:Emitter<TimerEventType> = new Emitter();
	
	public var currentCount (default, null):Int;
	public var delay (get, set):Float;
	public var repeatCount (default, set):Int;
	public var running (default, null):Bool;
	
	var __delay:Float;
	
	#if js
	var __timerID:Int;
	#else
	var __timer:haxe.Timer;
	#end
	
	
	
	
	public function new (delay:Float, repeatCount:Int = 0):Void {
		
		if (Math.isNaN (delay) || delay < 0) {
			
			throw "The delay specified is negative or not a finite number";
			
		}
		
		__delay = delay;
		this.repeatCount = repeatCount;
		
		running = false;
		currentCount = 0;
		
	}
	
	public function reset ():Void {
		
		if (running) {
			
			stop ();
			
		}
		
		currentCount = 0;
		
	}
	
	public function start ():Void {
		
		if (!running) {
			
			running = true;
			
			#if js
			__timerID = js.Browser.window.setInterval (timer_onTimer, Std.int (__delay));
			#else
			__timer = new haxe.Timer (__delay);
			__timer.run = timer_onTimer;
			#end
			
		}
		
	}
	
	public function stop ():Void {
		
		running = false;
		
		#if js
		if (__timerID != null) {
			
			js.Browser.window.clearInterval (__timerID);
			__timerID = null;
			
		}
		#else
		if (__timer != null) {
			
			__timer.stop ();
			__timer = null;
			
		}
		#end
		
	}
	
	private function get_delay ():Float {
		
		return __delay;
		
	}
	
	private function set_delay (value:Float):Float {
		
		__delay = value;
		
		if (running) {
			
			stop ();
			start ();
			
		}
		
		return __delay;
		
	}
	
	private function set_repeatCount (v:Int):Int {
		
		if (running && v != 0 && v <= currentCount) {
			
			stop ();
			
		}
		
		repeatCount = v;
		return v;
		
	}
	
	private function timer_onTimer ():Void {
		
		currentCount ++;
		
		if (repeatCount > 0 && currentCount >= repeatCount) {
			
			stop ();
			//dispatchEvent (new TimerEvent (TimerEvent.TIMER));
			emitter.emit(TComplete);
			//dispatchEvent (new TimerEvent (TimerEvent.TIMER_COMPLETE));
			
		} else {
			
			//dispatchEvent (new TimerEvent (TimerEvent.TIMER));
			
		}
		
	}
		
	public inline function on<T>(event:TimerEventType, handler:T->Void)
	{
		emitter.on(event, handler);
	}
	
	public inline function off<T>(event:TimerEventType, handler:T->Void)
	{
		return emitter.off(event, handler);
	}
	
}

#end

@:enum
abstract TimerEventType(Int) from Int to Int
{
	var TComplete = 1;
}
