//ready collection
$(document).ready(function(){
	/* Initialize IU.JS*/
	
	console.log('iu')
	if (typeof isEditor != 'undefined' && isEditor == true){
		return;
	}
	console.log('start : transition code');
                  
    /*INIT_IUTransition_REPLACEMENT_START*/
	//Initialize transition
	$('.IUTransition').each(function(){
        var eventType = $(this).attr('transitionevent');
                            
        if (eventType=='mouseOn'){
            $(this).mouseenter(transitionAnimationOn);
            $(this).mouseleave(transitionAnimationOff);
        }
        else {
            $(this).bind(eventType, transitionAnimation);
        }
        var firstObj = $(this).children().filter('.IUItem')[0];
        $(firstObj).css('display', 'block');
        var secondObj = $(this).children().filter('.IUItem')[1];
        $(secondObj).css('visibility', 'hidden');
	});
    /*INIT_IUTransition_REPLACEMENT_END*/
    /*INIT_IUMenuBar_REPLACEMENT_START*/
    //Initialize IUMenu
	$('.mobile-button').on('click', function(){
		var menu = $(this).next('ul');
		if (menu.hasClass('open')) {
			menu.removeClass('open');
		}
		else {
			menu.addClass('open');
		}
	});
	
	$('.IUMenuBar > ul > li.has-sub, .IUMenuBar > ul > li > ul > li.has-sub').hover(function(){
		if($(this).hasClass('open')){
			$(this).removeClass('open');
		}
		else{
			$(this).addClass('open');
		}
		
		var menu = $(this).children('ul');
		if (menu.hasClass('open')) {
			menu.removeClass('open');
		}
		else {
			menu.addClass('open');
		}
	});
	
	$('.IUMenuBar a[href]').each(function() {
		activateLink(this, 'parent');
	 });
                  
    /*INIT_IUMenuBar_REPLACEMENT_END*/
	 
    /*INIT_JS_REPLACEMENT*/

    /*INIT_Default_REPLACEMENT_START*/
	
	$("[iulink='1']").each(function(){
		var link = $(this).children().get(0);
		activateLink(link, 'parent');
	});
	
    $("[divlink='1']").click(function(evn){
		var link =  this.href.split('#')[0];
		var url = window.location.pathname;
	    var urlRegExp = new RegExp(url == '/' ? window.location.origin + '/?$' : url.replace(/\/$/,''));
		if(urlRegExp.test(link)){
		    evn.preventDefault();
			var div =  this.href.split('#')[1];
			var linkIU = $('#'+div);
	        $('html,body').scrollTo(linkIU.offset().left, linkIU.offset().top); 			
		}
    });
                 
    /* Initialize IUFrame.js */
    resizeCollection();
    resizePageLinkSet();
    makefullSizeSection();
    resizeSideBar();
    //makeBottomLocation();
    resizePageContentHeight();
    reframeCenter();
                  
    /* Initialize iu.js*/
    relocateScrollAnimation();

    
	/*init text media query*/
	reloadTextMediaQuery();
    /*INIT_Default_REPLACEMENT_END*/
                  
    console.log("ready : iuinit.js");
});

//css - initialize
//document.ready fires when all HTML has been loaded

/*INIT_WINDOW_LOAD_REPLACEMENT_START*/
$(window).load(function(){
    reframeCenter();
})
/*INIT_WINDOW_LOAD_REPLACEMENT_END*/

