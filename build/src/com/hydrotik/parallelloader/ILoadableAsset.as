/*
* Copyright 2007-2011 (c) Donovan Adams, http://blog.hydrotik.com/
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

	/**
	 * @author Donovan Adams | Hydrotik | http://blog.hydrotik.com
	 * @version 0.1.0
	 * @exampleText Provides a forward facing access point for loaded items to the developer
	 */
	public interface ILoadableAsset {
		function get percentage():Number;
		function get bytesLoaded():int;
		function get bytesTotal():int;
		function get target():*;
		function get container():*;
		function get message():String;
		function get path():URLRequest;
		function get title():String;
		function set index(i:int):void;
		function get index():int;
		function set isLoading(b:Boolean):void;
		function get isLoading():Boolean;
		function set isLoaded(b:Boolean):void;
		function get isLoaded():Boolean;
		function get width() : Number;
		function get height() : Number;
	}
}
