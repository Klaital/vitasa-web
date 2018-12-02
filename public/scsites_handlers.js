let OurUser = null;
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

    OurUser = BackendHelper.FindUserByEmail(BackendHelper.UserCredentials.Email);

    PopulateTable();
}

function PopulateTable() {
    OurUser.SitesCoordinated.sort(function (a, b) {
       return a.Name.localeCompare(b.Name);
    });

    OurUser.SitesCoordinated.forEach(function (sitecoordinated) {
        AddSitesRow(sitecoordinated);
    });
}

function AddSitesRow(sitecoordinated) {

    const newRow = $('<tr>');
    let cols = "";

    cols += '<td>';
    cols += '<a style="cursor: pointer" id="' + sitecoordinated.SiteSlug
        + '" onclick="siterow_click(\'' + sitecoordinated.SiteSlug + '\'); ">' + sitecoordinated.SiteName + '</a>';
    cols += '</td>';
    newRow.append(cols);
    $("table#vitasa_sites_table").append(newRow);
}

function siterow_click(slug) {
    BackendHelper.Filter.SelectedSiteSlug = slug;
    BackendHelper.SaveFilter()
        .then(function () {
            window.location.href = 'scsitecalendar.html';
        })
        .catch(function (error) {
            console.log(error);
        });
}

function DoViewEditSCVolHours() {
    window.location.href = "scvolhours.html";
}