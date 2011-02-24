/*
 * Copyright 2007-2009 (c) Donovan Adams, http://blog.hydrotik.com/
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

package com.hydrotik.parallelloader {
	import flash.net.URLRequest;	
	import flash.events.Event;

	/**
	 * @author Donovan Adams | Hydrotik | http://blog.hydrotik.com
	 * @version: 0.1.0
	 */
	public class ParallelLoaderEvent extends Event {

		// Event types
		public static var ITEM_START : String = "itemStart";

		public static var ITEM_PROGRESS : String = "itemProgress";

		public static var ITEM_COMPLETE : String = "itemComplete";

		public static var ITEM_ERROR : String = "itemError";

		public static var ITEM_HTTP_STATUS : String = "itemHTTPStatus";
		
		public static var START : String = "start";

		public static var PROGRESS : String = "progress";

		public static var COMPLETE : String = "complete";


		// Public properties
		public var container : *;
		
		public var targ : *;

		public var content : *;

		public var title : String = "";

		public var fileType : int;
		
		public var currItem : ILoadable;

		public var path : URLRequest;

		public var bytesLoaded : Number = -1;

		public var bytesTotal : Number = -1;	

		public var percentage : Number = 0;

		public var index : int;	

		public var length : int;
		
		public var bandwidth:Number;

		public var queueBytes:Number;

		public var width : Number;

		public var height : Number;

		public var message : String = "";

		public var bmArray : Array;

		public var info : Object = null;
		

		public function ParallelLoaderEvent( type : String, currItem:ILoadable, bytesTotal:Number, bytesLoaded:Number, percentage:Number, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
			this.currItem = currItem;
			this.percentage = percentage;
			this.bytesTotal = bytesTotal;
			this.bytesLoaded = bytesLoaded;
			this.bandwidth = bandwidth;
			if(currItem){
				this.title = currItem.title;
				this.width = currItem.width;
				this.height = currItem.height;
			}
		}
	}
}