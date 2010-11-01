/*******

File: LPERG Backend IR Input Controller
Author: Daniel Plemmons (see LPERG site for contact information)

Description:
Main Controller and Interface for all IR Input.
 
Features:
	- Take in TUIO data from Bridge
	- Sanitize TUIO data for front-end constumption
	- Provide interface for front-end to access totem data
	- Track gestures [incomplete]
	- Dispatch gesture events to front-end [incomplete]
	
*******/


package detection {
	
	//needed for use of the Point object
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.geom.Point;
	
	import tuio.*;
	import tuio.TuioEvent;
	import tuio.connectors.*;
	import tuio.osc.*;
	
	public class TotemInputController extends MovieClip{
		
		//If DUMMY_MODE is true, the controller will return only static testing data.
		private const DUMMY_MODE:Boolean = false;
		
		private var totems:Array = new Array(new LpergTotem(), new LpergTotem(), new LpergTotem(), new LpergTotem());
		
		//tuio controller vars
		private var tuioC:TuioClient;
		private var tuioMngr:TuioManager;


		public function TotemInputController() {
			//check to see if the stage is active.  If not, wait till the stage is active
			if (stage) { init(); }
			else { addEventListener(Event.ADDED_TO_STAGE, init); }
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			/**
			 * set up the connection to the TUIO data bridge.  
			 * In this case we're using wiimoteWhiteboard which
			 * connects via a UDP connection.  Documentation can
			 * be found in the TUIO Flash Blog Documentation files.
			**/
			
			this.tuioC = new TuioClient(new UDPConnector());
			
			//TUIO manager will watch for all incoming TUIO data
			this.tuioMngr = TuioManager.init(stage, this.tuioC);
			
			//listeners to track for new, upadates, and removed TUIO data points.
			this.tuioMngr.addEventListener(TuioEvent.ADD, tuioAddHandler);
			this.tuioMngr.addEventListener(TuioEvent.UPDATE, tuioUpdateHandler);
			this.tuioMngr.addEventListener(TuioEvent.REMOVE, tuioRemoveHandler);
			
		}
		
		//accessor for totem data
		public function totemData(totemID:Number = -1):Array {
			/**	
			 * if the caller enters no totemID 
			 * all totems will be returned
			 * 
			 * if the caller enters a totemID 
			 * then only that totem is retured 	
			**/
			 
			//check for dummy mode, if so input dummy data
			if(DUMMY_MODE) {
				//dummy locations
				totems[0].setLoc(20,40);
				totems[1].setLoc(80, 20);
				totems[2].setLoc(120,140);
				totems[3].setLoc(300,400);
				
				//dummy deltas
				totems[1].setDeltaX(10);
			}
			
			if(totemID == -1) {
				return totems;
			} else if (totemID >=0 && totemID <= 3){
				return totems[totemID];
			} else {
				trace("ERROR: Invalid Totem ID [TotemInput.as -> TotemData()]");
				return null;
			}
		}
		
		/** Tuio Event Respone Functions **/
		
		private function tuioAddHandler(e:TuioEvent) { //solve for a new TUIO point
			//trace("Add TUIO Point [tuioInputController.as -> tuioAddHandler()]");
			
			var inactiveTotems:Array = new Array();
			
			var tuioPoint:Point = new Point(e.tuioContainer.x*stage.stageWidth, e.tuioContainer.y*stage.stageHeight); //get the x and y from the TuioEvent and add them to a point
			
			//current closest inactive totem to the new point and the associated totem
			var shortestDist:Number = -1;
			var closestTotem:LpergTotem = null;
			
			/**
			 * check for any inactive totems
			**/
			for(var i:int = 0; i < totems.length; i++) {
				if(totems[i].isActive() == false) { inactiveTotems.push(totems[i]);}
			}
			
			/**
			 * if there are no non-active totems we have an extra point and an error
			**/
			if(inactiveTotems.length == 0) {
				trace("ERROR: Extra Point [totemInput.as -> tuioAddHandler()]");
				return; //end function execution.  There is nothing to do with the new totem.
			}
			
			/**
			 * figure out which totem to give the controller to
			**/
			for(var j:int = 0; j < inactiveTotems.length; j++) {
				if( (closestTotem == null) || ( twoPointDist( tuioPoint.x, tuioPoint.y, inactiveTotems[j].getLoc().x, inactiveTotems[j].getLoc().y ) < shortestDist ) ) { //if this is the first check or if the distance to this totem is shortest yet.
					//set a new closestTotem and shortestDist
					closestTotem = inactiveTotems[j];
					shortestDist = twoPointDist( tuioPoint.x, tuioPoint.y, inactiveTotems[j].getLoc().x, inactiveTotems[j].getLoc().y );
				}
			}
			
			/**
			 * set the new totem data
			**/
		
			closestTotem.setController(e.tuioContainer.sessionID.toString()); //assign the new control point to the closest free totem
			closestTotem.setLoc(tuioPoint.x, tuioPoint.y, true); //set the new location.  IGNORING DELTA.
		}
		
		private function tuioUpdateHandler(e:TuioEvent) { // solve for an updated tuio point
			//trace("Update TUIO Point [tuioInputController.as -> tuioUpdateHandler()]");
			var tuioPoint:Point = new Point(e.tuioContainer.x*stage.stageWidth,e.tuioContainer.y*stage.stageHeight); //get the x and y from the TuioEvent and add them to a point
			tuioToTotem(e).setLoc(tuioPoint.x, tuioPoint.y); //update that point
		}
		
		private function tuioRemoveHandler(e:TuioEvent) {
			//trace("Remove TUIO Point [tuioInputController.as -> tuioRemoveHandler()]");
			
			tuioToTotem(e).deactivate();
		}
		
		private function tuioToTotem(e:TuioEvent):LpergTotem {
			var hugeSuccess:Boolean = false;
			
			for(var i:int = 0; i < totems.length; i++) {
				if(totems[i].getController() == e.tuioContainer.sessionID.toString()) { //if the current totem has the updating point as its controllerID
					
					/*
					at some point I'm probably going to need to write a check in here
					to make sure that an ID switch has not happened.  I just need to know
					the maximum px/second that a player is going to be moving.  If an action happens
					above this speed threshold i'll know an ID switch occured and can 
					account for it by switching the controllingIDs for the totems.
					*/
					hugeSuccess = true; //I'm making a note here huge success.
					return totems[i];
				}
			}		
			
			if(!hugeSuccess) {
				trace("ERROR: Active TUIO point updating with no associated totem [totemInput.as -> tuioToTotem()]"); //tuio point is a lie
				return null;
			}
			else{
				trace("ERROR: No way in hell should this line of code run [totemInput.as -> tuioToTotem()]"); //1011011010120010110...I think I saw a 2
				return null;
			}
			
		}
		
		
		
		/** Relative Location and Angle Finding **/
		private function twoPointDist(x1:Number, y1:Number, x2:Number, y2:Number) { //solve for the distance between two points
			return Math.sqrt(((x1-x2) * (x1-x2)) + ((y1 - y2) * (y1 - y2)));
		}
	}
}
