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
		
		
	
		public class RecordVideoCommand extends SimpleCommand implements ICommand
		{
			/* 
				When this runs we have initialised the framework and its players.
				Let's grab a proxy and connect to FMS.			
			 */
			override public function execute( note:INotification ):void
			{			
				// send something to the trace window
				sendNotification( ApplicationFacade.LOG, "Record Video Command: Execute");
								
				sendNotification( ApplicationFacade.VIDEO_RECORD_CALL, note.getBody());
				
				if(note.getBody() == "false"){
					sendNotification( ApplicationFacade.VIDEO_PLAY_CALL, "true");
				}
				
			}
		
		}
		
	}