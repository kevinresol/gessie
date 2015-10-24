package gessie.core;

@:enum
abstract GestureState(Int) to Int
{
    public var isEndState(get, never):Bool;
    
	var GSNone = 0;
	
    var GSPossible = 1 ;
    var GSBegan = 2;
    var GSChanged = 3 ;
    
    var GSRecognized = 4;
    var GSEnded = 5;
    var GSCancelled = 6;
    var GSFailed = 7;
    
    @:to
    public function toGestureEventType():GestureEventType
    {
        return switch(this)
        {
            case GSPossible: GEPossible;
            case GSRecognized: GERecognized;
            case GSBegan: GEBegan;
            case GSChanged: GEChanged;
            case GSEnded: GEEnded;
            case GSCancelled: GECancelled;
            case GSFailed: GEFailed;
			default: GEFailed;
        }
    }
    
    @:to
    public function toString():String
    {
        return 'TODO';
    }
    
    public function canTransitTo(s:GestureState)
    {
        var a = switch(this)
        {
            case GSPossible: [GSRecognized, GSBegan, GSFailed];
            case GSRecognized: [GSPossible];
            case GSBegan: [GSChanged, GSEnded, GSCancelled];
            case GSChanged: [GSChanged, GSEnded, GSCancelled];
            case GSEnded: [GSPossible];
            case GSCancelled: [GSPossible];
            case GSFailed: [GSPossible];
            default: [];
        }
        return a.indexOf(s) != -1;
    }
    
    
    inline function get_isEndState():Bool 
        return this >= 4;
}
