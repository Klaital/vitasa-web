let LoggedInUser = null;
let Suggestions = null;
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

    Suggestions = await BackendHelper.GetAllSuggestions();

    $("span#vitasa_username")[0].innerText = LoggedInUser.Name;

    PopulateSuggestionsTable();
}

function PopulateSuggestionsTable() {
    Suggestions.forEach(function (sug) {
        AddAdminSuggestionRow(sug);
    });
}

function AddAdminSuggestionRow(sug) {
    let cols = '';
    cols += '<td style="cursor: pointer" id="vitasa_adminsuggestions_sug_' + sug.id.toString() + '">';
    cols += '<span class="font-weight-bold" id="vitasa_adminsuggestions_msg_' + sug.id.toString() + '">' + sug.Subject + '</span>' +
    '<span id="vitasa_adminsuggetions_text_' + sug.id.toString() + '">' + sug.Text + '</span>';
    cols += '</td>';

    cols += '<td>';
    cols += '<input type="button" class="btn btn-md btn-primary" id="vitasa_adminsuggestions_editsend_" value="Edit/Send" ' +
        'onclick="DoSuggestionEditSend_Click(' + sug.id.toString() + ');">';
    cols += '&nbsp;';

    cols += '<input type="button" class="btn btn-md btn-danger" id="vitasa_adminsuggestions_delete_" value="Delete" ' +
        'onclick="DoSuggestionDelete_Click(' + sug.id.toString() + ');">';

    cols += '</td>';

    const newRow = $('<tr id="vitasa_adminsuggestions_sug_' + sug.id.toString() + '">');
    newRow.append(cols);
    $("table#vitasa_adminnotifications_table").append(newRow);
}

function ClearAllAdminSuggestionRows() {
    Suggestions.forEach(function(sug) {
        $('tr#vitasa_adminsuggestions_sug_' + sug.id.toString()).remove();
    });
}

let ModalSuggestion = null;

// ----------------------------------------------------------
//            Site Edit and/or Send
// ----------------------------------------------------------

function DoSuggestionEditSend_Click(noteid) {
    ModalSuggestion = null;
    if (noteid === -1) {
        ModalSuggestion = new C_Suggestion(null);
    } else {
        for (let ix = 0; ix !== Suggestions.length; ix++) {
            if (Suggestions[ix].id === noteid) {
                ModalSuggestion = Suggestions[ix];
                break;
            }
        }
    }

    let symd = ModalSuggestion.Created.YMD;
    let symd_s = MonthNames[symd.Month - 1] + " " + symd.Day.toString() + ", " + symd.Year.toString();
    let shms = ModalSuggestion.Created.HMS;
    let shms_s = shms.Hour.toString() + ":" + C_YMDhms.PadTo(shms.Minute.toString(), 2) + ":" + C_YMDhms.PadTo(shms.Minute.toString(), 2);
    $('#vitasa_adminsuggestion_received')[0].value = symd_s + " at " + shms_s;

    let suguser = BackendHelper.FindUserById(ModalSuggestion.UserId);
    let sugusername = "unknown";
    if (suguser !== null)
        sugusername = suguser.Name;

    $('#vitasa_adminsuggestion_from')[0].value = ModalSuggestion.FromPublic ? "Public" : sugusername;
    $('#vitasa_adminsuggestion_subject')[0].value = ModalSuggestion.Subject;
    $('#vitasa_adminsuggestion_message')[0].value = ModalSuggestion.Text;

    $('#vitasa_modal_adminsuggestions_editsend').modal({});
}


// Called when the edit workitem modal is closed by user action
$('#vitasa_modal_adminsuggestions_editsend').on('hidden.bs.modal', function () {
    // if it was the cancel button, we can safely just quit
    let clickedbuttonid = $(document.activeElement).attr("id");
    if (clickedbuttonid === "vitasa_button_cancel") {
        return;
    }

    // save === download
    if (clickedbuttonid === "vitasa_button_save") {
        // somehow, do a download
        let msg = '';
        msg += 'Subject: ' + ModalSuggestion.Subject + '\n';
        msg += 'Message:\n';
        msg += ModalSuggestion.Text;
        msg += '\n----- end of suggestion -----\n';

        download('suggestion.txt', msg);
    }
});

// ----------------------------------------------------------
//            Notification Delete
// ----------------------------------------------------------

function DoSuggestionDelete_Click(noteid) {
    if (noteid === -1)
        return;

    ModalSuggestion = null;
    for(let ix = 0; ix !== Suggestions.length; ix++) {
        if (Suggestions[ix].id === noteid) {
            ModalSuggestion = Suggestions[ix];
            break;
        }
    }

    MessageBox(
        'Confirm',
        'Are you sure you want to delete this suggestion? THERE IS NO UNDO.',
        [ "Yes", "No" ],
        DeleteSuggestionConfirm
    );
}

function DeleteSuggestionConfirm(button) {
    if (button.toLowerCase() !== "yes")
        return;

    ClearAllAdminSuggestionRows();

    BackendHelper.DeleteSuggestion(ModalSuggestion)
        .then(function (success) {
            if (success) {
                Suggestions = BackendHelper.GetAllSuggestions()
                    .then(function () {
                        PopulateSuggestionsTable();
                    })
                    .catch(function (error) {
                        console.log(error);
                    });
            } else {
                MessageBox("Error", "Unable to delete the suggestion.", [ "Ok" ], null);
            }
        })
        .catch(function (error) {
            console.log(error);
        });
}




