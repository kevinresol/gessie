package gessie.core;

import gessie.geom.Point;

interface ITouchHitTester<T>
{
    /**
        Return the topmost object under `point` (screen coordinate)
    */
    function hitTest(point:Point, possibleTarget:T, ?ofClass:Class<Dynamic>, ?exclude:Array<T>):T;
}
