let OurUser = null;
var BackendHelper = null;

let Reports = [ "WorkLog" ];

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
    cols += '   <input type="button" class="btn btn-md btn-primary" value="Download" onclick="AdminReport_clicked(\'' + r + '\');">';
    cols += '</td>';

    const newRow = $('<tr>');
    newRow.append(cols);
    $("table#vitasa_adminreports_table").append(newRow);
}

function AdminReport_clicked(report) {
    if (Reports.indexOf(report) === 0) {
        DoWorkLogReport();
    }
}

function DoWorkLogReport() {
    let msg = '';
    msg += 'col1,col2,col3\n';
    msg += '1,2,3\n';
    msg += '4,5,6\n';

    download('worklog.csv', msg);
}
