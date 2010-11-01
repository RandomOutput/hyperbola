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
			var slopeX:Number;
			var slopeY:Number;
			var modX:Number;
			var modY:Number;
			
			for each(var wormhole in wormholeList){
				if(MathUtils.twoPointDist(this.x, this.y, wormhole.x, wormhole.y) <= CUTOFF){
					gForce = (GRAV * (this.radius * this.density) * (wormhole.radius * wormhole.density)) / ((MathUtils.twoPointDist(this.x, this.y, wormhole.x, wormhole.y) * (MathUtils.twoPointDist(this.x, this.y, wormhole.x, wormhole.y))));
					
					modX = (wormhole.x - this.x) / MathUtils.twoPointDist(this.x, this.y, wormhole.x, wormhole.y);
					modY = (wormhole.y - this.y) / MathUtils.twoPointDist(this.x, this.y, wormhole.x, wormhole.y);
					
					this.deltaX += modX;
					this.deltaY += modY;
				}
				
				super.behavior();

			}
			
			for each(var goal in goalList){
				gForce = (GRAV * (this.radius * this.density) * (goal.radius * goal.density)) / (MathUtils.twoPointDist(this.x, this.y, goal.x, goal.y) * MathUtils.twoPointDist(this.x, this.y, goal.x, goal.y));
				modX = (goal.x - this.x) / MathUtils.twoPointDist(this.x, this.y, goal.x, goal.y);
				modY = (goal.y - this.y) / MathUtils.twoPointDist(this.x, this.y, goal.x, goal.y);
				
				this.deltaX += modX;
				this.deltaY -= modY;
			}
		}
	}
}