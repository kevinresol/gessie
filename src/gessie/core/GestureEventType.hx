package gessie.core;

class GestureEvent
{
	public var newState:GestureState;
	public var oldState:GestureState;
	
	public function new(type:GestureEventType, newState:GestureState, oldState:GestureState)
	{
		this.newState = newState;
		this.oldState = oldState;
	}
	
	override public function clone():GestureEvent
	{
		return new GestureEvent(type, newState, oldState);
	}
	
	public function toString():String
	{
		return 'TODO'; //formatToString("GestureEvent", "type", "oldState", "newState");
	}
}

abstract GestureEventType(Int) to Int
{
    var GEPossible = 1;
    var GERecognized = 2;
    var GEBegan = 3;
    var GEChanged = 4;
    var GEEnded = 5;
    var GECancelled = 6;
    var GEFailed = 7;
    var GEStateChange = 8;
}
