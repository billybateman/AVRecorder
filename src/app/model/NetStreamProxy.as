	
	package app.model
	{
		import flash.events.AsyncErrorEvent;
		import flash.events.IOErrorEvent;
		import flash.events.NetStatusEvent;
		import flash.events.SecurityErrorEvent;
		import flash.net.NetConnection;
		import flash.net.ObjectEncoding;
		import flash.net.NetStream;
		import flash.media.*;
		
		import org.puremvc.patterns.observer.Notification;
		import org.puremvc.patterns.proxy.Proxy;
		import org.puremvc.interfaces.IProxy;
	
		import flash.external.ExternalInterface;
		import flash.events.Event;
		import flash.events.TimerEvent;
	
		import app.ApplicationFacade;
				
		
		public class NetStreamProxy extends Proxy implements IProxy
		{
			public static const NAME:String = "NetStreamProxy";
			
			private var ns:NetStream;		
			
			
			public function NetStreamProxy()
			{
				super( NAME );
			}			
						
			public function connect( nc:NetConnection ):void
			{
				var msg:String = "Net Stream Proxy: Connect";				
				sendNotification( ApplicationFacade.LOG, msg );			
				
				ns = new NetStream ( nc ) ;
				ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler ) ;
				ns.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler ) ;
				ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler ) ;		
				
			}		
						
			public function getNetStream():NetStream {
				return ns;
			}			
			
			public function disconnect():void
			{
				var msg:String = "Net Stream Proxy: Disconnecting";				
				sendNotification( ApplicationFacade.LOG, msg );			
				
				ns.close();
			}		
			
					
			// apparently we need this to avoid runtime error
			public function close():void
			{
				sendNotification( ApplicationFacade.LOG, "Net Stream Proxy: Server called close on us" );
			}
			
			private function netStatusHandler(e:NetStatusEvent):void
			{
				trace("ns status : ", e.info.code);
				switch (e.info.code){
					case "NetStream.Play.Start" :						
						trace("ns started playing");
						
						break;
					case "NetStream.Play.Stop" :						
						trace("ns stopped playing");
						//sendNotification( ApplicationFacade.VIDEO_PLAY_CALL, "false" );
						break;
					case "NetStream.Play.UnpublishNotify" :						
						trace("ns unpublish notify");
						break;
					case "NetStream.Buffer.Full" :						
						trace("NS Buffer Full");
						//ns.bufferTime=expandedBufferLength;
						break;
					case "NetStream.Buffer.Empty":						
						//ns.bufferTime=startBufferLength;
						break;
					case "NetStream.Buffer.Flush":
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