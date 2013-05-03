package app.view {    import org.puremvc.patterns.mediator.Mediator;    import org.puremvc.interfaces.IMediator;        /**     * Base class for all mediators in this app     *      * This gives us a place to put some app-specific shortcuts.     *      * @author David Knape     */    public class BaseMediator extends Mediator implements IMediator {                public static const NAME:String = "BaseMediator";                private var _name:String = "";                public function BaseMediator(name:String, viewComponent:Object = null)        {            super(viewComponent);            _name = name;        }                /**         * References _name so, we don't have to declare this function in all our mediators         */        override public function getMediatorName():String         {                return _name;        }    }}