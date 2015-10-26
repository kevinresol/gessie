package gessie.impl.luxe;
import gessie.core.IDisplayListAdapter;
import luxe.Entity;

import luxe.Visual;

/**
 * ...
 * @author Kevin
 */
class LuxeDisplayListAdapter implements IDisplayListAdapter<Visual>
{
	public var target(get, null):Visual;
	
	// TODO: need a cross-platform weak ref
	#if js
	var targetWeakMap:Map<Visual, Bool> = new Map();
	#else
	var targetWeakMap:haxe.ds.WeakMap<Visual, Bool> = new haxe.ds.WeakMap();
	#end
	
	public function new(target:Visual = null) 
	{
		if(target != null)
			targetWeakMap.set(target, true);
	}
	
	public function contains(object:Visual):Bool
	{
		return true;
	}
	
	public function getHierarchy(object:Visual):Array<Visual>
	{
		var list = [];
		var entity:Entity = object;
		
		while (entity != null)
		{
			if (Std.is(entity, Visual))
				list.push(cast entity);
			entity = entity.parent;
		}
		
		return list;
	}
	
	function get_target():Visual
	{
		for (key in targetWeakMap.keys())
			return key;
		return null;
	}
}