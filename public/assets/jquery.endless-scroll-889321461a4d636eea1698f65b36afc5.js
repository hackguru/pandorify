/**
 * Endless Scroll plugin for jQuery
 *
 * v1.4.2
 *
 * Copyright (c) 2008 Fred Wu
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */
/**
 * Usage:
 *
 * // using default options
 * $(document).endlessScroll();
 *
 * // using some custom options
 * $(document).endlessScroll({
 *   fireOnce: false,
 *   fireDelay: false,
 *   loader: "<div class=\"loading\"><div>",
 *   callback: function(){
 *     alert("test");
 *   }
 * });
 *
 * Configuration options:
 *
 * bottomPixels  integer          the number of pixels from the bottom of the page that triggers the event
 * fireOnce      boolean          only fire once until the execution of the current event is completed
 * fireDelay     integer          delay the subsequent firing, in milliseconds. 0 or false to disable delay.
 * loader        string           the HTML to be displayed during loading
 * data          string|function  plain HTML data, can be either a string or a function that returns a string
 * insertAfter   string           jQuery selector syntax: where to put the loader as well as the plain HTML data
 * callback      function         callback function, accepets one argument: fire sequence (the number of times
 *                                the event triggered during the current page session)
 * resetCounter  function         resets the fire sequence counter if the function returns true, this function
 *                                could also perform hook actions since it is applied at the start of the event
 * ceaseFire     function         stops the event (no more endless scrolling) if the function returns true
 *
 * Usage tips:
 *
 * The plugin is more useful when used with the callback function, which can then make AJAX calls to retrieve content.
 * The fire sequence argument (for the callback function) is useful for 'pagination'-like features.
 */
(function(a){a.fn.endlessScroll=function(b){var c={bottomPixels:50,fireOnce:!0,fireDelay:150,loader:"<br />Loading...<br />",data:"",insertAfter:"div:last",resetCounter:function(){return!1},callback:function(){return!0},ceaseFire:function(){return!1}},b=a.extend(c,b),d=!0,e=!1,f=0;b.ceaseFire.apply(this)===!0&&(d=!1),d===!0&&a(this).scroll(unlimited_scroll=function(){if(this==document)var c=a(document).height()-a(window).height()<=a(window).scrollTop()+b.bottomPixels;else{var d=a(".endless_scroll_inner_wrap",this);d.length==0&&a(this).wrapInner('<div class="endless_scroll_inner_wrap" />');var c=d.length>0&&d.height()-a(this).height()<=a(this).scrollTop()+b.bottomPixels}if(b.ceaseFire.apply(this)===!1&&c&&(b.fireOnce==0||b.fireOnce==1&&e!=1)){b.resetCounter.apply(this)===!0&&(f=0),e=!0,f++,a(b.insertAfter).after('<div id="endless_scroll_loader">'+b.loader+"</div>"),data=typeof b.data=="function"?b.data.apply(this):b.data;if(data!==!1){a("div#endless_scroll_loader").remove(),a(b.insertAfter).after('<div id="endless_scroll_data">'+data+"</div>"),a("div#endless_scroll_data").hide().fadeIn(),a("div#endless_scroll_data").removeAttr("id");var g=new Array;g[0]=f,b.callback.apply(this,g),b.fireDelay!==!1||b.fireDelay!==0?(a("body").after('<div id="endless_scroll_marker"></div>'),a("div#endless_scroll_marker").fadeTo(b.fireDelay,1,function(){a(this).remove(),e=!1})):e=!1}}})}})(jQuery)