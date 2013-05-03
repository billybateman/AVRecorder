package com.bumpslide.events
{
	import flash.events.Event;

	/**
	 * Custom Event for service results
	 * 
	 * @author David Knape
	 */
	public class ServiceEvent extends Event
	{
		
		private var _params:Array;
		private var _result:Object;
		
		public function ServiceEvent( type:String, service_result:Object=null, input_params:Array=null ) {
			super(type, false, false);
			_params = input_params==null ? new Array() : input_params;
			_result = service_result==null ? new Object() : service_result;			
		}
		
		/**
		* 	This object contains data loaded in response
		* 	to remote service calls
		*/
		public function get result():Object
		{
			return _result;
		}

		/**
		 * This is an array of parameters that were sent as 
		 * input to the remote service (optional)
		 */
		public function get params():Array
		{
			return _params;
		}
		
		override public function toString() : String {
			return '[ServiceEvent:'+this.type+'] ';
		}
	}
}