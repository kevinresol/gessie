# gessie

Gesture Recognition Library for Haxe

Ported from the AS3 gesture library [Gestouch](https://github.com/fljot/Gestouch)

## Usage

### OpenFL

```haxe
public function new() 
{
	super();
	
	Gessie.init(stage, new OpenflInputAdapter(stage, true, true));
	Gessie.addDisplayListAdapter(DisplayObject, new OpenflDisplayListAdapter());
	Gessie.addTouchHitTester(new OpenflTouchHitTester(stage));
	
	stage.addEventListener(Event.ENTER_FRAME, function(_) Gessie.update());
	
	var bmd = new BitmapData(400,400);
	var bm = new Bitmap(bmd);
	var s = new Sprite();
	s.addChild(bm);
	s.mouseEnabled = true;
	addChild(s);
	
	var tap = new TapGesture(s);
	tap.numTapsRequired = 1;
	tap.on(GERecognized, function(_) trace('tapped'));
	
	var pan = new PanGesture(s);
	pan.on(GEBegan, function(_) trace('pan began', pan._offsetX, pan._offsetY));
	pan.on(GEEnded, function(_) trace('pan ended', pan._offsetX, pan._offsetY));
	pan.on(GECancelled, function(_) trace('pan cancelled', pan._offsetX, pan._offsetY));
	pan.on(GEChanged, function(_) trace('pan changed', pan._offsetX, pan._offsetY));
	
	var swipe = new SwipeGesture(s);
	swipe.on(GERecognized, function(_) trace('swiped'));
}
```

### Luxe

```haxe
override function ready() 
{
	Gessie.init(null, new LuxeInputAdapter());
	Gessie.addDisplayListAdapter(Visual, new LuxeDisplayListAdapter());
	Gessie.addTouchHitTester(new LuxeTouchHitTester());
	
	var s = new Visual( {
		name: "test gessie",
		size: new Vector(200, 200),
	});
	
	var tap = new TapGesture(s);
	tap.numTapsRequired = 1;
	tap.on(GERecognized, function(_) trace('tapped'));
	
	var pan = new PanGesture(s);
	pan.on(GEBegan, function(_) trace('pan began', pan._offsetX, pan._offsetY));
	pan.on(GEEnded, function(_) trace('pan ended', pan._offsetX, pan._offsetY));
	pan.on(GECancelled, function(_) trace('pan cancelled', pan._offsetX, pan._offsetY));
	pan.on(GEChanged, function(_) trace('pan changed', pan._offsetX, pan._offsetY));
	
	var swipe = new SwipeGesture(s);
	swipe.on(GERecognized, function(_) trace('swiped'));
}
```

### Other platforms:

1. Call `Gessie.update()` in your update loop
2. Implement 3 interfaces:
  - ITouchHitTester
  - IInputAdapter
  - IDisplayListAdapter


## License

MIT
