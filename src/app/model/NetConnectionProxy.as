	
	package app.model
	{
		import flash.events.AsyncErrorEvent;
		import flash.events.IOErrorEvent;
		import flash.events.NetStatusEvent;
		import flash.events.SecurityErrorEvent;
		import flash.net.NetConnection;
		import flash.net.ObjectEncoding;
		import flash.net.NetStream;
		import flash.media.Video;
		
		import org.puremvc.patterns.observer.Notification;
		import org.puremvc.patterns.proxy.Proxy;
		import org.puremvc.interfaces.IProxy;
	
		import flash.external.ExternalInterface;
		import flash.events.Event;
		import flash.events.TimerEvent;
	
		import app.ApplicationFacade;
				
		
		public class NetConnectionProxy extends Proxy implements IProxy
		{
			public static const NAME:String = "NetConnectionProxy";
			
			
			private var nc:NetConnection;
			private var connected:Boolean;
			private var ns:NetStream;
			
			
			public function NetConnectionProxy()
			{
				super( NAME );
			}
			
			public function onRegister():void
			{	
				
				sendNotification( ApplicationFacade.LOG, "Net Connection Proxy: Registered" );
				
				// set to AMF0 in order to work with FMS2. FMS3 will not need this line.
				NetConnection.defaultObjectEncoding = flash.net.ObjectEncoding.AMF0;
			}
			
			public function getNetConnection():NetConnection {
				return nc;
			}
			
			public function connect( rtmp:String, user:String ):void
			{
				var msg:String = "Net Connection Proxy: Connect(" + rtmp + "," + user + ")";				
				sendNotification( ApplicationFacade.LOG, msg );			
				
				nc = new NetConnection();
				
				nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
	    		nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	    		nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
	    		
	    		nc.connect( rtmp, user );				
				nc.client = this;
				
			}
						
			public function disconnect():void
			{
				var msg:String = "Net Connection Proxy: Disconnecting";				
				sendNotification( ApplicationFacade.LOG, msg );			
				
				nc.close();
				
				connected = false;
			}			
					
			// bandwidth check, this is sometimes needed to avoid runtime errors with some CDNs
			public function onBWDone ( ... arguments ):void
			{
				//var msg:String = "onBWDone: kbitDown = " + kbitDown + ", deltaDown= " + deltaDown + ", deltaTime = " + deltaTime + ", latency = " + latency;
			}
			
			public function onBWCheck ( e:* ):void
			{	
				var msg:String = "Net Connection Proxy: onBWCheck called";
				sendNotification( ApplicationFacade.LOG, msg );				
				return;
			}			
					
			// apparently we need this to avoid runtime error
			public function close():void
			{
				sendNotification( ApplicationFacade.LOG, "Net Connection Proxy: Server called close on us" );
			}
					
			private function netStatusHandler( e:NetStatusEvent ):void
			{
				
				var msg:String;
				sendNotification( ApplicationFacade.LOG, "Net Connection Proxy: " + e.info.code );
				
				switch ( e.info.code ) 
				{					
					case "NetConnection.Connect.Success":
					
			            msg = "Net Connection Proxy: connected successfully to " + NetConnection(e.target).uri;
           				sendNotification( ApplicationFacade.LOG, msg );     
           				      				
		            	connected = true;
		            	nc = NetConnection(e.target);
		            	// send a note passing NC so that we can use it to connect SharedObjects etc.
						sendNotification( ApplicationFacade.NETSTATUS, {nc:nc, status:"success"} );
						break;
					
					case "NetConnection.Connect.Rejected":
						msg = "Net Connection Proxy: NetConnection rejected";
						connected = false;
						sendNotification( ApplicationFacade.LOG, msg );
						break;
							
					case "NetConnection.Connect.Failed":
						msg = "Net Connection Proxy: NetConnection failed";
						connected = false;
						sendNotification( ApplicationFacade.LOG, msg );
						break;
				}			
			}
			
			private function securityErrorHandler( e:SecurityErrorEvent ):void
			{
				var msg:String = "Net Connection Proxy: Security error event " +e.toString();
				sendNotification( ApplicationFacade.LOG, msg );
			}
			
			protected function asyncErrorHandler(e:AsyncErrorEvent):void
			{
	           	var msg:String = "Net Connection Proxy: asyncErrorHandler " + e.error.message;
	           	sendNotification( ApplicationFacade.LOG, msg );
	       	}
				
	       	protected function IOErrorHandler(e:IOErrorEvent):void
			{
	           	var msg:String = "Net Connection Proxy: IOErrorHandler " + e.text;
	           	sendNotification( ApplicationFacade.LOG, msg );
	        }			
		}
	}