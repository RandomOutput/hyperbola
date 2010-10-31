package utils
{
	import actors.DynamicCircle;
	import actors.Wormhole;

	public class Teleportation
	{
		public var object:DynamicCircle;
		public var wormhole:Wormhole;
		public var destination:Wormhole;
		
		public function Teleportation(_object:DynamicCircle, _wormhole:Wormhole)
		{
			object = _object;
			wormhole = _wormhole;
			destination = wormhole.pair;
		}
	}
}