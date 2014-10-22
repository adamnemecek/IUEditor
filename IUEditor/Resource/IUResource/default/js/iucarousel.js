function reloadCarousel(carouselID){
	destroyCarousel(carouselID);
	initCarousel(carouselID);
}

function initCarousel(carouselID){
	var carousel = $('#'+carouselID);
	var wrapper = carousel.find('.wrapper');
	var count = $(wrapper).children().length;
		
	//copy first & last Obj
	var firstObj = $($(wrapper).children()[0]).clone();
	var htmlID = firstObj.attr('id');
	firstObj.attr('id', 'carousel_copy_'+htmlID);
	firstObj.addClass('carousel_copy');
	var lastObj = $($(wrapper).children()[count-1]).clone();
	htmlID = lastObj.attr('id');
	lastObj.attr('id', 'carousel_copy_'+htmlID);
	lastObj.addClass('carousel_copy');
		
	//insert copy objects
	$(firstObj).insertAfter($($(wrapper).children()[count-1]));
	$(lastObj).insertBefore($($(wrapper).children()[0]));
		
	//set position
	var width = 100 * (count+2);
	$(wrapper).css('width', width+'%');
	$(wrapper).css('height','100%');
	
	var childrenWidth = 100 / (count+2);	
	$(wrapper).children().each(function(){
		$(this).css('width', childrenWidth+'%');

	});
		
	carousel.data('index', 1);
	var left =  100 * -1;
	$(wrapper).css('left', left+'%');		

	//click binding
	carousel.find('.Prev').click(function(){
		prevCarousel(carouselID);
	});
	
	carousel.find('.Next').click(function(){
		nextCarousel(carouselID);
	});
	
	carousel.find('.IUCarouselItem').on( "swipeleft", function(){
		nextCarousel(carouselID);
	});
	
	carousel.find('.IUCarouselItem').on( "swiperight",function(){
		prevCarousel(carouselID);
	});
	
	carousel.find('.Pager >li').each(function(index){
		$(this).click(function(){
			moveCarousel(carouselID, index+1);
		})
	});
	
	//timer
	var timer = carousel.attr('timer');
	if(timer != undefined){
		var time = parseInt(timer);
		if(time < 4000){
			time = 4000;
		}
		window.setInterval(function(){ 
			nextCarousel(carouselID);
		}, time);
	}
    
	activeCarousel(carouselID);
}

function destroyCarousel(carouselID){
	var carousel = $('#'+carouselID);
	var wrapper = carousel.find('.wrapper');
	var copyObjects = $(wrapper).find('.carousel_copy');
	copyObjects.each(function(){
		$(this).remove();
	})
}

function nextCarousel(carouselID){
	var carousel = $('#'+carouselID);
	var wrapper = carousel.find('.wrapper');
	var index = carousel.data('index')+1;
	if(index >= $(wrapper).children().length){
		index = 1;
	}
	moveCarousel(carouselID, index);
}

function prevCarousel(carouselID){
	var carousel = $('#'+carouselID);
	var wrapper = carousel.find('.wrapper');
	var index = carousel.data('index')-1;
	if(index < 0){
		index = $(wrapper).children().length-2;
	}
	moveCarousel(carouselID, index);
}
function moveCarousel(carouselID, toIndex){
	var carousel = $('#'+carouselID);
	var wrapper = carousel.find('.wrapper');
	var count = $(wrapper).children().length;
	var index = carousel.data('index');
	
	if(index==0){
		var left = 100 * -1 * (count-2);
		$(wrapper).css('left', left+'%');
	}
	else if(index==count-1){
		var left = 100 * -1;
		$(wrapper).css('left', left+'%');		
	}
	
	var firstLeft = 100 * -1 * toIndex;
	carousel.data('index', toIndex);
    
	$(wrapper).animate({'left': firstLeft+'%'}, 400);
	activeCarousel(carouselID);
	
}

function activeCarousel(carouselID){
	var carousel = $('#'+carouselID);
	var wrapper = carousel.find('.wrapper');
	var count = $(wrapper).children().length;
	var index = carousel.data('index');

	//select li class active
	var selectIndex = index -1;
	if(index == count-1){
		selectIndex = 0;
	}
	else if(index == 0){
		selectIndex = count-3;
	}
	carousel.find('.Pager').children().each(function(i){
		if(i == selectIndex){
			$(this).addClass('active');
		}
		else{
			$(this).removeClass('active');
		}
	});

}

