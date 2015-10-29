package gessie.core;
import gessie.core.GestureManager;
import gessie.core.IDisplayListAdapter;
import gessie.core.IInputAdapter;
import gessie.core.ITouchHitTester;
import gessie.core.TouchManager;
import gessie.util.Emitter;
import gessie.util.Macros.*;

/**
 * ...
 * @author Kevin
 */
@:allow(gessie)
class Gessie
{
	public static var emitter:Emitter<GessieEventType> = new Emitter();
	public static var root:Root;
	public static var inputAdapter(default, set):IInputAdapter<Dynamic>;
	public static var touchManager(default, null):TouchManager<Dynamic> = new TouchManager();
	public static var gestureManager(default, null):GestureManager<Dynamic> = new GestureManager(touchManager);
	
	static var displayListAdaptersMap:Map<String, IDisplayListAdapter<Dynamic>> = new Map();
	
	public static function init<T:{}>(root:Root, inputAdapter:IInputAdapter<T>)
	{
		Gessie.root = root;
		Gessie.inputAdapter = inputAdapter;
	}
	
	public static function addDisplayListAdapter<T:{}>(targetClass:Class<Dynamic>, adapter:IDisplayListAdapter<T>):Void
	{
		assertNull(targetClass);
		assertNull(adapter);
		
		var className = Type.getClassName(targetClass);
		displayListAdaptersMap[className] = adapter;
	}
	
	public static function addTouchHitTester<T>(hitTester:ITouchHitTester<T>, priority:Int = 0)
	{
		touchManager.addTouchHitTester(hitTester, priority);
	}
	
	
	public static function removeTouchHitTester<T>(hitTester:ITouchHitTester<T>)
	{
		touchManager.removeInputAdapter(hitTester);
	}
	
	public static function update()
	{
		emitter.emit(GEnterFrame);
	}
	
	static function createGestureTargetAdapter<T:{}>(target:T):IDisplayListAdapter<T>
	{
		var adapter = getDisplayListAdapter(target);

		if (adapter != null)
			return cast Type.createInstance(Type.getClass(adapter), [target]);
		
		throw 'Cannot create adapter for target $target of type ${Type.getClassName(Type.getClass(target))}.';
	}
	
	static function getDisplayListAdapter(object:Dynamic)
	{
		var cls = Type.getClass(object);
		var className = Type.getClassName(cls);
		var result = displayListAdaptersMap[className];
		
		while (result == null) 
		{
			cls = Type.getSuperClass(cls);
			if (cls == null) break;
			className = Type.getClassName(cls);
			result = displayListAdaptersMap[className];
		}
		return result;
	}
	
	
	static function set_inputAdapter(v:IInputAdapter<Dynamic>):IInputAdapter<Dynamic>
	{
		if (inputAdapter == v) return v;
		
		inputAdapter = v;
		
		if (inputAdapter != null)
		{
			inputAdapter.touchManager = touchManager;
			inputAdapter.init();
		}
		
		return inputAdapter;
	}
	
	
}

@:enum
abstract GessieEventType(Int) from Int to Int
{
	var GEnterFrame = 1;
}
