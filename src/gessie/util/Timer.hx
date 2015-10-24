package gessie.util;


class Timer
{
	public var delay:Float;
	
	var emitter:Emitter<TimerEventType> = new Emitter();
	
	#if openfl
	
	var timer:openfl.utils.Timer;
	
	#end
	
	public function new(delay:Float, repeatCount:Int = 0)
	{
		#if openfl
		
		timer = new openfl.utils.Timer(delay, repeatCount);
		timer.addEventListener(openfl.events.TimerEvent.TIMER_COMPLETE, function(_) emitter.emit(TComplete));
		
		#end
	}
	
	public inline function on<T>(event:TimerEventType, handler:T->Void)
	{
		emitter.on(event, handler);
	}
	
	public inline function off<T>(event:TimerEventType, handler:T->Void)
	{
		return emitter.off(event, handler);
	}
	
	public function reset()
	{
		#if openfl
		
		timer.reset();
		
		#end
	}
	
	public function start()
	{
		#if openfl
		
		timer.start();
		
		#end
	}
	
}

@:enum
abstract TimerEventType(Int) from Int to Int
{
	var TComplete = 1;
}
