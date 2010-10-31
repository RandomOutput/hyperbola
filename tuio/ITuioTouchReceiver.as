package tuio
{
	import tuio.TouchEvent;

	public interface ITuioTouchReceiver
	{
		function updateTouch(event:TouchEvent):void;
		function removeTouch(event:TouchEvent):void;
	}
}