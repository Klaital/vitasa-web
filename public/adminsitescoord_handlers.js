let LoggedInUser = null;
let OurSiteSlug = null;
let OurSite = null;
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

    LoggedInUser = BackendHelper.FindUserByEmail(BackendHelper.UserCredentials.Email);

    $("span#vitasa_username")[0].innerText = LoggedInUser.Name;

    let hrefs = window.location.href.split('?');
    let siteslugs = hrefs[1].split('=');

    OurSiteSlug = siteslugs[1];

    OurSite = BackendHelper.FindSiteBySlug(OurSiteSlug);

    $('#vitasa_adminsitescoord_sitename')[0].innerText = OurSite.Name;

    PopulateSiteCoordinatorsTable();
}

let SiteCoordinators = null;
function PopulateSiteCoordinatorsTable() {
    SiteCoordinators = [];
    let users = BackendHelper.GetAllUsers();
    users.forEach(function (user) {
        if (user.HasSiteCoordinator())
            SiteCoordinators.push(user);
    });
    SiteCoordinators.sort(function(a, b) { return a.Name.localeCompare(b.Name); } );

    SiteCoordinators.forEach(function (sc) {
        AddAdminSiteCoordRow(sc);
    });
}

function AdminSitesCoordSaveAndReturn(save) {
    if (save === 1) {
        // do the save
        SaveSiteCoordinatorsFromList()
            .then(function () {
                window.location.href = 'adminsites.html';
            })
            .catch(function (error) {
                console.log(error);
            })
    }

    // and return
    window.location.href = 'adminsites.html';
}

function AddAdminSiteCoordRow(user) {
    let checked_s = "";
    for(let ix = 0; ix !== user.SitesCoordinated.length; ix ++) {
        let scix = user.SitesCoordinated[ix];
        if (scix.SiteId === OurSite.id) {
            checked_s = "checked";
            break;
        }
    }

    let cols = '<td>';
    cols += '<div class="custom-control custom-checkbox">';
    cols += '&nbsp;<input type="checkbox" class="custom-control-input" id="vitasa_adminsitescoord_cb_' + user.id.toString() + '" ' + checked_s + '>';
    cols += '<label class="custom-control-label" for="vitasa_adminsitescoord_cb_' + user.id.toString() + '">' + user.Name + '</label>';
    cols += '</td>';

    const newRow = $('<tr id="vitasa_adminsitescoord_user_' + user.id.toString() + '">');
    newRow.append(cols);
    $("table#vitasa_adminsitescoord_table").append(newRow);
}

async function SaveSiteCoordinatorsFromList() {
    let coordinatorsAdded = [];
    let coordinatorsRemoved = [];

    SiteCoordinators.forEach(function (user) {
        let ss = 'vitasa_adminsitescoord_cb_' + user.id.toString();
        let checked = $('#' + ss)[0].checked;

        if (checked) {
            // expect to find this site in this user's list of sitescoordinated; if missing, then add
            let found = false;
            for(let ix = 0; ix !== user.SitesCoordinated.length; ix ++) {
                let scix = user.SitesCoordinated[ix];
                if (scix.SiteId === OurSite.id) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                let sc = C_SiteCoordinated.Create(OurSite.id, OurSite.Name, OurSite.Slug);
                sc.userid = user.id;
                coordinatorsAdded.push(sc);
            }

        } else {
            // expect to find that this is not in our users list; if found then remove
            // expect to find this site in our users list of sitescoordinated; if missing, then add
            let found = false;
            for(let ix = 0; ix !== user.SitesCoordinated.length; ix ++) {
                let scix = user.SitesCoordinated[ix];
                if (scix.SiteId === OurSite.id) {
                    found = true;
                    break;
                }
            }
            if (found) {
                let sc = C_SiteCoordinated.Create(OurSite.id, OurSite.Name, OurSite.Slug);
                sc.userid = user.id;
                coordinatorsRemoved.push(sc);
            }
        }
    });

    for(let ix = 0; ix !== coordinatorsAdded.length; ix++) {
        let sc = coordinatorsAdded[ix];
        let user = BackendHelper.FindUserById(sc.userid);
        await BackendHelper.AddSiteCoordinatorForSite(user, sc.SiteId);
    }

    for(let ix = 0; ix !== coordinatorsRemoved.length; ix++) {
        let sc = coordinatorsAdded[ix];
        let user = BackendHelper.FindUserById(sc.userid);
        await BackendHelper.RemoveSiteCoordinatorForSite(user, sc.SiteId);
    }
}


