
let OurUser = null;
let OurSite = null;
var BackendHelper = null;

let SeasonFirstDate = null;
let SeasonLastDate = null;

// This loads the UI with the defaults for the various controls
$( document ).ready(function() {
    PageInit()
    .catch(function (error) {
        console.log(error);
    })
});

async function PageInit() {
    BackendHelper = new C_BackendHelper();
    await BackendHelper.Initialize();
    await BackendHelper.LoadAllUsers();

    if (BackendHelper.UserCredentials.IsValidCredential())
        OurUser = await BackendHelper.DoLogin(BackendHelper.UserCredentials.Email, BackendHelper.UserCredentials.Password);

    if (OurUser !== null)
        $("span#vitasa_username")[0].innerText = BackendHelper.UserCredentials.Name;

    let hrefs = window.location.href.split('?');
    let siteslugs = hrefs[1].split('=');
    let oursiteslug = siteslugs[1];
    if (oursiteslug.endsWith('#'))
        oursiteslug = oursiteslug.substr(0, oursiteslug.length - 1);

    OurSite = BackendHelper.FindSiteBySlug(oursiteslug);

    $('#vitasa_adminsitescal_sitename')[0].innerText = OurSite.Name;
    $('button#vitasa_adminsitecalreset_firstdate')[0].innerText = 'From: ' + BackendHelper.Filter.SeasonFirstDate.toString();
    $('button#vitasa_adminsitecalreset_lastdate')[0].innerText = 'To: ' + BackendHelper.Filter.SeasonLastDate.toString();

    SeasonFirstDate = BackendHelper.Filter.SeasonFirstDate;
    SeasonLastDate = BackendHelper.Filter.SeasonLastDate;

    DrawAdminSiteCalResetTable();
}

function DrawAdminSiteCalResetTable() {
    for(let dow = 0; dow !== 7; dow++) {
        AdminSiteCalResetRow(dow);
    }
}

// function ClearAdminSiteCalResetTable() {
//     $('#vitasa_adminsitecalreset_table_tbody')[0].innerHTML = '';
// }

OpenTimeHoursDropDownList = [];
OpenTimeMinuteDropDownList = [];
OpenTimeAMPMDropDownList = [];
CloseTimeHoursDropDownList = [];
CloseTimeMinuteDropDownList = [];
CloseTimeAMPMDropDownList = [];
let DropDownListIndex = 0;

function AdminSiteCalResetRow(dow) {
    // () Site is Open    Open: 08^ 00^ AM    Close 01^ 30^ PM
    let cols = '<td>';

    cols += '<strong>' + DayOfWeekNames[dow] + '</strong> <br/>';

    cols += '<div class="custom-control custom-checkbox">';
    cols += '&nbsp;<input type="checkbox" class="custom-control-input" id="vitasa_adminsitecalreset_cb_' + dow.toString() + '">';
    cols += '<label class="custom-control-label" for="vitasa_adminsitecalreset_cb_' + dow.toString() + '">Site Is Open</label>';
    cols += '</div>';

    cols +=
        '            <div class="btn-group" style="cursor: pointer;">' +
        '                <span class="modal-title">&nbsp;Open Time: &nbsp; &nbsp;</span>' +
        '                <div class="dropdown btn-light">' +
        '                    <div class="dropdown-toggle" data-toggle="dropdown">' +
        '                        <span id="vitasa_opentime_hours_button_' + dow.toString() + '">Hour</span><span class="caret"></span>' +
        '                    </div >' +
        '                    <div class="dropdown-menu" id="vitasa_opentime_hours_' + dow.toString() + '">' +
        '                    </div>' +
        '                </div>' +
        '                <span class="modal-title">&nbsp;:&nbsp;</span>' +
        '                <div class="dropdown btn-light">' +
        '                    <div class="dropdown-toggle" data-toggle="dropdown">' +
        '                        <span id="vitasa_opentime_minutes_button_' + dow.toString() + '">Minute</span><span class="caret"></span>' +
        '                    </div >' +
        '                    <div class="dropdown-menu" id="vitasa_opentime_minutes_' + dow.toString() + '">' +
        '                    </div>' +
        '                </div>' +
        '                <span class="modal-title">&nbsp;&nbsp;</span>' +
        '                <div class="dropdown btn-light">' +
        '                    <div class="dropdown-toggle" data-toggle="dropdown">' +
        '                        <span id="vitasa_opentime_ampm_button_' + dow.toString() + '">AM</span><span class="caret"></span>' +
        '                    </div >' +
        '                    <div class="dropdown-menu" id="vitasa_opentime_ampm_' + dow.toString() + '">' +
        '                    </div>' +
        '                </div>' +
        '            </div>' +
        '            <div class="btn-group" style="cursor: pointer;">' +
        '                <span class="modal-title">&nbsp;Close Time: &nbsp; &nbsp;</span>' +
        '                <div class="dropdown btn-light">' +
        '                    <div class="dropdown-toggle" data-toggle="dropdown">' +
        '                        <span id="vitasa_closetime_hours_button_' + dow.toString() + '">Hour</span><span class="caret"></span>' +
        '                    </div >' +
        '                    <div class="dropdown-menu" id="vitasa_closetime_hours_' + dow.toString() + '">' +
        '                    </div>' +
        '                </div>' +
        '                <span class="modal-title">&nbsp;:&nbsp;</span>' +
        '                <div class="dropdown btn-light">' +
        '                    <div class="dropdown-toggle" data-toggle="dropdown">' +
        '                        <span id="vitasa_closetime_minutes_button_' + dow.toString() + '">Minute</span><span class="caret"></span>' +
        '                    </div >' +
        '                    <div class="dropdown-menu" id="vitasa_closetime_minutes_' + dow.toString() + '">' +
        '                    </div>' +
        '                </div>' +
        '                <span class="modal-title">&nbsp;&nbsp;</span>' +
        '                <div class="dropdown btn-light">' +
        '                    <div class="dropdown-toggle" data-toggle="dropdown">' +
        '                        <span id="vitasa_closetime_ampm_button_' + dow.toString() + '">AM</span><span class="caret"></span>' +
        '                    </div >' +
        '                    <div class="dropdown-menu" id="vitasa_closetime_ampm_' + dow.toString() + '">' +
        '                    </div>' +
        '                </div>' +
        '            </div>';
    cols += '</td>';

    const newRow = $('<tr>');
    newRow.append(cols);
    $("table#vitasa_adminsitecalreset_table").append(newRow);

    let hoursChoices = [];
    for(let h = 1; h !== 13; h++) {
        let hc = { "text" : h.toString(), "item" : h.toString() };
        hoursChoices.push(hc);
    }

    let minuteChoices = [];
    for(let h = 0; h !== 60; h += 15) {
        let m_s = h.toString();
        if (m_s.length === 1)
            m_s = "0" + m_s;
        let hc = { "text" : m_s, "item" : h.toString() };
        minuteChoices.push(hc);
    }

    let ampmchoices =
        [
            {"text" : "AM", "item" : "AM"},
            {"text" : "PM", "item" : "PM"}
        ];

    let openTimeHourOptions = {
        "choices": hoursChoices,
        "selitem" : "8",
        "dropdownid" : "vitasa_opentime_hours_" + dow.toString(),
        "buttonid" : "vitasa_opentime_hours_button_" + dow.toString()
    };
    let othdd = new C_DropdownHelper(openTimeHourOptions);
    OpenTimeHoursDropDownList.push(othdd);
    othdd.SetHelper("OpenTimeHoursDropDownList[" + DropDownListIndex.toString() + "]");
    othdd.CreateDropdown();

    let openTimeMinuteOptions = {
        "choices": minuteChoices,
        "selitem" : "0",
        "dropdownid" : "vitasa_opentime_minutes_" + dow.toString(),
        "buttonid" : "vitasa_opentime_minutes_button_" + dow.toString()
    };
    let otmdd = new C_DropdownHelper(openTimeMinuteOptions);
    OpenTimeMinuteDropDownList.push(otmdd);
    otmdd.SetHelper("OpenTimeMinuteDropDownList[" + DropDownListIndex.toString() + "]");
    otmdd.CreateDropdown();

    let openTimeAMPMOptions = {
        "choices": ampmchoices,
        "selitem" : "AM",
        "dropdownid" : "vitasa_opentime_ampm_" + dow.toString(),
        "buttonid" : "vitasa_opentime_ampm_button_" + dow.toString()
    };
    let otampmdd = new C_DropdownHelper(openTimeAMPMOptions);
    OpenTimeAMPMDropDownList.push(otampmdd);
    otampmdd.SetHelper("OpenTimeAMPMDropDownList[" + DropDownListIndex.toString() + "]");
    otampmdd.CreateDropdown();

    let closeTimeHourOptions = {
        "choices": hoursChoices,
        "selitem" : "1",
        "dropdownid" : "vitasa_closetime_hours_" + dow.toString(),
        "buttonid" : "vitasa_closetime_hours_button_" + dow.toString()
    };
    let cthdd = new C_DropdownHelper(closeTimeHourOptions);
    CloseTimeHoursDropDownList.push(cthdd);
    cthdd.SetHelper("CloseTimeHoursDropDownList[" + DropDownListIndex.toString() + "]");
    cthdd.CreateDropdown();

    let closeTimeMinuteOptions = {
        "choices": minuteChoices,
        "selitem" : "0",
        "dropdownid" : "vitasa_closetime_minutes_" + dow.toString(),
        "buttonid" : "vitasa_closetime_minutes_button_" + dow.toString()
    };
    let ctmdd = new C_DropdownHelper(closeTimeMinuteOptions);
    CloseTimeMinuteDropDownList.push(ctmdd);
    ctmdd.SetHelper("CloseTimeMinuteDropDownList[" + DropDownListIndex.toString() + "]");
    ctmdd.CreateDropdown();

    let closeTimeAMPMOptions = {
        "choices": ampmchoices,
        "selitem" : "PM",
        "dropdownid" : "vitasa_closetime_ampm_" + dow.toString(),
        "buttonid" : "vitasa_closetime_ampm_button_" + dow.toString()
    };
    let ctampmdd = new C_DropdownHelper(closeTimeAMPMOptions);
    CloseTimeAMPMDropDownList.push(ctampmdd);
    ctampmdd.SetHelper("CloseTimeAMPMDropDownList[" + DropDownListIndex.toString() + "]");
    ctampmdd.CreateDropdown();

    DropDownListIndex++;
}

function AdminSiteCalResetBackToSiteCalendar() {
    window.location.href = "adminsitescal.html?siteslug=" + OurSite.Slug;
}

function SetSeasonFirstDate() {
    ShowCalendar("Season First Date", BackendHelper.Filter.SeasonFirstDate, SeasonFirstDate_callback);
}

function SeasonFirstDate_callback(date) {
    SeasonFirstDate = date;
    BackendHelper.Filter.SeasonFirstDate = date;
    $('button#vitasa_adminsitecalreset_firstdate')[0].innerText = 'From: ' + date.toString();
    BackendHelper.SaveFilter()
        .catch(function (error) {
            console.log(error);
        })
}

function SetSeasonLastDate() {
    ShowCalendar("Season Last Date", BackendHelper.Filter.SeasonLastDate, SeasonLastDate_callback);
}

function SeasonLastDate_callback(date) {
    SeasonLastDate = date;
    BackendHelper.Filter.SeasonLastDate = date;
    $('button#vitasa_adminsitecalreset_lastdate')[0].innerText = 'To: ' + date.toString();
    BackendHelper.SaveFilter()
        .catch(function (error) {
            console.log(error);
        })
}

function AdminSiteCalResetSave() {
    MessageBox(
        "Confirm",
        "This action will overwrite every calendar entry for [" + OurSite.Name + "] starting [" + SeasonFirstDate.toString() + "] up through [" + SeasonLastDate.toString() + "]. Proceeed? THERE IS NO UNDO.",
        [ "Yes", "No" ],
        AdminSiteCalResetCallBack
    );
}

function AdminSiteCalResetCallBack(button) {
    if (button !== "Yes")
        return;

    AdminSiteCalReset_Action()
        .then(function () {
            window.location.href = "adminsitescal.html?siteslug=" + OurSite.Slug;
        })
        .catch(function (error) {
            console.log(error);
        })
}

/**
 * @return {boolean} true on success
 */
async function AdminSiteCalReset_Action() {
    StartBusy("Working...");

    let ok = true;

    // first thing is to remove all the old calendar entries; we queue them up so the forEach doesn't get messed with
    let celist = [];
    OurSite.SiteCalendar.forEach(function (ce) {
       celist.push(ce);
    });
    for(let ix = 0; ix !== celist.length; ix ++) {
        ok = await BackendHelper.DeleteCalendarEntry(celist[ix]);
        if (!ok)
            break;
    }

    if (ok)
    {
        let today = new C_YMD(SeasonFirstDate.Year, SeasonFirstDate.Month, SeasonFirstDate.Day);
        let last = new C_YMD(SeasonLastDate.Year, SeasonLastDate.Month, SeasonLastDate.Day);
        while (today.CompareTo(last) < 1) {
            let dow = today.DayOfWeek();

            // build a calendar entry for this date with values from the page
            let ce = buildCalendarEntryForDOW(dow);
            ce.Date = C_YMD.FromYMD(today.Year, today.Month, today.Day);

            // add to the site's calendar
            ok = await BackendHelper.CreateCalendarEntry(ce);

            // break if error
            if (!ok)
                break;

            today.AddDays(1);
        }
    }

    StopBusy();

    return ok;
}

/**
 * @return {C_CalendarEntry}
 */
function buildCalendarEntryForDOW(dow) {
    let siteisopen = $('#vitasa_adminsitecalreset_cb_' + dow.toString())[0].checked;
    let opentime = new C_HMS(8, 0, 0);
    let closetime = new C_HMS(17, 0, 0);
    if (siteisopen) {
        // start here: the parseInt is returning NaN ! <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        let openhour = parseInt(OpenTimeHoursDropDownList[dow].DropDownSelectedItem);
        let openminute = parseInt(OpenTimeMinuteDropDownList[dow].DropDownSelectedItem);
        opentime = new C_HMS(openhour, openminute, 0);
        let closehour = parseInt(CloseTimeHoursDropDownList[dow].DropDownSelectedItem);
        let closeminute = parseInt(CloseTimeMinuteDropDownList[dow].DropDownSelectedItem);
        closetime = new C_HMS(closehour, closeminute, 0);
    }

    let res = new C_CalendarEntry(null);
    res.SiteId = OurSite.id;
    res.SiteIsOpen = siteisopen;
    res.OpenTime = opentime;
    res.CloseTime = closetime;

    return res;
}



