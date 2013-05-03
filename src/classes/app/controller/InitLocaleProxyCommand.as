package app.controller
	{
		
		    
		import org.puremvc.interfaces.*;
		import org.puremvc.patterns.command.*;
		import org.puremvc.patterns.observer.*;
		
		import app.model.*;
		import app.view.ApplicationMediator;
		import app.ApplicationFacade;
		import app.Main;
		
		import flash.events.*;
		import flash.net.URLRequest;
		import flash.net.URLLoader;
		import flash.net.URLRequestHeader;
		import flash.net.URLRequestMethod;
		
		import gs.GUID;
	
		public class InitLocaleProxyCommand extends SimpleCommand implements ICommand
		{
			/* 
				When this runs we have initialised the framework and its players.
				Let's grab a proxy and connect to FMS.			
			 */
			override public function execute( note:INotification ):void
			{			
								 
				var locale:Object = note.getBody() as Object;
				
			    sendNotification( ApplicationFacade.LOG, "InitLocaleProxy Command: " + locale);
				
				if(!locale.applicationView){
					locale.applicationView = "player";
				}
				
				if(!locale.user){
					locale.user = "bbateman";
				}
				
				if(!locale.file){					
					// Generate Guid
					var guid = new GUID();
					locale.file = guid.create(40);
					locale.fileGenerated = "true";
				} else {
					locale.fileGenerated = "false";
				}
				
				if(!locale.record_length){
					locale.record_length = 1200;
				}
				
				if(!locale.volume_level){
					locale.volume_level = 0.8;
				}
				
				if(!locale.saveOption){
					// Two options
					// 1. javascript, 2. serviceUrl					
					locale.saveOption = "javascript";
				}
				
				if(!locale.serviceUrl){
					locale.serviceUrl = "";
				}
				
				if(!locale.basePath){
					locale.basePath = "";
				}
				
				if(!locale.autoStart){
					locale.autoStart = "false";
				}
				
				facade.registerProxy( new LocaleProxy( LocaleProxy.NAME, locale ) );  
				
			}
		
		}
		
	}