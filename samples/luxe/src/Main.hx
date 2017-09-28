package;

import gessie.gesture.PanGesture;
import gessie.gesture.SwipeGesture;
import gessie.gesture.TapGesture;
import gessie.gesture.ZoomGesture;
import gessie.gesture.RotateGesture;
import gessie.gesture.TransformGesture;
import gessie.impl.luxe.LuxeDisplayListAdapter;
import gessie.impl.luxe.LuxeInputAdapter;
import gessie.impl.luxe.LuxeTouchHitTester;
import luxe.Color;
import luxe.Input;
import gessie.core.Gessie;
import luxe.Text;
import luxe.Vector;
import luxe.Visual;

class Main extends luxe.Game 
{
	override function ready() 
	{
		Gessie.init(null, new LuxeInputAdapter());
		Gessie.addDisplayListAdapter(Visual, new LuxeDisplayListAdapter());
		Gessie.addTouchHitTester(new LuxeTouchHitTester());
		
		var s = new Visual( {
			name: "purple",
			color: new Color().rgb(0x9E67E9),
			size: new Vector(200, 200),
		});
		var s1 = new Visual( {
			name: "green",
			color: new Color().rgb(0x29D39C),
			pos: new Vector(100,100),
			size: new Vector(200, 200),
		});
		
		var text = new Text( {
			point_size:20,
			pos: new Vector(0, Luxe.screen.height),
			align_vertical: bottom,
			text: "Tap the squares",
		});
		
		var tap = new TapGesture(s);
		tap.numTapsRequired = 1;
		tap.on(GERecognized, function(_) text.text += '\ntapped purple');
		
		var tap1 = new TapGesture(s1);
		tap1.numTapsRequired = 1;
		tap1.on(GERecognized, function(_) text.text += '\ntapped green');
		
		var pan = new PanGesture(s);
		pan.on(GEBegan, function(_) text.text += '\npurple pan began');
		pan.on(GEEnded, function(_) text.text += '\npurple pan ended');
		pan.on(GECancelled, function(_) text.text += '\npurple pan cancelled');
		pan.on(GEChanged, function(_) text.text += '\npurple pan changed: offset=' + pan._offsetX +','+pan._offsetY);
		
		var swipe = new SwipeGesture(s);
		swipe.on(GERecognized, function(_) text.text += '\nswiped purple');

		var zoom = new ZoomGesture(s1);
        zoom.on(GEChanged, function(_) {
                            s1.scale.x=zoom.scaleX;
                            s1.scale.y=zoom.scaleY;
                        });
        var rotate = new RotateGesture(s1);
        rotate.on(GEChanged, function(_) s1.rotation_z=rotate.rotation);
        var trans = new TransformGesture(s);
        trans.on(GEChanged, function(_) {
                            s.scale.set_xy(trans.scale, trans.scale);
                            s.rotation_z=trans.rotation;
                        });
	}

	override function onkeyup(e:KeyEvent) 
	{
		if(e.keycode == Key.escape)
			Luxe.shutdown();
	}
	
	override public function ontouchdown(event:TouchEvent) 
	{
		super.ontouchdown(event);
	}

	override function update(dt:Float) 
	{
		
	}
}