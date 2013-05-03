package com.bumpslide.util {
		
	import com.bumpslide.util.*;
	import flash.utils.*;
	
	//import org.asapframework.util.framepulse.*;
	
	/**
	* FTween 
	* 
	* FTween is a target-based tweening utility. 
	*
	* 
	* <p>Simple usage:
	*   FTween.ease( my_mc, '_x', 200 );
	* 
	* <p>Tweening multiple properties:
	*   FTween.spring( my_mc, ['_x', '_y'], [_xmouse, _ymouse]);
	* 
	* <p>Adjusting config options:
	*   var ft:FTween = FTween.ease( my_mc, '_rotation', 45.6 );
	*   ft.KEEP_ROUNDED = false;
	* 
	* <p>Stopping Tweens:
	*   FTween.stopTweening( my_mc ); // stops all tweens
	*   FTween.stopTweening( my_mc, '_x' ); // stops _x tweens
	* 
	* see com.bumpslide.example.ftween for more examples
	* 
	* @author David Knape
	*/
	
	public class FTween extends Object{
			
		/**
		* Tweens movie clips properties using simple easing
		* 
		* @param	obj
		* @param	obj props
		* @param	obj targets
		* @param	easeFactor
		*/
		static public function ease( obj:Object, props:*, targets:*, easeFactor:Number=.3 ) : FTween {		
			var tweener:FTween = FTween.getInstance( obj );
			tweener.tween(props, targets, FTween.defaultEasing, easeFactor);
			return tweener;
		}
		
		/**
		* Tweens using a spring behavior
		* 
		* @param	obj
		* @param	obj props
		* @param	obj targets
		* @param	springValue
		* @param	friction
		*/
		static public function spring( obj:Object, props:*, targets:*, springValue:Number=.3, friction:Number=.3 ): FTween {	
			var tweener:FTween = FTween.getInstance( obj );
			tweener._enforceMinVeloc = true;
			tweener.tween(props, targets, FTween.springing, springValue, friction);
			return tweener;
		}	
		
		/**
		* Tweens at a flat rate
		* 
		* @param	obj
		* @param	obj props
		* @param	obj targets
		* @param	speed
		*/
		static public function linear( obj:Object, props:*, targets:*, speed:Number=.3): FTween {	
			var tweener:FTween = FTween.getInstance( obj );
			tweener.tween(props, targets, FTween.linearEasing, speed);
			return tweener;
		}	
			
		/**
		* Smooth easing for scrollbars and such
		* 
		* Uses easing, but caps the speed at a given max. 
		* 
		* @param	obj
		* @param	obj props
		* @param	obj targets
		* @param	easeFactor
		* @param	max velocity
		*/
		static public function smooth( obj:Object, props:*, targets:*, easeFactor:Number=.3, maxVeloc:Number=100 ): FTween {		
			var tweener:FTween = FTween.getInstance( obj );
			tweener.tween(props, targets, FTween.smoothEasing, easeFactor, maxVeloc);
			return tweener;
		}
			
		/**
		 * Stop any tweens on an obj
		 * optional param (prop) triggers a tween stop of only that property 
		 * returns false if obj was not being tweened
		 */
		static public function stopTweening(obj:Object, prop:String) : Boolean {	
			var ft: FTween = FTween.getInstance( obj );
			if(ft == null || ft._isTweening==false) {
				//trace('not tweening '+obj);
				return false;
			} else {
				ft.stop( prop );
				return true;
			} 
			
			
		}
		
		/**
		* whether or not a clip is tweening
		* 
		* @param	obj
		* @return
		*/
		static public function isTweening( obj:Object ) : Boolean {
			return FTween.getInstance( obj )._isTweening==true;
		}
		
		/**
		* There is only one tweener allowed per movie clip
		* 
		* This function is used by the static public functions to get that instance
		* 
		* @param	obj
		*/
		static private function getInstance(obj:Object):FTween {
			if(obj==null) {
				return null;
			}
			var ft_instance:* = obj[INSTANCE_NAME];		
			if(ft_instance==null) ft_instance = new FTween( obj );
			return ft_instance;
		}	
	
		
		
		//--------------------------------
		// The actual Easing Functions
		//--------------------------------
		
		// easing function should return actual delta (new velocity)
		static private function defaultEasing( current:Number, target:Number, veloc:Number, params:* ) : Number {		
			var easeFactor:Number = params[0]!=null ? params[0] : 0.3; 
			return (target-current) * easeFactor;
		}
		
		// easing function should return actual delta (new velocity)
		static private function smoothEasing( current:Number, target:Number, veloc:Number, params:* ) : Number {		
			var delta:Number = FTween.defaultEasing.apply(null, arguments);
			var maxDelta:Number = params[1]!=null ? params[1] : Number.MAX_VALUE; 
			//return Math.min(maxDelta, delta);
			
			if(delta>0) return Math.min( delta, maxDelta );
			else return Math.max( delta, -maxDelta );
		}	
		
		// easing function should return actual delta (new velocity)
		static private function springing( current:Number, target:Number, veloc:Number, params:*) : Number {		
			var spring:Number   = params[0]!=null ? params[0] : 0.3; 
			var friction:Number = params[1]!=null ? params[1] : 0.3;		
			veloc += (target-current) * spring;
			veloc *= (1-friction);		
			return veloc;
		}
		
		// easing function should return actual delta (new velocity)
		static private function linearEasing( current:Number, target:Number, veloc:Number, params:* ) : Number {		
			var d:Number = (target-current);
			var speed:Number = (params[0]!=null) ? params[0] : 10;
			//Debug.trace('speed  = '+speed);
			if(d>0) return Math.min( d, speed );
			else return Math.max( d, -speed );
		}
		
		// easing function should return actual delta (new velocity)
		static private function gravitation( current:Number, target:Number, veloc:Number, params:* ) : Number {
			
			/**
			* Problem with similuating gravitation using FTween:
			* 
			* FTween operates on all properties independently.
			* Accurately representing gravity on a movieclip
			* requires calculating the actual distance using both X and Y
			* in this loop, we only have access to one at a time.  
			*  
			*  
			*/
			
			var objectMass:Number = params[0]!=null ? params[0] : 2; 
			var targetMass:Number = params[1]!=null ? params[1] : 5;
			var K:Number = 100;
			
			var dist:Number = target-current;		
			var grav:Number = K * objectMass * targetMass / Math.pow(dist,2);    		
			var accel:Number = grav/objectMass;		
			
			var direction:Number = dist/Math.abs(dist);		
					
			veloc += accel*direction;		
			
			// Keep us from overshotting our target
			if(direction>0) {
				veloc = Math.min( dist, veloc );
			} else {
				veloc = Math.max( dist, veloc );
			}
			
			return veloc;		
		}
		
		
		
		
		//--------------------------------
		// The class code
		//--------------------------------
		
	
		// configuration options	
		//var MAX_FRAMES = 100;
		public var MIN_DELTA:Number = .5;
		public var MIN_VELOC:Number = .5;
		public var KEEP_ROUNDED:Boolean = true;
		//var USE_FRAMES = false;
		public var UPDATE_MS:int = 30;
		public var MAX_TWEEN_TIME:int = 20000;
		
		static private var INSTANCE_NAME : String = "__bumpslide_ftween";
		
		private var _isTweening : Boolean = false;
		private var _frameCount:int = 0;
		private var _obj : Object;
		private var _tweens : Object;
		private var _efDelegate : Function ;
		private var _updateInt:int = -1;
		private var _timeoutInt:int = -1;
		private var _enforceMinVeloc:Boolean = false;
		
		// AsBroadcaster Mix-ins
//		private var broadcastMessage:Function;
//		public var addListener:Function;
//		public var removeListener:Function;
//		
		static private var lastTweenID:Number=1111;
		private var _tweenID:Number = 0;
		
		//static var isBroadcaster = AsBroadcaster.initialize( FTween.prototype );
		
		// CTOR
		public function FTween(obj:Object) {
			
			//AsBroadcaster.initialize( this );
			
			// link obj to tweener
			_obj = obj;
			
			// cancel any old tweens on this clip
			_obj[INSTANCE_NAME].stop();
			
			_obj[INSTANCE_NAME] = this;
			
			_tweenID = FTween.lastTweenID++;
			_tweens = {};
			
			//this.addListener( _obj );
			
		}
		
		public function tween(props:*, targets:*, easingFunc:Function, ...params ):FTween {
	
			_isTweening = true;
			
			if(easingFunc==null) easingFunc = defaultEasing;
		
			// turn single values into arrays if they are not already (hacky)
			if(props.push == undefined) props = [props];
			if(targets.push == undefined ) targets = [targets];
			
			for(var n in props) {
				
				// make sure our target is not undefined
				if(targets[n]!=undefined) {
					
					// maintain current tweeen velocity if already tweening
					var currentVeloc:Number = (_tweens[ props[n] ]!=undefined)  ? _tweens[ props[n] ].veloc : 0;
					var currentValue:Number = (_tweens[ props[n] ]!=undefined)  ? _tweens[ props[n] ].current : _obj[props[n]];
					// replace any existing tween for that property
					_tweens[ props[n] ] = {
						current: currentValue,
						target: targets[n],
						veloc: currentVeloc,
						easingFunc: easingFunc,
						params: params	
						
					};
				}
				
			}
	
			// reset frame count (safeguard for runaway tweens)
			_frameCount = 0;
			
			//if(0 && USE_FRAMES) {
				//warn('using frames');
				//FramePulse.getInstance().addEventListener(FramePulseEvent.ON_ENTERFRAME, this);
			//} else {
				clearInterval(_updateInt);
			//	_updateInt = setInterval( this, 'onEnterFrame', UPDATE_MS);
			//}		
			onEnterFrame();		
				
			
			// no tween should take longer than this
			clearInterval( _timeoutInt );
			_timeoutInt = setInterval( tweenTimeout, MAX_TWEEN_TIME);
			
			return this;
		}
		
		/**
		* Stops tweening a specific property, or all properties
		* if no property name is given
		* 
		* @param	propName
		*/
		public function stop(propName:String=null):void {
			if(propName!=null) {
				stopTween( propName );
			} else {
				reset();
			}
		}
		
		
			
		private function onEnterFrame():void {
			
			//debug( 'doTween '+_obj._name);
			var tw:Object; // tween data
			var tweenCount:int = 0;
			
			_frameCount++;
			
			for( var prop in _tweens) {
				
				++tweenCount;
				
				tw = _tweens[prop];
				var previousVelocity:Number = tw.veloc;
				tw.veloc = tw.easingFunc.call( null, tw.current, tw.target, tw.veloc, tw.params );
				tw.current += tw.veloc;		
				
				_obj[prop] = (KEEP_ROUNDED) ? Math.round(tw.current) : tw.current;
	
				//debug( 'changing '+prop+' to '+_obj[prop]+' (delta='+tw.veloc+')');
				
				// check to see if we should finish up
				if	( 
						// if we are close and not moving very fast
						(
							Math.abs(tw.target-_obj[prop]) <= MIN_DELTA  
								&& 	
							(!_enforceMinVeloc || Math.abs(tw.veloc) <= MIN_VELOC)
						)   
						//	|| 
						
						// or if we are taking longer than expected
						//(_frameCount>MAX_FRAMES && warn('Exceeded max frames '+MAX_FRAMES) )
							||
						
						// or if we aren't moving
						(tw.veloc == 0 && previousVelocity==0  && warn('Stopped outside min delta') )
				)
				{
					// complete this tween
					_obj[prop] = tw.target;
					stopTween( prop );
					//broadcastMessage( 'onTweenComplete'+prop );
				}
					
				// _obj[prop] = Math.round( _obj[prop] );	
						
				//updateAfterEvent();
			}	
			
			// this hurts performance.  It's better to just check values using local
			// onEnterFrame loops
			//broadcastMessage('onTweenUpdate', _obj, _tweens);
			
			if(tweenCount==0) {
				debug('onTweenComplete');
				//broadcastMessage('onTweenComplete', _obj);
				reset();
				return;
			}		
			
			clearInterval(_updateInt);
			_updateInt = setInterval( onEnterFrame, UPDATE_MS);
			
		}	
		
	
		private function stopTween(propName:String):void  {
			delete _tweens[propName];
		}
		
		private function reset(): void  {
			_frameCount=0;
			clearInterval(_updateInt);
			clearInterval( _timeoutInt );
			//FramePulse.getInstance().removeEventListener(FramePulseEvent.ON_ENTERFRAME, this);
			_isTweening = false;
			//delete _obj[FTween.EFCLIP_NAME].onEnterFrame;
			_tweens = {};
		}
		
		private function debug( msg:String ) : void  {
			trace(this+'('+_obj._name+') '+ msg );
		}
		
		private function warn( msg:String ): Boolean  {
			trace(this+'('+_obj._name+') '+ msg );
			return true;
		}
		
		private function tweenTimeout(): void  {
			clearInterval(this._timeoutInt);
			for( var prop in _tweens) {
				_obj[prop] = _tweens[prop].target;
			}
			reset();
			warn('Tween Timed out - extend MAX_TWEEN_TIME if this is in error');
		}
		
		public function toString () : String {
			return '[FTween '+this._tweenID+'] ';
		}
		
		
		
	}
}