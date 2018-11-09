package gessie.impl.heaps;

import gessie.core.Gessie;
import gessie.core.IDisplayListAdapter;
import h2d.Object;

/**
 * ...
 * @author josu igoa
 */
class HeapsDisplayListAdapter implements IDisplayListAdapter<Object>
{
	public var target(default, null):Object;
	
	public function new(target:Object = null) 
	{
		this.target = target;
	}
	
	public function contains(object:Object):Bool
	{
		if (target == Gessie.root)
		{
			return true;
		}
        function contain(e:Object, o:Object)
		{
			if (e.getChildIndex(o) != -1)
				return true;
			
			for (c in e.iterator())
				if (contain(c, o)) return true;
				
			return false;
		}
		
		return contain(target, object);
	}
	
	public function dispose():Void
	{
		target = null;
	}
	
	public function getHierarchy(object:Object):Array<Object>
	{
		var list = [];
		
		while (object != null)
		{
			list.push(object);
			object = object.parent;
		}
		
		return list;
	}
}
