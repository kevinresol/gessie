package gessie.plugin.dragdrop;
import gessie.geom.Point;

/**
 * ...
 * @author Kevin
 */
typedef DragDropEvent = 
{
	data:DragData,
	?isDropped:Bool,
	?location:Point,
}

@:enum
abstract DragDropEventType(Int) from Int to Int
{
	var DStart = 1;
	var DComplete = 2;
	var DDrop = 3;
	var DEnter = 4;
	var DExit = 5;
	var DMove = 6;
}