// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(function() {
  $("#friend_tokens").tokenInput("/facebook/friends.json", {
    crossDomain: false,
    //    prePopulate: $("#book_author_tokens").data("pre"),
    theme: "facebook"
  });
});

$(document).ready(function(){	
  $('.playlist.add a').click(function() {
    $('.playlist.add').before("<li class='playlist' style='display: none;' ><a href='#'><span class='icon'></span><form id='new_playlist'  style='display: inline;'><input type='text'/></form></a></li>");
    $('.playlist.add').prev().slideDown("fast").find('input').focus();
    $('#new_playlist').submit(function() {
      $.post('/playlist/create', { plname: $('#new_playlist input').val()});
      return false;
    });
    $('#new_playlist input').blur(function() {
      $(this).closest('.playlist').slideUp();
      return false;
    });
  });

  $('li .delete').click(function(event) {
    $(this).closest('.playlist').addClass('confirming').find('.confirm').click(function(event) {
      console.log('DELETE PLAYLIST AND .slideUp()');
      $(this).slideUp();
    }).mouseleave(function(event) {
      $(this).parent().removeClass('confirming');
    });
    return false;
  });

  $('button.detail').click(function() {
    $('.view-toggle .active').removeClass('active');
    $(this).addClass('active');
    content = $('#song_view').attr("content");
    content_id = $('#song_view').attr("content_id");
    if (content == 'playlist') {
      $.get('/playlist/play', { id: content_id , type: 'detail' });
    } else if (content == 'hot'){
      $.get('/song/hot_songs', { type: 'detail' });
    } else if (content == 'recom'){
      $.get('/recommendation/recommended', { type: 'detail' });
    }
  });

  $('button.grid').click(function() {
    $('.view-toggle .active').removeClass('active');
    $(this).addClass('active');
    content = $('#song_view').attr("content");
    content_id = $('#song_view').attr("content_id");
    if (content == 'playlist') {
      $.get('/playlist/play', { id: content_id , type: 'grid' });
    }else if (content == 'hot'){
      $.get('/song/hot_songs', { type: 'grid' });
    }else if (content == 'recom'){
      $.get('/recommendation/recommended', { type: 'grid' });
    }
  });

  $('#side_bar li').click(function() {
    $('#side_bar li.active').removeClass('active');
    $(this).addClass('active');
  });





});

