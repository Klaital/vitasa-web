# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Role.create(Role::VALID_ROLE_NAMES.collect {|r| {name: r}})

if Rails.env == 'development'
    Site.create([
        {
            name: "Cody Library",
            slug: 'cody-library',
            street: '11441 Vance Jackson Rd',
            city: 'San Antonio',
            state: 'TX',
            latitude: '29.5324397',
            longitude: '-98.590141',
            google_place_id: 'ChIJETMeHs5gXIYRRDPQxNwy4FU',
            sitecoordinator: nil,
            sitestatus: 'Closed',
        },
        {
            name: "Thousand Oaks Library",
            slug: 'thousand-oaks-library',
            street: '4618 Thousand Oaks',
            city: 'San Antonio',
            state: 'TX',
            latitude: '29.545058',
            longitude: '-98.4036457',
            google_place_id: 'ChIJh8mGDl6LXIYRj-mzXGDC-So',
            sitecoordinator: nil,
            sitestatus: 'Open',
        }
    ])
end
