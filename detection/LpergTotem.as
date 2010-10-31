/*******
File: Hyperbola Backend Totem Object
Author: Daniel Plemmons (see LPERG site for contact information)

Description:
Holds properties for individual totem.  
Mostly used as a container to send totem data to front-end
*******/

package  detection {
	
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	public class LpergTotem {
		
		private var totemLoc:Point = new Point(0,0); //current location of the totem
		private var deltaX:Number = 0; //difference between current x and prev x on stage grid.
		private var deltaY:Number = 0; //difference between current y and prev y on stage grid.
		
		private var currentController:String = ""; //the ID of the current controlling point
		
		//time of last data update
		private var lastUpdated:Number = 0;
		
		private const RADIUS = 89;
		
		public function lpergTotem(startLoc:Point = null, startDeltaX:Number = 0, startDeltaY:Number = 0) {
			//assign inital state based on constructor arguments
			if(startLoc != null) {	setLoc(startLoc.x, startLoc.y); }
			setDeltaX(startDeltaX);
			setDeltaY(startDeltaY);		
		}
		
		/** Utility Functions **/

		
		/** Accessors **/
		/***************/
		
		public function getLoc():Point {
			return totemLoc;
		}
		
		public function getDeltaX():Number {
			return deltaX;
		}
		
		public function getDeltaY():Number {
			return deltaY;
		}
		
		public function isActive():Boolean {
			if(currentController == "") { return false; } else { return true; }
		}
		
		public function getRadius():int {
			return RADIUS;
		}
		
		internal function getController():String {
			return currentController;
		}
		
		internal function timeSinceUpdate():Number {
			//returns the time in milliseconds since the last update;
			
			return (getTimer() - lastUpdated);
		}
		
		
		/** Modifiers **/
		/***************/
		
		internal function seLoctX(newX:Number, ignoreDelta = false) {
			if(!ignoreDelta) { //unless ignoring this change, update the deltaX
				setDeltaX(totemLoc.x - newX);
			}
			
			totemLoc.x = newX; //update X
			lastUpdated = getTimer(); //mark the new data update
		}
		
		internal function setLocY(newY:Number, ignoreDelta = false) {
			if(!ignoreDelta) { //unless ignoring this change, update the deltaX
				setDeltaY(totemLoc.y - newY);
			}
			
			totemLoc.y = newY; //update Y
			lastUpdated = getTimer(); //mark the new upate
		}
		
		internal function setLoc(newX:Number, newY:Number, ignoreDelta = false) {
			if(!ignoreDelta) { //unless ignoring this change, update the deltaX and deltaY
				setDeltaX(totemLoc.x - newX); 
				setDeltaY(totemLoc.y - newY);
			}
			
			totemLoc.x = newX; //update X
			totemLoc.y = newY; //update Y
			lastUpdated = getTimer(); //mark the new data update
		}
		
		internal function setDeltaX(newDeltaX:Number) {
			deltaX = newDeltaX;
			lastUpdated = getTimer();
		}
		
		internal function setDeltaY(newDeltaY:Number) {
			deltaY = newDeltaY;
			lastUpdated = getTimer();
		}
		
		internal function setController(newController:String):void {
			currentController = newController;
		}
		
		internal function deactivate() {
			currentController = "";
			this.setDeltaX(0);
			this.setDeltaY(0);
		}

	}
	
}
