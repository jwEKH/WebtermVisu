// Diverse globale Variablen
// Vorgehensweise analog zu der in VCO_Edit.aspx
var prj;
var IdVisu;
var canvas;
var vctx;
var visudata;
var bmpIndex = 0;
var VisuDownload = {};
var LinkButtonList = [];
var canvasOffset;
var offsetX;
var offsetY;
var requestDrawingFlag = false;
var bgColors = [];
var hasSymbolsFlag = false;
var vtipCanvas;
var tipvctx;
var tt_dots = []; // Liste der tooltips: Koordinate und Text and BitmapIndex
var waitReloadMS = 5000;
var nReloadCycles = 0;
var maxReloadCycles = 100;
var bAutoReload;
var ReloadTimerVar;
var showLog;
var hInit;
var wInit;
var startAngle = 1.1 * Math.PI;
var endAngle = 1.9 * Math.PI;
var stoerungen;
var stoerungText = "";
var xStoerButtonMin;
var yStoerButtonMin;
var xStoerButtonMax;
var yStoerButtonMax;
var xZaehlerButtonNeuMin;
var xZaehlerButtonNeuMax;
var yZaehlerButtonNeuMin;
var yZaehlerButtonNeuMax;
var match;
var gesamtZaehler = "";

var DEBUG = false;
var FORCE_ANALOGMISCHER = false;
var locked = false;

var ClickableElement = [];		   /*SettingsFromVisualisierung*/
var ClickableElementList = [];	  /*SettingsFromVisualisierung*/
var ClickableElementUrlList = []; /*SettingsFromVisualisierung*/
var clickableElementUrl;
var currentID;

//$("document").ready(function () {
//	setTimeout(cbCyclicChanged());
//});

// URL Query Strings auswerten
function getParameterByName(name) {
	name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
	var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
		results = regex.exec(location.search);
	return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}


function copyToClip() {
	// Create new element
	var el = document.createElement('textarea');

	// Set value (string to be copied)
	el.value = document.getElementById("modalZaehler").innerText;

	// Set non-editable to avoid focus and move outside of view
	el.setAttribute('readonly', '');
	el.style = { position: 'absolute', left: '-9999px' };
	document.body.appendChild(el);
	// Select text inside element
	el.select();
	// Copy text to clipboard
	document.execCommand("copy");
	// Remove temporary element
	document.body.removeChild(el);
}

function closeModal() {
	var modal = document.getElementById('myModal');
	var span = document.getElementById("closeModal");
	span.onclick = function () {
		modal.style.display = "none";
	}
}

function closeModalZaehler() {
	var modal = document.getElementById('modalZaehler');
	var span = document.getElementById("closeModalZaehler");
	span.onclick = function () {
		modalZaehler.style.display = "none";
	}
}

function initVisu() {

	IdVisu = getParameterByName('Id').substr(0,5);
	wInit = window.outerWidth;
	hInit = window.outerHeight;
	bAutoReload = false;

	vStatCanvas = document.getElementById('vStatCanvas');
	vStatCanvas.width = 1400;
	vStatCanvas.height = 630;
	vStatCtx = vStatCanvas.getContext('2d');

	vDynCanvas = document.getElementById('vDynCanvas');
	vDynCanvas.width = 1400;
	vDynCanvas.height = 630;
	vDynCtx = vDynCanvas.getContext('2d');

	// test listener for stoerung
	vStatCanvas.addEventListener("mousedown", getPosition, false);

	vtipCanvas = document.getElementById("vtipCanvas");
	vtipCanvas.width = 170;
	vtipCanvas.height = 25;
	vtipCanvas.style.left = "-2000px";
	tipvctx = vtipCanvas.getContext("2d");

	canvasOffset = $("body").offset(); //$("vinsideWrapper").offset();
	canvasOffsetX = canvasOffset.left;
	canvasOffsetY = canvasOffset.top + $(".tab").height() + 2 * parseInt($(".tab").css('border-bottom-width')) + parseInt($(".tab").css('margin-bottom'));	// + $(".tab").marginBottom;

	visudata = $.parseJSON(loadDeployedVTO(IdVisu));
	prj = visudata.VCOData.Projektnumer;
	getOnlinegesamtZaehler(prj);
	/*SettingsFromVisualisierung*/
	addClickableElementToList(visudata);

	// Tooltips einlesen
	initTooltips();

	// Mouse-hover-handler für ToolTip dynamischer Elemente
	$("#vimgArea").mousemove(function (e) {
		handleMouseMove(e);
	});

	// Mouse-down-handler für bmp wechsel (statische Elemente)
	$("#vStatCanvas").mousedown(function (e) {
		handleMouseDown(e);
	});
	setBitmap(bmpIndex);
}

function startVisu() {
	try {
		var clearStoerung = document.getElementById("modalBody");
		clearStoerung.innerHTML = "";
		stoerungText = "";
		var k = getOnlineData(prj);
		VisuDownload = $.parseJSON(k);
		var Stoerungen = VisuDownload.Stoerungen;
		var stoerungencount = Stoerungen.length;
		for (var i = 0; i < stoerungencount; i++) {
			stoerungText += Stoerungen[i].BezNr + ". " + Stoerungen[i].StoerungText.trim() + "<br/>";
		}


	}
	catch (e) {
		log(e.message);
		log("Es konnten keine Visualisierungsdaten heruntergeladen werden von Steuerung " + prj);
	}
	DrawVisu(true);
}


// Linkbutton in Liste eintragen
function addClickableElementToList(visudata) {
	try {
		for (var i = 0; i < visudata.DropList.length; i++) {
			if (visudata.DropList[i].VCOItem.clickable == true) {
				var item = new Object();
				item["x"] = visudata.DropList[i].x;
				item["y"] = visudata.DropList[i].y;
				item["clickable"] = true;
				item["Bezeichnung"] = visudata.DropList[i].VCOItem.Bez.trim();
				item["id"] = visudata.DropList[i].VCOItem.iD.trim();
				item["h"] = visudata.DropList[i].BgHeight;
				item["bitmapIndex"] = visudata.DropList[i].bmpIndex;
				if (item["Bezeichnung"] == "HK") {
					item["radius"] = 18;

				}
				if (item["Bezeichnung"] == "KES") {
					item["radius"] = 18;
				}

				if (item["Bezeichnung"] == "BHK") {
					item["radius"] = 18;
				}
				if (item["Bezeichnung"] == "WWL") {
					item["radius"] = 18;
				}
				createLinkForClickableElement(visudata.DropList[i].VCOItem.iD.trim());
				ClickableElementList.push(item);
			}
		}
	}
	catch (e) {
		log(e.message);
	}
}


function getVisuItemEinheit(i) {
	i = i.trim();
	switch (i) {
		case "1":
			return "°C";
			break;
		case "2":
			return "bar";
			break;
		case "3":
			return "V";
			break;
		case "4":
			return "kW";
			break;
		case "5":
			return "m^3/h";
			break;
		case "6":
			return "mWS";
			break;
		case "7":
			return "%";
			break;
		case "8":
			return "kWh";
			break;
		case "9":
			return "Bh";
			break;
		case "10":
			return "m^3";
			break;
		case "11":
			return "°C\u00F8";
			break;
		case "12":
			return "mV";
			break;
		case "13":
			return "UPM";
			break;
		case "14":
			return "s";
			break;
		case "15":
			return "mbar";
			break;
		case "16":
			return "A";
			break;
		case "17":
			return "Hz";
			break;
		case "18":
			return "1/h";
			break;
		case "40":
			return "";
			break;
	}
}

// click event on canvas

function getPosition(event) {
	var x = event.x - canvasOffsetX;
	var y = event.y - canvasOffsetY;

	//click event für das anstehende Störungen button
	if (bmpIndex == 0 && ((x > xStoerButtonMin) && (x < xStoerButtonMax)) && ((y > yStoerButtonMin) && (y < yStoerButtonMax))) {


		var vStatCanvas = document.getElementById("vStatCanvas");
		var modal = document.getElementById('modalStoerung');
		window.onclick = function (event) {
			if (event.target == modal) {
				modal.style.display = "none";
			}
		}

		//alert(stoerungText);
		if (stoerungText != "") {
			document.getElementById("modalHeader").innerHTML = '<h5> Aktuelle Störungen' + '<span id="closeModalStoerung" class="close">&times;</span>';
			document.getElementById("modalContent").style.width = '30%';
			document.getElementById("modalBody").innerHTML = "</br> <pre>" + stoerungText + "</pre>";//stoerungText ;
			var span = document.getElementById("closeModalStoerung");
			span.onclick = function () {
				modal.style.display = "none";
			}
		}
		else {
			document.getElementById("modalHeader").innerHTML = '<h5> Aktuelle Störungen' + '<span id="closeModalStoerung" class="close">&times;</span>';
			document.getElementById("modalContent").style.width = '30%';
			document.getElementById("modalBody").innerHTML = "keine weiteren Störungen";
			var span = document.getElementById("closeModalStoerung");
			span.onclick = function () {
				modal.style.display = "none";
			}
		}
		modal.style.display = "block";

	}

	//click event für das neue Zähler button, die Ohne verweis auf Zähler.png funktioniert
	if (bmpIndex == 0 && ((x > xZaehlerButtonNeuMin) && (x < xZaehlerButtonNeuMax)) && ((y > yZaehlerButtonNeuMin) && (y < yZaehlerButtonNeuMax))) {
		//alert("on area");
		var vStatCanvas = document.getElementById("vStatCanvas");
		var modal = document.getElementById('modalZaehler');
		window.onclick = function (event) {
			if (event.target == modal) {
				modal.style.display = "none";
			}
		}
		//zähler holen
		var prj = visudata.VCOData.Projektnumer;
		var currentdate = new Date();
		var datetime = "&emsp;&emsp;" + currentdate.getDate() + "."
			+ (currentdate.getMonth() + 1) + "."
			+ currentdate.getFullYear() + " : "
			+ currentdate.getHours() + ":"
			+ (currentdate.getMinutes() < 10 ? '0' : '') + currentdate.getMinutes();
		//+ currentdate.getSeconds();
		var dateMonthYear = currentdate.getDate() + "."
			+ (currentdate.getMonth() + 1) + "."
			+ currentdate.getFullYear();

		//var gesamtZaehler = getOnlinegesamtZaehler(IdVisu);

		if (gesamtZaehler != "") {
			document.getElementById("modalHeaderZaehler").innerHTML = '<h5> Zähler: ' + Projektname + " " + datetime + '<span id="closeModalZaehler" class="close">&times;</span>';
			document.getElementById("modalContenZaehler").style.width = '80%';
			document.getElementById("aktuelleZaehler").innerHTML = "</br> <pre>" + gesamtZaehler + "</pre>";

			var span = document.getElementById("closeModalZaehler");
			span.onclick = function () {
				modalZaehler.style.display = "none";
			}

		}
		else {

			var aktuelleZaehler = getOnlineAktuellZaehler(prj)
			document.getElementById("modalContenZaehler").style.width = '80%';
			document.getElementById("aktuelleZaehler").innerHTML = "Keine Zählerdaten verfügbar";
			closeModalZaehler();
		}
		modal.style.display = "block";
	}

}

function ReloadTimerFunc() {
	ReloadData();
	if (bAutoReload == true) {
		nReloadCycles++;
		if (nReloadCycles > maxReloadCycles) {
			nReloadCycles = 0;
			$("#cbcyclicReload").prop("checked", false);
		}
		else
			ReloadTimerVar = setTimeout(function () { ReloadTimerFunc() }, waitReloadMS);
	}
}



// Mouse Handler für Tooltip Anzeige
function handleMouseMove(e) {

	var mouseX = parseInt(e.clientX - canvasOffsetX);
	var mouseY = parseInt(e.clientY - canvasOffsetY);

	var currentBmpIndex = bmpIndex;
	match = false;
	var matchTT = false;

	for (var i = 0; i < LinkButtonList.length; i++) {
		var item = LinkButtonList[i];
		if (mouseX > item.x_min && mouseX < item.x_max && mouseY > item.y_min && mouseY < item.y_max) {
			match = true;
			i = LinkButtonList.length;
		}
	}


	for (var i = 0; i < tt_dots.length; i++) {
		var dx = mouseX - tt_dots[i].x;
		var dy = mouseY - tt_dots[i].y;
		if (tt_dots[i].b) {							//Bool'sches Element?
			dx = mouseX - (tt_dots[i].x - 15);		//Referenzpunkt der Bool'schen Grafiken für tt ungünstig
			dy = mouseY - (tt_dots[i].y + 10);		//daher Verschiebung um 15 & 10px
		}
		var txt = tt_dots[i].t;
		var index = tt_dots[i].index
		if ((dx * dx < 1600) && (dy * dy < 200) && (dx > 0) && (dy < 0) && (index == currentBmpIndex)) {

			vtipCanvas.style.left = (tt_dots[i].x) + "px";
			vtipCanvas.style.top = (tt_dots[i].y - 40) + "px";
			tipvctx = vtipCanvas.getContext("2d");
			tipvctx.clearRect(0, 0, vtipCanvas.width, vtipCanvas.height);
			//                  tipvctx.rect(0,0,vtipCanvas.width,vtipCanvas.height);

			tipvctx.font = "13.5px Arial";
			vtipCanvas.width = tipvctx.measureText(txt).width;//(6 * txt.length + 22);
			vtipCanvas.height = 20;
			tipvctx.font = "12px Arial";
			tipvctx.fillStyle = "#F1F1F1"; /*rgb(241, 241, 241); white gray*/
			tipvctx.fillText(txt, 5, 14);

			match = true;
			matchTT = true;

			i = tt_dots.length;
		}

	}

	if (match) $(".vinsideWrapper").css("cursor", "pointer");	//Vorarbeit: Pointer als Cursor für zukünftige Visu Bedienung

	if (!matchTT) vtipCanvas.style.left = "-2000px";

	if (!match && !matchTT) $(".vinsideWrapper").css("cursor", "default");

}

// Tooltip pushen
function pushToolTip(px, py, txt, idx) {
	tt_dots.push({
		x: px,
		y: py,
		t: txt,
		index: idx
	});
}

// Tooltipliste aufbauen
function initTooltips() {
	var x = visudata;
	var y = x;
	var DropList = visudata.DropList;

	var n = DropList.length;
	for (i = 0; i < n; i++) {
		if (DropList[i].ToolTip.trim() != "")
			pushToolTip(DropList[i].x, DropList[i].y, DropList[i].ToolTip, DropList[i].bmpIndex);
	}
}


// Neuzeichnung anfordern (Timer ruft auf)
function requestDrawing() {
	requestDrawingFlag = true;
}

// Timer-Mechanik Darstellung und Animation
var TimerVar = setInterval(function () { globalTimer() }, 100);
var TimerToggle = false;
var TimerToggleCounter = 0;
var TimerCounter = 0;

function globalTimer() {
	if (requestDrawingFlag || hasSymbolsFlag) {
		TimerCounter++;
		if (TimerCounter > 10000)
			TimerCounter = 0;

		// 500ms Toggle (1 Hz)
		TimerToggleCounter++;
		if (TimerToggleCounter > 5) {
			TimerToggleCounter = 0;
			TimerToggle = !TimerToggle;
		}
		requestDrawingFlag = false;
		DrawVisu();
	}

}



function fpButton(ctx, x, y, betrieb) {
	var notches = 7,                      // num. of notches
		radiusO = 12,                    // outer radius
		radiusI = 9,                    // inner radius
		radiusH = 5,                    // hole radius
		taperO = 30,                     // outer taper %
		taperI = 40,                     // inner taper %

		// pre-calculate values for loop
		pi2 = 2 * Math.PI,            // cache 2xPI (360deg)
		angle = pi2 / (notches * 2),    // angle between notches
		taperAI = angle * taperI * 0.005, // inner taper offset (100% = half notch)
		taperAO = angle * taperO * 0.005, // outer taper offset
		a = angle,                  // iterator (angle)
		toggle = false;                  // notch radius level (i/o)

	ctx.save();
	ctx.fillStyle = '#000';
	ctx.lineWidth = 2.5;
	ctx.strokeStyle = '#000';
	ctx.beginPath();
	ctx.moveTo(x + radiusO * Math.cos(taperAO), y + radiusO * Math.sin(taperAO));

	for (; a <= pi2; a += angle) {

		// draw inner to outer line
		if (toggle) {
			ctx.lineTo(x + radiusI * Math.cos(a - taperAI),
				y + radiusI * Math.sin(a - taperAI));
			ctx.lineTo(x + radiusO * Math.cos(a + taperAO),
				y + radiusO * Math.sin(a + taperAO));
		}

		// draw outer to inner line
		else {
			ctx.lineTo(x + radiusO * Math.cos(a - taperAO),  // outer line
				y + radiusO * Math.sin(a - taperAO));
			ctx.lineTo(x + radiusI * Math.cos(a + taperAI),  // inner line
				y + radiusI * Math.sin(a + taperAI));
		}

		// switch level
		toggle = !toggle;
	}
	// close the final line
	ctx.closePath();
	ctx.moveTo(x + radiusH, y);
	ctx.arc(x, y, radiusH, 0, pi2);

	//automatik betrieb
	if (!!betrieb) {
		//vDynCtx.font = "12px Arial";
		//vDynCtx.fillText("Handbetrieb", x - 20, y + 24);
		ctx.translate(x, y);
		ctx.moveTo(40, 27);
		ctx.lineTo(40, 10);
		ctx.arc(38, 8, 2, 2 * Math.PI, 1 * Math.PI, true);
		ctx.lineTo(36, 16);
		ctx.arc(34, 6.5, 2, 2 * Math.PI, 1 * Math.PI, true);
		ctx.lineTo(32, 15);
		ctx.arc(30, 5.5, 2, 2 * Math.PI, 1 * Math.PI, true);
		ctx.lineTo(28, 15);
		ctx.arc(26, 6.5, 2, 2 * Math.PI, 1 * Math.PI, true);
		ctx.lineTo(24, 20);
		ctx.lineTo(20, 16);
		ctx.arc(19, 17.8, 2, 1.8 * Math.PI, 0.8 * Math.PI, true);
		ctx.lineTo(26, 27);
		ctx.lineTo(40, 27);
		ctx.fillStyle = 'yellow';
		ctx.scale(1, 1);
		ctx.fill();
		//vDynCtx.stroke();
	}
	ctx.stroke();
	ctx.restore();
}



function Absenkung(vDynCtx, x, y, scale, active) {
	vDynCtx.save();
	vDynCtx.moveTo(0 - 10 * scale, 0);
	vDynCtx.font = '10pt Arial';
	vDynCtx.fillStyle = `#1F94B9`; /*EKH Cyan*/ //'blue';

	vDynCtx.translate(x, y);

	if (active == 1)
		vDynCtx.fillText('Nacht', 0, 0);
	else
		vDynCtx.fillText('Tag', 1, 0);

	vDynCtx.restore();
}


function BHDreh(vctx, x, y, scale, rotation) {
	vctx.save();
	vctx.lineWidth = 1 * scale;
	vctx.translate(x, y);
	vctx.rotate(Math.PI / 180 * rotation);
	vctx.strokeStyle = `#1F94B9`; /*EKH Cyan*/ //"steelblue";
	vctx.beginPath();
	vctx.arc(0, 0, 13 * scale, 0, Math.PI * 2, true);

	vctx.moveTo(0 + 10 * scale, 0);
	vctx.arc(0, 0, 10 * scale, 0, -Math.PI / 4, true);
	vctx.moveTo(0 + 10 * scale, 0);
	vctx.arc(0, 0, 10 * scale, 0, Math.PI / 4, false);

	vctx.moveTo(0 - 10 * scale, 0);
	vctx.arc(0, 0, 10 * scale, Math.PI, -3 * Math.PI / 4, false);
	vctx.moveTo(0 - 10 * scale, 0);
	vctx.arc(0, 0, 10 * scale, Math.PI, 3 * Math.PI / 4, true);
	vctx.stroke();

	vctx.lineWidth = 3 * scale;

	vctx.beginPath();
	vctx.moveTo(0 - 10 * scale, 0);
	vctx.lineTo(0 + 10 * scale, 0);

	vctx.stroke();
	vctx.restore();
}


function feuer(vctx, x, y, scale) {
	// 30x48
	var rd1 = (Math.random() - 0.5) * 3;
	var rd2 = (Math.random() - 0.5) * 3;
	var rd3 = (Math.random() - 0.5) * 3;
	var rd4 = (Math.random() - 0.5) * 3;
	var rd5 = (Math.random() - 0.5) * 3;
	var rd6 = (Math.random() - 0.5) * 3;
	vctx.save();

	vctx.lineWidth = 1;
	vctx.translate(x, y);
	vctx.scale(scale, scale);
	vctx.strokeStyle = "red";
	vctx.fillStyle = "yellow";
	vctx.beginPath();
	vctx.moveTo(0 + rd1, -20);
	vctx.lineTo(-5 + rd2, -10);
	vctx.lineTo(-8 + rd3, -5);
	vctx.lineTo(-7 + rd4, 5);
	vctx.lineTo(-2 + rd5, 10);

	vctx.lineTo(2 + rd5, 10);
	vctx.lineTo(4 + rd4, 5);
	vctx.lineTo(6 + rd6, -5);
	vctx.lineTo(5 + rd2, -10);
	vctx.lineTo(0 + rd1, -20);
	vctx.fill();
	vctx.stroke();

	//vctx.closePath();
	vctx.restore();
}

function pmpDreh2(vctx, x, y, scale, rot) {
	// 12x12
	vctx.save();
	vctx.strokeStyle = "black";
	vctx.fillStyle = "black";
	vctx.lineWidth = 1;
	vctx.translate(x, y);
	vctx.rotate(Math.PI / 180 * rot);
	vctx.scale(scale, scale);
	vctx.beginPath();
	vctx.arc(0, 0, 11, 0, Math.PI * 2, true);
	vctx.stroke();
	vctx.closePath();
	vctx.beginPath();
	vctx.lineWidth = 1, 5;
	vctx.arc(0, 0, 6, 0, Math.PI * 2, true);
	vctx.fillStyle = 'black';
	vctx.fill();
	vctx.closePath();
	vctx.beginPath();
	vctx.arc(0, 0, 6, startAngle, endAngle, true);
	vctx.lineTo(0, 0);
	vctx.fillStyle = 'white';
	vctx.fill();
	vctx.closePath();

	vctx.stroke();
	vctx.restore();
}

function drawEllipse(vctx, x, y, w, h) {
	var kappa = .5522848,
		ox = (w / 2) * kappa, // control point offset horizontal
		oy = (h / 2) * kappa, // control point offset vertical
		xe = x + w,           // x-end
		ye = y + h,           // y-end
		xm = x + w / 2,       // x-middle
		ym = y + h / 2;       // y-middle


	vctx.moveTo(x, ym);
	vctx.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y);
	vctx.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym);
	vctx.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye);
	vctx.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym);
	//vctx.closePath(); // not used correctly, see comments (use to close off open path)
	vctx.stroke();
}

function luefter(vctx, x, y, scale, rotL, rotDir) {
	// 51x51
	vctx.save();
	vctx.strokeStyle = "black";
	vctx.fillStyle = "grey";
	vctx.lineWidth = 1;
	vctx.translate(x, y);
	vctx.rotate(Math.PI / 180 * rotDir);
	vctx.scale(scale, scale);
	vctx.beginPath();
	vctx.arc(0, 0, 24, 0, Math.PI * 2, true);
	vctx.moveTo(0, -24);
	vctx.lineTo(-23, -5);
	vctx.moveTo(0, 24);
	vctx.lineTo(-23, 5);
	vctx.stroke();
	vctx.closePath();
	vctx.beginPath();
	vctx.rotate(Math.PI / 180 * rotL);
	drawEllipse(vctx, 0, -5, 22, 10);
	drawEllipse(vctx, -22, -5, 22, 10);
	vctx.fill();

	vctx.restore();
}

function ventil(ctx, x, y, scale, rot) {
	// 6x6
	ctx.save();
	ctx.strokeStyle = "black";
	ctx.fillStyle = "black";
	ctx.lineWidth = 1;
	ctx.translate(x, y);
	ctx.rotate(Math.PI / 180 * (rot + 180));
	ctx.scale(scale, scale);
	ctx.beginPath();
	ctx.fillRect(-1.5, -1, 1.5, 2);
	ctx.moveTo(0, 2);
	ctx.lineTo(2, 0);
	ctx.lineTo(0, -2);
	ctx.fill();
	//patch 22.11.2022: doppelte Pfeile
	ctx.translate(11, 0);
	ctx.fillRect(-1.5, -1, 1.5, 2);
	ctx.moveTo(0, 2);
	ctx.lineTo(2, 0);
	ctx.lineTo(0, -2);
	ctx.fill();

	ctx.restore();
}

function ventilFilled(ctx, x, y, scale, rot) {
	// 6x6
	ctx.save();
	ctx.strokeStyle = "black";
	ctx.fillStyle = "black";
	ctx.lineWidth = 1;
	ctx.translate(x, y);
	ctx.rotate(Math.PI / 180 * rot);
	ctx.scale(scale, scale);
	ctx.beginPath();
	
	ctx.moveTo(-8, -8);
	ctx.lineTo(-8, 8);
	ctx.lineTo(8, 0);
	ctx.lineTo(-8, -8);

	ctx.fill();

	ctx.restore();
}

function lueftungsklappe(ctx, x, y, scale, val, orientation = 'Links', isNC = true) {
	let rotation = 0;
	if (orientation == 'Oben') rotation = 90;
	if (orientation == 'Rechts') rotation = 180;
	if (orientation == 'Unten') rotation = 270;
	if (!val) val = 0;
	if (isNC) val = 100 - val;
	rotation -= val/100 * 75;
	
	ctx.save();
	ctx.strokeStyle = "black";
	ctx.lineWidth = 1;
	ctx.translate(x, y);
	ctx.scale(scale, scale);
	ctx.beginPath();
	//Kreis zeichnen
	ctx.arc(0, 0, 3, 0, 2 * Math.PI);
	ctx.fillStyle = 'black';
	ctx.fill();

	
	ctx.rotate(rotation * Math.PI / 180);
	ctx.moveTo(-20, 0);
	ctx.lineTo(20, 0);

	ctx.stroke();
	ctx.restore();
}

function Led(vctx, x, y, scale, col) {
	if (col) {
		vctx.save();
		vctx.strokeStyle = "black";
		vctx.fillStyle = "#aaa";
		vctx.lineWidth = 1;
		vctx.translate(x, y);
		vctx.scale(scale, scale);
		vctx.beginPath();
		
		vctx.arc(0, 0, 6, 0, Math.PI * 2, true);
		vctx.stroke();
		vctx.fill();
		vctx.closePath();
		vctx.beginPath();
		vctx.arc(0, 0, 4, 0, Math.PI * 2, true);
		vctx.fillStyle = col;
		vctx.fill();
		vctx.restore();
	}
}

function schalter(ctx, x, y, scale, val, orientation = 'Links') {
	const rotation =    (orientation === 'Oben') ? 90 :
						(orientation == 'Rechts') ? 180 :
						(orientation == 'Unten') ? 270 : 0;
				
	ctx.save();
	ctx.strokeStyle = "black";
	ctx.lineWidth = 2;
	ctx.translate(x, y);
	ctx.rotate(Math.PI / 180 * rotation);
	ctx.scale(scale, scale);
	ctx.beginPath();
	//Kreis zeichnen
	ctx.moveTo(-20, 0);
	ctx.lineTo(-10, 0);
	ctx.lineTo(13, (val) ? -3 : -15);

	ctx.moveTo(10, -5);
	ctx.lineTo(10, 0);
	ctx.lineTo(20, 0);

	ctx.stroke();
	ctx.restore();
}


// Hintergrundfarbe setzen
function initBGColors() {
	var n = visudata.VCOData.Bitmaps.length;
	for (var i = 0; i < n; i++) {
		var url = visudata.VCOData.Bitmaps[i].URL;
		var bgcol = getBGColor(url);
		bgColors.push(bgcol);
	}
}

// Bitmap setzen
function setBitmap(idx) {
	$("#vimgTarget").remove();
	$("#vimgArea").prepend("<img id='vimgTarget' src='" + visudata.VCOData.Bitmaps[idx].URL + "' class='vcoveredImage'>");
	$(".vinsideWrapper").css("background-color", bgColors[bmpIndex]);
}


// Mousebutton Eventhandler für Bitmapwechsel
//function handleMouseDown(e) {
//	mx = parseInt(e.clientX - offsetX);
//	my = parseInt(e.clientY - offsetY);
//	var n = LinkButtonList.length;
//	for (var i = 0; i < n; i++) {
//		var item = LinkButtonList[i];
//		if (mx > item.x_min && mx < item.x_max && my > item.y_min && my < item.y_max) {
//			//log(item.x + " " + item.y);
//			//log(item.x_min + " " + item.x_max + " " + item.y_min + " " + item.y_max + " - " + mx + " / " + my);
//			bmpIndex = item.bmp;
//			setBitmap(bmpIndex);
//			requestDrawing();
//		}
//	}
//}

// Mousebutton Eventhandler für Bitmapwechsel
function handleMouseDown(e) {
	mx = parseInt(e.clientX - canvasOffsetX);
	my = parseInt(e.clientY - canvasOffsetY);
	var n = LinkButtonList.length;
	match = false;							//Flag zur Click-treffer Erkennung (es ist nicht davon auszugehen, dass es keine doppelten Click-treffer gibt!)
	if (!match) {
		for (var i = 0; i < n; i++) {
			var item = LinkButtonList[i];
			if (mx > item.x_min && mx < item.x_max && my > item.y_min && my < item.y_max) {
				match = true;
				//log(item.x + " " + item.y);
				//log(item.x_min + " " + item.x_max + " " + item.y_min + " " + item.y_max + " - " + mx + " / " + my);

				/*bmpIndex = item.bmp;
				setBitmap(bmpIndex);
				requestDrawing();*/

				if (bmpIndex != item.bmp) {
					bmpIndex = item.bmp;
					setBitmap(bmpIndex);
					requestDrawing();
					DrawVisu(true);
				}
			}
		}
	}

	//if (!match) openFaceplate();
}


// Zeichen-Hauptfunktion. Wird bei Bedarf von Timer aufgerufen
function DrawVisu(redrawStat = false) {
	vDynCtx.clearRect(0, 0, vDynCanvas.width, vDynCanvas.height);
	drawPropertyList();

	if (redrawStat) {
		vStatCtx.clearRect(0, 0, vStatCanvas.width, vStatCanvas.height);
		drawTextList();
	}
}

// Linkbutton in Liste eintragen
function addLinkButtonToList(x, y, w, h, orientation, targetBmp, txt) {
	var item = new Object();
	item["txt"] = txt;
	item["x"] = x;
	item["y"] = y;
	0 - 6, 0 - item.BgHeight - 6, w + 16, item.BgHeight + 16

	//Referenzpunkt (x,y = TextBeginn unten links bei orientation==hor)
	if (orientation == "hor") {
		item["x_min"] = x - 6;
		item["y_min"] = y - h - 6;
		item["x_max"] = item.x_min + w + h;
		item["y_max"] = item.y_min + 2 * h;
		item["bmp"] = targetBmp;
	}
	if (orientation == "up") {
		item["x_min"] = x - h - 6;
		item["y_max"] = y + 6;
		item["y_min"] = item.y_max - w - h;
		item["x_max"] = item.x_min + 2 * h;
		item["bmp"] = targetBmp;
	}
	if (orientation == "dn") {
		item["x_max"] = x + h + 6;
		item["y_min"] = y - 6;
		item["x_min"] = item.x_max - 2 * h;
		item["y_max"] = item.y_min + w + h;
		item["bmp"] = targetBmp;
	}

	// get coordinate of the stoerung button
	if (txt == "anstehende Störungen") {
		xStoerButtonMin = item.x_min;
		xStoerButtonMax = item.x_max;
		yStoerButtonMin = item.y_min;
		yStoerButtonMax = item.y_max;
	}
	//get coordinate of button zähler archiv
	if (txt == "Zähler Archiv") {
		xArchivButton = item.x_min;
		yArchivButton = item.y_min;
		xArchivButtonBot = item.x_max;
		yArchivButtonBot = item.y_max;
	}

	//get coordinate of button zähler anzeigen
	if (txt == "Zähler anzeigen") { // & FreitextList[i].BgColor == "slateBlue ") {
		xZaehlerButtonNeuMin = item.x_min;
		yZaehlerButtonNeuMin = item.y_min;
		xZaehlerButtonNeuMax = item.x_max;
		yZaehlerButtonNeuMax = item.y_max;
	}

	//get coordinate of Button IPKamera1
	if (txt == "IP Kamera 1") { // &  FreitextList[i].BgColor == "#ff9966") {
		xIPKamera1Button = item.x_min;
		yIPKamera1Button = item.y_min;
		xIPkamera1ButtonBot = item.x_max;
		yIPkamera1ButtonBot = item.y_max;
	}

	//get coordinate of Button IPKamera2
	if (txt == "IP Kamera 2") { // & FreitextList[i].BgColor == "#ff9966") {
		xIPKamera2Button = item.x_min;
		yIPKamera2Button = item.y_min;
		xIPkamera2ButtonBot = item.x_max;
		yIPkamera2ButtonBot = item.y_max;
	}

	//Anzeige des Clickbereichs für Button
	//vStatCtx.fillRect(item["x_min"], item["y_min"], item["x_max"] - item["x_min"], item["y_max"] - item["y_min"]);

	LinkButtonList.push(item);
}

// Gedroptes zeichen
function _drawDropList() {
	var DropList = visudata.DropList;

	var n = DropList.length;
	for (i = 0; i < n; i++) {
		drawVCOItem(DropList[i]);
	}
}


// Properties zeichnen incl. Symbole
function drawVCOItem(item) {
	if (item.bmpIndex == bmpIndex) {
		const msr = `${item.VCOItem.Bez.trim()}${parseInt(item.VCOItem.Kanal)}`;
		let svalue = "-";

		const liveDataItem = VisuDownload.Items.find(liveDataItem => msr === `${liveDataItem.Bezeichnung.trim()}${parseInt(liveDataItem.Kanal)}`);
		if (liveDataItem) {
			const {Bezeichnung, sWert, Wert, Nachkommastellen} = liveDataItem;
			svalue = (Bezeichnung.trim() === "HKNA") ? sWert : parseFloat(Wert).toFixed(Nachkommastellen);
		}

		const val = parseFloat(svalue.trim());
		if (item.VCOItem.isBool) {
			if (item.Symbol.match(/(fpButton)|(Heizkreis)/)) {
				fpButton(vDynCtx, item.x, item.y, val);
			}

			if (item.Symbol == "Absenkung") {
				Absenkung(vDynCtx, item.x, item.y, 1, val);
			}

			if (item.Symbol == "Feuer") {
				if (val)
				feuer(vDynCtx, item.x, item.y, 1);
			}

			if (item.Symbol == "BHKW") {
				BHDreh(vDynCtx, item.x, item.y, 1, TimerCounter * 30 * val);
			}

			if (item.Symbol == "Pumpe") {
				pmpDreh2(vDynCtx, item.x, item.y, 1, TimerCounter * 30 * val);
			}
			
			const rotation =    (item.SymbolFeature === "Rechts") ? 180 :
								(item.SymbolFeature === "Oben") ? 90 :
								(item.SymbolFeature === "Unten") ? 270 : 0;
			if (item.Symbol == "Luefter") {
				const angle = (val) ? TimerCounter * 30 : 30;
				luefter(vDynCtx, item.x, item.y, 1, angle, rotation);
			}

			if (item.Symbol === "Ventil") {
				if (val) {
					ventil(vDynCtx, item.x, item.y, 2, rotation);
				}
			}
			if (item.Symbol === "VentilFilled") {
				if (val) {
					ventilFilled(vDynCtx, item.x, item.y, 1, rotation);
				}
			}

			if (item.Symbol.match(/(Lueftungsklappe)|(Abluftklappen)/)) {
				const _val = (val === 1) ? 100 : val;
				lueftungsklappe(vDynCtx, item.x, item.y, 1, _val, item.SymbolFeature);                            
			}

			if (item.Symbol === "Led") {
				const falseColor = (item.SymbolFeature.match(/(gruen\/)/)) ? `green` :
								   (item.SymbolFeature.match(/(rot\/)/)) ? `red` :
								   undefined;
				const trueColor = (item.SymbolFeature.match(/(\/gruen)/)) ? `green` :
								  (item.SymbolFeature.match(/(\/rot)/)) ? `red` :
								  undefined;
				const blink = item.SymbolFeature.match(/(blinkend)/);
				const _val = !!parseInt(svalue);
				const currentColor = (_val) ? trueColor : falseColor;

				if (!(blink && TimerToggle)) {
					Led(vDynCtx, item.x, item.y, 1, currentColor);
				}
			}

			if (item.Symbol == "Schalter") {
				schalter(vDynCtx, item.x, item.y, 1, val, item.SymbolFeature);
			}

			hasSymbolsFlag = true;
		}
		else {
			VisuDownload.Items.find(liveDataItem => `GR2` === `${liveDataItem.Bezeichnung.trim()}${parseInt(liveDataItem.Kanal)}`);
		
			const isGassensor = (item.VCOItem.Bez.trim() === "GA");
			const warngrenze = (isGassensor) ? VisuDownload.Items.find(liveDataItem => `GR2` === `${liveDataItem.Bezeichnung.trim()}${parseInt(liveDataItem.Kanal)}`) : undefined;
			const stoergrenze = (isGassensor) ? VisuDownload.Items.find(liveDataItem => `GR3` === `${liveDataItem.Bezeichnung.trim()}${parseInt(liveDataItem.Kanal)}`) : undefined;
			vDynCtx.fillStyle = (item.VCOItem.Bez.trim() === "KES") ? `#fc1803` :
								(val > stoergrenze) ? `#fc1803`:
								(val > warngrenze) ? `#fcdf03` :
								(isGassensor) ? `#42f545` :
						   		item.BgColor;

			const txt = `${svalue} ${item.VCOItem.sEinheit}`;
			const txtWidth = vDynCtx.measureText(txt).width;
			vDynCtx.fillRect(item.x - 1, item.y - item.BgHeight - 1, txtWidth + 2, item.BgHeight + 3);
			
			vDynCtx.font = item.font;
			vDynCtx.fillStyle = item.Color;
			vDynCtx.fillText(txt, item.x, item.y);
		}
	}
}


// Aufruf Funktion
function drawPropertyList() {
	_drawDropList();
}

// Aufruf Funktion
function drawTextList() {
	var FreitextList = visudata.FreitextList;
	var n = FreitextList.length;
	LinkButtonList = [];	//LinkButtonList leeren -> wird nachfolgend neu erzeugt
	for (i = 0; i < n; i++) {
		var item = FreitextList[i];
		if (FreitextList[i].bmpIndex == bmpIndex) {
			var x = item.x;
			var y = item.y;
			var txt = item.Freitext;
			vStatCtx.font = item.font;
			vStatCtx.fillStyle = item.BgColor;
			var w = vStatCtx.measureText(txt).width;

			if (item.isVerweis) {
				vStatCtx.save();
				vStatCtx.translate(x, y);
				if (item.VerweisAusrichtung == "up")
					vStatCtx.rotate(-Math.PI / 2);
				if (item.VerweisAusrichtung == "dn")
					vStatCtx.rotate(Math.PI / 2);
				vStatCtx.fillRect(0 - 6, 0 - item.BgHeight - 6, w + 16, item.BgHeight + 16);
				vStatCtx.strokeStyle = "black";
				vStatCtx.strokeRect(0 - 6, 0 - item.BgHeight - 6, w + 16, item.BgHeight + 16);
				vStatCtx.fillStyle = item.Color;
				vStatCtx.fillText(txt, 0, 0);
				vStatCtx.restore();
				addLinkButtonToList(x, y, w, item.BgHeight, item.VerweisAusrichtung, item.idxVerweisBitmap, txt);
			}
			else {
				vStatCtx.fillRect(x - 1, y - item.BgHeight - 1, w + 2, item.BgHeight + 3);
				vStatCtx.fillStyle = item.Color;
				vStatCtx.fillText(txt, x, y);
			}
		}
	}
}


// 

// Loggen
function log(s) {
	$('#output').append(new Date().toLocaleTimeString() + " " + s + "<br />");
	//var objDiv = document.getElementById("output");
	//objDiv.scrollTop = objDiv.scrollHeight;
}

function createVisuTransferObject(fName) {

	var vto = new Object();
	if (fName == undefined)
		vto["FileName"] = "VisuSnapshot";
	else
		vto["FileName"] = fName;
	vto["DropList"] = DropList;
	vto["FreitextList"] = FreitextList;
	vto["VCOData"] = jsonVCOData;
	return vto;
}

function DeployVisu() {
	var vto = createVisuTransferObject();
	var svto = JSON.stringify({ 'vto': vto });
	//saveSnapshotToServer(svto);
	return svto;
}


function ReloadData() {
	var date = new Date();
	var rawvisuData = getOnlineData(IdVisu);
	//createVisudata(rawvisuData);

	if (rawvisuData != "") {
		VisuDownload = $.parseJSON(rawvisuData);
		DrawVisu();
		document.querySelector('#vupdateStatus-bar').style.color = 'black';
		document.querySelector('#vupdateStatus-info').textContent = 'Letzte Datenaktualisierung: ' + date.toLocaleString("de-DE");
		//console.log("Letzte Datenaktualisierung:" + Date().toLocaleString());
	}
	else {
		document.querySelector('#vupdateStatus-bar').style.color = 'red';
		if (document.querySelector('#vupdateStatus-info').textContent == " ") document.querySelector('#vupdateStatus-info').textContent = 'Datenaktualisierung fehlgeschlagen!';
		//console.log("Datenaktualisierung fehlgeschlagen!");
	}
}



//function ReloadData() {

//	var date = new Date();
//	var Data = getOnlineData(IdVisu);
//	if (Data != "") {
//		VisuDownload = $.parseJSON(Data);
//		Draw();
//	}
//	else
//		log("Reload: Keine Daten verfügbar");
//}


// Zeichen-Hauptfunktion. Wird bei Bedarf von Timer aufgerufen
function DrawVisu(redrawStat = false) {
	vDynCtx.clearRect(0, 0, vDynCanvas.width, vDynCanvas.height);
	drawPropertyList();

	if (redrawStat) {
		vStatCtx.clearRect(0, 0, vStatCanvas.width, vStatCanvas.height);
		drawTextList();
	}

}

function UpdateLabelMouseOverHandler() {
	$('#xlabel').css("background-color", "red");
}

function UpdateLabelMouseOutHandler() {
	$('#xlabel').css("background-color", "lightgrey");

}


/*Ab hier Visu Bedienung:*/
// When the user clicks anywhere outside of the Modal, close it
window.onclick = function (event) {
	var modals = Array.from(document.getElementsByClassName("modalVisuBg"));
	modals.forEach(function (el) {
		if (el == event.target) {
			if (el.id.includes('fp')) closeFaceplate();
			if (el.id.includes('Pin')) closePinModal();
			if (el.id.includes('Kalender')) closeModalWochenKalenderImVisu();
		}
	});
}

function closeFaceplate() {
	destroyFaceplate();
	hideElemementById('fpBg');
	hideElemementById('osk');
	//AnchorHandler(1);	//Sprung ins Hauptmenü, wenn Kalender geschlossen wird
}

function destroyFaceplate() {
	var modalBody = document.getElementById('fpBody');
	while (modalBody.firstChild) {
		modalBody.removeChild(modalBody.firstChild);
	}
}


function updateSliderValue(event) {
	var sliderValue;
	var slider;
	(typeof event) == 'string' ? slider = document.getElementById(event) : slider = document.getElementById(event.target.id);

	//Fehlerausstieg bei nicht vorhandenem Slider
	if (slider == null || slider == undefined) return -100;

	//Einheit ermitteln und zusammen mit aktuellem SliderWert in lblUnitFaceplate schreiben
	var unit;
	slider.id.includes('Pumpe') ? unit = document.getElementById('inputWertPumpen Handwert').nextSibling.textContent.trim() : unit = '%';
	slider.nextSibling.textContent = slider.value + ' ' + unit;
	/*
	//aktuellen SliderWert in lblUnitFaceplate schreiben
	(unit.includes('mWS')) ? slider.nextSibling.textContent = slider.value + ' mWS' : slider.nextSibling.textContent = slider.value + ' %';*/

	//Interpretation und Anzeige der Extremwerte
	if (slider.id == 'inputWertFaceplateBetriebsart') {	//Sollwert Handbetrieb Kessel/BHKW
		if (slider.value < 2) slider.nextSibling.textContent = 'Auto';
	}
	if (slider.id.includes('Mischer') || slider.id.includes('Ventil')) {
		if (slider.value < 1) slider.nextSibling.textContent = 'Zu';
		if (slider.value >= 100) slider.nextSibling.textContent = 'Auf';
	}
	if (slider.id.includes('Pumpe') && slider.value <= 2) slider.nextSibling.textContent = 'Min';
	if (slider.id.includes('Kesselpumpe') && slider.value <= 1) slider.nextSibling.textContent = 'Auto';

	if (slider.id.includes('Pumpe')) {
		//Wenn HK-Betriebsart && Pmp-Betriebsart == HandEin => SliderWert auch in versteckte Elemente 'inputWertPumpen Handwert' & 'inputWertBetriebsart' übernehmen; (minWert auf 2 begrenzen) 
		console.log(document.getElementById('btnHKHandEin').disabled, document.getElementById('btnHKPmpHandEin').disabled)
		if (document.getElementById('btnHKHandEin').disabled && document.getElementById('btnHKPmpHandEin').disabled) {
			//(minWert auf 2 begrenzen)
			document.getElementById('inputWertFaceplatePumpen Handwert').value > 2 ? sliderValue = document.getElementById('inputWertFaceplatePumpen Handwert').value : sliderValue = 2;

			document.getElementById('inputWertPumpen Handwert').value = sliderValue;
			document.getElementById('inputWertBetriebsart').value = sliderValue;
		}
	}

	//Wenn Kessel/BHKW-Betriebsart == HandEin => SliderWert auch in verstecktes Element 'inputWertBetriebsart' übernehmen; (Werte<2 als 1 [Auto Sollwert] interpretieren)
	var btnKesselHandEin = document.getElementById('btnKesselHandEin');
	if (btnKesselHandEin != null) {
		if (btnKesselHandEin.disabled) {
			document.getElementById('inputWertBetriebsart').value = document.getElementById('inputWertFaceplateBetriebsart').value;
			//Werte<2 als 1 [Auto Sollwert] interpretieren!
			if (document.getElementById('inputWertBetriebsart').value < 2) document.getElementById('inputWertBetriebsart').value = 1;
		}
	}

	//Wenn Betriebsart Kesselpumpe == Hand => SliderWert auch in verstecktes Element 'inputWertKesselpumpe' übernehmen; (Wert=0 [BETRIEBSARTKesselpumpeAuto] als 1 [HANDWERTKesselpumpeAuto] interpretieren)
	var btnKesselPmpHandEin = document.getElementById('btnKesselPmpHandEin');
	if (btnKesselPmpHandEin != null) {
		if (btnKesselPmpHandEin.disabled) {
			//Wert=0 [BETRIEBSARTKesselpumpeAuto] als 1 [HANDWERTKesselpumpeAuto] interpretieren!
			document.getElementById('inputWertFaceplateKesselpumpe').value > 0 ? sliderValue = document.getElementById('inputWertFaceplateKesselpumpe').value : sliderValue = 1;
			document.getElementById('inputWertKesselpumpe').value = sliderValue;
		}
	}

	//Wenn AnalogMischer/Ventil-Betriebsart == Hand => SliderWert auch in verstecktes Element 'inputWertMischer' übernehmen; (Wert=0 [Auto] als -1 [Dauer Zu] interpretieren)
	var btnMischerHand = document.getElementById('btnMischerHand');
	if (btnMischerHand != null) {
		if (btnMischerHand.disabled) {
			document.getElementById('inputWertMischer').value = document.getElementById('inputWertFaceplateMischer').value;
			//Wert=0 [Auto] als -1 [Dauer Zu] interpretieren!
			if (document.getElementById('inputWertMischer').value == 0) document.getElementById('inputWertMischer').value = -1;
		}
	}
	var btnVentilHand = document.getElementById('btnVentilHand');
	if (btnVentilHand != null) {
		if (btnVentilHand.disabled) {
			document.getElementById('inputWertVentil').value = document.getElementById('inputWertFaceplateVentil').value;
			//Wert=0 [Auto] als -1 [Dauer Zu] interpretieren!
			if (document.getElementById('inputWertVentil').value == 0) document.getElementById('inputWertVentil').value = -1;
		}
	}
	return sliderValue;
}


function getRelatedInputWertForBtn(btn) {
	var inputWert;
	Array.from(btn.parentNode.children).forEach(function (el) {
		if (el.className == 'inputWert') inputWert = el;
	});
	return inputWert;
}


function getBetriebsartValueForBtn(btn) {
	var val;

	//Betriebsart & generic
	if (btn.id.includes("Auto")) val = 0;
	//if (btn.id.includes("Hand")) val = document.getElementById('inputWertBetriebsart').value;	//Wert aus Betriebsart übernehmen;
	if (btn.id.includes("HandEin")) val = 1;
	if (btn.id.includes("HandAus")) val = -1;

	//Kessel & BHKW Betriebsart (Sollwert Handbetrieb)
	if (btn.id.includes("btnKesselHandEin") || btn.id.includes("btnBHKWHandEin")) val = document.getElementById('inputWertFaceplateBetriebsart').value;	//Wert aus Betriebsart übernehmen;

	//Mischer
	if (btn.id.includes("HandAuf")) val = 1;
	if (btn.id.includes("HandZu")) val = 2;
	if (btn.id.includes("Stopp")) val = -1;
	if (btn.id == "btnMischerHand") {	//bei Analogmischer SliderWert übernehmen, dabei Wert=0 [Auto] als -1 [Dauer Zu] interpretieren!
		val = document.getElementById('inputWertFaceplateMischer').value;
		if (val == 0) val = -1;
	}
	if (btn.id == "btnVentilHand") {	//bei Analogventil SliderWert übernehmen, dabei Wert=0 [Auto] als -1 [Dauer Zu] interpretieren!
		val = document.getElementById('inputWertFaceplateVentil').value;
		if (val == 0) val = -1;
	}

	//HK-Pumpe
	if (btn.id.includes("HKPmpAuto")) val = document.getElementById('inputWertBetriebsart').value;	//Wert aus Betriebsart übernehmen
	if (btn.id.includes("HKPmpHandEin")) val = updateSliderValue('inputWertFaceplatePumpen Handwert');	//Wert aus Slider Übernehmen, dabei Werte < 2 als 2 interpretieren!
	//"PmpHandAus" s.o. (wird durch "if (btn.id.includes("HandAus")) val = -1;" abgedeckt!)

	//Kessel-Pumpe
	if (btn.id.includes("KesselPmpHandEin")) val = updateSliderValue('inputWertFaceplateKesselpumpe');	//Wert aus Slider Übernehmen

	return val;
}



function RadioBtnBehaviorByName(event) {
	if (event == null || event == undefined) return -100;

	var btn;
	(typeof event) == 'string' ? btn = document.getElementById(event) : btn = document.getElementById(event.target.id);
	//console.log(btn);

	if (btn == null || btn == undefined) return -100;

	var relatedBtns = document.getElementsByName(btn.name);

	//TriggerBtns
	if (btn.id.includes('Trigger')) {	//Trigger btns have checkbox behavior too
		if (btn.className.includes("Checked")) {	//uncheck btn
			btn.className = btn.className.replace("Checked", "");
			getRelatedInputWertForBtn(btn).value = 0;	//Wert in verstecktes inputWert-Element übernehmen
		}
		else {	//check btn & uncheck relatedBtns
			relatedBtns.forEach(function (el) {
				if (el.id == btn.id) {
					el.className += "Checked";
					getRelatedInputWertForBtn(el).value = 1;	//Wert in verstecktes inputWert-Element übernehmen
				}
				else {
					el.className = el.className.replace("Checked", "");
					getRelatedInputWertForBtn(el).value = 0;	//Wert in verstecktes inputWert-Element übernehmen
				}
			});
		}
	}
	//All other Btns (Betriebsart, Mischer...)
	else {
		relatedBtns.forEach(function (el) {
			if (el.id == btn.id) {
				el.disabled = true;
				getRelatedInputWertForBtn(el).value = getBetriebsartValueForBtn(el);//1;	//Wert in verstecktes inputWert-Element übernehmen
				//return von getBetriebsartValueForBtn bzw. updateSliderValue prüfen?!
			}
			else {
				el.disabled = false
			}
		});
	}
}

function BetriebsartBtnHanlder(event) {
	//event darf auch ein ID-String sein!
	if (event == null || event == undefined) return -100;
	var btn;
	(typeof event) == 'string' ? btn = document.getElementById(event) : btn = document.getElementById(event.target.id);
	(typeof event) == 'string' ? RadioBtnBehaviorByName(event) : RadioBtnBehaviorByName(event.target.id);


	if (btn.id == "btnHKPmpHandAus") {		//Wenn Pumpe 'HandAus' => HK aus!
		btn = document.getElementById("btnHKHandAus");
		RadioBtnBehaviorByName(btn.id);
	}

	if (btn.id == "btnHKPmpAuto") {			//Wenn Pumpe 'Auto' => HK=HandEin, Pumpe=Auto [wert=1]
		document.getElementById('inputWertBetriebsart').value = 1;
		RadioBtnBehaviorByName(btn.id);//{		//Wenn Pumpe 'Auto' => HK=HandEin, Pumpe=Auto
	}

	if (btn.name == "btnHK") {    //BA HK geändert->Mi&Pu auf Auto
		var relatedBtns = Array.from(document.getElementsByClassName("btnAuto"));
		relatedBtns.forEach(function (el) {
			if (el.name != "btnHK") RadioBtnBehaviorByName(el.id);
		});
	}

	if (btn.id == "btnHKAuto" || btn.id == "btnHKHandAus") {    //BtnHKPmp sperren (Pmp->Auto bereits oben gesetzt) 
		var name = document.getElementsByName("btnHKPmp");
		name.forEach(function (el) {
			el.disabled = true;
			if (!(el.className.includes("NA"))) el.className += "NA";
		});
		RadioBtnBehaviorByName("btnHKPmpAuto");
	}

	if (btn.id == "btnHKHandEin") {                          //BtnBAPmp entsperren
		var name = document.getElementsByName("btnHKPmp");
		name.forEach(function (el) {
			el.className = el.className.replace("NA", "");
		});
		RadioBtnBehaviorByName("btnHKPmpAuto");
	}
	return 0;
}

function sendValueFromVisuToRtos(option) {
	var sendBackToRtosUrlList = [];
	var faceplateBody = document.getElementById('fpBody');
	var faceplateBodyList = Array.from(faceplateBody.children);
	var errorString = '';

	//normale Zurückübertragen mit Validierung der Eingabe; undefined kommt aus der onlickevent des html button (index.html)
	if (option == undefined) {
		faceplateBodyList.forEach(function (div) {
			var idx = parseInt(div.id.slice(-3)) - 90;
			div.childNodes.forEach(function (el) {
				if (el.className == 'inputWert'/*el.id.includes('inputWert')*/) {
					if (idx == 0) {
						ClickableElement[idx].wert = el.value.padEnd(20, ' ').slice(0, 20);
					}
					else {
						//Numerische Validierung
						var value = parseFloat(el.value);
						if (!isNaN(value) && el.value.trim() != '') {		//Wenn nicht leer und Fehlerfrei: neuen rtos-Wert prüfen & überschreiben
							//Wertebereich prüfen und ggf. korrigieren
							var unterGrenze = parseFloat(ClickableElement[idx].unterGrenze.trim());
							var oberGrenze = parseFloat(ClickableElement[idx].oberGrenze.trim());

							el.style.color = 'black';
							el.previousSibling.style.color = 'black';
							el.nextSibling.style.color = 'black';

							if (value < unterGrenze) {
								errorString += el.previousSibling.textContent + ': ' + 'min = ' + unterGrenze + '\n';
								el.style.color = '#C31D64';
								el.previousSibling.style.color = '#C31D64';
								el.nextSibling.style.color = '#C31D64';
								//el.value = unterGrenze.toString();
							}
							if (value > oberGrenze) {
								errorString += el.previousSibling.textContent + ': ' + 'max = ' + oberGrenze + '\n';
								el.style.color = '#C31D64';
								el.previousSibling.style.color = '#C31D64';
								el.nextSibling.style.color = '#C31D64';
								//el.value = oberGrenze.toString();//ClickableElement[idx].oberGrenze;
							}

							var returnValue = el.value.split('.');	//Trennung in Vor- & Nachkommastellen zur Formatierung; hier auch stringLängenkorrektur
							ClickableElement[idx].wert = returnValue[0].padStart(5, ' ').slice(-5) + '.';
							if (returnValue.length > 1) {
								ClickableElement[idx].wert += returnValue[1].padEnd(4, '0').slice(0, 4);
							}
							else {
								ClickableElement[idx].wert += '0000';
							}
						}
						else {	//isNaN || empty
							el.style.color = '#C31D64';
							if (el.previousSibling != null) el.previousSibling.style.color = '#C31D64';
							if (el.nextSibling != null) el.nextSibling.style.color = '#C31D64';
							if (el.previousSibling != null) errorString += el.previousSibling.textContent + ': ';
							errorString += 'ungültige Zahl!' + '\n';
						}
					}
				}
			});
		});
	}
	//Wenn "Zum Wochekalender" -> Wert "HK Wochenkalender" auf 1 umstellen und weitere Daten unverändert zurückübertragen
	else { //if (option == 'openHKWochenKalender' || option == 'closeHKWochenKalender') {
		ClickableElement.forEach(function (el) {
			//console.log(el.name.trim());
			if (el.name.includes('Wochenk')) {
				//console.log('+' + el.wert + '+');
				//Kalender mit Schreibrechten öffnen
				if (option == 'openHKWochenKalender' && !locked) el.wert = el.wert.replace('0', '1');
				//Kalender OHNE Schreibrechte öffnen
				if (option == 'openHKWochenKalender' && locked) el.wert = el.wert.replace('0', '2');
				//if (option == 'closeHKWochenKalender') el.wert = el.wert.replace('1', '0');
				//console.log('+' + el.wert + '+');
			}
		});
	}
	if (errorString == '') {
		//erzeugt Linkliste
		for (var i = 0; i < 20; i++) {
			var sendBackData = '';
			var link = ''
			var idForTranfer = 'v' + (i + 90).toString().padStart(3, '0');
			//1.Zeile auffüllen auf 60 Zeichen
			if (i == 0) {
				sendBackData += (ClickableElement[i].name + ClickableElement[i].wert).padEnd(60, ' ');
				link = 'http://' + IPE + '/JSONADD/PUT?' + idForTranfer + '=' + encodeURIComponent('"' + sendBackData + '"');
				sendBackToRtosUrlList.push(link);
			}
			else {
				sendBackData = ClickableElement[i].name + ClickableElement[i].wert + '  ' + ClickableElement[i].oberGrenze + ' ' +
					ClickableElement[i].unterGrenze + ' ' + ClickableElement[i].nachKommaStellen + ' ' + ClickableElement[i].einheit + '    ' + ClickableElement[i].lastItem;
				link = 'http://' + IPE + '/JSONADD/PUT?' + idForTranfer + '=' + encodeURIComponent('"' + sendBackData + '"');
				sendBackToRtosUrlList.push(link);
			}
		}
		//Linkliste an Rtos senden
		for (var j = 0; j < sendBackToRtosUrlList.length; j++) {
			sendDataWT(sendBackToRtosUrlList[j]);
			//console.log(sendBackToRtosUrlList[j]);
		}
		if (option == undefined) closeFaceplate();
		return 0;
	}
	else {
		alert(errorString);
		return -100;
	}
}


function openFaceplate() {
	/*SettingsFromVisualisierung*/
	//handle for button click and clickable item, same philosophy as bitmap change of non linked element above

	var n = ClickableElementList.length;
	for (var i = 0; i < n; i++) {
		var item = ClickableElementList[i];

		//check bitmap referenz to avoid interferenz between layer
		var currentBitmapIndex = bmpIndex;

		/********************* Heizkreise *************************/
		if ((item.bitmapIndex == currentBitmapIndex) && (item.Bezeichnung == "HK" || item.Bezeichnung == "KES" || item.Bezeichnung == "BHK" || item.Bezeichnung == "WWL")) {
			dx = mx - item.x;
			dy = my - item.y;
			if (dx * dx + dy * dy < item.radius * item.radius) {
				match = true;
				var matchItem = item;


				//search in the link list of clickable element base on unique id to find out the coresspondent link 
				for (var j = 0; j < ClickableElementUrlList.length; j++) {
					if (ClickableElementUrlList[j].indexOf(item.id) >= 0) {
						clickableElementUrl = ClickableElementUrlList[j];
					}
				}

				/*query the available adjustable params from RTOS in two step
					1. tell the RTOS-Webserver, which elemente will be queried
					2. wait at least "700ms" and get the information provided by RTOS-Webserver
				*/
				sendDataWT(clickableElementUrl);
				sleep(1000);
				var adjustmentOption = JSON.parse(getData(readParameterOfClickableElementUrl));

				ClickableElement = [];
				//24 stellig für Name , 10 stellig für Werte, 2 Leerzeichen, 5 stellig für Obergrenze, 1 Leerzeichen, 5 stellig für Untergrenze, 1 Leerzeichen, 1 stellig für Nachkommastellen, 1 Leerzeichen, 5 stellig für Einheit
				for (var j = 70; j < 90; j++) {
					var rtosVariable = "v0" + j;
					var option = adjustmentOption[rtosVariable];
					var item = new Object();
					item['name'] = option.substr(0, 24);
					if (j == 70) {
						var modalId = item['name'].trim();
						item['wert'] = option.substr(24, 20)
						item["oberGrenze"] = '';
						item["unterGrenze"] = '';
						item["nachKommaStellen"] = '';
						item["einheit"] = '';
						item["lastItem"] = option.substr(59, 1);
					}
					else {
						item['wert'] = option.substr(24, 10);
						item["oberGrenze"] = option.substr(36, 5);
						item["unterGrenze"] = option.substr(42, 5);
						item["nachKommaStellen"] = option.substr(48, 1);
						item["einheit"] = option.substr(50, 5);
						item["lastItem"] = option.substr(59, 1);
					}
					//console.log(item);
					ClickableElement.push(item);
				}

				buildFaceplate();

			}
		}
	}

	if (match) showFaceplate(matchItem);//modal.style.display = "block";
}

function buildFaceplate() {
	var faceplateID = ClickableElement[0].name;
	var faceplateTyp = faceplateID.slice(0, 3).trim();
	if (faceplateTyp == 'KES') {
		faceplateTyp = 'Kessel';
		faceplateID = 'Kessel' + faceplateID.trim().slice(-2);
	}
	if (faceplateTyp == 'BHK') {
		faceplateTyp = 'BHKW';
		faceplateID = 'BHKW' + faceplateID.trim().slice(-2);
	}

	var modal = document.getElementById('fpBg');
	var modalHeader = document.getElementById('txtFpHeader');
	modalHeader.innerHTML = 'Einstellungen für ' + faceplateID;
	var modalBody = document.getElementById('fpBody');


	for (var j = 0; j < ClickableElement.length; j++) {

		var div = document.createElement('div');
		div.id = 'v' + (j + 90).toString().padStart(3, '0');
		modalBody.appendChild(div);

		//Für leere Zeilen nur inputWert versteckt im Faceplate einfügen (enthält leeren 'Rohwert aus ClickableElement)
		if (ClickableElement[j].name.trim() == '') {
			/*var inputWert = document.createElement('input');
			inputWert.type = 'text';
			inputWert.value = ClickableElement[j].wert;
			inputWert.className = 'inputWert';
			inputWert.style.display = 'none';
			div.appendChild(inputWert);*/
		}
		else {

			var lblName = document.createElement('label');
			lblName.className = 'lblName';

			//ggf. Zwischenüberschrift einfügen
			var h5 = document.createElement('h5');
			var h6 = document.createElement('h6');
			if (j == 0) {
				h5.innerHTML = faceplateTyp + " Parameter:";
				lblName.innerHTML = "Name/Alias";
			}
			else {
				lblName.innerHTML = ClickableElement[j].name.trim();
			}

			if (ClickableElement[j].name.includes('Kesselpumpe')) h5.innerHTML = "Kesselpumpenparameter:";

			if (ClickableElement[j].name.includes('Mischer')) h5.innerHTML = faceplateTyp + ' Mischer Betriebsart:';
			if (ClickableElement[j].name.includes('Ventil')) h5.innerHTML = faceplateTyp + ' Ventil Betriebsart:';
			if (ClickableElement[j].name.includes('20 &degC')) {	//Startindikator Sektor Pumpenkennlinie
				h5.innerHTML = faceplateTyp + ' Pumpenparameter:';
				h6.innerHTML = "Kennlinie (Außentemperatur):";
			}
			if (ClickableElement[j].name.includes('Pumpen Handwert')) h6.innerHTML = "Pumpen Betriebsart:";

			if (ClickableElement[j].name.includes('Wochenk')) {	//Startindikator Sektor Wochenkalender & 
				h5.innerHTML = "Wochenkalender:";
			}
			if (h5.innerHTML != '') div.appendChild(h5);
			if (h6.innerHTML != '') div.appendChild(h6);

			div.appendChild(lblName);

			var inputWert = document.createElement('input');
			if (j == 0) {
				inputWert.type = 'text';
				inputWert.maxlength = 20;
				inputWert.disabled = true;
				//console.log(inputWert);*/
			}
			else {
				inputWert.type = 'number';
				//inputWert.maxlength = 10;
				inputWert.min = parseFloat(ClickableElement[j].unterGrenze.trim());
				inputWert.max = parseFloat(ClickableElement[j].oberGrenze.trim());
				inputWert.step = Math.pow(10, -ClickableElement[j].nachKommaStellen);
				inputWert.onclick = showOSK; //osk bei Eingabe einblenden
			}

			var nachKommaStelle = parseInt(ClickableElement[j].nachKommaStellen);
			if (isNaN(nachKommaStelle) || nachKommaStelle == 0) {
				inputWert.value = ClickableElement[j].wert.trim();
			}
			else {
				inputWert.value = ClickableElement[j].wert.trim().substring(0, (ClickableElement[j].wert.trim().indexOf('.') + nachKommaStelle + 1));
			}

			//inputWert.value = ClickableElement[j].wert.trim();

			inputWert.className = 'inputWert';
			inputWert.id = inputWert.className + ClickableElement[j].name.trim();
			div.appendChild(inputWert);

			var lblUnit = document.createElement('label');
			lblUnit.innerHTML = /*parseFloat(ClickableElement[j].wert.trim()) + ' ' +*/ ClickableElement[j].einheit.trim();
			lblUnit.className = 'lblUnit';
			div.appendChild(lblUnit);


			if (ClickableElement[j].name.includes('Betriebsart')) {		//Indikator Betriebsart;
				//HK Betriebsart merken, um Btn zu setzen
				var Betriebsart = ClickableElement[j].wert.trim();

				//lblName, inputWert & lblUnit ausblenden
				if (!DEBUG) {
					div.childNodes.forEach(function (el) {
						//if (!(faceplateTyp == 'HK' && el.className == 'lblName'))
						el.style.display = 'none';
						//if (el.className == 'inputWert' || el.className == 'lblUnit') el.style.display = 'none';
					});
				}

				if (faceplateTyp == 'Kessel' || faceplateTyp == 'BHKW') {
					var lblNameFaceplate = document.createElement('label');
					lblNameFaceplate.innerHTML = 'Sollwert Handbetrieb';
					lblNameFaceplate.className = 'lblNameFaceplate';
					div.appendChild(lblNameFaceplate);

					var inputWert = document.createElement('input');
					inputWert.type = 'range';
					inputWert.min = parseFloat(ClickableElement[j].unterGrenze.trim());
					inputWert.max = parseFloat(ClickableElement[j].oberGrenze.trim());
					inputWert.step = Math.pow(10, -ClickableElement[j].nachKommaStellen);
					inputWert.oninput = updateSliderValue;
					inputWert.value = ClickableElement[j].wert.trim();
					inputWert.className = 'inputWertFaceplate';
					inputWert.id = inputWert.className + ClickableElement[j].name.trim();
					div.appendChild(inputWert);

					var lblUnitFaceplate = document.createElement('label');
					lblUnitFaceplate.innerHTML = ClickableElement[j].einheit.trim();
					lblUnitFaceplate.className = 'lblUnitFaceplate';
					div.appendChild(lblUnitFaceplate);
					div.appendChild(document.createElement('br'));


					/*var lblName.innerHTML = 'Sollwert Handbetrieb';
					//lblUnit.innerHTML = parseFloat(ClickableElement[j].wert.trim()) + ' ' + ClickableElement[j].einheit.trim();
					inputWert.type = 'range';
					inputWert.oninput = updateSliderValue;
					updateSliderValue(inputWert.id);*/
				}

				var lblNameFaceplate = document.createElement('label');
				lblNameFaceplate.innerHTML = ClickableElement[j].name.trim();
				lblNameFaceplate.className = 'lblNameFaceplate';
				div.appendChild(lblNameFaceplate);

				var btnAuto = document.createElement('input');
				btnAuto.type = 'button';
				btnAuto.id = 'btn' + faceplateTyp + 'Auto';
				btnAuto.className = 'btnAuto';
				btnAuto.name = 'btn' + faceplateTyp;
				btnAuto.onclick = BetriebsartBtnHanlder;
				div.appendChild(btnAuto);

				var btnHandEin = document.createElement('input');
				btnHandEin.type = 'button';
				btnHandEin.id = 'btn' + faceplateTyp + 'HandEin';
				btnHandEin.className = 'btnHandEin';
				btnHandEin.name = 'btn' + faceplateTyp;
				btnHandEin.onclick = BetriebsartBtnHanlder;
				div.appendChild(btnHandEin);

				var btnHandAus = document.createElement('input');
				btnHandAus.type = 'button';
				btnHandAus.id = 'btn' + faceplateTyp + 'HandAus';
				btnHandAus.className = 'btnHandAus';
				btnHandAus.name = 'btn' + faceplateTyp;
				btnHandAus.onclick = BetriebsartBtnHanlder;
				div.appendChild(btnHandAus);

			}


			if (ClickableElement[j].name.includes('Mischer') || ClickableElement[j].name.includes('Ventil')) {
				//Mischer Betriebsart & Typ merken, um Btn zu setzen
				var mischerBetriebsart = ClickableElement[j].wert.trim();
				var mischerTyp = ClickableElement[j].einheit.trim();	//3P/Analog
				var mischerName = ClickableElement[j].name.trim();		//Mischer oder Ventil

				//lblName, inputWert & lblUnit ausblenden (enthalten Daten zur Rückübertragung)
				if (!DEBUG) {
					div.childNodes.forEach(function (el) {
						if (el.className == 'lblName' || el.className == 'inputWert' || el.className == 'lblUnit') el.style.display = 'none';
					});
				}
				/*//dafür Hilfslabel erzeugen & br einfügen:
				var lblUnitFaceplate = document.createElement('label');
				lblUnitFaceplate.innerHTML = '%';
				lblUnitFaceplate.className = 'lblUnitFaceplate';
				div.appendChild(lblUnitFaceplate);
				div.appendChild(document.createElement('br'));*/

				if (ClickableElement[j].einheit.includes('%') || FORCE_ANALOGMISCHER) {
					var lblNameFaceplate = document.createElement('label');
					lblNameFaceplate.innerHTML = ClickableElement[j].name.trim() + ' Öffnung';
					lblNameFaceplate.className = 'lblNameFaceplate';
					div.appendChild(lblNameFaceplate);

					var inputWert = document.createElement('input');
					inputWert.type = 'range';
					inputWert.min = parseFloat(ClickableElement[j].unterGrenze.trim());
					inputWert.max = parseFloat(ClickableElement[j].oberGrenze.trim());
					inputWert.step = Math.pow(10, -ClickableElement[j].nachKommaStellen);
					inputWert.oninput = updateSliderValue;
					inputWert.value = ClickableElement[j].wert.trim();
					inputWert.className = 'inputWertFaceplate';
					inputWert.id = inputWert.className + ClickableElement[j].name.trim();
					div.appendChild(inputWert);

					var lblUnitFaceplate = document.createElement('label');
					lblUnitFaceplate.innerHTML = ClickableElement[j].einheit.trim();
					lblUnitFaceplate.className = 'lblUnitFaceplate';
					div.appendChild(lblUnitFaceplate);
					div.appendChild(document.createElement('br'));
				}




				var lblNameFaceplate = document.createElement('label');
				lblNameFaceplate.innerHTML = ClickableElement[j].name.trim() + ' Betriebsart';
				lblNameFaceplate.className = 'lblNameFaceplate';
				div.appendChild(lblNameFaceplate);

				var btnAuto = document.createElement('input');
				btnAuto.type = 'button';
				btnAuto.id = 'btn' + ClickableElement[j].name.trim() + 'Auto';
				btnAuto.className = 'btnAuto';
				btnAuto.name = 'btn' + ClickableElement[j].name.trim();
				btnAuto.onclick = BetriebsartBtnHanlder;
				div.appendChild(btnAuto);

				if (ClickableElement[j].einheit.includes('%') || FORCE_ANALOGMISCHER) {
					//Bei Analogmischer nur btnHand erzeugen
					var btnHand = document.createElement('input');
					btnHand.type = 'button';
					btnHand.id = 'btn' + ClickableElement[j].name.trim() + 'Hand';
					btnHand.className = 'btnHand';
					btnHand.name = 'btn' + ClickableElement[j].name.trim();
					btnHand.onclick = BetriebsartBtnHanlder;
					div.appendChild(btnHand);
				}

				if (ClickableElement[j].einheit.includes('3P') && !FORCE_ANALOGMISCHER) {
					//lblName, inputWert & lblUnitFaceplate zusätzlich ausblenden
					if (!DEBUG) {
						div.childNodes.forEach(function (el) {
							if (el.className == 'lblName' || el.className == 'inputWert' || el.className == 'lblUnitFaceplate') el.style.display = 'none';
						});
					}

					var btnHandAuf = document.createElement('input');
					btnHandAuf.type = 'button';
					btnHandAuf.id = 'btn' + ClickableElement[j].name.trim() + 'HandAuf';
					btnHandAuf.className = 'btnHandAuf';
					btnHandAuf.name = 'btn' + ClickableElement[j].name.trim();
					btnHandAuf.onclick = BetriebsartBtnHanlder;
					div.appendChild(btnHandAuf);

					var btnHandZu = document.createElement('input');
					btnHandZu.type = 'button';
					btnHandZu.id = 'btn' + ClickableElement[j].name.trim() + 'HandZu';
					btnHandZu.className = 'btnHandZu';
					btnHandZu.name = 'btn' + ClickableElement[j].name.trim();
					btnHandZu.onclick = BetriebsartBtnHanlder;
					div.appendChild(btnHandZu);

					var btnStopp = document.createElement('input');
					btnStopp.type = 'button';
					btnStopp.id = 'btn' + ClickableElement[j].name.trim() + 'Stopp';
					btnStopp.className = 'btnStopp';
					btnStopp.name = 'btn' + ClickableElement[j].name.trim();
					btnStopp.onclick = BetriebsartBtnHanlder;
					div.appendChild(btnStopp);
				}
			}


			if (ClickableElement[j].name.includes('Pumpen Handwert') || ClickableElement[j].name.includes('Kesselpumpe')) {
				var HandwertKesselpumpe;
				if (ClickableElement[j].name.includes('Kesselpumpe')) HandwertKesselpumpe = ClickableElement[j].wert.trim();
				if (!DEBUG) {
					//inputWert & lblUnit ausblenden (enthält info über HK Betriebsart)
					div.childNodes.forEach(function (el) {
						if (el.className == 'inputWert' || el.className == 'lblUnit') el.style.display = 'none';
					});
				}
				//dafür Slider(range) erzeugen:
				var inputWert = document.createElement('input');
				inputWert.type = 'range';
				inputWert.min = parseFloat(ClickableElement[j].unterGrenze.trim());
				inputWert.max = parseFloat(ClickableElement[j].oberGrenze.trim());
				inputWert.step = Math.pow(10, -ClickableElement[j].nachKommaStellen);
				inputWert.oninput = updateSliderValue;
				inputWert.value = ClickableElement[j].wert.trim();
				inputWert.className = 'inputWertFaceplate';
				inputWert.id = inputWert.className + ClickableElement[j].name.trim();
				div.appendChild(inputWert);

				var lblUnit = document.createElement('label');
				lblUnit.innerHTML = ClickableElement[j].einheit.trim();
				lblUnit.className = 'lblUnitFaceplate';
				div.appendChild(lblUnit);

				div.appendChild(document.createElement('br'));

				var lblNameFaceplate = document.createElement('label');
				lblNameFaceplate.innerHTML = 'Betriebsart ' + faceplateTyp + '-Pumpe';
				lblNameFaceplate.className = 'lblNameFaceplate';
				div.appendChild(lblNameFaceplate);

				var btnAuto = document.createElement('input');
				btnAuto.type = 'button';
				btnAuto.id = 'btn' + faceplateTyp + 'PmpAuto';
				btnAuto.className = 'btnAuto';
				btnAuto.name = 'btn' + faceplateTyp + 'Pmp';
				btnAuto.onclick = BetriebsartBtnHanlder;
				div.appendChild(btnAuto);

				var btnHandEin = document.createElement('input');
				btnHandEin.type = 'button';
				btnHandEin.id = 'btn' + faceplateTyp + 'PmpHandEin';
				btnHandEin.className = 'btnHandEin';
				btnHandEin.name = 'btn' + faceplateTyp + 'Pmp';
				btnHandEin.onclick = BetriebsartBtnHanlder;
				div.appendChild(btnHandEin);

				if (faceplateTyp != 'Kessel') {		//HandAus bei Kesselpumpe nicht vorgesehen!
					var btnHandAus = document.createElement('input');
					btnHandAus.type = 'button';
					btnHandAus.id = 'btn' + faceplateTyp + 'PmpHandAus';
					btnHandAus.className = 'btnHandAus';
					btnHandAus.name = 'btn' + faceplateTyp + 'Pmp';
					btnHandAus.onclick = BetriebsartBtnHanlder;
					div.appendChild(btnHandAus);
				}
			}


			if (ClickableElement[j].name.includes('Einmalig')) {
				var btnID;
				if (ClickableElement[j].name.includes('EIN')) btnID = 'Ein';
				if (ClickableElement[j].name.includes('AUS')) btnID = 'Aus';
				if (ClickableElement[j].name.includes('Desinf.')) btnID = 'Desinf';

				//inputWert & lblUnit ausblenden
				if (!DEBUG) {
					div.childNodes.forEach(function (el) {
						if (el.className == 'inputWert' || el.className == 'lblUnit') el.style.display = 'none';
					});
				}

				//TriggerButton erzeugen
				var btnTrigger = document.createElement('input');
				btnTrigger.type = 'button';
				btnTrigger.id = 'btnTrigger' + btnID;
				btnTrigger.className = 'btn' + btnID;
				btnTrigger.name = 'btnTrigger';
				//btnTrigger.value = btnID;
				btnTrigger.onclick = RadioBtnBehaviorByName;
				div.appendChild(btnTrigger);
			}


			if (ClickableElement[j].name.includes('Wochenk')) {
				//inputWert & lblUnit ausblenden
				if (!DEBUG) {
					div.childNodes.forEach(function (el) {
						if (el.className == 'inputWert' || el.className == 'lblUnit') el.style.display = 'none';
					});
				}

				//SprungButton erzeugen
				var btnWochenkalender = document.createElement('input');
				btnWochenkalender.type = 'button';
				btnWochenkalender.id = 'btnWochenkalender';
				btnWochenkalender.value = 'zum Kalender';
				btnWochenkalender.onclick = jumpToWochenKalender;
				div.appendChild(btnWochenkalender);
			}
		}
	}

	//Btn entsprechend aktueller Betriebsart setzen und Verriegelung setzen
	//handleConfirmBtn(locked);


	var activeBtn;
	switch (Betriebsart) {
		case '-1':
			activeBtn = document.getElementById('btn' + faceplateTyp + 'HandAus');
			break;

		case '0':
			activeBtn = document.getElementById('btn' + faceplateTyp + 'Auto');
			break;

		case '1':
			activeBtn = document.getElementById('btn' + faceplateTyp + 'HandEin');
			break;

		default:
			activeBtn = document.getElementById('btn' + faceplateTyp + 'HandEin');
		//activeBtn = document.getElementById('btn' + faceplateTyp + 'Auto').nextSibling; //entspricht BtnHand oder BtnHandEin
	}
	if (activeBtn != null) BetriebsartBtnHanlder(activeBtn.id);
	if (faceplateTyp == 'HK' && Betriebsart > 1) BetriebsartBtnHanlder('btnHKPmpHandEin');


	if (faceplateTyp == 'Kessel') {
		updateSliderValue('inputWertFaceplateBetriebsart');
		updateSliderValue('inputWertFaceplateKesselpumpe');
		(HandwertKesselpumpe == 0) ? RadioBtnBehaviorByName('btn' + faceplateTyp + 'PmpAuto') : RadioBtnBehaviorByName('btn' + faceplateTyp + 'PmpHandEin');
	}


	if (faceplateTyp == 'HK') {
		updateSliderValue('inputWertFaceplatePumpen Handwert');

		if (mischerBetriebsart == '0') RadioBtnBehaviorByName('btn' + mischerName + 'Auto');
		if (mischerTyp != undefined && mischerTyp != null) {
			if (mischerTyp.includes('3P') && !FORCE_ANALOGMISCHER) {
				if (mischerBetriebsart == '-1') RadioBtnBehaviorByName('btn' + mischerName + 'Stopp');
				if (mischerBetriebsart == '1') RadioBtnBehaviorByName('btn' + mischerName + 'HandAuf');
				if (mischerBetriebsart == '2') RadioBtnBehaviorByName('btn' + mischerName + 'HandZu');
			}
			if (mischerTyp.includes('%') || FORCE_ANALOGMISCHER) {
				if (mischerBetriebsart != '0') RadioBtnBehaviorByName('btn' + mischerName + 'Hand');
				updateSliderValue('inputWertFaceplate' + mischerName);
			}
		}
	}
}


function jumpToWochenKalender() {
	//1.Deaktivieren Autoreload Funktion beim Fernbedienung ? (überlegung)
	clearInterval(fernbedienungAutoReload);
	//2.Der Wert 'HK Wochenkalender' wird auf 1 geändert und zurückübertragen (gesamte 20 Zeile)
	//Pearl-seitig wird das HK-Wochenkalender aufm Canvas gerendert.
	var sendError = sendValueFromVisuToRtos('openHKWochenKalender');
	if (!sendError) {
		//3.Modalfenster mit eingebettets Heizkreiswochenkalender einblenden oder Fernbedienung Tab im Iframe darstellen
		//showElemementById('wochenKalenderImVisu');
		showWochenKalenderVisu();
		activeTabID = 'wochenKalenderImVisu';
		wochenKalenderImVisuAutoReload = setInterval(refreshTextAreaWithoutParameterLocal, 50, wochenKalenderImVisuCanvasContext, wochenKalenderImVisuCanvas);
	}
}

function closeModalWochenKalenderImVisu() {
	hideElemementById('wochenKalenderImVisu');
	//sendData(clickableElementUrl);
	//sendValueFromVisuToRtos('closeHKWochenKalender');
	AnchorHandler(1);	//Sprung ins Hauptmenü, wenn Kalender geschlossen wird
	//showElemementById('osk');	//osk für Faceplate öffnen
}

function showOSK(event) {
	if (event.target.id.includes('inputWert')) showElemementById('osk');
}

function showFaceplate(matchItem) {
	const OFFSET_ICON_2_FACEPLATE_PX = 80;
	const OFFSET_FP_2_OSK = 40;
	var faceplateBackground = showElemementById('fpBg');
	var faceplateContent = document.getElementById('fpContent');
	var osk = showElemementById('osk');	//osk temporär zu Anordnungsberechnung öffnen; wird am Ende wieder geschlossen!

	if (matchItem.x + OFFSET_ICON_2_FACEPLATE_PX + faceplateContent.offsetWidth < window.innerWidth) {
		faceplateContent.style.left = matchItem.x + OFFSET_ICON_2_FACEPLATE_PX + 'px';
		faceplateContent.offsetLeft + osk.offsetWidth < window.innerWidth ? osk.style.left = faceplateContent.style.left : osk.style.left = faceplateContent.offsetLeft + faceplateContent.offsetWidth - osk.offsetWidth + 'px';
	}
	else if (matchItem.x - OFFSET_ICON_2_FACEPLATE_PX - faceplateContent.offsetWidth > 0) {
		faceplateContent.style.left = matchItem.x - OFFSET_ICON_2_FACEPLATE_PX - faceplateContent.offsetWidth + 'px';
		faceplateContent.offsetLeft + osk.offsetWidth < window.innerWidth ? osk.style.left = faceplateContent.style.left : osk.style.left = faceplateContent.offsetLeft + faceplateContent.offsetWidth - osk.offsetWidth + 'px';
	}
	else {
		faceplateContent.style.left = '0px';
		osk.style.left = '0px';
	}

	if (faceplateContent.offsetTop + faceplateContent.offsetHeight + OFFSET_FP_2_OSK + osk.offsetHeight < window.innerHeight) {
		osk.style.top = faceplateContent.offsetTop + faceplateContent.offsetHeight + OFFSET_FP_2_OSK + 'px';
	}
	else if (faceplateContent.offsetLeft + faceplateContent.offsetWidth + OFFSET_FP_2_OSK + osk.offsetWidth < window.innerWidth) {
		osk.style.left = faceplateContent.offsetLeft + faceplateContent.offsetWidth + OFFSET_FP_2_OSK + 'px';
		osk.style.top = faceplateContent.offsetTop + faceplateContent.offsetHeight - osk.offsetHeight + 'px';
	}
	else {
		osk.style.left = faceplateContent.offsetLeft - osk.offsetWidth - OFFSET_FP_2_OSK + 'px';
		osk.style.top = faceplateContent.offsetTop + faceplateContent.offsetHeight - osk.offsetHeight + 'px';
		if (osk.offsetLeft < 0) {
			osk.style.left = '0px';
			faceplateContent.style.left = osk.offsetWidth + 'px';//faceplateContent.offsetLeft + Math.abs(osk.offsetLeft) + 'px';
			//osk.style.top = osk.offsetTop - OFFSET_FP_2_OSK + 'px';
		}
	}
	hideElemementById('osk'); //Anordnungsberechnung abgeschlossen -> osk ausblenden!
}

function showWochenKalenderVisu() {
	var faceplate = document.getElementById('fpContent');
	var wochenKalenderImVisu = document.getElementById('wochenKalenderImVisu');
	var wochenKalenderImVisuContent = $('#wochenKalenderImVisuContent');

	var kalenderHeader = document.getElementById('txtWochenKalenderImVisuHeader');
	var faceplateHeader = document.getElementById('txtFpHeader');
	kalenderHeader.textContent = faceplateHeader.textContent.replace('Einstellungen', 'Wochenkalender');

	wochenKalenderImVisu.style.display = "block";
	//console.log(wochenKalenderImVisuContent.width());

	var kalenderLeft = faceplate.offsetLeft + faceplate.clientWidth - wochenKalenderImVisuContent.width();
	if (kalenderLeft < 10) kalenderLeft = 10;

	wochenKalenderImVisuContent.css('left', kalenderLeft);
	wochenKalenderImVisuContent.css('top', faceplate.offsetTop);
	hideElemementById('osk');	//osk ausblenden wenn Kalender geöffnet wird
}


function sleep(miliseconds) {
	var currentTime = new Date().getTime();

	while (currentTime + miliseconds >= new Date().getTime()) {
	}
}


function getOnlineData(IdVisu) {
	var res;
	$.ajax({
		type: "POST",
		url: "WebServiceEK.asmx/getVisuDataRaw",
		data: '{Projektnummer: ' + "'" + IdVisu + "'" + '}',
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (response) {
			var r = response.d;
			log("getOnlineData ok");

			var d = new Date();
			var h = d.getHours(); h = ("0" + h).slice(-2);
			var m = d.getMinutes(); m = ("0" + m).slice(-2);
			var s = d.getSeconds(); s = ("0" + s).slice(-2);
			var t = h + ":" + m + ":" + s;

			$("#xlabel").empty();
			$("#xlabel").append("<bdi>Letztes Update: " + t + "</bdi>");

			res = r;

		},
		complete: function (xhr, status) {
			log("getOnlineData complete");
		},
		error: function (msg) {
			log("getOnlineData fail: " + msg);
		}
	});

	return res;
}


function getOnlineDataAsync(prj) {

	$.ajax({
		type: "POST",
		url: "WebServiceEK.asmx/getVisuDataRaw",
		data: '{Projektnummer: ' + "'" + prj + "'" + '}',
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: true,
		success: function (response) {
			var r = response.d;
			log("getOnlineData ok");

			var d = new Date();
			var h = d.getHours(); h = ("0" + h).slice(-2);
			var m = d.getMinutes(); m = ("0" + m).slice(-2);
			var s = d.getSeconds(); s = ("0" + s).slice(-2);
			var t = h + ":" + m + ":" + s;

			Draw();

			$("#updateStatus-info").empty();
			$("#updateStatus-info").append("<bdi>Letztes Update: " + t + "</bdi>");
			VisuDownload = $.parseJSON(r);

		},
		complete: function (xhr, status) {
			log("getOnlineData complete");
		},
		error: function (msg) {
			log("getOnlineData fail: " + msg);
		}
	});


}


function toggleBools() {
	var x = VisuDownload;
	var n = VisuDownload.Items.length;
	for (i = 0; i < n; i++) {
		var itm = VisuDownload.Items[i];
		if (itm.isBool == true) {

			itm.BooVal = !itm.BooVal;
			if (itm.Wert == 1)
				itm.Wert = 0;
			else
				itm.Wert = 1;
		}
	};
}

function getOnlinegesamtZaehler(IdVisu) {
	var res;
	$.ajax({
		type: "POST",
		url: "WebServiceEK.asmx/getZaehlerGesamt",
		data: '{Projektnummer: ' + "'" + IdVisu + "'" + '}',
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (response) {
			var r = response.d;
			log("getOnlineTaehler ok");

			var d = new Date();
			var h = d.getHours(); h = ("0" + h).slice(-2);
			var m = d.getMinutes(); m = ("0" + m).slice(-2);
			var s = d.getSeconds(); s = ("0" + s).slice(-2);
			var t = h + ":" + m + ":" + s;

			$("#xlabel").empty();
			$("#xlabel").append("<bdi>Letztes Update: " + t + "</bdi>");

			res = r;

		},
		complete: function (xhr, status) {
			log("getOnlineZaehler complete");
		},
		error: function (msg) {
			log("getOnlineZaehler fail: " + msg);
		}
	});

	return res;
}

function loadDeployedVTO(ProjektNumber) {
	var res;
	$.ajax({
		type: "POST",
		url: "WebServiceEK.asmx/loadDeployedVTO",
		data: '{Projektnummer: ' + "'" + ProjektNumber + "'" + '}',
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function (response) {
			var r = response.d;
			log("loadDeployedVTO ok");
			res = r;
		},
		complete: function (xhr, status) {
			log("loadDeployedVTO complete");
		},
		error: function (msg) {
			log("loadDeployedVTO fail: " + msg);
		}
	});
	return res;
}

function sendDataWT(Url) {
	var res;
	$.ajax({
		type: "POST",
		url: "WebServiceEK.asmx/SendDataToRtos",
		data: "{Url: '" + Url + "'}",
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false, // wichtig! sonst kein Rückgabewert
		success: function (response) {
			res = response.d;
			log("sendData ok");
			//res = r;
		},
		complete: function (xhr, status) {
			log("sendData complete");
		},
		error: function (msg) {
			log("sendData fail: " + msg);
		}
	});
	return res;
}

function cbCyclicChanged() {
	ReloadTimerVar = setTimeout(function () { ReloadTimerFunc() }, waitReloadMS);
}


function UpdateLabelMouseOverHandler() {
	$('#xlabel').css("background-color", "red");
}

function UpdateLabelMouseOutHandler() {
	$('#xlabel').css("background-color", "lightgrey");

}


function findLabelAnstehendeStoerung() {
	//find the freitext "anstehende Störungen" and create this onlick function
	var elem = document.getElementById('myvCanvas');
	elemLeft = elem.offsetLeft,
		elemTop = elem.offsetTop,
		context = elem.getContext('2d'),
		elements = [];

	elem.addEventListener('click', function (event) {
		var x = event.pageX - elemLeft,
			y = event.pageY - elemTop;

		// Collision detection between clicked offset and element.
		elements.forEach(function (element) {
			if (y > element.top && y < element.top + element.height
				&& x > element.left && x < element.left + element.width) {
				alert('clicked an element');
			}
		});
	})
}





