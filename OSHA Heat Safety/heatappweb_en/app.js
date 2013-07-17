function set_heat_index(val)
{
	var obj = document.getElementById('heat_index_val');
	if(obj == undefined) return;
	if(val == undefined || val == "") return;
	obj.innerHTML = val;
}

function readCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function createCookie(name,value,days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	alert("createCookie(" + name + "=" + value + expires + "; path=/" + ");");
	document.cookie = name+"="+value+expires+"; path=/";
}

function eraseCookie(name) {
	createCookie(name,"",-1);
}

function refreshView()
{
	var val = readCookie("heat_index");
	
	alert("set_heat_index(" + val + ");");
	if(val != undefined && val != "") set_heat_index(val);
}

// 77.0 °F