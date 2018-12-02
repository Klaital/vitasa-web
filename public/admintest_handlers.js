let OurUser = null;
var BackendHelper = null;

let Reports = [ "Sites", "Get Site", "Create Site", "Update Site", "Delete Site", "Login", "Register" ];

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
    //BackendHelper.UsingOnlyLocalData = true;

    InitMenuItems(BackendHelper.UserCredentials);

    OurUser = BackendHelper.FindUserByEmail(BackendHelper.UserCredentials.Email);

    $("span#vitasa_username")[0].innerText = OurUser.Name;

    PopulateReportsTable();
}

function PopulateReportsTable() {
    Reports.forEach(function (r) {
        AddReportRow(r);
    });
}

function AddReportRow(r) {
    let cols = '';
    cols += '<td>';
    cols += '   <span>' + r + '</span>';
    cols += '</td>';

    cols += '<td>';
    cols += '   <input type="button" class="btn btn-md btn-primary" value="Execute" onclick="AdminReport_clicked(\'' + r + '\');">';
    cols += '</td>';

    const newRow = $('<tr>');
    newRow.append(cols);
    $("table#vitasa_adminreports_table").append(newRow);
}

function AdminReport_clicked(report) {
    if (Reports.indexOf(report) === 0) {
        TestGetAllSites();
    } else if (Reports.indexOf(report) === 1) {
        TestGetSite();
    } else if (Reports.indexOf(report) === 2) {
        TestCreateSite();
    } else if (Reports.indexOf(report) === 3) {
        TestUpdateSite()
    } else if (Reports.indexOf(report) === 4) {
        TestDeleteSite();
    } else if (Reports.indexOf(report) === 5) {
        TestLogin();
    } else if (Reports.indexOf(report) === 6) {
        DoRegister();
    }
}

function TestGetAllSites() {
    // SetUseOfTestData(false);
    // FetchAllSitesAsync()
    //     .then(function (sites) {
    //         console.log("yeah");
    //         SetUseOfTestData(true);
    //     })
    //     .catch(function (error) {
    //         console.log(error);
    //         SetUseOfTestData(true);
    //     })
}

function TestGetSite() {
}

function TestCreateSite() {
    // SetUseOfTestData(false);
    // let site = Sites[0];
    // FetchSiteAsync(Sites[0].Slug)
    //     .then(function (site) {
    //         console.log("yeah");
    //         SetUseOfTestData(true);
    //     })
    //     .catch(function (error) {
    //         console.log(error);
    //         SetUseOfTestData(true);
    //     })
}

function TestUpdateSite() {
    
}

function TestDeleteSite() {
    
}

function TestLogin() {
    BackendHelper.DoLogin("admin@g.c", "123456abc")
        .then(function (user) {
            console.log("login yeah");
            //SetUseOfTestData(true);
        })
        .catch(function (error) {
            console.log(error);
            //SetUseOfTestData(true);
        })
}

function DoRegister() {
    RegisterUserAsync("admin user", "admin@g.c", "123456abc", "123-123-1324")
        .then(function (success) {
            console.log("yeah");
        })
        .catch(function (error) {
            console.log(error);
        })
}



