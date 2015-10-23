package gessie.core;

interface IDisplayListAdapter<T> extends IGestureTargetAdapter<T>
{
	function getHierarchy(target:T):Array<T>;
}
