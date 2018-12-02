
let OurUser = null;
var BackendHelper = null;
let OurUserWorkItems = null;

$( document ).ready(function() {
    PageInit()
    .catch(function (error){
        console.log(error);
        ErrorMessageBox("Network error in loading sites, users, or credentials.");
    });
});

async function PageInit() {
    BackendHelper = new C_BackendHelper();
    await BackendHelper.Initialize();
    await BackendHelper.LoadAllUsers();

    InitMenuItems(BackendHelper.UserCredentials);

    OurUser = BackendHelper.FindUserByEmail(BackendHelper.UserCredentials.Email);

    PopulateTable();

    $("span#vitasa_username")[0].innerText = BackendHelper.UserCredentials.Name;
}

function PopulateTable() {
    OurUserWorkItems = BackendHelper.GetWorkLogForUser(OurUser.id);
    OurUserWorkItems.sort(function(a, b) { return a.Date.CompareTo(b.Date)} );

    OurUserWorkItems.forEach(function (wli) {
        AddWorkItemRow(wli);
    });
}

function ClearAllWorkItemRows() {
    OurUserWorkItems.forEach(function(wli) {
        $('#vitasa_workitemrow_' + wli.id.toString()).remove();
    });
}

function UpdateWorkItemRow(wli) {
    let dr = $("#vitasa_workitemdate_" + wli.id.toString());
    let sr = $("#vitasa_workitemsite_" + wli.id.toString());
    let hr = $("#vitasa_workitemhours_" + wli.id.toString());

    let site = BackendHelper.FindSiteById(wli.SiteId);

    dr[0].innerText = wli.Date.toString();
    sr[0].innerText = site.Name;
    hr[0].innerText = wli.Hours.toString();
}

function AddWorkItemRow(wli) {
    let site = BackendHelper.FindSiteById(wli.SiteId);

    const newRow = $('<tr id="vitasa_workitemrow_' + wli.id.toString() + '">');
    let cols = "";

    cols += '<th scope="row" id="vitasa_workitemdate_' + wli.id.toString() + '">' + wli.Date.toString() + '</th>';
    cols += '<td id="vitasa_workitemsite_' + wli.id.toString() + '">' + site.Name + '</td>';
    cols += '<td id="vitasa_workitemhours_' + wli.id.toString() + '">' + wli.Hours.toString() + '</td>';

    cols += '<td>';
    cols += '<input type="button" class="btn btn-md btn-primary" id="vitasa_volhours_editrow" value="Edit" ' +
        'onclick="DoEditWorkItem_clicked(' + wli.id.toString() + ');">';
    cols += '&nbsp;';
    cols += '<input type="button" class="btn btn-md btn-danger" id="vitasa_volhours_delrow" value="Delete" ' +
        'onclick="DoDeleteWorkItem_clicked(' + wli.id.toString() + ');">';
    cols += '</td>';
    newRow.append(cols);
    $("table#vitasa_volhours_table").append(newRow);
}

let VolHours_ModalWorkItem = null;
let VolHours_ModalSite = null;
// newitemid: -1 if new item, otherwise the id of the workitem to edit
// This is called when either a new work item is requested or when the user decides to
//  edit an existing item
function DoEditWorkItem_clicked(newitemid) {
    VolHours_ModalWorkItem = new C_WorkLog(null);
    if (newitemid !== -1) {
        VolHours_ModalWorkItem = BackendHelper.FindWorkItem(newitemid);
        VolHours_ModalSite = BackendHelper.FindSiteById(VolHours_ModalWorkItem.SiteId);
    }
    else {
        VolHours_ModalWorkItem.UserId = OurUser.id;
    }

    // populate the sites dropdown list, showing the selected item if existing item
    let selitem = null;
    let choices = [];
    let sites = BackendHelper.GetAllSites();
    sites.forEach(function (site) {
        if ((VolHours_ModalSite !== null) && (site.Slug === VolHours_ModalSite.Slug))
            selitem = VolHours_ModalSite.Slug;
        let nchoice = { "text": site.Name, "item" : site.Slug };
        choices.push(nchoice);
    });
    choices.sort(function(a,b) {return a.text.localeCompare(b); });

    // if no site selected, pick the first one
    if (selitem === null) {
        selitem = choices[0].item;
    }

    let sitesOptions = {
        "choices": choices,
        "selitem" : selitem,
        "dropdownid" : "vitasa_dropdown_site",
        "buttonid" : "vitasa_button_selectsite"
    };
    sitesDropDown = new C_DropdownHelper(sitesOptions); // this must be in the global space
    sitesDropDown.SetHelper("sitesDropDown");
    sitesDropDown.CreateDropdown();

    DrawVolHoursCalendar();

    $('#vitasa_workitem_hours')[0].value = VolHours_ModalWorkItem.Hours.toString();

    // need to populate the hours if existing
    $('#vitasa_modal_title').innerText = "Work Item";

    $('#vitasa_modal_workitem').modal({});
}

function DrawVolHoursCalendar() {
    let ourDate = BackendHelper.Filter.CalendarDate;
    let firstDayOfMonthDate = new C_YMD(ourDate.Year, ourDate.Month, 1);
    let firstDayOfMonthDayOfWeek = firstDayOfMonthDate.DayOfWeek();

    $('#vitasa_volhours_edit_date')[0].innerText = MonthNames[ourDate.Month - 1] + " - " + ourDate.Year.toString();
    $('#vitasa_volhours_edit_date_i')[0].value = MonthNames[ourDate.Month - 1] + " " + ourDate.Day.toString() + ", " + ourDate.Year.toString();

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
                    let anySiteOpen = BackendHelper.AnySiteOpenOnDate(thisdate);

                    calCel.bgColor = anySiteOpen ? CalendarColor_Site_SiteOpen : CalendarColor_Site_SiteClosed;
                    calCel.innerText = dn.toString();
                }
            }
            else {
                let thisdate = new C_YMD(ourDate.Year, ourDate.Month, dn);
                let daysInMonth = thisdate.DaysInMonth();
                let anySiteOpen = BackendHelper.AnySiteOpenOnDate(thisdate);

                if (thisdate.Day <= daysInMonth) {
                    calCel.bgColor = anySiteOpen ? CalendarColor_Site_SiteOpen : CalendarColor_Site_SiteClosed;
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

function volhoursworked_modal_dateclicked(element, which) {
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

    BackendHelper.Filter.CalendarDate = date;

    $('#vitasa_volhours_edit_date')[0].innerText = MonthNames[date.Month - 1] + " - " + date.Year.toString();
    $('#vitasa_volhours_edit_date_i')[0].value = MonthNames[date.Month - 1] + " " + date.Day.toString() + ", " + date.Year.toString();
}

function VolHoursEdit_PreviousMonth() {
    let ourdate = BackendHelper.Filter.CalendarDate;
    ourdate.Month = ourdate.Month - 1;
    if (ourdate.Month === 0) {
        ourdate.Month = 12;
        ourdate.Year--;
    }
    BackendHelper.Filter.CalendarDate = ourdate;

    DrawVolHoursCalendar();

    BackendHelper.SaveFilter()
        .catch(function (error) {
            console.log(error);
        })
}

function VolHoursEdit_NextMonth() {
    let ourdate = BackendHelper.Filter.CalendarDate;
    ourdate.Month = ourdate.Month + 1;
    if (ourdate.Month > 12) {
        ourdate.Month = 1;
        ourdate.Year++;
    }
    BackendHelper.Filter.CalendarDate = ourdate;

    DrawVolHoursCalendar();

    BackendHelper.SaveFilter()
        .catch(function (error) {
            console.log(error);
        })
}

// /**
//  * @return {boolean}
//  */
// function DatesListIncludes(dateslist, date) {
//     let res = false;
//
//     for(let ix = 0; ix !== dateslist.length; ix++) {
//         let dix = dateslist[ix];
//         if (dix.CompareTo(date) === 0) {
//             res = true;
//             break;
//         }
//     }
//
//     return res;
// }

// Called when the edit workitem modal is closed by user action
$('#vitasa_modal_workitem').on('hidden.bs.modal', function () {
    // if it was the cancel button, we can safely just quit
    let clickedbuttonid = $(document.activeElement).attr("id");
    if (clickedbuttonid === "vitasa_button_cancel") {
        return;
    }

    if (clickedbuttonid !== "vitasa_button_save")
        return;

    let hours = $('#vitasa_workitem_hours')[0].value;
    VolHours_ModalWorkItem.Hours = parseFloat(hours);
    let cd = BackendHelper.Filter.CalendarDate;
    VolHours_ModalWorkItem.Date = new C_YMD(cd.Year, cd.Month, cd.Day);
    let s = BackendHelper.FindSiteBySlug(sitesDropDown.DropDownSelectedItem);
    VolHours_ModalWorkItem.SiteId = s.id;
    VolHours_ModalWorkItem.UserId = OurUser.id;

    // use VolHours_ModalSite null to indicate a new item
    if (VolHours_ModalSite === null) {
        BackendHelper.CreateWorkLog(VolHours_ModalWorkItem)
        .then(function() {
            // add to the table
            ClearAllWorkItemRows();
            PopulateTable();
        })
        .catch(function(error) {
            console.log(error);
        });
    }
    else {
        BackendHelper.UpdateWorkLog(VolHours_ModalWorkItem)
        .then(function() {
            // add to the table
            UpdateWorkItemRow(VolHours_ModalWorkItem);
        })
        .catch(function(error) {
            console.log(error);
        });
    }
    VolHours_ModalSite = null;
});

function DoDeleteWorkItem_clicked(wlid) {
    //vitasa_workitemrow_' + wli.id.toString()
    let wli = BackendHelper.FindWorkItem(wlid); // FindUserWorkItemById(OurUser, wlid);
    BackendHelper.DeleteWorkLog(wli)
        .then(function (success) {
            if (success) {
                //let xx = $('tr#vitasa_workitemrow_' + wli.id.toString());
                //$('tr#vitasa_workitemrow_' + wli.id.toString()).innerHTML = '';
                $('tr#vitasa_workitemrow_' + wli.id.toString()).remove();
            }
        })
        .catch(function (error) {
            console.log(error);
        })
}

