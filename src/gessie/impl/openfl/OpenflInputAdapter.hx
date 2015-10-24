package gessie.impl.openfl;
import gessie.core.IInputAdapter;
import gessie.core.TouchManager;
import openfl.display.DisplayObject;
import openfl.display.Stage;
import openfl.events.EventPhase;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;
import gessie.util.Macros.*;

/**
 * ...
 * @author Kevin
 */
class OpenflInputAdapter implements IInputAdapter<DisplayObject>
{
	static inline var MOUSE_TOUCH_POINT_ID:Int = 0;
	
	@:isVar
	public var touchManager(get, set):TouchManager<DisplayObject>;
	
	var stage:Stage;
	var explicitlyHandleTouchEvents:Bool;
	var explicitlyHandleMouseEvents:Bool;

	public function new(stage:Stage, explicitlyHandleTouchEvents:Bool = false, explicitlyHandleMouseEvents:Bool = false) 
	{
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		
		assertNull(stage);
		
		this.stage = stage;
		
		this.explicitlyHandleTouchEvents = explicitlyHandleTouchEvents;
		this.explicitlyHandleMouseEvents = explicitlyHandleMouseEvents;
	}
	
	public function init()
	{
		if (Multitouch.supportsTouchEvents || explicitlyHandleTouchEvents)
		{
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler, true);
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler, false);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, true);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, false);
			// Maximum priority to prevent event hijacking and loosing the touch
			stage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler, true, 9999);
			stage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler, false, 9999);
		}
		
		if (!Multitouch.supportsTouchEvents || explicitlyHandleMouseEvents)
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false);
		}
	}
	
	public function onDispose()
	{
		touchManager = null;
		
		stage.removeEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler, true);
		stage.removeEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler, false);
		stage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, true);
		stage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, false);
		stage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler, true);
		stage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler, false);
		
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true);
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false);
		unstallMouseListeners();
	}
	
	function installMouseListeners()
	{
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false);
		// Maximum priority to prevent event hijacking
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true, 9999);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 9999);
	}
	
	
	function unstallMouseListeners()
	{
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false);
		// Maximum priority to prevent event hijacking
		stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
		stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false);
	}
	
	function touchBeginHandler(event:TouchEvent)
	{
		// We listen in EventPhase.CAPTURE_PHASE or EventPhase.AT_TARGET
		// (to catch on empty stage) phases only
		if (event.eventPhase == EventPhase.BUBBLING_PHASE)
			return;
		
		touchManager.onTouchBegin(event.touchPointID, event.stageX, event.stageY, event.target);
	}
	
	
	function touchMoveHandler(event:TouchEvent)
	{
		// We listen in EventPhase.CAPTURE_PHASE or EventPhase.AT_TARGET
		// (to catch on empty stage) phases only
		if (event.eventPhase == EventPhase.BUBBLING_PHASE)
			return;
		
		touchManager.onTouchMove(event.touchPointID, event.stageX, event.stageY);
	}
	
	
	function touchEndHandler(event:TouchEvent)
	{
		// We listen in EventPhase.CAPTURE_PHASE or EventPhase.AT_TARGET
		// (to catch on empty stage) phases only
		if (event.eventPhase == EventPhase.BUBBLING_PHASE)
			return;
		
		if (Reflect.hasField(event, "isTouchPointCanceled") && Reflect.field(event, "isTouchPointCanceled"))
		{
			touchManager.onTouchCancel(event.touchPointID, event.stageX, event.stageY);
		}
		else
		{
			touchManager.onTouchEnd(event.touchPointID, event.stageX, event.stageY);
		}
	}
	
	
	function mouseDownHandler(event:MouseEvent)
	{
		// We listen in EventPhase.CAPTURE_PHASE or EventPhase.AT_TARGET
		// (to catch on empty stage) phases only
		if (event.eventPhase == EventPhase.BUBBLING_PHASE)
			return;
		
		var touchAccepted = touchManager.onTouchBegin(MOUSE_TOUCH_POINT_ID, event.stageX, event.stageY, event.target);
		
		if (touchAccepted)
		{
			installMouseListeners();			
		}
	}
	
	
	function mouseMoveHandler(event:MouseEvent)
	{
		// We listen in EventPhase.CAPTURE_PHASE or EventPhase.AT_TARGET
		// (to catch on empty stage) phases only
		if (event.eventPhase == EventPhase.BUBBLING_PHASE)
			return;
		
		touchManager.onTouchMove(MOUSE_TOUCH_POINT_ID, event.stageX, event.stageY);
	}
	
	
	function mouseUpHandler(event:MouseEvent)
	{
		// We listen in EventPhase.CAPTURE_PHASE or EventPhase.AT_TARGET
		// (to catch on empty stage) phases only
		if (event.eventPhase == EventPhase.BUBBLING_PHASE)
			return;			
		
		touchManager.onTouchEnd(MOUSE_TOUCH_POINT_ID, event.stageX, event.stageY);
		
		if (touchManager.activeTouchesCount == 0)
		{
			unstallMouseListeners();
		}
	}
	
	inline function get_touchManager()
		return touchManager;
		
		
	inline function set_touchManager(v)
		return touchManager = v;
}