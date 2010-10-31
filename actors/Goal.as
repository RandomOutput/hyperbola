package actors
{
	public class Goal extends DynamicCircle
	{
		public var owner:String;
		
		public function Goal(_xLoc:Number,_yLoc:Number, _deltaX:Number = 0, _deltaY:Number = 0, _radius:Number = 10, _owner:String = "player1")
		{
			super(_xLoc, _yLoc, _deltaX, _deltaY, _radius);
			owner = _owner;
		}
	}
}