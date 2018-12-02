
let OurUser = null;
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
    BackendHelper.UsingOnlyLocalData = true;

    InitMenuItems(BackendHelper.UserCredentials);

    if (BackendHelper.UserCredentials.IsValidCredential())
        OurUser = await BackendHelper.DoLogin(BackendHelper.UserCredentials.Email, BackendHelper.UserCredentials.Password);

    if (OurUser !== null)
        $("span#vitasa_username")[0].innerText = BackendHelper.UserCredentials.Name;

    DrawCalendar();
}

// Colors:
// 0: FFFFFF - not a date, blank space with no number, page background
// 1: F4F4F4 - date with no site open [grey]
// 2: ffa500 - date with only 1 site open [orange
// 3: 228B22 - date with exactly 2, non-overlapping [dark green]
// 4: 8b0000 - date with 2 that overlap or 3 or more [dark red]

//let CalendarBackgroundColors = [ "FFFFFF", "F4F4F4", "FFA500", "228B22", "E00000" ];

function DrawCalendar() {
    let firstDayOfMonthDate = new C_YMD(BackendHelper.Filter.CalendarDate.Year, BackendHelper.Filter.CalendarDate.Month, 1);
    let firstDayOfMonthDayOfWeek = firstDayOfMonthDate.DayOfWeek();

    $('#vitasa_cal_date')[0].innerText = MonthNames[BackendHelper.Filter.CalendarDate.Month - 1] + " - " + BackendHelper.Filter.CalendarDate.Year.toString();

    for(let x = 0; x !== 7; x++) {
        for(let y = 0; y !== 7; y++) {
            let calSelector = "#vitasa_cal_" + x.toString() + y.toString();
            let calCel = $(calSelector)[0];
            let dn = x * 7 + (y - firstDayOfMonthDayOfWeek + 1);

            if (x === 0) {
                if (y < firstDayOfMonthDayOfWeek) {
                    calCel.bgColor = CalendarColor_Mobile_NotADate;
                    calCel.innerText = "";
                }
                else {
                    let thisdate = new C_YMD(BackendHelper.Filter.CalendarDate.Year, BackendHelper.Filter.CalendarDate.Month, dn);
                    calCel.bgColor = GetColorForDate(thisdate);
                    calCel.innerText = dn.toString();
                }
            }
            else {
                let date = new C_YMD(BackendHelper.Filter.CalendarDate.Year, BackendHelper.Filter.CalendarDate.Month, dn);
                let daysInMonth = date.DaysInMonth();

                if (date.Day <= daysInMonth) {
                    calCel.bgColor = GetColorForDate(date);
                    calCel.innerText = dn.toString();
                }
                else {
                    calCel.bgColor = CalendarColor_Mobile_NotADate;
                    calCel.innerText = "";
                }
            }
        }
    }
}

/**
 * @return {string}
 */
function GetColorForDate(date) {
    let celist = BackendHelper.FindOpenMobileSitesOnDate(date);

    let res = CalendarColor_Mobile_NotADate;

    if (celist.length === 0) {
        res = CalendarColor_Mobile_NoSiteOpen;
    }
    else if (celist.length === 1) {
        res = CalendarColor_Mobile_OneSiteOpen;
    }
    else if ((celist.length === 2) && !Overlap(celist)) {
        res = CalendarColor_Mobile_TwoSitesOpen;
    }
    else {
        res = CalendarColor_Mobile_ManySitesOpen;
    }

    return res;
}


function PreviousMonth() {
    BackendHelper.Filter.CalendarDate.Month = BackendHelper.Filter.CalendarDate.Month - 1;
    if (BackendHelper.Filter.CalendarDate.Month === 0) {
        BackendHelper.Filter.CalendarDate.Month = 12;
        BackendHelper.Filter.CalendarDate.Year--;
    }

    BackendHelper.SaveFilter()
        .then(function () {
            DrawCalendar();
        })
        .catch(function (error) {
            console.log(error);
        })
}

function NextMonth() {
    BackendHelper.Filter.CalendarDate.Month = BackendHelper.Filter.CalendarDate.Month + 1;
    if (BackendHelper.Filter.CalendarDate.Month > 12) {
        BackendHelper.Filter.CalendarDate.Month = 1;
        BackendHelper.Filter.CalendarDate.Year++;
    }

    BackendHelper.SaveFilter()
        .then(function () {
            DrawCalendar();
        })
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

    let firstDayOfMonthDate = new C_YMD(BackendHelper.Filter.CalendarDate.Year, BackendHelper.Filter.CalendarDate.Month, 1);
    let firstDayOfMonthDayOfWeek = firstDayOfMonthDate.DayOfWeek();

    if ((x === 0) && (y < firstDayOfMonthDayOfWeek))
        return;

    let dn = x * 7 + (y - firstDayOfMonthDayOfWeek + 1);
    let date = new C_YMD(BackendHelper.Filter.CalendarDate.Year, BackendHelper.Filter.CalendarDate.Month, dn);
    let daysInMonth = date.DaysInMonth();

    if (dn > daysInMonth)
        return;

    // start here to show the site details
    $('#vitasa_modal_sitedetails_date')[0].innerText = date.toString();

    // build the list of mobile sites open on this date
    let celist = BackendHelper.FindOpenMobileSitesOnDate(date);

    if (celist.length === 0)
        return;

    $("#vitasa_sitedetails_sites tbody tr").remove();

    celist.forEach(function (ce) {
        let site = BackendHelper.FindSiteById(ce.SiteId);
        if (site === null)
            return;

        const newRow = $('<tr>');
        let cols = "";

        let open_hours = ce.OpenTime.toStringFormat("hh:mm p") + " to " + ce.CloseTime.toStringFormat("hh:mm p");
        cols += '<td>' + site.Name + '</td>';
        cols += '<td>' + open_hours + '</td>';

        newRow.append(cols);

        $("table#vitasa_sitedetails_sites").append(newRow);
    });

    $('#vitasa_modal_sitedetails').modal({});
}


