package app.view {
    import app.ApplicationFacade;    

    import org.puremvc.interfaces.IMediator;    
    import app.Main;
    import app.view.components.*;
    
    import com.bumpslide.events.UIEvent;
    
    import app.model.StageProxy; 

    /**
     * A Mediator for interacting with the top level Application
     */
    public class ApplicationMediator extends BaseMediator implements IMediator
    {
        // Cannonical name of the Mediator
        public static const NAME:String = "ApplicationMediator";
        
        /**
         * Constructor. 
         *  
         * @param object the viewComponent (root display object in this case)
         */
        public function ApplicationMediator( viewComponent:Object ) 
        {
           trace("Application Mediator Loaded");
		   
		   // pass the viewComponent to the superclass
            super( NAME, viewComponent );            
            
            // wait for views to be created
            viewComponent.addEventListener( BottomMenu.EVENT_CREATION_COMPLETE, registerChildMediators );
			viewComponent.addEventListener( Save.EVENT_CREATION_COMPLETE, registerChildMediators );
			viewComponent.addEventListener( VideoArea.EVENT_CREATION_COMPLETE, registerChildMediators );
			viewComponent.addEventListener( TopMenu.EVENT_CREATION_COMPLETE, registerChildMediators );
			
			
        }
        
        /**
         * Register addition mediators once child components have been initialized
         */
        private function registerChildMediators(event:UIEvent):void
        {        	
			
			if(event.data.name == "bottom_menu_mc"){
				var bottom_menu_mc:BottomMenu = event.data as BottomMenu;			
        				
				// register child mediators            
				facade.registerMediator( new BottomMenuMediator( bottom_menu_mc ) );
				
				// trigger stage update
				sendNotification( ApplicationFacade.CMD_STAGE_UPDATE );
			}
			
			if(event.data.name == "save_mc"){
				var save_mc:Save = event.data as Save;			
        				
				// register child mediators            
				facade.registerMediator( new SaveMediator( save_mc ) );
				
				// trigger stage update
				sendNotification( ApplicationFacade.CMD_STAGE_UPDATE );
			}
			
			if(event.data.name == "video_area_mc"){
				var video_area_mc:VideoArea = event.data as VideoArea;			
        				
				// register child mediators            
				facade.registerMediator( new VideoAreaMediator( video_area_mc ) );
				
				// trigger stage update
				sendNotification( ApplicationFacade.CMD_STAGE_UPDATE );
			}
			
			if(event.data.name == "top_menu_mc"){
				var top_menu_mc:TopMenu = event.data as TopMenu;
			
        				
				// register child mediators            
				facade.registerMediator( new TopMenuMediator( top_menu_mc ) );
				
				// trigger stage update
				sendNotification( ApplicationFacade.CMD_STAGE_UPDATE );
			}
			
			
			
        }        
    }
}
