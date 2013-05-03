package app.controller
	{
		
		import flash.net.NetConnection;
		import flash.display.DisplayObject;
    
		import org.puremvc.interfaces.*;
		import org.puremvc.patterns.command.*;
		import org.puremvc.patterns.observer.*;
		
		import app.model.*;
		import app.view.ApplicationMediator;
		import app.ApplicationFacade;
		import app.Main;
		
		
	
		public class SaveVideoCommand extends SimpleCommand implements ICommand
		{
			/* 
				When this runs we have initialised the framework and its players.
				Let's grab a proxy and connect to FMS.			
			 */
			override public function execute( note:INotification ):void
			{			
				// send something to the trace window
				sendNotification( ApplicationFacade.LOG, "Save Video Command: Execute");
				
				/* Get the user from the local proxy */
				var localProxy:LocaleProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;
				var flashVars:Object = localProxy.getLocale() as Object;				
				
				var save_option:String = flashVars.saveOption;			
				var service_url:String = flashVars.serviceUrl;
				
				var saveAction:String = note.getBody() as String;
				
				if(saveAction == "true"){
				
				
					/* Get user and stream_name from note  */
					var saveObject:Object = flashVars;
					
					if(save_option == "javascript"){
						var javascriptProxy:JavascriptProxy = facade.retrieveProxy( JavascriptProxy.NAME ) as JavascriptProxy;
						javascriptProxy.saveVideo(saveObject);
						
					} else {		
					
						/* save video through service url */
						var serviceProxy:ServiceProxy = facade.retrieveProxy( ServiceProxy.NAME ) as ServiceProxy;
						serviceProxy.saveVideo(service_url, saveObject );			
					
					}
				
				}
				
			}
		
		}
		
	}