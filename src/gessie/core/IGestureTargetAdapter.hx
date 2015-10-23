package gessie.core;

interface IGestureTargetAdapter<T>
{
    public var target(get, set):T;
	
	function contains(other:T):Bool;
}
