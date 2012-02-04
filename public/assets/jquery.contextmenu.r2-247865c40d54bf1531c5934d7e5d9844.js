/*
 * ContextMenu - jQuery plugin for right-click context menus
 *
 * Author: Chris Domigan
 * Contributors: Dan G. Switzer, II
 * Parts of this plugin are inspired by Joern Zaefferer's Tooltip plugin
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *
 * Version: r2
 * Date: 16 July 2007
 *
 * For documentation visit http://www.trendskitchens.co.nz/jquery/contextmenu/
 *
 */
(function(a){function i(d,h,i,k){var l=f[d];e=a("#"+l.id).find("ul:first").clone(!0),e.css(l.menuStyle).find("li").css(l.itemStyle).hover(function(){a(this).css(l.itemHoverStyle)},function(){a(this).css(l.itemStyle)}).find("img").css({verticalAlign:"middle",paddingRight:"2px"}),b.html(e),!l.onShowMenu||(b=l.onShowMenu(i,b)),a.each(l.bindings,function(c,d){a("#"+c,b).bind("click",function(a){j(),d(h,g)})}),b.css({left:i[l.eventPosX],top:i[l.eventPosY]}).show(),l.shadow&&c.css({width:b.width(),height:b.height(),left:i.pageX+2,top:i.pageY+2}).show(),a(document).one("click",j)}function j(){b.hide(),c.hide()}var b,c,d,e,f,g,h={menuStyle:{listStyle:"none",padding:"1px",margin:"0px",backgroundColor:"#fff",border:"1px solid #999",width:"100px"},itemStyle:{margin:"0px",color:"#000",display:"block",cursor:"default",padding:"3px",border:"1px solid #fff",backgroundColor:"transparent"},itemHoverStyle:{border:"1px solid #0a246a",backgroundColor:"#b6bdd2"},eventPosX:"pageX",eventPosY:"pageY",shadow:!0,onContextMenu:null,onShowMenu:null};a.fn.contextMenu=function(d,e){b||(b=a('<div id="jqContextMenu"></div>').hide().css({position:"absolute",zIndex:"500"}).appendTo("body").bind("click",function(a){a.stopPropagation()})),c||(c=a("<div></div>").css({backgroundColor:"#000",position:"absolute",opacity:.2,zIndex:499}).appendTo("body").hide()),f=f||[],f.push({id:d,menuStyle:a.extend({},h.menuStyle,e.menuStyle||{}),itemStyle:a.extend({},h.itemStyle,e.itemStyle||{}),itemHoverStyle:a.extend({},h.itemHoverStyle,e.itemHoverStyle||{}),bindings:e.bindings||{},shadow:e.shadow||e.shadow===!1?e.shadow:h.shadow,onContextMenu:e.onContextMenu||h.onContextMenu,onShowMenu:e.onShowMenu||h.onShowMenu,eventPosX:e.eventPosX||h.eventPosX,eventPosY:e.eventPosY||h.eventPosY});var g=f.length-1;return a(this).bind("contextmenu",function(a){var b=f[g].onContextMenu?f[g].onContextMenu(a):!0;return b&&i(g,this,a,e),!1}),this},a.contextMenu={defaults:function(b){a.each(b,function(b,c){typeof c=="object"&&h[b]?a.extend(h[b],c):h[b]=c})}}})(jQuery),$(function(){$("div.contextMenu").hide()})