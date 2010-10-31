package utils
{
	import actors.DynamicCircle;

	public class Collision
	{
		public var obj1:DynamicCircle;
		public var obj2:DynamicCircle;
		
		public function Collision(_obj1:DynamicCircle, _obj2:DynamicCircle)
		{
			obj1 = _obj1;
			obj2 = _obj2;
		}
	}
}