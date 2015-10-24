package gessie.core;

interface IInputAdapter<T:{}>
{
	var touchManager(get, set):TouchManager<T>;
	
	function init():Void;
}
