package gessie.core;

interface IGestureTargetAdapter<T:{}>
{
    var target(get, null):T;
	
	function contains(other:T):Bool;
}
