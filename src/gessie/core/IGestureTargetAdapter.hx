package gessie.core;

interface IGestureTargetAdapter<T:{}>
{
    var target(default, null):T;
	
	function contains(other:T):Bool;
    function dispose():Void;
}
