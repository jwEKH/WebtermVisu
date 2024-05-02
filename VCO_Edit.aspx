<%@ Page Title="VCO_Edit" Language="C#" MasterPageFile="~/Wide.Master" AutoEventWireup="true" CodeBehind="VCO_Edit.aspx.cs" Inherits="WebAppJanStyle1.VCO_Edit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

    <style>

        /* Dimensionierung Ummantelung aussen */
        #voutsideWrapper
        {
            width: 1400px;
            height: 630px;
            /*border: 1px solid blue;*/
            padding: 0px;
            border-radius: 25px;
            
        }

        /* Relativer Bezug Ummantelung innen */
        .vinsideWrapper
        {
            width: 100%;
            height: 100%;
            position: relative;
            background-color: rgba(0, 0, 0,0);
            border-radius: 25px;
            
        }

        /* Relativer Bezug Bitmap */
        .vcoveredImage
        {
            /*width: 100%;
            height: 100%;*/
            position: absolute;
            top: 0px;
            left: 0px;
            border-radius: 25px;
        }

        /* Absoluter Bezug für Zeichen-Canvas */
        .vcoveringCanvas
        {
            width: 100%;
            height: 100%;
            position: absolute;
            top: 0px;
            left: 0px;
            background-color: rgba(0, 0, 0, 0);
            border-radius: 25px;
            box-shadow: 10px 10px 5px #888888;
           
        }

        /* Absoluter Bezug für Tooltip-Canvas. Zunächst ausserhalb des sichtbaren Bereichs */
        #tipCanvas
        {
            background-color: white;
            border: 1px solid blue;
            position: absolute;
            left: -2000px;
            top: 100px;
        }

        /* Textformatierung Infos */
        .infoDiv
        {
            background-color: white;
            border: 1px solid blue;
            position: absolute;
            left: 700px;
            top: 500px;
            width: 300px;
            height: 300px;
            display: none;
            background-color: rgba(223, 223, 223, 0.9);
            border-radius: 15px;
            box-shadow: 10px 10px 5px #888888;
        }

        /* Formatierung Bitmapauswahl */
        .imgSelect
        {
            border-radius: 15px;
            background-color: beige;
            padding: 5px;
            margin: 5px;
        }

         /* Formatierung Buttonbereich */
        .Buttonbar
        {
            border-radius: 15px;
            background-color: lightsteelblue;
            padding: 17px;
            margin-top: 5px;
            width: 100%;
            height: 60px;
            /*box-shadow: 10px 10px 5px #888888;*/
        }

        /* Formatierung Buttons */
        .cmdButton
        {
            border-radius: 8px;
            background-color: lightgrey;
            padding-left: 10px;
            padding-top: 3px;
            margin-top: 0px;
            width: 140px;
            height: 30px;
        }

        /* Formatierung Titel */
        .Title
        {
            text-align: center;
            color: darkblue;
            text-decoration: underline;
        }

        /* Formatierung Cursor auf LineItems */
        li
        {
            cursor: cell;
            position: relative;
        }

        /* Formatierung Cursor auf anwählbaren Bereichen */
        .clickable
        {
            cursor: cell;
        }

        /* Formatierung Hinweise */
        .Hinweis
        {
            font: 12px Arial;
            text-align: center;
            color: darkblue;
            font-style: oblique;
        }

        /* Formatierung Dragbereiche (hier Label) */
        .draglabel
        {
            font: 14px Arial;
            text-align: center;
            color: darkblue;
            border-radius: 4px;
            background-color: lightgray;
            padding: 2px;
            margin: 2px;
        }


        /* Formatierung Tabs (Labels)) */
        .tablabel
        {
            font: 14px Arial;
            text-align: center;
            color: darkblue;
            border-radius: 4px;
            background-color: lightgray;
            padding: 2px;
            margin: 2px;
        }

        /* Formatierung gewählte Tabs (hier Labels) */
        .tablabelSelected
        {
            font: 14px Arial;
            text-align: center;
            color: red;
            border-radius: 4px;
            background-color: lightgray;
            padding: 2px;
            margin: 2px;
        }


        /* Formatierung Listenbereiche */
        .ListFrame
        {
            height: 100%;
            border-radius: 15px;
            background-color: lightsteelblue;
            padding: 5px;
            margin: 0px;
        }


        /* --- Modales Menue: Edit Tooltip ---*/
        #EditToolTip
        {
            position: fixed;
            font-family: Arial, Helvetica, sans-serif;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            background: rgba(111,111,111,0.3);
            z-index: 99999;
            opacity: 0;
            transition: opacity 400ms ease-in;
            pointer-events: none;
        }

            #EditToolTip:target
            {
                opacity: 1;
                pointer-events: auto;
            }


            #EditToolTip > div
            {
                width: 250px;
                left: 800px;
                top: 200px;
                position: absolute;
                margin: 10% auto;
                padding: 5px 20px 13px 20px;
                border-radius: 10px;
                background: #fff;
                background: -moz-linear-gradient(#fff, #999);
                background: -webkit-linear-gradient(#fff, #999);
                background: -o-linear-gradient(#fff, #999);
                box-shadow: 10px 10px 5px #888888;
            }

        /* --- Modales Menue: Edit Symbol ---*/
        #EditSymbol
        {
            position: fixed;
            font-family: Arial, Helvetica, sans-serif;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            background: rgba(111,111,111,0.3);
            z-index: 99999;
            opacity: 0;
            transition: opacity 400ms ease-in;
            pointer-events: none;
        }

            #EditSymbol:target
            {
                opacity: 1;
                pointer-events: auto;
            }


            #EditSymbol > div
            {
                width: 250px;
                left: 800px;
                top: 200px;
                position: absolute;
                margin: 10% auto;
                padding: 5px 20px 13px 20px;
                border-radius: 10px;
                background: #fff;
                background: -moz-linear-gradient(#fff, #999);
                background: -webkit-linear-gradient(#fff, #999);
                background: -o-linear-gradient(#fff, #999);
                box-shadow: 10px 10px 5px #888888;
            }

        /* Abschalten Featureansicht in Symbolmenue */
        .SelectSymbolFeature
        {
            display: none;
        }
        #divSymbolFeatureOptions {
            display: none;
        }

        /* Formatierung Log Division */
        .Logging
        {
            width: 100%;
            height: 130px;
            overflow-x: hidden;
            overflow-y: scroll;
            padding: 10px;
            background-color: lightgrey;
            border: 1px solid blue;
        }


        /* --- Modales Menue: Datei laden ---*/
        #SelectFile
        {
            position: fixed;
            font-family: Arial, Helvetica, sans-serif;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            background: rgba(111,111,111,0.3);
            z-index: 99999;
            opacity: 0;
            transition: opacity 400ms ease-in;
            pointer-events: none;
        }

            #SelectFile:target
            {
                opacity: 1;
                pointer-events: auto;
            }


            #SelectFile > div
            {
                width: 350px;
                left: 800px;
                top: 200px;
                position: absolute;
                margin: 10% auto;
                padding: 5px 20px 13px 20px;
                border-radius: 10px;
                background: #fff;
                background: -moz-linear-gradient(#fff, #999);
                background: -webkit-linear-gradient(#fff, #999);
                background: -o-linear-gradient(#fff, #999);
                box-shadow: 10px 10px 5px #888888;
            }


        /* --- Modales Menue: Datei speichern ---*/
       #SaveFile
        {
            position: fixed;
            font-family: Arial, Helvetica, sans-serif;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            background: rgba(111,111,111,0.3);
            z-index: 99999;
            opacity: 0;
            transition: opacity 400ms ease-in;
            pointer-events: none;
        }

            #SaveFile:target
            {
                opacity: 1;
                pointer-events: auto;
            }


            #SaveFile > div
            {
                width: 350px;
                left: 800px;
                top: 200px;
                position: absolute;
                margin: 10% auto;
                padding: 5px 20px 13px 20px;
                border-radius: 10px;
                background: #fff;
                background: -moz-linear-gradient(#fff, #999);
                background: -webkit-linear-gradient(#fff, #999);
                background: -o-linear-gradient(#fff, #999);
                box-shadow: 10px 10px 5px #888888;
            }

    </style>


</asp:Content>



<asp:Content ID="Content3" ContentPlaceHolderID="CPH_Form" runat="server">
    <script src="Scripts/VisuScript.js"></script>

    <script type="text/javascript">

        // Globale Variablen
        var VCO_Data;               // Visu Creation Objekt (serialisiert)
        var jsonVCOData = "[]";     // dito als Objekt
        var bmpIndex = 0;           // aktuell angezeigte Bitmap
        var CurrentVCOItem;         // drag & drop Zwischenspeicher
        var CurrentX;               // drag & drop Zwischenspeicher
        var CurrentY;               // drag & drop Zwischenspeicher
        var canvas;                 // Aktueller Canvas
        var ctx;                    // Aktueller Canvas-Context(2d)
        var CurrentDroplistItem;    // Für Zugriffe aus modalem Fenster (Symbolauswahl)
        var MarkedToolTipItem;     // Tooltip - Wertübergabe aus modalem Menue

        // Farbschema-Variablen
        var colInUse = "red";
        var colNotInUse = "black";
        var colMarked = "lightgrey";
        var bgColUnmarked = "beige";

        // aktuell gewähltes Symbol und Feature bei boolschen Props
        var selectedSymbol = "";
        var selectedSymbolFeature = "";

        // Kein Drag & Drop für bereits eingefügte Werte.
        // Wird von "drag(ev)" gesetzt und von "allowDrop(ev)" geprüft
        var noDnD = false;

        // In Liste Markierter Eintrag 
        var MarkedItem = null;
        // Markierter Freitext-Eintrag
        var MarkedTextItem = null;

        var DropList = [];          // Liste der per drag & drop eingefügten Objekte
        var FreitextList = [];      // Liste der per drag & drop eingefügten Freitexte

        // bei Initialisierung per document.getElementById() ermittelte Label-Objekte des DOM  
        var _xPos;
        var _yPos;
        var _lblEinheit;
        var _lblNK;
        var _lblKanal;
        var _lblBez;
        var _lblKomm;
        var _lblID;
        var _lblclikAble;
        
        // Zustandsvariablen Shift- und Steuertasten
        var ShiftPressed = false;
        var ArrUpPressed = false;
        var ArrDnPressed = false;
        var ArrLfPressed = false;
        var ArrRgPressed = false;

        // Vorschlag für Datei speichern
        var CurrentFileName = "";

        // Log-Funktion
        function log(s) {
            $('#output').append(new Date().toLocaleTimeString() + " " + s + "<br />");
            var objDiv = document.getElementById("output");
            objDiv.scrollTop = objDiv.scrollHeight;
        }


        //function Heizkreis(ctx, x, y) {
        //    ctx.save();
        //    ctx.lineWidth = 1;
        //    ctx.translate(x, y);
        //    ctx.beginPath();
        //    ctx.arc(0, 0, 15, 0, 2 * Math.PI);
        //    ctx.stroke();
        //    ctx.restore();
        //}

        function fpButton(ctx, x, y) {
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
            ctx.beginPath()
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
            ctx.stroke();
            ctx.restore();
        }

        function Absenkung(ctx, x, y, scale, active) {
            ctx.save();
            ctx.moveTo(0 - 10 * scale, 0);
            ctx.font = '12pt Arial';
            ctx.fillStyle = 'blue';

            ctx.translate(x, y);

            if (active)
                ctx.fillText('Nacht', 0, 0);
            else
                ctx.fillText('Tag', 0, 0);

            ctx.restore();
        }
        // Zeichnen: Drehender Anker 1 BHKW
        function BHDreh(ctx, x, y, scale, rotation) {
            ctx.save();
            ctx.lineWidth = 1 * scale;
            ctx.translate(x, y);
            ctx.rotate(Math.PI / 180 * rotation);
            ctx.strokeStyle = "steelblue";
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



        // Zeichnen: Feuer
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


        // Hilfsfunktion für Ellipsen
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

        // Zeichnen: Lüfter
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

        // Zeichnen: Drehende Pumpe V1
        function pmpDreh1(ctx, x, y, scale, rot) {
            // 12x12
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
            ctx.arc(0, 0, 11, 0, Math.PI / 2, false);
            ctx.fill();
            ctx.moveTo(0, 0);
            ctx.lineTo(0, 11);
            //ctx.moveTo(0, 0);
            ctx.lineTo(11, 0);
            ctx.fill();
            ctx.restore();
        }

        // Zeichnen: Drehende Pumpe V2
        function pmpDreh2(ctx, x, y, scale, rot) {
            // 12x12
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
            ctx.lineWidth = 2;
            ctx.moveTo(0, -11);
            ctx.lineTo(0, 11);
            //ctx.moveTo(0, 0);
            ctx.stroke();
            ctx.restore();
        }

        //Zeichnen: Drehende Pumpe V3
        function pmpDreh3(ctx, x, y, scale, rot) {

            ctx.save();
            ctx.strokeStyle = "black";
            ctx.fillStyle = "black";
            ctx.lineWidth = 1;
            ctx.translate = (x, y);
            ctx.rotate(math.PI / 180 * rot)
            ctx.scale(scale, scale);
            ctx.beginPath();
            ctx.moveTo(0, 0)
            ctx.lineTo(0, 0)
            ctx.arc(x, y, radius, startAngle, endAngle, counterClockwise);
            ctx.stroke();
            ctx.restore();
        }


        //Zeichnen: Abluftklappe 
        function lueftungsklappe(ctx, x, y, scale, val, rotation) {
            if (!val) val = 0;
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

        function freitext(ctx, x, y, scale, font, color, txt, bgHeight, bgColor, active) {
            ctx.save();
            ctx.moveTo(0 - 10 * scale, 0);

            var w = ctx.measureText(txt).width;
            ctx.font = font;
            if (bgColor) {
                ctx.fillStyle = bgColor;
                ctx.fillRect(x - 1, y - bgHeight - 1, w + 2, bgHeight + 3);
            }    
            
            ctx.translate(x, y);
            
            ctx.fillStyle = color;
            if (active) ctx.fillText(txt, 0, 0);

            ctx.restore();
        }

        // Zeichnen: Ventil
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

            ctx.moveTo(-8, -8);
            ctx.lineTo(-8, 8);
            ctx.lineTo(8, 0);
            ctx.lineTo(-8, -8);

            ctx.fill();

            /*ctx.fillRect(-1.5, -1, 1.5, 2);
            ctx.moveTo(0, 3);
            ctx.lineTo(2, 0);
            ctx.lineTo(0, -2);
            ctx.fill();
			
			ctx.translate(11, 0);
            ctx.fillRect(-1.5, -1, 1.5, 2);
            ctx.moveTo(0, 2);
            ctx.lineTo(2, 0);
            ctx.lineTo(0, -2);
            ctx.fill();*/
			
            ctx.restore();
        }

        // Zeichnen: LED
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

        function schalter(ctx, x, y, scale, val, rotation) {
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



        //Zeichen circle for HK Tooltip
        function hktooltip(ctx, x, y, scale) {
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

        //// document ready function
        //$(function () {
        //    canvas = document.getElementById('myvCanvas');
        //    canvas.width = 1400;
        //    canvas.height = 630;
        //    ctx = canvas.getContext('2d');
        //    // Label-Variablen initialisieren
        //    _xPos = document.getElementById("xPos");
        //    _yPos = document.getElementById("yPos");
        //    _lblEinheit = document.getElementById("lblEinheit");
        //    _lblNK = document.getElementById("lblNK");
        //    _lblKanal = document.getElementById("lblKanal");
        //    _lblBez = document.getElementById("lblBez");
        //    _lblKomm = document.getElementById("lblKomm");
        //    _lblID = document.getElementById("lblID");
        //    _lblclikAble = document.getElementById("lblClickable");
        //    $("#pghdr").empty();
        //    $("#pghdr").append(" <h1>Visualisierung bearbeiten</h1>");
        //    // Visu-Objekt laden
        //    getVCO();

        //});

        // Handler für Shift- Pfeil und Sondertasten (jeweils Key Up und Key Down)
        $(document).ready(function () {

            canvas = document.getElementById('myvCanvas');
            canvas.width = 1400;
            canvas.height = 630;
            ctx = canvas.getContext('2d');
            // Label-Variablen initialisieren
            _xPos = document.getElementById("xPos");
            _yPos = document.getElementById("yPos");
            _lblEinheit = document.getElementById("lblEinheit");
            _lblNK = document.getElementById("lblNK");
            _lblKanal = document.getElementById("lblKanal");
            _lblBez = document.getElementById("lblBez");
            _lblKomm = document.getElementById("lblKomm");
            _lblID = document.getElementById("lblID");
            _lblclikAble = document.getElementById("lblClickable");
            $("#pghdr").empty();
            $("#pghdr").append(" <h1>Visualisierung bearbeiten</h1>");
            // Visu-Objekt laden
            getVCO();


            $(this).keydown(function (e) {
                //if(e.keyCode != 16)
                //    alert(e.keyCode + " " + e.shiftKey);
                if (e.keyCode == 16)
                    ShiftPressed = true;
                if (e.keyCode == 38)
                    ArrUpPressed = true;
                if (e.keyCode == 40)
                    ArrDnPressed = true;
                if (e.keyCode == 37)
                    ArrLfPressed = true;
                if (e.keyCode == 39)
                    ArrRgPressed = true;
                // Scrollen der Werteliste unterbinden
                if (ArrUpPressed || ArrDnPressed || ArrLfPressed || ArrRgPressed || e.keyCode == 13)
                    e.preventDefault();
                if (e.keyCode == 46) { // Del
                    removeMarkedItem();
                    removeMarkedTextItem();
                }
                // ToolTip
                /*if (e.keyCode == 84) {
                    if (MarkedItem != null)
                        EditTooltip(MarkedItem);
                }*/
                //e.preventDefault();
            });

            $(this).keyup(function (e) {

                if (e.keyCode == 16)
                    ShiftPressed = false;
                if (e.keyCode == 38)
                    ArrUpPressed = false;
                if (e.keyCode == 40)
                    ArrDnPressed = false;
                if (e.keyCode == 37)
                    ArrLfPressed = false;
                if (e.keyCode == 39)
                    ArrRgPressed = false;
                e.preventDefault();
            });

        });

        // Timer für Positionierung der Werte auf der Zeichenfläche. 100-200ms passen in etwa
        var TimerVar = setInterval(function () { globalTimer() }, 100);
        var r = 0;

        function globalTimer() {
            r++;
            if (r > 10000)
                r = 0;
            if (ArrUpPressed)
                pxUp();
            else
                if (ArrDnPressed)
                    pxDn();
                else
                    if (ArrLfPressed)
                        pxLf();
                    else
                        if (ArrRgPressed)
                            pxRg();

        }

        // Tooltip Menue vorbereiten und aufrufen
        function EditTooltip(MarkedItem) {
            if (MarkedItem != null) {
                var s = MarkedItem.innerText;
                var slist = s.split(" ");
                var mBez = slist[0].trim();
                var mKanal = parseInt(slist[1]);
                var n = DropList.length;
                for (i = 0; i < n; i++) {
                    var DrawObject = DropList[i];
                    var bmpIndex = DrawObject["bmpIndex"];
                    var Bez = DrawObject["VCOItem"].Bez.trim();
                    var Kanal = DrawObject["VCOItem"].Kanal;
                    if (mBez == Bez && mKanal == Kanal) {
                        MarkedToolTipItem = DrawObject;
                        document.getElementById("ToolTipText").value = DrawObject.ToolTip;
                        location.href = "#EditToolTip";

                        break;
                    }
                }
            }

        }

        // "Übernehmen" Button in Tooltip abarbeiten
        function ConfirmToolTip() {
            var tt = document.getElementById("ToolTipText").value;
            MarkedToolTipItem.ToolTip = tt;

            fillInfo(MarkedToolTipItem);
            location.href = "#";
        }


        // Hintergrundfarbe einer Bitmap ermitteln
        function getBGColor(url) {
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getBackgroundColor",
                data: '{imgURL: ' + "'" + url + "'" + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (response) {
                    //VCO_Data = response.d;
                    //jsonVCOData = $.parseJSON(VCO_Data);
                    log(response.d);
                    $(".vinsideWrapper").css("background-color", response.d);
                },

                complete: function (xhr, status) {

                    log("getBGColor ok");
                },

                error: function (msg) {
                    log("getBGColor fail: " + msg);
                }
            });
        }

        // VCO = Visu Creation Object.
        // Beinhaltet alle notwendigen Daten zur Erstellung einer Visualisierung
        function getVCO() {
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getCurrentVCO",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (response) {
                    VCO_Data = response.d;
                    jsonVCOData = $.parseJSON(VCO_Data);
                },

                complete: function (xhr, status) {

                    log("VCO-Daten geladen für: ");
                    log(jsonVCOData.Beschreibung);
                    DisplayEditor();
                },

                error: function (msg) {
                    log("getVisuData fail");
                }
            });



        }


        // Update Screen nach Änderungen
        function DisplayEditor() {
            log("Display Editor aufgerufen");
            getBGColor(jsonVCOData.Bitmaps[bmpIndex].URL);  // Hintergrundfarbe für aktuelle Bitmap
            FillPropertyTable(jsonVCOData);                 // Werteliste der Steuerung laden
            FillImageList(jsonVCOData);                     // Bitmapliste initialisieren
        }

        // Eventhandler für click auf Werteliste. Markierung togglen oder umverlegen
        function liClick(item) {

            // Etwas fummelig: Umschaltlogik für Markierungen

            // Nicht verwendete Werte ignorieren
            $('#dummy').css('color', colInUse);
            if ($("#" + item.id).css("color") != $('#dummy').css('color')) {
                return;
            }
            // Markierung entfernen, sofern nicht die eigene
            $(".props").each(function () {
                var x = $(this)[0].id;
                if (x != item.id) {
                    $("#" + x).css("background-color", bgColUnmarked);
                }
            });
            // eigene Markiereung togglen
            var itm = item;
            $('#dummy').css('color', colInUse); // nur auf gesetzte Werte anwenden
            if ($("#" + item.id).css("color") === $('#dummy').css('color')) {
                $('#dummy').css('background-color', colMarked);
                if ($("#" + item.id).css("background-color") === $('#dummy').css('background-color')) {
                    $("#" + item.id).css("background-color", bgColUnmarked);
                    MarkedItem = null;
                    fillInfo(null);
                }
                else {
                    $("#" + item.id).css("background-color", colMarked);
                    MarkedItem = item; // Markierten Eintrag global merken
                    selectBitmapForMarkedItem();


                    var s = MarkedItem.innerText;
                    var slist = s.split(" ");
                    var mBez = slist[0].trim();
                    var mKanal = parseInt(slist[1]);
                    var n = DropList.length;
                    for (i = 0; i < n; i++) {
                        var DrawObject = DropList[i];
                        var bmpIndex = DrawObject["bmpIndex"];
                        var Bez = DrawObject["VCOItem"].Bez.trim();
                        var Kanal = DrawObject["VCOItem"].Kanal;
                        if (mBez == Bez && mKanal == Kanal) {
                            fillInfo(DrawObject);
                            break;
                        }
                    }
                }

            }
        }


        // Item in der Liste der gedropten Items finden
        function findDrawObject(MarkedItem) {
            var s = MarkedItem.innerText;
            var slist = s.split(" ");
            var mBez = slist[0].trim();
            var mKanal = parseInt(slist[1]);
            var n = DropList.length;
            for (i = 0; i < n; i++) {
                var DrawObject = DropList[i];
                var bmpIndex = DrawObject["bmpIndex"];
                var Bez = DrawObject["VCOItem"].Bez.trim();
                var Kanal = DrawObject["VCOItem"].Kanal;
                if (mBez == Bez && mKanal == Kanal) {
                    return DrawObject;
                    break;
                }
            }
        }

        // Property Liste füllen
        function FillPropertyTable(vco, numCols) {
            var n = vco.PearlImportItems.length;
            var p = vco.PearlImportItems;
            var list = "<ul id='lstvitems'>";
            for (i = 0; i < n; i++) {
                if (p[i].select) {
                    var line = "<li class='props' id='drag" + i + "' draggable='true' ondragstart='drag(event)' onclick='liClick(drag" + i + ")'>" +
                        p[i].Bez + " " + p[i].Kanal + (p[i].isBool ? " (bool) " : "") + " " + p[i].Kommentar + " id=" + i + "" +
                        "</li>"
                    list += line;
                }
            }
            list += "</ul>";
            $("#vitems").empty();
            $("#vitems").append(list);
            //$("#imgArea").empty();
            $("#imgArea").prepend("<img id='imgTarget' src='" + vco.Bitmaps[bmpIndex].URL + "' class='vcoveredImage'>");
        }

        // Freitext-Liste füllen
        function FillFreitextList() {

            CleanUpFreitextList();

            var ul = document.getElementById("lstFreitext");
            ul.innerHTML = "";
            var n = FreitextList.length;
            for (var i = 0; i < n; i++) {
                var txt = FreitextList[i].Freitext;
                txt += " (" + FreitextList[i].bmpIndex + "," + FreitextList[i].x + "," + FreitextList[i].y + ")";

                if (FreitextList[i].isVerweis)
                    txt += " - Verweis";

                var li = document.createElement("li");
                var liid = "lift_" + FreitextList[i].bmpIndex + "_" + FreitextList[i].x + "_" + FreitextList[i].y;
                li.setAttribute("id", liid);
                li.setAttribute("onclick", "liFreitextClick('" + liid + "')");
                //li.onclick = function () { liFreitextClick(liid); };

                li.appendChild(document.createTextNode(txt));
                li.classList.add("ft_item");
                ul.appendChild(li);
            }
        }

        // Eventhandler Klick auf Freitextlisten-Eintrag
        function liFreitextClick(item) {
            $('#dummy_txt').css('background-color', colMarked);

            $(".ft_item").each(function () {
                if (item === this.id) {
                    var x = $('#dummy_txt').css('background-color');
                    var y = $("#" + item).css("background-color");
                    if (x === y) {
                        $("#" + item).css("background-color", bgColUnmarked);
                        MarkedTextItem = null;
                    }
                    else {
                        $("#" + item).css("background-color", colMarked);
                        MarkedTextItem = item; // Markierten Eintrag global merken
                        selectBitmapForMarkedTextItem();
                    }
                }
                else
                    $(this).css("background-color", bgColUnmarked);
            });
        }

        // Bitmap-Liste aufbauen
        function FillImageList(vco) {
            var b = vco.Bitmaps;
            var n = b.length;
            var list = "";
            for (i = 0; i < n; i++) {
                if (i == 0)
                    list += "<input id='rdb" + i + "' type='radio' name='img'" + " onclick='radioclick(" + i + ")' " + " value='img" + i + "' checked/>" + " " + b[i].Beschreibung + "<br />";
                else
                    list += "<input id='rdb" + i + "' type='radio' name='img'" + " onclick='radioclick(" + i + ")' " + " value='img" + i + "' />" + " " + b[i].Beschreibung + "<br />";

            }
            $("#ImageSelect").empty();
            $("#ImageSelect").append(list);

        }

        // Eventhandler für Klicks auf Radiobuttons Bitmapliste
        function radioclick(i) {
            bmpIndex = i;
            $(".vcoveredImage").remove();
            $("#imgArea").prepend("<img id='imgTarget' src='" + jsonVCOData.Bitmaps[bmpIndex].URL + "' class='vcoveredImage'>");
            var burl = jsonVCOData.Bitmaps[bmpIndex].URL;
            getBGColor(burl);
            DrawAllLists();
        }

        // Drag&Drop: Implementierung für Texte
        function dragtxt(ev) {
            ev.dataTransfer.setData("text", ev.target.id);
        }

        // Drag&Drop: Implementierung für Properties
        function drag(ev) {
            $('#dummy').css('color', colInUse);
            if ($("#" + ev.target.id).css("color") === $('#dummy').css('color')) {
                noDnD = true;
            }
            else
                noDnD = false;
            ev.dataTransfer.setData("text", ev.target.id);
            var txt = ev.target.innerHTML; // " id="
            var n = txt.lastIndexOf(" id=");
            if (n >= 0) {
                var sid = txt.substring(n + 4);
                var id = parseInt(sid);
                CurrentVCOItem = jsonVCOData.PearlImportItems[id];
            }

            _lblEinheit.innerHTML = CurrentVCOItem.sEinheit;
            _lblNK.innerHTML = CurrentVCOItem.NKStellen;
            _lblBez.innerHTML = CurrentVCOItem.Bez;
            _lblKanal.innerHTML = CurrentVCOItem.Kanal;
            _lblKomm.innerHTML = CurrentVCOItem.Kommentar;
            _lblID.innerHTML = CurrentVCOItem.iD;
            _lblclikAble.innerHTML = CurrentVCOItem.clickAble;
        }

        // Drag&Drop: Implementierung Drop für Properties und Texte
        function drop(ev) {
            ev.preventDefault();
            const data = ev.dataTransfer.getData("text");
            const t = data.split(" ");
            const isVCOItem = (t[0] == "Freitext") ? false : true;

            const sz = document.getElementById("selSize");
            const ff = document.getElementById("selFontfamily");
            const ft = sz.value + ff.value;
            const col = document.getElementById("selColor").value;
            const bgcol = document.getElementById("selBgCol").value;
            const ssz = sz.value;
            const sn = parseInt(ssz.substring(0, ssz.indexOf("px")));

            const obj = new Object();
            obj.bmpIndex = bmpIndex;
            if (isVCOItem) {
                obj.VCOItem = CurrentVCOItem;
                obj.ToolTip = CurrentVCOItem.Kommentar;
            }
            obj.x = CurrentX;
            obj.y = CurrentY;
            if (document.querySelector(`#cbAlignItems`).checked)
                alignItems(obj, isVCOItem);
            obj.font = ft;
            obj.Color = col;
            obj.BgColor = bgcol;
            obj.BgHeight = sn;
            

            if (!isVCOItem) {
                const p = data.indexOf(" ");
                const ftxt = data.substr(p + 1);

                obj.Freitext = ftxt;
                // Usrsprüngliche Positionen bei Eingabe merken
                obj._x = CurrentX;
                obj._y = CurrentY;
                //if (bgcol == "")
                //    bgcol = $(".vinsideWrapper").css("background-color");

                // Freitext als Verweis verwenden
                obj.isVerweis = TextIsVerweis;
                obj.VerweisAusrichtung = VerweisAusrichtung;
                obj.idxVerweisBitmap = idxBitmap;


                FreitextList.push(obj);

                $(".infoDiv").hide();
                DrawAllLists();
                document.getElementById("TextInput").value = "";
                FillFreitextList();
            }
            else {
                obj.Symbol = "";
                obj.SymbolFeature = "";

                // ggf. Symbol Initialisierung fordern
                if (CurrentVCOItem.isBool)
                    obj.ShowSymbolMenue = true;

                //if (bgcol == "")
                //    bgcol = $(".vinsideWrapper").css("background-color");
                DropList.push(obj);

                $("#" + data).css("color", colInUse);

                $(".infoDiv").hide();
                DrawAllLists();
                // Markieren
                liClick(document.getElementById(data));
            }
        }

        //Align Items on Drop
        function alignItems(obj, isVCOItem, toleranceInPx=10) {
            const upperLimitX = obj.x + toleranceInPx;
            const lowerLimitX = obj.x - toleranceInPx;
            const upperLimitY = obj.y + toleranceInPx;
            const lowerLimitY = obj.y - toleranceInPx;

            let distanceX = 999999;
            let distanceY = 999999;
            const list = (isVCOItem) ? DropList : FreitextList;
            list.forEach(el => {
                if (obj.bmpIndex === el.bmpIndex) {
                    if (!isVCOItem || obj.VCOItem.isBool === el.VCOItem.isBool) {
                        let elDistance = Math.sqrt(Math.pow(el.x - obj.x, 2) + Math.pow(el.y - obj.y, 2));
                        if (el.x <= upperLimitX && el.x >= lowerLimitX) {
                            if (elDistance < distanceX) {
                                log(`alignItem X`);
                                distanceX = elDistance;
                                obj.x = el.x;
                            }
                        }
                        if (el.y <= upperLimitY && el.y >= lowerLimitY) {
                            if (elDistance < distanceY) {
                                log(`alignItem Y`);
                                distanceY = elDistance;
                                obj.y = el.y;
                            }
                        }
                    }
                }
            });
        }

        // Drag&Drop Abbruch impl.
        function leave(ev) {
            $(".infoDiv").hide();

        }

        // Drag&Drop Dropbereich abgrenzen
        function allowDrop(ev) {

            if (noDnD == false) {
                ev.preventDefault();
                DisplayInfo(ev);
            }
        }

        // Hilfsfunktion zum Debuggen
        function DisplayInfo(ev) {

            CurrentX = Math.round(ev.layerX);
            CurrentY = Math.round(ev.layerY);
            _xPos.innerHTML = "X=" + CurrentX;
            _yPos.innerHTML = "Y=" + CurrentY;
            $(".infoDiv").css("top", Math.round(ev.pageY + 100) + "px");
            $(".infoDiv").css("left", Math.round(ev.pageX + 100) + "px");
            $(".infoDiv").show();
        }

        // Freitext Liste aufbauen und zeichnen
        function _drawFreitextList() {

            var n = FreitextList.length;
            for (i = 0; i < n; i++) {
                var item = FreitextList[i];
                if (FreitextList[i].bmpIndex == bmpIndex) {
                    var x = item.x;
                    var y = item.y;
                    var txt = item.Freitext;
                    ctx.font = item.font;
                    if (item.BgColor) ctx.fillStyle = item.BgColor;
                    var w = ctx.measureText(txt).width;

                    if (item.isVerweis) {
                        ctx.save();
                        ctx.translate(x, y);
                        if (item.VerweisAusrichtung == "up")
                            ctx.rotate(-Math.PI / 2);
                        if (item.VerweisAusrichtung == "dn")
                            ctx.rotate(Math.PI / 2);
                        if (item.BgColor) ctx.fillRect(0 - 6, 0 - item.BgHeight - 6, w + 16, item.BgHeight + 16);
                        ctx.strokeStyle = "black";
                        ctx.strokeRect(0 - 6, 0 - item.BgHeight - 6, w + 16, item.BgHeight + 16);
                        ctx.fillStyle = item.Color;
                        ctx.fillText(txt, 0, 0);
                        ctx.restore();
                    }
                    else {
                        if (item.BgColor) ctx.fillRect(x - 1, y - item.BgHeight - 1, w + 2, item.BgHeight + 3);
                        ctx.fillStyle = item.Color;
                        ctx.fillText(txt, x, y);
                    }
                }
            }
        }

        // Dropliste aufbauen und zeichnen
        function _drawDropList() {
            var n = DropList.length;
            //ctx.clearRect(0, 0, canvas.width, canvas.height);
            for (i = 0; i < n; i++) {
                CurrentDroplistIndex = i; // von Symbol-Menue zu verwenden
                drawVCOItem(DropList[i]);
            }

        }

        // Alle neu zeichnen
        function DrawAllLists() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            _drawDropList();
            _drawFreitextList();
        }

        // VCO ( Visu Control Objekt) zeichnen
        function drawVCOItem(item) {
            if (item.bmpIndex === bmpIndex) {
		        const {VCOItem, x, y, BgColor, BgHeight} = item;
                
                if (item.ShowSymbolMenue) {
                    CurrentDroplistItem = item;
                    location.href = '#EditSymbol';
                }
                else {
                    if (VCOItem.isBool) {
                        drawSymbolAndFeature(item);
                    }
                    else {
                        ctx.font = item.font;
                        const txt = `${VCOItem.Bez} ${VCOItem.Kanal} ${VCOItem.sEinheit.replace(`^3`,`³`)}`;
                        const w = ctx.measureText(txt).width;
                        if (BgColor) {
                            ctx.fillStyle = BgColor;
                            ctx.fillRect(x - 1, y - BgHeight - 1, w + 2, BgHeight + 3);
                        }
                        ctx.fillStyle = item.Color;
                        ctx.fillText(txt, x, y);
                    }
                }
            }
        }

        // Bitmap für markierten Freitext setzen
        function selectBitmapForMarkedTextItem() {
            if (MarkedTextItem != null) {
                var slist = MarkedTextItem.split("_");
                var bmpIndex = parseInt(slist[1]);
                radioclick(bmpIndex);
                $("#rdb" + bmpIndex).prop("checked", true);
                DrawAllLists();
            }
        }

        // Bitmap für markierten Wert setzen
        function selectBitmapForMarkedItem() {
            if (MarkedItem != null) {
                var s = MarkedItem.innerText;
                var slist = s.split(" ");
                var mBez = slist[0].trim();
                var mKanal = parseInt(slist[1]);
                var n = DropList.length;
                for (i = 0; i < n; i++) {
                    var DrawObject = DropList[i];
                    var bmpIndex = DrawObject["bmpIndex"];
                    var Bez = DrawObject["VCOItem"].Bez.trim();
                    var Kanal = DrawObject["VCOItem"].Kanal;
                    if (mBez == Bez && mKanal == Kanal) {
                        radioclick(bmpIndex);
                        $("#rdb" + bmpIndex).prop("checked", true);
                        DrawAllLists();
                        break;
                    }
                }
            }
        }

        // Hilfsfunktion 
        Array.prototype.remove = function (from, to) {
            var rest = this.slice((to || from) + 1 || this.length);
            this.length = from < 0 ? this.length + from : from;
            return this.push.apply(this, rest);
        };

        // aktuell markierten Freitext löschen
        function removeMarkedTextItem() {
            if (MarkedTextItem != null) {
                n = FreitextList.length;
                for (i = 0; i < n; i++) {
                    var s = MarkedTextItem.split("_");
                    var bmp = s[1];
                    var x = parseInt(s[2]);
                    var y = parseInt(s[3]);
                    if (FreitextList[i].bmpIndex == bmp && FreitextList[i]._x == x && FreitextList[i]._y == y) {
                        $(".ft_item").each(function () {
                            $('#dummy_txt').css('background-color', colMarked);
                            var bg1 = $(this).css("background-color");
                            var bg2 = $('#dummy_txt').css('background-color');
                            if (bg1 === bg2) {

                                $(this).remove();
                            }
                        });
                        FreitextList.remove(i);
                        MarkedTextItem = null;

                        DrawAllLists();
                        break;
                    }
                }
            }
        }

        // aktuell markierten Wert löschen
        function removeMarkedItem() {
            if (MarkedItem != null) {
                var s = MarkedItem.innerText;
                var slist = s.split(" ");
                var mBez = slist[0].trim();
                var mKanal = parseInt(slist[1]);
                var n = DropList.length;
                for (i = 0; i < n; i++) {
                    var DrawObject = DropList[i];
                    var bmpIndex = DrawObject["bmpIndex"];
                    var Bez = DrawObject["VCOItem"].Bez.trim();
                    var Kanal = DrawObject["VCOItem"].Kanal;
                    if (mBez == Bez && mKanal == Kanal) {
                        $(".props").each(function () {
                            var x = $(this)[0].id;
                            if (x == MarkedItem.id) {
                                $("#" + x).css("background-color", bgColUnmarked);
                                $("#" + x).css("color", colNotInUse);
                            }
                        });
                        DropList.remove(i);
                        MarkedItem = null;
                        fillInfo(null);
                        DrawAllLists();
                        break;
                    }
                }
            }
        }

        function CleanUpFreitextList() {
            if (FreitextList != null) {
                var n = FreitextList.length;
                for (var i = 0; i < n; i++) {
                    //FreitextList[i].x = FreitextList[i]._x;
                    //FreitextList[i].y = FreitextList[i]._y;
                    FreitextList[i]._x = FreitextList[i].x;
                    FreitextList[i]._y = FreitextList[i].y;
                }
            }
        }

        // Eventhandler für Verschiebungen auf dem Canvas (per Timer getriggert)
        function pxMove(direction, step) {
            // selektierten Eintrag in Liste finden, dann per id in Drawlist finden, Wert ändern und neu zeichnen
            if (MarkedItem != null) {
                var s = MarkedItem.innerText;
                var slist = s.split(" ");
                var mBez = slist[0].trim();
                var mKanal = parseInt(slist[1]);
                var n = DropList.length;
                for (i = 0; i < n; i++) {
                    var DrawObject = DropList[i];
                    var bmpIndex = DrawObject["bmpIndex"];
                    var Bez = DrawObject["VCOItem"].Bez.trim();
                    var Kanal = DrawObject["VCOItem"].Kanal;
                    if (mBez == Bez && mKanal == Kanal) {
                        if (direction == "up") {
                            DropList[i]["y"] -= 1 * step;
                            if (DropList[i]["y"] < 10)
                                DropList[i]["y"] = 10;
                        }
                        if (direction == "down") {
                            DropList[i]["y"] += 1 * step;
                            if (DropList[i]["y"] > canvas.height - 5)
                                DropList[i]["y"] = canvas.height - 5;
                        }
                        if (direction == "left") {
                            DropList[i]["x"] -= 1 * step;
                            if (DropList[i]["x"] < 1)
                                DropList[i]["x"] = 1;
                        }
                        if (direction == "right") {
                            DropList[i]["x"] += 1 * step;
                            if (DropList[i]["x"] > canvas.width - 15)
                                DropList[i]["x"] = canvas.width - 15;
                        }
                        DrawAllLists();
                        break;

                    }
                }

            }
            // dito für Texteinträge
            if (MarkedTextItem != null) {
                n = FreitextList.length;
                for (var i = 0; i < n; i++) {
                    var s = MarkedTextItem.split("_");
                    var bmp = s[1];
                    var x = parseInt(s[2]);
                    var y = parseInt(s[3]);

                    if (FreitextList[i].bmpIndex == bmp && FreitextList[i]._x == x && FreitextList[i]._y == y) {

                        if (direction == "up") {
                            FreitextList[i]["y"] -= 1 * step;
                            if (FreitextList[i]["y"] < 10)
                                FreitextList[i]["y"] = 10;
                        }
                        if (direction == "down") {
                            FreitextList[i]["y"] += 1 * step;
                            if (FreitextList[i]["y"] > canvas.height - 5)
                                FreitextList[i]["y"] = canvas.height - 5;
                        }
                        if (direction == "left") {
                            FreitextList[i]["x"] -= 1 * step;
                            if (FreitextList[i]["x"] < 1)
                                FreitextList[i]["x"] = 1;
                        }
                        if (direction == "right") {
                            FreitextList[i]["x"] += 1 * step;
                            if (FreitextList[i]["x"] > canvas.width - 15)
                                FreitextList[i]["x"] = canvas.width - 15;
                        }
                        DrawAllLists();
                        break;
                    }
                }
            }
        }

        // Einzelne Impl.
        function pxUp() {
            var step = ShiftPressed ? 5 : 1;
            pxMove("up", step);
        }

        function pxDn() {
            var step = ShiftPressed ? 5 : 1;
            pxMove("down", step);
        }

        function pxLf() {
            var step = ShiftPressed ? 5 : 1;
            pxMove("left", step);
        }

        function pxRg() {
            var step = ShiftPressed ? 5 : 1;
            pxMove("right", step);
        }

        // Remove
        function pxRem() {
            removeMarkedItem();
        }

        // Drag&Drop: Drag Freitext
        function dragFreitext(ev) {
            var txt = document.getElementById("TextInput").value.trim();
            if (txt == "")
                noDnD = true;
            else
                noDnD = false;
            ev.dataTransfer.setData("text", "Freitext " + txt.trim());
        }

        // Tab Label Umschaltung impl.
        function handleTabLabel(item) {
            $("#tabLabel1").switchClass("tablabelSelected", "tablabel");
            $("#tabLabel2").switchClass("tablabelSelected", "tablabel");
            $("#tabLabel3").switchClass("tablabelSelected", "tablabel");

            $("#vitems").css("display", "none");
            $("#textitems").css("display", "none");
            $("#symbolitems").css("display", "none");

            $(item).switchClass("tablabel", "tablabelSelected");

            var id = item.id;
            if (id == "tabLabel1") {
                $("#vitems").css("display", "block");
                $(".ft_item").each(function () {
                    $(this).css("background-color", bgColUnmarked);
                });
                MarkedTextItem = null;
            }
            if (id == "tabLabel2") {
                $("#textitems").css("display", "block");
                // Markierungen in Propertyliste entfernen
                $(".props").each(function () {
                    var x = $(this)[0].id;
                    $("#" + x).css("background-color", bgColUnmarked);
                });
                // Gemerkte Markierung entfernen
                MarkedItem = null;
            }

            if (id == "tabLabel3")
                $("#symbolitems").css("display", "block");
        }


        // Hilfsfunktion für Symbol-Menue
        function HandleSymbolFeatures(value) {
            const divSymbolFeatureOptions = document.querySelector('#divSymbolFeatureOptions');
            divSymbolFeatureOptions.style.display = 'none';
            var select = document.getElementById('SelectSymbolFeature');
            select.style.display = 'none';
            var i;
            for (i = select.options.length - 1; i >= 0; i--) {
                select.remove(i);
            }
            
            if (value.match(/(Ventil)|(Lueft)|(Schalter)/)) {
                //$("#SelectSymbolFeature").css("display", "block");
                select.style.display = 'block';
                var opt;
                opt = document.createElement('option');
                opt.value = "Links"; opt.innerHTML = "Links"; select.appendChild(opt);
                opt = document.createElement('option');
                opt.value = "Rechts"; opt.innerHTML = "Rechts"; select.appendChild(opt);
                opt = document.createElement('option');
                opt.value = "Oben"; opt.innerHTML = "Oben"; select.appendChild(opt);
                opt = document.createElement('option');
                opt.value = "Unten"; opt.innerHTML = "Unten"; select.appendChild(opt);
            }
            if (value == "Led") {
                //$("#SelectSymbolFeature").css("display", "block");
                select.style.display = 'block';
                var opt;
                opt = document.createElement('option');
                opt.value = "gruen/rot"; opt.innerHTML = "grün/rot"; select.appendChild(opt);
                opt = document.createElement('option');
                opt.value = "rot/gruen"; opt.innerHTML = "rot/grün"; select.appendChild(opt);
                opt = document.createElement('option');
                opt.value = "gruen/unsichtbar"; opt.innerHTML = "grün/unsichtbar"; select.appendChild(opt);
                opt = document.createElement('option');
                opt.value = "unsichtbar/rot"; opt.innerHTML = "unsichtbar/rot"; select.appendChild(opt);
                opt = document.createElement('option');
                opt.value = "unsichtbar/rot blinkend"; opt.innerHTML = "unsichtbar/rot blinkend"; select.appendChild(opt);
                opt = document.createElement('option');
                opt.value = "gruen/rot blinkend"; opt.innerHTML = "grün/rot blinkend"; select.appendChild(opt);
            }
            if (value == "Freitext") divSymbolFeatureOptions.style.display = 'block';
            selectedSymbol = value;
            //selectedSymbolFeature = select.value;
        }

        // Symbole zeichnen
        function drawSymbolAndFeature(_item) {
            // bei Neuanlage in Droplist noch nicht gesetzt, aber im Auswahlmenue
            const item = (_item) ? _item : CurrentDroplistItem;
            
            if (item.ShowSymbolMenue == true) {
                // Neuer Eintrag. in Droplist setzen
                item.ShowSymbolMenue = false;
                item.Symbol = selectedSymbol;
                item.SymbolFeature = (item.Symbol === 'Freitext')   ? `${(document.querySelector('#cbInvertSymbolFeature').checked) ? `!` : ``}${document.querySelector('#TextInputSymbolFeature').value}`
                                                                    : document.querySelector(`#SelectSymbolFeature`).value;
            }

            const {Symbol, x, y, SymbolFeature} = item;

            // nun zeichnen
            if (Symbol.match(/(fpButton)|(Heizkreis)/)) {
                fpButton(ctx, x, y, 1);
            }

            if (Symbol == "Absenkung") {
                Absenkung(ctx, x, y, 1, 0);
            }

            if (Symbol == "HKTooltip") {
                hktooltip(ctx, x, y, 1);
            }

            if (Symbol == "BHKW") {
                BHDreh(ctx, x, y, 1, 0);
            }
            if (Symbol == "Feuer") {
                feuer(ctx, x, y, 1);
            }
            if (Symbol == "Pumpe") {
                pmpDreh2(ctx, x, y, 1, 0);
            }

            const rotation =    (SymbolFeature === "Rechts") ? 180 :
                                (SymbolFeature === "Oben") ? 90 :
                                (SymbolFeature === "Unten") ? 270 : 0;
            if (Symbol == "Luefter")
                luefter(ctx, x, y, 1, 30, rotation);
            if (Symbol == "Ventil")
                ventil(ctx, x, y, 1, rotation);
            if (Symbol == "Lueftungsklappe")
                lueftungsklappe(ctx, x, y, 1, 100, rotation);
            if (Symbol == "Schalter")
                schalter(ctx, x, y, 1, 100, rotation);
            if (Symbol == "Freitext")
                freitext(ctx, x, y, 1, item.font, item.Color, SymbolFeature, item.BgHeight, item.BgColor, true);

            if (Symbol == "Led") {
                if (SymbolFeature == "gruen/rot")
                    Led(ctx, x, y, 1, "green");
                if (SymbolFeature == "rot/gruen")
                    Led(ctx, x, y, 1, "red");
                if (SymbolFeature == "unsichtbar/rot")
                    Led(ctx, x, y, 1, "orange");
                if (SymbolFeature == "unsichtbar/rot blinkend")
                    Led(ctx, x, y, 1, "magenta");
                if (SymbolFeature == "gruen/rot blinkend")
                    Led(ctx, x, y, 1, "yellow");
            }
            // Menue verlassen
            location.href = "#";
        }


        // Info für selektierte Property
        function fillInfo(DrawItem) {
            if (DrawItem == null) {
                document.getElementById('infoBez').innerHTML = "-";
                document.getElementById('infoKanal').innerHTML = "-";
                document.getElementById('infoEinheit').innerHTML = "-";
                document.getElementById('infoTooltip').innerHTML = "-";
                document.getElementById('infoKomm').innerHTML = "-";
                document.getElementById('infoID').innerHTML = "-";
                document.getElementById('infoClickable').innerHTML = "-";
            }
            else {
                document.getElementById('infoBez').innerHTML = DrawItem.VCOItem.Bez;
                document.getElementById('infoKanal').innerHTML = DrawItem.VCOItem.Kanal;
                document.getElementById('infoEinheit').innerHTML = DrawItem.VCOItem.sEinheit;
                document.getElementById('infoTooltip').innerHTML = DrawItem.ToolTip;
                document.getElementById('infoKomm').innerHTML = DrawItem.VCOItem.Kommentar;
                document.getElementById('infoID').innerHTML = DrawItem.VCOItem.iD;
                document.getElementById('infoClickable').innerHTML = DrawItem.VCOItem.clickable;
            }
        }

        // globale Variablen für Verweise auf andere Bitmaps
        var TextIsVerweis = false;
        var VerweisAusrichtung = "hor";
        var idxBitmap = 0;

        // Eventhandler für Verweiswechsel Checkbox
        function cbVerweisChanged() {
            if (document.getElementById("cbVerweis").checked) {

                var select = document.getElementById('SelectVerweisBitmap');
                for (var i = select.options.length - 1; i >= 0; i--) {
                    select.remove(i);
                }

                $("#Verweisoptionen").css("display", "block");
                TextIsVerweis = true;
                var Bitmaps = jsonVCOData.Bitmaps;
                for (var i = 0; i < Bitmaps.length; i++) {
                    var opt = document.createElement('option');
                    opt.value = i; opt.innerHTML = Bitmaps[i].Beschreibung;
                    select.appendChild(opt);
                }
                var y = 9;
            }
            else {
                $("#Verweisoptionen").css("display", "none");
                TextIsVerweis = false;
            }
        }

        // Änderung Verweis global merken
        function rdVerweisChanged(value) {
            VerweisAusrichtung = value;
        }

        // Bitmapwechsel merken
        function VerweisBitmapChanged() {
            var idx = document.getElementById('SelectVerweisBitmap').selectedIndex;
            idxBitmap = idx;
        }

        // Transferobjekt für Export per Webservice erzeugen
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

        // Transferobjekt posten per Webservice 
        function postVTO(fileName, vto) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/postVTO",
                data: vto,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false, // wichtig! sonst kein Rückgabewert
                success: function (response) {
                    var r = response.d;
                    log("postVTO ok");
                    res = r;
                },
                complete: function (xhr, status) {
                    log("sendVTO complete");
                },
                error: function (msg) {
                    log("sendVTO fail: " + msg);
                }
            });
            return res;
        }

        // Transferobjekt laden
        function loadVTO() {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/loadVTO",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,// wichtig! sonst kein Rückgabewert
                success: function (response) {
                    var r = response.d;
                    log("loadVTO ok");
                    res = r;
                },
                complete: function (xhr, status) {
                    log("loadVTO complete");
                },
                error: function (xhr, status, error) {

                }
            });
            return res;
        }

        // Testfenster für aktuellen Stand anfordern
        function testVisu() {
            var vto = createVisuTransferObject();
            var svto = JSON.stringify({ 'vto': vto });
            var k = postVTO("", svto);
            loadVisu();
            //var x = $.parseJSON(k);
        }

        // Freies Browserfenster erzeugen
        function loadVisu() {
            //var loaded = loadVTO();
            window.open("/VisuTestPage.aspx", "", "width=1135, height=800");
            //var x = 12;
        }

        // bei erfolgreichem laden true
        var hasSampleData = false;

        // Beispieldaten laden (siehe Webservice impl.)
        function downloadSampleData(Projektnummer) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/downloadSampleData",
                data: '{Projektnummer: ' + "'" + Projektnummer + "'" + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (response) {
                    var r = response.d;
                    if (r == "ok") {
                        log("loadSampleData ok");
                        hasSampleData = true;
                    }
                    else
                        log("loadSampleData not loaded");
                    res = r;
                },
                complete: function (xhr, status) {
                    log("loadSampleData complete");
                },
                error: function (msg) {
                    log("loadSampleData failed");
                }
            });
            return res;
        }

        // Aufruffunktion Beispieldaten
        function getSampleData() {
            var prj = jsonVCOData.Projektnumer;
            downloadSampleData(prj);
        }

        // aktuellen Stand mit Dateinamen speichern
        function saveFileToServer(vto) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/saveVisuFile",
                data: vto,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var r = response.d;
                    log("saveFileToServer ok");
                    res = r;
                },
                complete: function (xhr, status) {
                    log("saveFileToServer complete");
                },
                error: function (msg) {
                    log("saveFileToServer fail: " + msg);
                }
            });
            return res;
        }

        // aktuellen Stand als Deploy in EF speichern
        function deployVisu(vto) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/deployVisu",
                data: vto,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var r = response.d;
                    log("deployVisu ok");
                    res = r;
                },
                complete: function (xhr, status) {
                    log("deployVisu complete");
                },
                error: function (msg) {
                    log("deployVisu fail: " + msg);
                }
            });
            return res;
        }

        // aktuellen Stand in Snapshot Datei speichern
        function saveSnapshotToServer(vto) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/saveSnapshot",
                data: vto,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var r = response.d;
                    log("saveSnapshot ok");
                    res = r;
                },
                complete: function (xhr, status) {
                    log("saveSnapshot complete");
                },
                error: function (msg) {
                    log("saveSnapshot fail: " + msg);
                }
            });
            return res;
        }

        // Snapshot laden
        function loadSnapshotFromServer() {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/loadSnapshot",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var r = response.d;
                    log("loadSnapshot ok");
                    res = r;
                    return res;
                },
                complete: function (xhr, status) {
                    log("loadSnapshot complete");
                },
                error: function (msg) {
                    log("loadSnapshot fail: " + msg);
                }
            });
            return res;
        }

        // Datei per Name laden
        function loadVisuFileFromServer(fname) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/loadVisuFile",
                data: '{fname: ' + "'" + fname + "'" + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var r = response.d;
                    log("loadVisuFileFromServer ok");
                    res = r;
                    return res;
                },
                complete: function (xhr, status) {
                    log("loadVisuFileFromServer complete");
                },
                error: function (msg) {
                    log("loadVisuFileFromServer fail: " + msg);
                }
            });
            return res;
        }


        // In Gebrauch befindliche Properties in Liste farblich markieren
        function markUsedItems() {
            var n = DropList.length;
            for (var i = 0; i < n; i++) {
                var VCO = DropList[i].VCOItem;
                var Bez = VCO.Bez.trim();
                var Kanal = VCO.Kanal;
                $(".props").each(function () {
                    var x = $(this)[0].id;
                    var txt = $(this)[0].innerText;
                    var sp = txt.split(" ");
                    var _Bez = sp[0].trim();
                    var _Kanal = parseInt(sp[1]);

                    if (Bez == _Bez && Kanal == _Kanal) {
                        $("#" + x).css("color", colInUse);
                    }
                });
            }
        }

        
        // Snapshot speichern (Aufruf Funktion)
        function saveSnapshot() {
            var vto = createVisuTransferObject();
            var svto = JSON.stringify({ 'vto': vto });
            saveSnapshotToServer(svto);
        }

        // Snapshot laden (Aufruf Funktion)
        function loadSnapshot() {
            var svto = loadSnapshotFromServer();
            var vto = $.parseJSON(svto);
            DropList = vto["DropList"];
            FreitextList = vto["FreitextList"];
            jsonVCOData = vto["VCOData"];
            DisplayEditor();
            MarkedItem = null;
            markUsedItems();
            FillFreitextList();
            MarkedTextItem = null;
            DrawAllLists();
            CurrentFileName = "VisuSnapshot";
        }

        // Liste der Visudateien auf Server anfordern
        function getVisuFileList() {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getVisuFileList",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var r = response.d;
                    log("getVisuFileList ok");
                    res = r;
                    return res;
                },
                complete: function (xhr, status) {
                    log("getVisuFileList complete");
                },
                error: function (msg) {
                    log("getVisuFileList fail: " + msg);
                }
            });
            return res;
        }

        // per Dateiname laden (Aufruf Funktion)
        function loadFromFile() {
            var flist = $.parseJSON(getVisuFileList());
            var select = document.getElementById('FileList');
            var i;
            for (i = select.options.length - 1; i >= 0; i--) {
                select.remove(i);
            }
            var n = flist.length;
            for (var i = 0; i < n; i++) {
                var opt = document.createElement('option');
                opt.value = flist[i];
                opt.innerHTML = flist[i];
                select.appendChild(opt);
            }
            location.href = "#SelectFile";
        }

        // per Dateiname speichern (Aufruf Funktion)
        function saveToFile() {

            var sfname = document.getElementById('saveFileName');
            sfname.value = CurrentFileName;
            location.href = "#SaveFile";
        }

        // Impl. Übernehmen Button (speichern)
        function ConfirmSaveFile() {
            var sfname = document.getElementById('saveFileName').value;
            if (sfname.trim() != "") {
                var vto = createVisuTransferObject(sfname.trim());
                var svto = JSON.stringify({ 'vto': vto });
                saveFileToServer(svto);
                location.href = "#";
            }
        }

        // Impl. Übernehmen Button (laden)
        function ConfirmFileSelection() {
            var selFile = document.getElementById('FileList').value;
            CurrentFileName = selFile;
            var svto = loadVisuFileFromServer(selFile);

            //var svto = loadSnapshotFromServer();
            var vto = $.parseJSON(svto);
            DropList = vto["DropList"];
            FreitextList = vto["FreitextList"];
            jsonVCOData = vto["VCOData"];
            DisplayEditor();
            MarkedItem = null;
            markUsedItems();
            FillFreitextList();
            MarkedTextItem = null;
            DrawAllLists();

            location.href = "#";
        }

        function DeployVisu() {
            var vto = createVisuTransferObject();
            var svto = JSON.stringify({ 'vto': vto });
            console.log(svto);
            //saveSnapshotToServer(svto);
            deployVisu(svto);
        }

        function updateVisu() {
            window.location.href = "/_s1_PearlUpload.aspx";
        };

    </script>

    <div id="main" class="container" style="max-width: 2200px">
        <div class="row">
            <div class="col-md-2" style="height: 640px;">
                <div class="ListFrame">



                    <div id="vitems" style="height: 600px; overflow-y: scroll; background-color: beige; margin: 5px; padding: 8px; border-radius: 15px; display: block">
                    </div>

                    <div id="textitems" style="height: 600px; overflow-y: scroll; background-color: beige; margin: 5px; padding: 8px; border-radius: 15px; display: none">
                        <p class="Title">Freitext / Verweis</p>
                        <p class="Hinweis">
                            Freitext eingeben und mit "Drag" auf die Zeichenfäche ziehen.
                        </p>
                        <input type="text" id="TextInput" style="width: 120px">
                        <label id="txtdrag" class="draglabel" draggable="true" ondragstart="dragFreitext(event)">Drag</label>

                        <br />
                        <input id="cbVerweis" type="checkbox" onchange="cbVerweisChanged()" />
                        Verweistext zu Bitmap
                        <div id="Verweisoptionen" class="Verweisoptionen" style="display: none">
                            <input id="rdHor" type="radio" name="rdVerweis" onclick="rdVerweisChanged(value)" value="hor" checked />
                            Horizontal<br />
                            <input id="rdUp" type="radio" name="rdVerweis" onclick="rdVerweisChanged(value)" value="up" />
                            Vertikal Aufwärts<br />
                            <input id="rdDn" type="radio" name="rdVerweis" onclick="rdVerweisChanged(value)" value="dn" />
                            Vertikal Abwärts<br />

                            Verweisen zu Bitmap:<br />
                            <select id="SelectVerweisBitmap" onchange="VerweisBitmapChanged()">
                            </select>
                        </div>
                        <br />
                        Liste:
                        <ul id='lstFreitext'>
                        </ul>
                    </div>

                    <div id="symbolitems" style="height: 600px; overflow-y: scroll; background-color: beige; margin: 5px; padding: 8px; border-radius: 15px; display: none">
                        <p class="Title">Verweise</p>



                    </div>



                    <div>
                        <label id="tabLabel1" class="tablabelSelected" onclick="handleTabLabel(tabLabel1)">Werte</label>
                        <label id="tabLabel2" class="tablabel" onclick="handleTabLabel(tabLabel2)">Texte</label>
                        <input id="cbAlignItems" type="checkbox" checked>
                        <label id="lblAlignItems">alignItems</label>
                        <%--                        <label id="tabLabel3" class="tablabel" onclick="handleTabLabel(tabLabel3)">Verweise</label>--%>
                    </div>
                </div>



            </div>
            <div id="vimage" class="col-md-8" style="height: 640px">
                <div id="voutsideWrapper" class="container">
                    <div id="imgArea" class="vinsideWrapper">


                        <canvas id="myvCanvas" class="vcoveringCanvas" ondrop="drop(event)" ondragover="allowDrop(event)" ondragleave="leave(event)"></canvas>
                        <canvas id="tipCanvas" width="200" height="25"></canvas>
                    </div>

                </div>
            </div>

            <div class="col-md-2" style="left:100px;">
                <div style="height: 640px; background-color: lightsteelblue; padding: 5px; margin: 0px; border-radius: 15px;">
                    <div>
                    </div>
                    <div id="ImageSelect" class="imgSelect">
                        <p class="Title">Verfügbare Bitmaps</p>
                    </div>
                    <div id="Div1" class="imgSelect">
                        <p class="Title">Einstellungen</p>
                        <label style="padding-left: 20px; width: 110px">Schriftart:</label>
                        <select id="selFontfamily">
                            <option value="Arial">Arial</option>
                            <option value="Courier New">Courier New</option>
                            <option value="Verdana">Verdana</option>
                        </select>
                        <br />
                         <label style="padding-left: 20px; width: 110px">Schriftgröße:</label>
                       <select id="selSize">
                            <option value="8px ">8</option>
                            <option value="9px ">9</option>
                            <option value="10px ">10</option>
                            <option value="11px ">11</option>
                            <option value="12px " selected="selected">12</option>
                            <option value="13px ">13</option>
                            <option value="14px ">14</option>
                            <option value="16px ">16</option>
                            <option value="18px ">18</option>
                            <option value="20px ">20</option>
                            <option value="22px ">22</option>
                            <option value="24px ">24</option>
                        </select>
                        <br />
                        <label style="padding-left: 20px; width: 110px">Schriftfarbe:</label>
                        <select id="selColor">
                            <option value="red">rot</option>
                            <option value="black" selected="selected">schwarz</option>
                            <option value="blue">blau</option>
                            <option value="yellow">gelb</option>
                            <option value="#00c000 ">Wirtschaft</option>
                             <option value="#E0E0E0">zaehlerbg</option>

                        </select>
                        <br />


                        <label style="padding-left: 20px; width: 110px">Hintergrund:</label>
                        <select id="selBgCol">
                            <option value="transparent" selected="selected">transparent</option>
                            <option value="#1F94B9">EKH blau</option>
                            <option value="#C31D64">EKH rot</option>
                            <option value="slateBlue ">slateBlue </option>
                            <option value="#BEBEBE">bitmapbg</option>
                            <option value="#E0E0E0">zaehlerbg</option>
                            <option value="white">weiß</option>
                            <option value="grey">grau</option>
                            <option value="schwarz">schwarz</option>
                            <option value="red">rot</option>
                            <option value="blue">blau</option>
                            <option value="green">grün</option>
                            <option value="yellow">gelb</option>
                            <option value="lightcoral">lightcoral</option>
                            <option value="lightsalmon">lightsalmon</option>
                            <option value="cyan">cyan</option>
                            <option value="lightcyan">lightcyan</option>
                            <option value="hotpink">hotpink</option>
                            <option value="lightgreen">lightgreen</option>
                            <option value="lightSeaGreen ">lightSeaGreen </option>
                            <option value="yellowGreen">yellowGreen</option>
                            <option value="beige">beige</option>
                            <option value="lightblue">hellblau</option>
                            <option value="#ff9966">IPKamera</option>
                            <option value="#C0C0FF">sollwert</option>
                            <option value="#FFC0FF">Absenkung</option>
                        </select>
                        <br />
                    </div>
                    <div id="Div2" class="imgSelect">
                        <p class="Title">Positionen bearbeiten</p>

                        <p class="Hinweis">
                            EIntrag in Liste selektieren, um zu verschieben oder entfernen.
                        Pfeiltasten verwenden, um pixelweise zu verscheiben. Mit gedrückter Shift-Taste 
                        um je 5 Pixel verschieben. Mit "Entf" den markierten Eintrag löschen.
                        </p>
                    </div>
                    <div id="DivInfo" class="imgSelect">
                        <p class="Title">Markierter Eintrag - Eigenschaften</p>
                        <div style="width: 100px; float: left">Bezeichnung</div>
                        <div id="infoBez" style="">-</div>
                        <div style="width: 100px; float: left">Kanal</div>
                        <div id="infoKanal" style="">- </div>
                        <div style="width: 100px; float: left">Einheit</div>
                        <div id="infoEinheit" style="">- </div>
                        <div style="width: 100px; float: left">Tooltip</div>
                        <div id="infoTooltip" style="">- </div>
                        <div style="width: 100px; float: left">Kommentar</div>
                        <div id="infoKomm" style="">- </div>
                        <div style="width: 100px; float: left">ID</div>
                        <div id="infoID" style="">- </div>
                        <div style="width: 100px; float: left">Clickable</div>
                        <div id="infoClickable" style="">- </div>
                        <br />
                    </div>
                </div>
            </div>

        </div>
        <div class="row">
            <div class="col-md-12">
                <div id="Buttonbar" class="Buttonbar">

                    <%--                    Buttons
                    --%>
                    <input id="Button3" type="button" value="Update Visu" class="cmdButton" onclick="updateVisu()" />
                    <input id="Button4" type="button" value="Testen" class="cmdButton" onclick="testVisu()" />
                    <input id="Button5" type="button" value="Testdaten laden" class="cmdButton" onclick="getSampleData()" />
                    <input id="Button6" type="button" value="Shot speichern" class="cmdButton" onclick="saveSnapshot()" />
                    <input id="Button7" type="button" value="Shot laden" class="cmdButton" onclick="loadSnapshot()" />

                    <input id="Button8" type="button" value="Datei laden" class="cmdButton" onclick="loadFromFile()" />
                    <input id="Button9" type="button" value="Datei speichern" class="cmdButton" onclick="saveToFile()" />

                    <input id="Button1" type="button" value="Veröffentlichen" class="cmdButton" onclick="DeployVisu()" />


                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-12">
                <div id="output" class="Logging">
                </div>
            </div>
        </div>

    </div>

    <div id="iDiv" class="infoDiv">
        <br />
        <label id="xPos" style="padding-left: 20px; width: 80px"></label>
        <label id="yPos" style="width: 180px"></label>
        <br />
        <label style="padding-left: 20px; width: 80px">Einheit:</label>
        <label id="lblEinheit" style="width: 180px"></label>
        <br />

        <label style="padding-left: 20px; width: 80px">NK:</label>
        <label id="lblNK" style="width: 180px"></label>
        <br />

        <label style="padding-left: 20px; width: 80px">Bez:</label>
        <label id="lblBez" style="width: 180px"></label>
        <br />

        <label style="padding-left: 20px; width: 80px">Kanal:</label>
        <label id="lblKanal" style="width: 180px"></label>
        <br />

        <label style="padding-left: 20px; width: 80px">Bemerk.:</label>
        <label id="lblKomm" style="width: 180px"></label>
        <br />

         <label style="padding-left: 20px; width: 80px">ID:</label>
        <label id="lblID" style="width: 180px"></label>
        <br />

         <label style="padding-left: 20px; width: 80px">Clickable:</label>
        <label id="lblClickable" style="width: 180px"></label>
        
        <br />
    </div>

    <div id="EditSymbol" class="EditSymbol">
        <div id="eftDiv">
            <p class="Title">Symbol auswählen</p>
            <br />
            <input id="Radio1" name="rgSymbols" type="radio" value="BHKW" onclick="HandleSymbolFeatures(value)" checked />
            BHKW<br />
            <input id="Radio2" name="rgSymbols" type="radio" value="Feuer" onclick="HandleSymbolFeatures(value)" />
            Feuer<br />
            <input id="Radio3" name="rgSymbols" type="radio" value="Luefter" onclick="HandleSymbolFeatures(value)" />
            Lüfter<br />
            <input id="Radio4" name="rgSymbols" type="radio" value="Pumpe" onclick="HandleSymbolFeatures(value)" />
            Pumpe<br />
            <input id="Radio5" name="rgSymbols" type="radio" value="Led" onclick="HandleSymbolFeatures(value)" />
            Led<br />
            <input id="Radio11" name="rgSymbols" type="radio" value="Freitext" onclick="HandleSymbolFeatures(value)" />
            Freitext<br />
            <input id="Radio6" name="rgSymbols" type="radio" value="Ventil" onclick="HandleSymbolFeatures(value)" />
            Ventil<br />
            <input id="Radio8" name="rgSymbols" type="radio" value="hkTooltip" onclick="HandleSymbolFeatures(value)" />
            HKTooltip<br />
            <input id="Radio7" name="rgSymbols" type="radio" value="Absenkung" onclick="HandleSymbolFeatures(value)" />
            Absenkung<br />
            <input id="Radio9" name="rgSymbols" type="radio" value="Lueftungsklappe" onclick="HandleSymbolFeatures(value)" />
            Lueftungsklappe<br />
            <input id="Radio10" name="rgSymbols" type="radio" value="fpButton" onclick="HandleSymbolFeatures(value)" />
            Faceplate Button<br />
            <input id="Radio11" name="rgSymbols" type="radio" value="Schalter" onclick="HandleSymbolFeatures(value)" />
            Schalter<br />            
            <br />


            <select id="SelectSymbolFeature" class="SelectSymbolFeature">
            </select>
            <div id="divSymbolFeatureOptions">
                <input id="TextInputSymbolFeature" type="text"></input>
                <br/>
                <input id="cbInvertSymbolFeature" type="checkbox"></input>
                <label>lowActive?</label>
            </div>
            <br />
            <br />
            <label id="Label2" class="draglabel" onclick="drawSymbolAndFeature(null)" style="width: 180px">Übernehmen</label>
        </div>
    </div>

    <div id="EditToolTip" class="EditToolTip">
        <div id="ettDiv">
            <p class="Title">Tooltip bearbeiten</p>
            <br />
            <p>Tooltip-Text:</p>
            <input id="ToolTipText" type="text" style="width: 200px" />
            <br />
            <br />
            <label id="Label1" class="draglabel" onclick="ConfirmToolTip()" style="width: 90px;">Übernehmen</label>
            <label id="Label3" class="draglabel" onclick="location.href = '#'" style="width: 90px;">Abbrechen</label>
        </div>
    </div>



    <div id="SelectFile" class="SelectFile">
        <div id="selFile">
            <p class="Title">Datei laden</p>
            <br />
            <p>Verfügbare Visualisierungsdateien:</p>
            <select id="FileList" class="FileList">
            </select>
            <br />
            <br />
            <label id="Label4" class="draglabel" onclick="ConfirmFileSelection()" style="width: 90px;">Übernehmen</label>
            <label id="Label5" class="draglabel" onclick="location.href = '#'" style="width: 90px;">Abbrechen</label>
        </div>
    </div>

    <div id="SaveFile" class="SaveFile">
        <div id="saveFile">
            <p class="Title">Datei speichern</p>
            <br />
            <p>Dateiname:</p>

            <input id="saveFileName" type="text" style="width: 200px" />
            <br />
            <br />
            <label id="Label6" class="draglabel" onclick="ConfirmSaveFile()" style="width: 90px;">Übernehmen</label>
            <label id="Label7" class="draglabel" onclick="location.href = '#'" style="width: 90px;">Abbrechen</label>
        </div>
    </div>

    <div id="dummy_txt" style="display: none;"></div>
    <div id="dummy" style="display: none;"></div>
</asp:Content>



