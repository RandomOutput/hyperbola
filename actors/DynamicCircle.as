package actors
{
	import flash.display.MovieClip;
	import flash.net.dns.AAAARecord;
	
	public class DynamicCircle extends MovieClip
	{
		protected const GRAV:Number = .01;
		protected const CUTOFF:Number = 160;
		
		private static const FRICTION:Number = .99;
		private const MIN_SPEED:Number = 5;
		
		public var deltaX:Number;
		public var deltaY:Number;
		public var radius:Number;
		public var density:Number;
		
		public function DynamicCircle(_xLoc:Number, _yLoc:Number,_deltaX:Number = 0, _deltaY:Number = 0, _radius:Number = 10, _density:Number = 1)
		{
			this.x = _xLoc;
			this.y = _yLoc;
			deltaX = _deltaX;
			deltaY = _deltaY;
			radius = _radius;
			density = _density;
		}
		
		public function behavior():void {
			if(Math.sqrt((this.deltaX*this.deltaX) + (this.deltaY + this.deltaY)) > MIN_SPEED) {
				this.deltaX *= FRICTION;
				this.deltaY *= FRICTION;
			}
		}
		
		public function move():void {
			this.x += deltaX;
			this.y += deltaY;
		}
	}
}