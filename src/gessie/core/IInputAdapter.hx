package gessie.core;

interface IInputAdapter
{
	var touchesManager(get, set):TouchesManager;
	
	function init():void;
}
