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

    $("span#vitasa_username")[0].innerText = OurUser.Name;

    PopulateUsersTable();
}

function PopulateUsersTable() {
    let users = BackendHelper.GetAllUsers();
    // populate the table
    users.sort(function(a, b) { return a.Name.localeCompare(b.Name); } );

    users.forEach(function (user) {
        AddAdminUserRow(user);
    });
}

function AddAdminUserRow(user) {
    let userrole = 'Undefined';
    if (user.HasAdmin())
        userrole = "Admin";
    else if (user.HasSiteCoordinator())
        userrole = "Site Coordinator";
    else if (user.HasVolunteer())
        userrole = "Volunteer";

    let cols = '';
    cols += '<td style="cursor: pointer" id="vitasa_adminusers_user_' + user.id.toString() + '">';
    cols += '<span class="font-weight-bold" id="vitasa_adminusers_username_' + user.id.toString() + '">' + user.Name + '</span>'
        + '<br/><span id="vitasa_adminusers_usercertrole_' + user.id.toString() + '" >[' + user.Certification + '] ' + userrole + '</span>';
    cols += '</td>';

    cols += '<td>';

    cols += '<input type="button" class="btn btn-md btn-primary" id="vitasa_adminusers_edituser" value="Edit" ' +
        'onclick="DoEditAdminUser_clicked(' + user.id.toString() + ');">';
    cols += '&nbsp;';

    cols += '<input type="button" class="btn btn-md btn-danger" id="vitasa_adminusers_deleteuser" value="Delete" ' +
        'onclick="DeleteUser_click(' + user.id.toString() + ');">';
    if (user.HasSiteCoordinator()) {
        cols += '&nbsp;';
        cols += '<input type="button" class="btn btn-md btn-primary" id="vitasa_adminusers_sitescoord" value="Sites Coord" ' +
            'onclick="DoAdminUserSitesCoord(' + user.id.toString() + ');">';
        cols += '</td>';
    }

    const newRow = $('<tr id="vitasa_adminusers_user_' + user.id.toString() + '">');
    newRow.append(cols);
    $("table#vitasa_adminusers_table").append(newRow);
}

// function UpdateAdminUserRow(user) {
//     let userrole = 'Undefined';
//     if (user.HasAdmin())
//         userrole = "Admin";
//     else if (user.HasSiteCoordinator())
//         userrole = "Site Coordinator";
//     else if (user.HasVolunteer())
//         userrole = "Volunteer";
//
//     let nr = $("#vitasa_adminusers_username_" + user.id.toString());
//     let crr = $("#vitasa_adminusers_usercertrole_" + user.id.toString());
//
//     nr[0].innerText = user.Name;
//     crr[0].innerText = '<br/> [' + user.Certification + '] ' + userrole;
// }

function ClearAllAdminUserRows() {
    let users = BackendHelper.GetAllUsers();
    users.forEach(function(user) {
        $('tr#vitasa_adminusers_user_' + user.id.toString()).remove();
    });
}

let ModalUser = null;

// Called with userid == -1 means to create a new user
function DoEditAdminUser_clicked(userid) {
    ModalUser = (userid === -1) ? new C_User(null) : BackendHelper.FindUserById(userid);

    $('#vitasa_adminusers_username')[0].value = ModalUser.Name;
    $('#vitasa_adminusers_useremail')[0].value = ModalUser.Email;
    $('#vitasa_adminusers_phone')[0].value = ModalUser.Phone;
    $('input#vitasa_adminusers_mobile')[0].checked = ModalUser.HasMobile();

    let certChoices =
        [
            { "text" : "None", "item" : "None" },
            { "text" : "Basic", "item" : "Basic" },
            { "text" : "Advanced", "item" : "Advanced" }
        ];

    let certselitem = ModalUser.Certification;

    let certOptions = {
        "choices": certChoices,
        "selitem" : certselitem,
        "dropdownid" : "vitasa_dropdown_adminusers_cert",
        "buttonid" : "vitasa_button_adminusers_cert"
    };
    certDropDown = new C_DropdownHelper(certOptions);
    certDropDown.SetHelper("certDropDown");
    certDropDown.CreateDropdown();

    let roleChoices =
        [
            { "text" : "None", "item" : "None" },
            { "text" : "Volunteer", "item" : "Volunteer" },
            { "text" : "Site Coordinator", "item" : "SiteCoordinator" },
            { "text" : "Admin", "item" : "Admin" }
        ];

    let roleselitem = "None";
    if (ModalUser.HasAdmin())
        roleselitem = "Admin";
    else if (ModalUser.HasSiteCoordinator())
        roleselitem = "SiteCoordinator";
    else if (ModalUser.HasVolunteer())
        roleselitem = "Volunteer";

    let roleOptions = {
        "choices": roleChoices,
        "selitem" : roleselitem,
        "dropdownid" : "vitasa_dropdown_adminusers_role",
        "buttonid" : "vitasa_button_adminusers_role"
    };
    roleDropDown = new C_DropdownHelper(roleOptions);
    roleDropDown.SetHelper("roleDropDown");
    roleDropDown.CreateDropdown();

    $('#vitasa_modal_adminusers_edituser').modal({});
}

// Called when the edit workitem modal is closed by user action
$('#vitasa_modal_adminusers_edituser').on('hidden.bs.modal', function () {
    // if it was the cancel button, we can safely just quit
    let clickedbuttonid = $(document.activeElement).attr("id");
    if (clickedbuttonid === "vitasa_button_cancel") {
        return;
    }

    if (clickedbuttonid !== "vitasa_button_save")
        return;

    let pw =  $('#vitasa_adminusers_pw')[0].value;
    let pwc =  $('#vitasa_adminusers_pwc')[0].value;

    if ((pw !== pwc) && (pw.length !== 0)) {
        ErrorMessageBox("Passwords do not match.");
        return;
    }

    let name =  $('#vitasa_adminusers_username')[0].value;
    let email = $('#vitasa_adminusers_useremail')[0].value;
    let phone = $('#vitasa_adminusers_phone')[0].value;
    let mobile = $('input#vitasa_adminusers_mobile')[0].checked;
    let cert = certDropDown.DropDownSelectedItem;
    let role = roleDropDown.DropDownSelectedItem;

    ClearAllAdminUserRows();

    if (ModalUser.id === -1) {
        ModalUser.Name = name;
        ModalUser.Email = email;
        ModalUser.Phone = phone;
        ModalUser.Roles = [];
        if (mobile)
            ModalUser.Roles.push("Mobile");
        ModalUser.Roles.push(role);
        ModalUser.Password = pw;

        // todo: complain if the passwords are blank or don't match

        BackendHelper.CreateUser(ModalUser)
            .then(function () {
                ModalUser = null;
                PopulateUsersTable();
            })
            .catch(function (error) {
                console.log(error);
            });
    } else {
        ModalUser.Name = name;
        ModalUser.Email = email;
        ModalUser.Phone = phone;
        ModalUser.Certification = cert;

        let roles = [];
        roles.push(role);
        if (mobile)
            roles.push("Mobile");
        ModalUser.Roles = roles;

        if((pw === pwc) && (pw.length > 6))
            ModalUser.Password = pw;

        // todo: complain if the passwords don't match

        BackendHelper.UpdateUser(ModalUser)
            .then(function () {
                ModalUser = null;
                PopulateUsersTable();
            })
            .catch(function (error) {
                console.log(error);
            });
    }

    ModalUser = null;
});

let UserIdToDelete = -1;
function DeleteUser_click(userid) {
    UserIdToDelete = userid;

    MessageBox(
        'Confirm',
        'Are you sure you want to delete this user? There is no undo.',
        [ "Yes", "No" ],
        DeleteConfirm
    );
}

// // called when the user wants to delete a workitem
// $('table').on('click','#vitasa_adminusers_deleteuser',function(){
// });

function DeleteConfirm(button) {
    if (button.toLowerCase() === "yes") {
        // remove the user from the db
        let user = BackendHelper.FindUserById(UserIdToDelete);
        if (user !== null) {
            ClearAllAdminUserRows();

            BackendHelper.DeleteUser(user)
                .then(function () {
                    // re-populate the table
                    PopulateUsersTable();
                })
                .catch(function (error) {
                    console.log(error);
                });
        }
    }
}

function DoAdminUserSitesCoord(userid) {
    let user = BackendHelper.FindUserById(userid);
    if (user === null)
        return;

    ModalUser = user;

    $('#vitasa_modal_adminusers_username')[0].innerText = 'Sites Coordinated by ' + user.Name;

    let sites = BackendHelper.GetAllSites();
    sites.forEach(function(site) {
        AddRowToSitesCoordTable(site, user);
    });

    $('#vitasa_modal_adminusers_sitecoord').modal({});
}

// Called when the edit workitem modal is closed by user action
$('#vitasa_modal_adminusers_sitecoord').on('hidden.bs.modal', function () {
    // if it was the cancel button, we can safely just quit
    let clickedbuttonid = $(document.activeElement).attr("id");
    if (clickedbuttonid === "vitasa_button_adminusers_cancel") {
        ClearSitesList();
        return;
    }

    if (clickedbuttonid !== "vitasa_button_adminusers_save") {
        ClearSitesList();
        return;
    }

    // do an update on the site coords
    let sites = BackendHelper.GetAllSites();
    let checkedSites = [];
    sites.forEach(function(site) {
        let id_ = "#vitasa_adminusers_sitescoord_" + site.id.toString();
        let id_e = $(id_);
        let checked = id_e[0].checked;
        if (checked)
            checkedSites.push(site);
    });

    // for every site in checkedSites that is not in the ModalUser's list, add that site
    let addList = [];
    checkedSites.forEach(function (site) {
        let foundInUserList = false;
        for(let ix = 0; ix !== ModalUser.SitesCoordinated.length; ix++) {
            let scix = ModalUser.SitesCoordinated[ix];
            if (scix.SiteId === site.id) {
                foundInUserList = true;
                break;
            }
        }
        if (!foundInUserList) {
            // add this site to the user's list
            addList.push(site);
        }
    });
    if (addList.length !== 0) {
        addList.forEach(function (site) {
            //let sc = C_SiteCoordinated.Create(site.id, site.Name, site.Slug);
            BackendHelper.AddSiteCoordinatorForSite(ModalUser, site)
                .catch(function (error) {
                   console.log(error);
                });
        })
    }

    // for every site in the user's list that is NOT in the checkedSites list, remove that site
    let removeList = [];
    ModalUser.SitesCoordinated.forEach(function (sc) {
        let foundInCheckedSitesList = false;
        for(let ix = 0; ix !== checkedSites.length; ix ++) {
            let cix = checkedSites[ix];
            if (cix.id === sc.SiteId) {
                foundInCheckedSitesList = true;
                break;
            }
        }
        if (!foundInCheckedSitesList){
            removeList.push(sc);
        }
    });
    if (removeList.length !== 0) {
        removeList.forEach(function (sc) {
            // remove this site from user list
            BackendHelper.RemoveSiteCoordinatorForSite(ModalUser, sc.SiteId)
                .catch(function (error) {
                    console.log(error);
                })
        })
    }

    ClearSitesList();
});


function AddRowToSitesCoordTable(site, user) {
    let checked = false;

    for(let ix = 0; ix !== user.SitesCoordinated.length; ix++) {
        let scix = user.SitesCoordinated[ix];
        if (scix.SiteId === site.id) {
            checked = true;
            break;
        }
    }

    let checked_s = checked ? "checked" : "";

    let cols = '<div class="custom-control custom-checkbox">';
    cols += '&nbsp;<input type="checkbox" class="custom-control-input" id="vitasa_adminusers_sitescoord_' + site.id.toString() + '" ' + checked_s + '>';
    cols += '<label class="custom-control-label" for="vitasa_adminusers_sitescoord_' + site.id.toString() + '">' + site.Name + '</label>';

    const newRow = $('<div class="custom-control custom-checkbox">');
    newRow.append(cols);
    $("div#vitasa_adminusers_sitecoord_list").append(newRow);
}

function ClearSitesList() {
    $('#vitasa_adminusers_sitecoord_list')[0].innerHTML = '';
}
