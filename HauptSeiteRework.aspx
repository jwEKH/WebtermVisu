<%@ Page Title="" Language="C#" MasterPageFile="~/Wide2.Master" Async="true" AutoEventWireup="true" CodeBehind="HauptSeiteRework.aspx.cs" Inherits="WebAppJanStyle1.HauptSeiteRework" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="Content/bootstrap5.min.css" rel="stylesheet" />
    <style>

        #userDivWrapper{
            padding-top: 10px;
            padding-bottom: 15px;
        }

        .modal {
            display: none; /* Hidden by default */
            position: fixed; /* Stay in place */
            z-index: 1; /* Sit on top */
            left: 0px;
            top: 0px;
            width: 100%; /* Full width */
            height: 100%;
            overflow: auto; /* Enable scroll if needed */
            background-color: #f2f2f2;
            opacity:0.9;
        }

        .modal-content {
	    width:30%;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) !important;
             /*-webkit-animation-name: animatetop;
            -webkit-animation-duration: 0.4s;
            animation-name: animatetop;
            animation-duration: 0.4s*/
        }

        /* Add Animation */
        @-webkit-keyframes animatetop {
            from {top:-300px; opacity:0} 
            to {top:0; opacity:1}
        }

        @keyframes animatetop {
            from {top:-300px; opacity:0}
            to {top:0; opacity:1}
        }

        /*equivalent to "btn default" in boostrap3 */
        .btn-default {
            color: #333;
            background-color: #fff;
            border-color: #ccc;
        }
        .btn-default:focus {
            color: #333;
            background-color: #e6e6e6;
            border-color: #8c8c8c;
        }
        .btn-default:hover {
            color: #333;
            background-color: #e6e6e6;
            border-color: #adadad;
        }
        .btn-default:active {
            color: #333;
            background-color: #e6e6e6;
            border-color: #adadad;
        }
        .mousePointer{
            cursor: pointer
        }

    </style>

    <script src="Scripts/jquery-3.5.1.min.js"></script>
    <script>
        var Steuerungen;
        var isAscending = true;
        var role;
        var isAdmin;
        var userName;
        var ipe;
        var ftppwd;

        $('document').ready(function () {
            Steuerungen = JSON.parse(getSteuerungForUser());
            role = getUserRole();
            userName = getUserName();
            isAdmin = checkUserRole();
            /*Steuerungen = JSON.parse(getAllUserConfig());*/
            displayAllSteuerungen(Steuerungen);
            steuerungSearchBox = document.getElementById('searchSteuerung');
            steuerungSearchBox.addEventListener('keypress', function (event) { if (event.which == '13') { event.preventDefault(); } });
            steuerungSearchBox.addEventListener('keyup', searchSteuerung);
            var lastSearchKeyword = steuerungSearchBox.value;
            if (lastSearchKeyword != "") {
                var $steuerungCells = $("#displayTableBody td");
                var val = lastSearchKeyword.toUpperCase();
                $steuerungCells.parent().hide();
                $steuerungCells.filter(function () {
                    return -1 != $(this).text().toUpperCase().indexOf(val);
                }).parent().show();
            }
            ftppwd = getRTOSFTPPwd();

        });


        function searchSteuerung() {

            //clear sessionStorage, which is currently use for saving search results
            //window.sessionStorage.clear();

            //searching
            var $steuerungCells = $("#displayTableBody td");
            var val = $.trim(this.value).toUpperCase();
            if (val === "")
                $steuerungCells.parent().show();
            else {
                $steuerungCells.parent().hide();
                $steuerungCells.filter(function () {
                    return -1 != $(this).text().toUpperCase().indexOf(val);
                }).parent().show();
            }

            //save search result in sessionStorage
            //window.sessionStorage.setItem('searchResult',)
        }
        function displayAllSteuerungen(Steuerungen) {
            var table = document.getElementById('displayTableBody');
            table.innerHTML = "";
            for (var i = 0; i < Steuerungen.length; i++) {
                var ProjektNummer = Steuerungen[i].Name.toUpperCase();
                ipe = Steuerungen[i]['networkInformationen']['PrimaryIP'];
                var vpnGatewayType = Steuerungen[i]['networkInformationen']['VPNGatewayType'];

                if (vpnGatewayType != "SSV") {
                    vpnGatewayType = 'Teltonika';
                }
                var row = document.createElement('tr');
                row.id = ProjektNummer;

                //var cell0 = document.createElement('td');
                //var lblNummerierung = document.createElement('label');
                //lblNummerierung.innerHTML = i + 1;
                //cell0.appendChild(lblNummerierung);
                //row.appendChild(cell0);

                var cell1 = document.createElement('td');
                var lblProjektNummer = document.createElement('label');
                lblProjektNummer.innerHTML = ProjektNummer.toUpperCase();
                cell1.appendChild(lblProjektNummer);
                row.appendChild(cell1);

                var cell2 = document.createElement('td');
                var lblProjektName = document.createElement('label');
                lblProjektName.innerHTML = Steuerungen[i].Bezeichnung;
                cell2.appendChild(lblProjektName);
                row.appendChild(cell2);

                var cell3 = document.createElement('td');
                if (Steuerungen[i].permission.term) {
                    var btnFernbedienung = document.createElement('button');
                    btnFernbedienung.type = "button";
                    /*btnFernbedienung.value = "Fernbedienung";*/
                    btnFernbedienung.innerHTML = "Fernbedienung";
                    btnFernbedienung.id = ProjektNummer + 'fernbedienung';
                    btnFernbedienung.addEventListener('click', OpenModal)
                    btnFernbedienung.addEventListener('click', openWT)
                    btnFernbedienung.classList.add('btn');
                    btnFernbedienung.classList.add('btn-default');
                    cell3.appendChild(btnFernbedienung);
                }
                row.appendChild(cell3);

                var cell4 = document.createElement('td');
                if (Steuerungen[i].permission.qh) {
                    var btnQhData = document.createElement('input');
                    btnQhData.type = "button";
                    btnQhData.value = "1/4h Daten";
                    btnQhData.id = ProjektNummer + 'qhData';
                    btnQhData.addEventListener('click', openQHView)
                    btnQhData.classList.add('btn');
                    btnQhData.classList.add('btn-default');
                    cell4.appendChild(btnQhData);
                }
                row.appendChild(cell4);

                var cell5 = document.createElement('td');
                if (Steuerungen[i].permission.visu) {
                    var btnVisu = document.createElement('input');
                    btnVisu.type = "button";
                    btnVisu.value = "Visualisierung";
                    btnVisu.id = ProjektNummer + 'visualisierung';
                    btnVisu.addEventListener('click', openVisu)
                    btnVisu.classList.add('btn');
                    btnVisu.classList.add('btn-default');
                    cell5.appendChild(btnVisu);
                }
                row.appendChild(cell5);


                var cell7 = document.createElement('td');
                if (role != "Gast") {
                    var btnAktuelleStoerung = document.createElement('input');
                    btnAktuelleStoerung.type = "button";
                    btnAktuelleStoerung.value = "akt. Störung";
                    btnAktuelleStoerung.id = ProjektNummer + ':' + Steuerungen[i].Bezeichnung;
                    if (Steuerungen[i].gestoert) {
                        btnAktuelleStoerung.classList.add('btn');
                        btnAktuelleStoerung.classList.add('btn-warning');
                    }
                    else {
                        btnAktuelleStoerung.classList.add('btn');
                        btnAktuelleStoerung.classList.add('btn-default');
                    }
                    btnAktuelleStoerung.addEventListener('click', OpenStoerungsModal)
                    cell7.appendChild(btnAktuelleStoerung);
                }
                row.appendChild(cell7);

                var cell8 = document.createElement('td');
                if (role != "Gast") {
                    var btnZuletztGesehen = document.createElement('input');
                    btnZuletztGesehen.type = "button";
                    btnZuletztGesehen.id = ProjektNummer + 'zuletztgemeldet';
                    btnZuletztGesehen.classList.add('btn');
                    btnZuletztGesehen.disabled = true;

                    btnZuletztGesehen.value = Steuerungen[i].lastSeen;
                    var reggie = /(\d{2}).(\d{2}).(\d{4}) (\d{2}):(\d{2}):(\d{2})/;
                    var dateArray = reggie.exec(Steuerungen[i].lastSeen);
                    var lastseen = new Date(
                        (+dateArray[3]),
                        (+dateArray[2]) - 1, // month starts at 0!
                        (+dateArray[1]),
                        (+dateArray[4]),
                        (+dateArray[5]),
                        (+dateArray[6])
                    );
                    var timespan = new Date() - lastseen;
                    if (timespan > 86400000) { // 1 day in milliseconds
                        /*btnZuletztGesehen.classList.add('btn-warning');*/
                        if (timespan > 604800000) { // 1 week in milliseconds
                            btnZuletztGesehen.classList.add('btn-danger');
                        }
                    }

                    else {
                        btnZuletztGesehen.classList.add('btn-outline-info');
                    }
                    cell8.appendChild(btnZuletztGesehen);
                }
                row.appendChild(cell8);


                var cell9 = document.createElement('td');
                if (role != "Gast") {
                    //create outerdiv for dropdownlist
                    var div = document.createElement('div');
                    div.classList.add('dropdown');

                    //create button and using as dropdown eintry
                    var dropdownButon = document.createElement('button');
                    dropdownButon.type = "button";
                    dropdownButon.id = ProjektNummer + 'dropdown';
                    dropdownButon.classList.add('btn');
                    dropdownButon.classList.add('btn-secondary');
                    dropdownButon.classList.add('dropdown-toggle');
                    dropdownButon.setAttribute("data-bs-toggle", "dropdown");
                    dropdownButon.setAttribute("aria-expanded", "false");
                    dropdownButon.innerHTML = "Anlagenspezifisches";

                    //create unlisted element as wrapper for listed element
                    var ul = document.createElement('ul');
                    ul.classList.add('dropdown-menu');
                    ul.setAttribute("aria-labelledby", dropdownButon.id);

                    //create nested listed element of unlisted element above
                    var liVerdrahtungsplan = document.createElement('li');

                    //create a tag inside the listed element
                    //a tag come with onlick event for the coresspondent task such as viewpdf, redirect to stoerung configuration ...

                    //Eintrag for Verdrahtungsplan
                    var atagVerdrahtungsplan = document.createElement('a');
                    atagVerdrahtungsplan.innerHTML = "Verdrahtungsplan";
                    atagVerdrahtungsplan.id = ProjektNummer + "verdrahtungsplan";
                    atagVerdrahtungsplan.addEventListener('click', viewPDF);
                    atagVerdrahtungsplan.classList.add('dropdown-item');
                    atagVerdrahtungsplan.setAttribute("href", '#');
                    liVerdrahtungsplan.appendChild(atagVerdrahtungsplan);
                    ul.appendChild(liVerdrahtungsplan);

                    //Eintrag für Bedienungsanleitung
                    var liBedienungsanleitung = document.createElement('li');
                    var atagBedienungsAnleitung = document.createElement('a');
                    atagBedienungsAnleitung.innerHTML = "Bedienungsanleitung";
                    atagBedienungsAnleitung.id = ProjektNummer + "bedienungsanleitung";
                    atagBedienungsAnleitung.addEventListener('click', viewPDF);
                    atagBedienungsAnleitung.classList.add('dropdown-item');
                    atagBedienungsAnleitung.setAttribute("href", '#');

                    liBedienungsanleitung.appendChild(atagBedienungsAnleitung);
                    ul.appendChild(liBedienungsanleitung);


                    //Eintrag für stoerung konfiguration

                    var liStoerungKonfiguration = document.createElement('li');
                    var atagStoerungKonfiguration = document.createElement('a');
                    atagStoerungKonfiguration.innerHTML = "Störungskonfiguration";
                    atagStoerungKonfiguration.id = ProjektNummer + "stoerungkonfig";
                    atagStoerungKonfiguration.addEventListener('click', openStoerungKonfig);
                    atagStoerungKonfiguration.classList.add('dropdown-item');
                    atagStoerungKonfiguration.setAttribute("href", '#');
                    liStoerungKonfiguration.appendChild(atagStoerungKonfiguration);
                    ul.appendChild(liStoerungKonfiguration);

                    //Eintrag für Bearbeitung
                    var liNotiz = document.createElement('li');
                    var atagNotiz = document.createElement('a');
                    atagNotiz.innerHTML = "Notiz Bearbeitung";
                    atagNotiz.id = ProjektNummer + "notizbearbeitung";
                    atagNotiz.addEventListener('click', openNote);
                    atagNotiz.classList.add('dropdown-item');
                    atagNotiz.setAttribute("href", '#');
                    liNotiz.appendChild(atagNotiz);
                    ul.appendChild(liNotiz);

                    //Eintrag für Anlagen Administration
                    var liAdministration = document.createElement('li');
                    var atagAdministration = document.createElement('a');
                    atagAdministration.innerHTML = "Administration";
                    atagAdministration.id = ProjektNummer + "administration";
                    /*atagAdministration.addEventListener('click', '');*/
                    atagAdministration.classList.add('dropdown-item');
                    atagAdministration.setAttribute("href", 'AnlageAdministration.aspx' + '?Id=' + ProjektNummer);
                    atagAdministration.setAttribute("target", '_blank');
                    liAdministration.appendChild(atagAdministration);
                    ul.appendChild(liAdministration);

                    div.appendChild(dropdownButon);
                    div.appendChild(ul);
                    cell9.appendChild(div);
                }
                row.appendChild(cell9);

                var cell10 = document.createElement('td');
                if (role == 'Admin') {
                    var btnProjektVerwaltung = document.createElement('button');
                    btnProjektVerwaltung.type = "button";
                    btnProjektVerwaltung.innerHTML = "Projektverlauf";
                    btnProjektVerwaltung.id = ProjektNummer + 'projektVerwaltung';
                    btnProjektVerwaltung.addEventListener('click', openProjektVerwaltung)
                    btnProjektVerwaltung.classList.add('btn');
                    btnProjektVerwaltung.classList.add('btn-default');
                    cell10.appendChild(btnProjektVerwaltung);
                }
                row.appendChild(cell10);


                var cell6 = document.createElement('td');
                if (isAdmin) {
                    var div = document.createElement('div');
                    div.classList.add('dropdown');

                    //create button and using as dropdown eintry
                    var dropdownButon = document.createElement('button');
                    dropdownButon.type = "button";
                    dropdownButon.id = ProjektNummer + 'dropdown';
                    dropdownButon.classList.add('btn');
                    dropdownButon.classList.add('btn-secondary');
                    dropdownButon.classList.add('dropdown-toggle');
                    dropdownButon.setAttribute("data-bs-toggle", "dropdown");
                    dropdownButon.setAttribute("aria-expanded", "false");
                    dropdownButon.innerHTML = "Networking Tool";

                    //create unlisted element as wrapper for listed element
                    var ul = document.createElement('ul');
                    ul.classList.add('dropdown-menu');
                    ul.setAttribute("aria-labelledby", dropdownButon.id);
                    ul.id = ipe;

                    //create nested listed element of unlisted element above
                    var liVPNGateway = document.createElement('li');

                    //create a tag inside the listed element
                    //a tag come with onlick event for the coresspondent task such as viewpdf, redirect to stoerung configuration ...

                    //Eintrag für Verdrahtungsplan
                    var atagVPNGateway = document.createElement('a');
                    atagVPNGateway.innerHTML = "VPN Gateway";
                    atagVPNGateway.addEventListener('click', openVPNGateway);
                    atagVPNGateway.classList.add('dropdown-item');
                    atagVPNGateway.classList.add(vpnGatewayType);
                    atagVPNGateway.setAttribute("href", '#');
                    liVPNGateway.appendChild(atagVPNGateway);
                    ul.appendChild(liVPNGateway);

                    //Eintrag für Bedienungsanleitung
                    var liSSHVPNGateway = document.createElement('li');
                    var atagSSHVPNGateway = document.createElement('a');
                    atagSSHVPNGateway.innerHTML = "SSH RUT";
                    atagSSHVPNGateway.addEventListener('click', openSSHVPNGateway);
                    atagSSHVPNGateway.classList.add('dropdown-item');
                    atagSSHVPNGateway.setAttribute("href", '#');

                    liSSHVPNGateway.appendChild(atagSSHVPNGateway);
                    ul.appendChild(liSSHVPNGateway);

                    //Eintrag für Anlage mit PanelPC
                    if (Steuerungen[i].hasPC ) {
                        var liPanelPC = document.createElement('li');
                        var atagPanelPC = document.createElement('a');
                        atagPanelPC.innerHTML = "Teamviewer VPN";
                        atagPanelPC.addEventListener('click', openTeamviewer);
                        atagPanelPC.classList.add('dropdown-item');
                        atagPanelPC.setAttribute("href", '#');

                        liPanelPC.appendChild(atagPanelPC);
                        ul.appendChild(liPanelPC);
                    }

                    //Eintrag für stoerung konfiguration
                    if (ProjektNummer.indexOf('P2') >= 0) {
                        var liSSHPi = document.createElement('li');
                        var atagSSHPi = document.createElement('a');
                        atagSSHPi.innerHTML = "SSH Pi";
                        atagSSHPi.addEventListener('click', openSSHPi);
                        atagSSHPi.classList.add('dropdown-item');
                        atagSSHPi.setAttribute("href", '#');
                        liSSHPi.appendChild(atagSSHPi);
                        ul.appendChild(liSSHPi);

                        //Eintrag für Bearbeitung
                        var liFTPRtos = document.createElement('li');
                        var atagFTPRtos = document.createElement('a');
                        atagFTPRtos.innerHTML = "FTP RTOS";
                        atagFTPRtos.addEventListener('click', openFTPRtos);
                        atagFTPRtos.classList.add('dropdown-item');
                        atagFTPRtos.setAttribute("href", '#');
                        liFTPRtos.appendChild(atagFTPRtos);
                        ul.appendChild(liFTPRtos);

                        var liTeamviewerVPN = document.createElement('li');
                        var atagTeamviewerVPN = document.createElement('a');
                        atagTeamviewerVPN.innerHTML = "Teamviewer VPN";
                        atagTeamviewerVPN.addEventListener('click', openTeamviewer);
                        atagTeamviewerVPN.classList.add('dropdown-item');
                        atagTeamviewerVPN.setAttribute("href", '#');
                        liTeamviewerVPN.appendChild(atagTeamviewerVPN);
                        ul.appendChild(liTeamviewerVPN);

                        var liVNCViewer = document.createElement('li');
                        var atagVNCViewer = document.createElement('a');
                        atagVNCViewer.innerHTML = "VNC Viewer";
                        atagVNCViewer.addEventListener('click', openVNCViewer);
                        atagVNCViewer.classList.add('dropdown-item');
                        atagVNCViewer.setAttribute("href", '#');
                        liVNCViewer.appendChild(atagVNCViewer);
                        ul.appendChild(liVNCViewer);
                    }
                    div.appendChild(dropdownButon);
                    div.appendChild(ul);
                    cell6.appendChild(div);
                }
                row.appendChild(cell6);
                table.appendChild(row);
            }

        }

        function openVPNGateway() {
            var ip = this.offsetParent.id;
            if (this.classList.contains("SSV")) {
                ip = ip + ':7777';
            }
            else {
                ip = ip;
            }
            window.open('http://' + ip);
        }
        function openSSHVPNGateway() {
            var ip = this.offsetParent.id;
            document.location = "ssh://" + "root@" + ip;

        }
        function openSSHPi() {
            var ip = this.offsetParent.id;
            document.location = "ssh://" + "pi@" + ip + ":2222";

        }
        function openFTPRtos() {
            var ip = this.offsetParent.id;
            document.location = "ftp://" + "admin" + ":" + ftppwd + "@" + ip + "/";
        }
        function openTeamviewer() {
            var ip = this.offsetParent.id;
            document.location = "tvcontrol1://control?device=" + ip;
        }

        function openVNCViewer() {
            var ip = this.offsetParent.id;
            var test = "vnc://" + ip;
            document.location = "vnc://" + ip;
        }

        function openWT() {

            window.open('/WebTerm.aspx?Id=' + this.id.substring(0, 5), '_self', '', 'true')
        }

        function openQHView() {
            window.open('/QHView.aspx?Id=' + this.id.substring(0, 5) + '', '', 'width=1135, height=800, titlebar = no, toolbar = no, location = no, status = no, menubar = no')
        }

        function openVisu() {
            window.open(`/VisuView${(checkUserRole()) ? /*'Admin'*/'' : ''}.aspx?Id=${this.id.substring(0, 5)}`, '', 'width=1300, height=820, location = yes,scrollbars = yes')
        }

        function openProjektVerwaltung() {
            window.open('https://projekt.energiekontor-hannover.de/projects/' + this.id.substring(0, 5).replace(' ', '').toLowerCase() + '/work_packages?query_props=%7B%22c%22%3A%5B%22id%22%2C%22subject%22%2C%22type%22%2C%22status%22%2C%22priority%22%2C%22author%22%2C%22assignee%22%2C%22updatedAt%22%2C%22createdAt%22%5D%2C%22hi%22%3Atrue%2C%22g%22%3A%22%22%2C%22is%22%3Atrue%2C%22tv%22%3Afalse%2C%22hla%22%3A%5B%22status%22%2C%22priority%22%2C%22dueDate%22%5D%2C%22t%22%3A%22id%3Aasc%22%2C%22f%22%3A%5B%7B%22n%22%3A%22status%22%2C%22o%22%3A%22*%22%2C%22v%22%3A%5B%5D%7D%5D%2C%22pp%22%3A20%2C%22pa%22%3A1%7D');

        }

        function openNote() {
            window.open('/NoteEdit.aspx?Id=' + this.id.substring(0, 5) + '', '', 'width=1135, height=800')

        }
        function openVPNWebConfig(steuerung) {
            window.open('http://' + steuerung + '', '', 'width=1135, height=800')
        }

        function openNportWebConfig(steuerung) {
            window.open('http://' + steuerung + '', '', 'width=1135, height=800')
        }

        function openStoerungKonfig() {
            window.open('/EditStoerungConfig.aspx?Id=' + this.id.substring(0, 5), '_blank');
            /*var stoeUrl = "/EditStoerungConfig.aspx?ID=" + this.id.substring(0, 5);*/
            /*window.location = stoeUrl;*/

        }

        function OpenModal() {
            var modal = document.getElementById('myModal');
            modal.style.display = "block";
        }


        function OpenStoerungsModal() {
            //get Störungen
            projektNr = this.id;
            var prj = projektNr.substring(0, projektNr.indexOf(":"));
            var prjName = projektNr.substring(projektNr.indexOf(":") + 1);
            var modal = document.getElementById('stoerungModal');
            var Stoerungen = getStoerungsOnline(prj);
            if (Stoerungen != "false") {
                if (Stoerungen == "") {
                    document.getElementById("stoerungModalHeader").innerHTML = '<h4> Aktuelle Störungen der Anlage: ' + prjName;
                    document.getElementById("stoerungModalBody").innerHTML = "Aktuell stehen keine Störungen an!";
                    var btnClose = document.getElementById("btncloseStoerungModal");
                    btnClose.onclick = function () {
                        modal.style.display = "none";
                    }
                }
                else {
                    document.getElementById("stoerungModalHeader").innerHTML = '<h4> Aktuelle Störungen der Anlage: ' + prjName;
                    document.getElementById("stoerungModalBody").innerHTML = Stoerungen;
                    var btnClose = document.getElementById("btncloseStoerungModal");
                    btnClose.onclick = function () {
                        modal.style.display = "none";
                    }
                }
            }
            else {
                document.getElementById("stoerungModalHeader").innerHTML = '<h4> Aktuelle Störungen der Anlage: ' + prjName;
                document.getElementById("stoerungModalBody").innerHTML = "Es kann aktuell keine Störungen abgeholt werden.";
                var btnClose = document.getElementById("btncloseStoerungModal");
                btnClose.onclick = function () {
                    modal.style.display = "none";
                }
            }
            modal.style.display = "block";
        }

        function getRTOSFTPPwd() {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/RtosFtpPwd",
                data: '{ProjektNummer: ' + "'" + Steuerungen + "'" + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    res = response.d;
                    /*log("getOnlineData ok");*/
                    //res = r;
                },
                complete: function (xhr, status) {
                    /*log("getOnlineData complete");*/
                },
                error: function (msg) {
                    /*log("getOnlineData fail: " + msg);*/
                }
            });

            return res;
        }

        function getIPE(prj) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getIPEFromProjektnummer",
                data: '{ProjektNummer: ' + "'" + prj + "'" + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    res = response.d;
                    /*log("getOnlineData ok");*/
                    //res = r;
                },
                complete: function (xhr, status) {
                    /*log("getOnlineData complete");*/
                },
                error: function (msg) {
                    /*log("getOnlineData fail: " + msg);*/
                }
            });

            return res;
        }



        function getStoerungsOnline(prj) {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getStoerungsOnline",
                data: '{Projektnummer: ' + "'" + prj + "'" + '}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    res = response.d;
                    /*log("getOnlineData ok");*/
                    //res = r;
                },
                complete: function (xhr, status) {
                    /*log("getOnlineData complete");*/
                },
                error: function (msg) {
                    /*log("getOnlineData fail: " + msg);*/
                }
            });

            return res;
        }

        function getSteuerungForUser() {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getSteuerungForUser",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    res = response.d;
                    /*log("getOnlineData ok");*/
                    //res = r;
                },
                complete: function (xhr, status) {
                    /*log("getOnlineData complete");*/
                },
                error: function (msg) {
                    /*log("getOnlineData fail: " + msg);*/
                }
            });

            return res;
        }


        function getUserName() {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getUserName",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var r = response.d;
                    //console.log("getRole ok");
                    res = r;
                },
                complete: function (xhr, status) {
                    //console.log("getRole complete");
                },
                error: function (msg) {
                    //console.log("getRole fail: " + msg);
                }
            });
            return res;
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

        function getUserRole() {
            var res;
            $.ajax({
                type: "POST",
                url: "WebServiceEK.asmx/getRole",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var r = response.d;
                    //console.log("getRole ok");
                    res = r;
                },
                complete: function (xhr, status) {
                    //console.log("getRole complete");
                },
                error: function (msg) {
                    //console.log("getRole fail: " + msg);
                }
            });
            return res;
        }

        // When the user clicks anywhere outside of the modal, close it
        //window.onclick = function (event) {
        //    if (event.target == stoerungModal) {
        //        stoerungModal.style.display = "none";
        //    }
        //}

        function viewPDF() {
            var info = this.id;
            var projektNummer = info.substring(0, 5).toUpperCase();
            var name = info.substring(5);
            if (name == 'bedienungsanleitung') {
                var url = '/web/viewer.html?file=/Bedienungsanleitung/' + projektNummer + '.pdf' + '?' + Date.now();
                window.open(url);
            }
            if (name == 'verdrahtungsplan') {
                var url = '/web/viewer.html?file=/Verdrahtungsplan/' + projektNummer + '.pdf' + '?' + Date.now();
                window.open(url);
            }
        }

        function sortByProjektNummer() {
            var sortedSteuerung = Steuerungen.sort(comparePrjNr);
            displayAllSteuerungen(sortedSteuerung);
            isAscending = !isAscending;
        }
        function sortByProjektName() {
            var sortedSteuerung = Steuerungen.sort(compareName);
            displayAllSteuerungen(sortedSteuerung);
            isAscending = !isAscending;
        }
        function sortByStoerung() {
            var sortedSteuerung = Steuerungen.sort(compareStoerung);
            displayAllSteuerungen(sortedSteuerung);
            isAscending = !isAscending;
        }
        function sortByLetzteMeldung() {
            var sortedSteuerung = Steuerungen.sort(compareLetzteMeldung);
            displayAllSteuerungen(sortedSteuerung);
            isAscending = !isAscending;
        }

        function comparePrjNr(a, b) {
            if (isAscending) {
                if (a.Name.toUpperCase() < b.Name.toUpperCase()) {
                    return -1;
                }
                if (a.Name.toUpperCase() > b.Name.toUpperCase()) {
                    return 1;
                }
            }
            else {
                if (a.Name.toUpperCase() > b.Name.toUpperCase()) {
                    return -1;
                }
                if (a.Name.toUpperCase() < b.Name.toUpperCase()) {
                    return 1;
                }
            }

            return 0;
        }

        function compareName(a, b) {
            if (isAscending) {
                if (a.Bezeichnung.toUpperCase() < b.Bezeichnung.toUpperCase()) {
                    return -1;
                }
                if (a.Bezeichnung.toUpperCase() > b.Bezeichnung.toUpperCase()) {
                    return 1;
                }
            }
            else {
                if (a.Bezeichnung.toUpperCase() > b.Bezeichnung.toUpperCase()) {
                    return -1;
                }
                if (a.Bezeichnung.toUpperCase() < b.Bezeichnung.toUpperCase()) {
                    return 1;
                }
            }

            return 0;
        }

        function compareStoerung(a, b) {
            if (isAscending) {
                if (a.gestoert < b.gestoert) {
                    return 1;
                }
                if (a.gestoert > b.gestoert) {
                    return -1;
                }
            }
            else {
                if (a.gestoert > b.gestoert) {
                    return 1;
                }
                if (a.gestoert < b.gestoert) {
                    return -1;
                }
            }
            return 0;
        }

        function compareLetzteMeldung(a, b) {

            /*Parse string to dateTime object in javascript and  compare
             * 
             * "07.02.2022 14:29:44" Day Month Year Hour Minute Secons*/
            var reggie = /(\d{2}).(\d{2}).(\d{4}) (\d{2}):(\d{2}):(\d{2})/;
            var firstDateArray = reggie.exec(a.lastSeen);
            var firstDate = new Date(
                (+firstDateArray[3]),
                (+firstDateArray[2]) - 1, // Careful, month starts at 0!
                (+firstDateArray[1]),
                (+firstDateArray[4]),
                (+firstDateArray[5]),
                (+firstDateArray[6])
            );

            var secondDateArray = reggie.exec(b.lastSeen);
            var secondDate = new Date(
                (+secondDateArray[3]),
                (+secondDateArray[2]) - 1, // Careful, month starts at 0!
                (+secondDateArray[1]),
                (+secondDateArray[4]),
                (+secondDateArray[5]),
                (+secondDateArray[6])
            );

            if (isAscending) {
                if (firstDate.getTime() > secondDate.getTime()) {
                    return -1;
                }
                if (firstDate.getTime() < secondDate.getTime()) {
                    return 1;
                }
            }
            else {
                if (firstDate.getTime() > secondDate.getTime()) {
                    return 1;
                }
                if (firstDate.getTime() < secondDate.getTime()) {
                    return -1;
                }
            }
            return 0;
        }
    </script>
</asp:Content>

<asp:Content ID="Content2"  ContentPlaceHolderID="CPH_Form" runat="server">
    <div id="userDivWrapper">
        <input type="text" id="searchSteuerung"class="form-control" placeholder="Steuerung suchen..." />
    </div>

        <table id="steuerungTabelle" class="table table-striped" style="margin-bottom:60px;">
          <thead>
            <tr>
              <%--<th id="number" class=""  scope="col">#</th>  --%>
              <th id="colPrjNr" class="mousePointer" onclick="sortByProjektNummer()" scope="col">PrjNr. &#8645;</th>
              <th id="colPrjName" class="mousePointer" onclick="sortByProjektName()" scope="col">Projektname &#8645;</th>
              <th scope="col">Fernbedienung</th>
              <th scope="col">1/4h Daten</th>
              <th scope="col">Visualisierung</th>
             <%-- <th scope="col">Störungskonfiguration</th>--%>
              <th id="colStoerung" class="mousePointer" onclick="sortByStoerung()" scope="col">Aktuelle Störungen &#8645;</th>
              <th id="colLetzeMeldung"  class="mousePointer" onclick="sortByLetzteMeldung()" scope="col">Zuletzt gemeldet &#8645;</th>
              <th scope="col">Anlagenspezifisches</th>
            </tr>
          </thead>
          <tbody id="displayTableBody">

          </tbody>
        </table>
 
        <!-- Stoerung Modal -->
        <div id="stoerungModal" class="modal">
          <!-- Modal content -->
          <div class="modal-content">
            <div id="stoerungModalHeader" class="modal-header">
            </div>
            <div id="stoerungModalBody" class="modal-body">
            </div>
            <div class="modal-footer">
                <button id="btncloseStoerungModal" type="button" class="btn btn-info">Schließen</button>
            </div>
          </div>
        </div>

            <!-- Verbindung Modal -->
        <div id="myModal" class="modal">
            <div class="modal-content">

                <div class="modal-body">
                    <p>Verbindung wird hergestellt....... Bitte warten</p>
                    <div class="progress" style="margin-bottom: 0;">
                        <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar" aria-valuenow="100" style="width: 100%"></div>
                    </div>
                </div>
            </div>
        </div>

</asp:Content>
