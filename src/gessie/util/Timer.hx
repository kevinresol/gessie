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
	public var delay:Float;
	
	var repeatCount:Int;
	
	var emitter:Emitter<TimerEventType> = new Emitter();
	
	
	
	public static function update()
	{
		
	}
	
	public function new(delay:Float, repeatCount:Int = 0)
	{
		this.delay = delay;
		this.repeatCount = repeatCount;
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
		
	}
	
	public function start()
	{
		
	}
	
}

#end

@:enum
abstract TimerEventType(Int) from Int to Int
{
	var TComplete = 1;
}
