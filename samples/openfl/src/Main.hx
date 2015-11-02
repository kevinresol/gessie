package;

import gessie.core.Gessie;
import gessie.gesture.TapGesture;
import gessie.impl.openfl.OpenflDisplayListAdapter;
import gessie.impl.openfl.OpenflInputAdapter;
import gessie.impl.openfl.OpenflTouchHitTester;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.text.TextField;

/**
 * ...
 * @author Kevin
 */
class Main extends Sprite 
{

	public function new() 
	{
		super();
		
		trace("start");
		
		Gessie.init(stage, new OpenflInputAdapter(stage, true, true));
		Gessie.addDisplayListAdapter(DisplayObject, new OpenflDisplayListAdapter());
		Gessie.addTouchHitTester(new OpenflTouchHitTester(stage));
		
		var bmd1 = new BitmapData(200, 200, false, 0xFF7979);
		var bmd2 = new BitmapData(200, 200, false, 0x72DAFC);
		
		var s1 = new Sprite();
		var s2 = new Sprite();
		s2.x = s2.y = 100;
		
		s1.addChild(new Bitmap(bmd1));
		s2.addChild(new Bitmap(bmd2));
		
		addChild(s1);
		addChild(s2);
		
		var tap1 = new TapGesture(s1);
		var tap2 = new TapGesture(s2);
		
		var tf = new TextField();
		tf.y = 400;
		tf.height = 80;
		tf.textColor = 0xffffff;
		tf.text = "Tap the squares";
		addChild(tf);
		
		inline function addText(text)
		{
			tf.text += '\n$text';
			tf.scrollV = tf.maxScrollV;
		}
		
		tap1.on(GERecognized, function(_) addText('tapped red'));
		tap2.on(GERecognized, function(_) addText('tapped blue'));
		
		
	}

}
