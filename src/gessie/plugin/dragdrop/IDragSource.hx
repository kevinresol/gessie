package gessie.plugin.dragdrop;

import gessie.plugin.dragdrop.*;

interface IDragSource
{
    function onDragStart(data:DragData):Void;
    function onDragComplete(data:DragData, isDropped:Bool):Void;
}
