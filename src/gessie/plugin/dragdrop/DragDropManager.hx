package gessie.plugin.dragdrop;

import gessie.core.*;
import gessie.geom.Point;
import gessie.util.Macros.*;
import gessie.plugin.dragdrop.*;

class DragDropManager
{
    static var helperPoint:Point;
    static var dragSource:IDragSource;
    static var dropTarget:IDropTarget;
    static var dragData:DragData;
    static var touchPointId:Int;
    static var isAccepted:Bool;
    static var isDragging(get, never):Bool;
    
    public static function startDrag(source:IDragSource, touch:Touch<Dynamic>, data:DragData)
    {
        if(isDragging) cancelDrag();
        
        assertNull(source);
        assertNull(dragData);
        
        dragSource = source;
        dragData = data;
        touchPointId = touch.id;
        source.onDragStart(data);
        
        // TODO handle touchmove and keydown
    }
    
    public static function acceptDrag(target:IDropTarget)
    {
        if(dropTarget != target)
			throw "Drop target cannot accept a drag at this time. Acceptance may only happen after the DragDropEvent.DRAG_ENTER event is dispatched and before the DragDropEvent.DRAG_EXIT event is dispatched.";
		isAccepted = true;
    }
    
    public static function cancelDrag()
    {
        if(!isDragging) return;
        completeDrag(false);
    }
    
    public static function onTouchBegin(touchId:Int, x:Float, y:Float)
    {
        if(touchId != touchPointId) return;
    }
    public static function onTouchMove(touchId:Int, x:Float, y:Float)
    {
        if(touchId != touchPointId) return;
    }
    public static function onTouchEnd(touchId:Int, x:Float, y:Float)
    {
        if(touchId != touchPointId) return;
        touchPointId = -1;
		var isDropped = false;
		if(dropTarget != null && isAccepted)
		{
			dropTarget.onDragComplete(dragData);
			isDropped = true;
		}
		dropTarget = null;
		completeDrag(isDropped);
    }
    public static function onTouchCancel(touchId:Int, x:Float, y:Float)
    {
        if(touchId != touchPointId) return;
    }
    
    static function updateDropTarget(location:Point)
	{
		/*
        var target = Gessie.touchManager.hitTesters[0].hitTest(location);
        
		while(target && !(target is IDropTarget))
		{
			target = target.parent;
		}
		if(target)
		{
			target.globalToLocal(location, location);
		}
		if(target != dropTarget)
		{
			if(dropTarget)
			{
				//notice that we can reuse the previously saved location
				dropTarget.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_EXIT, _dragData, false, dropTargetLocalX, dropTargetLocalY));
			}
			dropTarget = IDropTarget(target);
			isAccepted = false;
			if(dropTarget)
			{
				dropTargetLocalX = location.x;
				dropTargetLocalY = location.y;
				dropTarget.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_ENTER, _dragData, false, dropTargetLocalX, dropTargetLocalY));
			}
		}
		else if(dropTarget)
		{
			dropTargetLocalX = location.x;
			dropTargetLocalY = location.y;
			dropTarget.dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_MOVE, _dragData, false, dropTargetLocalX, dropTargetLocalY));
		}
        */
	}

    
    
    static function completeDrag(isDropped:Bool)
    {
        if(!isDragging)
			throw "Drag cannot be completed because none is currently active.";
        
		if(dropTarget != null)
		{
			dropTarget.onDragExit(dragData);
			dropTarget = null;
		}
		var source = dragSource;
		var data = dragData;
		cleanup();
        source.onDragComplete(data, false);
    }
    
    static function cleanup()
	{
        // remove touchmove keydown handlers
		dragSource = null;
		dragData = null;
	}
    
    static inline function get_isDragging():Bool
        return dragData != null;
}
