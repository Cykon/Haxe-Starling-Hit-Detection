/**
  * This class is meant to be the main driver behind a simple game.
  *
  * Author: Michael Albanese
  * Creation Date: January 25, 2015
  *
  */
package com.cykon.haxe.example;

import starling.utils.AssetManager;
import starling.textures.Texture;
import starling.events.EnterFrameEvent;
import starling.events.KeyboardEvent;
import starling.events.TouchEvent;
import starling.events.Touch;
import starling.display.Stage;
import starling.display.Shape;
import flash.system.System;

import com.cykon.haxe.movable.circle.PlayerCircle;
import com.cykon.haxe.movable.circle.Circle;
import com.cykon.haxe.movable.line.Line;
import com.cykon.haxe.movable.line.LineDisplay;
import com.cykon.haxe.cmath.Vector;
import com.cykon.haxe.util.VectorDisplay;

class Lines extends starling.display.Sprite {
	/* The 'perfect' update time, used to modify velocities in case
	   the game is not quite running at frameRate */
	static var perfectDeltaTime : Float = 1/60;
	
	// Reference to the global stage
	static var globalStage : Stage = null;
	
	// Keep track of game assets
	var assets : AssetManager  = new AssetManager();
	var running = true;
	
	var mouseX:Float;
	var mouseY:Float;
	var spawnX:Float;
	var spawnY:Float;
	
	var _player:Circle;
	var player:Circle;
	var line:Line;
	
	// Simple constructor
    public function new() {
        super();
		populateAssetManager();
    }
	
	/** Function used to load in any assets to be used during the game */
	private function populateAssetManager() {
		assets.enqueue("../assets/circle.png");
		assets.enqueue("../assets/circle2.png");
		assets.loadQueue(function(percent){
			// Ideally we would have some feedback here (loading screen)
			
			// When percent is 1.0 all assets are loaded
			if(percent == 1.0){
				startScreen();
			}
		});
	}
	
	/** Do stuff with the menu screen */
	private function startScreen(){
		startGame();
	}
	
	var L1:Line;
	/** Function to be called when we are ready to start the game */
	private function startGame() {
		player = new Circle( assets.getTexture("circle"), 100, 100, 25 );
		_player = new Circle( assets.getTexture("circle2"), 100, 100, 25 );
		player.setVelocity(0,0);
		
		line = Line.getLine(400,300,200,400);
		var lineDisplay = new LineDisplay(2,0,1);
		lineDisplay.addLines([line]);
		
		addChild(lineDisplay);
		addChild(player);
		addChild(_player);
		
		trace("<CLICK> to set circle starting position");
		trace("<SPACE> to shoot circle towards mouse cursor");
		trace("<F> to pause on the next hit");
		trace("<G> to pause");
		
		// Start the onEnterFrame calls
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);	
		globalStage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		globalStage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		globalStage.addEventListener(TouchEvent.TOUCH, onTouch);
	}
	
	/** The game is over! */
	private function triggerGameOver(){		
	}
	
	/** Restart the game */
	private function restartGame(){
	}
	
	var V1:Shape = null;
	var V2:Shape = null;
	
	/** Function called every frame update, main game logic loop */
	private function onEnterFrame( event:EnterFrameEvent ) {
		if(!running)
			return;
	
		// Create a modifier based on time passed / expected time
		var modifier = (event == null) ? 1.0 : event.passedTime / perfectDeltaTime;
		
		
		
		if(player.lineHit(line, modifier)){
			trace("HIT");
			
			if(V1 != null){
				V1.removeFromParent();
				V2.removeFromParent();
			}
			
			V1 = VectorDisplay.display( new Vector(player.getVX(), player.getVY()), player.getX(), player.getY() );
			player.hitBounce();
			V2 = VectorDisplay.display( new Vector(player.getVX(), player.getVY()), player.getX(), player.getY() );
			
			if(zeroVel)
				running = false;
			
			addChild(V1);
			addChild(V2);
		}
		
		player.applyVelocity(modifier);
	}
	
	/** Used to detect clicks */
	private function onTouch( event:TouchEvent ){
		var touch:Touch = event.touches[0];
		if(touch.phase == "ended"){
			spawnX = touch.globalX;
			spawnY = touch.globalY;
			_player.setLoc(spawnX,spawnY);
		}
		
		mouseX = touch.globalX;
		mouseY = touch.globalY;
	}
	
	/** Used to keep track of when a key is unpressed */
	private function keyUp(event:KeyboardEvent):Void{
	}
	
	var useRecorded = false;
	var recorded = {x:189.0,y:243.0,vx:4.82860975888604, vy:4.82860975888604};
	var zeroVel = false;
	/** Used to keep track when a key is pressed */
	private function keyDown(event:KeyboardEvent){
		if(event.keyCode == 72){
			useRecorded = !useRecorded;
			trace("RECORDING: " + useRecorded);
		}
		if(event.keyCode == 71){
			running = !running;
		}
		
		if(event.keyCode == 70){
			running = true;
			zeroVel = !zeroVel;
			trace(zeroVel);
		}

		if(event.keyCode == 32){
			running = true;
			haxe.Log.clear();
			player.setLoc(spawnX,spawnY);
			
			var vector = Vector.getVector(player.getX(), player.getY(), mouseX, mouseY);
			vector.normalize().multiply(10);
			player.setVelocity(vector.vx, vector.vy);
			
			if(useRecorded){
				player.setLoc(recorded.x, recorded.y);
				player.setVelocity(recorded.vx, recorded.vy);
			}
			
			recorded = {x:player.getX(), y:player.getY(), vx:player.getVX(), vy:player.getVY()};
			
			trace(player.getX() + " " + player.getY());
			trace(player.getVX() + " " + player.getVX());
		}
	}
	
	/** Main method, used to set up the initial game instance */
    public static function main() {
		// Frame rate the game ~should~ run at
		
        try {
			// Attempt to start the game logic 
			var starling = new starling.core.Starling(Lines, flash.Lib.current.stage);
			starling.showStats = true;
            globalStage = starling.stage; 
			starling.start();  
        } catch(e:Dynamic){
            trace(e);
        }
    }
}