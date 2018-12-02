const MonthNames = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
const DayOfWeekNames = [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ];
// const States = [
//     "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
//     "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
//     "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
//     "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
//     "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY" ];

const CalendarColor_Site_NotADate = "FFFFFF";
const CalendarColor_Site_SiteClosed = "F4F4F4";
const CalendarColor_Site_SiteOpen = "87CEFA"; // light blue
const CalendarColor_Mobile_NotADate = "FFFFFF";
const CalendarColor_Mobile_NoSiteOpen = "F4F4F4"; // light grey
const CalendarColor_Mobile_OneSiteOpen = "87CEF4"; // light blue
const CalendarColor_Mobile_TwoSitesOpen = "228b22"; // light green
const CalendarColor_Mobile_ManySitesOpen = "E00000"; // dark red

function logout_click() {
    let curpage = window.location.href;
    let curpage1 = curpage.split("/"); // make the page name the last element
    let curpage2 = curpage1[curpage1.length-1];
    let curpage3 = curpage2.split(".");
    let curpage4 = curpage3[0];

    BackendHelper.DoLogout()
        .then(function()
        {
            if (curpage4 === "index") {
                $("button#vitasa_signin").dropdown("toggle");

                //SetupMainMenu();
                InitMenuItems(null);
            }
            else {
                window.location.href = 'index.html';
            }
        })
        .catch(function(error)
        {
            console.log(error);
        });
}

// ==========================================================================================
//
//                      Settings Modal
//
// ==========================================================================================

function settings_click() {
    DoSettings()
        .catch(function(error) {
            console.log(error);
        });
}

async function DoSettings() {
    let html =
        '    <!-- edit settings modal -->' +
        '    <div class="modal" tabindex="-1" role="dialog" id="vitasa_modal_settings">' +
        '        <div class="modal-dialog" role="document">' +
        '            <div class="modal-content">' +
        '                <div class="modal-header">' +
        '                    <h5 class="modal-title" id="vitasa_modal_title">Settings</h5>' +
        '                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" id="vitasa_modal_button_cancel">' +
        '                        <span aria-hidden="true">&times;</span>' +
        '                    </button>' +
        '                </div>' +
        '' +
        '                <div class="modal-body">' +
        '                   <div class="row">' +
        '                       <div class="col">' +
        '                           <br/>' +
        '                           <div class="input-group mb-3">' +
        '                               <div class="input-group-prepend">' +
        '                                   <span class="input-group-text" id="vitasa_settings_name">Name:</span>' +
        '                               </div>' +
        '                               <input type="text" class="form-control" placeholder="Name" aria-label="Name" aria-describedby="vitasa_settings_name" id="vitasa_settings_name" onkeyup="vitasa_settings_keypress();">' +
        '                           </div>' +
        '                       </div>' +
        '                   </div>' +
        '' +
        '                   <div class="row">' +
        '                       <div class="col">' +
        '                           <br/>' +
        '                           <div class="input-group mb-3">' +
        '                               <div class="input-group-prepend">' +
        '                                   <span class="input-group-text" id="vitasa_settings_email">Email:</span>' +
        '                               </div>' +
        '                               <input type="text" class="form-control" placeholder="Email" aria-label="Email" aria-describedby="vitasa_settings_email" id="vitasa_settings_email" onkeyup="vitasa_settings_keypress();">' +
        '                           </div>' +
        '                       </div>' +
        '                   </div>' +
        '' +
        '                   <div class="row">' +
        '                       <div class="col">' +
        '                           <br/>' +
        '                           <div class="input-group mb-3">' +
        '                               <div class="input-group-prepend">' +
        '                                   <span class="input-group-text" id="vitasa_settings_password">Password:</span>' +
        '                               </div>' +
        '                               <input type="password" class="form-control" placeholder="Password" aria-label="Password" aria-describedby="vitasa_settings_password" id="vitasa_settings_password" onkeyup="vitasa_settings_keypress();">' +
        '                           </div>' +
        '                       </div>' +
        '                   </div>' +
        '' +
        '                   <div class="row">' +
        '                       <div class="col">' +
        '                           <br/>' +
        '                           <div class="input-group mb-3">' +
        '                               <div class="input-group-prepend">' +
        '                                   <span class="input-group-text" id="vitasa_settings_passwordconfirm">Password confirm:</span>' +
        '                               </div>' +
        '                               <input type="password" class="form-control" placeholder="Password" aria-label="Password" aria-describedby="vitasa_settings_passwordconfirm" id="vitasa_settings_passwordconfirm" onkeyup="vitasa_settings_keypress();">' +
        '                           </div>' +
        '                       </div>' +
        '                   </div>' +
        '' +
        '                   <div class="row">' +
        '                       <div class="col">' +
        '                            <br/>' +
        '                           <div class="input-group mb-3">' +
        '                               <div class="input-group-prepend">' +
        '                                   <span class="input-group-text" id="vitasa_settings_phone">Phone:</span>' +
        '                               </div>' +
        '                               <input type="text" class="form-control" placeholder="Phone" aria-label="Phone" aria-describedby="vitasa_settings_phone" id="vitasa_settings_phone" onkeyup="vitasa_settings_keypress();">' +
        '                           </div>' +
        '                       </div>' +
        '                   </div>' +
        '               </div>' +
        '' +
        '                <div class="modal-footer">' +
        '                    <button type="button" class="btn btn-secondary" data-dismiss="modal" id="vitasa_button_cancel">Cancel</button>' +
        '                    <button type="button" class="btn btn-primary" data-dismiss="modal" id="vitasa_button_save" disabled>Save</button>' +
        '                </div>' +
        '              </div>' +
        '            </div>' +
        '        </div>' +
        '    </div>';

    const newRow = $('<div>');
    newRow.append(html);
    $("body").append(newRow);

    if (!BackendHelper.UserCredentials.IsValidCredential())
        return;

    let ouruser = BackendHelper.FindUserByEmail(BackendHelper.UserCredentials.Email);
    if (ouruser === null)
        return;

    $('input#vitasa_settings_name')[0].value = ouruser.Name;
    $('input#vitasa_settings_email')[0].value = ouruser.Email;
    $('input#vitasa_settings_password')[0].value = "";
    $('input#vitasa_settings_passwordconfirm')[0].value = "";
    $('input#vitasa_settings_phone')[0].value = ouruser.Phone;

    vitasa_settings_keypress();

    let modal = $('#vitasa_modal_settings');
    modal.modal({});

    modal.on('hidden.bs.modal', function () {
        // if it was the cancel button, we can safely just quit
        let clickedbuttonid = $(document.activeElement).attr("id");
        if (clickedbuttonid === "vitasa_button_cancel")
            return;

        let nname = $('input#vitasa_settings_name')[0].value;
        let nemail = $('input#vitasa_settings_email')[0].value;
        let npw = $('input#vitasa_settings_password')[0].value;
        let npwc = $('input#vitasa_settings_passwordconfirm')[0].value;
        let nphone = $('input#vitasa_settings_phone')[0].value;

        let user = BackendHelper.FindUserByEmail(BackendHelper.UserCredentials.Email);
        if (user === null)
            return;

        user.Name = nname;
        user.Email = nemail;
        user.Phone = nphone;

        if((npw === npwc) && (npw.length > 6))
            user.Password = npw;

        let saveUserCredentials = false;
        if (user.Email !== BackendHelper.UserCredentials.Email) {
            BackendHelper.UserCredentials.Name = nname;
            BackendHelper.UserCredentials.Email = nemail;
            if((npw === npwc) && (npw.length > 6)) {
                BackendHelper.UserCredentials.Password = npw;
            }
            saveUserCredentials = true;
        }

        $('#vitasa_username')[0].innerText = nname;

        BackendHelper.UpdateUser(user)
            .then(function () {
                if (saveUserCredentials)
                    BackendHelper.UpdateUserCredentialsToLocalStorage()
                        .catch(function (error) {
                            console.log(error);
                        });
            })
            .catch(function (error) {
                console.log(error);
            });
    });
}

function vitasa_settings_keypress() {
    let nname = $('input#vitasa_settings_name')[0].value;
    let nemail = $('input#vitasa_settings_email')[0].value;
    let npw = $('input#vitasa_settings_password')[0].value;
    let npwc = $('input#vitasa_settings_passwordconfirm')[0].value;
    let nphone = $('input#vitasa_settings_phone')[0].value;

    let nameok = nname.length > 2;
    let emailok = IsValidEmail(nemail);
    let pwok = ((npw.length === 0) && (npwc.length === 0))
        || ((npw.length > 6) && (npw === npwc));
    let phoneok = nphone.length > 6;

    let enableSubmit = nameok && emailok && pwok && phoneok;

    $("button#vitasa_button_save").prop("disabled", !enableSubmit);
}

// ==========================================================================================
//
//                      Suggestion Modal
//
// ==========================================================================================

function suggestionmodalstart() {
    let html = '    <!-- suggestion modal -->' +
        '    <div class="modal" tabindex="-1" role="dialog" id="vitasa_modal_suggestion">' +
        '        <div class="modal-dialog" role="document">' +
        '            <div class="modal-content">' +
        '                <div class="modal-header">' +
        '                    <h5 class="modal-title">Post a Suggestion</h5>' +
        '                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">' +
        '                        <span aria-hidden="true">&times;</span>' +
        '                    </button>' +
        '                </div>' +
        '                <div class="modal-body">' +
        '' +
        '                   <div class="row">' +
        '                       <div class="col">' +
        '                           <div class="input-group mb-3">' +
        '                               <div class="input-group-prepend">' +
        '                                   <span class="input-group-text" id="basic-addon1">Subject</span>' +
        '                               </div>' +
        '                               <input type="text" class="form-control" placeholder="Subject" aria-label="Username" aria-describedby="basic-addon1" id="vitasa_suggestion_subject">' +
        '                           </div>' +
        '                       </div>' +
        '                   </div>' +
        '' +
        '                   <div class="row">' +
        '                       <div class="col">' +
        '                           <div class="input-group">' +
        '                               <div class="input-group-prepend">' +
        '                                   <span class="input-group-text">Suggestion</span>' +
        '                               </div>' +
        '                               <textarea class="form-control" aria-label="Suggestion" id="vitasa_suggestion_body"></textarea>' +
        '                           </div>' +
        '                       </div>' +
        '                   </div>' +
        '' +
        '                </div>' +
        '                <div class="modal-footer">' +
        '                    <button type="button" class="btn btn-secondary" data-dismiss="modal" id="vitasa_button_cancel">Cancel</button>' +
        '                    <button type="button" class="btn btn-primary" data-dismiss="modal" id="vitasa_button_save">Save</button>' +
        '                </div>' +
        '            </div>' +
        '        </div>' +
        '    </div>';

    const newRow = $('<div>');
    newRow.append(html);
    $("body").append(newRow);

    let modal = $('#vitasa_modal_suggestion');
    modal.modal({});

    modal.on('hidden.bs.modal', function () {
        // if it was the cancel button, we can safely just quit
        let clickedbuttonid = $(document.activeElement).attr("id");
        if (clickedbuttonid === "vitasa_button_cancel")
            return;

        let subject = $('input#vitasa_suggestion_subject')[0].value;
        let textarea = $('textarea#vitasa_suggestion_body')[0].value;

        let user = BackendHelper.FindUserByEmail(BackendHelper.UserCredentials.Email);
        if (user === null)
            return;

        BackendHelper.CreateSuggestion(user, subject, textarea)
            .catch(function (error) {
                console.log(error);
            });
    });
}

// ==========================================================================================
//
//                      Error Modal
//
// ==========================================================================================

/**
 ** Put a modal box on the screen to let the user know something has happened
 **/
function ErrorMessageBox(errorMessage) {
    let html =
        '    <!-- error modal -->\n' +
        '    <div class="modal" tabindex="-1" role="dialog" id="vitasa_modal_error">\n' +
        '      <div class="modal-dialog" role="document">\n' +
        '        <div class="modal-content">\n' +
        '          <div class="modal-header">\n' +
        '            <h5 class="modal-title">Error</h5>\n' +
        '            <button type="button" class="close" data-dismiss="modal" aria-label="Close">\n' +
        '              <span aria-hidden="true">&times;</span>\n' +
        '            </button>\n' +
        '          </div>\n' +
        '          <div class="modal-body">\n' +
        '            <p id="vitasa_modal_errormessage">error message</p>\n' +
        '          </div>\n' +
        '          <div class="modal-footer">\n' +
        '            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>\n' +
        '          </div>\n' +
        '        </div>\n' +
        '      </div>\n' +
        '    </div>\n';

    const newRow = $('<div>');
    newRow.append(html);
    $("body").append(newRow);

    document.getElementById("vitasa_modal_errormessage").innerText = errorMessage;

    let modal = $('#vitasa_modal_error');
    modal.modal({});
}

// ==========================================================================================
//
//                      Message Modal
//
// ==========================================================================================

/**
 ** Put a modal box on the screen to let the user know something has happened
 * title = string of text to use as the title
 * message = the message to display
 * buttons = array of buttons to include: Ok, Cancel, Yes, No, Save
 **/
let ModalCallBack = null;
function MessageBox(title, message, buttons, callback) {
    ModalCallBack = callback;

    let html =
        '    <!-- error modal -->\n' +
        '    <div class="modal" tabindex="-1" role="dialog" id="vitasa_modal_messagebox">' +
        '      <div class="modal-dialog" role="document">' +
        '        <div class="modal-content">' +
        '          <div class="modal-header">' +
        '            <h5 class="modal-title" id="vitasa_modal_message_title">.</h5>' +
        '            <button type="button" class="close" data-dismiss="modal" aria-label="Close" id="vitasa_modal_button_cancel">' +
        '              <span aria-hidden="true">&times;</span>' +
        '            </button>' +
        '          </div>' +
        '          <div class="modal-body">' +
        '            <p id="vitasa_modal_message_body">.</p>' +
        '          </div>\n' +
        '          <div class="modal-footer">';

    if (buttons === null) {
        html += '<button type="button" class="btn btn-secondary" data-dismiss="modal" id="vitasa_modal_button_cancel">Ok</button>';
    }
    else {
        buttons.forEach(function (b) {
            html += '<button type="button" class="btn btn-secondary" data-dismiss="modal" id="vitasa_modal_button_' + b + '">' + b + '</button>';
        })
    }
    html += '        </div>' +
        '        </div>' +
        '      </div>' +
        '    </div>';

    const newRow = $('<div>');
    newRow.append(html);
    $("body").append(newRow);

    document.getElementById("vitasa_modal_message_title").innerText = title;
    document.getElementById("vitasa_modal_message_body").innerText = message;

    let modal = $('#vitasa_modal_messagebox');
    modal.modal({});

    // Called when the edit workitem modal is closed by user action
    modal.on('hidden.bs.modal', function () {
        let clickedbuttonid = $(document.activeElement).attr("id");
        let clickedbuttonid_split = clickedbuttonid.split('_');
        let clickedbutton = clickedbuttonid_split[clickedbuttonid_split.length - 1];

        $('#vitasa_modal_messagebox').remove();

        if (ModalCallBack !== null) {
            ModalCallBack(clickedbutton);
            ModalCallBack = null;
        }
    });
}

// ==========================================================================================
//
//                      Calendar Modal
//
// ==========================================================================================

let CalendarModalCallBack = null;
let CalendarModalDate = null;
let CalendarModalCloseWithValue = false;
function ShowCalendar(title, date, callback) {
    CalendarModalCallBack = callback;
    CalendarModalDate = date;
    
    let cols = 
        '<div class="modal" tabindex="-1" role="dialog" id="vitasa_modal_calendar">' +
        '    <div class="modal-dialog" role="document">' +
        '        <div class="modal-content">' +
        '            <div class="modal-header">' +
        '                <h5 class="modal-title" id="vitasa_modal_calendar_title">.</h5>  ' +
        '                <button type="button" class="close" data-dismiss="modal" aria-label="Close">  ' +
        '                    <span aria-hidden="true">&times;</span>  ' +
        '                </button>  ' +
        '            </div>  ' +
        '            <div class="modal-body">  ' +
        
        
        // '                <div class="row">  ' +
        // '                    <div class="col">  ' +
        // '                        <button type="button" class="btn btn-outline-primary" onclick="GetSeason_PreviousMonth();">Previous</button>  ' +
        // '                    </div>  ' +
        // '                    <div class="col">' +
        // '                        <span id="vitasa_modal_calendar_date">.</span>\n' +
        // '                    </div>\n'+
        // '                    <div class="col">  ' +
        // '                        <button type="button" class="btn btn-outline-primary" onclick="GetSeason_NextMonth();">Next</button>  ' +
        // '                    </div>  ' +
        // '                </div>  ' +
        
        
        '              <div class="row">' +
        '                  <div class="col">' +
        '                      <div class="d-flex">' +
        '                          <div>' +
        '                            <button type="button" class="btn btn-primary" onclick="GetSeason_PreviousMonth();">Previous</button>' +
        '                          </div>' +
        '                          <div class="flex-grow-1 text-center">' +
        '                              <span id="vitasa_modal_calendar_date">.</span>' +
        '                          </div>' +
        '                          <div>' +
        '                              <button type="button" class="btn btn-primary" onclick="GetSeason_NextMonth();">Next</button>' +
        '                          </div>' +
        '                      </div>' +
        '                  </div>' +
        '              </div>' +
        
        
        
        
        
        '                <div class="row">  ' +
        '                   <div class="col">  ' +
        '                    <table class="table">  ' +
        '                        <thead class="thead-dark">  ' +
        '                        <tr>  ' +
        '                            <th scope="col">Sun</th>  ' +
        '                            <th scope="col">Mon</th>  ' +
        '                            <th scope="col">Tue</th>  ' +
        '                            <th scope="col">Wed</th>  ' +
        '                            <th scope="col">Thu</th>  ' +
        '                            <th scope="col">Fri</th>  ' +
        '                            <th scope="col">Sat</th>  ' +
        '                        </tr>  ' +
        '                        </thead>  ' +
        '                        <tbody>  ' +
        '                        <tr>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_00" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_01" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_02" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_03" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_04" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_05" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_06" onclick="seasonday_click(this);">.</td>  ' +
        '                        </tr>  ' +
        '                        <tr>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_10" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_11" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_12" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_13" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_14" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_15" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_16" onclick="seasonday_click(this);">.</td>  ' +
        '                        </tr>  ' +
        '                        <tr>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_20" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_21" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_22" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_23" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_24" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_25" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_26" onclick="seasonday_click(this);">.</td>  ' +
        '                        </tr>  ' +
        '                        <tr>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_30" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_31" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_32" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_33" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_34" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_35" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_36" onclick="seasonday_click(this);">.</td>  ' +
        '                        </tr>  ' +
        '                        <tr>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_40" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_41" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_42" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_43" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_44" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_45" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_46" onclick="seasonday_click(this);">.</td>  ' +
        '                        </tr>  ' +
        '                        <tr>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_50" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_51" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_52" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_53" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_54" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_55" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_56" onclick="seasonday_click(this);">.</td>  ' +
        '                        </tr>  ' +
        '                        <tr>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_60" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_61" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_62" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_63" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_64" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_65" onclick="seasonday_click(this);">.</td>  ' +
        '                            <td class="calendar_items" id="vitasa_cal_66" onclick="seasonday_click(this);">.</td>  ' +
        '                        </tr>  ' +
        '                        </tbody>  ' +
        '                    </table>  ' +
        '                   </div>  ' +
        '                </div>  ' +
        '            </div>  ' +
        '            <div class="modal-footer">\n' +
        '                <button type="button" class="btn btn-secondary" data-dismiss="modal" id="vitasa_calendar_close">Close</button>\n' +
        '            </div>\n' +
        '        </div>\n' +
        '    </div>\n' +
        '</div>\n';
    const newRow = $('<div>');
    newRow.append(cols);
    $("body").append(newRow);

    $('#vitasa_modal_calendar_date')[0].innerText = MonthNames[CalendarModalDate.Month - 1] + " - " + CalendarModalDate.Year.toString();
    $('#vitasa_modal_calendar_title')[0].innerText = title;

    DrawSeasonCalendar();

    let modal = $('#vitasa_modal_calendar');
    modal.modal({});

    // Called when the edit workitem modal is closed by user action
    modal.on('hidden.bs.modal', function () {
        // if it was the cancel button, we can safely just quit
        //let clickedbuttonid = $(document.activeElement).attr("id");

        $('#vitasa_modal_calendar').remove();

        if (CalendarModalCloseWithValue && (CalendarModalCallBack !== null)) {
            CalendarModalCallBack(CalendarModalDate);
        }
        CalendarModalCallBack = null;
        CalendarModalCloseWithValue = false;
    });

}
// Colors:
// 0: FFFFFF - not a date, blank space with no number, page background
// 1: F4F4F4 - date with no site open [grey]
// 2: ffa500 - date with only 1 site open [orange
// 3: 228B22 - date with exactly 2, non-overlapping [dark green]
// 4: 8b0000 - date with 2 that overlap or 3 or more [dark red]


function DrawSeasonCalendar() {
    let ourDate = BackendHelper.Filter.CalendarDate;
    let firstDayOfMonthDate = new C_YMD(ourDate.Year, ourDate.Month, 1);
    let firstDayOfMonthDayOfWeek = firstDayOfMonthDate.DayOfWeek();

    CalendarModalDate = ourDate;
    $('#vitasa_modal_calendar_date')[0].innerText = MonthNames[ourDate.Month - 1] + " - " + ourDate.Year.toString();
    //$('#vitasa_cal_date')[0].innerText = MonthNames[OurDate.Month - 1] + " - " + OurDate.Year.toString();

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
                    calCel.bgColor = CalendarColor_Site_SiteClosed;
                    calCel.innerText = dn.toString();
                }
            }
            else {
                let date = new C_YMD(ourDate.Year, ourDate.Month, dn);
                let daysInMonth = date.DaysInMonth();

                if (date.Day <= daysInMonth) {
                    calCel.bgColor = CalendarColor_Site_SiteClosed;
                    calCel.innerText = dn.toString();
                }
                else {
                    calCel.bgColor = CalendarColor_Site_NotADate;
                    calCel.innerText = "";
                }
            }
        }
    }
}

function GetSeason_PreviousMonth() {
    let ourdate = BackendHelper.Filter.CalendarDate;
    ourdate.Month = ourdate.Month - 1;
    if (ourdate.Month === 0) {
        ourdate.Month = 12;
        ourdate.Year--;
    }
    BackendHelper.Filter.CalendarDate = ourdate;

    DrawSeasonCalendar();

    BackendHelper.SaveFilter()
        .catch(function (error) {
            console.log(error);
        })
}

function GetSeason_NextMonth() {
    let ourdate = BackendHelper.Filter.CalendarDate;
    ourdate.Month = ourdate.Month + 1;
    if (ourdate.Month > 12) {
        ourdate.Month = 1;
        ourdate.Year++;
    }
    BackendHelper.Filter.CalendarDate = ourdate;

    DrawSeasonCalendar();

    BackendHelper.SaveFilter()
        .catch(function (error) {
            console.log(error);
        })
}

function seasonday_click(element, which) {
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

    CalendarModalDate = date;
    CalendarModalCloseWithValue = true;

    $('#vitasa_modal_calendar').modal('hide');
}

// ==========================================================================================
//
//                      Busy Modal
//
// ==========================================================================================

/**
 **/
function StartBusy(title) {

    let html =
        '    <!-- busy modal -->\n' +
        '    <div class="modal" tabindex="-1" role="dialog" id="vitasa_modal_messagebox">' +
        '      <div class="modal-dialog modal-dialog-centered" role="document">' +
        '        <div class="modal-content">' +
        '          <div class="modal-header">' +
        '            <h5 class="modal-title" id="vitasa_modal_message_title">.</h5>' +
        '          </div>' +
        '          <div class="modal-body">' +
        '            <h5 class="modal-title" id="vitasa_modal_message_message">.</h5>' +
        '          </div>' +
        '        </div>' +
        '      </div>' +
        '    </div>';

    const newRow = $('<div>');
    newRow.append(html);
    $("body").append(newRow);

    document.getElementById("vitasa_modal_message_title").innerText = title;

    let modal = $('#vitasa_modal_messagebox');
    modal.modal({});

    // Called when the edit workitem modal is closed by user action
    modal.on('hidden.bs.modal', function () {
        // let clickedbuttonid = $(document.activeElement).attr("id");
        // let clickedbuttonid_split = clickedbuttonid.split('_');
        // let clickedbutton = clickedbuttonid_split[clickedbuttonid_split.length - 1];

        $('#vitasa_modal_messagebox').remove();
    });
}

function StopBusy() {
    $('#vitasa_modal_messagebox').modal('hide');
}

function InitMenuItems(usercred) {
    if ((usercred !== null) && usercred.IsValidCredential()) {
        $("span#vitasa_username")[0].innerText = usercred.Name;

        $("button#vitasa_actionsbutton").prop("disabled", false);
        $("button#vitasa_signin").prop("disabled", true);
    }
    else {
        $("span#vitasa_username")[0].innerText = "";

        $("button#vitasa_actionsbutton").prop("disabled", true);
        $("button#vitasa_signin").prop("disabled", false);
    }

    let cols = '';
    // cols +=
    //     '                        <button class="dropdown-item" type="button" onclick="load_click();">Reload Test Data</button>';

    if (!window.location.href.includes("index.html"))
        cols +=
            '                        <a class="dropdown-item" href="index.html" id="vitasa_menu_volunteer_mobile">Staff Home Page</a>';


    if ((usercred != null) && usercred.IsValidCredential() && usercred.HasVolunteer()) {
        cols +=
            '                        <h6 class="dropdown-header" id="vitasa_menu_volunteer">Volunteers</h6>' +
            '                        <a class="dropdown-item" href="volhoursworked.html" id="vitasa_menu_volunteer">Work Log</a>';
        if (usercred.HasMobile())
            cols +=
                '                        <a class="dropdown-item" href="mobilecalendar.html" id="vitasa_menu_volunteer_mobile">Mobile Calendar</a>';
        cols +=
            '                        <button class="dropdown-item" type="button" id="vitasa_menu_volunteer" onclick="suggestionmodalstart();">Post Suggestion</button>' +
            '                        <button class="dropdown-item" type="button" id="vitasa_menu_volunteer" onclick="settings_click();">Settings</button>' +
            '                        <button class="dropdown-item" type="button" id="vitasa_menu_volunteer" onclick="logout_click();">Logout</button>'
    }
    if ((usercred != null) && usercred.IsValidCredential() && usercred.HasSiteCoordinator()) {
        cols +=
            '                        <h6 class="dropdown-header" id="vitasa_menu_sitecoordinator">Site Coordinators</h6>' +
            '                        <a class="dropdown-item" href="scsites.html" id="vitasa_menu_sitecoordinator">Sites</a>';
        if (usercred.HasMobile())
            cols +=
                '                        <a class="dropdown-item" href="mobilecalendar.html" id="vitasa_menu_sitecoordinator_mobile">Mobile</a>';
        cols +=
            '                        <button class="dropdown-item" type="button" id="vitasa_menu_sitecoordinator" onclick="settings_click();">Settings</button>' +
            '                        <button class="dropdown-item" type="button" id="vitasa_menu_sitecoordinator" onclick="logout_click();">Logout</button>';
    }
    if ((usercred != null) && usercred.IsValidCredential() && usercred.HasAdmin()) {
        cols +=
            '                        <h6 class="dropdown-header" id="vitasa_menu_admin">Admin</h6>' +
            '                        <a class="dropdown-item" href="admintest.html" id="vitasa_menu_admin">Test</a>' +
            '                        <a class="dropdown-item" href="adminusers.html" id="vitasa_menu_admin">Users</a>' +
            '                        <a class="dropdown-item" href="adminsites.html" id="vitasa_menu_admin">Sites</a>' +
            '                        <a class="dropdown-item" href="adminnotifications.html" id="vitasa_menu_admin">Notifications</a>' +
            '                        <a class="dropdown-item" href="adminsuggestions.html" id="vitasa_menu_admin">Suggestions</a>' +
            '                        <a class="dropdown-item" href="mobilecalendar.html" id="vitasa_menu_admin">Mobile Calendar</a>' +
            '                        <a class="dropdown-item" href="adminreports.html" id="vitasa_menu_admin">Reports</a>' +
            '                        <a class="dropdown-item" href="adminemailsubscribers.html?type=newuser" id="vitasa_menu_admin">Email List on New User</a>' +
            '                        <a class="dropdown-item" href="adminemailsubscribers.html?type=newsuggestion" id="vitasa_menu_admin">Email List on New Suggestion</a>' +
            '                        <button class="dropdown-item" type="button" id="vitasa_menu_admin" onclick="settings_click();">Settings</button>' +
            '                        <button class="dropdown-item" type="button" id="vitasa_menu_admin" onclick="logout_click();">Logout</button>';
    }

    let menu = $('div#vitasa_mainmenu');
    // clear the children nodes
    menu[0].innerHTML = "";
    const newRow = $('<div>');
    newRow.append(cols);
    menu.append(newRow);
}

/**
 * Returns a sting in the form mmm dd, yyyy
 * @return {string}
 */
function DateString(time)
{
    let res = new Date();
    res.setTime(time);

    const year = res.getFullYear();
    const month = res.getMonth();
    const day = res.getDate();

    const month_s = MonthNames[month];

    return month_s + " " + day.toString() + ", " + year.toString();
}

/**
 * @return {boolean}
 */
function Overlap(ceList)
{
    let res = false;
    for (let ceix = 0; ceix !== ceList.length; ceix++)
    {
        let ce = ceList[ceix];

        // with this one, see if any other entry overlaps
        for (let cetix = 0; cetix !== ceList.length; cetix++)
        {
            let cet = ceList[cetix];

            if (ceix !== cetix)
            {
                res = ((ce.OpenTime.Num() >= cet.OpenTime.Num()) && (ce.OpenTime.Num() < cet.CloseTime.Num()))
                    || ((ce.CloseTime.Num() > cet.OpenTime.Num()) && (ce.CloseTime.Num() <= cet.CloseTime.Num()));
            }
            if (res)
                break;
        }
        if (res)
            break;
    }

    return res;
}

/**
 * @return {boolean}
 */
function IsValidEmail(e) {
    if (!e.includes("@"))
        return false;

    let e_s = e.split('@');
    if (e_s.length !== 2)
        return false;

    if (e_s[0].length === 0)
        return false;
    if (!e_s[1].includes('.'))
        return false;

    let e_s1_s = e_s[1].split('.');
    if (e_s1_s.length !== 2)
        return false;
    if ((e_s1_s[0].length === 0) || (e_s1_s[1].length === 0))
        return false;

    return true;
}

function download(filename, text) {
    const element = document.createElement('a');
    element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
    element.setAttribute('download', filename);

    element.style.display = 'none';
    document.body.appendChild(element);

    element.click();

    document.body.removeChild(element);
}


