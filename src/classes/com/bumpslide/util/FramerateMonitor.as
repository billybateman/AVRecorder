package com.bumpslide.util {	    import flash.display.DisplayObject;    import flash.display.Sprite;    import flash.events.Event;    import flash.system.System;    import flash.text.TextField;    import flash.text.TextFormat;    import flash.text.GridFitType;    import flash.text.AntiAliasType;        import flash.utils.*;        /**     * FPS and Memory Monitor     *      * @author David Knape     */    public class FramerateMonitor extends Sprite {    	    	    	public var fpsField:TextField;    	public var memField:TextField;    			private var fpsCount:int = 0;		private var avgCount:int = 30;				private var previousTime:uint;  		private var alignFunc:Function;				// update fps every X frames		private static const UPDATE_FRAMES:int = 10; 		       	public function FramerateMonitor( textColor:Number=0xeeeeee, backgroundColor:Number=0x000000, backgroundAlpha:Number=.5, alignHandler:Function=null)        	{       		       		if(alignHandler==null) alignFunc = Align.right;       		else alignFunc = alignHandler;       		       		// draw background       		var bg:Sprite = new Sprite();       		bg.graphics.lineStyle( 1, textColor, backgroundAlpha );       		bg.graphics.beginFill(backgroundColor, backgroundAlpha );       		bg.graphics.drawRect( 0, 0, 52, 26);       		bg.graphics.endFill();       		bg.x = bg.y = 1;       		       		       		       		// draw text fields       		fpsField = new TextField();       		fpsField.width = 50;       		fpsField.height = 15;       		fpsField.x = 2;       		fpsField.y = 1;        		fpsField.selectable = false;       		fpsField.antiAliasType = AntiAliasType.ADVANCED;       		fpsField.gridFitType = GridFitType.PIXEL;      		       		      		       		memField = new TextField();       		memField.width = 50;       		memField.height = 15;       		memField.x = 2;       		memField.y = 12;          		memField.selectable = false;    		       		memField.antiAliasType = AntiAliasType.ADVANCED;       		memField.gridFitType = GridFitType.PIXEL;       		       		// add to stage       		addChild( bg );       		addChild( fpsField );       		addChild( memField );       		       		// format text fields       		var tf:TextFormat = new TextFormat('Verdana', 9, textColor );       		fpsField.defaultTextFormat = tf;       		memField.defaultTextFormat = tf;       		       		       		       		// update on enterframe       		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage );       		        }                private function onAddedToStage(e:Event) : void {           	stage.addEventListener( Event.RESIZE, onStageResize );                	addEventListener( Event.ENTER_FRAME, update );        	onStageResize();        }                private function onStageResize(e:Event=null) : void {        	alignFunc.apply( null, [this, stage.stageWidth-4] );        }        private function update(e:Event) : void {			var time:uint = getTimer();			fpsCount += time-previousTime;			if (avgCount < 1){				fpsField.text = String(Math.round(1000/(fpsCount/UPDATE_FRAMES))+" FPS");				avgCount = UPDATE_FRAMES;				fpsCount = 0;			}			avgCount--;			previousTime = time;						memField.text = Math.round(System.totalMemory/(1024*1024)) + " MB";		}        }}