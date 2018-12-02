let OurUser = null;
let OurSite = null;
var BackendHelper = null;
let OurSiteWorkItems = null;

$( document ).ready(function() {
    DoPageLoad()
        .catch(function (error){
            console.log(error);
            ErrorMessageBox("Error in page load.");
        });
});

async function DoPageLoad() {
    BackendHelper = new C_BackendHelper();
    await BackendHelper.Initialize();
    await BackendHelper.LoadAllUsers();

    InitMenuItems(BackendHelper.UserCredentials);

    OurUser = BackendHelper.FindUserByEmail(BackendHelper.UserCredentials.Email);

    OurSite = BackendHelper.FindSiteBySlug(BackendHelper.Filter.SelectedSiteSlug);

    $("span#vitasa_username")[0].innerText = OurUser.Name;
    $('h2#vitasa_sitename')[0].innerText = OurSite.Name;

    PopulateSCTable();
}

function PopulateSCTable() {
    // populate the table
    OurSiteWorkItems = BackendHelper.GetWorkLogForSite(OurSite.id);
    OurSiteWorkItems.sort(function(a, b) { return a.Date.CompareTo(b.Date)} );

    OurSiteWorkItems.forEach(function (wli) {
        AddSCWorkItemRow(wli);
    });
}

function ClearAllSCWorkItemRows() {
    OurSiteWorkItems.forEach(function(wli) {
        $('#vitasa_workitemrow_' + wli.id.toString()).remove();
    });
}

function UpdateSCWorkItemRow(wli) {
    let dr = $("#vitasa_scworkitemdate_" + wli.id.toString());
    let ur = $("#vitasa_scworkitemuser_" + wli.id.toString());
    let hr = $("#vitasa_scworkitemhours_" + wli.id.toString());

    let user = BackendHelper.FindUserById(wli.UserId);

    let a_s = wli.Approved ? " [Approved]" : " [not Approved]";

    dr[0].innerText = wli.Date.toString();
    ur[0].innerText = user.Name;
    hr[0].innerText = wli.Hours.toString() + a_s;
}

function AddSCWorkItemRow(wli) {
    let user = BackendHelper.FindUserById(wli.UserId);

    let a_s = wli.Approved ? " [Approved]" : " [not Approved]";

    const newRow = $('<tr id="vitasa_scworkitemrow_' + wli.id.toString() + '">');
    let cols = "";

    cols += '<th scope="row" id="vitasa_scworkitemdate_' + wli.id.toString() + '">' + wli.Date.toString() + '</th>';
    cols += '<td id="vitasa_scworkitemuser_' + wli.id.toString() + '">' + user.Name + '</td>';
    cols += '<td id="vitasa_scworkitemhours_' + wli.id.toString() + '">' + wli.Hours.toString() + a_s + '</td>';

    cols += '<td>';
    cols += '<input type="button" class="btn btn-md btn-primary" id="vitasa_scvolhours_editrow" value="Edit" ' +
        'onclick="DoEditSCWorkItem_clicked(' + wli.id.toString() + ');">';
    cols += '&nbsp;';
    cols += '<input type="button" class="btn btn-md btn-danger" id="vitasa_scvolhours_delrow" value="Delete" ' +
        'onclick="DoDeleteSCWorkItem(' + wli.id.toString() + ');">';
    cols += '&nbsp;';
    cols += '<input type="button" class="btn btn-md btn-primary" id="vitasa_scvolhours_approverow" value="Approve" ' +
        'onclick="DoApproveSCWorkItem(' + wli.id.toString() + ');">';
    cols += '</td>';
    newRow.append(cols);
    $("table#vitasa_scvolhours_table").append(newRow);
}

let ModalWorkItem = null;
let ModalNewWorkItem = false;
let ModalWorkItemCalendarDate = null;
// newitemid: -1 if new item, otherwise the id of the workitem to edit
// This is called when either a new work item is requested or when the user decides to edit an existing item
function DoEditSCWorkItem_clicked(newitemid) {
    ModalWorkItem = new C_WorkLog(null);
    ModalNewWorkItem = newitemid === -1;
    if (newitemid !== -1) {
        ModalWorkItem = BackendHelper.FindWorkItem(newitemid);
    }
    else {
        ModalWorkItem.UserId = OurUser.id;
        ModalWorkItem.Date = C_YMD.Now();
    }

    // build a dropdown of users to select from
    let vol = BackendHelper.FindAllVolunteers();
    vol.sort(function (a, b) {
        return a.Name.localeCompare(b.Name);
    });

    let usersChoices = [];
    vol.forEach(function (u) {
        let c = { "text": u.Name, "item" : u.id.toString() };
        usersChoices.push(c);
    });

    let userselitem = ModalWorkItem.UserId.toString();

    let usersOptions = {
        "choices": usersChoices,
        "selitem" : userselitem,
        "dropdownid" : "vitasa_dropdown_users",
        "buttonid" : "vitasa_button_selectuser"
    };
    usersDropDown = new C_DropdownHelper(usersOptions); // this must be in the global space
    usersDropDown.SetHelper("usersDropDown");
    usersDropDown.CreateDropdown();

    BackendHelper.Filter.CalendarDate = ModalWorkItem.Date;
    $('#vitasa_scvolhours_edit_date_i')[0].value = ModalWorkItem.Date.toStringFormat("mmm dd, yyyy");
    $('#vitasa_workitem_hours')[0].value = ModalWorkItem.Hours.toString();
    $('#vitasa_modal_scvolhours_sitename')[0].innerText = OurSite.Name;
    $('#vitasa_modal_title').innerText = "Work Item";

    DrawSCVolHoursCalendar();

    $('#vitasa_modal_scworkitem').modal({});

    BackendHelper.SaveFilter()
        .catch(function (error) {
            console.log(error);
        })
}

function DoApproveSCWorkItem(newitemid) {
    if (newitemid === -1)
        return; // should not happen

    let wi = BackendHelper.FindWorkItem(newitemid); // FindSiteWorkItemById(OurSite, newitemid);
    wi.Approved = true;

    BackendHelper.UpdateWorkLog(wi)
    .then(function () {
        UpdateSCWorkItemRow(wi);
    });
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
$('#vitasa_modal_scworkitem').on('hidden.bs.modal', function () {
    let ae = $(document.activeElement);
    // if it was the cancel button, we can safely just quit
    if (ae.attr("id") === "vitasa_button_cancel") {
        return;
    }

    // unless they hit the save button we will also just quit
    if (ae.attr("id") !== "vitasa_button_save") {
        return;
    }

    let hours = $('#vitasa_workitem_hours')[0].value;
    ModalWorkItem.Hours = parseFloat(hours);
    if (isNaN(ModalWorkItem.Hours))
        ModalWorkItem.Hours = 0;
    ModalWorkItem.Date = ModalWorkItemCalendarDate;
    ModalWorkItem.SiteId = OurSite.id;
    ModalWorkItem.UserId = parseInt(usersDropDown.DropDownSelectedItem);

    // use VolHours_ModalSite null to indicate a new item
    if (ModalNewWorkItem) {
        BackendHelper.CreateWorkLog(ModalWorkItem)
            .then(function() {
                // add to the table
                ClearAllSCWorkItemRows();
                PopulateSCTable();
                ModalNewWorkItem = false;
            })
            .catch(function(error) {
                console.log(error);
            });
    }
    else {
        BackendHelper.UpdateWorkLog(ModalWorkItem)
            .then(function() {
                // add to the table
                UpdateSCWorkItemRow(ModalWorkItem);
                ModalNewWorkItem = false;
            })
            .catch(function(error) {
                console.log(error);
            });
    }
});

function DoDeleteSCWorkItem(wlid) {
    let wli = FindSiteWorkItemById(OurSite, wlid);
    BackendHelper.DeleteWorkLog(wli)
        .then(function (success) {
            if (success)
                $('tr#vitasa_scworkitemrow_' + wli.id.toString()).remove();
        })
        .catch(function (error) {
            console.log(error);
        })
}

function DrawSCVolHoursCalendar() {
    let ourDate = BackendHelper.Filter.CalendarDate;
    let firstDayOfMonthDate = new C_YMD(ourDate.Year, ourDate.Month, 1);
    let firstDayOfMonthDayOfWeek = firstDayOfMonthDate.DayOfWeek();

    $('#vitasa_scvolhours_edit_date')[0].innerText = MonthNames[ourDate.Month - 1] + " - " + ourDate.Year.toString();

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
                    //let thisdate = new C_YMD(ourDate.Year, ourDate.Month, dn);
                    calCel.bgColor = CalendarColor_Site_SiteOpen;
                    calCel.innerText = dn.toString();
                }
            }
            else {
                let date = new C_YMD(ourDate.Year, ourDate.Month, dn);
                let daysInMonth = date.DaysInMonth();

                if (date.Day <= daysInMonth) {
                    calCel.bgColor = CalendarColor_Site_SiteOpen;
                    calCel.innerText = dn.toString();
                }
                else {
                    calCel.bgColor = CalendarColor_Site_NotADate[0];
                    calCel.innerText = "";
                }
            }
        }
    }
}

function SCVolHoursEdit_PreviousMonth() {
    let ourdate = BackendHelper.Filter.CalendarDate;
    ourdate.Month = ourdate.Month - 1;
    if (ourdate.Month === 0) {
        ourdate.Month = 12;
        ourdate.Year--;
    }
    BackendHelper.Filter.CalendarDate = ourdate;

    DrawSCVolHoursCalendar();

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

    DrawSCVolHoursCalendar();

    BackendHelper.SaveFilter()
        .catch(function (error) {
            console.log(error);
        })
}

function scvolhoursworked_modal_dateclicked(element, which) {
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

    ModalWorkItemCalendarDate = date;

    $('#vitasa_scvolhours_edit_date')[0].innerText = MonthNames[date.Month - 1] + " - " + date.Year.toString();
    $('#vitasa_scvolhours_edit_date_i')[0].value = MonthNames[date.Month - 1] + " " + date.Day.toString() + ", " + date.Year.toString();
}



