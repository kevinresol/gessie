package gessie.core;

@:enum
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


typedef GestureEventPayload = 
{
	newState:GestureState, 
	oldState:GestureState,
}