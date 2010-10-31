package actors
{	
	import flash.geom.Point;
	
	import utils.MathUtils;
	
	public class Puck extends DynamicCircle
	{
		private var wormholeList:Vector.<Wormhole>;
		private var goalList:Vector.<Goal>;
		
		public var power:Number;
		
		public function Puck(_wormholeList:Vector.<Wormhole>, _goalList:Vector.<Goal>,_xLoc:Number,_yLoc:Number, _deltaX = 0, _deltaY = 0, _radius = 10, _power = 100)
		{
			super(_xLoc, _yLoc, _deltaX, _deltaY, _radius);
			wormholeList = _wormholeList;
			goalList = _goalList;
			power = _power;
		}
		
		public override function behavior():void {
			//F = GmM/ r^2
			var gForce:Number;
			var modX:Number;
			var modY:Number;
			
			for each(var wormhole in wormholeList){
				gForce = (GRAV * (this.radius * this.density) * (wormhole.radius * wormhole.density)) / (MathUtils.twoPointDist(this.x, this.y, wormhole.x, wormhole.y) * MathUtils.twoPointDist(this.x, this.y, wormhole.x, wormhole.y));
				modX = gForce * MathUtils.degreesToSlope(MathUtils.getAngle(new Point(this.x, this.y), new Point(wormhole.x, wormhole.y))).x;
				modY = gForce * MathUtils.degreesToSlope(MathUtils.getAngle(new Point(this.x, this.y), new Point(wormhole.x, wormhole.y))).y;
				this.deltaX += modX;
				this.deltaY += modY;
			}
			
			for each(var goal in goalList){
				gForce = (GRAV * (this.radius * this.density) * (goal.radius * goal.density)) / (MathUtils.twoPointDist(this.x, this.y, goal.x, goal.y) * MathUtils.twoPointDist(this.x, this.y, goal.x, goal.y));
				modX = gForce * MathUtils.degreesToSlope(MathUtils.getAngle(new Point(this.x, this.y), new Point(goal.x, goal.y))).x;
				modY = gForce * MathUtils.degreesToSlope(MathUtils.getAngle(new Point(this.x, this.y), new Point(goal.x, goal.y))).y;
				this.deltaX += modX;
				this.deltaY += modY;
			}
		}
	}
}