package gessie.impl.luxe;
import gessie.core.IDisplayListAdapter;
import luxe.Entity;
import luxe.Scene;
import luxe.Visual;

/**
 * ...
 * @author Kevin
 */
class LuxeDisplayListAdapter implements IDisplayListAdapter<Visual>
{
	public static var targets:Map<Visual, Int> = new Map();
	
	public var target(default, null):Visual;
	
	public static function addTarget(target:Visual)
	{
		targets[target] = targets.exists(target) ? targets[target] + 1 : 1;
	}
	
	public static function removeTarget(target:Visual)
	{
		var i = targets[target] - 1;
		
		if(i == 0) targets.remove(target);
		else targets[target] = i;
	}
	
	public function new(target:Visual = null) 
	{
		this.target = target;
	}
	
	public function contains(object:Visual):Bool
	{
		function contain(e:Entity, o:Entity)
		{
			if (e.children.indexOf(o) != -1)
				return true;
			
			for (c in e.children)
				if (contain(c, o)) return true;
				
			return false;
		}
		
		return contain(target, object);
	}
	
	public function dispose():Void
	{
		target = null;
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
}
