let LoggedInUser = null;
let Subscribers = null;
let AllUsers = null;
let NewUserEmail = false;
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

    AllUsers = BackendHelper.GetAllUsers();

    InitMenuItems(BackendHelper.UserCredentials);

    LoggedInUser = BackendHelper.FindUserByEmail(BackendHelper.UserCredentials.Email);

    Suggestions = await BackendHelper.GetAllSuggestions();

    let hrefs = window.location.href.split('?');
    let option = hrefs[1].split('=');
    NewUserEmail = option[1] === "newuser";
    
    let doctitle = NewUserEmail ? "New User" : "New Suggestion";
    $('#vitasa_admin_pagetitle')[0].innerText = "VITA SA - Admin Email Subscriptions for " + doctitle;

    $("span#vitasa_username")[0].innerText = LoggedInUser.Name;

    PopulateEmailTable();
}

function PopulateEmailTable() {
    // build the list of users subscribed to new user email
    Subscribers = [];
    AllUsers.forEach(function (user) {
        if (user.HasAdmin())
            Subscribers.push(user);
    });

    Subscribers.forEach(function (user) {
        AddAdminEmailRow(user);
    });
}

function AddAdminEmailRow(user) {
    let checked = (NewUserEmail && user.SubscribeEmailNewUser) || (!NewUserEmail && user.SubscribeEmailFeedback);
    let checked_s = checked ? " checked" : "";
    
    let cols = '<td>';
    cols += '<div class="custom-control custom-checkbox">';
    cols += '&nbsp;<input type="checkbox" class="custom-control-input" id="vitasa_adminemail_cb_' + user.id.toString() + '" ' + checked_s + '>';
    cols += '<label class="custom-control-label" for="vitasa_adminemail_cb_' + user.id.toString() + '">' + user.Name + '</label>';
    cols += '</td>';

    const newRow = $('<tr id="vitasa_adminemail_sub_' + user.id.toString() + '">');
    newRow.append(cols);
    $("table#vitasa_adminemail_table").append(newRow);
}

// function ClearAllAdminSuggestionRows() {
//     Subscribers.forEach(function(user) {
//         $('tr#vitasa_adminemail_sub_' + user.id.toString()).remove();
//     });
// }

function AdminEmailSubscriptionsSave() {
    // build a list of user for which we need to change their subscriptions
    let changeSubscriptions = []; // list of C_User
    Subscribers.forEach(function (user) {
        let checked = $('#vitasa_adminemail_cb_' + user.id.toString())[0].checked;
        if (NewUserEmail) {
            if (checked !== user.SubscribeEmailNewUser) {
                changeSubscriptions.push(user);
                user.SubscribeEmailNewUser = checked;
            }
        } else {
            if (checked !== user.SubscribeEmailFeedback) {
                changeSubscriptions.push(user);
                user.SubscribeEmailFeedback = checked;
            }
        }
    });

    UpdateUsers(changeSubscriptions)
        .then(function (success) {
            if (success)
                window.location.href = "index.html";
            else
                ErrorMessageBox("Unable to save subscriptions to one or more users.");
        })
        .catch(function (error) {
            console.log(error);
        })
}

/**
 * @return {boolean}
 */
async function UpdateUsers(users) {
    let success = true;
    for(let ix = 0; ix !== users.length; ix++) {
        let user = users[ix];

        await BackendHelper.UpdateUser(user);
    }

    return success;
}




