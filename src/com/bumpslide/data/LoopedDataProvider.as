package com.bumpslide.data {        /**     * @author David Knape     */    public class LoopedDataProvider {    	    	var data:Array;    	    	private static const LENGTH:Number = 9999999;    	    	public function LoopedDataProvider( a:Array ) {    		data = a;    	}    	    	    	public function getItemAt(n:int) : * {    		if(data.length==0) return undefined;    		return data[ n%data.length ];    	}    	    	public function get length () : Number {    	    		return LENGTH;        }    }}