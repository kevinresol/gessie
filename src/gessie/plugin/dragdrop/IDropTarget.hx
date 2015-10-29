package gessie.plugin.dragdrop;

interface IDropTarget
{
    function onDragComplete(data:DragData):Void;
    function onDragEnter(data:DragData):Void;
    function onDragExit(data:DragData):Void;
    function onDragMove():Void;
}
