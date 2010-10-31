package actors
{
	public class Wormhole extends DynamicCircle
	{
		public var pair:Wormhole;
		public var type:String;
		public var speed:int;
		
		public function Wormhole(_xLoc:Number,_yLoc:Number, _deltaX:Number = 0, _deltaY:Number = 0, _radius:Number = 10, _pair:Wormhole = null, _speed = 10)
		{
			super(_xLoc, _yLoc, _deltaX, _deltaY, _radius);
			pair = _pair;
			if(pair == null) {
				type = "end";
			} else {
				type = "start";
			}
			speed = _speed;
		}
		
		public override function move():void {
			//parabolic movement...fuck that shit.
			/*
			if(this.y + speed < stage.height) {
				this.y+=speed;
				this.x = (this.y + (stage.height / 2))*(this.y + (stage.height / 2));
			}
			*/
		}
	}
}