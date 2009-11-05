<!--
function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}
function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}
function MM_showHideLayers() { //v9.0
  var i,p,v,obj,args=MM_showHideLayers.arguments;
  for (i=0; i<(args.length-2); i+=3) 
  with (document) if (getElementById && ((obj=getElementById(args[i]))!=null)) { v=args[i+2];
    if (obj.style) { obj=obj.style; v=(v=='show')?'visible':(v=='hide')?'hidden':v; }
    obj.visibility=v; }
}


// this function may already be used so attempt to reroute to new name \\\
function displayDropDown(onDiv,action,offDiv) {
	
	displayIndexDropDown(onDiv,action,offDiv)
}

function displayIndexDropDown(onDiv,action,offDiv) {
	
	//alert('onDiv: '+onDiv+'\naction: '+action+'\noffDiv: '+offDiv);
	
	var offDivs=offDiv.split(';');

	for (var i=0; i<offDivs.length; i++)
	{
		if(document.getElementById(offDivs[i]))
		{
			document.getElementById(offDivs[i]).style.display='none';
		}
	}
	
	if(document.getElementById(onDiv))
	{
		if(action=='flip')
		{
			if(document.getElementById(onDiv).style.display=='none')
			{
				document.getElementById(onDiv).style.display='block';
			}
			else
			{
				document.getElementById(onDiv).style.display='none';
			}
		}
		else
		{
			document.getElementById(onDiv).style.display=action;
		}
	}
}

function checkAll(fields,action)
{
	var field=fields.split(';');
	
	for (i = 0; i < field.length; i++)
	{
		document.getElementById(field[i]).checked = action;
	}
}

function showInfoWindow(event, onDiv)
{
	//alert('onDiv: '+onDiv);
	
   // var s = 'X=' + window.event.clientX +  ' Y=' + window.event.clientY ;
   // alert(s);
   
	var posx = 0;
	var posy = 0;
	if (!e) var e = event;
	if (e.pageX || e.pageY) 	{
		posx = e.pageX;
		posy = e.pageY;
	}
	else if (e.clientX || e.clientY) 	{
		posx = e.clientX + document.body.scrollLeft
		+ document.documentElement.scrollLeft;
		posy = e.clientY + document.body.scrollTop
		+ document.documentElement.scrollTop;
	}

	//alert('posx: '+posx+'\nposy: '+posy);
	
	if(posx || posy)
	{
		var x = document.getElementById(onDiv)
		if(x.display!='block')
		{
			x.style.display = 'block';
			x.style.top = (posy+10)+'px';
			x.style.left = (posx-260)+'px';
		}
	}
}  

function discussionChange(id,onDiv)
{
	//alert('id: '+id+'\nonDiv: '+onDiv);
	
	var divs=new Array('discussion_display','discussion_new_topic','review_display','review_new_topic','suggestion_new_topic');
	var ids=new Array('discussion_display_button','review_display_button','suggestion_display_button');
	
	for(i=0; i<divs.length; i++)
	{
		if(document.getElementById(divs[i]))
		{
			
			document.getElementById(divs[i]).style.display='none';
		}
	}
	
	for(i=0; i<ids.length; i++)
	{
		document.getElementById(ids[i]).style.backgroundColor='#f0f0f0';
		document.getElementById(ids[i]).style.borderBottomColor='#dadad5';
	}
	document.getElementById(onDiv).style.display='block';
	document.getElementById(id).style.backgroundColor='#ffffff';
	document.getElementById(id).style.borderBottomColor='#ffffff';
}

function mediaDownloadChange(id,onDiv)
{
	//alert('id: '+id+'\nonDiv: '+onDiv);
	
	var divs=new Array('for_print_display','for_web_display');
	var ids=new Array('for_print_display_button','for_web_display_button');
	
	for(i=0; i<divs.length; i++)
	{
		if(document.getElementById(divs[i]))
		{
			
			document.getElementById(divs[i]).style.display='none';
		}
	}
	
	for(i=0; i<ids.length; i++)
	{
		document.getElementById(ids[i]).style.backgroundColor='#f0f0f0';
		document.getElementById(ids[i]).style.borderBottomColor='#dadad5';
	}
	document.getElementById(onDiv).style.display='block';
	document.getElementById(id).style.backgroundColor='#ffffff';
	document.getElementById(id).style.borderBottomColor='#ffffff';
}

function changeStar(id)
{
	var rating=id.replace(/review_star_/,'');
	
	document.getElementById('new_review_rating').value=rating;
	
	for(i=0; i<5; i++)
	{
		document.getElementById('review_star_'+(i+1)).src='images/review_star_empty.png';
	}
	for(i=0; i<rating; i++)
	{
		document.getElementById('review_star_'+(i+1)).src='images/review_star_full.png';
	}
}

function imageChange(images,onDiv)
{
	var image=images.split(';');
	if(document.getElementById(onDiv).src.match(image[1]))
	{
		document.getElementById(onDiv).src=image[0];
	}
	else
	{
		document.getElementById(onDiv).src=image[1];
	}
}


function sliderSelect(selectedElement)
{
    $('#featured_videos_carousel .slider_item_box').css('backgroundImage', '');
		$('#featured_videos_carousel .slider_item_box').removeClass('current');
    $(selectedElement).css('backgroundImage', 'url(/images/featured-thumb-selected-frame.png)');
		$(selectedElement).addClass('current');
    var thumb = $(selectedElement).attr('large_thumbnail');
    $('#featured_video_image').attr('src', thumb);    
}

function findPosX(obj)
  {
	  
	  
    var curleft = 0;
    if(obj.offsetParent)
        while(1) 
        {
          curleft += obj.offsetLeft;
          if(!obj.offsetParent)
            break;
          obj = obj.offsetParent;
        }
    else if(obj.x)
        curleft += obj.x;
    return curleft;
  }

  function findPosY(obj)
  {
    var curtop = 0;
    if(obj.offsetParent)
        while(1)
        {
          curtop += obj.offsetTop;
          if(!obj.offsetParent)
            break;
          obj = obj.offsetParent;
        }
    else if(obj.y)
        curtop += obj.y;
    return curtop;
  }
  
//-->