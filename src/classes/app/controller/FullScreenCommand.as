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
		
		
	
		public class FullScreenCommand extends SimpleCommand implements ICommand
		{
			/* 
				When this runs we have initialised the framework and its players.
				Let's grab a proxy and connect to FMS.			
			 */
			override public function execute( note:INotification ):void
			{			
				// send something to the trace window
				sendNotification( ApplicationFacade.LOG, "Full Screen Command: Execute");
								
				/* Get the user from the local proxy */
				var stageProxy:StageProxy = facade.retrieveProxy( StageProxy.NAME ) as StageProxy;
				stageProxy.toggleFullScreen();			
				
				sendNotification( ApplicationFacade.FULL_SCREEN_CALL, null);
			}
		
		}
		
	}