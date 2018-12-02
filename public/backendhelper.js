/**
 * This is THE interface into the backend. All data elements are accessed from here.
 */

class C_BackendHelper {
    constructor () {
        this.Sites = [];
        this.SitesSampleDateTime = null;
        this.Users = [];
        this.UsersSampleDateTime = null;
        this.WorkLogs = [];
        this.UsingOnlyLocalData = false;
        this.Filter = null;
        this.UserCredentials = null;
        this.Token = null;
        this.ForceFetch = true;
    }

    static get DataExpirationInterval_Seconds() {
        return 0 * 60 * 60;
    }

    get UseLocalDataOnly() {
        return this.UsingOnlyLocalData;
    }
    set UseLocalDataOnly(value) {
        this.UsingOnlyLocalData = value;
    }

    static get CoreURL() {
        // staging server: staging.volunteer-savvy.com
        //return "http://staging.volunteer-savvy.com/";
        // production server: volunteer-savvy.com
        return "http://volunteer-savvy.com/";
    }

    /*
     * load the local data if available or if unexpired, otherwise pull from backend
     * @param {boolean} allSites True if we are to ensure all sites are loaded and current
     * @param {boolean} allUsers True if we are to ensure that users are loaded and current
     */
    async Initialize() {
        // pull the data from localstorage
        await this.LoadSitesFromLocalStorage();
        await this.LoadWorkLogsFromLocalStorage();
        await this.LoadFilterFromLocalStorage();
        await this.LoadUserCredentialsFromLocalStorage();

        if (this.SitesSampleDateTime === null)
            this.SitesSampleDateTime = C_YMDhms.Now();
        if (this.UsersSampleDateTime === null)
            this.UsersSampleDateTime = C_YMDhms.Now();

        let time = Date.now();
        let timeplus = time + C_BackendHelper.DataExpirationInterval_Seconds * 1000;

        let sampleDateTime = new Date(this.SitesSampleDateTime.YMD.Year, this.SitesSampleDateTime.YMD.Month, this.SitesSampleDateTime.YMD.Day,
            this.SitesSampleDateTime.HMS.Hour, this.SitesSampleDateTime.HMS.Minute, this.SitesSampleDateTime.HMS.Second);
        let sampleTime = sampleDateTime.getTime();

        // check to see if the data has expired and we are allowed to fetch from the backend
        let needToRefetch = ((timeplus > sampleTime) || this.ForceFetch) && (!this.UseLocalDataOnly);
        if (needToRefetch) {
            // do the fetch from the backend
            let url = C_BackendHelper.CoreURL + "sites/";
            const resp = await fetch(url, {
                    cache: "no-store",
                    headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json'
                    },
                    method: "get"
                });

            if (resp.status < 200 && resp.status >= 300)
                return Promise.reject(new Error(resp.statusText));

            this.Sites = [];
            let _sites = await resp.json();
            let itIsArray = Array.isArray(_sites);
            if (itIsArray) {
                for (let ix = 0; ix !== _sites.length; ix++) {
                    let sitejson = _sites[ix];
                    let nsite = new C_Site(sitejson);
                    // pull the worklogs out and into a separate table
                    for (let iy = 0; iy !== nsite._WorkItems.length; iy++) {
                        let wi = nsite._WorkItems[iy];
                        let wlFound = false;
                        for (let ix = 0; ix !== nsite._WorkItems.length; ix++) {
                            if (nsite._WorkItems[ix].id === wi.id) {
                                wlFound = true;
                                break;
                            }
                        }
                        if (!wlFound)
                            this.WorkLogs.push(wi);
                    }
                    nsite._WorkItems = [];
                    this.Sites.push(nsite);
                }

                await this.UpdateSitesInLocalStorage();
            }
        }
    }
    
    async LoadAllUsers() {
        await this.LoadUsersFromLocalStorage();

        let time = Date.now();
        let timeplus = time + C_BackendHelper.DataExpirationInterval_Seconds * 1000;

        let sampleDateTime = new Date(this.UsersSampleDateTime.YMD.Year, this.UsersSampleDateTime.YMD.Month, this.UsersSampleDateTime.YMD.Day,
            this.UsersSampleDateTime.HMS.Hour, this.UsersSampleDateTime.HMS.Minute, this.UsersSampleDateTime.HMS.Second);
        let sampleTime = sampleDateTime.getTime();

        // check to see if the data has expired and we are allowed to fetch from the backend
        let needToRefetch = ((timeplus > sampleTime) || this.ForceFetch) && (!this.UseLocalDataOnly);
        if (needToRefetch) {
            // do the fetch from the backend
            let url = C_BackendHelper.CoreURL + "users/";
            const resp = await fetch(url, {
                    cache: "no-store",
                    headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json'
                    },
                    method: "get"
                });

            if (resp.status < 200 && resp.status >= 300)
                return Promise.reject(new Error(resp.statusText));

            this.Users = [];
            let _users = await resp.json();
            let itIsArray = Array.isArray(_users);
            if (itIsArray) {
                for (let ix = 0; ix !== _users.length; ix++) {
                    let userjson = _users[ix];
                    let nuser = new C_User(userjson);
                    // pull the worklogs out and into a separate table
                    for (let iy = 0; iy !== nuser._WorkItems.length; iy++) {
                        let wi = nuser._WorkItems[iy];
                        let wlFound = false;
                        for (let ix = 0; ix !== nuser._WorkItems.length; ix++) {
                            if (nuser._WorkItems[ix].id === wi.id) {
                                wlFound = true;
                                break;
                            }
                        }
                        if (!wlFound)
                            this.WorkLogs.push(wi);
                    }
                    nuser._WorkItems = [];
                    this.Users.push(nuser);

                }

                await this.UpdateUsersInLocalStorage();
            }
        }
    }

    async LoadTestData() {
        // get the test data, load it into localStorage
        this.UseLocalDataOnly = true;

        const resp = await fetch('testdata_sites5.json', {cache: "no-store"});
        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));

        let _sites = await resp.json();
        this.Sites = [];
        for(let ix = 0; ix !== _sites.length; ix++) {
            let sitejson = _sites[ix];
            let nsite = new C_Site(sitejson);

            // pull the worklogs out and into a separate table
            for(let iy = 0; iy !== nsite._WorkItems.length; iy++) {
                let wi = nsite._WorkItems[iy];
                let wlFound = false;
                for(let ix = 0; ix !== nsite._WorkItems.length; ix++) {
                    if (nsite._WorkItems[ix].id === wi.id) {
                        wlFound = true;
                        break;
                    }
                }
                if (!wlFound)
                    this.WorkLogs.push(wi);
            }
            nsite._WorkItems = [];
            
            this.Sites.push(nsite);
        }

        // fix up the calendar entries so that the SiteId is correct
        for(let ix = 0; ix !== this.Sites.length; ix++) {
            let site = this.Sites[ix];
            for(let iy = 0; iy !== site.SiteCalendar.length; iy++) {
                let ce = site.SiteCalendar[iy];
                ce.SiteId = site.id;
            }
        }

        const respu = await fetch('testdata_users2.json', {cache: "no-store"});
        if (respu.status < 200 && respu.status >= 300)
            return Promise.reject(new Error(respu.statusText));

        let users = await respu.json();
        this.Users = [];
        for(let ix = 0; ix !== users.length; ix++) {
            let user = users[ix];
            let nuser = new C_User(user);

            // pull the worklogs out and into a separate table
            for(let iy = 0; iy !== nuser._WorkItems.length; iy++) {
                let wi = nuser._WorkItems[iy];
                let wlFound = false;
                for(let ix = 0; ix !== nuser._WorkItems.length; ix++) {
                    if (nuser._WorkItems[ix].id === wi.id) {
                        wlFound = true;
                        break;
                    }
                }
                if (!wlFound)
                    this.WorkLogs.push(wi);
            }
            nuser._WorkItems = [];

            this.Users.push(nuser);
        }

        this.FixSiteCoordInTestData();

        this.FixSitesCoordinated();

        await this.UpdateSitesInLocalStorage();

        await this.UpdateUsersInLocalStorage();
    }

    /**
     * Load the sites from the user cache
     */
    async LoadSitesFromLocalStorage () {
        this.SitesSampleDateTime = null;
        if ("vitasa_allsites" in localStorage) {
            let _siteslocal = localStorage.vitasa_allsites;
            let _s1 = await C_EncryptDecryption.decrypt(_siteslocal);
            let sjson = JSON.parse(_s1);
            let _sites = sjson.sites;

            this.Sites = [];
            for(let ix = 0; ix !== _sites.length; ix++) {
                let sitejson = _sites[ix];
                let nsite = new C_Site(sitejson);
                this.Sites.push(nsite);
            }
            this.SitesSampleDateTime = C_YMDhms.FromString(sjson.sampleDateTime);
        }
    }

    async UpdateSitesInLocalStorage() {
        // build the string to put back into local storage: expiration + sites (as our cache)
        let sites_j = [];
        this.Sites.forEach(function (site) {
            let site_j = site.ToJson();
            sites_j.push(site_j);
        });

        let now = Date.now();
        let forlocal_clear = { sampleDateTime: now, sites: sites_j };
        let forlocal_clear_s = JSON.stringify(forlocal_clear);

        localStorage.vitasa_allsites = await C_EncryptDecryption.encrypt(forlocal_clear_s);
    }

    async LoadUsersFromLocalStorage() {
        if ("vitasa_allusers" in localStorage) {
            let _userslocal = localStorage.vitasa_allusers;
            let _u1 = await C_EncryptDecryption.decrypt(_userslocal);
            let ujson = JSON.parse(_u1);
            let _users = ujson.users;

            this.Users = [];
            for(let ix = 0; ix !== _users.length; ix++) {
                let userjson = _users[ix];
                let nuser = new C_User(userjson);
                this.Users.push(nuser);
            }
            this.UsersSampleDateTime = C_YMDhms.FromString(ujson.sampleDateTime);
        }
    }

    async UpdateUsersInLocalStorage() {
        // build the string to put back into local storage: expiration + sites (as our cache)
        let users_j = [];
        this.Users.forEach(function (user) {
            let user_j = user.ToJson();
            users_j.push(user_j);
        });

        let now = Date.now();
        let forlocal_clear = { sampleDateTime: now, users: users_j };
        let forlocal_clear_s = JSON.stringify(forlocal_clear);

        localStorage.vitasa_allusers = await C_EncryptDecryption.encrypt(forlocal_clear_s);
    }

    async LoadWorkLogsFromLocalStorage() {
        if ("vitasa_worklogs" in localStorage) {
            let _worklogsLocal_encrypted = localStorage.vitasa_worklogs;
            let _worklogsLocal_decrypted = await C_EncryptDecryption.decrypt(_worklogsLocal_encrypted);
            let _worklogs_json = JSON.parse(_worklogsLocal_decrypted);
            let _worklogs = _worklogs_json.users;

            this.WorkLogs = [];
            for(let ix = 0; ix !== _worklogs.length; ix++) {
                let worklog_json = _worklogs[ix];
                let worklog = new C_User(worklog_json);
                this.WorkLogs.push(worklog);
            }
        }
    }

    async UpdateWorkLogsInLocalStorage() {
        // build the string to put back into local storage: expiration + sites (as our cache)
        let worklogs = [];
        this.Users.forEach(function (worklog) {
            let worklog_json = worklog.ToJson();
            worklogs.push(worklog_json);
        });

        let now = Date.now();
        let forlocal_clear = { sampleDateTime: now, users: worklogs };
        let forlocal_clear_s = JSON.stringify(forlocal_clear);

        localStorage.vitasa_worklogs = await C_EncryptDecryption.encrypt(forlocal_clear_s);
    }

    async LoadFilterFromLocalStorage() {
        if (!("vitasa_sitesfiter" in localStorage)) {
            // create a new filter
            let nfilter = new C_Filter(null);
            let nfilter_j = nfilter.ToJson();
            let nfilter_s = JSON.stringify(nfilter_j);
            localStorage.vitasa_sitesfiter = await C_EncryptDecryption.encrypt(nfilter_s);
        }

        let filter_s_e = localStorage.vitasa_sitesfiter;
        let filter_s = await C_EncryptDecryption.decrypt(filter_s_e);
        let filter_j = JSON.parse(filter_s);

        this.Filter = new C_Filter(filter_j);
    }

    async UpdateFilterToLocalStorage() {
        let filter_s = JSON.stringify(this.Filter.ToJson());
        localStorage.vitasa_sitesfiter = await C_EncryptDecryption.encrypt(filter_s);
    }

    async LoadUserCredentialsFromLocalStorage() {
        if ("vitasa_loggedinuser" in localStorage) {
            const usercred_s_e = localStorage.vitasa_loggedinuser;
            const usercred_s = await C_EncryptDecryption.decrypt(usercred_s_e);
            const usercred_j = JSON.parse(usercred_s);
            this.UserCredentials = new C_UserCredential(usercred_j);
        }
        else {
            this.UserCredentials = new C_UserCredential(null);
        }
    }

    async UpdateUserCredentialsToLocalStorage() {
        let usercred_j = this.UserCredentials.ToJson();
        const usercred_s = JSON.stringify(usercred_j);
        localStorage.vitasa_loggedinuser = await C_EncryptDecryption.encrypt(usercred_s);
    }

    async ClearUserCredentialsInLocalStorage() {
        this.UserCredentials = new C_UserCredential(null);
        const usercred_s = JSON.stringify(this.UserCredentials.ToJson());
        localStorage.vitasa_loggedinuser = await C_EncryptDecryption.encrypt(usercred_s);
    }

    // ===============================================================================================
    //                           Sites
    // ===============================================================================================

    async CreateSite(site) {
        if (!(site instanceof C_Site))
            throw new Error("Expecing C_Site");
        if (site.Name.length === 0)
            return Promise.reject(new Error('site name required'));

        if (this.UsingOnlyLocalData) {
            let maxid = -1;
            for(let ix = 0; ix !== this.Sites.length; ix++) {
                if (this.Sites[ix].id > maxid)
                    maxid = this.Sites[ix].id;
            }
            site.id = ++maxid;

            this.Sites.push(site);
            return;
        }

        const _sitejson = site.ToJsonForBackend();

        const url = C_BackendHelper.CoreURL + "sites/";
        const resp = await fetch(url, {
            method: 'post',
            body: JSON.stringify(_sitejson),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));

        let _site = await resp.json();
        let nsite = new C_Site(_site);
        this.Sites.push(nsite);
    }

    async UpdateSite(site) {
        if (!(site instanceof C_Site))
            throw new Error("Expecing C_Site");
        if (site.Name.length === 0)
            return Promise.reject(new Error('site name required'));
        if (site.Slug.length === 0)
            return Promise.reject(new Error('site slug required'));

        if (this.UsingOnlyLocalData) {
            return;
        }

        const _sitejson = site.ToJsonForBackend();

        const url = C_BackendHelper.CoreURL + "sites/" + site.Slug;
        const resp = await fetch(url, {
            method: 'put',
            body: JSON.stringify(_sitejson),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));
    }

    async DeleteSite(site) {
        if (!(site instanceof C_Site))
            throw new Error("Expecing C_Site");
        if (site.Slug.length === 0)
            throw new Error('site slug required');

        if (this.UsingOnlyLocalData) {
            this._RemoveSite(site);

            return;
        }

        const url = C_BackendHelper.CoreURL + "sites/" + site.Slug;
        const resp = await fetch(url, {
            method: 'delete',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));

        this._RemoveSite(site);
    }

    _RemoveSite(site) {
        // remove from the local copy
        for(let ix = 0; ix !== this.Sites.length; ix++) {
            if (this.Sites[ix].id === site.id) {
                this.Sites.splice(ix, 1);
                break;
            }
        }

        let worklogsToRemove = [];
        // remove any workitems for this site
        for(let ix = 0; ix !== this.WorkLogs.length; ix ++) {
            if (this.WorkLogs[ix].SiteId === site.id)
                worklogsToRemove.push(this.WorkLogs[ix]);
        }
        for(let ix = 0; ix !== worklogsToRemove.length; ix++) {
            let wltr = worklogsToRemove[ix];
            // find the worklog in the array and splice it out
            for(let ix = 0; ix !== worklogsToRemove.length; ix ++) {
                if (worklogsToRemove[ix].id === wltr.id) {
                    this.WorkLogs.splice(ix, 1);
                    break;
                }
            }
        }
    }

    GetAllSites() {
        return this.Sites;
    }

    FindSiteById(id) {
        if (!Number.isInteger(id))
            throw Error("expecting integer");

        let res = null;
        for(let six = 0; six !== this.Sites.length; six++) {
            const s = this.Sites[six];
            if (s.id === id) {
                res = s;
                break;
            }
        }

        return res;
    }

    FindSiteBySlug(slug) {
        if (typeof slug !== 'string')
            throw new Error("expecting type string");

        let res = null;
        for(let six = 0; six !== this.Sites.length; six++) {
            const s = this.Sites[six];
            if (s.Slug === slug) {
                res = s;
                break;
            }
        }

        return res;
    }

    FindOpenSitesOnDate(date) {
        if (!(date instanceof C_YMD))
            throw new Error("date must be a C_YMD");

        let res = []; // list of calendar entries for sites open on requested date
        this.Sites.forEach(function(site) {
            site.SiteCalendar.forEach(function(ce) {
                if ((ce.Date.CompareTo(date) === 0) && ce.SiteIsOpen)
                    res.push(ce);
            });
        });

        return res;
    }

    FindOpenMobileSitesOnDate(date) {
        if (!(date instanceof C_YMD))
            throw new Error("date must be a C_YMD");

        let res = []; // list of calendar entries for sites open on requested date
        this.Sites.forEach(function(site) {
            if (site.SiteType.toLowerCase() === "mobile") {
                site.SiteCalendar.forEach(function (ce) {
                    if ((ce.Date.CompareTo(date) === 0) && ce.SiteIsOpen)
                        res.push(ce);
                });
            }
        });

        return res;
    }

    /**
     * @return {boolean}
     */
    AnySiteOpenOnDate(date) {
        let res = false;

        for(let ix = 0; ix !== this.Sites.length; ix++) {
            let site = this.Sites[ix];
            let ce = site.FindCalendarEntryForDate(date);
            if ((ce != null) && ce.SiteIsOpen) {
                res = true;
                break;
            }
        }

        return res;
    }
    FindAllMobileSites() {
        let res = [];

        this.Sites.forEach(function (site) {
            if (site.SiteType.toLowerCase() === "mobile")
                res.push(site);
        });

        return res;
    }

    // ===============================================================================================
    //                           Calendar Entries
    // ===============================================================================================

    async CreateCalendarEntry(calendarentry) {
        if (!(calendarentry instanceof C_CalendarEntry))
            throw new Error("expecting type C_WorkLog");

        let site = this.FindSiteById(calendarentry.SiteId);
        if (site === null)
            throw new Error("site not found");

        if (this.UsingOnlyLocalData) {

            let maxid = -1;
            for(let ix = 0; ix !== site.SiteCalendar.length; ix++) {
                if (site.SiteCalendar[ix].id > maxid)
                    maxid = site.SiteCalendar[ix].id;
            }
            calendarentry.id = ++maxid;

            site.SiteCalendar.push(calendarentry);
            return;
        }

        const _calendaritem_json = calendarentry.ToJson();

        const url = C_BackendHelper.CoreURL + "sites/" + site.Slug + "/calendars/";
        const resp = await fetch(url, {
            method: 'post',
            body: JSON.stringify(_calendaritem_json),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));

        let cejson_ = await resp.json();
        let ce_ = new C_CalendarEntry(cejson_);

        site.SiteCalendar.push(ce_);
    }

    async UpdateCalendarEntry(calendarentry) {
        if (!(calendarentry instanceof C_CalendarEntry))
            throw new Error("expecting type C_CalendarEntry");

        if (this.UsingOnlyLocalData) {
            return;
        }

        let site = this.FindSiteById(calendarentry.SiteId);
        if (site === null)
            throw new Error("site not found");

        const _calendaritem_json = calendarentry.ToJson();

        const url = C_BackendHelper.CoreURL + "sites/" + site.Slug + "/calendars/" + calendarentry.id.toString();
        const resp = await fetch(url, {
            method: 'put',
            body: JSON.stringify(_calendaritem_json),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));
    }

    async DeleteCalendarEntry(calendarentry) {
        if (!(calendarentry instanceof C_CalendarEntry))
            throw new Error("expecting type C_CalendarEntry");

        let site = this.FindSiteById(calendarentry.SiteId);
        if (site === null)
            throw new Error("site not found");

        if (this.UsingOnlyLocalData) {
            C_BackendHelper._RemoveCalendarEntry(calendarentry, site);
            return;
        }

        const url = C_BackendHelper.CoreURL + "sites/" + site.Slug + "/calendars/" + calendarentry.id.toString();
        const resp = await fetch(url, {
            method: 'delete',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));

        C_BackendHelper._RemoveCalendarEntry(calendarentry, site);
    }

    static _RemoveCalendarEntry(calendarentry, site) {
        if (!(calendarentry instanceof C_CalendarEntry))
            throw new Error("expecting type C_CalendarEntry");
        if (!(site instanceof C_Site))
            throw new Error("expecting C_Site");

        for(let iy = 0; iy !== site.SiteCalendar.length; iy++) {
            if (site.SiteCalendar[iy].id === calendarentry.id) {
                site.SiteCalendar.splice(iy, 1);
                break;
            }
        }
    }

    GetCalendarEntriesForSite(siteid) {
        if (!Number.isInteger(siteid))
            throw new Error("expecting integer");

        let site = this.FindSiteById(siteid);
        if (site === null)
            throw new Error("site not found");

        return site.SiteCalendar;
    }

    // ===============================================================================================
    //                           Users
    // ===============================================================================================

    async CreateUser(user) {
        if (!(user instanceof C_User))
            throw new Error("expecting C_User");

        if (this.UsingOnlyLocalData) {
            let maxid = -1;
            for(let ix = 0; ix !== this.Users.length; ix++) {
                if (this.Users[ix].id > maxid)
                    maxid = this.Users[ix].id;
            }
            user.id = ++maxid;
            this.Users.push(user);
            return;
        }

        const _userjson = user.ToJsonForHeader();

        const url = C_BackendHelper.CoreURL + "users/";
        const resp = await fetch(url, {
            method: 'post',
            body: JSON.stringify(_userjson),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            }
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));

        let userjson_ = await resp.json();
        let user_ = new C_User(userjson_);

        this.Users.push(user_);
    }

    async UpdateUser(user) {
        if (!(user instanceof C_User))
            throw new Error("expecting C_User");

        if (this.UsingOnlyLocalData) {
            return;
        }

        const _userjson = user.ToJsonForBackend();

        const url = C_BackendHelper.CoreURL + "users/" + user.id.toString();
        const resp = await fetch(url, {
            method: 'put',
            body: JSON.stringify(_userjson),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));
    }

    async DeleteUser(user) {
        if (!(user instanceof C_User))
            throw new Error("expecting C_User");

        if (this.UsingOnlyLocalData) {
            for(let ix = 0; ix !== this.Users.length; ix++) {
                if (this.Users[ix].id === user.id) {
                    this.Users.splice(ix, 1);
                    break;
                }
            }

            return;
        }

        const url = C_BackendHelper.CoreURL + "users/" + user.id;
        const resp = await fetch(url, {
            method: 'delete',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));

        for(let ix = 0; ix !== this.Users.length; ix++) {
            if (this.Users[ix].id === user.id) {
                this.Users.splice(ix, 1);
                break;
            }
        }
    }

    async RegisterUser(name, email, password, phone) {
        if (!(typeof name === 'string'))
            throw new Error("Expecting string");
        if (!(typeof email === 'string'))
            throw new Error("Expecting string");
        if (!(typeof password === 'string'))
            throw new Error("Expecting string");
        if (!(typeof phone === 'string'))
            throw new Error("Expecting string");

        const _user = {
            "name" : name,
            "email" : email,
            "password" : password,
            "password_confirmation" : password,
            "phone" : phone
        };

        const url = C_BackendHelper.CoreURL + "users/";

        const resp = await fetch(url, {
            method: 'post',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(_user)
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));

        let userjson_ = await resp.json();
        let user_ = new C_User(userjson_);

        this.Users.push(user_);
    }

    async DoLogin(email, password) {
        if (!(typeof email === 'string'))
            throw new Error("Expecting string");
        if (!(typeof password === 'string'))
            throw new Error("Expecting string");

        if (this.UsingOnlyLocalData) {
            let foundUser = null;
            for(let ix = 0; ix !== this.Users.length; ix++) {
                if (this.Users[ix].Email === email) {
                    foundUser = this.Users[ix];
                    break;
                }
            }
            return foundUser;
        }

        const loginJson =
            {
                "email" : email,
                "password" : password
            };

        const url = C_BackendHelper.CoreURL + "login/";
        const resp = await fetch(url,
            {
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                method : "post",
                body: JSON.stringify(loginJson)
            });

        if (resp.status < 200 && resp.status >= 300)
            return null;

        let _user = await resp.json();
        let user = new C_User(_user);

        // todo: this doesn't work; waiting on Chris to tell me new method of getting the token
        this.Token = resp.headers.get('Set-Cookie');

        return user;
    }

    async DoLogout() {
        this.Token = null;
        await this.ClearUserCredentialsInLocalStorage();
    }

    GetAllUsers() {
        return this.Users;
    }

    FindUserById(id) {
        if (!Number.isInteger(id))
            throw new Error("expecting integer");

        let res = null;
        for(let ix = 0; ix !== this.Users.length; ix++) {
            let u = this.Users[ix];
            if (u.id === id) {
                res = u;
                break;
            }
        }

        return res;
    }

    FindUserByEmail(email) {
        if (typeof email !== 'string')
            throw new Error("expecting string");

        let res = null;
        for(let ix = 0; ix !== this.Users.length; ix++) {
            let u = this.Users[ix];
            if (u.Email === email) {
                res = u;
                break;
            }
        }

        return res;
    }

    FindAllVolunteers() {
        let res = [];

        this.Users.forEach(function (user) {
            if (user.HasVolunteer())
                res.push(user);
        });

        return res;
    }

    // ===============================================================================================
    //                           WorkLog
    // ===============================================================================================

    async CreateWorkLog(workitem) {
        if (!(workitem instanceof C_WorkLog))
            throw new Error("expecting type C_WorkLog");

        if (this.UsingOnlyLocalData) {
            let maxid = -1;
            for(let ix = 0; ix !== this.WorkLogs.length; ix++) {
                if (this.WorkLogs[ix].id > maxid)
                    maxid = this.WorkLogs[ix].id;
            }
            workitem.id = ++maxid;
            this.WorkLogs.push(workitem);

            return;
        }

        const _workitem = workitem.ToJson();

        const url = C_BackendHelper.CoreURL + "users/" + workitem.UserId.toString() + "/work_logs";
        const resp = await fetch(url, {
            method: 'post',
            body: JSON.stringify(_workitem),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));

        let workitemjson_ = await resp.json();
        let workitem_ = new C_WorkLog(workitemjson_);

        this.WorkLogs.push(workitem_);
    }

    async UpdateWorkLog(workitem) {
        if (!(workitem instanceof C_WorkLog))
            throw new Error("expecting type C_WorkLog");

        if (this.UsingOnlyLocalData) {
            return;
        }

        const _workitem = workitem.ToJson();

        const url = C_BackendHelper.CoreURL + "users/" + workitem.UserId.toString() + "/work_logs/" + workitem.id.toString();
        const resp = await fetch(url, {
            method: 'put',
            body: JSON.stringify(_workitem),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));
    }

    async DeleteWorkLog(workitem) {
        if (!(workitem instanceof C_WorkLog))
            throw new Error("expecting type C_WorkLog");

        if (this.UsingOnlyLocalData) {
            // find the work item in the  list and remove
            for(let ix = 0; ix !== this.WorkLogs.length; ix++) {
                let wi = this.WorkLogs[ix];
                if (wi.id === workitem.id) {
                    this.WorkLogs.splice(ix, 1);
                    break;
                }
            }
            return;
        }

        const url = C_BackendHelper.CoreURL + "users/" + workitem.UserId.toString() + "/work_logs/" + workitem.id.toString();
        const resp = await fetch(url, {
            method: 'put',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));

        // find the work item in the  list and remove
        for(let ix = 0; ix !== this.WorkLogs.length; ix++) {
            let wi = this.WorkLogs[ix];
            if (wi.id === workitem.id) {
                this.WorkLogs.splice(ix, 1);
                break;
            }
        }
    }

    GetWorkLogForUser(userid) {
        let res = [];

        for(let ix = 0; ix !== this.WorkLogs.length; ix++) {
            if (this.WorkLogs[ix].UserId === userid)
                res.push(this.WorkLogs[ix]);
        }

        return res;
    }

    GetWorkLogForSite(siteid) {
        let res = [];

        for(let ix = 0; ix !== this.WorkLogs.length; ix++) {
            if (this.WorkLogs[ix].SiteId === siteid)
                res.push(this.WorkLogs[ix]);
        }

        return res;
    }

    FindWorkItem(wlid) {
        let res = null;

        for(let ix = 0; ix !== this.WorkLogs.length; ix++) {
            if (this.WorkLogs[ix].id === wlid) {
                res = this.WorkLogs[ix];
                break;
            }
        }

        return res;
    }

    // ===============================================================================================
    //                           SitesCoordinated
    // ===============================================================================================

    async AddSiteCoordinatorForSite(user, siteid) {
        if (!Number.isInteger(siteid))
            throw new Error("expecting integer");
        if (!(user instanceof C_User))
            throw new Error("expecting C_User");

        if (this.UsingOnlyLocalData) {
            let site = this.FindSiteById(siteid);
            if (site === null)
                throw new Error("site not found");

            let nsc = new C_SiteCoordinated(null);
            nsc.SiteId = siteid;
            nsc.SiteName = site.Name;
            nsc.SiteSlug = site.Slug;

            // add to the users workitems
            user.SitesCoordinated.push(nsc);

            // add to the site as well
            site.SiteCoordinatorIds.push(user.id);
            site.SiteCoordinatorNames.push(user.Name);
            return;
        }

        let site = this.FindSiteById(siteid);
        if (site === null)
            throw new Error("site not found");

        let nsc = new C_SiteCoordinated(null);
        nsc.SiteId = siteid;
        nsc.SiteName = site.Name;
        nsc.SiteSlug = site.Slug;

        const _sitecoordinated = nsc.ToJson();

        const url = C_BackendHelper.CoreURL + "users/" + user.id.toString() + "/sitecoordinator";
        const resp = await fetch(url, {
            method: 'post',
            body: JSON.stringify(_sitecoordinated),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));

        let sitecoordinatedjson_ = await resp.json();
        let sitecoordinated_ = new C_SiteCoordinated(sitecoordinatedjson_);

        // add to the users workitems
        user.SitesCoordinated.push(sitecoordinated_);

        // add to the site as well
        site.SiteCoordinatorIds.push(user.id);
        site.SiteCoordinatorNames.push(user.Name);
    }

    async RemoveSiteCoordinatorForSite(user, siteid) {
        if (!Number.isInteger(siteid))
            throw new Error("expecting integer");
        if (!(user instanceof C_User))
            throw new Error("expecting C_User");

        if (this.UsingOnlyLocalData) {
            // remove from the users list
            for(let ix = 0; ix !== user.SitesCoordinated.length; ix++) {
                if (user.SitesCoordinated[ix].SiteId === siteid) {
                    user.SitesCoordinated.splice(ix, 1);
                    break;
                }
            }

            // remove from the site's list
            let site = BackendHelper.FindSiteById(siteid);
            let ix = site.SiteCoordinatorIds.indexOf(user.id);
            if (ix !== -1) {
                site.SiteCoordinatorIds.splice(ix, 1);
                site.SiteCoordinatorNames.splice(ix, 1);
            }
            return;
        }

        const url = C_BackendHelper.CoreURL + "users/" + user.id.toString() + "/sitecoordinator";
        const resp = await fetch(url, {
            method: 'delete',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));

        // remove from the users list
        for(let ix = 0; ix !== user.SitesCoordinated.length; ix++) {
            if (user.SitesCoordinated[ix].SiteId === siteid) {
                user.SitesCoordinated.splice(ix, 1);
                break;
            }
        }

        // remove from the site's list
        let site = BackendHelper.FindSiteById(siteid);
        let ix = site.SiteCoordinatorIds.indexOf(user.id);
        if (ix !== -1) {
            site.SiteCoordinatorIds.splice(ix, 1);
            site.SiteCoordinatorNames.splice(ix, 1);
        }
    }

    // ===============================================================================================
    //                           Filter
    // ===============================================================================================

    async SaveFilter() {
        await this.UpdateFilterToLocalStorage();
    }

    GetFilteredSites(user) {
        if ((user !== null) && !(user instanceof C_User))
            throw new Error("expecting C_User");

        let res = [];
        // determine the required date, if any
        for(let i = 0; i !== this.Sites.length; i++) {
            let site = this.Sites[i];

            let ok = this.Filter.Dates === "all";
            if (!ok) {
                // compute the date required by the filter
                const date = C_BackendHelper.convertDateRequirementToDate(this.Filter.Dates);
                const datey = date.getFullYear();
                const datem = date.getMonth();
                const dated = date.getDay();
                // see if there is a calendar entry with this date
                const calendarEntries = site.SiteCalendar;
                for(let cex = 0; cex !== calendarEntries.length; cex++) {
                    const ce = calendarEntries[cex]; // form of yyyy-mm-dd
                    const cedate = ce.Date;
                    const cedatesplit = cedate.split("-");
                    if (cedatesplit.length === 3) {
                        const sy = parseInt(cedatesplit[0]);
                        const sm = parseInt(cedatesplit[1]);
                        const sd = parseInt(cedatesplit[2]);
                        if ((datey === sy) && (datem === sm) && (dated === sd)) {
                            ok = true;
                            break;
                        }
                    }
                }
            }

            // if we found a calendar date match then we can see if there is a site capability match
            if (ok)
                ok = this.Filter.SiteMatchesFilter(site, user);

            if (ok)
                res.push(site);
        }

        return res;
    }

    static convertDateRequirementToDate(datereq) {
        let incr = parseInt(datereq.slice(-1));

        let date = Date.now();
        let dateincr = date + incr * 24*60*60*1000;

        let res = new Date();
        res.setTime(dateincr);

        return res;
    }

    // ===============================================================================================
    //                           Notifications
    // ===============================================================================================

    async PostNotification(noti) {
        if (!(noti instanceof C_Notification))
            throw new Error("expecting _Notification");

        if (this.UsingOnlyLocalData) {
            return;
        }

        const _notejson = noti.ToJsonForHeader();

        let url = C_BackendHelper.CoreURL + "/notification_requests";
        if (noti.id !== -1)
            url += "/" + noti.id.toString() + "/resend";
        else
            url += "/send";

        const resp = await fetch(url, {
            method: 'post',
            body: JSON.stringify(_notejson),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));
    }

    async DeleteNotification(noti) {
        if (!(noti instanceof C_Notification))
            throw new Error("expecting _Notification");

        if (this.UsingOnlyLocalData) {
            return;
        }

        let url = C_BackendHelper.CoreURL + "/notification_requests";
        if (noti.id !== -1)
            url += '/' + noti.id.toString();

        const resp = await fetch(url, {
            method: 'delete',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));
    }

    async GetAllNotifications() {
        if (this.UsingOnlyLocalData) {
            let res1 = [];
            return res1;
        }

        let url = C_BackendHelper.CoreURL + "/notification_requests";

        const resp = await fetch(url, {
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            }
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));

        let notesjson_ = await resp.json();

        let res = [];
        notesjson_.forEach(function (notejson) {
            let nnote = new C_Notification(notejson);
            res.push(nnote);
        });

        return res;
    }

    // ===============================================================================================
    //                           Suggestions
    // ===============================================================================================

    async CreateSuggestion(sugg) {
        if (!(sugg instanceof C_Suggestion))
            throw new Error("expecting C_Suggestion");

        if (this.UsingOnlyLocalData) {
            return;
        }

        const _sugjson = sugg.ToJsonFromHeader();

        let url = C_BackendHelper.CoreURL + "/sugestions";

        const resp = await fetch(url, {
            method: 'post',
            body: JSON.stringify(_sugjson),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));
    }

    async UpdateSuggestion(sugg) {
        if (!(sugg instanceof C_Suggestion))
            throw new Error("expecting C_Suggestion");

        if (this.UsingOnlyLocalData) {
            return;
        }

        const _sugjson = sugg.ToJsonFromHeader();

        let url = C_BackendHelper.CoreURL + "/sugestions";

        const resp = await fetch(url, {
            method: 'put',
            body: JSON.stringify(_sugjson),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));
    }

    async DeleteSuggestion(sugg) {
        if (!(sugg instanceof C_Suggestion))
            throw new Error("expecting C_Suggestion");

        if (this.UsingOnlyLocalData) {
            return;
        }

        let url = C_BackendHelper.CoreURL + "/sugestions/" + sugg.id.toString();

        const resp = await fetch(url, {
            method: 'delete',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            },
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));
    }

    async GetAllSuggestions() {
        if (this.UsingOnlyLocalData) {
            return;
        }

        let url = C_BackendHelper.CoreURL + "/sugestions";

        const resp = await fetch(url, {
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'cookie' : this.Token
            }
        });

        if (resp.status < 200 && resp.status >= 300)
            return Promise.reject(new Error(resp.statusText));

        let suggestionsjson_ = await resp.json();

        let res = [];
        suggestionsjson_.forEach(function (sug) {
            let sugg = new C_Suggestion(sug);
            res.push(sugg);
        });

        return res;
    }

    // ===============================================================================================
    //                           Misc Helpers
    // ===============================================================================================

    FixSitesCoordinated() {
        // SiteId's
        for(let ix = 0; ix !== this.Users.length; ix++) {
            let user = this.Users[ix];
            for(let iy = 0; iy !== user.SitesCoordinated.length; iy++) {
                let sc = user.SitesCoordinated[iy];
                // fix the site with this slug
                for(let ix = 0; ix !== this.Sites.length; ix++) {
                    if (this.Sites[ix].Slug === sc.SiteSlug) {
                        sc.SiteId = this.Sites[ix].id;
                    }
                }
            }
        }
    }

    FixSiteCoordInTestData() {
        // fix up the site coordinator id/name in each site (the base data is missing this)
        for(let ix = 0; ix !== this.Sites.length; ix++) {
            let site = this.Sites[ix];
            // find all users that support this site
            let scusers = []; // list of C_User

            // find all the site coordinators that have this site in the support list
            for(let iy = 0; iy !== this.Users.length; iy++) {
                let user = this.Users[iy];
                if (!user.HasSiteCoordinator)
                    return;

                for(let iz = 0; iz !== user.SitesCoordinated.length; iz++) {
                    let sc = user.SitesCoordinated[iz];
                    if (sc.SiteId === site.id) {
                        scusers.push(user);
                    }
                }
            }

            if (scusers.length !== 0) {
                site.SiteCoordinatorIds = [];
                site.SiteCoordinatorNames = [];

                for(let iy = 0; iy !== scusers.length; iy++) {
                    let scuser = scusers[iy];
                    site.SiteCoordinatorIds.push(scuser.id);
                    site.SiteCoordinatorNames.push(scuser.Name);
                }
            }
        }
    }
}