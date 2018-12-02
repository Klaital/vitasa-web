
let OurMap;
let OurLastInfoWindow = null;
let OurUser = null;
var BackendHelper = null;

// This function is called when the google maps are ready to be initialized. Since this is an async
//   callback, we need to ensure that the vita site data has been loaded (by yet another async process).
//   To do this, we make sure that the completion 
function initMap() 
{
    const myLatLng = {lat: 29.4104978, lng: -98.5011676};

    OurMap = new google.maps.Map(document.getElementById("googleMap"), {
        zoom: 10,
        center: myLatLng
    });

    // do all the async stuff in an async function to avoid cascading .then()'s
    DoAsyncInitMap()
        .catch(function (error) {
            console.log(error);
        });
}

async function DoAsyncInitMap() {
    BackendHelper = new C_BackendHelper();
    await BackendHelper.Initialize();
    //await BackendHelper.LoadAllUsers();
    //await BackendHelper.LoadTestData();

    PageInit();

    OurUser = BackendHelper.FindUserByEmail(BackendHelper.UserCredentials.Email);

    InitMenuItems(BackendHelper.UserCredentials);

    const filteredSites = BackendHelper.GetFilteredSites(OurUser);

    // now that Sites is loaded, we need to put a pin on the map for each site
    for (let i = 0; i !== filteredSites.length; i++) {
        const site = filteredSites[i];
        addMarker2(OurMap, site, BackendHelper.Filter);
    }
}

function PageInit() {
    if (BackendHelper.Filter !== null) {
        document.getElementById("filter_mft").checked = BackendHelper.Filter.MFT;
        document.getElementById("filter_express").checked = BackendHelper.Filter.Express;
        document.getElementById("filter_inperson").checked = BackendHelper.Filter.InPerson;
        document.getElementById("filter_dropoff").checked = BackendHelper.Filter.DropOff;
        document.getElementById("filter_mobile").checked = BackendHelper.Filter.Mobile;

        if (BackendHelper.Filter["dates"] === "all")
            document.getElementById("filter_anydate").checked = true;
        else if (BackendHelper.Filter.Dates === "p0")
            document.getElementById("filter_p0").checked = true;
        else if (BackendHelper.Filter.Dates === "p1")
            document.getElementById("filter_p1").checked = true;
        else if (BackendHelper.Filter.Dates === "p2")
            document.getElementById("filter_p2").checked = true;
        else if (BackendHelper.Filter.Dates === "p3")
            document.getElementById("filter_p3").checked = true;
        else if (BackendHelper.Filter.Dates === "p4")
            document.getElementById("filter_p4").checked = true;

        let timenow = Date.now();
        let timeplus2days = timenow + 2 * 24 * 60 * 60 * 1000;
        let timeplus3days = timenow + 3 * 24 * 60 * 60 * 1000;
        let timeplus4days = timenow + 4 * 24 * 60 * 60 * 1000;

        document.getElementById("vitasa_filter_p2_label").innerText = DateString(timeplus2days);
        document.getElementById("vitasa_filter_p3_label").innerText = DateString(timeplus3days);
        document.getElementById("vitasa_filter_p4_label").innerText = DateString(timeplus4days);
    }

    document.getElementById("vitasa_label_filter_mobile").style.visibility =
        ((BackendHelper.UserCredentials !== null) && BackendHelper.UserCredentials.IsValidCredential() && BackendHelper.UserCredentials.HasMobile()) ? "visible" : "hidden";
}

function addMarker2(map, site, filter) {
    const lat = parseFloat(site.Latitude);
    const lng = parseFloat(site.Longitude);

    const standardSite = {
        position: {lat: lat, lng: lng},
        map: map,
        title: location.name,
        icon: {
            url: "http://maps.google.com/mapfiles/ms/icons/blue-dot.png"
        }
    };

    const preferedSite = {
        position: {lat: lat, lng: lng},
        map: map,
        title: location.name,
        icon: {
            url: "http://maps.google.com/mapfiles/ms/icons/red-dot.png"
        }
    };

    let siteIsPrefered = filter.PreferedSiteSlugs.includes(site.Slug);
    let markerOptions = siteIsPrefered ? preferedSite : standardSite;

    const marker = new google.maps.Marker(markerOptions);

    marker.addListener("click", function() {
        if (OurLastInfoWindow != null) {
            OurLastInfoWindow.close();
        }

        const contentString = "<a href=\"#\" onclick=\"infowindowclick('" + site.Slug + "');\"><b>" + site.Name + "</b></a><br/>"
            + "<a href=\"#\" onclick=\"infowindowclick('" + site.Slug + "');\"><b>\"" + site.Street + "\"</b></a>";

        OurLastInfoWindow = new google.maps.InfoWindow({content: contentString});

        OurLastInfoWindow.open(map, marker);
    });
}

function datesfilter_clicked()
{
    const anyDate = $("#filter_anydate").prop("checked");
    const tp0 = $("#filter_p0").prop("checked");
    const tp1 = $("#filter_p1").prop("checked");
    const tp2 = $("#filter_p2").prop("checked");
    const tp3 = $("#filter_p3").prop("checked");
    const tp4 = $("#filter_p4").prop("checked");

    if (anyDate)
        BackendHelper.Filter.Dates = "all";
    else if (tp0)
        BackendHelper.Filter.Dates = "p0";
    else if (tp1)
        BackendHelper.Filter.Dates = "p1";
    else if (tp2)
        BackendHelper.Filter.Dates = "p2";
    else if (tp3)
        BackendHelper.Filter.Dates = "p3";
    else if (tp4)
        BackendHelper.Filter.Dates = "p4";

    BackendHelper.SaveFilter()
        .then(function () {
            initMap();
        })
        .catch(function(error)
        {
            console.log(error);
        });
}

function capabilityfilter_clicked()
{
    BackendHelper.Filter.MFT = $("#filter_mft").prop("checked");
    BackendHelper.Filter.DropOff = $("#filter_dropoff").prop("checked");
    BackendHelper.Filter.InPerson = $("#filter_inperson").prop("checked");
    BackendHelper.Filter.Express = $("#filter_express").prop("checked");
    BackendHelper.Filter.Mobile = $("#filter_mobile").prop("checked");

    BackendHelper.SaveFilter()
        .then(function () {
            initMap();
        })
        .catch(function(error)
        {
            console.log(error);
        });
}

function login_click()
{
    const email = document.getElementById("vitasa_login_email").value;
    const password = document.getElementById("vitasa_login_password").value;

    BackendHelper.DoLogin(email, password)
    .then(function(loggedInUser)
    {
        if (loggedInUser !== null)
        {
            $("button#vitasa_signin").dropdown("toggle");

            // save this email/password/name/mobile/role in localStorage
            BackendHelper.UserCredentials.ImportUser(loggedInUser);
            BackendHelper.UserCredentials.Password = password;
            BackendHelper.UpdateUserCredentialsToLocalStorage()
            // let usercred = new C_UserCredential(null);
            // usercred.ImportUser(loggedInUser);
            // SaveUserCredentialsToLocalStorageAsync(usercred)
            .then(function() 
            {
                // configure menu's for the newly logged in user
                //SetupMainMenu(usercred);
                PageInit(null, BackendHelper.UserCredentials);
                InitMenuItems(BackendHelper.UserCredentials);
            })
            .catch(function(error)
            {
                ErrorMessageBox("Internal error (1).");
                console.log(error);
            });
        }
        else
            ErrorMessageBox("User name or password failed to match.");

        return false;
    })
    .catch(function(error)
    {
        ErrorMessageBox("Network error in trying the login.");
        console.log(error);
        return false;
    });

    return false; // to avoid form submission
}

function login_form_data_changed() {
    const email = document.getElementById("vitasa_login_email").value;
    const password = document.getElementById("vitasa_login_password").value;

    let ve = IsValidEmail(email);
    let enableSubmit = ve && (password.length > 6);

    $("button#vitasa_login_submit").prop("disabled", !enableSubmit);
}

function infowindowclick(siteslug)
{
    const site = BackendHelper.FindSiteBySlug(siteslug);

    if (site !== null)
        StartSiteDetailsModal(site);
}

//function StartSiteDetailsModal(site, usercred, filter) {
function StartSiteDetailsModal(site) {
    let usercred = BackendHelper.UserCredentials;
    let filter = BackendHelper.Filter;

    document.getElementById("vitasa_modal_sitename").innerText = site.Name;
    document.getElementById("vitasa_modal_sitestreetcsz").innerText = site.Street + " " + site.City + ", " + site.State + " " + site.Zip;

    $('div#vitasa_modal_preferedsite')[0].hidden = !usercred.Mobile;
    $('input#dropdownCheck')[0].checked = filter.PreferedSiteSlugs.includes(site.Slug);
    $('#vitasa_cal_date')[0].innerText = MonthNames[filter.CalendarDate.Month-1] + " " + filter.CalendarDate.Year.toString();

    let services = "";
    site.SiteCapabilities.forEach(function(c) {
        if (c.toLowerCase() !== "mobile") {
            if (services.length !== 0)
                services += ", ";
            services += c;
        }
    });
    $('#vitasa_modal_siteservices')[0].innerText = services;

    ModalSiteSlug = site.Slug;

    IndexDrawSeasonCalendar();

    $('#vitasa_modal_sitedetails').modal({});
}

$('#vitasa_modal_sitedetails').on('hidden.bs.modal', function () {
    if (redoMaps) {
        initMap();
        redoMaps = false;
    }
    ModalSiteSlug = null;
});

let redoMaps = false;
let ModalSiteSlug = null;

function preferedsitecheckchange() {
    let checked = $('input#dropdownCheck')[0].checked;

    let filter = BackendHelper.Filter;

    if (checked)
        filter.AddPreferedSiteSlug(ModalSiteSlug);
    else
        filter.RemovePreferedSiteSlug(ModalSiteSlug);
    redoMaps = true;

    let usercred = BackendHelper.UserCredentials;

    // adjust the prefered sites list for a signed in user
    let user = BackendHelper.FindUserByEmail(usercred.Email);

    if (checked) {
        if (!user.PreferedSites.includes(ModalSiteSlug))
            user.PreferedSites.push(ModalSiteSlug);
    }
    else {
        if (user.PreferedSites.includes(ModalSiteSlug)) {
            let ix = user.PreferedSites.indexOf(ModalSiteSlug);
            user.PreferedSites.splice(ix, 1);
        }
    }
    BackendHelper.UpdateUser(user)
        .then(function () {
            BackendHelper.UpdateFilterToLocalStorage()
                .then(function () {
                    BackendHelper.UpdateUserCredentialsToLocalStorage()
                        .catch(function (error) {
                            console.log(error);
                        });
                })
                .catch(function (error) {
                    console.log(error);
                });
        })
        .catch(function (error) {
            console.log(error);
        });
}

function load_click() {
    BackendHelper.LoadTestData()
    //ResetTestData()
        .catch(function (error) {
            console.log(error);
        })
}

function IndexPreviousMonth() {
    BackendHelper.Filter.CalendarDate.Month = BackendHelper.Filter.CalendarDate.Month - 1;
    if (BackendHelper.Filter.CalendarDate.Month === 0) {
        BackendHelper.Filter.CalendarDate.Month = 12;
        BackendHelper.Filter.CalendarDate.Year--;
    }
    BackendHelper.SaveFilter()
        .then(function () {
            IndexDrawSeasonCalendar();
        })
        .catch(function (error) {
            console.log(error);
        });
}

function IndexNextMonth() {
    BackendHelper.Filter.CalendarDate.Month = BackendHelper.Filter.CalendarDate.Month + 1;
    if (BackendHelper.Filter.CalendarDate.Month > 12) {
        BackendHelper.Filter.CalendarDate.Month = 1;
        BackendHelper.Filter.CalendarDate.Year++;
    }
    BackendHelper.SaveFilter()
        .then(function () {
            IndexDrawSeasonCalendar();
        })
        .catch(function (error) {
            console.log(error);
        });
}

function IndexDrawSeasonCalendar() {
    let site = BackendHelper.FindSiteBySlug(ModalSiteSlug);

    let ourDate = BackendHelper.Filter.CalendarDate;
    let firstDayOfMonthDate = new C_YMD(ourDate.Year, ourDate.Month, 1);
    let firstDayOfMonthDayOfWeek = firstDayOfMonthDate.DayOfWeek();

    $('#vitasa_cal_date')[0].innerText = MonthNames[ourDate.Month - 1] + " - " + ourDate.Year.toString();
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
                    let thisdate = new C_YMD(ourDate.Year, ourDate.Month, dn);
                    let ce = site.FindCalendarEntryForDate(thisdate);
                    if ((ce !== null) && ce.SiteIsOpen)
                        calCel.bgColor = CalendarColor_Site_SiteOpen;
                    else
                        calCel.bgColor = CalendarColor_Site_SiteClosed;
                    calCel.innerText = dn.toString();
                }
            }
            else {
                let date = new C_YMD(ourDate.Year, ourDate.Month, dn);
                let daysInMonth = date.DaysInMonth();
                let ce = site.FindCalendarEntryForDate(date);

                if (date.Day <= daysInMonth) {
                    if ((ce !== null) && ce.SiteIsOpen)
                        calCel.bgColor = CalendarColor_Site_SiteOpen;
                    else
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

function day_click(element, which) {
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

    if (dn > daysInMonth) {
        ShowNoData(date);
        return;
    }

    let site = BackendHelper.FindSiteBySlug(ModalSiteSlug);
    if (site === null) {
        ShowNoData(date);
        return;
    }

    let ce = site.FindCalendarEntryForDate(date);
    if (ce === null) {
        ShowNoData(date);
        return;
    }

    let open_s = ce.SiteIsOpen ? "Open" : "Closed";
    if (ce.SiteIsOpen)
        open_s += " [" + ce.OpenTime.toStringFormat("hh:mm p") + " to " + ce.CloseTime.toStringFormat("hh:mm p") + "]";

    $('#vitasa_index_sitedate')[0].value = ce.Date.toStringFormat("mmm dd, yyyy");
    $('#vitasa_index_siteopen')[0].value = open_s;
}

function ShowNoData(date) {
    $('#vitasa_index_sitedate')[0].value = date.toStringFormat("mmm dd, yyyy");
    $('#vitasa_index_siteopen')[0].value = "Site is Closed";
}


