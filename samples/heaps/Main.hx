package;

import gessie.gesture.PanGesture;
import gessie.gesture.SwipeGesture;
import gessie.gesture.TapGesture;
import gessie.gesture.ZoomGesture;
import gessie.gesture.RotateGesture;
import gessie.gesture.TransformGesture;
import gessie.impl.heaps.HeapsDisplayListAdapter;
import gessie.impl.heaps.HeapsInputAdapter;
import gessie.impl.heaps.HeapsTouchHitTester;
import gessie.core.Gessie;

class Main extends hxd.App {

    override function init() {
        Gessie.init(s2d, new HeapsInputAdapter(s2d));
		Gessie.addDisplayListAdapter(h2d.Sprite, new HeapsDisplayListAdapter());
		Gessie.addTouchHitTester(new HeapsTouchHitTester(s2d));

        var purple = new h2d.Bitmap(h2d.Tile.fromColor(0xff9e67e9, 400, 400), s2d);
        purple.name = 'purple';
        var green = new h2d.Bitmap(h2d.Tile.fromColor(0xff29D39C, 400, 400), s2d);
        green.x = 200;
        green.y = 200;
        green.name = 'green';
		
        var text = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        text.text = 'Tap the squares';
        text.x = s2d.width - text.textWidth;
		
		var tap = new TapGesture(purple);
		tap.numTapsRequired = 1;
		tap.on(GERecognized, function(_) text.text += '\ntapped purple');
		
		var tap1 = new TapGesture(green);
		tap1.numTapsRequired = 1;
		tap1.on(GERecognized, function(_) text.text += '\ntapped green');

		var twotap = new TapGesture(green);
		twotap.numTouchesRequired = 2;
		twotap.on(GERecognized, function(_) text.text += '\ntwo finger tapped green');
		
		var pan = new PanGesture(purple);
		pan.on(GEBegan, function(_) text.text += '\npurple pan began');
		pan.on(GEEnded, function(_) text.text += '\npurple pan ended');
		pan.on(GECancelled, function(_) text.text += '\npurple pan cancelled');
		pan.on(GEChanged, function(_) text.text += '\npurple pan changed: offset=' + pan._offsetX +','+pan._offsetY);
		
		var zoom = new ZoomGesture(green);
        zoom.on(GEChanged, function(_) {
                            green.scaleX=zoom.scaleX;
                            green.scaleY=zoom.scaleY;
                        });
        var rotate = new RotateGesture(green);
        rotate.on(GEChanged, function(_) green.rotation=rotate.rotation);
        var trans = new TransformGesture(s2d);
        trans.on(GEChanged, function(_) {
                            purple.setScale(trans.scale);
                            purple.rotation=trans.rotation;
                        });
    }

    override function update(dt:Float) {
        Gessie.update();
    }

    static function main() {
        new Main();
    }
}