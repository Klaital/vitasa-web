
let OurUser = null;
let OurSite = null;
var BackendHelper = null;

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

    DrawAdminSiteCalendar();
}

function DrawAdminSiteCalendar() {
    let ourDate = BackendHelper.Filter.CalendarDate;

    let firstDayOfMonthDate = new C_YMD(ourDate.Year, ourDate.Month, 1);
    let firstDayOfMonthDayOfWeek = firstDayOfMonthDate.DayOfWeek();

    $('#vitasa_adminsitecal_date')[0].innerText = MonthNames[ourDate.Month - 1] + " - " + ourDate.Year.toString();

    for(let x = 0; x !== 7; x++) {
        for(let y = 0; y !== 7; y++) {
            let calSelector = "#vitasa_cal_" + x.toString() + y.toString();
            let calCel = $(calSelector)[0];
            let dn = x * 7 + (y - firstDayOfMonthDayOfWeek + 1);

            if (x === 0) {
                if (y < firstDayOfMonthDayOfWeek) {
                    calCel.bgColor = CalendarColor_Site_NotADate;
                    calCel.innerText = "";
                }
                else {
                    let thisdate = new C_YMD(ourDate.Year, ourDate.Month, dn);
                    calCel.bgColor = GetColorForDate(thisdate, OurSite);
                    calCel.innerText = dn.toString();
                }
            }
            else {
                let date = new C_YMD(ourDate.Year, ourDate.Month, dn);
                let daysInMonth = date.DaysInMonth();

                if (date.Day <= daysInMonth) {
                    calCel.bgColor = GetColorForDate(date, OurSite);
                    calCel.innerText = dn.toString();
                }
                else {
                    calCel.bgColor = CalendarColor_Site_NotADate;
                    calCel.innerText = "";
                }
            }
        }
    }
}

// Colors:
// 0: FFFFFF - not a date, blank space with no number, page background
// 1: F4F4F4 - date with no site open [grey]
// 2: ffa500 - date with only 1 site open [orange
// 3: 228B22 - date with exactly 2, non-overlapping [dark green]
// 4: 8b0000 - date with 2 that overlap or 3 or more [dark red]

/**
 * @return {string}
 */
function GetColorForDate(date, site) {
    let ce = site.FindCalendarEntryForDate(date);

    let res = CalendarColor_Site_SiteClosed;

    if (ce == null) {
        res = CalendarColor_Site_NotADate;
    }
    else if (ce.SiteIsOpen) {
        res = CalendarColor_Site_SiteOpen;
    }

    return res;
}


function PreviousMonth() {
    let ourDate = BackendHelper.Filter.CalendarDate;
    
    ourDate.Month = ourDate.Month - 1;
    if (ourDate.Month === 0) {
        ourDate.Month = 12;
        ourDate.Year--;
    }
    BackendHelper.Filter.CalendarDate = ourDate;

    DrawAdminSiteCalendar();

    BackendHelper.SaveFilter()
        .catch(function (error) {
            console.log(error);
        })
}

function NextMonth() {
    let ourDate = BackendHelper.Filter.CalendarDate;

    ourDate.Month = ourDate.Month + 1;
    if (ourDate.Month > 12) {
        ourDate.Month = 1;
        ourDate.Year++;
    }

    BackendHelper.Filter.CalendarDate = ourDate;

    DrawAdminSiteCalendar();

    BackendHelper.SaveFilter()
        .catch(function (error) {
            console.log(error);
        })
}

function day_click(element, which) {
    let elementid = element.id;
    let xy = elementid.slice(-2);
    let x_s = xy.substring(0, 1);
    let y_s = xy.slice(1, 2);

    let x = parseInt(x_s);
    let y = parseInt(y_s);

    let ourDate = BackendHelper.Filter.CalendarDate;
    let firstDayOfMonthDate = new C_YMD(ourDate.Year, ourDate.Month, 1);
    let firstDayOfMonthDayOfWeek = firstDayOfMonthDate.DayOfWeek();

    if ((x === 0) && (y < firstDayOfMonthDayOfWeek))
        return;

    let dn = x * 7 + (y - firstDayOfMonthDayOfWeek + 1);
    let date = new C_YMD(ourDate.Year, ourDate.Month, dn);
    let daysInMonth = date.DaysInMonth();

    if (dn > daysInMonth)
        return;

    let ce = OurSite.FindCalendarEntryForDate(date);
    if (ce === null)
        return;

    $('#vitasa_modal_scsitecalendar_sitename')[0].innerText = OurSite.Name;
    $('#vitasa_modal_scsitecalendar_date')[0].innerText = MonthNames[date.Month-1] + " " + date.Day.toString() + ", " + date.Year.toString();

    $('input#vitasa_scsitecalendar_siteisopen')[0].checked = ce.SiteIsOpen;

    // populate the hours and minutes dropdowns for each of the open and close times

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
        "selitem" : ce.OpenTime.Get12HourHour().toString(),
        "dropdownid" : "vitasa_opentime_hours",
        "buttonid" : "vitasa_opentime_hours_button"
    };
    openTimeHoursDropDown = new C_DropdownHelper(openTimeHourOptions);
    openTimeHoursDropDown.SetHelper("openTimeHoursDropDown");
    openTimeHoursDropDown.CreateDropdown();

    let openTimeMinuteOptions = {
        "choices": minuteChoices,
        "selitem" : ce.OpenTime.Minute.toString(),
        "dropdownid" : "vitasa_opentime_minutes",
        "buttonid" : "vitasa_opentime_minutes_button"
    };
    openTimeMinuteDropDown = new C_DropdownHelper(openTimeMinuteOptions);
    openTimeMinuteDropDown.SetHelper("openTimeMinuteDropDown");
    openTimeMinuteDropDown.CreateDropdown();

    let openTimeAMPMOptions = {
        "choices": ampmchoices,
        "selitem" : ce.OpenTime.IsAm() ? "AM" : "PM",
        "dropdownid" : "vitasa_opentime_ampm",
        "buttonid" : "vitasa_opentime_ampm_button"
    };
    openTimeAMPMDropDown = new C_DropdownHelper(openTimeAMPMOptions);
    openTimeAMPMDropDown.SetHelper("openTimeAMPMDropDown");
    openTimeAMPMDropDown.CreateDropdown();

    let closeTimeHourOptions = {
        "choices": hoursChoices,
        "selitem" : ce.CloseTime.Get12HourHour().toString(),
        "dropdownid" : "vitasa_closetime_hours",
        "buttonid" : "vitasa_closetime_hours_button"
    };
    closeTimeHoursDropDown = new C_DropdownHelper(closeTimeHourOptions);
    closeTimeHoursDropDown.SetHelper("closeTimeHoursDropDown");
    closeTimeHoursDropDown.CreateDropdown();

    let closeTimeMinuteOptions = {
        "choices": minuteChoices,
        "selitem" : ce.CloseTime.Minute.toString(),
        "dropdownid" : "vitasa_closetime_minutes",
        "buttonid" : "vitasa_closetime_minutes_button"
    };
    closeTimeMinuteDropDown = new C_DropdownHelper(closeTimeMinuteOptions);
    closeTimeMinuteDropDown.SetHelper("closeTimeMinuteDropDown");
    closeTimeMinuteDropDown.CreateDropdown();

    let closeTimeAMPMOptions = {
        "choices": ampmchoices,
        "selitem" : ce.CloseTime.IsAm() ? "AM" : "PM",
        "dropdownid" : "vitasa_closetime_ampm",
        "buttonid" : "vitasa_closetime_ampm_button"
    };
    closeTimeAMPMDropDown = new C_DropdownHelper(closeTimeAMPMOptions);
    closeTimeAMPMDropDown.SetHelper("closeTimeAMPMDropDown");
    closeTimeAMPMDropDown.CreateDropdown();

    ActiveCalendarEntry = ce;

    $('#vitasa_modal_adminsitecal_details').modal({});
}

// Called when the edit workitem modal is closed by user action
$('#vitasa_modal_adminsitecal_details').on('hidden.bs.modal', function () {
    // if it was the cancel button, we can safely just quit
    let docactelemid = $(document.activeElement).attr("id");
    if (docactelemid === "vitasa_button_cancel")
        return;

    if (docactelemid !== "vitasa_button_save")
        return;

    // get the final values
    let sio = $("#vitasa_scsitecalendar_siteisopen").prop("checked");

    let oth = parseInt(openTimeHoursDropDown.DropDownSelectedItem);
    let otm = parseInt(openTimeMinuteDropDown.DropDownSelectedItem);
    let otampm = openTimeAMPMDropDown.DropDownSelectedItem;
    let ot = C_HMS.FromHoursMinutesAMPM(oth, otm, otampm);

    let cth = parseInt(closeTimeHoursDropDown.DropDownSelectedItem);
    let ctm = parseInt(closeTimeMinuteDropDown.DropDownSelectedItem);
    let ctampm = closeTimeAMPMDropDown.DropDownSelectedItem;
    let ct = C_HMS.FromHoursMinutesAMPM(cth, ctm, ctampm);

    if (ot.CompareTo(ct) === 1) {
        ErrorMessageBox("Open time must be before Close time.");
        return;
    }

    ActiveCalendarEntry.SiteIsOpen = sio;
    ActiveCalendarEntry.OpenTime = ot;
    ActiveCalendarEntry.CloseTime = ct;

    BackendHelper.UpdateCalendarEntry(ActiveCalendarEntry)
        .then(function (success) {
            if (success) {
                ActiveCalendarEntry = null;
                DrawAdminSiteCalendar();
            }
            else {
                ErrorMessageBox("Faied to update the Calendar entry.");
            }
        })
        .catch(function(error) {
            console.log(error);
        });
});

function AdminSiteCalBackToSites() {
    window.location.href = 'adminsites.html';
}

function AdminSiteCalToCalReset() {
    window.location.href = 'adminsitecalreset.html?siteslug=' + OurSite.Slug;
}



