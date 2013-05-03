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
	
		public class NetStatusCommand extends SimpleCommand implements ICommand
		{
			/* 
				This command runs everytime the NetConnection Proxy dispatches a status message.			
			*/
			 
			override public function execute( note:INotification ):void
			{
				// grab the content of the note, in this case an object with nc and status properties
				var status:String 			= Object(note.getBody()).status;
				var nc:NetConnection 		= Object(note.getBody()).nc;
								
				// send something to the trace window
				sendNotification( ApplicationFacade.LOG, "Net Status Command: " + status );
				
								
				if (status == "success")
				{					
					
					
					sendNotification( ApplicationFacade.NET_CONNECTION, nc );
				
					
				}
				

			}		
		}
	}