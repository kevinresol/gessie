package gessie.plugin.dragdrop;

import gessie.geom.Point;

interface IDropTarget
{
    function onDragDrop(data:DragData):Void;
    function onDragEnter(data:DragData, x:Float, y:Float):Void;
    function onDragExit(data:DragData):Void;
    function onDragMove(data:DragData, x:Float, y:Float):Void;
}
