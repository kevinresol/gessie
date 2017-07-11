package gessie.impl.heaps;

import gessie.core.Gessie;
import gessie.core.IDisplayListAdapter;
import h2d.Sprite;

/**
 * ...
 * @author josu igoa
 */
class HeapsDisplayListAdapter implements IDisplayListAdapter<Sprite>
{
	public var target(default, null):Sprite;
	
	public function new(target:Sprite = null) 
	{
		this.target = target;
	}
	
	public function contains(object:Sprite):Bool
	{
		if (target == Gessie.root)
		{
			return true;
		}
        function contain(e:Sprite, o:Sprite)
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
	
	public function getHierarchy(object:Sprite):Array<Sprite>
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
