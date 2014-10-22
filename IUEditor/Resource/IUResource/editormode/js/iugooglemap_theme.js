function getGoogleMapStaticStyle(index) {
	var styles = IUGoogleMapTheme(index);
	var result = [];
	styles.forEach(function(v, i, a){
        
		var style='';
		if( v.stylers ) { // only if there is a styler object
			if (v.stylers.length > 0) { // Needs to have a style rule to be valid.
				style += (v.hasOwnProperty('featureType') ? 'feature:' + v.featureType : 'feature:all') + '|';
				style += (v.hasOwnProperty('elementType') ? 'element:' + v.elementType : 'element:all') + '|';
				v.stylers.forEach(function(val, i, a){
					var propertyname = Object.keys(val)[0];
					var propertyval = val[propertyname].toString().replace('#', '0x');
					style += propertyname + ':' + propertyval + '|';
				});
			}
		}
		result.push('style='+encodeURIComponent(style));
	});
    
	return result.join('&');
}

function IUGoogleMapTheme(index){
	var themeList = [
	//paledawn-start
	[{"featureType":"water","stylers":[{"visibility":"on"},{"color":"#acbcc9"}]},{"featureType":"landscape","stylers":[{"color":"#f2e5d4"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#c5c6c6"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#e4d7c6"}]},{"featureType":"road.local","elementType":"geometry","stylers":[{"color":"#fbfaf7"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#c5dac6"}]},{"featureType":"administrative","stylers":[{"visibility":"on"},{"lightness":33}]},{"featureType":"road"},{"featureType":"poi.park","elementType":"labels","stylers":[{"visibility":"on"},{"lightness":20}]},{},{"featureType":"road","stylers":[{"lightness":20}]}]
	//paledawn-end
	,
	//subtlegrayscale-start
	[{"featureType":"landscape","stylers":[{"saturation":-100},{"lightness":65},{"visibility":"on"}]},{"featureType":"poi","stylers":[{"saturation":-100},{"lightness":51},{"visibility":"simplified"}]},{"featureType":"road.highway","stylers":[{"saturation":-100},{"visibility":"simplified"}]},{"featureType":"road.arterial","stylers":[{"saturation":-100},{"lightness":30},{"visibility":"on"}]},{"featureType":"road.local","stylers":[{"saturation":-100},{"lightness":40},{"visibility":"on"}]},{"featureType":"transit","stylers":[{"saturation":-100},{"visibility":"simplified"}]},{"featureType":"administrative.province","stylers":[{"visibility":"off"}]},{"featureType":"water","elementType":"labels","stylers":[{"visibility":"on"},{"lightness":-25},{"saturation":-100}]},{"featureType":"water","elementType":"geometry","stylers":[{"hue":"#ffff00"},{"lightness":-25},{"saturation":-97}]}]	
	//subtlegrayscale-end
	,
	//bluegray-start
	[{"featureType":"water","stylers":[{"visibility":"on"},{"color":"#b5cbe4"}]},{"featureType":"landscape","stylers":[{"color":"#efefef"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#83a5b0"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#bdcdd3"}]},{"featureType":"road.local","elementType":"geometry","stylers":[{"color":"#ffffff"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#e3eed3"}]},{"featureType":"administrative","stylers":[{"visibility":"on"},{"lightness":33}]},{"featureType":"road"},{"featureType":"poi.park","elementType":"labels","stylers":[{"visibility":"on"},{"lightness":20}]},{},{"featureType":"road","stylers":[{"lightness":20}]}]
	//bluegray-end
	,
	//green-start
	[{"featureType":"landscape","elementType":"geometry.fill","stylers":[{"color":"#bbd5c5"}]},{"featureType":"road.local","elementType":"geometry.stroke","stylers":[{"color":"#808080"}]},{"featureType":"road.highway","elementType":"geometry.fill","stylers":[{"color":"#fcf9a2"}]},{"featureType":"poi","elementType":"geometry.fill","stylers":[{"color":"#bbd5c5"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#808080"}]}]
	//green-end
	];
	
	return themeList[index];
}
