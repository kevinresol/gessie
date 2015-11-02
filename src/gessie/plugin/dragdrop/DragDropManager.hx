package gessie.plugin.dragdrop;

import gessie.core.*;
import gessie.core.Touch;
import gessie.core.TouchManager;
import gessie.geom.Point;
import gessie.util.Macros.*;
import gessie.plugin.dragdrop.*;

class DragDropManager
{
    static var helperPoint:Point = new Point();
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
        assertNull(data);
        
        dragSource = source;
        dragData = data;
        touchPointId = touch.id;
        source.dragDropEmitter.emit(DStart, {data:data});
        
        Gessie.touchManager.on(TBegan, onTouchBegin);
		Gessie.touchManager.on(TMoved, onTouchMove);
		Gessie.touchManager.on(TEnded, onTouchEnd);
		Gessie.touchManager.on(TCancelled, onTouchCancel);
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
    
    public static function onTouchBegin(touch:Touch<Dynamic>)
    {
        if(touch.id != touchPointId) return;
    }
    public static function onTouchMove(touch:Touch<Dynamic>)
    {
        if(touch.id != touchPointId) return;
		helperPoint.x = touch.location.x;
		helperPoint.y = touch.location.y;
		updateDropTarget(helperPoint);
    }
	
    public static function onTouchEnd(touch:Touch<Dynamic>)
    {
        if(touch.id != touchPointId) return;
        touchPointId = -1;
		var isDropped = false;
		if(dropTarget != null && isAccepted)
		{
			dropTarget.dragDropEmitter.emit(DDrop, {data:dragData});
			isDropped = true;
		}
		dropTarget = null;
		completeDrag(isDropped);
    }
    public static function onTouchCancel(touch:Touch<Dynamic>)
    {
        if(touch.id != touchPointId) return;
    }
    
    static function updateDropTarget(location:Point)
	{
		var target:IDropTarget = null;
		for (hitTester in Gessie.touchManager.hitTesters)
		{
			target = hitTester.hitTest(location, null, IDropTarget, [dragSource]);
			if (target != null) break;
		}
		
		if(target != dropTarget)
		{
			if(dropTarget != null)
				dropTarget.dragDropEmitter.emit(DExit, {data:dragData});
				
			dropTarget = cast target;
			isAccepted = false;
			
			if(dropTarget != null)
		dropTarget.dragDropEmitter.emit(DEnter, {data:dragData, location:location});
		}
		else if(dropTarget != null)
			dropTarget.dragDropEmitter.emit(DMove, {data:dragData, location:location});
        
	}
    
    static function completeDrag(isDropped:Bool)
    {
        if(!isDragging)
			throw "Drag cannot be completed because none is currently active.";
        
		if(dropTarget != null)
		{
			dropTarget.dragDropEmitter.emit(DExit, {data:dragData});
			dropTarget = null;
		}
		var source = dragSource;
		var data = dragData;
		cleanup();
        source.dragDropEmitter.emit(DComplete, {data:data, isDropped:false});
    }
    
    static function cleanup()
	{
        Gessie.touchManager.off(TBegan, onTouchBegin);
		Gessie.touchManager.off(TMoved, onTouchMove);
		Gessie.touchManager.off(TEnded, onTouchEnd);
		Gessie.touchManager.off(TCancelled, onTouchCancel);
		
		dragSource = null;
		dragData = null;
	}
    
    static inline function get_isDragging():Bool
        return dragData != null;
}
