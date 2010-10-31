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
		
		//TUIO data input
		private var totemInput:TotemInputController;
		
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
		
		private var startTime:Number;
		
		//collision handling
		private var collisionList:Vector.<Collision>;
		
		//teleportation handling
		private var teleportationList:Vector.<Teleportation>;
		
		//Main listens for the stage and runs init when the stage is confirmed
		public function Main()
		{
			if(stage) {init();}else{this.addEventListener(Event.ADDED_TO_STAGE, init);}
		}
		
		//init waits to start the game and kicks off input
		private function init(e:Event = null):void {
			//kick off tuio listening
			totemInput = new TotemInputController();
			stage.addChild(totemInput);	
			
			//kick off keyboard listening (currently required for game start)
			this.addEventListener(KeyboardEvent.KEY_DOWN, keyboardListener);
		}
		
		//defines data for all game objects and kicks off the engine
		private function gameStart():void {
			//initialize player scores
			player1Score = 0;
			player2Score = 0;
			
			//initialize game data constructs
			totemList = new Vector.<Totem>;
			puckList = new Vector.<Puck>;
			wormholeList = new Vector.<Wormhole>;
			goalList = new Vector.<Goal>;
			
			//define the initial game space
			topBound = 0;
			rightBound = 1280;
			bottomBound = 800;
			leftBound = 0;
			
			//store the startTime for this game instance
			startTime = getTimer();
			
			//set engine in motion
			this.addEventListener(Event.ENTER_FRAME, tick);
		}
		
		//primary frame-handler for engine
		private function tick(e:Event):void {
			//initialize (clear) collision and teleportation lists for this frame
			collisionList = new Vector.<Collision>;
			teleportationList = new Vector.<Teleportation>;
			
			//1. update table tracking data
			if(CONTROL_TYPE == "Tuio_UDP") {
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
			var newData = totemInput.totemData();
		}
		
		//move totems based on latest IR data
		private function updateTotems():void {
			
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
					if(MathUtils.twoPointDist(puck2.x, puck2.y, puck3.x, puck3.y) < puck2.radius + puck3.radius && !alreadyColliding(puck2, puck3)) {
						collisionList.push(new Collision(puck2, puck3));
					}
				}
				
				for each(var wormhole2:Wormhole in wormholeList) {
					if(MathUtils.twoPointDist(puck2.x, puck2.y, wormhole2.x, wormhole2.y) < puck2.radius + wormhole2.radius && !alreadyColliding(puck2, wormhole2)) {
						collisionList.push(new Collision(totem, wormhole));
					}
				}
				
				for each(var goal2:Goal in goalList) {
					if(MathUtils.twoPointDist(puck2.x, puck2.y, goal2.x, goal2.y) < puck2.radius + goal2.radius && !alreadyColliding(puck2, goal2)) {
						collisionList.push(new Collision(puck2, goal2));
					}
				}
			}
			
			for each(var wormhole3:Wormhole in wormholeList) {				
				for each(var wormhole4:Wormhole in wormholeList) {
					if(MathUtils.twoPointDist(wormhole3.x, wormhole3.y, wormhole4.x, wormhole4.y) < wormhole3.radius + wormhole4.radius && !alreadyColliding(wormhole3, wormhole4)) {
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
					if(MathUtils.twoPointDist(goal4.x, goal4.y, goal5.x, goal5.y) < goal4.radius + goal5.radius && !alreadyColliding(goal4, goal5)) {
						collisionList.push(new Collision(puck2, goal2));
					}
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
				var obj2:DynamicCircle = collision.obj1; //store object2 for ease of reference
				
				if(obj1 is Totem) { // if the first object is a totem
					if(obj2 is Puck) {// if the second object is a puck
					//collide with puck
						//1. modify puck vector
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
		
		private function circularCollision(obj1:DynamicCircle, obj2:DynamicCircle, object1Only:Boolean = false) {
			//collision equations translated from java: http://www.phy.ntnu.edu.tw/ntnujava/index.php?topic=4
			
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
				obj2.deltaX = vx1;
				obj2.deltaY = vy1;
			}
		}
		
		//itterate through stored teleportations and solve
		private function resolveTeleportation():void {
			for each(var teleportation:Teleportation in teleportationList) {
				var teleportedObj:DynamicCircle = teleportation.object;
				var destination:Wormhole = teleportation.destination;
				
				teleportedObj.x = destination.x;
				teleportedObj.y = destination.y;
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
		
		private function spawnPuck() {
			//spawn new puck in center
			//currently spawning with semi-random deltaX and deltaY
			var newPuck:Puck = new Puck(wormholeList, goalList, Math.random()*10, Math.random()*10, 10, 100);
			puckList.push(newPuck);
			stage.addChild(newPuck);
		}
		
		private function spawnWormhole() {
			var newWormhole:Wormhole = new Wormhole(0,0,0,0,10,null,0);
		}
		
		//Keyboard Listeners
		private function keyboardListener(e:KeyboardEvent):void {
			switch(e.keyCode) {
				case 32:
					gameStart();
					break;
				default:
					break;
			}
		}
	}
}