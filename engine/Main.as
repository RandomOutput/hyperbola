package engine
{
	import actors.DynamicCircle;
	import actors.Goal;
	import actors.Puck;
	import actors.Totem;
	import actors.Wormhole;
	
	import detection.IRPoint;
	import detection.TotemInputController;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	
	import utils.Collision;
	import utils.MathUtils;
	import utils.Teleportation;
	
	public class Main extends MovieClip
	{
		//User input method
		private const CONTROL_TYPE:String = "TUIO_UDP";
		
		//debugging
		private const DEBUG_MODE:Boolean = true;
		
		//actor radii
		private const TOTEM_RAD:Number = 57.5;
		private const PUCK_RAD:Number = 46;
		private const WORMHOLE_RAD:Number = 80;
		
		//TUIO data input
		private var totemStream:TotemInputController;
		private var latestTotemData:Array;
		
		//scoring
		private var player1Score:Number;
		private var player2Score:Number;
		
		//game actors
		private var totemList:Vector.<Totem>;
		private var puckList:Vector.<Puck>;
		private var wormholeList:Vector.<Wormhole>;
		private var goalList:Vector.<Goal>;
		
		//game space defenition
		private var leftBound:int;
		private var topBound:int;
		private var rightBound:int;
		private var bottomBound:int;
		
		private var playspace:Playspace;
		
		private var startTime:Number; //start time for game instance
		
		//non-game UI elements
		private var startScreen:StartScreen;
		
		//handles if game is currently running
		private var gameOn:Boolean = false;
		
		//collision handling
		private var collisionList:Vector.<Collision>;
		
		//teleportation handling
		private var teleportationList:Vector.<Teleportation>;
		
		//Main listens for the stage and runs init when the stage is confirmed
		public function Main()
		{
			if(DEBUG_MODE){trace("Main()");}
			if(stage) {init();}else{this.addEventListener(Event.ADDED_TO_STAGE, init);}
		}
		
		//init waits to start the game and kicks off input
		private function init(e:Event = null):void {
			if(DEBUG_MODE){trace("init()");}
			
			//kick off tuio listening
			totemStream = new TotemInputController();
			stage.addChild(totemStream);	
			
			//initialize and place playspace elements
			playspace = new Playspace();
			playspace.x = 34;
			playspace.y = 37;
			stage.addChild(playspace);
			
			//initialize and place start screen UI elements
			startScreen = new StartScreen();
			startScreen.x = 88;
			startScreen.y = 82;
			stage.addChild(startScreen);
			
			//kick off keyboard listening (currently required for game start)
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardListener);
		}
		
		//defines data for all game objects and kicks off the engine
		private function gameStart():void {
			if(stage.contains(startScreen)) {
				stage.removeChild(startScreen);
			}
			
			if(gameOn){
				clearGame();
			}
			
			gameOn = true;
			
			if(DEBUG_MODE){trace("gameStart()");}
			//initialize player scores
			player1Score = 0;
			player2Score = 0;
			
			//initialize game data constructs
			totemList = new Vector.<Totem>;
			puckList = new Vector.<Puck>;
			wormholeList = new Vector.<Wormhole>;
			goalList = new Vector.<Goal>;
			
			//define totems
			for(var i:int=0;i<4;i++) {
				var newTotem = new Totem(0,0,TOTEM_RAD);
				totemList.push(newTotem);
				stage.addChild(newTotem);
			}
			
			//define the initial game space
			topBound = 37;
			rightBound = 1248;
			bottomBound = 696;
			leftBound = 34;
			
			//store the startTime for this game instance
			startTime = getTimer();
			
			spawnPuck(200, 500);
			spawnPuck(800,500);
			spawnWormholePair();
			
			//set engine in motion
			this.addEventListener(Event.ENTER_FRAME, tick);
		}
		
		//primary frame-handler for engine
		private function tick(e:Event):void {
			//if(DEBUG_MODE){trace("tick()");}
			//initialize (clear) collision and teleportation lists for this frame
			collisionList = new Vector.<Collision>;
			teleportationList = new Vector.<Teleportation>;
			
			//1. update table tracking data
			if(CONTROL_TYPE == "TUIO_UDP") {
				updateIr();
			} else if(CONTROL_TYPE == "Keyboard") {
				if(DEBUG_MODE) {trace("init keyboard control");}
			}
			
			//2. move totems based on tracking data
			updateTotems();
			
			//3. apply all current actor behaviors
			totemBehaviors();
			puckBehaviors();
			wormholeBehaviors();
			goalBehaviors();
			
			//4. Collision Detection
			detectCollisions();
			
			//5. Collision Resolution
			resolveCollisions();
			
			//6. Teleportation
			resolveTeleportation();
			
			//6. Move actors based on updates
			updatePucks();
			updateWormholes();
			updateGoals();
		}
		
		//Bring in IR input & distribute data
		private function updateIr():void {
			//trace("updateIr()");
			latestTotemData = totemStream.totemData();
			//trace(latestTotemData);
		}
		
		//move totems based on latest IR data
		private function updateTotems():void {
			totemList[0].x = latestTotemData[0].getLoc().x;
			totemList[0].y = latestTotemData[0].getLoc().y;
			
			totemList[1].x = latestTotemData[1].getLoc().x;
			totemList[1].y = latestTotemData[1].getLoc().y;
			
			totemList[2].x = latestTotemData[2].getLoc().x;
			totemList[2].y = latestTotemData[2].getLoc().y;
			
			totemList[3].x = latestTotemData[3].getLoc().x;
			totemList[3].y = latestTotemData[3].getLoc().y;
		}
		
		//itterate through totems, run inate behavior function
		private function totemBehaviors():void {
			for each(var totem:Totem in totemList) {
				totem.behavior();
			}
		}
		
		//itterate through pucks, run inate behavior function
		private function puckBehaviors():void {
			for each(var puck:Puck in puckList) {
				puck.behavior();
			}
		}
		
		//itterate through wormholes, run inate behavior function
		private function wormholeBehaviors():void {
			for each(var wormhole:Wormhole in wormholeList) {
				wormhole.behavior();
			}
		}
		
		//itterate through goals, run inate behavior function
		private function goalBehaviors():void {
			for each(var goal:Goal in goalList) {
				goal.behavior();
			}
		}
		
		//detect collisions between actors & add them to collision list
		private function detectCollisions():void {
			for each(var totem:Totem in totemList) {
				for each(var puck:Puck in puckList) {
					if(MathUtils.twoPointDist(totem.x, totem.y, puck.x, puck.y) < totem.radius + puck.radius && !alreadyColliding(totem, puck)) {
						trace("puck vs. totem: DETECTED");
						collisionList.push(new Collision(totem, puck));
					}
				}
				
				for each(var wormhole:Wormhole in wormholeList) {
					if(MathUtils.twoPointDist(totem.x, totem.y, wormhole.x, wormhole.y) < totem.radius + wormhole.radius && !alreadyColliding(totem, wormhole)) {
						collisionList.push(new Collision(totem, wormhole));
					}
				}
				
				for each(var goal:Goal in goalList) {
					if(MathUtils.twoPointDist(totem.x, totem.y, goal.x, goal.y) < totem.radius + goal.radius && !alreadyColliding(totem, goal)) {
						collisionList.push(new Collision(totem, goal));
					}
				}
			}
			
			for each(var puck2:Puck in puckList) {
				for each(var puck3:Puck in puckList) {
					if(puck2 != puck3 && MathUtils.twoPointDist(puck2.x, puck2.y, puck3.x, puck3.y) <= (puck2.radius + puck3.radius) && !alreadyColliding(puck2, puck3)) {
						collisionList.push(new Collision(puck2, puck3));
					}
				}
				
				for each(var wormhole2:Wormhole in wormholeList) {
					if(MathUtils.twoPointDist(puck2.x, puck2.y, wormhole2.x, wormhole2.y) < puck2.radius + wormhole2.radius && !alreadyColliding(puck2, wormhole2)) {
						//trace("puck collide with wormhole");
						collisionList.push(new Collision(puck2, wormhole2));
					}
				}
				
				for each(var goal2:Goal in goalList) {
					if(MathUtils.twoPointDist(puck2.x, puck2.y, goal2.x, goal2.y) < puck2.radius + goal2.radius && !alreadyColliding(puck2, goal2)) {
						collisionList.push(new Collision(puck2, goal2));
					}
				}
				
				if(puck2.x + puck2.radius > rightBound || puck2.x - puck2.radius < leftBound) {
					wallCollision(puck2, "side");
				}
				
				if(puck2.y + puck2.radius > bottomBound || puck2.y - puck2.radius < topBound) {
					wallCollision(puck2, "base");	
				}
			}
			
			for each(var wormhole3:Wormhole in wormholeList) {				
				for each(var wormhole4:Wormhole in wormholeList) {
					if(wormhole3 != wormhole4 && MathUtils.twoPointDist(wormhole3.x, wormhole3.y, wormhole4.x, wormhole4.y) < wormhole3.radius + wormhole4.radius && !alreadyColliding(wormhole3, wormhole4)) {
						collisionList.push(new Collision(wormhole3, wormhole4));
					}
				}
				
				for each(var goal3:Goal in goalList) {
					if(MathUtils.twoPointDist(wormhole3.x, wormhole3.y, goal3.x, goal3.y) < wormhole3.radius + goal3.radius && !alreadyColliding(wormhole3, goal3)) {
						collisionList.push(new Collision(puck2, goal2));
					}
				}
			}
			
			for each(var goal4:Goal in goalList) {				
				for each(var goal5:Goal in goalList) {
					if(goal4 != goal5 && MathUtils.twoPointDist(goal4.x, goal4.y, goal5.x, goal5.y) < goal4.radius + goal5.radius && !alreadyColliding(goal4, goal5)) {
						collisionList.push(new Collision(puck2, goal2));
					}
				}
				
				if(goal4.x + goal4.radius > rightBound || goal4.x - goal4.radius < leftBound) {
					wallCollision(goal4, "side");
				}
					
				if(goal4.y + goal4.radius > bottomBound || goal4.y - goal4.radius < topBound) {
					wallCollision(goal4, "base");	
				}
				
			}
		}
		
		private function alreadyColliding(obj1:DynamicCircle, obj2:DynamicCircle):Boolean {
			var foundTarget:Boolean = false;
			for each(var collision:Collision in collisionList) {
				if(collision.obj1 == obj1 ||
					collision.obj1 == obj2 ||
					collision.obj2 == obj1 || 
					collision.obj2 == obj2) {
					foundTarget = true;
					break;
				}
			}
			
			return foundTarget;
		}
		
		//itterate through stored collisions and solve
		private function resolveCollisions():void {
			for each(var collision:Collision in collisionList) {
				var obj1:DynamicCircle = collision.obj1; //store object1 for ease of reference
				var obj2:DynamicCircle = collision.obj2; //store object2 for ease of reference
				
				if(obj1 is Totem) { // if the first object is a totem
					if(obj2 is Puck) {// if the second object is a puck
					//collide with puck
						//1. modify puck vector
						trace("totem vs. puck: RESOLUTION CALL");
						circularCollision(obj2, obj1, true);
					}
				} else if(obj1 is Puck){ // if the first object is a puck
					if(obj2 is Totem) {// if second object is a totem
					//collide puck with totem
						//1. modify puck vector
						circularCollision(obj1, obj2, true);
					} else if(obj2 is Puck) { //if second object is a puck
					//collide puck with puck
						//1. modify puck1 vector
						//2. modify puck2 vector
						circularCollision(obj1, obj2, false);
					} else if(obj2 is Wormhole) { //if second object is a wormhole
					//collide puck with wormhole
						//1. create teleportation object
						//2. push to teleportation list
						//trace("create new teleporation");
						teleportationList.push(new Teleportation(obj1, (obj2 as Wormhole)));
					} else if(obj2 is Goal) { //if second object is a goal
					//collide puck with goal
						//1.remove puck
						for(var i:int=0;i<puckList.length;i++) {
							if(puckList[i] == obj1) {
								stage.removeChild(puckList.splice(i,1) as Puck);
							}
						}
						
						//2.add to player score
						if((obj2 as Goal).owner == "player1"){
							player2Score += (obj1 as Puck).power; 
						} else if((obj2 as Goal).owner == "player2") {
							player1Score += (obj1 as Puck).power;
						}
						
						//3.spawn new puck
						spawnPuck();
					}
				} else if(obj1 is Wormhole && (obj1 as Wormhole).type == "start") { //if the first object is a wormhole
					if(obj2 is Puck) {
					//collide wormhole with puck
						//1. create teleportation object
						//2. push to teleportation list
						teleportationList.push(new Teleportation(obj2, (obj1 as Wormhole)));
					}
				} else if(obj1 is Goal) { //if the first object is a goal
					if(obj2 is Puck){
					//collide goal with puck
						//1.remove puck
						for(var j:int=0;j<puckList.length;j++) {
							if(puckList[j] == obj2) {
								stage.removeChild(puckList.splice(j,1) as Puck);
							}
						}
						
						//2.add to player score
						if((obj1 as Goal).owner == "player1"){
							player2Score += (obj2 as Puck).power; 
						} else if((obj1 as Goal).owner == "player2") {
							player1Score += (obj2 as Puck).power;
						}
						
						//3.spawn new puck
						spawnPuck();
					}		
				}
			}
		}
		
		private function wallCollision(obj:DynamicCircle, sideType:String) {
			if(sideType == "side") {
				obj.deltaX *= -1;
			} else if(sideType == "base") {
				obj.deltaY *= -1;
			}
		}
		
		private function circularCollision(obj1:DynamicCircle, obj2:DynamicCircle, object1Only:Boolean = false) {
			//collision equations translated from java: http://www.phy.ntnu.edu.tw/ntnujava/index.php?topic=4
			trace("circ collision");
			if(obj1 == obj2){
				if(DEBUG_MODE){trace("same object");}
				return;
			}
			
			var mass1:Number = obj1.density * obj1.radius;
			var mass2:Number = obj2.density * obj2.radius;
			var ed = 1;
			var dx:Number = obj1.x - obj2.x;
			var dy:Number = obj1.y - obj2.y;
			var distance:Number = Math.sqrt(dx*dx+dy*dy);
			var ax:Number = dx/distance;
			var ay:Number = dy/distance;
			var va1:Number = (obj1.deltaX*ax+obj1.deltaY*ay);
			var vb1:Number = ((-1 * obj1.deltaX)*ay+obj1.deltaY*ax);
			var va2:Number = (obj2.deltaX*ax+obj2.deltaY*ay);
			var vb2:Number = ((-1 * obj2.deltaX)*ay+obj2.deltaY*ax);
			var vaP1:Number = va1 + (1+ed)*(va2-va1)/(1+mass1/mass2);
			var vaP2:Number = va2 + (1+ed)*(va1-va2)/(1+mass2/mass1);
			var vx1:Number = vaP1*ax-vb1*ay;  
			var vy1:Number = vaP1*ay+vb1*ax; // new vx,vy for ball 1 after collision
			var vx2:Number = vaP2*ax-vb2*ay;  
			var vy2:Number = vaP2*ay+vb2*ax; // new vx,vy for ball 2 after collision
			
			obj1.deltaX = vx1;
			obj1.deltaY = vy1;
			
			if(!object1Only){
				obj2.deltaX = vx2;
				obj2.deltaY = vy2;
			}
		}
		
		//itterate through stored teleportations and solve
		private function resolveTeleportation():void {
			for each(var teleportation:Teleportation in teleportationList) {
				var teleportedObj:DynamicCircle = teleportation.object;
				var destination:Wormhole = teleportation.destination;
				
				if(destination != null) {
					teleportedObj.x = destination.x;
					teleportedObj.y = destination.y;
					//destination = destination.pair;
				}
			}
		}		
		
		//move / kill pucks
		private function updatePucks():void {
			for each(var puck:Puck in puckList) {
				if(puck.power <= 0) {
					for(var i:int=0;i<puckList.length;i++) {
						if(puckList[i] == puck) {
							stage.removeChild(puckList.splice(i,1) as Puck);
						}
					}
				} else {
					puck.move();
				}
			}
		}
		
		//move / kill wormholes
		private function updateWormholes():void {
			for each(var wormhole:Wormhole in wormholeList) {
				wormhole.move();
			}
		}
		
		//move / kill goals
		private function updateGoals():void {
			for each(var goal:Goal in goalList) {
				goal.move();
			}
		}
		
		private function spawnPuck(xLoc:Number = -1, yLoc:Number = -1) {
			//spawn new puck in center
			//currently spawning with semi-random deltaX and deltaY
			var newPuck:Puck;
			if(xLoc == -1 && yLoc == -1) {
				if(DEBUG_MODE){trace("spawn default puck");}
				newPuck = new Puck(wormholeList, goalList, (rightBound / 2) + leftBound,(bottomBound / 2) + topBound, (Math.random()*50) - 25, (Math.random()*50) - 25, PUCK_RAD, 100);
			} else {
				if(DEBUG_MODE){trace("spawn placed puck");}
				newPuck = new Puck(wormholeList, goalList, xLoc,yLoc, (Math.random()*50) - 25, (Math.random()*50) - 25, PUCK_RAD, 100);
			}
			
			puckList.push(newPuck);
			stage.addChild(newPuck);
		}
		
		//spawns a pair of wormholes at oposing sides of the s
		private function spawnWormholePair(xLoc = -1, yLoc = -1) {
			var newWormhole:Wormhole;
			var newWormholePair:Wormhole;
			
			if(xLoc == -1 && yLoc == -1) {
				if(DEBUG_MODE){trace("spawn default puck");}
				newWormhole = new Wormhole((rightBound / 2) + leftBound - 400,(bottomBound / 2) + topBound, 0, 0, WORMHOLE_RAD, null, 0);
				newWormholePair = new Wormhole(stage.width - newWormhole.x, stage.height - newWormhole.y, 0,0,WORMHOLE_RAD, newWormhole,0);
			} else {
				if(DEBUG_MODE){trace("spawn placed puck");}
				newWormhole = new Wormhole(xLoc,yLoc, 0, 0, WORMHOLE_RAD, null, 0);
				newWormholePair = new Wormhole(stage.width - newWormhole.x, stage.height - newWormhole.y, 0,0, WORMHOLE_RAD ,newWormhole,0);
			}
			
			wormholeList.push(newWormhole);
			wormholeList.push(newWormholePair);
			stage.addChild(newWormhole);
			stage.addChild(newWormholePair);
		}
		
		//Keyboard Listeners
		private function keyboardListener(e:KeyboardEvent):void {
			if(DEBUG_MODE){trace("keyboardListener()");}
			if(DEBUG_MODE){trace("KeyCode: " + e.keyCode);}
			switch(e.keyCode) {
				case 32:
					gameStart();
					break;
				default:
					break;
			}
		}
		
		//Clears all game actors from stage for game restart
		private function clearGame():void {
			for(var i:int=0; i<totemList.length;i++) {
				if(puckList[i] != null && stage.contains(puckList[i])){
					stage.removeChild(puckList[i]);
				}
			}
			
			totemList = new Vector.<Totem>;
			
			for(var j:int=0; j<puckList.length;j++){
				if(puckList[j] != null && stage.contains(puckList[j])){
					stage.removeChild(puckList[j]);
				}
			}
			
			puckList = new Vector.<Puck>;
			
			for(var k:int=0; k<wormholeList.length;k++){
				if(wormholeList[k] != null && stage.contains(wormholeList[k])){
					stage.removeChild(wormholeList[k]);
				}
			}
			
			wormholeList = new Vector.<Wormhole>;
			
			for(var l:int=0; l<goalList.length;l++){
				if(goalList[l] != null && stage.contains(goalList[l])){
					stage.removeChild(goalList[l]);
				}
			}
			
			goalList = new Vector.<Goal>;
		}
		
		//Toggles Game Execution
		private function playPause():void {
			if(gameOn) {
				stage.removeChild(startScreen);
				this.removeEventListener(Event.ENTER_FRAME, tick);
				gameOn = false; //CAR!!!!
			} else if(!gameOn) {
				stage.addChild(startScreen);
				this.addEventListener(Event.ENTER_FRAME, tick);
				gameOn = true; //GAME ON!!!!
			}
		}
	}
}