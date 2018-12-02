let LoggedInUser = null;
var BackendHelper = null;

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

    LoggedInUser = BackendHelper.FindUserByEmail(BackendHelper.UserCredentials.Email);

    $("span#vitasa_username")[0].innerText = LoggedInUser.Name;

    PopulateSitesTable();
}

function PopulateSitesTable() {
    // populate the table
    let sites = BackendHelper.GetAllSites();
    sites.sort(function(a, b) { return a.Name.localeCompare(b.Name); } );

    sites.forEach(function (site) {
        AddAdminSiteRow(site);
    });
}

function AddAdminSiteRow(site) {
    let addr = site.Street + " " + site.City + ", " + site.State;

    let cols = '';
    cols += '<td style="cursor: pointer" id="vitasa_adminsites_site_' + site.id.toString() + '">';
    cols += '<span class="font-weight-bold" id="vitasa_adminsites_name_' + site.id.toString() + '">' + site.Name + '</span>'
        + '<br/><span id="vitasa_adminsites_address_' + site.id.toString() + '">' + addr + '</span>';
    cols += '</td>';

    cols += '<td>';

    cols += '<input type="button" class="btn btn-md btn-primary" id="vitasa_adminsites_details" value="Details" ' +
        'onclick="DoSiteDetails_clicked(' + site.id.toString() + ');">';
    cols += '&nbsp;';

    cols += '<input type="button" class="btn btn-md btn-primary" id="vitasa_adminsites_calendar" value="Calendar" ' +
        'onclick="DoSiteCalendar_clicked(' + site.id.toString() + ');">';
    cols += '&nbsp;';

    cols += '<input type="button" class="btn btn-md btn-primary" id="vitasa_adminsites_coord" value="Coordinators" ' +
        'onclick="DoSiteCoord_clicked(' + site.id.toString() + ');">';
    cols += '&nbsp;';

    cols += '<input type="button" class="btn btn-md btn-danger" id="vitasa_adminsites_deleteuser" value="Delete" ' +
        'onclick="DeleteSite_click(' + site.id.toString() + ');">';

    cols += '</td>';

    const newRow = $('<tr id="vitasa_adminsites_site_' + site.id.toString() + '">');
    newRow.append(cols);
    $("table#vitasa_adminsites_table").append(newRow);
}

function ClearAllAdminSiteRows() {
    let sites = BackendHelper.GetAllSites();
    sites.forEach(function(site) {
        $('tr#vitasa_adminsites_site_' + site.id.toString()).remove();
    });
}

let ModalSite = null;

// ----------------------------------------------------------
//            Site Details
// ----------------------------------------------------------

function DoSiteDetails_clicked(siteid) {
    if (siteid === null)
        return;
    let site = null;
    if (siteid !== -1)
        site = BackendHelper.FindSiteById(siteid);
    else
        site = new C_Site(null);
    ModalSite = site;

    $('#vitasa_adminsites_name')[0].value = site.Name;
    $('#vitasa_adminsites_street')[0].value = site.Street;
    $('#vitasa_adminsites_city')[0].value = site.City;
    $('#vitasa_adminsites_zip')[0].value = site.Zip;
    $('#vitasa_adminsites_latitude')[0].value = site.Latitude;
    $('#vitasa_adminsites_longitude')[0].value = site.Longitude;

    SelectedState = site.State;
    $('#vitasa_adminsites_state')[0].value = site.State;

    $('input#vitasa_adminsites_mobile')[0].checked = site.SiteType.toLowerCase() === "mobile";
    $('input#vitasa_adminsites_dropoff')[0].checked = site.SiteCapabilities.includes("DropOff");
    $('input#vitasa_adminsites_express')[0].checked = site.SiteCapabilities.includes("Express");
    $('input#vitasa_adminsites_mft')[0].checked = site.SiteCapabilities.includes("MFT");
    $('input#vitasa_adminsites_inperson')[0].checked = site.SiteCapabilities.includes("InPerson");

    $('#vitasa_modal_adminsites_details').modal({});
}

let SelectedState = null;
function state_click(st) {
    $('#vitasa_adminsites_state')[0].value = st;
    SelectedState = st;
}

// Called when the edit workitem modal is closed by user action
$('#vitasa_modal_adminsites_details').on('hidden.bs.modal', function () {
    // if it was the cancel button, we can safely just quit
    let clickedbuttonid = $(document.activeElement).attr("id");
    if (clickedbuttonid === "vitasa_button_cancel") {
        return;
    }

    if (clickedbuttonid !== "vitasa_button_save")
        return;

    let site = ModalSite;

    site.Name = $('#vitasa_adminsites_name')[0].value;
    site.Street = $('#vitasa_adminsites_street')[0].value;
    site.City = $('#vitasa_adminsites_city')[0].value;
    site.Zip = $('#vitasa_adminsites_zip')[0].value;
    site.Latitude = $('#vitasa_adminsites_latitude')[0].value;
    site.Longitude = $('#vitasa_adminsites_longitude')[0].value;
    site.State = $('#vitasa_adminsites_state')[0].value;

    let mobile = $('input#vitasa_adminsites_mobile')[0].checked;
    let dropoff = $('input#vitasa_adminsites_dropoff')[0].checked;
    let express = $('input#vitasa_adminsites_express')[0].checked;
    let mft = $('input#vitasa_adminsites_mft')[0].checked;
    let inperson = $('input#vitasa_adminsites_inperson')[0].checked;

    site.SiteType = mobile ? "Mobile" : "Fixed";
    site.SiteCapabilities = [];
    if (dropoff)
        site.SiteCapabilities.push("DropOff");
    if (express)
        site.SiteCapabilities.push("Express");
    if (mft)
        site.SiteCapabilities.push("MFT");
    if (inperson)
        site.SiteCapabilities.push("InPerson");

    if (ModalSite.id !== -1) {
        BackendHelper.UpdateSite(site)
            .then(function () {
                ClearAllAdminSiteRows();
                PopulateSitesTable();

                // UpdateAdminSiteRow(VolHours_ModalSite);

                ModalSite = null;
            })
            .catch(function (error) {
                ModalSite = null;
                console.log(error);
            });
    } else {
        BackendHelper.CreateSite(site)
            .then(function () {
                ModalSite = null;

                ClearAllAdminSiteRows();
                PopulateSitesTable();
            })
            .catch(function (error) {
                ModalSite = null;
                console.log(error);
            });
    }

    ModalSite = null;
});

// ----------------------------------------------------------
//            Site Calendar
// ----------------------------------------------------------

function DoSiteCalendar_clicked(siteid) {
    if (siteid === null)
        return;
    let site = null;
    if (siteid !== -1)
        site = BackendHelper.FindSiteById(siteid);
    else
        site = new C_Site(null);
    ModalSite = site;

    window.location.href = "adminsitescal.html?siteslug=" + site.Slug;
}

// ----------------------------------------------------------
//            Site Coordinators
// ----------------------------------------------------------

function DoSiteCoord_clicked(siteid) {
    if (siteid === null)
        return;

    let site = null;
    if (siteid !== -1)
        site = BackendHelper.FindSiteById(siteid);
    else
        site = new C_Site(null);
    ModalSite = site;

    window.location.href = "adminsitescoord.html?siteslug=" + site.Slug;
}

// ----------------------------------------------------------
//            Site Delete
// ----------------------------------------------------------

let SiteIdToDelete = null;
function DeleteSite_click(siteid) {
    if (siteid === null)
        return;
    let site = null;
    if (siteid !== -1)
        site = BackendHelper.FindSiteById(siteid);
    else
        site = new C_Site(null);
    ModalSite = site;
    SiteIdToDelete = site.id;

    MessageBox(
        'Confirm',
        'Are you sure you want to delete "' + site.Name + '"? THERE IS NO UNDO.',
        [ "Yes", "No" ],
        DeleteSiteConfirm
    );
}

function DeleteSiteConfirm(button) {
    if (button.toLowerCase() === "yes") {
        // remove the user from the db
        let site = BackendHelper.FindSiteById(SiteIdToDelete);
        if (site !== null) {
            ClearAllAdminSiteRows();

            BackendHelper.DeleteSite(site)
                .then(function () {
                    // re-populate the table
                    PopulateSitesTable();
                })
                .catch(function (error) {
                    console.log(error);
                });
        }
    }
}



