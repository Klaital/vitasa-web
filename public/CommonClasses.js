
// ----------------------------------------------------------
// -----            Site
// ----------------------------------------------------------

class C_Site {
    constructor(json) {
        this.id = -1;
        this.Name = "";
        this.Slug = "";
        this.Street = "";
        this.City = "";
        this.State = "TX";
        this.Zip = "";
        this.Latitude = 29.4104978;
        this.Longitude = -98.5011676;
        this.SiteCoordinatorIds = [];
        this.SiteCoordinatorNames = [];
        this.SiteCalendar = [];
        this.SiteType = "Fixed";
        this._WorkItems = [];
        this.SiteCapabilities = [];

        if (json !== null) {
            if ("id" in json)
                this.id = parseInt(json.id);
            if ("name" in json)
                this.Name = json.name;
            if ("slug" in json)
                this.Slug = json.slug;
            if ("street" in json)
                this.Street = json.street;
            if ("city" in json)
                this.City = json.city;
            if ("state" in json)
                this.State = json.state;
            if ("zip" in json)
                this.Zip = json.zip;
            if ("latitude" in json)
                this.Latitude = json.latitude;
            if ("longitude" in json)
                this.Longitude = json.longitude;
            if ("sitecoordinatorids" in json)
                this.SiteCoordinatorIds = json.sitecoordinatorids;
            if ("sitecoordinatornames" in json)
                this.SiteCoordinatorNames = json.sitecoordinatornames;

            if ("calendar_overrides" in json) {
                let cals = json.calendar_overrides;
                this.SiteCalendar = [];
                for (let ix = 0; ix !== cals.length; ix++) {
                    let ce = new C_CalendarEntry(cals[ix]);
                    this.SiteCalendar.push(ce);
                }
            }

            this.SiteType = "Fixed";
            if ("site_features" in json) {
                this.SiteCapabilities = [];
                for(let ix = 0; ix !== json.site_features.length; ix++) {
                    let sf = json.site_features[ix];
                    if (sf.toLowerCase() === "mobile")
                        this.SiteType = "Mobile";
                    else
                        this.SiteCapabilities.push(sf);
                }
            }
                // this.SiteCapabilities = json.site_features;

            // if ("sitetype" in json)
            //     this.SiteType = json.sitetype;

            if ("worklog" in json) {
                let items = json.worklog;
                this._WorkItems = [];
                for (let ix = 0; ix !== items.length; ix++) {
                    let item = items[ix];
                    let nwi = new C_WorkLog(item);
                    this._WorkItems.push(nwi);
                }
            }
        }
    }

    ToJson() {
        return {
            "id": this.id,
            "name": this.Name,
            "slug": this.Slug,
            "street": this.Street,
            "city": this.City,
            "state": this.State,
            "zip": this.Zip,
            "latitude": this.Latitude,
            "longitude": this.Longitude,
            "sitecoordinatorids": this.SiteCoordinatorIds,
            "sitecoordinatornames": this.SiteCoordinatorNames,
            "calendar_overrides": this.SiteCalendar,
            "site_features": this.SiteCapabilities,
            "sitetype": this.SiteType,
            "worklog": this._WorkItems
        };
    }

    ToJsonForBackend() {
        return {
            "name": this.Name,
            "street": this.Street,
            "city": this.City,
            "state": this.State,
            "zip": this.Zip,
            "latitude": this.Latitude,
            "longitude": this.Longitude,
            "site_features": this.SiteCapabilities,
            "sitetype": this.SiteType,
        };
    }

    SiteHasFeature(feature) {
        let res = false;
        for(let fix = 0; fix !== this.SiteCapabilities.length; fix++)
        {
            let siteCapability = this.SiteCapabilities[fix];
            if (siteCapability.toLowerCase() === feature.toLowerCase())
            {
                res = true;
                break;
            }
        }

        return res;
    }

    FindCalendarEntryForDate(date) {
        let res = null;

        for(let ix = 0; ix !== this.SiteCalendar.length; ix++) {
            let ce = this.SiteCalendar[ix];
            if (date.CompareTo(ce.Date) === 0) {
                res = ce;
                break;
            }
        }

        return res;
    }
}

// ----------------------------------------------------------
// -----            User
// ----------------------------------------------------------

class C_User {
    constructor(json) {
        this.id = -1;
        this.Name = "";
        this.Password = null;
        this.Email = "";
        this.Phone = "";
        this.Certification = "none";
        this.Roles = [];
        this.SitesCoordinated = [];
        this._WorkItems = [];
        this.PreferedSites = [];
        this.SubscribeMobile = false;
        this.SubscribePrefered = false;
        this.SubscribeEmailFeedback = false;
        this.SubscribeEmailNewUser = false;
        //this.Token = null;

        let isUndefined = typeof json !== 'undefined';
        if ((json !== null) && isUndefined) {
            if ("id" in json)
                this.id = parseInt(json.id);
            if ("name" in json)
                this.Name = json.name;
            if ("email" in json)
                this.Email = json.email;
            if ("phone" in json)
                this.Phone = json.phone;
            if ("certification" in json)
                this.Certification = json.certification;
            if ("roles" in json)
                this.Roles = json.roles;
            if ("sites_coordinated" in json) {
                let items = json.sites_coordinated;
                this.SitesCoordinated = [];
                for (let ix = 0; ix !== items.length; ix++) {
                    let item = items[ix];
                    let nsc = new C_SiteCoordinated(item);
                    this.SitesCoordinated.push(nsc);
                }
            }

            if ("workitems" in json) {
                let items = json.workitems;
                this._WorkItems = [];
                for (let ix = 0; ix !== items.length; ix++) {
                    let item = items[ix];
                    let nwi = new C_WorkLog(item);
                    this._WorkItems.push(nwi);
                }
            }

            if ("preferredsites" in json)
                this.PreferedSites = json.preferredsites;
            if ("subscribemobile" in json)
                this.SubscribeMobile = json.subscribemobile;
            if ("subscribepreferred" in json)
                this.SubscribePrefered = json.subscribepreferred;
            if ("subscribeemailfeedback" in json)
                this.SubscribeEmailFeedback = json.subscribeemailfeedback;
            if ("subscribenemailnewuser" in json)
                this.SubscribeEmailNewUser = json.subscribenemailnewuser;
        }
    }

    ToJson() {
        return {
            "id": this.id,
            "name": this.Name,
            "password": this.Password,
            "email": this.Email,
            "phone": this.Phone,
            "certification": this.Certification,
            "roles": this.Roles,
            "sites_coordinated": this.SitesCoordinated, // ---------------- !!!!!!!
            "workitems": this._WorkItems,
            "preferredsites": this.PreferedSites,
            "subscribemobile": this.SubscribeMobile,
            "subscribepreferred": this.SubscribePrefered,
            "subscribeemailfeedback": this.SubscribeEmailFeedback,
            "subscribenemailnewuser": this.SubscribeEmailNewUser
        };
    }

    ToJsonForHeader() {
        return {
            "id": this.id,
            "name": this.Name,
            "password": this.Password,
            "password_confirm": this.Password,
            "email": this.Email,
            "phone": this.Phone,
            "certification": this.Certification,
            "roles": this.Roles,
            "preferredsites": this.PreferedSites,
            "subscribemobile": this.SubscribeMobile,
            "subscribepreferred": this.SubscribePrefered,
            "subscribeemailfeedback": this.SubscribeEmailFeedback,
            "subscribenemailnewuser": this.SubscribeEmailNewUser
        };
    }

    HasAdmin() {
        return this.Roles.includes("Admin");
    }

    HasSiteCoordinator() {
        return this.Roles.includes("SiteCoordinator");
    }

    HasVolunteer() {
        return this.Roles.includes("Volunteer");
    }

    HasMobile() {
        return this.Roles.includes("Mobile");
    }
}

// ----------------------------------------------------------
//            SiteCoordinated
// ----------------------------------------------------------

class C_SiteCoordinated {
    constructor(json) {
        this.SiteId = -1;
        this.SiteName = null;
        this.SiteSlug = null;
        if (json != null) {
            if ("siteid" in json)
                this.SiteId = parseInt(json.siteid);
            if ("SiteId" in json)
                this.SiteId = parseInt(json.SiteId);

            if ("name" in json)
                this.SiteName = json.name;
            if ("SiteName" in json)
                this.SiteName = json.SiteName;

            if ("slug" in json)
                this.SiteSlug = json.slug;
            if ("SiteSlug" in json)
                this.SiteSlug = json.SiteSlug;
        }
    }

    ToJson() {
        return {
            "siteid" : this.SiteId.toString(),
            "slug" : this.SiteSlug
        };
    }

    static Create(siteid, sitename, siteslug) {
        let sc = new C_SiteCoordinated(null);
        sc.SiteId = siteid;
        sc.SiteName = sitename;
        sc.SiteSlug = siteslug;

        return sc;
    }
}

// ----------------------------------------------------------
//            UserCredential
// ----------------------------------------------------------

class C_UserCredential {
    constructor(json) {
        if (json !== null) {
            this.Name = json.name;
            this.Email = json.email;
            this.Password = json.password;
            this.Role = json.role;
            this.Mobile = json.mobile;
        }
        else {
            this.Name = "";
            this.Email = "";
            this.Password = "";
            this.Role = "client";
            this.Mobile = false;
        }
    }

    ToJson() {
        return {
            "name": this.Name,
            "email": this.Email,
            "password": this.Password,
            "role": this.Role,
            "mobile": this.Mobile
        };
    }

    ImportUser(user) {
        if (!(user instanceof C_User))
            throw "Input type must be a C_User";

        this.Name = user.Name;
        this.Email = user.Email;
        this.Password = user.Password;
        if (user.HasAdmin())
            this.Role = "Admin";
        else if (user.HasSiteCoordinator())
            this.Role = "SiteCoordinator";
        else if (user.HasVolunteer())
            this.Role = "Volunteer";
        else
            this.Role = "Client";
        this.Mobile = user.HasMobile();
    }

    IsValidCredential() {
        return ((this.Email !== null) && (this.Email.length > 0))
            && ((this.Password !== null) && (this.Password.length > 0))
            && (this.Role !== "Client");
    }

    HasAdmin() {
        return this.Role.toLowerCase() === "admin";
    }

    HasSiteCoordinator() {
        return this.Role.toLowerCase() === "sitecoordinator";
    }

    HasVolunteer() {
        return this.Role.toLowerCase() === "volunteer";
    }

    HasMobile() {
        return this.Mobile;
    }
}

// ----------------------------------------------------------
//            WorkLog
// ----------------------------------------------------------

class C_WorkLog {
    constructor(json) {
        this.id = -1;
        this.Date = new C_YMD(0, 0, 0);
        this.SiteId = -1;
        this.UserId = -1;
        this.Hours = 0;
        this.Approved = false;

        if (json !== null) {
            if ("id" in json)
                this.id = parseInt(json.id);

            if ("date" in json)
                this.Date = C_YMD.FromString(json.date);
            if ("Date" in json)
                this.Date = C_YMD.FromObject(json.Date);

            if ("siteid" in json)
                this.SiteId = parseInt(json.siteid);
            if ("SiteId" in json)
                this.SiteId = parseInt(json.SiteId);

            if ("userid" in json)
                this.UserId = parseInt(json.userid);
            if ("UserId" in json)
                this.UserId = parseInt(json.UserId);

            if ("hours" in json)
                this.Hours = parseFloat(json.hours);
            if ("Hours" in json)
                this.Hours = parseFloat(json.Hours);

            if ("approved" in json)
                this.Approved = json.approved === "true";
            if ("Approved" in json)
                this.Approved = json.Approved;
        }
    }

    ToJson() {
        return {
            "id" : this.id.toString(),
            "date" : this.Date.toString(),
            "siteid" : this.SiteId.toString(),
            "userid" : this.UserId.toString(),
            "hours" : this.Hours.toString(),
            "approved" : this.Approved ? "true" : "false"
        };
    }

    // static FromWorkItem(wi) {
    //     return new C_WorkLog(
    //         {
    //             "date" : wi.Date.toString(),
    //             "siteid" : wi.SiteId.toString(),
    //             "userid" : wi.UserId.toString(),
    //             "hours" : wi.Hours.toString(),
    //             "approved" : wi.Approved.toString()
    //         });
    // }
}
// ----------------------------------------------------------
//            CalendarEntry
// ----------------------------------------------------------

class C_CalendarEntry {
    constructor (json) {
        this.id = -1;
        this.SiteId = -1;
        this.Date = C_YMD.Now();
        this.SiteIsOpen = false;
        this.OpenTime = new C_HMS(0, 0, 0);
        this.CloseTime = new C_HMS(0, 0, 0);

        if (json !== null) {
            if ("id" in json)
                this.id = parseInt(json.id);
            if ("siteid" in json)
                this.SiteId = parseInt(json.siteid);
            if ("SiteId" in json)
                this.SiteId = parseInt(json.SiteId);
            if ("date" in json)
                this.Date = C_YMD.FromString(json.date);
            if ("Date" in json)
                this.Date = C_YMD.FromObject(json.Date);
            if ("is_closed" in json)
                this.SiteIsOpen = json.is_closed === "false";
            if ("SiteIsOpen" in json)
                this.SiteIsOpen = json.SiteIsOpen;
            if ("opentime" in json)
                this.OpenTime = C_HMS.FromString(json.opentime);
            if ("OpenTime" in json)
                this.OpenTime = C_HMS.FromObject(json.OpenTime);
            if ("closetime" in json)
                this.CloseTime = C_HMS.FromString(json.closetime);
            if ("CloseTime" in json)
                this.CloseTime = C_HMS.FromObject(json.CloseTime);
        }
    }

    ToJson() {
        return {
            "id": this.id,
            "siteid": this.SiteId,
            "date": this.Date.toString(),
            "is_closed": !this.SiteIsOpen,
            "opentime": this.OpenTime.toString(),
            "closetime": this.CloseTime.toString()
        };
    }
}

// ----------------------------------------------------------
//            Filter
// ----------------------------------------------------------

class C_Filter {
    constructor (json) {
        this.Dates = "all";
        this.Mobile = false;
        this.MFT = false;
        this.DropOff = false;
        this.InPerson = false;
        this.Express = false;
        this.PreferedSiteSlugs = [];
        this.SelectedSiteSlug = "";
        this.CalendarDate = C_YMD.Now();
        this.SeasonFirstDate = C_YMD.Now();
        this.SeasonLastDate = C_YMD.Now();

        if (json !== null) {
            if ("dates" in json)
                this.Dates = json.dates;
            if ("mobile" in json)
                this.Mobile = json.mobile;
            if ("mft" in json)
                this.MFT = json.mft;
            if ("dropoff" in json)
                this.DropOff = json.dropoff;
            if ("inperson" in json)
                this.InPerson = json.inperson;
            if ("express" in json)
                this.Express = json.express;
            if ("preferedsiteslugs" in json)
                this.PreferedSiteSlugs = json.preferedsiteslugs;
            if ("selectedsiteslug" in json)
                this.SelectedSiteSlug = json.selectedsiteslug;
            if ("calendardate" in json)
                this.CalendarDate = C_YMD.FromString(json.calendardate);
            if ("seasonfirstdate" in json)
                this.SeasonFirstDate = C_YMD.FromString(json.seasonfirstdate);
            if ("seasonlastdate" in json)
                this.SeasonLastDate = C_YMD.FromString(json.seasonlastdate);
        }
    }

    ToJson() {
        return {
            "dates": this.Dates,
            "mobile": this.Mobile,
            "mft": this.MFT,
            "dropoff": this.DropOff,
            "inperson": this.InPerson,
            "express": this.Express,
            "preferedsiteslugs" : this.PreferedSiteSlugs,
            "selectedsiteslug" : this.SelectedSiteSlug,
            "calendardate" : this.CalendarDate.toString(),
            "seasonfirstdate" : this.SeasonFirstDate.toString(),
            "seasonlastdate" : this.SeasonLastDate.toString()
        };
    }

    AddPreferedSiteSlug(slug) {
        if (!this.PreferedSiteSlugs.includes(slug))
            this.PreferedSiteSlugs.push(slug);
    }

    RemovePreferedSiteSlug(slug) {
        if (this.PreferedSiteSlugs.includes(slug)) {
            let ix = this.PreferedSiteSlugs.indexOf(slug);
            if (ix !== -1)
                this.PreferedSiteSlugs.splice(ix, 1);
        }
    }

    SiteMatchesFilter(site, user) {
        let isAMobileSite = (site.SiteType.toLowerCase() === "mobile") || ((user !== null) && user.HasMobile());
        let ok = true;

        if (this.Mobile || this.MFT || this.DropOff || this.InPerson || this.Express)
        {
            const mftok = (this.MFT && site.SiteHasFeature("mft"));
            const dropoffok = (this.DropOff && site.SiteHasFeature("dropoff"));
            const inpersonok = (this.InPerson && site.SiteHasFeature("inperson"));
            const expressok = (this.Express && site.SiteHasFeature("express"));
            const mobileok = (this.Mobile && isAMobileSite);

            ok = mftok || dropoffok || inpersonok || expressok || mobileok;
        }

        if (isAMobileSite && ((user == null) || (!user.HasMobile())))
            ok = false;

        return ok;
    }
}

// ----------------------------------------------------------
//            Notification
// ----------------------------------------------------------

class C_Notification {
    constructor(json) {
        this.id = -1;
        this.Message = "";
        this.Audience = "Volunteers";
        this.Created = C_YMDhms.Now();
        this.Updated = C_YMDhms.Now();
        this.Sent = C_YMDhms.Now();

        if (json !== null) {
            if ("id" in json)
                this.id = parseInt(json.id);

            if ("message" in json)
                this.Message = json.message;

            if ("audience" in json)
                this.Audience = json.audience;

            if ("created_at" in json)
                this.Created = C_YMDhms.FromString(json.created_at);
            if ("updated_at" in json)
                this.Updated = C_YMDhms.FromString(json.updated_at);
            if ("sent" in json)
                this.Sent = C_YMDhms.FromString(json.sent);
        }
    }

    ToJson() {
        return {
            "id" : this.id.toString(),
            "message" : this.Message,
            "audience" : this.Audience,
            "created_at" : this.Created.toString(),
            "updated_at" : this.Updated.toString(),
            "sent" : this.Sent.toString()
        };
    }

    ToJsonForHeader() {
        return {
            "id" : this.id.toString(),
            "message" : this.Message,
            "audience" : this.Audience,
        };
    }
}

// ----------------------------------------------------------
//            Suggestion
// ----------------------------------------------------------

class C_Suggestion {
    constructor(json) {
        this.id = -1;
        this.UserId = -1;
        this.Subject = "";
        this.Text = "";
        this.Created = C_YMDhms.Now();
        this.Updated = C_YMDhms.Now();
        this.Status = "Open";
        this.FromPublic = false;

        if (json !== null) {
            if ("id" in json)
                this.id = parseInt(json.id);
            if ("user_id" in json)
                this.UserId = parseInt(json.user_id);

            if ("subject" in json)
                this.Subject = json.subject;
            if ("details" in json)
                this.Text = json.details;

            if ("created_at" in json)
                this.Created = C_YMDhms.FromString(json.created_at);
            if ("updated_at" in json)
                this.Updated = C_YMDhms.FromString(json.updated_at);

            if ("status" in json)
                this.Status = json.status;

            if ("from_public" in json)
                this.FromPublic = json.from_public === "true";
        }
    }

    ToJson() {
        return {
            "id" : this.id.toString(),
            "user_id" : this.UserId.toString(),
            "subject" : this.Subject,
            "details" : this.Text,
            "created_at" : this.Created.toString(),
            "updated_at" : this.Updated.toString(),
            "status" : this.Status,
            "from_public" : this.FromPublic ? "true" : "false"
        };
    }

    ToJsonFromHeader() {
        return {
            "id" : this.id.toString(),
            "user_id" : this.UserId.toString(),
            "subject" : this.Subject,
            "details" : this.Text,
            "from_public" : this.FromPublic ? "true" : "false"
        };
    }
}

// -------------------------- drop down manager ------------------------

// Sample invocation:
// let sitesOptions = {
//     "choices": choices,
//     "selitem" : selitem,
//     "dropdownid" : "vitasa_dropdown_site",
//     "buttonid" : "vitasa_button_selectsite"
// };
// sitesDropDown = new C_DropdownHelper(sitesOptions);
// sitesDropDown.SetHelper("sitesDropDown");
// sitesDropDown.CreateDropdown();
//
// input is array of
//   - choices: array of { "text" : "human name name for the item", "item" : "computer name for the item" }
//   - selitem: the "item" that is the default selected item
//   - dropdownid: the id="" that specifies where to put the dropdown items; assumed to be in a <div>
//   - buttonid: the id="" for teh button that initiates the dropdown; we will change the title
// >>> be sure to create this class in the global space, ie, without var, or let, or... <<<
class C_DropdownHelper {
    constructor(options) {
        this.DropDownSelectedItem = null;
        this.Options = options;
    }

    // This is the name of this class, as a string, as it would be seen in the global
    //  space; the value is used in the onclick event handler to find this object
    //  and invoke the appropriate methods.
    SetHelper(help) {
        this.Helper = help;
    }

    CreateDropdown() {
        let options = this.Options;
        let helper = this.Helper;
        this.DropDownSelectedItem = this.Options.selitem;

        // remove any previous items
        $("div#" + options.dropdownid)[0].innerHTML = '';
        // populate the dropdown
        this.Options.choices.forEach(function (c) {
            let seltext = "";
            if ((options.selitem !== null) && (options.selitem === c.item)) {
                seltext = "active";
                document.getElementById(options.buttonid).innerText = c.text;
            }
            const newRow = $("<span>");
            let cols = '<a class="dropdown-item" href="#" ' +
                'onclick="' + helper + '.DropdownItemSelected_Click(\'' + c.item + '\');" ' + seltext + '>' + c.text + '</a>';
            newRow.append(cols);
            $("div#" + options.dropdownid).append(newRow);
        });
    }

    DropdownItemSelected_Click(item) {
        let itemx = null;
        for (let ix = 0; ix !== this.Options.choices.length; ix++) {
            let cx = this.Options.choices[ix];
            if (cx.item === item) {
                itemx = cx;
                break;
            }
        }

        if (itemx !== null) {
            document.getElementById(this.Options.buttonid).innerText = itemx.text;
            this.DropDownSelectedItem = itemx.item;
        }
    }
}



// ----------------------------------------------------------
//            YMD
// ----------------------------------------------------------

/**
 *
 */
class C_YMD {
    constructor (year, month, day) {
        if (!Number.isInteger(year) || !Number.isInteger(month) || !Number.isInteger(day))
            throw new Error("values must be int's and non-null");

        this.Year = year;
        this.Month = month;
        this.Day = day;
    }

    static Now() {
        let dnow = new Date();
        let y = dnow.getFullYear();
        let m = dnow.getMonth() + 1;
        let d = dnow.getDate();

        return new C_YMD(y, m, d);
    }

    AddDays(num) {
        for(let ix = 0; ix !== num; ix++) {
            this.Day++;

            let xd = new Date(this.Year, this.Month, 0);
            let daysInMonth = xd.getDate();

            if (this.Day > daysInMonth) {
                this.Day = 1;
                this.Month++;
                if (this.Month > 12) {
                    this.Month = 1;
                    this.Year++;
                }
            }
        }
    }

    toString() {
        if (!Number.isInteger(this.Year) || !Number.isInteger(this.Month) || !Number.isInteger(this.Day))
            throw new Error("must be ints");

        let y_s = this.Year.toString();

        let m_s = this.Month.toString();
        if (m_s.length === 1)
            m_s = "0" + m_s;

        let d_s = this.Day.toString();
        if (d_s.length === 1)
            d_s = "0" + d_s;

        return y_s + "-" + m_s + "-" + d_s;
    }

    // returns a formated time using the provided format
    // "yyyy" is replaced with 4 digit year, "yy" is replaced with last two digits of year
    // "mm" is replaced with month number (1..12); "mmm" is replaced with month short name
    // "dd" is replaced with day number (1..31)
    // "dow" is replaced with name for the day of the week
    // all other characters in the string are unchanged
    toStringFormat(fmt) {
        let res = fmt.toLowerCase();

        if (res.includes("yyyy"))
            res = res.replace("yyyy", this.Year.toString());
        else if (res.includes("yy")) {
            let ys = this.Year.toString();
            ys = ys.substr(2, 2);
            res = res.replace("yy", ys);
        }

        if (res.includes("mmm")) {
            res = res.replace("mmm", MonthNames[this.Month - 1]);
        }
        else if (res.includes("mm"))
            res = res.replace("mm", this.Month.toString());

        if (res.includes("dd"))
            res = res.replace("dd", this.Day.toString());

        if (res.includes("dow")) {
            let dow = this.DayOfWeek();
            let down = DayOfWeekNames[dow];
            res = res.replace("dow", down);
        }

        return res;
    }

    DayOfWeek() {
        let xd = new Date(this.Year, this.Month - 1, this.Day);
        return xd.getDay();
    }

    DaysInMonth() {
        let xd = new Date(this.Year, this.Month, 0);
        return xd.getDate();
    }

    // format: yyyy-mm-dd
    static FromString(ymd) {
        let ymd_split = ymd.split("-");

        if (ymd_split.length !== 3)
            throw new Error("invalid format");

        let y_s = ymd_split[0];
        let y = parseInt(y_s);

        let m_s = ymd_split[1];
        let m = parseInt(m_s);

        let d_s = ymd_split[2];
        let d = parseInt(d_s);

        return new C_YMD(y, m, d);
    }

    // with members: Year, Month, Day
    static FromObject(ymd) {
        let y = ymd.Year;
        let m = ymd.Month;
        let d = ymd.Day;

        return new C_YMD(y, m, d);
    }

    static FromYMD(year, month, day) {
        return new C_YMD(year, month, day);
    }

    CompareTo(v2) {
        let res = 1;
        if ((this.Year === v2.Year) && (this.Month === v2.Month) && (this.Day === v2.Day))
            res = 0;
        else if ((this.Year < v2.Year)
            || ((this.Year === v2.Year) && (this.Month < v2.Month))
            || ((this.Year === v2.Year) && (this.Month === v2.Month) && (this.Day < v2.Day)))
            res = -1;

        return res;
    }
}

// ----------------------------------------------------------
//            HMS
// ----------------------------------------------------------

class C_HMS {
    constructor (hour, minute, second) {
        this.Hour = hour;
        this.Minute = minute;
        this.Second = second;
    }

    toString() {
        let h = this.Hour.toString();
        if (h.length === 1)
            h = "0" + h;

        let m = this.Minute.toString();
        if (m.length === 1)
            m = "0" + m;

        let s = this.Second.toString();
        if (s.length === 1)
            s = "0" + s;

        return h + ":" + m + ":" + s;
    }

    toStringFormat(fmt) {
        let res = fmt.toLowerCase();

        let ampm = "";
        let ampmHour = this.Hour;
        if (res.includes("p"))
        {
            if (ampmHour > 12) {
                ampmHour = ampmHour - 12;
                ampm = "pm";
                if (ampmHour === 0) {
                    ampmHour = 12;
                    ampm = "am";
                }
            }
            else if (ampmHour === 12)
                ampm = "pm";
            else
                ampm = "am";
        }

        let s_ampmHour =  ampmHour.toString();
        if (ampmHour < 10)
            s_ampmHour = " " + s_ampmHour;

        let min_s = this.Minute.toString();
        if (this.Minute < 9)
            min_s = "0" + min_s;

        let sec_s = this.Second.toString();
        if (this.Second < 9)
            sec_s = "0" + sec_s;

        if (res.includes("hh"))
            res = res.replace("hh", s_ampmHour);
        if (res.includes("mm"))
            res = res.replace("mm", min_s);
        if (res.includes("ss"))
            res = res.replace("ss", sec_s);
        if (res.includes("p"))
            res = res.replace("p", ampm);

        return res;
    }

    // assumed format is "hh:mm:ss"; each may be 1 or 2 digits, must have h and m
    static FromString(hms) {
        let s = 0;

        let hms_split = hms.split(":");

        if (hms_split.length < 2)
            throw new Error("invalid HMS format");

        let h_s = hms_split[0];
        let h = parseInt(h_s);

        let m_s = hms_split[1];
        let m = parseInt(m_s);

        if (hms_split.length > 2) {
            let s_s = hms_split[2];
            s = parseInt(s_s);
        }

        return new C_HMS(h, m, s);
    }

    static Now() {
        let dnow = new Date();
        let h = dnow.getHours();
        let m = dnow.getMinutes();
        let s = dnow.getSeconds();

        return new C_HMS(h, m, s);
    }

    // contains: Hour, Minute, Second
    static FromObject(hms) {
        let h = hms.Hour;
        let m = hms.Minute;
        let s = hms.Second;

        return new C_HMS(h, m, s);
    }

    Get12HourHour() {
        let res = this.Hour;
        if (res > 12)
            res = res - 12;
        if (res === 0)
            res = 12;

        return res;
    }

    IsAm() {
        return this.Hour < 12;
    }

    Num() {
       return this.Hour * 60 * 60 + this.Minute * 60 + this.Second;
    }

    static FromHoursMinutesAMPM(hour, minutes, ampm) {
        let h = hour + (ampm.toLowerCase() === "am" ? 0 : 12);
        if (h === 24)
            h = 0;

        if ((h < 0) || (h > 23))
            throw new Error("Hours value is out of range");
        if ((minutes < 0) || (minutes > 59))
            throw new Error("Minutes value is out of range");

        return new C_HMS(h, minutes, 0);
    }

    CompareTo(v2) {
        let res = 1;
        if ((this.Hour === v2.Hour) && (this.Minute === v2.Minute) && (this.Second === v2.Second))
            res = 0;
        else if ((this.Hour < v2.Hour)
            || ((this.Hour === v2.Hour) && (this.Minute < v2.Minute))
            || ((this.Hour === v2.Hour) && (this.Minute === v2.Minute) && (this.Second < v2.Second)))
            res = -1;

        return res;
    }
}

class C_YMDhms {
    constructor(ymd, hms) {
        if (!(ymd instanceof C_YMD))
            throw new Error("expecting C_YMD");
        if (!(hms instanceof C_HMS))
            throw new Error("expeting C_HMS");

        this.YMD = new C_YMD(ymd.Year, ymd.Month, ymd.Day);
        this.HMS = new C_HMS(hms.Hour, hms.Minute, hms.Second);
    }

    // 2009-06-15T13:45:30.0000000Z
    static FromString(ymdhms) {
        let res = null;

        try {
            let ymd_hms = ymdhms.split('T');

            let ymd_s = ymd_hms[0];
            let ymd_a = ymd_s.split('-');
            let y = parseInt(ymd_a[0]);
            let mo = parseInt(ymd_a[1]);
            let d = parseInt(ymd_a[2]);

            let hms_s = ymd_hms[1];
            let hms_a1 = hms_s.split('.');
            let hms_a = hms_a1[0].split(':');
            let h = parseInt(hms_a[0]);
            let mi = parseInt(hms_a[1]);
            let s = parseInt(hms_a[2]);

            let ymd = new C_YMD(y, mo, d);
            let hms = new C_HMS(h, mi, s);

            res = new C_YMDhms(ymd, hms);
        }
        catch {
            res = new C_YMDhms(C_YMD.Now(), C_HMS.Now());
        }

        return res;
    }

    // 2009-06-15T13:45:30.0000000Z
    toString() {
        return this.YMD.Year.toString() + '-' + C_YMDhms.PadTo(this.YMD.Month, 2) + '-' + C_YMDhms.PadTo(this.YMD.Day, 2) + 'Z' +
            C_YMDhms.PadTo(this.HMS.Hour) + ':' + C_YMDhms.PadTo(this.HMS.Minute) + ':' + C_YMDhms.PadTo(this.HMS.Second) + '.0000000Z';
    }

    CompareTo(ymdhms) {
        let res = 1;

        let ymdCompare = this.YMD.CompareTo(ymdhms.YMD);
        let hmsCompare = this.HMS.CompareTo(ymdhms.HMS);

        if ((ymdCompare === 0) && (hmsCompare === 0))
            res = 0;
        else if (ymdCompare < 0)
            res = -1;
        else if (hmsCompare < 0)
            res = -1;

        return res;
    }

    static Now() {
        return new C_YMDhms(C_YMD.Now(), C_HMS.Now());
    }

    static PadTo(value, digits) {
        let s = value.toString();
        while (s.length < digits) {
            s = '0' + s;
        }

        return s;
    }
}

class C_EncryptDecryption {
    static async encrypt(stringToEncrypt) {
        if (!C_EncryptDecryption._supportsCrypto())
            return stringToEncrypt;

        const mode = 'AES-GCM',
            length = 256,
            ivLength = 12,
            pw = 'now is the time for all good men';

        const encrypted = await C_EncryptDecryption._encrypt(stringToEncrypt, pw, mode, length, ivLength);

        const _iv_s = C_EncryptDecryption.toHexString(encrypted.iv);
        const _ciphertext_s = C_EncryptDecryption.toHexString(encrypted.cipherText);

        const _v = {part1: _iv_s, part2: _ciphertext_s};

        return JSON.stringify(_v);
    }

    static async decrypt(stringToDecrypt) {
        if (!C_EncryptDecryption._supportsCrypto())
            return stringToDecrypt;

        const _v1 = JSON.parse(stringToDecrypt);

        const _iv1 = C_EncryptDecryption.fromHexString(_v1.part1);
        const _ciphertext1 = C_EncryptDecryption.fromHexString(_v1.part2);

        const r_encrypted = {iv: _iv1, cipherText: _ciphertext1};

        const mode = 'AES-GCM',
            length = 256,
            //ivLength = 12,
            pw = 'now is the time for all good men';

        return await C_EncryptDecryption._decrypt(r_encrypted, pw, mode, length);
    }

    static _supportsCrypto () {
        return window.crypto && crypto.subtle && window.TextEncoder;
    }

    static toHexString(byteArray)
    {
        let s = '';
        const ba = new Uint8Array(byteArray);
        ba.forEach(
            function(byte)
            {
                s += ('0' + (byte & 0xFF).toString(16)).slice(-2);
            });
        return s;
    }

    static fromHexString(hexString)
    {
        const result = [];
        while (hexString.length >= 2)
        {
            result.push(parseInt(hexString.substring(0, 2), 16));
            hexString = hexString.substring(2, hexString.length);
        }
        return new Uint8Array(result);
    }

    static async genEncryptionKey (password, mode, length)
    {
        const algo =
            {
                name: 'PBKDF2',
                hash: 'SHA-256',
                salt: new TextEncoder().encode('a-unique-salt'),
                iterations: 1000
            };

        const derived = {name: mode, length: length};
        const encoded = new TextEncoder().encode(password);
        const key = await crypto.subtle.importKey('raw', encoded, {name: 'PBKDF2'}, false, ['deriveKey']);

        return crypto.subtle.deriveKey(algo, key, derived, false, ['encrypt', 'decrypt']);
    }

    static async _encrypt (text, password, mode, length, ivLength)
    {
        const algo =
            {
                name: mode,
                length: length,
                iv: crypto.getRandomValues(new Uint8Array(ivLength))
            };

        const key = await C_EncryptDecryption.genEncryptionKey(password, mode, length);

        const encoded = new TextEncoder().encode(text);

        return { cipherText: await crypto.subtle.encrypt(algo, key, encoded), iv: algo.iv };
    }

    static async _decrypt (encrypted, password, mode, length)
    {
        const algo =
            {
                name: mode,
                length: length,
                iv: encrypted.iv
            };

        const key = await C_EncryptDecryption.genEncryptionKey(password, mode, length);

        const decrypted = await crypto.subtle.decrypt(algo, key, encrypted.cipherText);

        return new TextDecoder().decode(decrypted);
    }
}
