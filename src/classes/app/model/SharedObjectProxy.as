
package app.model
	{
		import org.puremvc.patterns.observer.Notification;
		import org.puremvc.patterns.proxy.Proxy;
		import org.puremvc.interfaces.IProxy;
	
		import flash.external.ExternalInterface;
		import flash.events.Event;
		import flash.events.TimerEvent;
	
		import app.ApplicationFacade;
		
		import flash.events.*;
		import flash.net.*;
				
	
		public class SharedObjectProxy extends Proxy implements IProxy
		{
			
			public static const NAME:String = "SharedObjectProxy";						
			
			private var users_so:SharedObject;
			public var user_list:Array;
			
			private var chat_so:SharedObject;
			public var chat_list:Array;
			
			private var banned_so:SharedObject;
			public var banned_list:Array;
			
			public function SharedObjectProxy()
			{
				super( NAME  );
				user_list = new Array();
				chat_list = new Array();
				banned_list = new Array();
			}
				
			
			public function connect( nc:NetConnection ):void
			{				
				users_so = SharedObject.getRemote( "users", nc.uri, false );
				users_so.addEventListener(SyncEvent.SYNC, userSync);	            		  		
		        users_so.addEventListener(NetStatusEvent.NET_STATUS, onSOnetStatus);	            			            		
				users_so.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSOSecurityError);
				users_so.client = this;
				users_so.connect( nc );
				
				chat_so = SharedObject.getRemote( "textChat", nc.uri, false );
				chat_so.addEventListener(SyncEvent.SYNC, chatSync);	            		  		
		        chat_so.addEventListener(NetStatusEvent.NET_STATUS, onSOnetStatus);	            			            		
				chat_so.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSOSecurityError);
				chat_so.client = this;
				chat_so.connect( nc );
				
				banned_so = SharedObject.getRemote( "bannedUsers", nc.uri, false );
				banned_so.addEventListener(SyncEvent.SYNC, bannedSync);	            		  		
				banned_so.addEventListener(NetStatusEvent.NET_STATUS, onSOnetStatus);	            			            		
				banned_so.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSOSecurityError);
				banned_so.client = this;
				banned_so.connect( nc );
				
				
				
			}
			
			private function userSync( e:SyncEvent ):void
			{
				sendNotification( ApplicationFacade.LOG, "onUserSyncEvent: " + e);
				
				var list:Array = e.changeList;	
				var results:Object = e.target.data;
				
				var user_list = results.userList;
				
											
				// you could do this user_list.removeAll(); and then dispatch the entire ArrayCollection...
				// but that can end up in a flicker of the whole userlist, especially if it contains images.				
				// Instead we only handle changes: clearing the list, clearing items, adding items
				
				// iterate over the changelist
				
				//var user_list = new Array();
				
				for ( var i:Number = 0; i < list.length; i++)
				{
					var info:Object = list[i];								
					
					if(info.name != undefined && info.name != "userId" && info.name != "undefined" && info.name != "userList"){
						trace("users onSync> changList #" + i + ", " + info.code + " " + info.name);						
						
						// Loop object
						var userName 	= results[info.name].userName;
						var audio 		= results[info.name].audio;
						var video 		= results[info.name].video;
						
						trace("User:" + userName + " audio:" + audio);							
					}
					
					if (info.code == 'clear')
					{
						// as an example:
						// sendNotification( ApplicationFacade.USERLIST_CLEAR );
					}
					else if (info.code == 'change')
					{				
						//trace("slot changed: " + info.name);
						
						// for example we could do this:
						//sendNotification( ApplicationFacade.USERLIST_SYNC, results[info.name] );
					}
					else if (info.code == 'delete')
					{
						//trace("slot deleted: user id (server id) " + info.name);
						// as an example:
						// sendNotification( ApplicationFacade.USER_DELETE, info.name );
					}
					else if (info.code == 'success')
					{
						//trace("slot success");					
					}
					else if (info.code == 'reject')
					{
						//trace("slot reject");
					}

				}
				
				trace("User List:" + user_list);
				
				// if you were to dispatch the entire ArrayCollection you'd do it here
				//sendNotification( ApplicationFacade.USER_SYNC, user_list );
			}
			
			private function chatSync( e:SyncEvent ):void
			{
				sendNotification( ApplicationFacade.LOG, "onChatSyncEvent: " + e);
				
				var chatlist:Array = e.changeList;	
				var chatresults:Object = e.target.data;
				
											
				// you could do this user_list.removeAll(); and then dispatch the entire ArrayCollection...
				// but that can end up in a flicker of the whole userlist, especially if it contains images.				
				// Instead we only handle changes: clearing the list, clearing items, adding items
				
				// iterate over the changelist
				
				//var user_list = new Array();
				
				for ( var i:Number = 0; i < chatlist.length; i++){
					
					var info:Object = chatlist[i];				
					
					if(info.name != undefined && info.name != "undefined" && info.name != "textId"){
						
						trace("chat onSync> changList #" + i + ", " + info.code + " " + info.name);						
						
						/* Loop object
						var userName 	= results[info.name].userName;
						var audio 		= results[info.name].audio;
						var video 		= results[info.name].video;
						*/						
					
						if (info.code == 'clear')
						{
							// as an example:
							// sendNotification( ApplicationFacade.USERLIST_CLEAR );
						}
						else if (info.code == 'change')
						{				
							//trace("slot changed: " + info.name);
							
							// for example we could do this:
							//sendNotification( ApplicationFacade.USERLIST_SYNC, results[info.name] );
						}
						else if (info.code == 'delete')
						{
							//trace("slot deleted: user id (server id) " + info.name);
							// as an example:
							// sendNotification( ApplicationFacade.USER_DELETE, info.name );
						}
						else if (info.code == 'success')
						{
							//trace("slot success");					
						}
						else if (info.code == 'reject')
						{
							//trace("slot reject");
						}
					}

				}
				
				
				// if you were to dispatch the entire ArrayCollection you'd do it here
				//sendNotification( ApplicationFacade.CHAT_SYNC, chat_list );
			}
			
			private function bannedSync( e:SyncEvent ):void
			{
				sendNotification( ApplicationFacade.LOG, "onBannedSyncEvent: " + e);
				
				var bannedlist:Array = e.changeList;	
				var bannedresults:Object = e.target.data;
				
											
				// you could do this user_list.removeAll(); and then dispatch the entire ArrayCollection...
				// but that can end up in a flicker of the whole userlist, especially if it contains images.				
				// Instead we only handle changes: clearing the list, clearing items, adding items
				
				// iterate over the changelist
				
				//var user_list = new Array();
				
				for ( var i:Number = 0; i < bannedlist.length; i++){
					
					var info:Object = bannedlist[i];								
					
					if(info.name != undefined && info.name != "undefined" && info.name != "banList"){
						
						trace("banned onSync> changList #" + i + ", " + info.code + " " + info.name);						
						
						/* Loop object
						var userName 	= results[info.name].userName;
						var audio 		= results[info.name].audio;
						var video 		= results[info.name].video;
						*/						
					
						if (info.code == 'clear')
						{
							// as an example:
							// sendNotification( ApplicationFacade.USERLIST_CLEAR );
						}
						else if (info.code == 'change')
						{				
							//trace("slot changed: " + info.name);
							
							// for example we could do this:
							//sendNotification( ApplicationFacade.USERLIST_SYNC, results[info.name] );
						}
						else if (info.code == 'delete')
						{
							//trace("slot deleted: user id (server id) " + info.name);
							// as an example:
							// sendNotification( ApplicationFacade.USER_DELETE, info.name );
						}
						else if (info.code == 'success')
						{
							//trace("slot success");					
						}
						else if (info.code == 'reject')
						{
							//trace("slot reject");
						}
					}

				}
				
				
				// if you were to dispatch the entire ArrayCollection you'd do it here
				//sendNotification( ApplicationFacade.CHAT_SYNC, chat_list );
			}
					
			private function onSOnetStatus( e:NetStatusEvent ):void
			{
				sendNotification( ApplicationFacade.LOG, "onSOnetStatus: " + e);
			}
			
			private function onSOSecurityError( e:SecurityErrorEvent ):void
			{
				sendNotification( ApplicationFacade.LOG, "onSOnetStatus: " + e);
			}
		}
	}
	
	
	