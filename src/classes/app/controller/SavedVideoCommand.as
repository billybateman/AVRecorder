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
		
		import gs.GUID;
		
		
	
		public class SavedVideoCommand extends SimpleCommand implements ICommand
		{
			/* 
				When this runs we have initialised the framework and its players.
				Let's grab a proxy and connect to FMS.			
			 */
			override public function execute( note:INotification ):void
			{			
				// send something to the trace window
				sendNotification( ApplicationFacade.LOG, "Saved Video Command: Execute");
				
				/* Get the user from the local proxy 
				var javascriptProxy:JavascriptProxy = facade.retrieveProxy(JavascriptProxy.NAME ) as JavascriptProxy;
				javascriptProxy.saveVideo(note.getBody());*/
				
				/* Get the user from the local proxy */
				var localProxy:LocaleProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;
				var locale:Object = localProxy.getLocale() as Object;						
				
				if(locale.fileGenerated == "true"){					
					// Generate Guid
					var guid = new GUID();
					locale.file = guid.create(40);
					trace("Generate new file name: " + locale.file);
					localProxy.setLocale(locale);
					
				}							
				
				var str:String =  note.getBody() as String;
				 
				sendNotification( ApplicationFacade.VIDEO_SAVED_CALL, str );
				
			}
		
		}
		
	}