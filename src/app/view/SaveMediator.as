package app.view {

    import org.puremvc.interfaces.IMediator;
    import org.puremvc.interfaces.INotification;
    
       
    import app.ApplicationFacade;    
	import app.model.*;
    import app.view.events.*;
    import app.view.components.*;
    
    import com.bumpslide.events.UIEvent;
	
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.NetStream;
	import flash.media.*;
	import flash.utils.Timer;
	
	import gs.*;
	
    /**
     * Mediator for Save
     * 
     * @author Billy Bateman
     */
    public class SaveMediator extends BaseMediator implements IMediator {
        
       public static const NAME:String = "SaveMediator";
       
	   public var nc:NetConnection = new NetConnection;		 
	   
	   public var stageHeight:Number;
	   public var savey:Number;
	   
	   public var saveOpen:String = "false";
		
       public function SaveMediator(viewComponent:Object = null)
        {
            
			trace("Save Mediator Loaded");
			
			super(NAME, viewComponent);            
            
			save.addEventListener( ApplicationFacade.VIDEO_SAVE_CMD, onVideoSaveNotification );
        }
		
		/* Video Publish Notification */
		private function onVideoSaveNotification( e:GenericEvent ):void
		{		
			
			if(e.data == "true"){
				sendNotification( ApplicationFacade.VIDEO_SAVE_CMD, "true");
			}
			
			savey = stageHeight + save.height + 24;
			
			TweenLite.to(save, 1, {x:save.x, y:savey});
			
			saveOpen = "false";
			
		}
		
				
		private function connectUI(){
			trace("Connect UI");			
						
		}		
		        
        /**
         * viewComponent cast to appropriate type
         */
        public function get save() : Save {
            return viewComponent as Save;
        }
        
        /**
         * List all notifications this Mediator is interested in.
         * 
         * @return Array the list of Nofitication names
         */
        override public function listNotificationInterests():Array 
        {
            return [
               
                ApplicationFacade.STAGE_RESIZE,
				ApplicationFacade.NET_CONNECTION,				
				ApplicationFacade.VIDEO_RECORD_CALL,
				ApplicationFacade.VIDEO_SAVED_CALL
            ];            
        }

        /**
         * Handle all notifications this Mediator is interested in.
         * 
         * @param INotification a notification 
         */
        override public function handleNotification( note:INotification ):void 
        {
            switch ( note.getName() ) 
            {
               
                case ApplicationFacade.STAGE_RESIZE:
                    	var stage:StageProxy = note.getBody() as StageProxy;
                    	
						stageHeight = stage.stageHeight;
						
						if(saveOpen == "true"){
							save.y = stageHeight - save.height - 24;
						} else {
							save.y = stageHeight + save.height + 24;
						}
						
						if(stage.stageWidth > save.width){
							save.x = ( stage.stageWidth / 2 ) - ( save.width / 2 ) ;
						}						
						
						save.setSize( stage.stageWidth, stage.stageHeight );					
                    break;				
				case ApplicationFacade.NET_CONNECTION:
					nc = note.getBody() as NetConnection;					
					connectUI();
					break;				
				case ApplicationFacade.VIDEO_RECORD_CALL:
					//save.VideoSavedCall();
					var recordStr = note.getBody() as String;
						
					if(recordStr == "false"){
						saveOpen = "true";
						var newy = stageHeight - 24 - save.height;
						TweenLite.to(save, 1, {x:save.x, y:newy});
					} else {
						if(saveOpen == "true"){
							saveOpen = "false";
							savey = stageHeight + save.height + 24;
							TweenLite.to(save, 1, {x:save.x, y:savey});		
						}
					}
					break;
				
				case ApplicationFacade.VIDEO_SAVED_CALL:
					//save.VideoSavedCall();
					var savedStr = note.getBody() as String;
						
					if(saveOpen == "true"){
						saveOpen = "false";
						savey = stageHeight + save.height + 24;
						TweenLite.to(save, 1, {x:save.x, y:savey});		
					}
					
					trace(savedStr);
					
					break;
					
                default:
                    break;
            }
        }       
        
    }
}