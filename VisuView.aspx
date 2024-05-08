<%@ Page Title="VisuView" Language="C#" AutoEventWireup="true" CodeBehind="VisuView.aspx.cs" Inherits="WebAppJanStyle1.VisuView" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Content/bootstrap-datepicker.css" rel="stylesheet" />
    <link href="Content/VisuView.aspx.css" rel="stylesheet" />

    <style>
    </style>
</head>
<body>
    <script src="Scripts/jquery-2.1.1.js"></script>
    <script src="Scripts/jquery-ui-1.11.2.js"></script>
    <script src="Scripts/bootstrap.js"></script>
    <script src="Scripts/bootstrap-datepicker.min.js"></script>
    <script src="Scripts/moment-with-locales.min.js"></script>
<%--    <script src="Scripts/string.polyfill.js"></script>
    <script src="Scripts/NodeList.polyfill.js"></script>
    <script src="Scripts/Array.Profill.js"></script>  --%>            
   
    <%--<script src="Scripts/VisuView.aspx_Hilfsfunktion.js"></script>  --%>
    <%--<script src="Scripts/VisuView.aspx_Bedienung.js"></script>--%>
    <%--<script src="Scripts/VisuView.aspx_RecordData.js"></script>--%>
    <%--<script src="Scripts/VisuView_gemeinsam_Bedienung.js"></script>    --%>
    <%--<script src="Scripts/VisuView_gemeinsam_SymbolAndAnimation.js"></script>
    <script src="Scripts/VisuView.aspx_WebserviceCall.js"></script>--%>

    <%--<script src="Scripts/EK.JS"></script>--%>
    <script>

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

        $(function () {
            $('#datetimepicker1').datepicker({
                locale: 'de',
                format: 'dd.mm.yyyy',
                autoclose: true,
                clearBtn: true,
                endDate: '-1d',
                datesDisabled: '+1d',
                todayHighlight: true,

            });
        });

        function closeModal() {
            var modal = document.getElementById('stoerungModal');
            var span = document.getElementById("closeModal");
            span.onclick = function () {
                modal.style.display = "none";
            }
        }

        function closeModalZaehler() {
            var modal = document.getElementById('modalZaehler');
            modal.style.display = "none";
        }

        function closeModalById(id) {
            var modal = document.getElementById(id);
            modal.style.display = "none";
        }

        $(function () {

            IdVisu = getParameterByName('Id');
            //alert(IdVisu);

        });

        $(document).keydown(function (event) {
            tastascii = 0;
            tastkey = event.key;
            tastkeylength = tastkey.length;
            tastcode = event.keyCode;
            if (tastkeylength < 2) {         /* ein einzelnes Zeichen  */
                tastascii = tastkey.charCodeAt(0);
            }
            else {
                switch (tastcode) {
                    case 37:  //  LEFT 
                        tastascii = 8;
                        break;
                    case 38:  //  UP 
                        tastascii = 11;
                        break;
                    case 39:  //  RIGTH
                        tastascii = 12;
                        break;
                    case 40:  //  DOWN
                        tastascii = 10;
                        break;
                    case 13:  //  ENTER
                        tastascii = 13;
                        break;

                    case 27:  //  ESC
                        tastascii = 27;
                        break;
                    case 17:  //  STRG
                        tastascii = 17;
                        break;

                    default:
                }
            }
            if (tastascii > 0) {
                var TastURLId = TastURL + tastascii;
                var data = getData(TastURLId);
            }

            if (zykzaehler > einmalholen) {
                zykzaehler = einmalholen;
                tastzaehler = 0;
            }
            else {
                //  zykzaehler=zykzaehler+1;
                tastzaehler = einmalholen;
            }
        });

        // Diverse globale Variablen
        // Vorgehensweise analog zu der in VCO_Edit.aspx
        var IdVisu;
        var IPE;
        var Projektname = "";
        var aktuelleBenutzer;
        var autoCloseVisuWindows;

        // drawing canvas setting
        var canvas;
        var ctx;
        var ctxWK;
        var wochenKalenderImVisuCanvas;
        var wochenKalenderImVisuCanvasContext;
        var canvasOffset;
        var offsetX;
        var offsetY;
        var tipCanvas;
        var tipCtx;

        var visudata;
        var bmpIndex = 0;
        var VisuDownload;
        var LinkButtonList = [];


        var requestDrawingFlag = false;
        var bgColors = [];
        var hasSymbolsFlag = false;
        var tt_dots = []; // Liste der tooltips: Koordinate und Text and BitmapIndex
        var showLog;
        var hInit;
        var wInit;
        var startAngle = 1.1 * Math.PI;
        var endAngle = 1.9 * Math.PI;
        var stoerungen;
        var stoerungText = "";
        var mousex;               // 1: xPosition der Maus im Canvas
        var mousey;               // 1: yPosition der Maus im Canvas
        var gesamtZaehler = "";

        // autoreload setting
        var waitReloadMS = 5000; //download interval for visu data (in miliseconds)
        var nReloadCycles = 0;
        var maxReloadCycles = 10000;
        var bAutoReload;
        var ReloadTimerVar;
        var wochenKalenderImVisuAutoReload;

        //visu recording
        var visuDatenRecording;  //use for setInterval and clearInterval recording visu data (start and stop)
        var visuRecords = [];
        var visuRecordsSlider;
        var currentPlayBackPosition = 0;
        var globalPlaybackPosition = 0;
        var refreshIntervalId;
        var playbackSpeed;
        var isVisuPlaying = true;

        /*Variable für klickbaren Objecte */1
        var readParameterOfClickableElementUrl;
        var ClickableElement = [];
        var ClickableElementList = [];
        var ClickableElementUrlList = [];
        var sendBackToRtosUrlList = [];
        var currentID;
        var DEBUG = false;
        var FORCE_ANALOGMISCHER = false;
        var locked = true;
        var permissionVisuToRtos = true;
        var isAdmin = false;

        var xIPKamera1Button;
        var yIPKamera1Button;
        var xIPkamera1ButtonBot;
        var yIPkamera1ButtonBot;
        var xIPKamera2Button;
        var yIPKamera2Button;
        var xIPkamera2ButtonBot;
        var yIPkamera2ButtonBot;
        var nIntervID; /*intervalID to stop streaming*/

        // url settings
        var dataUrl = '';
        var paramsUrl = '';
        var UpURL = '';
        var DownURL = '';
        var RightURL = '';
        var LeftURL = '';
        var EnterURL = '';
        var kalenderUrl = '';
        var TastURL = '';
        var menuLink = '';
        var menuTextFile = '';
        var visuTextFile = '';
        var benachrichtigungsUrl = '';
        var anmeldungBenachrichtigungsUrl = '';
        var abmeldungBenachrichtigungUrl;

        /********************* Control Settings (mst Sulingen) *********************/
        var zyklus;               // ZUM SUCHEN <<< 
        var einmalholen;          // ZUM SUCHEN <<< 
        var zykzaehler;           // ZUM SUCHEN <<< 
        var tastzaehler;          // ZUM SUCHEN <<< 
        var tastkey;              // ZUM SUCHEN <<< 
        var tastcode;             // ZUM SUCHEN <<< 
        var tastkeylength;        // ZUM SUCHEN <<< 
        var tastascii;            // ZUM SUCHEN <<< 
        var stat1;                // 1: normale Ausgabe rot ab x,y fuer z Zeichen 
        var stat2;                // 1: normale Ausgabe rot ab x > 20 
        var stat3;                // 1: Ausgabe auf grossen Bildschirm (80*22 rot ab x,y fuer z Zeichen) 
        var stat4;                // 1: Ausgabe Wochenkalender in grafischer Form auf CANVAS Element                     
        var statTastzahl;         // 1: aktuelles Menue bietet die Moeglichkeit ueber Eingabe von "t" oder "T" eine Zahleneingabe zu machen 
        var statTastzeich;        // 1: aktuelles Menue bietet die Moeglichkeit ueber Eingabe von "t" oder "T" eine Zeichenkette einzugeben 
        var stat14haktiv;        // 1: Merlin ist beschaeftigt die Datei "viertdat.txt" zu erstellen 
        var toclipboard;              // Communikation Klick->Clipboard
        var statmouseweek;


        // Doc ready
        $(function () {
            prj = getParameterByName('Id');
            wInit = window.outerWidth;
            hInit = window.outerHeight;

            //set reload time, P2xx (1 second), P5xx P15xx (5 seconds)
            if (IdVisu.toUpperCase().indexOf('P2') >= 0) {
                waitReloadMS = 1000;
            }
            bAutoReload = false;
            $('#cbDebug').prop('checked', false);
            cbDebugChanged();
            // Canvas init
            aktuelleBenutzer = getUsername();

            visuRecordsSlider = document.getElementById('sliderDate');

            tipCanvas = document.getElementById("tipCanvas");
            tipCanvas.style.left = "-2000px";
            tipCtx = tipCanvas.getContext("2d");
            canvasOffset = $("#myCanvas").offset();
            offsetX = canvasOffset.left;
            offsetY = canvasOffset.top;

            //initialize Wochenkalender Canvas Setting
            canvas = document.getElementById('myCanvas');
            canvas.width = 1400;
            canvas.height = 630;
            ctx = canvas.getContext('2d');


            //initialize Wochenkalender Canvas Setting
            canvasWK = document.getElementById('settingFromVisuCanvas');
            ctxWK = canvasWK.getContext('2d');
            initCanvasWK();

            // Laden
            visudata = $.parseJSON(loadDeployedVTO(IdVisu));
            IPE = getIPEFromProjectnumber(IdVisu);
            createAllLink(IPE);
            readParameterOfClickableElementUrl = 'http://' + IPE + '/JSONADD/GET?p=5&Var=all';

            //add clickable item to list
            addClickableElementToList(visudata);

            addLinkButtonToList(visudata);
            //permissionVisuToRtos = getVisuSettingPermission(prj);
            //isAdmin = checkUserRole();

            //if (isAdmin) {
            //    var btnStart = document.getElementById('btnStartRecord');
            //    btnStart.style.display = 'inline-block';
            //}

            //if (!permissionVisuToRtos) {
            //    handleConfirmBtn(false);
            //}
            try {
                var k = getOnlineData(prj);
                VisuDownload = $.parseJSON(k);
                var Stoerungen = VisuDownload.Stoerungen;
                var stoerungencount = Stoerungen.length;

                for (var i = 0; i < stoerungencount; i++) {
                    stoerungText += Stoerungen[i].BezNr + ". " + Stoerungen[i].StoerungText.trim() + "<br/>";
                }
                //alert(stoerungText);
                var u = k;

            }
            catch (e) {
                log(e.message);
                log("Es konnten keine Visualisierungsdaten heruntergeladen werden von Steuerung " + prj);
            }
            Projektname = getProjektName(prj);

            getOnlinegesamtZaehler(prj);

            // Tooltips einlesen
            initTooltips();

            initBGColors();

            $("#myCanvas").mousemove(function (e) {
                handleMouseMove(e);
            });

            $("#myCanvas").mousedown(function (e) {
                handleMouseDown(e);
            });


            setBitmap(bmpIndex);
            Draw();
            //findLabelAnstehendeStoerung();
            document.title = "Visualisierung " + " " + Projektname;

            //auto reload will be automatically activated for P2xxx project
            if (IdVisu.toUpperCase().indexOf('P2') >= 0) {
                document.getElementById("cbcyclicReload").checked = true;
                cbCyclicChanged();
            }

            //automatically close after 30 minutes, will be disabled when visurecording ist called
            autoCloseVisuWindows = setTimeout("window.close()", 1800000);

        });

        //

        window.onclick = function (event) {
            var modals = Array.from(document.getElementsByClassName("modalVisuBg"));
            modals.forEach(function (el) {
                if (el == event.target) {
                    if (el.id.includes('fp')) closeFaceplate();
                    if (el.id.includes('Pin')) closePinModal();
                }
            });
        }


        function checkUserRole() {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/isAdmin",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var r = response.d;
                    log("getRole ok");
                    res = r;
                },
                complete: function (xhr, status) {
                    log("getRole complete");
                },
                error: function (msg) {
                    log("getRole fail: " + msg);
                }
            });
            return res;
        }

        function MeldungAndCloseModal(meldung) {
            var modal = document.getElementById('ModalZaehlerAbholung');
            document.getElementById("modalbodyZahelerAbholung").innerHTML = "<p>" + "<h2>" + meldung + "<h2>" + "</p>";
            setTimeout(function () { modal.style.display = "none"; }, 2000);
        }


        /******************* Create all needed Urls*******************************/
        function createAllLink(IPE) {
            dataUrl = 'http://' + IPE + '/JSONADD/GET?p=2&Var=all';
            paramsUrl = 'http://' + IPE + '/JSONADD/GET?p=1&Var=all';
            kalenderUrl = 'http://' + IPE + '/JSONADD/GET?p=3&Var=all';
            benachrichtigungsUrl = 'http://' + IPE + '/JSONADD/GET?p=4&Var=sel&V064';
            anmeldungBenachrichtigungsUrl = 'http://' + IPE + '/JSONADD/PUT?V009=QA>' + aktuelleBenutzer;
            abmeldungBenachrichtigungUrl = 'http://' + IPE + '/JSONADD/PUT?V009=QA<' + aktuelleBenutzer;
            UpURL = 'http://' + IPE + '/JSONADD/PUT?V010=11';
            DownURL = 'http://' + IPE + '/JSONADD/PUT?V010=10';
            RightURL = 'http://' + IPE + '/JSONADD/PUT?V010=12';
            LeftURL = 'http://' + IPE + '/JSONADD/PUT?V010=8';
            EnterURL = 'http://' + IPE + '/JSONADD/PUT?V010=13';
            TastURL = 'http://' + IPE + '/JSONADD/PUT?V010='
            menuLink = 'http://' + IPE + '/JSONADD/PUT?V004=';
            menuTextFile = 'http://' + IPE + '/DATA/menue.txt';
            visuTextFile = 'http://' + IPE + '/DATA/visdat.txt';
        }

        function createLinkForClickableElement(id) {
            var link = 'http://' + IPE + '/JSONADD/PUT?V008=Qz' + id;
            ClickableElementUrlList.push(link);
        }

        //after refresh the visualisierung canvas is the same as the wochenkalender canvas
        //using 2 canvas does not solve the problem, maybe the initcanvas causes this problem (maybe pass canvas as params is not best practice)
        // try new approach, initcanvas in visuview.aspx no longer takes any params, but initialize the wochenkalendercanvas directly
        function initCanvasWK() {
            //var parent = canvasWK.parentNode;
            //canvasWK.width = parent.width;
            //parent.offsetWidth > 0 ? canvasWK.width = parent.offsetWidth : canvasWK.width = 960;
            //parent.offsetHeight > 0 ? canvasWK.height = parent.offsetHeight : canvasWK.height = 520;
            //var parent = document.getElementById('fernbedienungDisplay');
            //canvasWK.width = parent.offsetWidth;
            //canvasWK.height = parent.offsetHeight;
            canvasWK.width = window.innerWidth;
            canvasWK.height = 520;

            canvasWK.addEventListener("click", function (evt) {
                var rect = canvasWK.getBoundingClientRect();

                if (stat4 == '1' && statmouseweek) {    //status 4:  Wochenkalender in CANVAS und Maus im Wochenfeld 
                    var x = evt.clientX - rect.left;
                    var y = evt.clientY - rect.top;
                    var ypos = Math.round((y - 76) / 30) - 1;
                    var xpos = Math.round((x - 50) / 5);
                    var maus = Math.round(4001 + ypos * 144 + xpos)
                    var TastURLId = TastURL + maus;
                    var data = getData(TastURLId);
                }
                else {
                    var x = evt.clientX - rect.left;
                    var y = 8 + evt.clientY - rect.top;

                    var xr = Math.round(x / 16)   //   /16 Zeichenbreite
                    var yr = Math.round(y / 30)   //   /30 Zeilenhoehe
                    //  alert(xr + ',' + yr);
                    var maus = Math.round(1000 + yr * 100 + xr)
                    var TastURLId = TastURL + maus;
                    var data = getData(TastURLId);
                }

                if (zykzaehler > einmalholen) {
                    zykzaehler = einmalholen;
                    tastzaehler = 0;
                }
                else {
                    tastzaehler = einmalholen;
                }

                if (xr > 54 && yr < 3) {
                    toclipboard = true;
                }

            }, false);

            canvasWK.addEventListener('mousemove', function (evt) {
                var rect = canvasWK.getBoundingClientRect();
                var x = evt.clientX - rect.left;
                var y = evt.clientY - rect.top;
                var xr = Math.round(x / 1)
                var yr = Math.round(y / 1)

                statmouseweek = false;

                if (stat4 == '1') {    //status 4:  Wochenkalender in CANVAS anzeigen 
                    if (xr > 50 && xr < 768 && yr > 91 && yr < 300) {
                        statmouseweek = true;
                        mousex = xr;
                        mousey = yr;
                        //timeweek(ctxWK);
                        timeweek();
                    }
                }

            }, false);
        }

        function timeweek() {
            //ctx = canvasContext;
            ctxWK.fillStyle = "#E0E0E0";
            ctxWK.fillRect(775, 90, 70, 220);

            var ypos = 85 + 30 * (Math.round((mousey - 76) / 30));
            var timehour = Math.round((mousex - 64) / 30);
            var timemin = 10 * Math.round((mousex - 50 - timehour * 30) / 5);
            ctxWK.fillStyle = "#000000";
            if (timemin > 50) {
                timemin = 50;
            }
            if (timemin < 10) {
                ctxWK.fillText(("00" + timehour).slice(-2) + ":00", 782, ypos);
            }
            else {
                ctxWK.fillText(("00" + timehour).slice(-2) + ":" + timemin, 778, ypos);
            }
        }

        // Mouse Handler für Tooltip Anzeige
        function handleMouseMove(e) {

            var currentBmpIndex = bmpIndex;
            var match = false;
            for (var i = 0; i < tt_dots.length; i++) {
                mouseX = parseInt(e.clientX - offsetX);
                mouseY = parseInt(e.clientY - offsetY);
                var dx = mouseX - tt_dots[i].x;
                var dy = mouseY - tt_dots[i].y;
                var txt = tt_dots[i].t;
                var index = tt_dots[i].index
                if ((dx * dx < 1600) && (dy * dy < 200) && (dx > 0) && (dy < 0) && (index == currentBmpIndex)) {

                    tipCanvas.style.left = (tt_dots[i].x) + "px";
                    tipCanvas.style.top = (tt_dots[i].y - 40) + "px";
                    tipCtx = tipCanvas.getContext("2d");
                    tipCtx.clearRect(0, 0, tipCanvas.width, tipCanvas.height);
                    //                  tipCtx.rect(0,0,tipCanvas.width,tipCanvas.height);
                    tipCtx.font = "12px Arial";
                    tipCtx.fillText(txt, 5, 15);
                    match = true;

                }
                if (!match) {
                    tipCanvas.style.left = "-2000px";
                }
            }
        }

        // Mousebutton Eventhandler für Bitmapwechsel
        function handleMouseDown(e) {

            var currentBmpIndex = bmpIndex;

            /*gett mouse click position*/
            mx = parseInt(e.clientX - offsetX);  //alternativ var x = event.x;
            my = parseInt(e.clientY - offsetY);  //alternativ var y = event.y;

            //click event für die kamera button
            if (((mx - xIPKamera1Button > 0) && (xIPkamera1ButtonBot - mx > 0)) && ((my - yIPKamera1Button > 0) && (yIPkamera1ButtonBot - my > 0))) {
                //alert('on kamera 1');
                //start streaming from IPKamera1
                if (IdVisu.toUpperCase() == 'P 679') {
                    displayKameraStream('http://10.0.6.106:8880/action/snap?cam=0&user=admin&pwd=Emb_Mhl_2020');
                }
                if (IdVisu.toUpperCase() == 'P 640') {

                    displayKameraStream('http://10.0.3.190:8080/snapshot.cgi?user=admin&pwd=');

                }
            }

            if (((mx - xIPKamera2Button > 0) && (xIPkamera2ButtonBot - mx > 0)) && ((my - yIPKamera2Button > 0) && (yIPkamera2ButtonBot - my > 0))) {
                //alert('on kamera 2');
                window.open("/Ueberwachung2.html");

            }

            var match = false; //Flag zur Click-treffer Erkennung (es ist nicht davon auszugehen, dass es keine doppelten Click-treffer gibt!)

            //handle for bitmap change or mouse click on non linked elements
            if (!match) {
                for (var i = 0; i < LinkButtonList.length; i++) {
                    var item = LinkButtonList[i];
                    //compare coordinate of click event with coordinate of the element in the list
                    if (mx > item.x_min && mx < item.x_max && my > item.y_min && my < item.y_max) {

                        //match = true;

                        //if coordinate correct, check the elements text and decide which element and which action do to
                        if (item.text == "anstehende Störungen") {
                            displayStoerungen();  //todo: may be use only 1 modal to clean code
                        }
                        if ((item.text == "Zähler anzeigen") && (item.BgColor.trim() == "slateBlue" || item.BgColor == '#1F94B9' /*EKH Cyan*/)) {
                            displayZaehler();    //todo: may be use only 1 modal to clean code
                        }

                        //actual bitmap change
                        bmpIndex = item.bmp;
                        setBitmap(bmpIndex);
                        requestDrawing();
                    }
                }
            }

            //handle for button click and clickable item, same philosophy as bitmap change of non linked element above

            if (!match) {
                openFaceplate();
            }


        }


        function jumpToWochenKalender(event) {
            //1.Deaktivieren Autoreload Funktion beim Fernbedienung ? (überlegung)
            //clearInterval(fernbedienungAutoReload);
            //2.Der Wert 'HK Wochenkalender' wird auf 1 geändert und zurückübertragen (gesamte 20 Zeile)
            //Pearl-seitig wird das HK-Wochenkalender aufm Canvas gerendert.
            //var sendError = sendValueFromVisuToRtos('openHKWochenKalender');
            var sendError = sendDataToRtosNEW(event);
            if (!sendError) {
                showWochenKalenderVisu();
                activeTabID = 'wochenKalenderImVisu';
                wochenKalenderImVisuAutoReload = setInterval(wochenKalenderImVisu, 50);
            }
        }

        function wochenKalenderImVisu() {
            var data;
            var jsonData;
            //ctxWK = wochenKalenderImVisuCanvasContext;
            //if (ctx == ctxWK) {
            //    alert('same context');
            //}

            var Displaycanvas = canvasWK;

            if (tastzaehler > 0) {                  // <<<
                tastzaehler = tastzaehler - 1;
                if (tastzaehler < 1) {
                    zykzaehler = 0;
                }
            }
            if (zykzaehler > 1) {
                zykzaehler = zykzaehler - 1;
            }
            else {                                   // <<< 
                if (tastzaehler < 2) {
                    tastzaehler = 0;
                }
                if (data == undefined) {
                    jsonData = getData(dataUrl);
                    data = JSON.parse(jsonData);
                }
                else {
                    data = data;
                }
                var x = data['v035'] - 1; //spalte, wo die texte anfang "rot" sein soll
                var y = data['v036'] + 15;    //Zeile, wo die Texte rot markiert werden soll
                var z = data['v037'];   //Anzahl der Zeichen, die rot markiert werden soll
                var s = data['v034'];   // DISPSTATUS  
                var variableName = "";
                var textToDisplay = "";
                var textToReplace = "";
                var rotText = "";
                var html = "";
                var rotHtml = "";
                var str = b32(s);
                var xpos = 1;                  //  Positionsvariable auf dem CANVAS  x (Pixel) 
                var ypos = 1;                  //  Positionsvariable auf dem CANVAS  y (Pixel)
                stat1 = str.charAt(0);          // 1: normale Ausgabe rot ab x,y fuer z Zeichen 
                stat2 = str.charAt(1);          // 1: normale Ausgabe rot ab x > 20 
                stat3 = str.charAt(2);          // 1: Ausgabe auf grossen Bildschirm (80*22 rot ab x,y fuer z Zeichen) 
                stat4 = str.charAt(3);          // 1: Ausgabe Wochenkalender in grafischer Form auf CANVAS Element                     
                statTastzahl = str.charAt(30);  // 1: aktuelles Menue bietet die Moeglichkeit ueber Eingabe von "t" ode "T" eine Zahleneingabe 
                statTastzeich = str.charAt(31); // 1: aktuelles Menue bietet die Moeglichkeit ueber Eingabe von "t" oder "T" eine Zeichenkette einzugeben 
                stat14haktiv = str.charAt(29);  // 1: Merlin ist beschaeftigt die Datei "viertdat.txt" zu erstellen 

                //status 4:  Wochenkalender in CANVAS anzeigen    600 * 350                             
                // zykzaehler=zyklus; 
                if (stat4 == '1') {
                    zykzaehler = zyklus;
                    jsonData = getData(kalenderUrl);
                    data = JSON.parse(jsonData);
                    ctxWK.fillStyle = "#E0E0E0";
                    ctxWK.fillRect(0, 0, Displaycanvas.width, Displaycanvas.height);
                    ctxWK.fillStyle = "#000000";
                    ctxWK.font = "20px Arial";
                    xpos = 5;    //  Positionsvariable auf dem CANVAS  x (Pixel) 
                    ypos = 25;    //  Positionsvariable auf dem CANVAS  y (Pixel)
                    ctxWK.fillText("<", xpos, ypos);         //  Pfeil fuer Ausstieg
                    xpos = 20;
                    ctxWK.fillStyle = "#23A6D1";	/*EKH hellblau*/             //  BUTTON fuer Ausstieg
                    ctxWK.fillRect(xpos + 1, ypos - 20, 20, 23);
                    ctxWK.fillStyle = "#1F94B9";	/*EKH blau*/
                    ctxWK.fillRect(xpos + 4, ypos - 17, 14, 17);
                    ctxWK.fillStyle = "#000000";

                    xpos = 50;
                    ypos = 25;
                    ctxWK.fillText("Wochenkalender von", xpos, ypos);

                    textToReplace = data['v039'].substring(13, 34)    // Name HK  auslesen aus 2. Zeile grosses Display x 13-34
                    xpos = 50;
                    ypos = ypos + 30;
                    ctxWK.fillText(textToReplace, xpos, ypos);

                    textToReplace = data['v039'].substring(39, 60)    //  Tag  Uhrzeit  auslesen aus 2. Zeile grosses Display x 39-60
                    xpos = xpos + 200;
                    ypos = ypos + 0;
                    ctxWK.fillText(textToReplace, xpos, ypos);

                    textToReplace = data['v040'].substring(42, 57)    //  Zustand zum Zeitpunkt    auslesen aus 3. Zeile grosses Display x 42-57
                    xpos = xpos + 220;
                    ypos = ypos + 0;
                    var index = textToReplace.indexOf("Tag");
                    if (index > 1) {
                        ctxWK.fillStyle = "#C31D64";	/*EKH rot*/
                    }
                    else {
                        index = textToReplace.indexOf("EIN");
                        if (index > 1) {
                            ctxWK.fillStyle = "#C31D64";	/*EKH rot*/
                        }
                        else {
                            index = textToReplace.indexOf("HT");
                            if (index > 1) {
                                ctxWK.fillStyle = "#C31D64";	/*EKH rot*/
                            }
                            else {
                                ctxWK.fillStyle = "#1F94B9";	/*EKH blau*/
                            }
                        }
                    }
                    ctxWK.fillText(textToReplace, xpos, ypos);

                    // Darstellung Wochenkalender im Canvas
                    xpos = 50;
                    ypos = ypos + 30;
                    ctxWK.fillStyle = "#303030";
                    ctxWK.fillText("0                              6                             12                            18                            24", xpos, ypos);
                    xpos = 2;
                    ypos = ypos + 30;
                    ctxWK.fillText("MO", xpos, ypos);
                    ypos = ypos + 30;
                    ctxWK.fillText("DI", xpos, ypos);
                    ypos = ypos + 30;
                    ctxWK.fillText("MI", xpos, ypos);
                    ypos = ypos + 30;
                    ctxWK.fillText("DO", xpos, ypos);
                    ypos = ypos + 30;
                    ctxWK.fillText("FR", xpos, ypos);
                    // ctxWK.fillStyle = "red";
                    ctxWK.fillStyle = "#C31D64";	/*EKH rot*/
                    ypos = ypos + 30;
                    ctxWK.fillText("SA", xpos, ypos);
                    ypos = ypos + 30;
                    ctxWK.fillText("SO", xpos, ypos);

                    if (statmouseweek) {
                        //timeweek(canvasContext);
                        timeweek();
                    }

                    var Bheizkreis = 0;
                    textToReplace = data['v040'].substring(42, 57)    //  Zustand zum Zeitpunkt    auslesen aus 3. Zeile grosses Display x 42-57
                    index = textToReplace.indexOf("Tag");             //  -> es handelt sich um einen Heizkreiskalender
                    if (index > 1) {
                        Bheizkreis = 1;
                    }
                    index = textToReplace.indexOf("Nacht");           //  -> es handelt sich um einen Heizkreiskalender
                    if (index > 1) {
                        Bheizkreis = 1;
                    }

                    if (Bheizkreis > 0) {
                        textToReplace = data['v056'].substring(48, 51)    //  an der Stelle steht bei einem Heizkreis der Betriebszustand (0:Auto, 1:Dauernacht, 2:Dauertag)

                        ctxWK.fillStyle = "#000000";
                        xpos = 550;
                        ypos = 425;
                        ctxWK.fillText("HK-Zustand", xpos, ypos);

                        xpos = 550;
                        ypos = 451;
                        ctxWK.fillStyle = "#23A6D1";	/*EKH hellblau*/             //  BUTTON HK Automatikbetrieb
                        ctxWK.fillRect(xpos + 1, ypos - 20, 20, 23);
                        ctxWK.fillStyle = "#1F94B9";	/*EKH blau*/
                        ctxWK.fillRect(xpos + 4, ypos - 17, 14, 17);
                        ctxWK.fillStyle = "#000000";
                        xpos = 580;
                        ctxWK.fillText("Automatikbetrieb (nach Wochenkalender)", xpos, ypos);
                        index = textToReplace.indexOf("1");               //  Automatikbetrieb
                        if (index > 0) {
                            ctxWK.strokeStyle = "#C31D64";         // EKH rot Kreuz setzen
                            ctxWK.setLineDash([5, 0]);
                            ctxWK.lineWidth = 3;
                            xpos = xpos - 25;
                            ypos = ypos - 2;
                            ctxWK.beginPath();
                            ctxWK.moveTo(xpos, ypos);
                            ctxWK.lineTo(xpos + 12, ypos - 12);
                            ctxWK.stroke();
                            ypos = ypos - 12;
                            ctxWK.beginPath();
                            ctxWK.moveTo(xpos, ypos);
                            ctxWK.lineTo(xpos + 12, ypos + 12);
                            ctxWK.stroke();
                        }

                        xpos = 550;
                        ypos = 481;
                        ctxWK.fillStyle = "#23A6D1";	/*EKH hellblau*/             //  BUTTON HK Dauertagbetrieb 
                        ctxWK.fillRect(xpos + 1, ypos - 20, 20, 23);
                        ctxWK.fillStyle = "#1F94B9";	/*EKH blau*/
                        ctxWK.fillRect(xpos + 4, ypos - 17, 14, 17);
                        ctxWK.fillStyle = "#000000";
                        xpos = 580;
                        ctxWK.fillText("Dauertagbetrieb", xpos, ypos);
                        index = textToReplace.indexOf("3");               //  Dauertagbetrieb
                        if (index > 0) {
                            ctxWK.strokeStyle = "#C31D64";         // EKH rot Kreuz setzen
                            ctxWK.setLineDash([5, 0]);
                            ctxWK.lineWidth = 3;
                            xpos = xpos - 25;
                            ypos = ypos - 2;
                            ctxWK.beginPath();
                            ctxWK.moveTo(xpos, ypos);
                            ctxWK.lineTo(xpos + 12, ypos - 12);
                            ctxWK.stroke();
                            ypos = ypos - 12;
                            ctxWK.beginPath();
                            ctxWK.moveTo(xpos, ypos);
                            ctxWK.lineTo(xpos + 12, ypos + 12);
                            ctxWK.stroke();
                            ctxWK.strokeStyle = "#606060";         // Kalender durchstreichen dunkelgrau
                            ctxWK.setLineDash([4, 10]);
                            ctxWK.lineWidth = 5;
                            xpos = 50;
                            ypos = 305;

                            ctxWK.beginPath();
                            ctxWK.moveTo(xpos, ypos);
                            ctxWK.lineTo(xpos + 725, ypos - 215);
                            ctxWK.stroke();
                        }

                        xpos = 550;
                        ypos = 511;
                        ctxWK.fillStyle = "#23A6D1";	/*EKH hellblau*/             //  BUTTON HK Dauernachtbetrieb
                        ctxWK.fillRect(xpos + 1, ypos - 20, 20, 23);
                        ctxWK.fillStyle = "#1F94B9";	/*EKH blau*/
                        ctxWK.fillRect(xpos + 4, ypos - 17, 14, 17);
                        ctxWK.fillStyle = "#000000";
                        xpos = 580;
                        ctxWK.fillText("Dauernachtbetrieb", xpos, ypos);
                        index = textToReplace.indexOf("2");               //  Dauernachtbetrieb
                        if (index > 0) {
                            ctxWK.strokeStyle = "#C31D64";         // EKH rot Kreuz setzen
                            ctxWK.setLineDash([5, 0]);
                            ctxWK.lineWidth = 3;
                            xpos = xpos - 25;
                            ypos = ypos - 2;
                            ctxWK.beginPath();
                            ctxWK.moveTo(xpos, ypos);
                            ctxWK.lineTo(xpos + 12, ypos - 12);
                            ctxWK.stroke();
                            ypos = ypos - 12;
                            ctxWK.beginPath();
                            ctxWK.moveTo(xpos, ypos);
                            ctxWK.lineTo(xpos + 12, ypos + 12);
                            ctxWK.stroke();
                            ctxWK.strokeStyle = "#606060";         // Kalender durchstreichen dunkelgrau
                            ctxWK.setLineDash([4, 10]);
                            ctxWK.lineWidth = 5;
                            xpos = 50;
                            ypos = 305;
                            ctxWK.beginPath();
                            ctxWK.moveTo(xpos, ypos);
                            ctxWK.lineTo(xpos + 725, ypos - 215);
                            ctxWK.stroke();
                        }
                    }

                    var act = 1;
                    textToReplace = data['v056'].substring(2, 40)    //  AKTION:   auslesen aus 19. Zeile grosses Display x 2-40           
                    xpos = 30;
                    ypos = 330;
                    index = textToReplace.indexOf("anschauen");       // bei Aktion "anschauen" Darstellung schwarz
                    if (index > 2) {
                        ctxWK.fillStyle = "#000000";
                    }
                    else {                                            // andere Aktion 
                        index = textToReplace.indexOf("HT");       // bei Aktion "HT setzen" Darstellung rot
                        if (index > 2) {
                            ctxWK.fillStyle = "#C31D64";	/*EKH rot*/
                            act = 2;
                        }
                        else {
                            index = textToReplace.indexOf("EIN");     // bei Aktion "EIN setzen" Darstellung rot
                            if (index > 2) {
                                ctxWK.fillStyle = "#C31D64";	/*EKH rot*/
                                act = 2;
                            }
                            else {
                                index = textToReplace.indexOf("Tag");     // bei Aktion "Tagbetrieb setzen" Darstellung rot
                                if (index > 2) {
                                    ctxWK.fillStyle = "#C31D64";	/*EKH rot*/
                                    act = 2;
                                }
                                else {
                                    ctxWK.fillStyle = "#1F94B9";	/*EKH blau*/	//  sonst blau
                                    act = 3;
                                }
                            }
                        }
                        ctxWK.font = "30px Arial";
                        xpos = 250;
                    }
                    ctxWK.fillText(textToReplace, xpos, ypos);
                    ctxWK.font = "20px Arial";

                    xpos = 20;
                    ypos = 425;
                    ctxWK.fillText("Bedienung", xpos, ypos);
                    xpos = 20;
                    ypos = 451;
                    ctxWK.fillStyle = "#23A6D1";	/*EKH hellblau*/             //  BUTTON Wochenkalender anschauen
                    ctxWK.fillRect(xpos + 1, ypos - 20, 20, 23);
                    ctxWK.fillStyle = "#1F94B9";	/*EKH blau*/
                    ctxWK.fillRect(xpos + 4, ypos - 17, 14, 17);
                    ctxWK.fillStyle = "#000000";
                    xpos = 50;
                    ctxWK.fillText("Wochenkalender anschauen", xpos, ypos);
                    if (act == 1) {
                        ctxWK.strokeStyle = "#000000";         // Haken setzen
                        ctxWK.setLineDash([5, 0]);
                        ctxWK.lineWidth = 3;
                        xpos = 28;
                        ypos = 442;
                        ctxWK.beginPath();
                        ctxWK.moveTo(xpos, ypos);
                        ctxWK.lineTo(xpos + 5, ypos + 5);
                        ctxWK.lineTo(xpos + 20, ypos - 10);
                        ctxWK.stroke();
                    }

                    xpos = 20;
                    ypos = 481;
                    ctxWK.fillStyle = "#23A6D1";	/*EKH hellblau*/             //  BUTTON rot setzen
                    ctxWK.fillRect(xpos + 1, ypos - 20, 20, 23);
                    ctxWK.fillStyle = "#1F94B9";	/*EKH blau*/
                    ctxWK.fillRect(xpos + 4, ypos - 17, 14, 17);
                    // ctxWK.fillStyle = "#C31D64";	/*EKH rot*/
                    ctxWK.fillStyle = "#000000";
                    xpos = 50;
                    ctxWK.fillText("rot setzen (max. 5 Stunden zwischen 2 Klicks)", xpos, ypos);
                    if (act == 2) {
                        ctxWK.strokeStyle = "#000000";         // Haken setzen
                        ctxWK.setLineDash([5, 0]);
                        ctxWK.lineWidth = 3;
                        xpos = 28;
                        ypos = 472;
                        ctxWK.beginPath();
                        ctxWK.moveTo(xpos, ypos);
                        ctxWK.lineTo(xpos + 5, ypos + 5);
                        ctxWK.lineTo(xpos + 20, ypos - 10);
                        ctxWK.stroke();
                    }

                    xpos = 20;
                    ypos = 511;
                    ctxWK.fillStyle = "#23A6D1";	/*EKH hellblau*/             //  BUTTON blau setzen
                    ctxWK.fillRect(xpos + 1, ypos - 20, 20, 23);
                    ctxWK.fillStyle = "#1F94B9";	/*EKH blau*/
                    ctxWK.fillRect(xpos + 4, ypos - 17, 14, 17);
                    // ctxWK.fillStyle = "#1F94B9";	/*EKH blau*/
                    ctxWK.fillStyle = "#000000";
                    xpos = 50;
                    ctxWK.fillText("blau setzen (max. 5 Stunden zwischen 2 Klicks)", xpos, ypos);
                    if (act == 3) {
                        ctxWK.strokeStyle = "#000000";         // Haken setzen
                        ctxWK.setLineDash([5, 0]);
                        ctxWK.lineWidth = 3;
                        xpos = 28;
                        ypos = 502;
                        ctxWK.beginPath();
                        ctxWK.moveTo(xpos, ypos);
                        ctxWK.lineTo(xpos + 5, ypos + 5);
                        ctxWK.lineTo(xpos + 20, ypos - 10);
                        ctxWK.stroke();
                    }
                    ctxWK.fillStyle = "#000000";

                    xpos = 30;

                    ctxWK.fillStyle = "#000000";
                    textToReplace = data['v057'].substring(2, 40)    //  AKTION:    auslesen aus 20. Zeile grosses Display x 2-40              
                    xpos = 30;
                    ypos = 355;
                    ctxWK.fillText(textToReplace, xpos, ypos);

                    // jetzt das Feld vom grossen Display auslesen ( "0" oder  "1")
                    // und als Striche blau oder rot im Wochenkalender darstellen
                    ypos = 116;
                    ctxWK.setLineDash([5, 0]);
                    ctxWK.lineWidth = 6;
                    for (i = 41; i < 55; i++) {
                        for (k = 7; k < 80; k++) {
                            variableName = "v0" + i;
                            textToReplace = data[variableName].substring(k, k + 1);
                            xpos = 17 + k * 5 + ((i - 41) % 2) * 360;
                            if (textToReplace == '1') {
                                ctxWK.strokeStyle = "#C31D64";	/*EKH rot*/
                                ctxWK.beginPath();
                                ctxWK.moveTo(xpos, ypos);
                                ctxWK.lineTo(xpos, ypos - 16);
                                ctxWK.stroke();
                            }
                            if (textToReplace == '0') {
                                ctxWK.strokeStyle = "#1F94B9";	/*EKH blau*/
                                ctxWK.beginPath();
                                ctxWK.moveTo(xpos, ypos);
                                ctxWK.lineTo(xpos, ypos - 10);
                                ctxWK.stroke();
                            }
                        }
                        if (((i - 41) % 2) > 0) {
                            ypos = ypos + 30;
                        }
                    }
                    // aktuelle Position markieren (senkrecht gestrichelt)
                    x = data['v061'] - 1; /*spalte, wo die texte anfang "rot" sein soll*/
                    y = data['v062'] - 1; /*Zeile, wo die Texte rot markiert werden muss*/
                    xpos = 17 + x * 5 + ((y - 1) % 2) * 360;
                    var y1 = Math.floor((y - 1) / 2);
                    ypos = 86 + y1 * 30;
                    ctxWK.setLineDash([3, 2]);
                    ctxWK.lineWidth = 3;
                    ctxWK.strokeStyle = "#000000";
                    ctxWK.beginPath();
                    ctxWK.moveTo(xpos, ypos);
                    ctxWK.lineTo(xpos, ypos - 22);
                    ctxWK.stroke();
                }

            }
        }



        function displayKameraStream(url) {
            var videomodal = document.getElementById('modalIPKamera');
            videomodal.style.display = "block";
            var videomodalHeader = document.getElementById('modalIPKameraHeader');
            videomodalHeader.innerHTML = 'Überwachungkamera der Anlage ' + Projektname;
            var imgbox = document.getElementById('ImgKamera');
            imgbox.src = getImage(url);

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

        function displayZaehler() {
            var modal = document.getElementById('modalZaehler');
            window.onclick = function (event) {
                if (event.target == modal) {
                    modal.style.display = "none";
                }
            }
            //zähler holen
            var prj = visudata.VCOData.Projektnumer;
            var Projektname = getProjektName(prj);
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

            if (gesamtZaehler != "") {
                document.getElementById("modalHeaderZaehler").innerHTML = '<h4> Zähler: ' + Projektname + " " + datetime + '<span onclick="closeModalZaehler()" class="close">&times;</span>';
                document.getElementById("modalContenZaehler").style.width = '80%';
                document.getElementById("aktuelleZaehler").innerHTML = "</br> <pre>" + gesamtZaehler + "</pre>";
                $('#datetimepicker1').datepicker().on('changeDate', function () {
                    var date = $('#inputDate').val();
                    var zaehler = getZaheler(prj, date);
                    document.getElementById("modalHeaderZaehler").innerHTML = '<h4> Zähler: ' + Projektname + " " + date + '<span onclick="closeModalZaehler()" class="close">&times;</span>';
                    if (zaehler != "") {
                        document.getElementById("aktuelleZaehler").innerHTML = "</br> <pre>" + zaehler + "</pre>";
                    }
                    else {
                        document.getElementById("aktuelleZaehler").innerHTML = "</br> <pre>  Keine Zählerdaten am: " + date + " gefunden </pre>";
                    }
                });
            }
            else {
                var aktuelleZaehler = getOnlineAktuellZaehler(prj)
                document.getElementById("modalContenZaehler").style.width = '80%';
                if (aktuelleZaehler != "") {
                    document.getElementById("modalHeaderZaehler").innerHTML = '<h4> Zähler: ' + Projektname + " " + datetime + '<span onclick="closeModalZaehler()" class="close">&times;</span>';
                    document.getElementById("aktuelleZaehler").innerHTML = "</br> <pre>" + aktuelleZaehler + "</pre>";
                }
                $('#datetimepicker1').datepicker().on('changeDate', function () {
                    var date = $('#inputDate').val();
                    var zaehler = getZaheler(prj, date);
                    document.getElementById("modalHeaderZaehler").innerHTML = '<h4> Zähler: ' + Projektname + " " + date + '<span onclick="closeModalZaehler()" class="close">&times;</span>';
                    if (zaehler != "") {
                        document.getElementById("aktuelleZaehler").innerHTML = "</br> <pre>" + zaehler + "</pre>";

                    }
                    else {
                        document.getElementById("aktuelleZaehler").innerHTML = "</br> <pre>  Keine Zählerdaten am: " + date + " gefunden </pre>";

                    }
                });
            }
            modal.style.display = "block";
        }

        function displayStoerungen() {

            var canvas = document.getElementById("myCanvas");
            var modal = document.getElementById('stoerungModal');
            window.onclick = function (event) {
                if (event.target == modal) {
                    modal.style.display = "none";
                }
            }
            //alert(stoerungText);
            if (stoerungText != "") {
                document.getElementById("modalHeader").innerHTML = '<h4> Aktuelle Störungen' + '<span id="closeModal" class="close">&times;</span>';
                document.getElementById("modalContent").style.width = '30%';
                document.getElementById("modalBody").innerHTML = "";
                document.getElementById("modalBody").innerHTML = stoerungText;
                var span = document.getElementById("closeModal");
                span.onclick = function () {
                    modal.style.display = "none";
                }
            }
            else {
                document.getElementById("modalHeader").innerHTML = '<h4> Aktuelle Störungen' + '<span id="closeModal" class="close">&times;</span>';
                document.getElementById("modalContent").style.width = '30%';
                document.getElementById("modalBody").innerHTML = "keine weiteren Störungen";
                var span = document.getElementById("closeModal");
                span.onclick = function () {
                    modal.style.display = "none";
                }
            }
            modal.style.display = "block";
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
                Draw();
            }

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
            $("#imgTarget").remove();
            $("#imgArea").prepend("<img id='imgTarget' src='" + visudata.VCOData.Bitmaps[idx].URL + "' class='coveredImage'>");
            $(".insideWrapper").css("background-color", bgColors[bmpIndex]);
        }

        // Zeichen-Hauptfunktion. Wird bei Bedarf von Timer aufgerufen
        function Draw(i) {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            if (i == undefined) {
                drawTextList();
                drawPropertyList();
            }
            else {
                drawTextList();
                VisuDownload = visuRecords[i][1];
                drawPropertyList();
                var d = visuRecords[i][0];
                var h = d.getHours(); h = ("0" + h).slice(-2);
                var m = d.getMinutes(); m = ("0" + m).slice(-2);
                var s = d.getSeconds(); s = ("0" + s).slice(-2);
                var t = h + ":" + m + ":" + s;
                $("#xlabel").empty();
                $("#xlabel").append("<bdi>Zeitstempel: " + t + "</bdi>");
                visuRecordsSlider.value = Math.ceil(visuRecords[i][0] / 1000); //muss round up the unix time, there are errors by back and forth date conversion
                if (i == visuRecords.length - 1) {
                    visuRecordsSlider.value = visuRecordsSlider.min;
                    //reset text of playback button
                    var btnSpeed = document.getElementById('btnPlaybackSpeed');
                    btnSpeed.innerHTML = "Abspielen " + "<span class=\"caret\" ></span >";
                }
            }
        }


        // Linkbutton in Liste eintragen
        function addLinkButtonToList(visudata) {
            var FreitextList = visudata.FreitextList;
            var n = FreitextList.length;
            for (var i = 0; i < n; i++) {
                var item = new Object();
                var freiTextListItem = FreitextList[i];
                var x = freiTextListItem.x;
                var y = freiTextListItem.y;
                var txt = freiTextListItem.Freitext;
                var w = ctx.measureText(txt).width;
                var h = freiTextListItem.BgHeight;
                var orientation = freiTextListItem.VerweisAusrichtung;
                var targetBmp = freiTextListItem.idxVerweisBitmap;

                item["x"] = freiTextListItem.x;
                item["y"] = freiTextListItem.y;
                item["BgColor"] = freiTextListItem.BgColor;

                if (orientation == "hor") {
                    item["x_min"] = x - 6;
                    item["y_min"] = y - h - 6;
                    item["x_max"] = x + w + 16;
                    item["y_max"] = y + 6;
                    item["bmp"] = targetBmp;
                    item["text"] = txt;
                }
                if (orientation == "up") {
                    item["x_min"] = x - h - 16;
                    item["y_min"] = y - w - 16;
                    item["x_max"] = x + 6;
                    item["y_max"] = y + 6;
                    item["bmp"] = targetBmp;
                    item["text"] = txt;
                }

                if (orientation == "dn") {
                    item["x_min"] = x - 6;
                    item["y_min"] = y - 6;
                    item["x_max"] = x + h + 16;
                    item["y_max"] = y + w + 6;
                    item["bmp"] = targetBmp;
                    item["text"] = txt;
                }
                LinkButtonList.push(item);
            }
        }

        // Linkbutton in Liste eintragen
        function addClickableElementToList(visudata) {
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

        function createEinstellbareObject(id) {
            var link = 'http://' + IPE + '/JSONADD/PUT?V008=Qz' + id;
            getData(link);

            var adjustmentOption = JSON.parse(getData(readParameterOfClickableElementUrl));
            var einstellbaresObjekt = new Object();
            einstellbaresObjekt['id'] = adjustmentOption['v070'].substring(0, 5);
            //create object for the setting
            for (var i = 71; i < 90; i++) {

                var rtosVariable = "v0" + i;
                einstellbaresObjekt[adjustmentOption[rtosVariable].substr(0, 23)] = adjustmentOption[rtosVariable].substr(24, 10);
                einstellbaresObjekt['einstellungWert'] = adjustmentOption[rtosVariable].substr(24, 10);
                einstellbaresObjekt['einstellungOberGrenze'] = adjustmentOption[rtosVariable].substr(36, 5);
                einstellbaresObjekt['einstellungUnterGrenze'] = adjustmentOption[rtosVariable].substr(42, 5);
                einstellbaresObjekt['einstellungNachkommaStellen'] = adjustmentOption[rtosVariable].substr(48, 1);
            }

            return einstellbaresObjekt;
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
            if (item["bmpIndex"] == bmpIndex) {
                var warnGrenze;
                var stoerGrenze;
                var gasSensorWert;
                var x = item.x;
                var y = item.y;
                var vco = item["VCOItem"];
                var values = VisuDownload.Items;
                var svalue = "-";
                var n = values.length;
                for (var i = 0; i < n; i++) {
                    if (vco.Bez.trim() == values[i].Bezeichnung.trim() && vco.Kanal == values[i].Kanal) {
                        var value = values[i].Wert;
                        var nk = values[i].Nachkommastellen;
                        svalue = parseFloat((value * 100) / 100).toFixed(nk);
                    }

                    if ((values[i].Bezeichnung == "GR") && (values[i].Kanal == 2)) {
                        var value = values[i].Wert;
                        var nk = values[i].Nachkommastellen;
                        warnGrenze = parseFloat((value * 100) / 100).toFixed(nk);
                    }
                    if ((values[i].Bezeichnung == "GR") && (values[i].Kanal == 3)) {
                        var value = values[i].Wert;
                        var nk = values[i].Nachkommastellen;
                        stoerGrenze = parseFloat((value * 100) / 100).toFixed(nk);
                    }
                    if (values[i].Bezeichnung == "GA") {
                        var value = values[i].Wert;
                        var nk = values[i].Nachkommastellen;
                        gasSensorWert = parseFloat((value * 100) / 100).toFixed(nk);
                    }
                    if ((values[i].Bezeichnung == "HKNA") & (vco.Kanal == values[i].Kanal)) {
                        svalue = values[i].sWert;
                    }
                }

                if (item.VCOItem.Bez.trim() == "KES") {
                    item.BgColor = "#fc1803";
                }

                if ((item.VCOItem.Bez.trim() == "GA") && (gasSensorWert > stoerGrenze)) {
                    item.BgColor = "#fc1803";
                }

                if ((item.VCOItem.Bez.trim() == "GA") && (gasSensorWert < stoerGrenze) && (gasSensorWert > warnGrenze)) {
                    item.BgColor = "#fcdf03";
                }

                if (warnGrenze != null) {
                    if ((item.VCOItem.Bez.trim() == "GA") && (gasSensorWert < warnGrenze)) {
                        item.BgColor = "#42f545";
                    }
                }

                var txt = svalue + " " + vco.sEinheit;

                if (false) { // item.ShowSymbolMenue) {
                    CurrentDroplistItem = item;
                    location.href = '#EditSymbol';
                }
                else {
                    if (vco.isBool) {
                        if (item.Symbol === `fpButton` || item.Symbol === `Heizkreis`) {
                            const val = parseFloat(svalue.trim());
                                fpButton(ctx, item.x, item.y, val);
                        }

                        if (item.Symbol == "Absenkung") {
                            const val = parseFloat(svalue.trim());
                                Absenkung(ctx, item.x, item.y, 1, val);
                        }

                        if (item.Symbol == "Feuer") {
                            const val = parseFloat(svalue.trim());
                            if (val)
                                feuer(ctx, item.x, item.y, 1);
                        }

                        if (item.Symbol == "BHKW") {
                            const val = parseFloat(svalue.trim());
                            BHDreh(ctx, item.x, item.y, 1, TimerCounter * 30 * val);
                        }

                        if (item.Symbol == "Pumpe") {
                            const val = parseFloat(svalue.trim());
                            pmpDreh2(ctx, item.x, item.y, 1, TimerCounter * 30 * val);
                        }

                        if (item.Symbol == "Luefter") {
                            const val = parseFloat(svalue.trim());
                            const angle = (val) ? TimerCounter * 30 : 30;
                            const rotation =    (item.SymbolFeature === "Rechts") ? 180 :
                                                (item.SymbolFeature === "Oben") ? 90 :
                                                (item.SymbolFeature === "Unten") ? 270 : 0;
                            luefter(ctx, item.x, item.y, 1, angle, rotation);
                        }

                        if (item.Symbol == "Ventil") {
                            const val = parseFloat(svalue.trim());
                            if (val) {
                                const rotation =    (item.SymbolFeature === "Rechts") ? 0 :
                                                    (item.SymbolFeature === "Oben") ? 270 :
                                                    (item.SymbolFeature === "Unten") ? 90 : 180;
                                ventil(ctx, item.x, item.y, 2, rotation);
                            }
                        }

                        if (item.Symbol == "Lueftungsklappe" || item.Symbol == "Abluftklappen") {
                            let val = parseFloat(svalue.trim());
                            if (val == 1) val = 100;
                            lueftungsklappe(ctx, item.x, item.y, 1, val, item.SymbolFeature);                            
                        }

                        if (item.Symbol == "Led") {
                            var b = (svalue.trim() == "1");

                            if (item.SymbolFeature == "unsichtbar/rot") {
                                if (b)
                                    Led(ctx, item.x, item.y, 1, "red");
                            }
                            if (item.SymbolFeature == "gruen/rot") {
                                if (!b)
                                    Led(ctx, item.x, item.y, 1, "green");
                                else
                                    Led(ctx, item.x, item.y, 1, "red");

                            }

                            if (item.SymbolFeature == "rot/gruen") {
                                if (!b)
                                    Led(ctx, item.x, item.y, 1, "red");
                                else
                                    Led(ctx, item.x, item.y, 1, "green");

                            }

                            if (item.SymbolFeature == "unsichtbar/rot blinkend") {
                                if (b) {
                                    if (TimerToggle)
                                        Led(ctx, item.x, item.y, 1, "red");
                                }
                            }
                            if (item.SymbolFeature == "gruen/rot blinkend") {
                                if (!b)
                                    Led(ctx, item.x, item.y, 1, "green");
                                else {
                                    if (TimerToggle)
                                        Led(ctx, item.x, item.y, 1, "red");
                                }
                            }
                        }

                        if (item.Symbol == "Schalter") {
                            const val = parseFloat(svalue.trim());
                            schalter(ctx, item.x, item.y, 1, val, item.SymbolFeature);
                        }

                        

                        hasSymbolsFlag = true;
                    }
                    else {
                        var sz = document.getElementById("selSize");
                        ctx.font = item.font;
                        var w = ctx.measureText(txt).width;
                        ctx.fillStyle = item.BgColor;
                        ctx.fillRect(x - 1, y - item.BgHeight - 1, w + 2, item.BgHeight + 3);
                        ctx.fillStyle = item.Color;
                        ctx.fillText(txt, x, y);
                    }
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
            for (i = 0; i < n; i++) {
                var item = FreitextList[i];
                if (FreitextList[i].bmpIndex == bmpIndex) {
                    var x = item.x;
                    var y = item.y;
                    var txt = item.Freitext;
                    ctx.font = item.font;
                    ctx.fillStyle = item.BgColor;
                    var w = ctx.measureText(txt).width;

                    if (item.isVerweis) {
                        ctx.save();
                        ctx.translate(x, y);
                        if (item.VerweisAusrichtung == "up")
                            ctx.rotate(-Math.PI / 2);
                        if (item.VerweisAusrichtung == "dn")
                            ctx.rotate(Math.PI / 2);
                        ctx.fillRect(0 - 6, 0 - item.BgHeight - 6, w + 16, item.BgHeight + 16);
                        ctx.strokeStyle = "black";
                        ctx.strokeRect(0 - 6, 0 - item.BgHeight - 6, w + 16, item.BgHeight + 16);
                        ctx.fillStyle = item.Color;
                        ctx.fillText(txt, 0, 0);
                        ctx.restore();
                        //remove from loop, coz add to much redundant element each loop (when bitmap change)
                        //addLinkButtonToList(x, y, w, item.BgHeight, item.VerweisAusrichtung, item.idxVerweisBitmap, item.Freitext)

                    }
                    else {
                        ctx.fillRect(x - 1, y - item.BgHeight - 1, w + 2, item.BgHeight + 3);
                        ctx.fillStyle = item.Color;
                        ctx.fillText(txt, x, y);
                    }

                    //get coordinate of Button IPKamera1
                    if (FreitextList[i].Freitext == "IP Kamera 1" & FreitextList[i].BgColor == "#ff9966") {
                        xIPKamera1Button = FreitextList[i].x - 6;
                        yIPKamera1Button = FreitextList[i].y - 22;
                        xIPkamera1ButtonBot = FreitextList[i].x + 105;
                        yIPkamera1ButtonBot = FreitextList[i].y + 18;
                    }

                    //get coordinate of Button IPKamera1
                    if (FreitextList[i].Freitext == "IP Kamera 2" & FreitextList[i].BgColor == "#ff9966") {
                        xIPKamera2Button = FreitextList[i].x - 6;
                        yIPKamera2Button = FreitextList[i].y - 22;
                        xIPkamera2ButtonBot = FreitextList[i].x + 105;
                        yIPkamera2ButtonBot = FreitextList[i].y + 18;
                    }
                }
            }
        }

        // Loggen
        function log(s) {
            $('#output').append(new Date().toLocaleTimeString() + " " + s + "<br />");
            var objDiv = document.getElementById("output");
            objDiv.scrollTop = objDiv.scrollHeight;

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

        function cbCyclicChanged() {

            var checked = $('#cbcyclicReload').prop('checked');
            bAutoReload = checked;
            if (checked == true) {
                ReloadTimerVar = setTimeout(function () { ReloadTimerFunc() }, waitReloadMS);
            }
            else
                nReloadCycles = 0;
        }

        function cbDebugChanged() {
            var checked = $('#cbDebug').prop('checked');
            showLog = checked;
            if (checked == true) {
                window.resizeTo(wInit, hInit);
                $('#output').show();
            }
            else {
                window.resizeTo(wInit, hInit - 130);
                $('#output').hide();
            }

        }



        function UpdateClickHandler() {
            var checked = $('#cbcyclicReload').prop('checked');
            if (checked == false) {
                ReloadData();
            }
        }

        function UpdateLabelMouseOverHandler() {
            $('#xlabel').css("background-color", "red");
        }

        function UpdateLabelMouseOutHandler() {
            $('#xlabel').css("background-color", "lightgrey");

        }

        function ReloadData() {
            getOnlineDataAsync(IdVisu);
        }

        function closemodalIPKamera() {
            var modalIPKamera = document.getElementById('modalIPKamera');
            modalIPKamera.style.display = 'none';
        }

        //function hideElemementById(id) {
        //    var selectedElement = document.getElementById(id);
        //    selectedElement.style.display = "none";

        //}

        function hideElemementById(id) {
            var selectedElement = document.getElementById(id);
            if (selectedElement != null) selectedElement.style.display = "none";
            return selectedElement;
        }

        function showElemementById(id) {
            var selectedElement = document.getElementById(id);
            if (selectedElement != null) selectedElement.style.display = "block";
            return selectedElement;
        }

        /*Für die Rückübertragung soll die Werte 10 stellig, rechtbündig sein (Eckhards Vorgabe)
        * Die padEnd() in Javascript kann dafür genutzt werden, diese Funktion funktioniert leider nicht im Internet Explorer
        * Eine einfache Implementation als Alternativ wird unten geführt
        *   *1 Werte werden in einzel Charakter geparst
        *   *2 Ein Array mit feste Größe von  10 Elemente erzeugt
        *   *3 Letztes Element des Charatker Array = Letztes Element des großfesten Array und weiter
        *   *4 Nachdem Auffülen wird die gebliebenen Elemente des großfesten Array mit Leerzeichen
        *   *5 Letztendlich werden die Kommas, die aus dem 1. Schritt mit Hilfe von Regex entfern
        * */
        function padStartUsingArray(wertFromTextbox, targetLength) {
            var valueInCharacter = wertFromTextbox.split('');
            var arrayFixedLength = new Array(parseInt(targetLength));
            var numberOfCharacter = valueInCharacter.length
            for (var k = 0; k < numberOfCharacter; k++) {
                arrayFixedLength[9 - k] = valueInCharacter[numberOfCharacter - 1 - k]
            }
            for (var l = 0; l < 10 - valueInCharacter.length; l++) {
                arrayFixedLength[l] = ' ';
            }
            var formatedValue = arrayFixedLength.toString().replace(/,/g, '');
            return formatedValue;
        }


        function b32(n) {
            if (!String.prototype.padStart) {
                String.prototype.padStart = function padStart(targetLength, padString) {
                    targetLength = targetLength >> 0; //truncate if number or convert non-number to 0;
                    padString = String((typeof padString !== 'undefined' ? padString : ' '));
                    if (this.length > targetLength) {
                        return String(this);
                    }
                    else {
                        targetLength = targetLength - this.length;
                        if (targetLength > padString.length) {
                            padString += padString.repeat(targetLength / padString.length); //append to original to ensure we are longer than needed
                        }
                        return padString.slice(0, targetLength) + String(this);
                    }
                };
            }
            else {

                // >>> ensures highest bit isn’t interpreted as a sign
                return (n >>> 0).toString(2).padStart(32, '0');
            }
        }

        function sleep(miliseconds) {
            var currentTime = new Date().getTime();

            while (currentTime + miliseconds >= new Date().getTime()) {
            }
        }
        /********************************Bedienung*************************************************/
        function closeFaceplate() {
            var modal = document.getElementById("fpBg");
            modal.style.display = 'none';
            destroyFaceplate();
        }

        function destroyFaceplate() {
            var modalBody = document.getElementById('fpBody');
            while (modalBody.firstChild) {
                modalBody.removeChild(modalBody.lastChild);
            }
        }

        function handleConfirmBtn(disable) {
            document.getElementById("btnFaceplateConfirm").disabled = disable;
        }


        function sendDataToRtosNEW(event) {
            if (event == null || event == undefined) return event;

            var btn;
            (typeof event) == 'string' ? btn = document.getElementById(event) : btn = event.target;
            if (btn == null || btn == undefined) return btn;

            var errorString = '';

            //Nur RtosVar für Wochenkalender ändern (Aufforderung an Rtos Kalenderdaten schicken)
            if (btn.id.toUpperCase().includes('CALENDER')) {
                ClickableElement.forEach(function (el) {
                    if (btn.idx == el.idx) el.wert = el.wert.replace('0', '1');
                });
            }
            else {
                var rtosVars = Array.from(document.getElementsByClassName('divRtosVar'));
                var changedRtosVars = [];
                rtosVars.forEach(function (el) {
                    if (el.wert != undefined) changedRtosVars.push(el);
                });

                changedRtosVars.forEach(function (changedEl) {
                    ClickableElement.forEach(function (el) {
                        if (changedEl.idx == el.idx) {
                            var changedVal = parseFloat(changedEl.wert);
                            //console.log(typeof changedEl.wert);
                            if (isNaN(changedVal) || changedEl.wert.toString().trim() == '') {
                                changedEl.style.color = '#C31D64';
                                errorString += changedEl.firstElementChild.textContent + ': ' + 'ungültige Zahl!' + '\n';
                            }
                            else if (changedVal > parseFloat(el.oberGrenze)) {
                                changedEl.style.color = '#C31D64';
                                errorString += changedEl.firstElementChild.textContent + ': ' + 'max = ' + el.oberGrenze + '\n';
                            }
                            else if (changedVal < parseFloat(el.unterGrenze)) {
                                changedEl.style.color = '#C31D64';
                                errorString += changedEl.firstElementChild.textContent + ': ' + 'min = ' + el.unterGrenze + '\n';
                            }
                            else {
                                el.wert = changedVal.toFixed(4).padStart(10).padEnd(12);
                            }
                        }
                    });
                });
            }

            if (errorString != '') {
                alert(errorString);
            }
            else {
                var sendErrors = '';
                ClickableElement.forEach(function (el) {
                    var rtosVar = '"' + el.name + el.wert + el.oberGrenze + el.unterGrenze + el.nachKommaStellen + el.einheit + el.sectionIndicator + '"';
                    //console.log(rtosVar);
                    var url = 'http://' + IPE + '/JSONADD/PUT?v' + el.idx.toString().padStart(3, '0') + '=' + encodeURIComponent(rtosVar);
                    sendDataWTAsync(url);
                    //console.log(url);
                      
                    //if (!ans.includes('OK')) sendErrors += ans;
                });
                if (sendErrors != '') console.log(sendErrors);
            }

            if (btn.id.toUpperCase().includes('CONFIRM') || btn.id.toUpperCase().includes('SEND')) closeFaceplate();
        }

        function returnValueFromRTOS(msg) {
            return msg;
        }

        //function sendDataToRtosNEW(event) {
        //	if (event == null || event == undefined) return event;

        //	var btn;
        //	(typeof event) == 'string' ? btn = document.getElementById(event) : btn = event.target;
        //	if (btn == null || btn == undefined) return btn;

        //	var errorString = '';

        //	//Nur RtosVar für Wochenkalender ändern (Aufforderung an Rtos Kalenderdaten schicken)
        //	if (!permissionVisuToRtos) {
        //		ClickableElement.forEach(function (el) {
        //			if (btn.idx == el.idx) el.wert = el.wert.replace('0', btn.wert);
        //		});
        //	}
        //	else {
        //		var rtosVars = Array.from(document.getElementsByClassName('divRtosVar'));
        //		var changedRtosVars = [];
        //		rtosVars.forEach(function (el) {
        //			if (el.wert != undefined) changedRtosVars.push(el);
        //		});

        //		changedRtosVars.forEach(function (changedEl) {
        //			ClickableElement.forEach(function (el) {
        //				if (changedEl.idx == el.idx) {
        //					var changedVal = parseFloat(changedEl.wert);
        //					//console.log(typeof changedEl.wert);
        //					if (isNaN(changedVal) || changedEl.wert.toString().trim() == '') {
        //						changedEl.style.color = '#C31D64';
        //						errorString += changedEl.firstElementChild.textContent + ': ' + 'ungültige Zahl!' + '\n';
        //					}
        //					else if (changedVal > parseFloat(el.oberGrenze)) {
        //						changedEl.style.color = '#C31D64';
        //						errorString += changedEl.firstElementChild.textContent + ': ' + 'max = ' + el.oberGrenze + '\n';
        //					}
        //					else if (changedVal < parseFloat(el.unterGrenze)) {
        //						changedEl.style.color = '#C31D64';
        //						errorString += changedEl.firstElementChild.textContent + ': ' + 'min = ' + el.unterGrenze + '\n';
        //					}
        //					else {
        //						el.wert = changedVal.toFixed(4).padStart(10).padEnd(12);
        //					}
        //				}
        //			});
        //		});
        //	}

        //	if (errorString != '') {
        //		alert(errorString);
        //	}
        //	else {
        //		var sendErrors = '';
        //		ClickableElement.forEach(function (el) {
        //			var rtosVar = '"' + el.name + el.wert + el.oberGrenze + el.unterGrenze + el.nachKommaStellen + el.einheit + el.sectionIndicator + '"';
        //			link = 'http://' + IPE + '/JSONADD/PUT?v' + el.idx.toString().padStart(3, '0') + '=' + encodeURIComponent(rtosVar);
        //			sendBackToRtosUrlList.push(link);
        //		});

        //	}
        //	for (var j = 0; j < sendBackToRtosUrlList.length; j++) {
        //		sendDataWT(sendBackToRtosUrlList[j]);
        //	}

        //	if (btn.id.toUpperCase().includes('CONFIRM') || btn.id.toUpperCase().includes('SEND')) closeFaceplate();
        //}



        function openFaceplate() {
            var n = ClickableElementList.length;
            var match;
            var matchItem;
            for (var i = 0; i < n; i++) {
                var item = ClickableElementList[i];
                var currentBitmapIndex = bmpIndex;
                if ((item.bitmapIndex == currentBitmapIndex) && (item.Bezeichnung == "HK" || item.Bezeichnung == "KES" || item.Bezeichnung == "BHK" || item.Bezeichnung == "WWL")) {
                    dx = mx - item.x;
                    dy = my - item.y;
                    if (dx * dx + dy * dy < item.radius * item.radius) {
                        match = true;
                        matchItem = item;
                        showElemementById('fpBg');
                        hideElemementById('fpContent');
                        showElemementById('visLoader');
                        for (var j = 0; j < ClickableElementUrlList.length; j++) {
                            if (ClickableElementUrlList[j].indexOf(item.id) >= 0) {
                                clickableElementUrl = ClickableElementUrlList[j];
                            }
                        }
                        sendDataWT(clickableElementUrl);
                        sleep(600);
                        getDataAsync(readParameterOfClickableElementUrl, testcallback);
                    }
                }
            }
            if (match) showFaceplate(matchItem);
        }

        function testcallback(msg) {
            ClickableElement = [];
            adjustmentOption = JSON.parse(msg);
            for (var k = 70; k < 90; k++) {
                var rtosVariable = "v0" + k;
                var option = adjustmentOption[rtosVariable];
                var newItem = new Object();
                newItem.idx = k + 20;
                newItem['name'] = '';
                newItem['wert'] = '';
                newItem["oberGrenze"] = '';
                newItem["unterGrenze"] = '';
                newItem["nachKommaStellen"] = '';
                newItem["einheit"] = '';
                newItem["sectionIndicator"] = option.substr(59, 1);

                switch (newItem["sectionIndicator"]) {
                    case 'H':
                        newItem['name'] = option.substr(0, 24);
                        newItem['wert'] = option.substr(24, 35);
                        break;
                    case 'S':
                        item['name'] = option.substr(0, 59);
                        break;
                    default:
                        newItem['name'] = option.substr(0, 24);
                        newItem['wert'] = option.substr(24, 12);
                        newItem["oberGrenze"] = option.substr(36, 6);
                        newItem["unterGrenze"] = option.substr(42, 6);
                        newItem["nachKommaStellen"] = option.substr(48, 2);
                        newItem["einheit"] = option.substr(50, 9);
                }
                ClickableElement.push(newItem);
            }
            buildFaceplateNEW();
        }

        function convertHexToRGBArray(hex) {
            var rgb;
            if (hex == undefined) return hex;
            if (hex.startsWith('#')) hex = hex.slice(1);
            if (hex.length == 3) {
                rgb = [parseInt(hex[0] + hex[0], 16),
                parseInt(hex[1] + hex[1], 16),
                parseInt(hex[2] + hex[2], 16)
                ];
            }
            if (hex.length == 6) {
                rgb = [parseInt(hex[0] + hex[1], 16),
                parseInt(hex[2] + hex[3], 16),
                parseInt(hex[4] + hex[5], 16)
                ];
            }
            return rgb;
        }

        function convertRGBArrayToHex(rgb) {
            if (!Array.isArray(rgb)) return undefined;
            if (rgb.length != 3) return undefined;

            var hex = '#';
            rgb.forEach(function (el) {
                (Math.abs(el) < 256) ? hex += Math.round(el).toString(16).toUpperCase().padStart(2, '0') : hex += '00';
                //console.log(hex);	
            });
            return hex;
        }


        function calcColor(percentVal, minColorHex, maxColorHex) {
            //console.log(percentVal, minColorHex, maxColorHex);
            if (percentVal == undefined) return percentVal;
            if (percentVal < 0) percentVal = 0;
            if (percentVal > 100) percentVal = 100;
            if (minColorHex == undefined) minColorHex = '#1F94B9';
            if (maxColorHex == undefined) maxColorHex = '#C31D64';

            var minColorRGB = convertHexToRGBArray(minColorHex);
            var maxColorRGB = convertHexToRGBArray(maxColorHex);
            var retColorRGB = [Math.round(percentVal / 100 * (maxColorRGB[0] - minColorRGB[0]) + minColorRGB[0]),
            Math.round(percentVal / 100 * (maxColorRGB[1] - minColorRGB[1]) + minColorRGB[1]),
            Math.round(percentVal / 100 * (maxColorRGB[2] - minColorRGB[2]) + minColorRGB[2])
            ];
            //console.log(retColorRGB);
            var retColorHex = convertRGBArrayToHex(retColorRGB);
            //console.log(retColorHex);
            return retColorHex;
        }

        function sliderStyling(event) {
            if (event == null || event == undefined) return event;
            //console.log(event);
            var slider = event.target;
            var percentVal = (slider.value - slider.min) / (slider.max - slider.min) * 100;
            var minColor, currentColor;
            //console.log(slider);
            if (slider.disabled) {
                minColor = '#C0C0C0';
                currentColor = minColor;
            }
            else {
                minColor = slider.minColor;
                currentColor = calcColor(percentVal, slider.minColor, slider.maxColor);

                if (slider.maxColor == '#C31D64') {
                    slider.classList.remove('quarter');
                    slider.classList.remove('half');
                    slider.classList.remove('threequarter');
                    slider.classList.remove('full');
                    if (percentVal > 80) {
                        slider.classList.add('full');
                    } else if (percentVal > 60) {
                        slider.classList.add('threequarter');
                    } else if (percentVal > 40) {
                        slider.classList.add('half');
                    } else if (percentVal > 20) {
                        slider.classList.add('quarter');
                    }
                }
            }

            //console.log(currentColor);
            slider.style.background = 'linear-gradient(to right, ' + minColor + ' 0%, ' + currentColor + ' ' + percentVal + '%, #E0E0E0 ' + percentVal + '%, #E0E0E0 100%)';

            //convertHexToRGBArray('#1F94B9');
            //calcColor(100);
        }

        function sliderHandler(event) {	//sliderHandler
            if (event == null || event == undefined) return event;

            sliderStyling(event);
            var slider;
            (typeof event) == 'string' ? slider = document.getElementById(event) : slider = event.target;
            if (slider == null || slider == undefined) return slider;

            var divRtosVar = document.getElementById('v' + slider.idx.toString().padStart(3, '0'));
            var btnHand = document.getElementById('btnHand' + slider.idx);

            //Due to wrapping the slider in a container-div (.divInpWert), the aimed target (.lblUnit) is
            //actually the parentsNextSibling...
            var parentsNextSibling = slider.parentElement.nextElementSibling;
            //return parentsNextSibling if null || undefined
            if (parentsNextSibling == null || parentsNextSibling == undefined) return parentsNextSibling;

            if (slider.unit != parentsNextSibling.unit) console.log('updateNextSiblingOfSlider: Diskrepanz "unit"');
            if (slider.unit != parentsNextSibling.unit) return null;
            //console.log(slider, parentsNextSibling);

            if (slider.max - slider.min == 101 && slider.value <= 0) slider.value = -1;
            slider.wert = slider.value;
            divRtosVar.wert = slider.wert;
            if (btnHand != null) btnHand.wert = slider.wert;
            parentsNextSibling.wert = slider.wert;
            parentsNextSibling.value = slider.value;

            //slider.min <= 0 
            (slider.max - slider.min == 101 && slider.value <= 0) ? parentsNextSibling.innerHTML = 'Zu' : parentsNextSibling.innerHTML = parentsNextSibling.value + ' ' + parentsNextSibling.unit;

            return parentsNextSibling;
        }

        function decrementSliderValue(event) {
            if (event == null || event == undefined) return event;

            var slider = event.target.nextElementSibling;
            //console.log(slider);
            slider.value -= slider.step;
            var pseudoEvent = {};
            pseudoEvent.target = slider;
            sliderHandler(pseudoEvent);
        }

        function incrementSliderValue(event) {
            if (event == null || event == undefined) return event;

            //console.log(event.target);
            var slider = event.target.previousElementSibling;
            slider.value = parseFloat(slider.value) + parseFloat(slider.step);
            //Sonderfall Analogmischer
            if (slider.unit == '%' && slider.value == 0) slider.value = parseFloat(slider.value) + parseFloat(slider.step);
            //console.log(slider.value);
            var pseudoEvent = {};
            pseudoEvent.target = slider;
            sliderHandler(pseudoEvent);
        }

        function radioBtnByNameNEW(event) {
            if (event == null || event == undefined) return event;

            var btn;
            (typeof event) == 'string' ? btn = document.getElementById(event) : btn = event.target;
            if (btn == null || btn == undefined) return btn;

            var divRtosVar = document.getElementById('v' + btn.idx.toString().padStart(3, '0'));
            if (btn.wert.toString() == '') {
                var slider = document.getElementById('inpWert' + btn.idx);
                btn.wert = slider.wert;
            }
            divRtosVar.wert = btn.wert;

            //var changedBtns = [];
            var relatedBtns = document.getElementsByName(btn.name);
            relatedBtns.forEach(function (el) {
                //console.log(el);
                if (el.id == btn.id) {
                    if (!el.className.includes('checked')) {
                        //changedBtns.push(el);
                        el.className += " checked";
                    }
                    else {
                        if (el.className.includes('uncheckable')) el.className = el.className.replace("checked", "").trim();
                    }
                }
                else {
                    //if (el.className.includes('checked')) changedBtns.push(el);
                    el.className = el.className.replace("checked", "").trim();
                }
            });

            return btn; //return event;? return changedBtns;???
        }

        function toggleSliderAbilityByBtnHandNEW(event) {
            var btn = event.target;
            if (btn == null || btn == undefined) return event;

            var enabled = btn.className.toUpperCase().includes('HAND');

            btn.parentElement.childNodes.forEach(function (el) {
                if (el.type == 'range') {
                    el.disabled = !enabled;
                    //console.log(el.className);
                    (enabled) ? el.classList.remove('disabled') : el.classList.add('disabled');
                    //console.log(el.className);
                    var pseudoEvent = {};
                    pseudoEvent.target = el;
                    sliderStyling(pseudoEvent);
                }
                if (el.className.includes('btnIncDec')) el.disabled = !enabled;
            });

        }

        function updateLblUnit(event) {
            var btn = event.target;
            if (btn == null || btn == undefined) return event;

            var lbl = btn.parentElement.nextElementSibling;
            if (lbl == null || lbl == undefined) return event;

            if (btn.title.toUpperCase().includes('HAND')) {
                (lbl.value <= 0) ? lbl.innerHTML = 'Zu' : lbl.innerHTML = lbl.value + ' ' + lbl.unit;
            }
            else {
                lbl.innerHTML = btn.title;
            }
        }

        function controlGroupBtnHandlerNEW(event) {
            if (event == null || event == undefined) return event;
            //console.log(event);
            var btn;
            (typeof event) == 'string' ? btn = document.getElementById(event) : btn = event.target;

            var returnedBtn = radioBtnByNameNEW(event); //returned event??!
            if (btn != returnedBtn) console.log('fpBtnHandler: btn != returnedBtn');
            if (btn != returnedBtn) return btn; //return event;???	
            //if (btn.className.includes('Hand')) disableSliderNEW();
            toggleSliderAbilityByBtnHandNEW(event);
            updateLblUnit(event);
            //console.log(btn);
        }

        function createControlGroup(fpSection, el) {
            //div mit ID=rtosVariable erzeugen & anhängen (return object)
            var divRtosVar = document.createElement('div');
            fpSection.appendChild(divRtosVar);
            divRtosVar.id = 'v' + el.idx.toString().padStart(3, '0');
            divRtosVar.className = 'divRtosVar';
            divRtosVar.idx = el.idx;

            //Namenslabel erzeugen & anhängen
            var lblName = document.createElement('label');
            divRtosVar.appendChild(lblName);
            lblName.className = 'lblName';
            lblName.innerHTML = el.name.trim();

            //Inputelemente (btns, slider, number, etc.) erzeugen & anhängen
            var divInpWert = document.createElement('div');
            divRtosVar.appendChild(divInpWert);
            divInpWert.className = 'divInpWert';
            divInpWert.id = divInpWert.className + el.idx;
            divInpWert.idx = el.idx;

            //zu erzeugende Elemente auf Basis der Range ermitteln:
            var range = (parseFloat(el.oberGrenze.trim()) - parseFloat(el.unterGrenze.trim()) + 1) * Math.pow(10, el.nachKommaStellen);

            //Zeilenumbruch vor lblName anfügen, um Textausrichtung mittig zu Btns (außer Kalender) zu setzen
            if (range <= 4 && !lblName.innerHTML.includes('kalender')) lblName.innerHTML = '\n' + lblName.innerHTML;

            //-Button vor Slider erzeugen
            if (range > 4) {
                var btnIncDec = document.createElement('input');
                divInpWert.appendChild(btnIncDec);
                btnIncDec.type = 'button';
                btnIncDec.className = 'btnIncDec btnDec';
                var btnVal = Math.pow(10, -el.nachKommaStellen);
                if (btnVal < 1) btnVal = btnVal.toString().slice(1);
                btnIncDec.value = '-';// + btnVal;
                btnIncDec.onclick = decrementSliderValue;
            }

            var inpWert = document.createElement('input');
            divInpWert.appendChild(inpWert);
            inpWert.className = 'inpWert';
            inpWert.id = inpWert.className + el.idx;
            inpWert.idx = el.idx;
            inpWert.unit = el.einheit.trim();
            //if (inpWert.unit.includes('&deg') || el.name.includes('Betriebsart')) inpWert.className += ' gradientSlider';
            inpWert.unterGrenze = parseFloat(el.unterGrenze.trim());
            inpWert.oberGrenze = parseFloat(el.oberGrenze.trim());
            inpWert.min = inpWert.unterGrenze;
            inpWert.minColor = '#1F94B9';
            inpWert.max = inpWert.oberGrenze;
            if (inpWert.unit.includes('&deg') || lblName.innerHTML.includes('Kessel') || lblName.innerHTML.includes('BHKW')) {
                inpWert.maxColor = '#C31D64';
            }
            else {
                inpWert.maxColor = '#1F94B9';
            }
            inpWert.step = Math.pow(10, -el.nachKommaStellen);
            inpWert.wert = parseFloat(el.wert);

            //+Button hinter Slider erzeugen
            if (range > 4) {
                var btnIncDec = document.createElement('input');
                divInpWert.appendChild(btnIncDec);
                btnIncDec.type = 'button';
                btnIncDec.className = 'btnIncDec btnInc';
                var btnVal = Math.pow(10, -el.nachKommaStellen);
                if (btnVal < 1) btnVal = btnVal.toString().slice(1);
                btnIncDec.value = '+';// + btnVal;
                btnIncDec.onclick = incrementSliderValue;
            }

            //console.log(range);
            var checkedBtn;
            switch (range) {

                //createTriggerBtn (Einmalig...); radioBtnByNameNEW
                case 2:
                    inpWert.type = 'button';
                    inpWert.id = 'triggerBtn';
                    inpWert.className += ' btnBA';
                    inpWert.className += ' uncheckable';
                    inpWert.name = 'triggerBtn';
                    inpWert.wert = 1;
                    inpWert.title = el.name.trim();
                    inpWert.onclick = radioBtnByNameNEW;
                    if (el.name.toUpperCase().includes('AUS')) {
                        inpWert.id += 'Aus';
                        inpWert.className += ' btnAus';
                    }
                    else if (el.name.toUpperCase().includes('EIN')) {
                        inpWert.id += 'Ein';
                        inpWert.className += ' btnEin';
                    }
                    if (el.wert == inpWert.wert) checkedBtn = inpWert;
                    break;

                //createBtnCalender || createBtnGroup
                case 3:
                    if (parseFloat(el.unterGrenze.trim()) == 0) {
                        inpWert.type = 'button';
                        inpWert.id = 'calenderBtn';
                        inpWert.className += ' calenderBtn';
                        locked ? inpWert.wert = 2 : inpWert.wert = 1;
                        inpWert.value = 'zum Kalender';
                        inpWert.title = 'Absenkungswochenkalender öffnen';
                        if (inpWert.wert == 2) inpWert.title += ' (schreibgeschützt)';
                        inpWert.onclick = jumpToWochenKalender;
                    }

                    if (parseFloat(el.unterGrenze.trim()) == -1) {
                        for (var i = 0; i < 3; i++) {
                            if (i > 0) {
                                var inpWert = document.createElement('input');
                                divInpWert.appendChild(inpWert);
                                inpWert.className = 'inpWert';
                                inpWert.idx = el.idx;
                            }

                            var id;
                            if (i == 0) id = 'Auto';
                            if (i == 1) id = 'Ein';
                            if (i == 2) id = 'Aus';

                            inpWert.type = 'button';
                            inpWert.title = id;
                            inpWert.id = 'btn' + id + el.idx;	//el.idx nutzen um eindeutige IDs zu erzeugen
                            inpWert.className += ' btnBA';
                            inpWert.className += (' btn' + id);
                            inpWert.name = 'btnBA' + el.idx;	//el.idx nutzen um eindeutige RadioGroups zu erzeugen
                            (i == 2) ? inpWert.wert = -1 : inpWert.wert = i;
                            inpWert.onclick = radioBtnByNameNEW;
                            if (el.wert == inpWert.wert) checkedBtn = inpWert;
                        }
                    }
                    break;

                //createBtnGroup3PMischer (Auto, HandOpen, HandClose, Stop)
                case 4:
                    for (var i = 0; i < 4; i++) {
                        if (i > 0) {
                            var inpWert = document.createElement('input');
                            divInpWert.appendChild(inpWert);
                            inpWert.className = 'inpWert';
                            inpWert.idx = el.idx;
                        }

                        var id;
                        if (i == 0) id = 'Auto';
                        if (i == 1) id = 'Auf';
                        if (i == 2) id = 'Zu';
                        if (i == 3) id = 'Stopp';

                        inpWert.type = 'button';
                        inpWert.title = id;
                        inpWert.id = 'btn' + id + el.idx;	//el.idx nutzen um eindeutige IDs zu erzeugen
                        inpWert.className += ' btnBA';
                        inpWert.className += (' btn' + id);
                        inpWert.name = 'btnValve' + el.idx;	//el.idx nutzen um eindeutige RadioGroups zu erzeugen
                        (i == 3) ? inpWert.wert = -1 : inpWert.wert = i;
                        inpWert.onclick = radioBtnByNameNEW;
                        if (el.wert == inpWert.wert) checkedBtn = inpWert;
                    }
                    break;

                //createSliderBtnCombo (Auto, Hand/(HandOn, HandOff))
                case 101: //Kesselpumpe: (hat kein 'Aus' [-1]!; min = 1 statt 2)
                    inpWert.min = 1;
                case 102:
                    lblName.innerHTML = 'Handwert\n\n' + lblName.innerHTML;

                    var iterations = range - 100 + 1;
                    /*console.log(el.name.toUpperCase().includes('MISCHER'));*/
                    if (el.name.toUpperCase().includes('MISCHER') || el.name.toUpperCase().includes('VENTIL'))
                        iterations = 1;//*/			//SONDERFALL MISCHER!

                    for (var i = 0; i <= iterations; i++) {
                        var inpBtn = document.createElement('input');
                        divInpWert.appendChild(inpBtn);
                        inpBtn.className = 'inpWert';
                        inpBtn.idx = el.idx;

                        var id;
                        if (i == 0) {
                            id = 'Auto';
                            inpBtn.wert = 0;
                        }
                        if (i == 1) {
                            id = 'Hand';
                            inpBtn.wert = '';
                        }
                        if (i == 2) {
                            id = 'Ein';
                            inpBtn.wert = 1;
                        }
                        if (i == 3) {
                            id = 'Aus';
                            inpBtn.wert = -1;
                            inpWert.min = 2;
                        }

                        inpBtn.type = 'button';
                        (id == 'Ein') ? inpBtn.title = id + ' (Sollw. intern)' : inpBtn.title = id;
                        inpBtn.id = 'btn' + id + el.idx;//el.idx nutzen um eindeutige IDs zu erzeugen
                        inpBtn.className += ' btnBA';
                        inpBtn.className += (' btn' + id);
                        inpBtn.name = 'btnBA' + el.idx;	//el.idx nutzen um eindeutige RadioGroups zu erzeugen
                        //console.log(el.idx);
                        //(i == 3) ? inpBtn.value = -1 : inpBtn.value = i/2;
                        inpBtn.onclick = controlGroupBtnHandlerNEW;
                        if (el.wert == inpBtn.wert) checkedBtn = inpBtn;
                        //console.log(checkedBtn);
                    }
                    if (checkedBtn == undefined || checkedBtn == null) checkedBtn = document.getElementById('btnHand' + el.idx);
                //hier KEIN break um zusätzlichen slider zu erzeugen!
                //break;
                //createSlider/Number?
                default:
                    inpWert.type = 'range';

                    inpWert.value = inpWert.wert;
                    if (parseFloat(inpWert.value) < parseFloat(inpWert.min)) inpWert.value = inpWert.min;
                    if (parseFloat(inpWert.value) > parseFloat(inpWert.max)) inpWert.value = inpWert.max;
                    inpWert.wert = inpWert.value;

                    if (inpWert.type == 'number' || inpWert.type == 'text') inpWert.onclick = showOSK; //OSK für 'text' & 'number' bei Eingabe einblenden
                    if (inpWert.type == 'range') inpWert.oninput = sliderHandler;
            }

            //Unit-Label erzeugen & anhängen
            var lblUnit = document.createElement('label');
            divRtosVar.appendChild(lblUnit);
            lblUnit.className = 'lblUnit';
            lblUnit.idx = el.idx;
            lblUnit.value = inpWert.value;//parseFloat(el.wert);
            lblUnit.unit = el.einheit.trim();
            if (lblUnit.unit != '' && lblUnit.unit != '3P') lblUnit.innerHTML = inpWert.value + ' ' + inpWert.unit;
            if (lblUnit.innerHTML.includes('undefined')) lblUnit.innerHTML = "";

            //pseudoEvents ausführen um aktuellen Zustand zu Initiieren
            var pseudoEvent = {};
            if (inpWert.type == 'range') {
                pseudoEvent.target = inpWert;
                sliderHandler(pseudoEvent);
            }

            if (checkedBtn != null && checkedBtn != undefined) {
                pseudoEvent.target = checkedBtn;
                (range > 4) ? controlGroupBtnHandlerNEW(pseudoEvent) : radioBtnByNameNEW(pseudoEvent);
            }
            //return divRtosVar;
        }

        function buildFaceplateNEW() {            
            let fpSection;
            ClickableElement.forEach(function (el) {
                const h4fpHeader = document.getElementById('h4FpHeader');
                if (el.sectionIndicator.toUpperCase() == 'H')
                    h4fpHeader.innerHTML = `Einstellungen für ${el.wert.trim()}`;
                
                const sectionTitle =    (el.name.includes('Betriebsart') || el.name.includes('Wochenkalender')) ? el.name.trim() :
                                        (el.name.includes('NennVL')) ? 'HK-Temperaturparameter' :
                                        (el.name.includes('20 &degC')) ? 'Pumpenkennlinie\n(nach Außentemperatur)' : 
                                        undefined;
                
                if (sectionTitle || !fpSection) {
                    //Beginn neue Section
                    //neue Section erzeugen & anhängen
                    fpSection = document.createElement('div');
                    const fpBody = document.getElementById('fpBody');
                    fpBody.appendChild(fpSection);
                    fpSection.className = 'fpSection';

                    //Zwischenüberschrift erzeugen & anhängen
                    var h5fpSection = document.createElement('h5');
                    fpSection.appendChild(h5fpSection)
                    if (sectionTitle)
                        h5fpSection.innerHTML = sectionTitle;
                }

                //FP-Zeile erzeugen
                if (el.sectionIndicator.toUpperCase() != 'H' && el.wert.trim() != '')
                    createControlGroup(fpSection, el);
            });
        }

        //function jumpToWochenKalender(event) {
        //	//1.Deaktivieren Autoreload Funktion beim Fernbedienung ? (überlegung)
        //	clearInterval(fernbedienungAutoReload);
        //	//2.Der Wert 'HK Wochenkalender' wird auf 1 geändert und zurückübertragen (gesamte 20 Zeile)
        //	//Pearl-seitig wird das HK-Wochenkalender aufm Canvas gerendert.
        //	//var sendError = sendValueFromVisuToRtos('openHKWochenKalender');
        //	var sendError = sendDataToRtosNEW(event);
        //	if (!sendError) {
        //		//3.Modalfenster mit eingebettets Heizkreiswochenkalender einblenden oder Fernbedienung Tab im Iframe darstellen
        //     	//showElemementById('wochenKalenderImVisu');

        //		showWochenKalenderVisu();
        //		activeTabID = 'wochenKalenderImVisu';
        //		wochenKalenderImVisuAutoReload = setInterval(refreshTextAreaWithoutParameterLocal, 50, wochenKalenderImVisuCanvasContext, wochenKalenderImVisuCanvas);
        //	}
        //}


        function closeModalWochenKalenderImVisu() {
            hideElemementById('wochenKalenderImVisu');
            sendData(clickableElementUrl);
            //sendValueFromVisuToRtos('closeHKWochenKalender');
            //AnchorHandler(1);	//Sprung ins Hauptmenü, wenn Kalender geschlossen wird
            //showElemementById('osk');	//osk für Faceplate öffnen
        }

        function showOSK(event) {
            if (event.target.id.includes('inputWert')) showElemementById('osk');
        }

        function showFaceplate(matchItem) {
            const OFFSET_ICON_2_FACEPLATE_PX = 80;
            const OFFSET_FP_2_OSK = 40;
            var faceplateBackground = showElemementById('fpBg');
            hideElemementById('visLoader');
            var faceplateContent = showElemementById('fpContent');//document.getElementById('fpContent');
            var osk = showElemementById('osk');	//osk temporär zu Anordnungsberechnung öffnen; wird am Ende wieder geschlossen!

            if (matchItem.x + OFFSET_ICON_2_FACEPLATE_PX + faceplateContent.offsetWidth < window.innerWidth) {
                faceplateContent.style.left = matchItem.x + OFFSET_ICON_2_FACEPLATE_PX + 'px';
                /*faceplateContent.offsetLeft + osk.offsetWidth < window.innerWidth ? osk.style.left = faceplateContent.style.left : osk.style.left = faceplateContent.offsetLeft + faceplateContent.offsetWidth - osk.offsetWidth + 'px';*/
            }
            else if (matchItem.x - OFFSET_ICON_2_FACEPLATE_PX - faceplateContent.offsetWidth > 0) {
                faceplateContent.style.left = matchItem.x - OFFSET_ICON_2_FACEPLATE_PX - faceplateContent.offsetWidth + 'px';
                /*faceplateContent.offsetLeft + osk.offsetWidth < window.innerWidth ? osk.style.left = faceplateContent.style.left : osk.style.left = faceplateContent.offsetLeft + faceplateContent.offsetWidth - osk.offsetWidth + 'px';*/
            }
            else {
                faceplateContent.style.left = '0px';
                osk.style.left = '0px';
            }

            if (faceplateContent.offsetTop + faceplateContent.offsetHeight + OFFSET_FP_2_OSK + osk.offsetHeight < window.innerHeight) {
                osk.style.top = faceplateContent.offsetTop + faceplateContent.offsetHeight + OFFSET_FP_2_OSK + 'px';
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
            var faceplateHeader = document.getElementById('h4FpHeader');
            kalenderHeader.textContent = faceplateHeader.textContent.replace('Einstellungen', 'Wochenkalender');
            //console.log(wochenKalenderImVisu);
            wochenKalenderImVisu.style.display = "block";
            //console.log(wochenKalenderImVisuContent.width());

            var kalenderLeft = faceplate.offsetLeft + faceplate.clientWidth - wochenKalenderImVisuContent.width();
            if (kalenderLeft < 10) kalenderLeft = 10;

            wochenKalenderImVisuContent.css('left', kalenderLeft);
            wochenKalenderImVisuContent.css('top', faceplate.offsetTop);
            hideElemementById('osk');	//osk ausblenden wenn Kalender geöffnet wird
        }

        /**************************************Recorddata********************************************************************/
        //save canvas (#myCanvas) as png
        function visuScreenshot() {
            canvas = document.getElementById('myCanvas');
            var imgData = canvas.toDataURL("image/png", 1);

        }

        function PlayPauseToggle() {
            if (isVisuPlaying) {
                Pause();
            }
            else {
                Play();
            }
        }

        function Pause() {
            clearInterval(refreshIntervalId);
            isVisuPlaying = false;
            var playPauseBtn = document.getElementById('btnPlayPause');
            playPauseBtn.value = "Fortsetzen";
        }

        function Play() {
            clearInterval(refreshIntervalId);
            playback(globalPlaybackPosition, playbackSpeed);
            isVisuPlaying = true;
            var playPauseBtn = document.getElementById('btnPlayPause');
            playPauseBtn.value = "Pause";
        }

        function showRecordResults(id) {
            /*alert('tea time');*/
            //disable the automatical data refresh if any
            bAutoReload = false;

            //create max value of the slider
            var endTime = Date.parse(visuRecords[visuRecords.length - 1][0]) / 1000;
            visuRecordsSlider.max = endTime;

            //show slider and playback button
            var continuePlayButton = document.getElementById('btnPlayPause');
            continuePlayButton.style.display = 'inline-block';

            visuRecordsSlider.style.display = 'inline-block';

            //hide stop recording button
            var stopButton = document.getElementById('btnStopRecord');
            stopButton.style.display = 'none';

            // quit current running drawing
            clearInterval(refreshIntervalId);

            //set playback speed as fraction of recording interval
            if (id == '1x') {
                playbackSpeed = waitReloadMS;
                //add speed to playback button
                var btnSpeed = document.getElementById('btnPlaybackSpeed');
                btnSpeed.innerHTML = "Abspielgeschwindigkeit: " + id + " " + "<span class=\"caret\" ></span >";
            }
            if (id == '2x') {
                playbackSpeed = waitReloadMS / 2;
                //add speed to playback button
                var btnSpeed = document.getElementById('btnPlaybackSpeed');
                btnSpeed.innerHTML = "Abspielgeschwindigkeit: " + id + " " + "<span class=\"caret\" ></span >";
            }
            if (id == '4x') {
                playbackSpeed = waitReloadMS / 4;
                //add speed to playback button
                var btnSpeed = document.getElementById('btnPlaybackSpeed');
                btnSpeed.innerHTML = "Abspielgeschwindigkeit: " + id + " " + "<span class=\"caret\" ></span >";
            }
            if (id == '8x') {
                playbackSpeed = waitReloadMS / 8;
                //add speed to playback button
                var btnSpeed = document.getElementById('btnPlaybackSpeed');
                btnSpeed.innerHTML = "Abspielgeschwindigkeit: " + id + " " + "<span class=\"caret\" ></span >";
            }
            if (id == '16x') {
                playbackSpeed = waitReloadMS / 16;
                //add speed to playback button
                var btnSpeed = document.getElementById('btnPlaybackSpeed');
                btnSpeed.innerHTML = "Abspielgeschwindigkeit: " + id + " " + "<span class=\"caret\" ></span >";
            }

            //set globalPlaybackPosition to 0, when slider catch slider.max (max)
            //slider value was reset on Draw() function
            if (visuRecordsSlider.value == visuRecordsSlider.min) {
                globalPlaybackPosition = 0;

            }


            //continues playback at the last position
            playback(globalPlaybackPosition, playbackSpeed);
        }


        function playback(currentPlayBackPosition, playbackSpeed) {

            clearInterval(refreshIntervalId);

            //change Start/Pause button status
            var playPauseBtn = document.getElementById('btnPlayPause');
            playPauseBtn.value = "Pause";
            isVisuPlaying = true;

            refreshIntervalId = setInterval(function () {
                if (currentPlayBackPosition < (visuRecords.length)) {
                    Draw(currentPlayBackPosition);
                } else {
                    clearInterval(refreshIntervalId);
                }
                currentPlayBackPosition++;
                globalPlaybackPosition = currentPlayBackPosition;
            }, playbackSpeed)
        }


        function sliderUpdated(newVal) {

            clearInterval(refreshIntervalId);

            //create date variable from slider value
            var selectDate = new Date(newVal * 1000);
            // update date on label
            var h = selectDate.getHours(); h = ("0" + h).slice(-2);
            var m = selectDate.getMinutes(); m = ("0" + m).slice(-2);
            var s = selectDate.getSeconds(); s = ("0" + s).slice(-2);
            var t = h + ":" + m + ":" + s;
            $("#xlabel").empty();
            $("#xlabel").append("<bdi>Zeitstempel: " + t + "</bdi>");

            //var aktuellePosition;
            for (var i = 0; i < visuRecords.length; i++) {
                clearInterval(refreshIntervalId);
                var sliderValue = Math.ceil(visuRecords[i][0].getTime() / 1000); //muss round up the unix time, there are errors by back and forth date conversion
                if (((sliderValue - visuRecordsSlider.step) < newVal) && (newVal < (sliderValue + visuRecordsSlider.step))) {  //when the value of the slider lay in between two recorded values, the smaller recorded value and its index will be took for condition check
                    globalPlaybackPosition = i;
                }
            }
            //draw the dataset at the selected time on slider and pause
            //Pause();
            //Draw(globalPlaybackPosition);

            //or
            //continue playback after changes on slider
            playback(globalPlaybackPosition, playbackSpeed);
        }


        function startRecording(id) {

            //quitting automatical close visu windows
            // this setting can be found at visuView.aspx
            clearTimeout(autoCloseVisuWindows);

            //quitting automatical data reload
            document.getElementById("cbcyclicReload").checked = false;
            cbCyclicChanged();

            //reset visurecords array at start of each session
            visuRecords = [];

            //stop recording after specified time
            if (id == '15') {
                var timeOut = id * 60 * 1000
                visuDatenRecording = setInterval(recordVisuDataAsync, waitReloadMS);
                setTimeout(function () {
                    stopRecording();
                }, timeOut);
            }
            if (id == '30') {
                var timeOut = id * 60 * 1000
                visuDatenRecording = setInterval(recordVisuDataAsync, waitReloadMS);
                setTimeout(function () {
                    stopRecording();
                }, timeOut);
            }
            if (id == '45') {
                var timeOut = id * 60 * 1000
                visuDatenRecording = setInterval(recordVisuDataAsync, waitReloadMS);
                setTimeout(function () {
                    stopRecording();
                }, timeOut);
            }
            if (id == '60') {
                var timeOut = id * 60 * 1000
                visuDatenRecording = setInterval(recordVisuDataAsync, waitReloadMS);
                setTimeout(function () {
                    stopRecording();
                }, timeOut);
            }
            if (id == 'unlimited') {
                visuDatenRecording = setInterval(recordVisuDataAsync, waitReloadMS);
            }

            //show hide, change status text for diverse button for better logic
            var recordButton = document.getElementById('btnStartRecord');
            recordButton.innerText = 'Aufnahme läuft';
            var stopButton = document.getElementById('btnStopRecord');
            stopButton.style.display = 'inline-block';
            var viewButton = document.getElementById('btnPlaybackSpeed');
            viewButton.style.display = 'none';
            var continuePlayButton = document.getElementById('btnPlayPause');
            continuePlayButton.style.display = 'none';

            visuRecordsSlider.style.display = 'none';

            //styling start recording button with running backgroud 
            var className = $('#btnStartRecord').attr('class');
            $("#btnStartRecord").removeClass(className).addClass("btn btnStartRecordPressed");
        }

        function stopRecording() {
            //quit current recording session
            clearInterval(visuDatenRecording);

            //create slider range with time stamp from first item of visurecords
            // last item will be created at showRecordResults(). The async ajax call add extra element to visuRecords after stopRecording() was called
            var startTime = Date.parse(visuRecords[0][0]) / 1000;
            visuRecordsSlider.min = startTime;
            visuRecordsSlider.value = visuRecordsSlider.min
            //slider with date  time hat default step of 1 second
            //this step should be the same as the data refresh rate 
            visuRecordsSlider.step = waitReloadMS / 1000;

            //show hide, change status text diverse button
            var recordButton = document.getElementById('btnStartRecord');
            var play = '\u25b6'; //play symbol in unicode 
            recordButton.innerText = "Start Aufnahme " + play;

            var btnplaybackSpeedn = document.getElementById('btnPlaybackSpeed');
            btnplaybackSpeedn.style.display = 'inline-block';

            var btnStoprecording = document.getElementById('btnStopRecord');
            btnStoprecording.style.display = 'none';

            //reset start button styling to normal
            var className = $('#btnStartRecord').attr('class');
            $("#btnStartRecord").removeClass(className).addClass("btn btn-default");
        }

        function recordVisuDataAsync() {
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getVisuDataRaw",
                data: '{Projektnummer: ' + "'" + IdVisu + "'" + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (response) {
                    var r = response.d;
                    log("getOnlineData ok");
                    VisuDownload = $.parseJSON(r);
                },
                complete: function (xhr, status) {
                    log("getOnlineData complete");
                    var d = new Date();
                    var h = d.getHours(); h = ("0" + h).slice(-2);
                    var m = d.getMinutes(); m = ("0" + m).slice(-2);
                    var s = d.getSeconds(); s = ("0" + s).slice(-2);
                    var t = h + ":" + m + ":" + s;

                    $("#xlabel").empty();
                    $("#xlabel").append("<bdi>Letztes Update: " + t + "</bdi>");
                    if (xhr.responseJSON.d == "") {
                        var e = status;
                    }
                    visuRecords.push([d, $.parseJSON(xhr.responseJSON.d)]);
                    Draw();
                },
                error: function (msg) {
                    log("getOnlineData fail: " + msg);
                }
            });
        }


        function zeroPad(num, places) {
            var zero = places - num.toString().length + 1;
            return Array(+(zero > 0 && zero)).join("0") + num;
        }
        function formatDT(__dt) {
            var year = __dt.getFullYear();
            var month = zeroPad(__dt.getMonth() + 1, 2);
            var date = zeroPad(__dt.getDate(), 2);
            var hours = zeroPad(__dt.getHours(), 2);
            var minutes = zeroPad(__dt.getMinutes(), 2);
            var seconds = zeroPad(__dt.getSeconds(), 2);
            return year + '-' + month + '-' + date + ' ' + hours + ':' + minutes + ':' + seconds;
        }


        /*******************************************SymbolAnimation*************************************************************/
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
            if (betrieb != '0') {
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


        function Absenkung(ctx, x, y, scale, active) {
            ctx.save();
            ctx.moveTo(0 - 10 * scale, 0);
            ctx.font = '10pt Arial';
            ctx.fillStyle = `#1F94B9`; /*EKH Cyan*/ //'blue';

            ctx.translate(x, y);

            if (active == 1)
                ctx.fillText('Nacht', 0, 0);
            else
                ctx.fillText('Tag', 1, 0);

            ctx.restore();
        }


        function BHDreh(ctx, x, y, scale, rotation) {
            ctx.save();
            ctx.lineWidth = 1 * scale;
            ctx.translate(x, y);
            ctx.rotate(Math.PI / 180 * rotation);
            ctx.strokeStyle = `#1F94B9`; /*EKH Cyan*/ //"steelblue";
            ctx.beginPath();
            ctx.arc(0, 0, 13 * scale, 0, Math.PI * 2, true);

            ctx.moveTo(0 + 10 * scale, 0);
            ctx.arc(0, 0, 10 * scale, 0, -Math.PI / 4, true);
            ctx.moveTo(0 + 10 * scale, 0);
            ctx.arc(0, 0, 10 * scale, 0, Math.PI / 4, false);

            ctx.moveTo(0 - 10 * scale, 0);
            ctx.arc(0, 0, 10 * scale, Math.PI, -3 * Math.PI / 4, false);
            ctx.moveTo(0 - 10 * scale, 0);
            ctx.arc(0, 0, 10 * scale, Math.PI, 3 * Math.PI / 4, true);
            ctx.stroke();

            ctx.lineWidth = 3 * scale;

            ctx.beginPath();
            ctx.moveTo(0 - 10 * scale, 0);
            ctx.lineTo(0 + 10 * scale, 0);

            ctx.stroke();
            ctx.restore();
        }


        function feuer(ctx, x, y, scale) {
            // 30x48
            var rd1 = (Math.random() - 0.5) * 3;
            var rd2 = (Math.random() - 0.5) * 3;
            var rd3 = (Math.random() - 0.5) * 3;
            var rd4 = (Math.random() - 0.5) * 3;
            var rd5 = (Math.random() - 0.5) * 3;
            var rd6 = (Math.random() - 0.5) * 3;
            ctx.save();

            ctx.lineWidth = 1;
            ctx.translate(x, y);
            ctx.scale(scale, scale);
            ctx.strokeStyle = "red";
            ctx.fillStyle = "yellow";
            ctx.beginPath();
            ctx.moveTo(0 + rd1, -20);
            ctx.lineTo(-5 + rd2, -10);
            ctx.lineTo(-8 + rd3, -5);
            ctx.lineTo(-7 + rd4, 5);
            ctx.lineTo(-2 + rd5, 10);

            ctx.lineTo(2 + rd5, 10);
            ctx.lineTo(4 + rd4, 5);
            ctx.lineTo(6 + rd6, -5);
            ctx.lineTo(5 + rd2, -10);
            ctx.lineTo(0 + rd1, -20);
            ctx.fill();
            ctx.stroke();

            //ctx.closePath();
            ctx.restore();
        }

        function pmpDreh2(ctx, x, y, scale, rot) {
            // 12x12
            var startAngle = 1.1 * Math.PI;
            var endAngle = 1.9 * Math.PI;
            ctx.save();
            ctx.strokeStyle = "black";
            ctx.fillStyle = "black";
            ctx.lineWidth = 1;
            ctx.translate(x, y);
            ctx.rotate(Math.PI / 180 * rot);
            ctx.scale(scale, scale);
            ctx.beginPath();
            ctx.arc(0, 0, 11, 0, Math.PI * 2, true);
            ctx.stroke();
            ctx.closePath();
            ctx.beginPath();
            ctx.lineWidth = 1.5;
            ctx.arc(0, 0, 6, 0, Math.PI * 2, true);
            ctx.fillStyle = 'black';
            ctx.fill();
            ctx.closePath();
            ctx.beginPath();
            ctx.arc(0, 0, 6, startAngle, endAngle, true);
            ctx.lineTo(0, 0);
            ctx.fillStyle = 'white';
            ctx.fill();
            ctx.closePath();

            ctx.stroke();
            ctx.restore();
        }

        function drawEllipse(ctx, x, y, w, h) {
            var kappa = .5522848,
                ox = (w / 2) * kappa, // control point offset horizontal
                oy = (h / 2) * kappa, // control point offset vertical
                xe = x + w,           // x-end
                ye = y + h,           // y-end
                xm = x + w / 2,       // x-middle
                ym = y + h / 2;       // y-middle


            ctx.moveTo(x, ym);
            ctx.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y);
            ctx.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym);
            ctx.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye);
            ctx.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym);
            //ctx.closePath(); // not used correctly, see comments (use to close off open path)
            ctx.stroke();
        }

        function luefter(ctx, x, y, scale, rotL, rotDir) {
            // 51x51
            ctx.save();
            ctx.strokeStyle = "black";
            ctx.fillStyle = "grey";
            ctx.lineWidth = 1;
            ctx.translate(x, y);
            ctx.rotate(Math.PI / 180 * rotDir);
            ctx.scale(scale, scale);
            ctx.beginPath();
            ctx.arc(0, 0, 24, 0, Math.PI * 2, true);
            ctx.moveTo(0, -24);
            ctx.lineTo(-23, -5);
            ctx.moveTo(0, 24);
            ctx.lineTo(-23, 5);
            ctx.stroke();
            ctx.closePath();
            ctx.beginPath();
            ctx.rotate(Math.PI / 180 * rotL);
            drawEllipse(ctx, 0, -5, 22, 10);
            drawEllipse(ctx, -22, -5, 22, 10);
            ctx.fill();

            ctx.restore();
        }

        //Zeichnen: Abluftklappe 
        function ablufklappen(ctx, x, y, scale, rot) {
            ctx.save();
            ctx.strokeStyle = "black";
            ctx.lineWidth = 1;
            ctx.translate(x, y);
            ctx.scale(scale, scale);
            ctx.beginPath();
            //Kreis zeichnen
            ctx.arc(15, 0, 3, 0, 2 * Math.PI, false);
            ctx.fillStyle = 'black';
            ctx.fill();

            //Linine durch den Kreis zeichnen ggf. rotieren
            //rotation 0 = bool value = 1
            if (rot == 0) {
                ctx.moveTo(0, 0);
                ctx.lineTo(30, 0);
            }
            //rotation 0 = bool value = 0
            if (rot == 45) {
                ctx.rotate(45 * Math.PI / 180);
                ctx.moveTo(0, 0);
                ctx.lineTo(30, 0);

            }
            ctx.stroke();
            ctx.restore();
        }

        function ventil(ctx, x, y, scale, rot) {
            // 6x6
            ctx.save();
            ctx.strokeStyle = "black";
            ctx.fillStyle = "black";
            ctx.lineWidth = 1;
            ctx.translate(x, y);
            ctx.rotate(Math.PI / 180 * rot);
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


        function Led(ctx, x, y, scale, col) {
            ctx.save();
            ctx.strokeStyle = "black";
            ctx.fillStyle = "#aaa";
            ctx.lineWidth = 1;
            ctx.translate(x, y);
            ctx.scale(scale, scale);
            ctx.beginPath();

            ctx.arc(0, 0, 6, 0, Math.PI * 2, true);
            ctx.stroke();
            ctx.fill();
            ctx.closePath();
            ctx.beginPath();
            ctx.arc(0, 0, 4, 0, Math.PI * 2, true);
            ctx.fillStyle = col;
            ctx.fill();
            ctx.restore();
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


        /*****************************************Webservicecall****************************************************/

        // VTO (Visu Transfer Objekt) laden
        function loadVTO() {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/loadVTO",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var r = response.d;
                    log("loadVTO ok");
                    res = r;
                },
                complete: function (xhr, status) {
                    log("loadVTO complete");
                },
                error: function (msg) {
                    log("loadVTO fail: " + msg);
                }
            });
            return res;
        }

        function loadDeployedVTO(prj) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/loadDeployedVTO",
                data: '{Projektnummer: ' + "'" + prj + "'" + '}',
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

        // Hintergrundfarbe einer Bitmap ermitteln
        function getBGColor(url) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getBackgroundColor",
                data: '{imgURL: ' + "'" + url + "'" + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    //VCO_Data = response.d;
                    //jsonVCOData = $.parseJSON(VCO_Data);
                    log(response.d);
                    res = response.d;
                    //$(".insideWrapper").css("background-color", response.d);
                },
                complete: function (xhr, status) {
                    log("getBGColor ok");
                },
                error: function (msg) {
                    log("getBGColor fail: " + msg);
                }
            });
            return res;
        }

        // Beispieldaten per Projektnummer laden (siehe Impl. Websevice)
        function getVisuDownload(prj) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getVisuSampleData",
                data: '{Projektnummer: ' + "'" + prj + "'" + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var r = response.d;
                    log("getVisuDownload ok");
                    res = r;
                },
                complete: function (xhr, status) {
                    log("getVisuDownload complete");
                },
                error: function (msg) {
                    log("getVisuDownload fail: " + msg);
                }
            });

            return res;
        }

        function getOnlineData(prj) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getVisuDataRaw",
                data: '{Projektnummer: ' + "'" + prj + "'" + '}',
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

        function getOnlineAktuellZaehler(prj) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getZaehlerAktuell",
                data: '{Projektnummer: ' + "'" + prj + "'" + '}',
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
                    //log("getOnlineTaehler complete");
                },
                error: function (msg) {
                    //log("getOnlineTaehler fail: " + msg);
                }
            });

            return res;
        }

        function getOnlinegesamtZaehler(prj) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getZaehlerGesamt",
                data: '{Projektnummer: ' + "'" + prj + "'" + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (response) {
                    gesamtZaehler = response.d;
                    //var r = response.d;
                    //log("getOnlineZaehler ok");

                    var d = new Date();
                    var h = d.getHours(); h = ("0" + h).slice(-2);
                    var m = d.getMinutes(); m = ("0" + m).slice(-2);
                    var s = d.getSeconds(); s = ("0" + s).slice(-2);
                    var t = h + ":" + m + ":" + s;

                    $("#xlabel").empty();
                    $("#xlabel").append("<bdi>Letztes Update: " + t + "</bdi>");

                    //return res;

                    //res = r;

                },
                complete: function (xhr, status) {
                    //log("getOnlineZaehler complete");
                },
                error: function (msg) {
                    //log("getOnlineZaehler fail: " + msg);
                }
            });
            if (res == 1) {

                MeldungAndCloseModal("Aktualisierung erfolgreich");
            }
            if (res == 0) {

                MeldungAndCloseModal("Aktualisierung fehlgeschlagen");
            }
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
                    VisuDownload = $.parseJSON(r);

                    $("#xlabel").empty();
                    $("#xlabel").append("<bdi>Letztes Update: " + t + "</bdi>");


                },
                complete: function (xhr, status) {
                    //log("getOnlineData complete");
                    Draw();
                },
                error: function (msg) {
                    //log("getOnlineData fail: " + msg);
                }
            });
        }


        function getZaheler(Steuerung, datum) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getZaehlerData",
                data: "{Steuerung: '" + Steuerung + "', datum:'" + datum + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false, // wichtig! sonst kein Rückgabewert
                success: function (response) {
                    var r = response.d;
                    //log("requestHeader ok");
                    res = r;
                },
                complete: function (xhr, status) {
                    //log("requestHeader complete");
                },
                error: function (msg) {
                    //log("requestHeader fail: " + msg);
                }
            });
            return res;
        }


        function getAccess(Steuerung, modul) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/checkAccessRight",
                data: "{projektNummer: '" + Steuerung + "', modul:'" + modul + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false, // wichtig! sonst kein Rückgabewert
                success: function (response) {
                    var r = response.d;
                    //log("requestHeader ok");
                    res = r;
                },
                complete: function (xhr, status) {
                    //log("requestHeader complete");
                },
                error: function (msg) {
                    //log("requestHeader fail: " + msg);
                }
            });
            return res;
        }



        function getData(Url) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getJSONData",
                data: "{Url: '" + Url + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false, // wichtig! sonst kein Rückgabewert
                success: function (response) {
                    res = response.d;
                    //log("requestJSONData ok");
                    //res = r;
                },
                complete: function (xhr, status) {
                    //log("requestJSONData complete");
                },
                error: function (msg) {
                    //log("requestJSONData fail: " + msg);
                }
            });
            return res;
        }

        function getDataAsync(Url, callback) {
            var res = "";
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getJSONData",
                data: "{Url: '" + Url + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true, 
                success: function (response) {
                    res = response.d;
                    callback(res);
                    res = "";
                },
                complete: function (xhr, status) {
                },
                error: function (msg) {
                }
            });
            //return res;
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
                    //log("sendData ok");
                    //res = r;
                },
                complete: function (xhr, status) {
                    //log("sendData complete");
                },
                error: function (msg) {
                    //log("sendData fail: " + msg);
                }
            });
            return res;
        }

        function sendDataWTAsync(Url, callback) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/SendDataToRtos",
                data: "{Url: '" + Url + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true, // 
                success: function (response) {
                    res = response.d;
                    callback(res);
                },
                complete: function (xhr, status) {
                    //log("sendData complete");
                },
                error: function (msg) {
                    //log("sendData fail: " + msg);
                }
            });
            return res;
        }


        function getImage(Url) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getImageIPCam",
                data: "{Url: '" + Url + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false, // wichtig! sonst kein Rückgabewert
                success: function (response) {
                    res = 'data:image/png;base64,' + response.d;
                    //log("requestImage ok");
                    //res = r;
                },
                complete: function (xhr, status) {
                    log("requestImage complete");
                },
                error: function (msg) {
                    //log("requestImage fail: " + msg);
                }
            });
            return res;
        }



        function getProjektName(prj) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getPrjName",
                data: '{ProjektNummer: ' + "'" + prj + "'" + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    res = response.d;
                    /*log("getname ok");*/

                },
                complete: function (xhr, status) {
                    /*log("getname complete");*/
                },
                error: function (msg) {
                    /*log("getname fail: " + msg);*/
                }
            });
            return res;
        }

        function getUsername() {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getUserName",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false, // wichtig! sonst kein Rückgabewert
                success: function (response) {
                    res = response.d;
                    log("getUserName ok");
                    //res = r;
                },
                complete: function (xhr, status) {
                    log("getUserName complete");
                },
                error: function (msg) {
                    log("getUserName fail: " + msg);
                }
            });
            return res;
        }

        function getIPEFromProjectnumber(ProjektNummer) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getIPEFromProjektnummer",
                data: '{ProjektNummer: ' + "'" + ProjektNummer + "'" + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var r = response.d;
                    //console.log("get IPE ok");
                    res = r + ':8080';
                },
                complete: function (xhr, status) {
                    //console.log("getIPE complete");
                },
                error: function (msg) {
                    //console.log("getIPE fail: " + msg);
                }
            });
            return res;
        }

        function getVisuSettingPermission(prj) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getPermissionForVisuSetting",
                data: '{Projektnummer: ' + "'" + prj + "'" + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var r = response.d;
                    log("getPermission ok");
                    res = r;
                },
                complete: function (xhr, status) {
                    log("getPermission complete");
                },
                error: function (msg) {
                    log("getPermission fail: " + msg);
                }
            });
            return res;
        }


        /*************************Polyfill************************************/

        'use strict';

        /**
         * String.prototype.at()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support    No      No      No                  No    No      No
         * -------------------------------------------------------------------------------
         */
        if (!String.prototype.at) {
            Object.defineProperty(String.prototype, "at",
                {
                    value: function (n) {
                        // ToInteger() abstract op
                        n = Math.trunc(n) || 0;
                        // Allow negative indexing from the end
                        if (n < 0) n += this.length;
                        // OOB access is guaranteed to return undefined
                        if (n < 0 || n >= this.length) return undefined;
                        // Otherwise, this is just normal property access
                        return this[n];
                    },
                    writable: true,
                    enumerable: false,
                    configurable: true
                });
        }

        /**
         * String.fromCharCode()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.fromCodePoint()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	41  	29      (No)	            28	    10      ?
         * -------------------------------------------------------------------------------
         */
        if (!String.fromCodePoint) {
            (function () {
                var defineProperty = (function () {
                    try {
                        var object = {};
                        var $defineProperty = Object.defineProperty;
                        var result = $defineProperty(object, object, object) && $defineProperty;
                    } catch (error) { }
                    return result;
                })();
                var stringFromCharCode = String.fromCharCode;
                var floor = Math.floor;
                var fromCodePoint = function () {
                    var MAX_SIZE = 0x4000;
                    var codeUnits = [];
                    var highSurrogate;
                    var lowSurrogate;
                    var index = -1;
                    var length = arguments.length;
                    if (!length) {
                        return '';
                    }
                    var result = '';
                    while (++index < length) {
                        var codePoint = Number(arguments[index]);
                        if (
                            !isFinite(codePoint) ||
                            codePoint < 0 ||
                            codePoint > 0x10ffff ||
                            floor(codePoint) != codePoint
                        ) {
                            throw RangeError('Invalid code point: ' + codePoint);
                        }
                        if (codePoint <= 0xffff) {
                            // BMP code point
                            codeUnits.push(codePoint);
                        } else {
                            codePoint -= 0x10000;
                            highSurrogate = (codePoint >> 10) + 0xd800;
                            lowSurrogate = (codePoint % 0x400) + 0xdc00;
                            codeUnits.push(highSurrogate, lowSurrogate);
                        }
                        if (index + 1 == length || codeUnits.length > MAX_SIZE) {
                            result += stringFromCharCode.apply(null, codeUnits);
                            codeUnits.length = 0;
                        }
                    }
                    return result;
                };
                if (defineProperty) {
                    defineProperty(String, 'fromCodePoint', {
                        value: fromCodePoint,
                        configurable: true,
                        writable: true,
                    });
                } else {
                    String.fromCodePoint = fromCodePoint;
                }
            })();
        }

        /**
         * String.anchor()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	1.0     (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.charAt()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.charCodeAt()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	1.0     (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.codePointAt()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	41  	29      11	                28	    10      ?
         * -------------------------------------------------------------------------------
         */
        if (!String.prototype.codePointAt) {
            (function () {
                var codePointAt = function (position) {
                    if (this == null) {
                        throw TypeError();
                    }
                    var string = String(this);
                    var size = string.length;
                    var index = position ? Number(position) : 0;
                    if (index != index) {
                        index = 0;
                    }
                    if (index < 0 || index >= size) {
                        return undefined;
                    }
                    var first = string.charCodeAt(index);
                    var second;
                    if (first >= 0xd800 && first <= 0xdbff && size > index + 1) {
                        second = string.charCodeAt(index + 1);
                        if (second >= 0xdc00 && second <= 0xdfff) {
                            return (first - 0xd800) * 0x400 + second - 0xdc00 + 0x10000;
                        }
                    }
                    return first;
                };
                if (Object.defineProperty) {
                    Object.defineProperty(String.prototype, 'codePointAt', {
                        value: codePointAt,
                        configurable: true,
                        writable: true,
                    });
                } else {
                    String.prototype.codePointAt = codePointAt;
                }
            })();
        }

        /**
         * String.concat()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.endsWith()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	41  	17      (No)	            (No)	9       (Yes)
         * -------------------------------------------------------------------------------
         */
        if (!String.prototype.endsWith) {
            Object.defineProperty(String.prototype, 'endsWith', {
                configurable: true,
                writable: true,
                value: function (searchString, position) {
                    var subjectString = this.toString();
                    if (
                        typeof position !== 'number' ||
                        !isFinite(position) ||
                        Math.floor(position) !== position ||
                        position > subjectString.length
                    ) {
                        position = subjectString.length;
                    }
                    position -= searchString.length;
                    var lastIndex = subjectString.lastIndexOf(searchString, position);
                    return lastIndex !== -1 && lastIndex === position;
                },
            });
        }

        /**
         * String.includes()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	41  	40      (No)	            (No)	9       (Yes)
         * -------------------------------------------------------------------------------
         */
        if (!String.prototype.includes) {
            Object.defineProperty(String.prototype, 'includes', {
                configurable: true,
                writable: true,
                value: function (search, start) {
                    if (typeof start !== 'number') {
                        start = 0;
                    }
                    if (start + search.length > this.length) {
                        return false;
                    } else {
                        return this.indexOf(search, start) !== -1;
                    }
                },
            });
        }

        /**
         * String.indexOf()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.lastIndexOf()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.link()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	1.0    (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.localeCompare()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	1.0    (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.match()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.normalize()
         * version 0.0.1
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	34   	31      (No)	            (Yes)	10      (Yes)
         * -------------------------------------------------------------------------------
         */
        if (!String.prototype.normalize) {
            // need polyfill
        }

        /**
         * String.padEnd()
         * version 1.0.1
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	57   	48      (No)	            44   	10      15
         * -------------------------------------------------------------------------------
         */
        if (!String.prototype.padEnd) {
            Object.defineProperty(String.prototype, 'padEnd', {
                configurable: true,
                writable: true,
                value: function (targetLength, padString) {
                    targetLength = targetLength >> 0; //floor if number or convert non-number to 0;
                    padString = String(typeof padString !== 'undefined' ? padString : ' ');
                    if (this.length > targetLength) {
                        return String(this);
                    } else {
                        targetLength = targetLength - this.length;
                        if (targetLength > padString.length) {
                            padString += padString.repeat(targetLength / padString.length); //append to original to ensure we are longer than needed
                        }
                        return String(this) + padString.slice(0, targetLength);
                    }
                },
            });
        }

        /**
         * String.padStart()
         * version 1.0.1
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	57   	51      (No)	            44   	10      15
         * -------------------------------------------------------------------------------
         */
        if (!String.prototype.padStart) {
            Object.defineProperty(String.prototype, 'padStart', {
                configurable: true,
                writable: true,
                value: function (targetLength, padString) {
                    targetLength = targetLength >> 0; //floor if number or convert non-number to 0;
                    padString = String(typeof padString !== 'undefined' ? padString : ' ');
                    if (this.length > targetLength) {
                        return String(this);
                    } else {
                        targetLength = targetLength - this.length;
                        if (targetLength > padString.length) {
                            padString += padString.repeat(targetLength / padString.length); //append to original to ensure we are longer than needed
                        }
                        return padString.slice(0, targetLength) + String(this);
                    }
                },
            });
        }

        /**
         * String.repeat()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	41   	24      (No)	            (Yes)   9       (Yes)
         * -------------------------------------------------------------------------------
         */
        if (!String.prototype.repeat) {
            Object.defineProperty(String.prototype, 'repeat', {
                configurable: true,
                writable: true,
                value: function (count) {
                    if (this == null) {
                        throw new TypeError("can't convert " + this + ' to object');
                    }
                    var str = '' + this;
                    count = +count;
                    if (count != count) {
                        count = 0;
                    }
                    if (count < 0) {
                        throw new RangeError('repeat count must be non-negative');
                    }
                    if (count == Infinity) {
                        throw new RangeError('repeat count must be less than infinity');
                    }
                    count = Math.floor(count);
                    if (str.length == 0 || count == 0) {
                        return '';
                    }
                    if (str.length * count >= 1 << 28) {
                        throw new RangeError(
                            'repeat count must not overflow maximum string size'
                        );
                    }
                    var rpt = '';
                    for (; ;) {
                        if ((count & 1) == 1) {
                            rpt += str;
                        }
                        count >>>= 1;
                        if (count == 0) {
                            break;
                        }
                        str += str;
                    }
                    return rpt;
                },
            });
        }

        /**
         * String.search()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.slice()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.split()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.startsWith()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	41   	17      (No)	            28   	9       (Yes)
         * -------------------------------------------------------------------------------
         */
        if (!String.prototype.startsWith) {
            Object.defineProperty(String.prototype, 'startsWith', {
                configurable: true,
                writable: true,
                value: function (searchString, position) {
                    position = position || 0;
                    return this.substr(position, searchString.length) === searchString;
                },
            });
        }

        /**
         * String.substr()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.substring()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.toLocaleLowerCase()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.toLocaleUpperCase()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.toLowerCase()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.toString()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.toUpperCase()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)	            (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.trim()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	3.5     9    	            10.5	5       ?
         * -------------------------------------------------------------------------------
         */
        if (!String.prototype.trim) {
            Object.defineProperty(String.prototype, 'trim', {
                configurable: true,
                writable: true,
                value: function () {
                    return this.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '');
                },
            });
        }

        /**
         * String.trimLeft()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	3.5     (No)    	        ?	    ?       ?
         * -------------------------------------------------------------------------------
         */

        /**
         * String.trimRight()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	3.5     (No)    	        ?	    ?       ?
         * -------------------------------------------------------------------------------
         */

        /**
         * String.valueOf()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	(Yes)  	(Yes)   (Yes)    	        (Yes)	(Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * String.raw
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	41   	34      (No)  	            (No)	10      ?
         * -------------------------------------------------------------------------------
         */


        if (window.NodeList && !NodeList.prototype.forEach) {
            NodeList.prototype.forEach = function (callback, thisArg) {
                thisArg = thisArg || window;
                for (var i = 0; i < this.length; i++) {
                    callback.call(thisArg, this[i], i, this);
                }
            };
        }


        'use strict';

        /**
         * Array.prototype.findLastIndex()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support    No      No      No                  No    No      No
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.findLastIndex) {
            Object.defineProperty(Array.prototype, "findLastIndex",
                {
                    value: function (predicate, thisArg) {
                        let idx = this.length - 1;
                        while (idx >= 0) {
                            const value = this[idx];
                            if (predicate.call(thisArg, value, idx, this)) {
                                return idx;
                            }
                            idx--;
                        }
                        return -1;
                    }
                    ,
                    writable: true,
                    enumerable: false,
                    configurable: true
                });
        }

        /**
         * Array.prototype.findLast()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support    No      No      No                  No    No      No
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.findLast) {
            Object.defineProperty(Array.prototype, "findLast",
                {
                    value: function (predicate, thisArg) {
                        let idx = this.length - 1;
                        while (idx >= 0) {
                            const value = this[idx];
                            if (predicate.call(thisArg, value, idx, this)) {
                                return value;
                            }
                            idx--;
                        }
                        return undefined;
                    }
                    ,
                    writable: true,
                    enumerable: false,
                    configurable: true
                });
        }

        /**
         * Array.prototype.at()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support    No      No      No                  No    No      No
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.at) {
            Object.defineProperty(Array.prototype, "at",
                {
                    value: function (n) {
                        // ToInteger() abstract op
                        n = Math.trunc(n) || 0;
                        // Allow negative indexing from the end
                        if (n < 0) n += this.length;
                        // OOB access is guaranteed to return undefined
                        if (n < 0 || n >= this.length) return undefined;
                        // Otherwise, this is just normal property access
                        return this[n];
                    },
                    writable: true,
                    enumerable: false,
                    configurable: true
                });
        }

        /**
         * Array.prototype.from()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	45  	32      (No)	            (Yes)	9       (Yes)
         * -------------------------------------------------------------------------------
         */
        if (!Array.from) {
            Array.from = (function () {
                var toStr = Object.prototype.toString;
                var isCallable = function (fn) {
                    return typeof fn === 'function' || toStr.call(fn) === '[object Function]';
                };
                var toInteger = function (value) {
                    var number = Number(value);
                    if (isNaN(number)) {
                        return 0;
                    }
                    if (number === 0 || !isFinite(number)) {
                        return number;
                    }
                    return (number > 0 ? 1 : -1) * Math.floor(Math.abs(number));
                };
                var maxSafeInteger = Math.pow(2, 53) - 1;
                var toLength = function (value) {
                    var len = toInteger(value);
                    return Math.min(Math.max(len, 0), maxSafeInteger);
                };

                // The length property of the from method is 1.
                return function from(arrayLike /*, mapFn, thisArg */) {
                    // 1. Let C be the this value.
                    var C = this;

                    // 2. Let items be ToObject(arrayLike).
                    var items = Object(arrayLike);

                    // 3. ReturnIfAbrupt(items).
                    if (arrayLike == null) {
                        throw new TypeError(
                            'Array.from requires an array-like object - not null or undefined'
                        );
                    }

                    // 4. If mapfn is undefined, then let mapping be false.
                    var mapFn = arguments.length > 1 ? arguments[1] : void undefined;
                    var T;
                    if (typeof mapFn !== 'undefined') {
                        // 5. else
                        // 5. a If IsCallable(mapfn) is false, throw a TypeError exception.
                        if (!isCallable(mapFn)) {
                            throw new TypeError(
                                'Array.from: when provided, the second argument must be a function'
                            );
                        }

                        // 5. b. If thisArg was supplied, let T be thisArg; else let T be undefined.
                        if (arguments.length > 2) {
                            T = arguments[2];
                        }
                    }

                    // 10. Let lenValue be Get(items, "length").
                    // 11. Let len be ToLength(lenValue).
                    var len = toLength(items.length);

                    // 13. If IsConstructor(C) is true, then
                    // 13. a. Let A be the result of calling the [[Construct]] internal method
                    // of C with an argument list containing the single item len.
                    // 14. a. Else, Let A be ArrayCreate(len).
                    var A = isCallable(C) ? Object(new C(len)) : new Array(len);

                    // 16. Let k be 0.
                    var k = 0;
                    // 17. Repeat, while k < len… (also steps a - h)
                    var kValue;
                    while (k < len) {
                        kValue = items[k];
                        if (mapFn) {
                            A[k] =
                                typeof T === 'undefined'
                                    ? mapFn(kValue, k)
                                    : mapFn.call(T, kValue, k);
                        } else {
                            A[k] = kValue;
                        }
                        k += 1;
                    }
                    // 18. Let putStatus be Put(A, "length", len, true).
                    A.length = len;
                    // 20. Return A.
                    return A;
                };
            })();
        }

        /**
         * Array.prototype.isArray()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  5    	  4       9    	              10.5	5       (Yes)
         * -------------------------------------------------------------------------------
         */
        if (!Array.isArray) {
            Array.isArray = function (arg) {
                return Object.prototype.toString.call(arg) === '[object Array]';
            };
        }

        /**
         * Array.prototype.of()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  45    	25      (No)    	          (No)	9       (Yes)
         * -------------------------------------------------------------------------------
         */
        if (!Array.of) {
            Array.of = function () {
                return Array.prototype.slice.call(arguments);
            };
        }

        /**
         * Array.prototype.copyWithin()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  45     	32      (No)     	          32  	9       12
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.copyWithin) {
            Object.defineProperty(Array.prototype, 'copyWithin', {
                configurable: true,
                writable: true,
                value: function (target, start /*, end*/) {
                    // Steps 1-2.
                    if (this == null) {
                        throw new TypeError('this is null or not defined');
                    }

                    var O = Object(this);

                    // Steps 3-5.
                    var len = O.length >>> 0;

                    // Steps 6-8.
                    var relativeTarget = target >> 0;

                    var to =
                        relativeTarget < 0
                            ? Math.max(len + relativeTarget, 0)
                            : Math.min(relativeTarget, len);

                    // Steps 9-11.
                    var relativeStart = start >> 0;

                    var from =
                        relativeStart < 0
                            ? Math.max(len + relativeStart, 0)
                            : Math.min(relativeStart, len);

                    // Steps 12-14.
                    var end = arguments[2];
                    var relativeEnd = end === undefined ? len : end >> 0;

                    var final =
                        relativeEnd < 0
                            ? Math.max(len + relativeEnd, 0)
                            : Math.min(relativeEnd, len);

                    // Step 15.
                    var count = Math.min(final - from, len - to);

                    // Steps 16-17.
                    var direction = 1;

                    if (from < to && to < from + count) {
                        direction = -1;
                        from += count - 1;
                        to += count - 1;
                    }

                    // Step 18.
                    while (count > 0) {
                        if (from in O) {
                            O[to] = O[from];
                        } else {
                            delete O[to];
                        }

                        from += direction;
                        to += direction;
                        count--;
                    }

                    // Step 19.
                    return O;
                },
            });
        }

        /**
         * Array.prototype.entries()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  38   	  28      (No)     	          25  	7.1     ?
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.entries) {
            Array.prototype.entries = function () {
                function Iterator() { }

                Iterator.prototype.next = function () {
                    if (index > selfThis.length - 1) {
                        done = true;
                    }
                    if (done) {
                        return { value: undefined, done: true };
                    }
                    return { value: [index, selfThis[index++]], done: false };
                };

                var selfThis = this;
                var index = 0;
                var done;

                return new Iterator();
            };
        }

        /**
         * Array.prototype.every()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  (Yes)   1.5     9    	             (Yes)  (Yes)   ?
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.every) {
            Object.defineProperty(Array.prototype, 'every', {
                configurable: true,
                writable: true,
                value: function (callbackfn, thisArg) {
                    var T, k;

                    if (this == null) {
                        throw new TypeError('this is null or not defined');
                    }

                    // 1. Let O be the result of calling ToObject passing the this
                    //    value as the argument.
                    var O = Object(this);

                    // 2. Let lenValue be the result of calling the Get internal method
                    //    of O with the argument "length".
                    // 3. Let len be ToUint32(lenValue).
                    var len = O.length >>> 0;

                    // 4. If IsCallable(callbackfn) is false, throw a TypeError exception.
                    if (typeof callbackfn !== 'function') {
                        throw new TypeError();
                    }

                    // 5. If thisArg was supplied, let T be thisArg; else let T be undefined.
                    if (arguments.length > 1) {
                        T = thisArg;
                    }

                    // 6. Let k be 0.
                    k = 0;

                    // 7. Repeat, while k < len
                    while (k < len) {
                        var kValue;

                        // a. Let Pk be ToString(k).
                        //   This is implicit for LHS operands of the in operator
                        // b. Let kPresent be the result of calling the HasProperty internal
                        //    method of O with argument Pk.
                        //   This step can be combined with c
                        // c. If kPresent is true, then
                        if (k in O) {
                            // i. Let kValue be the result of calling the Get internal method
                            //    of O with argument Pk.
                            kValue = O[k];

                            // ii. Let testResult be the result of calling the Call internal method
                            //     of callbackfn with T as the this value and argument list
                            //     containing kValue, k, and O.
                            var testResult = callbackfn.call(T, kValue, k, O);

                            // iii. If ToBoolean(testResult) is false, return false.
                            if (!testResult) {
                                return false;
                            }
                        }
                        k++;
                    }
                    return true;
                },
            });
        }

        /**
         * Array.prototype.fill()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  45      31      (No)    	          (No)  7.1     (Yes)
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.fill) {
            Object.defineProperty(Array.prototype, 'fill', {
                configurable: true,
                writable: true,
                value: function (value) {
                    // Steps 1-2.
                    if (this == null) {
                        throw new TypeError('this is null or not defined');
                    }

                    var O = Object(this);

                    // Steps 3-5.
                    var len = O.length >>> 0;

                    // Steps 6-7.
                    var start = arguments[1];
                    var relativeStart = start >> 0;

                    // Step 8.
                    var k =
                        relativeStart < 0
                            ? Math.max(len + relativeStart, 0)
                            : Math.min(relativeStart, len);

                    // Steps 9-10.
                    var end = arguments[2];
                    var relativeEnd = end === undefined ? len : end >> 0;

                    // Step 11.
                    var final =
                        relativeEnd < 0
                            ? Math.max(len + relativeEnd, 0)
                            : Math.min(relativeEnd, len);

                    // Step 12.
                    while (k < final) {
                        O[k] = value;
                        k++;
                    }

                    // Step 13.
                    return O;
                },
            });
        }

        /**
         * Array.prototype.filter()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support  	(Yes)   1.5     9   	             (Yes)  (Yes)   ?
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.filter) {
            Object.defineProperty(Array.prototype, 'filter', {
                configurable: true,
                writable: true,
                value: function (fun /*, thisArg*/) {
                    if (this === void 0 || this === null) {
                        throw new TypeError();
                    }

                    var t = Object(this);
                    var len = t.length >>> 0;
                    if (typeof fun !== 'function') {
                        throw new TypeError();
                    }

                    var res = [];
                    var thisArg = arguments.length >= 2 ? arguments[1] : void 0;
                    for (var i = 0; i < len; i++) {
                        if (i in t) {
                            var val = t[i];

                            // NOTE: Technically this should Object.defineProperty at
                            //       the next index, as push can be affected by
                            //       properties on Object.prototype and Array.prototype.
                            //       But that method's new, and collisions should be
                            //       rare, so use the more-compatible alternative.
                            if (fun.call(thisArg, val, i, t)) {
                                res.push(val);
                            }
                        }
                    }

                    return res;
                },
            });
        }

        /**
         * Array.prototype.find()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  45      25      (No)  	            32    7.1     12
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.find) {
            Object.defineProperty(Array.prototype, 'find', {
                configurable: true,
                writable: true,
                value: function (predicate) {
                    // 1. Let O be ? ToObject(this value).
                    if (this == null) {
                        throw new TypeError('"this" is null or not defined');
                    }

                    var o = Object(this);

                    // 2. Let len be ? ToLength(? Get(O, "length")).
                    var len = o.length >>> 0;

                    // 3. If IsCallable(predicate) is false, throw a TypeError exception.
                    if (typeof predicate !== 'function') {
                        throw new TypeError('predicate must be a function');
                    }

                    // 4. If thisArg was supplied, let T be thisArg; else let T be undefined.
                    var thisArg = arguments[1];

                    // 5. Let k be 0.
                    var k = 0;

                    // 6. Repeat, while k < len
                    while (k < len) {
                        // a. Let Pk be ! ToString(k).
                        // b. Let kValue be ? Get(O, Pk).
                        // c. Let testResult be ToBoolean(? Call(predicate, T, « kValue, k, O »)).
                        // d. If testResult is true, return kValue.
                        var kValue = o[k];
                        if (predicate.call(thisArg, kValue, k, o)) {
                            return kValue;
                        }
                        // e. Increase k by 1.
                        k++;
                    }

                    // 7. Return undefined.
                    return undefined;
                },
            });
        }

        /**
         * Array.prototype.findIndex()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  45      25      (No)  	            (Yes) 7.1     (Yes)
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.findIndex) {
            Object.defineProperty(Array.prototype, 'findIndex', {
                configurable: true,
                writable: true,
                value: function (predicate) {
                    // 1. Let O be ? ToObject(this value).
                    if (this == null) {
                        throw new TypeError('"this" is null or not defined');
                    }

                    var o = Object(this);

                    // 2. Let len be ? ToLength(? Get(O, "length")).
                    var len = o.length >>> 0;

                    // 3. If IsCallable(predicate) is false, throw a TypeError exception.
                    if (typeof predicate !== 'function') {
                        throw new TypeError('predicate must be a function');
                    }

                    // 4. If thisArg was supplied, let T be thisArg; else let T be undefined.
                    var thisArg = arguments[1];

                    // 5. Let k be 0.
                    var k = 0;

                    // 6. Repeat, while k < len
                    while (k < len) {
                        // a. Let Pk be ! ToString(k).
                        // b. Let kValue be ? Get(O, Pk).
                        // c. Let testResult be ToBoolean(? Call(predicate, T, « kValue, k, O »)).
                        // d. If testResult is true, return k.
                        var kValue = o[k];
                        if (predicate.call(thisArg, kValue, k, o)) {
                            return k;
                        }
                        // e. Increase k by 1.
                        k++;
                    }

                    // 7. Return -1.
                    return -1;
                },
            });
        }

        /**
         * Array.prototype.flat()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  69      62      (No)    	          56    12      (No)
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.flat) {
            Object.defineProperty(Array.prototype, 'flat', {
                configurable: true,
                writable: true,
                value: function () {
                    var depth =
                        typeof arguments[0] === 'undefined' ? 1 : Number(arguments[0]) || 0;
                    var result = [];
                    var forEach = result.forEach;

                    var flatDeep = function (arr, depth) {
                        forEach.call(arr, function (val) {
                            if (depth > 0 && Array.isArray(val)) {
                                flatDeep(val, depth - 1);
                            } else {
                                result.push(val);
                            }
                        });
                    };

                    flatDeep(this, depth);
                    return result;
                },
            });
        }

        /**
         * Array.prototype.flatMap()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  69      62      (No)    	          56    12      (No)
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.flatMap) {
            Object.defineProperty(Array.prototype, 'flatMap', {
                configurable: true,
                writable: true,
                value: function () {
                    return Array.prototype.map.apply(this, arguments).flat(1);
                },
            });
        }

        /**
         * Array.prototype.forEach()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  (Yes)   1.5     9    	              (Yes) (Yes)   ?
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.forEach) {
            Object.defineProperty(Array.prototype, 'forEach', {
                configurable: true,
                writable: true,
                value: function (callback /*, thisArg*/) {
                    var T, k;

                    if (this == null) {
                        throw new TypeError('this is null or not defined');
                    }

                    // 1. Let O be the result of calling toObject() passing the
                    // |this| value as the argument.
                    var O = Object(this);

                    // 2. Let lenValue be the result of calling the Get() internal
                    // method of O with the argument "length".
                    // 3. Let len be toUint32(lenValue).
                    var len = O.length >>> 0;

                    // 4. If isCallable(callback) is false, throw a TypeError exception.
                    // See: http://es5.github.com/#x9.11
                    if (typeof callback !== 'function') {
                        throw new TypeError(callback + ' is not a function');
                    }

                    // 5. If thisArg was supplied, let T be thisArg; else let
                    // T be undefined.
                    if (arguments.length > 1) {
                        T = arguments[1];
                    }

                    // 6. Let k be 0
                    k = 0;

                    // 7. Repeat, while k < len
                    while (k < len) {
                        var kValue;

                        // a. Let Pk be ToString(k).
                        //    This is implicit for LHS operands of the in operator
                        // b. Let kPresent be the result of calling the HasProperty
                        //    internal method of O with argument Pk.
                        //    This step can be combined with c
                        // c. If kPresent is true, then
                        if (k in O) {
                            // i. Let kValue be the result of calling the Get internal
                            // method of O with argument Pk.
                            kValue = O[k];

                            // ii. Call the Call internal method of callback with T as
                            // the this value and argument list containing kValue, k, and O.
                            callback.call(T, kValue, k, O);
                        }
                        // d. Increase k by 1.
                        k++;
                    }
                    // 8. return undefined
                },
            });
        }

        /**
         * Array.prototype.includes()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  47      43      (No)    	          34    9       14
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.includes) {
            Object.defineProperty(Array.prototype, 'includes', {
                configurable: true,
                writable: true,
                value: function (searchElement, fromIndex) {
                    // 1. Let O be ? ToObject(this value).
                    if (this == null) {
                        throw new TypeError('"this" is null or not defined');
                    }

                    var o = Object(this);

                    // 2. Let len be ? ToLength(? Get(O, "length")).
                    var len = o.length >>> 0;

                    // 3. If len is 0, return false.
                    if (len === 0) {
                        return false;
                    }

                    // 4. Let n be ? ToInteger(fromIndex).
                    //    (If fromIndex is undefined, this step produces the value 0.)
                    var n = fromIndex | 0;

                    // 5. If n ≥ 0, then
                    //  a. Let k be n.
                    // 6. Else n < 0,
                    //  a. Let k be len + n.
                    //  b. If k < 0, let k be 0.
                    var k = Math.max(n >= 0 ? n : len - Math.abs(n), 0);

                    function sameValueZero(x, y) {
                        return (
                            x === y ||
                            (typeof x === 'number' &&
                                typeof y === 'number' &&
                                isNaN(x) &&
                                isNaN(y))
                        );
                    }

                    // 7. Repeat, while k < len
                    while (k < len) {
                        // a. Let elementK be the result of ? Get(O, ! ToString(k)).
                        // b. If SameValueZero(searchElement, elementK) is true, return true.
                        // c. Increase k by 1.
                        if (sameValueZero(o[k], searchElement)) {
                            return true;
                        }
                        k++;
                    }

                    // 8. Return false
                    return false;
                },
            });
        }

        /**
         * Array.prototype.indexOf()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  (Yes)   1.5     9    	              (Yes) (Yes)   ?
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.indexOf) {
            Object.defineProperty(Array.prototype, 'indexOf', {
                configurable: true,
                writable: true,
                value: function (searchElement, fromIndex) {
                    var k;

                    // 1. Let o be the result of calling ToObject passing
                    //    the this value as the argument.
                    if (this == null) {
                        throw new TypeError('"this" is null or not defined');
                    }

                    var o = Object(this);

                    // 2. Let lenValue be the result of calling the Get
                    //    internal method of o with the argument "length".
                    // 3. Let len be ToUint32(lenValue).
                    var len = o.length >>> 0;

                    // 4. If len is 0, return -1.
                    if (len === 0) {
                        return -1;
                    }

                    // 5. If argument fromIndex was passed let n be
                    //    ToInteger(fromIndex); else let n be 0.
                    var n = fromIndex | 0;

                    // 6. If n >= len, return -1.
                    if (n >= len) {
                        return -1;
                    }

                    // 7. If n >= 0, then Let k be n.
                    // 8. Else, n<0, Let k be len - abs(n).
                    //    If k is less than 0, then let k be 0.
                    k = Math.max(n >= 0 ? n : len - Math.abs(n), 0);

                    // 9. Repeat, while k < len
                    while (k < len) {
                        // a. Let Pk be ToString(k).
                        //   This is implicit for LHS operands of the in operator
                        // b. Let kPresent be the result of calling the
                        //    HasProperty internal method of o with argument Pk.
                        //   This step can be combined with c
                        // c. If kPresent is true, then
                        //    i.  Let elementK be the result of calling the Get
                        //        internal method of o with the argument ToString(k).
                        //   ii.  Let same be the result of applying the
                        //        Strict Equality Comparison Algorithm to
                        //        searchElement and elementK.
                        //  iii.  If same is true, return k.
                        if (k in o && o[k] === searchElement) {
                            return k;
                        }
                        k++;
                    }
                    return -1;
                },
            });
        }

        /**
         * Array.prototype.join()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support   	1       1       5.5    	            (Yes) (Yes)   ?
         * -------------------------------------------------------------------------------
         */

        /**
         * Array.prototype.keys()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  38      28      (No)    	          25    7.1     (Yes)
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.keys) {
            Array.prototype.keys = function () {
                function Iterator() { }

                Iterator.prototype.next = function () {
                    if (index > selfThis.length - 1) {
                        done = true;
                    }
                    if (done) {
                        return { value: undefined, done: true };
                    }
                    return { value: index++, done: false };
                };

                var selfThis = this;
                var index = 0;
                var done;

                return new Iterator();
            };
        }

        /**
         * Array.prototype.lastIndexOf()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  (Yes)   (Yes)   9    	              (Yes) (Yes)   ?
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.lastIndexOf) {
            Object.defineProperty(Array.prototype, 'lastIndexOf', {
                configurable: true,
                writable: true,
                value: function (searchElement /*, fromIndex*/) {
                    if (this === void 0 || this === null) {
                        throw new TypeError();
                    }

                    var n,
                        k,
                        t = Object(this),
                        len = t.length >>> 0;
                    if (len === 0) {
                        return -1;
                    }

                    n = len - 1;
                    if (arguments.length > 1) {
                        n = Number(arguments[1]);
                        if (n != n) {
                            n = 0;
                        } else if (n != 0 && n != 1 / 0 && n != -(1 / 0)) {
                            n = (n > 0 || -1) * Math.floor(Math.abs(n));
                        }
                    }

                    for (k = n >= 0 ? Math.min(n, len - 1) : len - Math.abs(n); k >= 0; k--) {
                        if (k in t && t[k] === searchElement) {
                            return k;
                        }
                    }
                    return -1;
                },
            });
        }

        /**
         * Array.prototype.map()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support  	(Yes)   1.5     9    	              (Yes) (Yes)   ?
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.map) {
            Object.defineProperty(Array.prototype, 'map', {
                configurable: true,
                writable: true,
                value: function (callback /*, thisArg*/) {
                    var T, A, k;

                    if (this == null) {
                        throw new TypeError('this is null or not defined');
                    }

                    // 1. Let O be the result of calling ToObject passing the |this|
                    //    value as the argument.
                    var O = Object(this);

                    // 2. Let lenValue be the result of calling the Get internal
                    //    method of O with the argument "length".
                    // 3. Let len be ToUint32(lenValue).
                    var len = O.length >>> 0;

                    // 4. If IsCallable(callback) is false, throw a TypeError exception.
                    // See: http://es5.github.com/#x9.11
                    if (typeof callback !== 'function') {
                        throw new TypeError(callback + ' is not a function');
                    }

                    // 5. If thisArg was supplied, let T be thisArg; else let T be undefined.
                    if (arguments.length > 1) {
                        T = arguments[1];
                    }

                    // 6. Let A be a new array created as if by the expression new Array(len)
                    //    where Array is the standard built-in constructor with that name and
                    //    len is the value of len.
                    A = new Array(len);

                    // 7. Let k be 0
                    k = 0;

                    // 8. Repeat, while k < len
                    while (k < len) {
                        var kValue, mappedValue;

                        // a. Let Pk be ToString(k).
                        //   This is implicit for LHS operands of the in operator
                        // b. Let kPresent be the result of calling the HasProperty internal
                        //    method of O with argument Pk.
                        //   This step can be combined with c
                        // c. If kPresent is true, then
                        if (k in O) {
                            // i. Let kValue be the result of calling the Get internal
                            //    method of O with argument Pk.
                            kValue = O[k];

                            // ii. Let mappedValue be the result of calling the Call internal
                            //     method of callback with T as the this value and argument
                            //     list containing kValue, k, and O.
                            mappedValue = callback.call(T, kValue, k, O);

                            // iii. Call the DefineOwnProperty internal method of A with arguments
                            // Pk, Property Descriptor
                            // { Value: mappedValue,
                            //   Writable: true,
                            //   Enumerable: true,
                            //   Configurable: true },
                            // and false.

                            // In browsers that support Object.defineProperty, use the following:
                            // Object.defineProperty(A, k, {
                            //   value: mappedValue,
                            //   writable: true,
                            //   enumerable: true,
                            //   configurable: true
                            // });

                            // For best browser support, use the following:
                            A[k] = mappedValue;
                        }
                        // d. Increase k by 1.
                        k++;
                    }

                    // 9. return A
                    return A;
                },
            });
        }

        /**
         * Array.prototype.pop()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  1       1       5.5 	              (Yes) (Yes)   ?
         * -------------------------------------------------------------------------------
         */

        /**
         * Array.prototype.push()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  1       1       5.5 	              (Yes) (Yes)   ?
         * -------------------------------------------------------------------------------
         */

        /**
         * Array.prototype.reduce()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support  	(Yes)   3       9	                  10.5  4       ?
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.reduce) {
            Object.defineProperty(Array.prototype, 'reduce', {
                configurable: true,
                writable: true,
                value: function (callback /*, initialValue*/) {
                    if (this === null) {
                        throw new TypeError(
                            'Array.prototype.reduce ' + 'called on null or undefined'
                        );
                    }
                    if (typeof callback !== 'function') {
                        throw new TypeError(callback + ' is not a function');
                    }

                    // 1. Let O be ? ToObject(this value).
                    var o = Object(this);

                    // 2. Let len be ? ToLength(? Get(O, "length")).
                    var len = o.length >>> 0;

                    // Steps 3, 4, 5, 6, 7
                    var k = 0;
                    var value;

                    if (arguments.length >= 2) {
                        value = arguments[1];
                    } else {
                        while (k < len && !(k in o)) {
                            k++;
                        }

                        // 3. If len is 0 and initialValue is not present,
                        //    throw a TypeError exception.
                        if (k >= len) {
                            throw new TypeError(
                                'Reduce of empty array ' + 'with no initial value'
                            );
                        }
                        value = o[k++];
                    }

                    // 8. Repeat, while k < len
                    while (k < len) {
                        // a. Let Pk be ! ToString(k).
                        // b. Let kPresent be ? HasProperty(O, Pk).
                        // c. If kPresent is true, then
                        //    i.  Let kValue be ? Get(O, Pk).
                        //    ii. Let accumulator be ? Call(
                        //          callbackfn, undefined,
                        //          « accumulator, kValue, k, O »).
                        if (k in o) {
                            value = callback(value, o[k], k, o);
                        }

                        // d. Increase k by 1.
                        k++;
                    }

                    // 9. Return accumulator.
                    return value;
                },
            });
        }

        /**
         * Array.prototype.reduceRight()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  (Yes)   3       9	                  10.5  4       ?
         * -------------------------------------------------------------------------------
         */
        if ('function' !== typeof Array.prototype.reduceRight) {
            Object.defineProperty(Array.prototype, 'reduceRight', {
                configurable: true,
                writable: true,
                value: function (callback /*, initialValue*/) {
                    if (null === this || 'undefined' === typeof this) {
                        throw new TypeError(
                            'Array.prototype.reduce called on null or undefined'
                        );
                    }
                    if ('function' !== typeof callback) {
                        throw new TypeError(callback + ' is not a function');
                    }
                    var t = Object(this),
                        len = t.length >>> 0,
                        k = len - 1,
                        value;
                    if (arguments.length >= 2) {
                        value = arguments[1];
                    } else {
                        while (k >= 0 && !(k in t)) {
                            k--;
                        }
                        if (k < 0) {
                            throw new TypeError('Reduce of empty array with no initial value');
                        }
                        value = t[k--];
                    }
                    for (; k >= 0; k--) {
                        if (k in t) {
                            value = callback(value, t[k], k, t);
                        }
                    }
                    return value;
                },
            });
        }

        /**
         * Array.prototype.reverse()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  1       1       5.5	                (Yes)   (Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * Array.prototype.shift()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support  	1       1       5.5	                (Yes) (Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * Array.prototype.slice()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  1       1       5.5	                (Yes) (Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * Array.prototype.some()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  1       1.5     9	                 (Yes)  (Yes)   ?
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.some) {
            Object.defineProperty(Array.prototype, 'some', {
                configurable: true,
                writable: true,
                value: function (fun /*, thisArg*/) {
                    if (this == null) {
                        throw new TypeError('Array.prototype.some called on null or undefined');
                    }

                    if (typeof fun !== 'function') {
                        throw new TypeError();
                    }

                    var t = Object(this);
                    var len = t.length >>> 0;

                    var thisArg = arguments.length >= 2 ? arguments[1] : void 0;
                    for (var i = 0; i < len; i++) {
                        if (i in t && fun.call(thisArg, t[i], i, t)) {
                            return true;
                        }
                    }

                    return false;
                },
            });
        }

        /**
         * Array.prototype.sort()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support  	1       1       5.5	                (Yes) (Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * Array.prototype.splice()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support  	1       1       5.5	                (Yes) (Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * Array.prototype.toLocaleString()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  (Yes)   (Yes)   (Yes) 	            (Yes) (Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.toLocaleString) {
            Object.defineProperty(Array.prototype, 'toLocaleString', {
                configurable: true,
                writable: true,
                value: function (locales, options) {
                    // 1. Let O be ? ToObject(this value).
                    if (this == null) {
                        throw new TypeError('"this" is null or not defined');
                    }

                    var a = Object(this);

                    // 2. Let len be ? ToLength(? Get(A, "length")).
                    var len = a.length >>> 0;

                    // 3. Let separator be the String value for the
                    //    list-separator String appropriate for the
                    //    host environment's current locale (this is
                    //    derived in an implementation-defined way).
                    // NOTE: In this case, we will use a comma
                    var separator = ',';

                    // 4. If len is zero, return the empty String.
                    if (len === 0) {
                        return '';
                    }

                    // 5. Let firstElement be ? Get(A, "0").
                    var firstElement = a[0];
                    // 6. If firstElement is undefined or null, then
                    //  a.Let R be the empty String.
                    // 7. Else,
                    //  a. Let R be ?
                    //     ToString(?
                    //       Invoke(
                    //        firstElement,
                    //        "toLocaleString",
                    //        « locales, options »
                    //       )
                    //     )
                    var r =
                        firstElement == null
                            ? ''
                            : firstElement.toLocaleString(locales, options);

                    // 8. Let k be 1.
                    var k = 1;

                    // 9. Repeat, while k < len
                    while (k < len) {
                        // a. Let S be a String value produced by
                        //   concatenating R and separator.
                        var s = r + separator;

                        // b. Let nextElement be ? Get(A, ToString(k)).
                        var nextElement = a[k];

                        // c. If nextElement is undefined or null, then
                        //   i. Let R be the empty String.
                        // d. Else,
                        //   i. Let R be ?
                        //     ToString(?
                        //       Invoke(
                        //        nextElement,
                        //        "toLocaleString",
                        //        « locales, options »
                        //       )
                        //     )
                        r =
                            nextElement == null
                                ? ''
                                : nextElement.toLocaleString(locales, options);

                        // e. Let R be a String value produced by
                        //   concatenating S and R.
                        r = s + r;

                        // f. Increase k by 1.
                        k++;
                    }

                    // 10. Return R.
                    return r;
                },
            });
        }

        /**
         * Array.prototype.toString()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support  	(Yes)   (Yes)   (Yes)               (Yes) (Yes)   (Yes)
         * -------------------------------------------------------------------------------
         */

        /**
         * Array.prototype.unshift()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support	  1       1       5.5                 (Yes) (Yes)   ?
         * -------------------------------------------------------------------------------
         */

        /**
         * Array.prototype.values()
         * version 0.0.0
         * Feature	        Chrome  Firefox Internet Explorer   Opera	Safari	Edge
         * Basic support  	(No)    (No)    (No)                (No)  9       (Yes)
         * -------------------------------------------------------------------------------
         */
        if (!Array.prototype.values) {
            Array.prototype.values = function () {
                function Iterator() { }

                Iterator.prototype.next = function () {
                    if (index > selfThis.length - 1) {
                        done = true;
                    }
                    if (done) {
                        return { value: undefined, done: true };
                    }
                    return { value: selfThis[index++], done: false };
                };

                var selfThis = this;
                var index = 0;
                var done;

                return new Iterator();
            };
        }


    </script>


    <form id="form1" runat="server">
        <div class=" container">
            <div class="row">
                <div id="vimage" class="col-md-8" style="height: 640px">
                    <div id="outsideWrapper" class="container">
                        <div id="imgArea" class="insideWrapper">
                            <canvas id="myCanvas" class="coveringCanvas" ondrop="drop(event)" ondragover="allowDrop(event)" ondragleave="leave(event)"></canvas>
                            <canvas id="tipCanvas" width="150" height="25"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- The Modal Stoerung -->
            <div id="stoerungModal" class="modalEK">
                <!-- Modal content -->
                <div id="modalContent" class="modal-content">
                    <div class="modal-header" id="modalHeader">
                        <span id="closeModal" class="close">&times;</span>
                    </div>
                    <div class="modal-body" id="modalBody">
                   </div>
                  </div>
            </div>
        </div>
            <%-- End The Modal Stoerung--%>

          <!-- The Modal ipkamera -->
        <div id="modalIPKamera" class="videoModal">
                <div class="modal-header" id="modalIPKameraHeader">
                </div>
            <img class="ImgBox" id ="ImgKamera" src="/" />
        <div class="modal-footer" id="ipKameraModalFooter">
            <input id="ipKameraModalClose" type="button" class="modalFooterButton" onclick="closemodalIPKamera()" value="Schließen" />
        </div>
        </div>

        <!-- The Modal Zählerabholung -->
        <div id="ModalZaehlerAbholung" class="modalEK">
            <div class="modal-content-ZaehlerAbholung">
			    <div class="loader"></div>
                <div id="modalbodyZahelerAbholung" ></div>
            </div>
        </div>
        <!-- The Modal Zählerabholung -->

        <%--modal zähler--%>
        <div id="modalZaehler" class="modalEK">
            <!-- Modal content -->
            <div id="modalContenZaehler" class="modal-content">
                <div class="modal-header" id="modalHeaderZaehler">
                    
                </div>
                <div class="modal-body" id="ModalBodyZaehler">
                        
                    <div class="input-group date col-md-6" id="datetimepicker1">
                        <input id="inputDate" type="text" class="form-control" value="Wählen Sie Datum für Zählerarchiv aus" />
                        <span class="input-group-addon"><i class="glyphicon glyphicon-th"></i></span>
                    </div>
                    <div id="aktuelleZaehler"></div>
                </div>
                <div class="modal-footer" id="modalFooter">
                    <input id="btnCopyClip" type="button" class="modalFooterButton" onclick="copyToClip()" value="In Zwischenlage kopieren" />
                </div>
            </div>
        </div>
       <%--end modal zähler--%>

	   <!-- Modal für Einstellwerte-->
		 <div id="fpBg" class="modalVisuBg" >
		  <!-- <div id="visLoader" class="loader"></div>-->
		  <!-- FP content -->
		  <div id="fpContent" class="modalVisuContent">
			<div id="fpHeader" class="modalVisuHeader">
			  <span class="close" onclick="closeFaceplate()">&times;</span>
			  <h4 id="h4FpHeader"></h4>
			</div>
			<div id="fpBody" class="modalVisuBody" >
			</div>
			<div id="fpFooter" class="modalVisuFooter">
			  <input type="button" id="btnFaceplateConfirm" onclick ="sendDataToRtosNEW(event)" value="Übernehmen"/> 
			  <input type="button" id="btnFaceplateCancel" onclick="closeFaceplate()" value="Abbrechen" /> 
			</div>
		  </div>
		</div>
		<!--end modal einstellwerte-->

        <!-- Modal für eingebetten HK Wochenkalender-->
		<div id="wochenKalenderImVisu" class="modalVisuBg">
			<!-- Modal content -->
			<div id="wochenKalenderImVisuContent">
				<div class="modalVisuHeader">
					<span class="close" onclick="closeModalWochenKalenderImVisu()">&times;</span>
					<h4 id="txtWochenKalenderImVisuHeader">Wochenkalender </h4>
				</div>
				<div class="modalVisuBody" id="wochenKalenderImVisuBody">
				<canvas id="settingFromVisuCanvas"></canvas>
				</div>
				<div class="modalVisuFooter">
					<input id="btnCloseWochenKalenderModal" type="button" class="form-control" onclick="closeModalWochenKalenderImVisu()" value="Schließen" />
				</div>
			</div>
			<!-- Button Group -->
<%--			<div id="buttonGroupVisu">
				<button id="btnUpVisu" class="btn" onclick="EthernetButtonHanlder(id)"></button>
				<button id="btnDownVisu" class="btn" onclick="EthernetButtonHanlder(id)"></button>
				<button id="btnLeftVisu" class="btn" onclick="EthernetButtonHanlder(id)"></button>
				<button id="btnRightVisu" class="btn" onclick="EthernetButtonHanlder(id)"></button>
				<button id="btnEnterVisu" class="btn" onclick="EthernetButtonHanlder(id)"></button>
			</div>--%>
            <button id="vbtnVirtualKeyboard" class="btnOSK" onclick="EthernetButtonHanlder(id)" hidden>Tastatur</button>
		</div>
		<!--end modal Modal für eingebetten HK Wochenkalender-->

        <div class="row">
            <div class="col-md-8" >
                <div id="output" class="Logging">
                </div>
            </div>
        </div>

        <div class="row" id="loggingWrapper">
            <input id="cbDebug" type ="checkbox" onchange="cbDebugChanged()" style="display: none;" value="debug" checked/><bdi style="display: none;">Log anzeigen</bdi>
            <%--<input id="Button1" type="button" value="Toggle" class="cmdButton" onclick="toggleBools()" />--%>
            <%--<input id="Button2" type="button" value="Reload" class="cmdButton" onclick="ReloadData()" />--%>
            <input id="cbcyclicReload" type ="checkbox" onchange="cbCyclicChanged()" value="cyclic"/><bdi>Autom. Nachladen</bdi>

            <div class="btn-group dropup">
                <button id="btnStartRecord" style="display: none;" class="btn btn-default " type="button" data-toggle="dropdown">
                    Start Aufnahme
                <span class="caret"></span>
                </button>
                <ul class="dropdown-menu">
                    <li id="15" onclick="startRecording(id)"><a href="#">15 Minuten</a></li>
                    <li id="30" onclick="startRecording(id)"><a href="#">30 Minuten</a></li>
                    <li id="45" onclick="startRecording(id)"><a href="#">45 Minuten</a></li>
                    <li id="60" onclick="startRecording(id)"><a href="#">60 Minuten</a></li>
                    <li id="unlimited" onclick="startRecording(id)"><a href="#">unbegrenzt</a></li>
                </ul>
            </div>
   

            <%--<input id="btnStartRecord" type="button" class="btn btn-default" onclick="startRecording()" style="display: none;" value="Start Aufnahme &#x25b6;" />--%>
            <input id="btnStopRecord" type="button" class="btn btn-default" onclick="stopRecording()" style="display: none;"  value="Stop Aufnahme  &#x25a0;" />

             <div  class="btn-group dropup">
                <button id="btnPlaybackSpeed" style="display: none;" class="btn btn-default dropdown-toggle" type="button" data-toggle="dropdown">
                    Abspielen
                <span class="caret"></span>
                </button>
                <ul class="dropdown-menu">
                    <li id="1x" onclick="showRecordResults(id)"><a href="#">1x &nbsp &#x23e9;&#xFE0E;</a></li>
                    <li id="2x" onclick="showRecordResults(id)"><a href="#">2x &nbsp &#x23e9;&#xFE0E;</a></li>
                    <li id="4x" onclick="showRecordResults(id)"><a href="#">4x &nbsp &#x23e9;&#xFE0E;</a></li>
                    <li id="8x" onclick="showRecordResults(id)"><a href="#">8x &nbsp &#x23e9;&#xFE0E;</a></li>
                    <li id="16x" onclick="showRecordResults(id)"><a href="#">16x &#x23e9;&#xFE0E;</a></li>
                </ul>
            </div>
            <input id="sliderDate" type="range" class="visuRecordSlider"  style="display: none;" onchange="sliderUpdated(this.value)"/>
            <input id="btnPlayPause" type="button" class="btn btn-default"  onclick="PlayPauseToggle()" style="display: none;" value="Pause" />
            <%--<input id="btnScreenshot" type="button" class="btn btn-default"  onclick="visuScreenshot()"  value="Screenshot" />--%>
        </div>
            <label id="xlabel" class="right" 
                onclick="UpdateClickHandler()"
                onmouseover="UpdateLabelMouseOverHandler()"
                onmouseout="UpdateLabelMouseOutHandler()">
            </label>
    </form>
</body>
</html>
