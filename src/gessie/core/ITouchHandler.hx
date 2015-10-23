package gessie.core;

import gessie.geom.Point;

interface ITouchHitTester<T>
{
    function hitTest(point:Point, possibleTarget:T):T;
}
