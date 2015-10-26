package gessie.impl.openfl;
import gessie.core.Gessie;
import gessie.core.IDisplayListAdapter;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Stage;

/**
 * ...
 * @author Kevin
 */
class OpenflDisplayListAdapter implements IDisplayListAdapter<DisplayObject>
{
	public var target(get, null):DisplayObject;
	
	// TODO: need a cross-platform weak ref
	#if js
	var targetWeakMap:Map<DisplayObject, Bool> = new Map();
	#else
	var targetWeakMap:haxe.ds.WeakMap<DisplayObject, Bool> = new haxe.ds.WeakMap();
	#end
	
	public function new(target:DisplayObject = null) 
	{
		targetWeakMap.set(target, true);
	}
	
	public function contains(object:DisplayObject):Bool
	{
		if (target == Gessie.root)
		{
			return true;
		}
		var targetAsDOC = Std.instance(this.target, DisplayObjectContainer);
		return targetAsDOC != null && targetAsDOC.contains(object);
		
		/**
		 * There might be case when we use some old "software" 3D library for instace,
		 * which viewport is added to classic Display List. So native stage, root and some other
		 * sprites will actually be parents of 3D objects. To ensure all gestures (both for
		 * native and 3D objects) work correctly with each other contains() method should be
		 * a bit more sophisticated.
		 * But as all 3D engines (at least it looks like that) are moving towards Stage3D layer
		 * this task doesn't seem significant anymore. So I leave this implementation as
		 * comments in case someone will actually need it.
		 * Just uncomment this and it should work. 
		
		// else: more complex case.
		// object is not of the same type as this.target (flash.display::DisplayObject)
		// it might we some 3D library object in it's viewport (which itself is in DisplayList).
		// So we perform more general check:
		const adapter:IDisplayListAdapter = Gestouch.gestouch_internal::getDisplayListAdapter(object);
		if (adapter)
		{
			return adapter.getHierarchy(object).indexOf(this.target) > -1;
		}
		*/
		
		return false;
	}
	
	public function getHierarchy(object:DisplayObject):Array<DisplayObject>
	{
		var list = [];
		while (object != null)
		{
			list.push(object);
			object = object.parent;
		}
		
		return list;
	}
	
	function get_target():DisplayObject
	{
		for (key in targetWeakMap.keys())
			return key;
		return null;
	}
}