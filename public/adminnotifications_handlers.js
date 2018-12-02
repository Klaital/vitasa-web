let LoggedInUser = null;
let Notifications = null;
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

    Notifications = await BackendHelper.GetAllNotifications();

    InitMenuItems(BackendHelper.UserCredentials);

    LoggedInUser = BackendHelper.FindUserByEmail(BackendHelper.UserCredentials.Email);

    $("span#vitasa_username")[0].innerText = LoggedInUser.Name;

    PopulateNotificationsTable();
}

function PopulateNotificationsTable() {
    Notifications.forEach(function (note) {
        AddAdminNotificationRow(note);
    });
}

function AddAdminNotificationRow(note) {
    let cols = '';
    cols += '<td style="cursor: pointer" id="vitasa_adminnotifications_note_' + note.id.toString() + '">';
    cols += '<span class="font-weight-bold" id="vitasa_adminnotifications_msg_' + note.id.toString() + '">' + note.Message + '</span>';
    cols += '</td>';

    cols += '<td>';
    cols += '<span id="vitasa_adminnotifications_audience_' + note.id.toString() + '">' + note.Audience + '</span>';
    cols += '</td>';

    cols += '<td>';
    cols += '<input type="button" class="btn btn-md btn-primary" id="vitasa_adminnotifications_editsend_" value="Edit/Send" ' +
        'onclick="DoNotificationEditSend_Click(' + note.id.toString() + ');">';
    cols += '&nbsp;';

    cols += '<input type="button" class="btn btn-md btn-danger" id="vitasa_adminnotifications_delete_" value="Delete" ' +
        'onclick="DoNotificationDelete_Click(' + note.id.toString() + ');">';

    cols += '</td>';

    const newRow = $('<tr id="vitasa_adminnotifications_note_' + note.id.toString() + '">');
    newRow.append(cols);
    $("table#vitasa_adminnotifications_table").append(newRow);
}

function ClearAllAdminNotificationRows() {
    Notifications.forEach(function(note) {
        $('tr#vitasa_adminnotifications_note_' + note.id.toString()).remove();
    });
}

let ModalNotification = null;

// ----------------------------------------------------------
//            Site Edit and/or Send
// ----------------------------------------------------------

function DoNotificationEditSend_Click(noteid) {
    ModalNotification = null;
    if (noteid === -1) {
        ModalNotification = new C_Notification(null);
    } else {
        for (let ix = 0; ix !== Notifications.length; ix++) {
            if (Notifications[ix].id === noteid) {
                ModalNotification = Notifications[ix];
                break;
            }
        }
    }

    let audienceChoices =
        [
            { "text" : "Volunteers", "item" : "volunteers" },
            { "text" : "Site Coordinators", "item" : "SiteCoordinators" }
        ];

    let audienceOptions = {
        "choices": audienceChoices,
        "selitem" : ModalNotification.Audience,
        "dropdownid" : "vitasa_button_adminnotifications_audience",
        "buttonid" : "vitasa_button_adminnotifications_audience"
    };
    audienceDropDown = new C_DropdownHelper(audienceOptions);
    audienceDropDown.SetHelper("audienceDropDown");
    audienceDropDown.CreateDropdown();

    let symd = ModalNotification.Sent.YMD;
    let symd_s = MonthNames[symd.Month - 1] + " " + symd.Day.toString() + ", " + symd.Year.toString();
    let shms = ModalNotification.Sent.HMS;
    let shms_s = shms.Hour.toString() + ":" + C_YMDhms.PadTo(shms.Minute.toString(), 2) + ":" + C_YMDhms.PadTo(shms.Minute.toString(), 2);
    $('#vitasa_adminnotification_sent')[0].value = symd_s + " at " + shms_s;

    $('#vitasa_adminnotification_message')[0].value = ModalNotification.Message;

    $('#vitasa_modal_adminnotifications_editsend').modal({});
}


// Called when the edit workitem modal is closed by user action
$('#vitasa_modal_adminnotifications_editsend').on('hidden.bs.modal', function () {
    // if it was the cancel button, we can safely just quit
    let clickedbuttonid = $(document.activeElement).attr("id");
    if (clickedbuttonid === "vitasa_button_cancel") {
        return;
    }

    if (clickedbuttonid === "vitasa_button_save") {
        // get the values from the form
        ModalNotification.Audience = audienceDropDown.DropDownSelectedItem;
        ModalNotification.Message = $('#vitasa_adminnotification_message')[0].value;

        ClearAllAdminNotificationRows();

        // do the save and send part
        BackendHelper.PostNotification(ModalNotification)
            .then(function (success) {
                ModalNotification = null;
                PopulateNotificationsTable();

                if (!success) {
                    MessageBox("Error", "Unable to save or send the notification.", [ "Ok" ], null);
                }
            })
            .catch(function (error) {
                console.log(error);
            });
    }
});

// ----------------------------------------------------------
//            Notification Delete
// ----------------------------------------------------------

function DoNotificationDelete_Click(noteid) {
    if (noteid === -1)
        return;

    ModalNotification = null;
    for(let ix = 0; ix !== Notifications.length; ix++) {
        if (Notifications[ix].id === noteid) {
            ModalNotification = Notifications[ix];
            break;
        }
    }

    MessageBox(
        'Confirm',
        'Are you sure you want to delete this notification? THERE IS NO UNDO.',
        [ "Yes", "No" ],
        DeleteNotificationConfirm
    );
}

function DeleteNotificationConfirm(button) {
    if (button.toLowerCase() !== "yes")
        return;

    ClearAllAdminNotificationRows();

    BackendHelper.DeleteNotification(ModalNotification)
        .then(function (success) {
            if (success) {
                BackendHelper.GetAllNotifications()
                    .then(function (suggestions) {
                        Suggestions = suggestions;
                        PopulateNotificationsTable();
                    })
                    .catch(function (error) {
                        console.log(error);
                    });
            } else {
                MessageBox("Error", "Unable to delete the notification.", [ "Ok" ], null);
            }
        })
        .catch(function (error) {
            console.log(error);
        });
}

// ----------------------------------------------------------
//            New Notification
// ----------------------------------------------------------

function AdminNotificationsNew() {
    DoNotificationEditSend_Click(-1);
}




