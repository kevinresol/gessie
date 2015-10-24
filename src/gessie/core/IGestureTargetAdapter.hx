package gessie.core;

interface IGestureTargetAdapter<T:{}>
{
    public var target:T;
	
	function contains(other:T):Bool;
}
