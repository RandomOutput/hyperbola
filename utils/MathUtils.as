package utils
{
	import flash.geom.Point;
	
	public class MathUtils
	{
		public function MathUtils()
		{
			trace("abstract class, no need to use constructor [MathUtils]");
		}
		
		//given two ordered pairs gives the distance
		public static function twoPointDist(x1:Number, y1:Number, x2:Number, y2:Number):Number { //solve for the distance between two points
			var retVal:Number = Math.sqrt(( (x1-x2) * (x1-x2) )+( (y1-y2) * (y1-y2) ));
			return retVal;
		}
		
		//send it two points and it will give you the angle in degrees
		public static function getAngle(pt1:Point, pt2:Point):Number {
			var rad = Math.atan2((pt2.y-pt1.y) * -1, pt2.x-pt1.x);
			var deg = rad * 180 / Math.PI;
			if ((pt2.x-pt1.x)<0) {
				deg += 180;
			}
			if ((pt2.x-pt1.x)>=0 && ((pt2.y-pt1.y) * -1)<0) {
				deg += 360;
			}
			return deg;
		}
		
		//send it degrees, it will give you a vector as an x,y point
		public static function degreesToSlope(deg:Number):Point {
			var rad = deg * Math.PI / 180			
			return new Point(Math.cos(rad), Math.sin(rad));
		}
	}
}