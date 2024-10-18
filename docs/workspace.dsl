workspace {

    model {
        !identifiers hierarchical
        properties {
            "structurizr.groupSeparator" "/"
        }

        group "Generic Function Modules" {
            prs = softwareSystem "Pseudonym Reference Service" {
                tags "Generic Function Modules"
            }
            ads = softwareSystem "Adressing Service" {
                tags "Generic Function Modules"
            }

            nri = softwareSystem "National Referral Index" {
                tags "Generic Function Modules"

                localize = container "Localize API"
                update = container "Update API"
            }
        }

        group "Healthcare Provider domain" {
            epdUser = person "Healthcare Professional"
            epd = softwareSystem "EPD/PACS" {
                tags "Healthcare Application"
                timelineModule = container "Timeline Module"
            }
            adminPortal = softwareSystem "Admin Portal"
            admin = person "Administrator"

            localAds = softwareSystem "Local Addressing Register" {
                tags "Healthcare Application"
            }

            lmr = softwareSystem "Localization Metadata Register" {
                tags "Reference Implementation"

                api = container "API"
                db = container "Database"
            }

            sourceLmr = softwareSystem "Localization Metadata Register (Source)" {
                tags "Reference Implementation"
            }
            lrs = softwareSystem "Localization Register Service" {
                tags "Reference Implementation"
                api = container "LRS API"
            }
        }

        lmr -> nri "Update localization data"
        epdUser -> epd
        epdUser -> epd "Find Healthcare data provider endpoints"

        nri -> prs "Request base Pseudonym"
        lmr -> prs

        lrs.api -> prs "Request Pseudonym"
        lrs.api -> nri "Localize health data with Pseudonym"
        lrs.api -> ads "Find endpoints [ITI-90]"
        lrs.api -> lmr "Fetch metadata [FHIR]"

        epd -> nri.localize "Localize health data with Pseudonym"
        epd -> nri.update "Update localization data"
        epd -> ads "Find endpoints [ITI-90]"
        epd -> lmr "Fetch metadata [FHIR]"
        epd -> prs "Request Pseudonym"
        epd -> lrs "Request timeline"

        admin -> adminPortal
        adminPortal -> ads
        adminPortal -> localAds
        localAds -> ads
    }

    views {
        terminology {
            person "Person"
            softwareSystem "System"
            container "Container"
            component "Component"
            deploymentNode "Deployment node"
            infrastructureNode "Infrastructuur"
            relationship "Relation"
        }

        systemContext lrs "Architecture" {
            include *
        }

        dynamic * "LocalizeHealthData" {
            title "Localize Health Data"
            epdUser -> epd "Request patient overview"
            epd -> prs "Request Pseudonym"
            epd -> nri "Localize health data with Pseudonym"
            nri -> prs
        }

        dynamic * "FindEndpoints" {
            title "Find Endpoints"
            epdUser -> epd "Find Healthcare data provider endpoints"
            epd -> ads
        }

        dynamic * "FetchMetadata" {
            title "Fetch Metadata"
            epdUser -> epd "Request metadata"
            epd -> prs "Request Pseudonym"
            epd -> lmr 
            lmr -> prs "Lookup lmr pseudonym"
        }

        dynamic * "UpdateLocalization" {
            title "Update Localization without a Localization Metadata Register"
            epdUser -> epd "Add or update health data for a patient"
            {

            }
            epd -> prs "Create and request Pseudonym"
            epd -> nri "Update localization data"
            nri -> prs "Lookup nri pseudonym"
        }
        
        dynamic * "UpdateLocalizationWithMetadataRegister" {
            title "Update Localization with a Localization Metadata Register"
            epdUser -> epd "Add or update health data for a patient"
            epd -> lmr "Add or update metadata for a patient"
            lmr -> prs "Request Pseudonym"
            lmr -> nri "Update localization data"
            nri -> prs "Lookup nri pseudonym"
        }

        dynamic * "UpdateAddressbookReferrals" {
            title "Update Addressbook Referrals"
            admin -> adminPortal "Change addressbook registration"
            adminPortal -> ads "Update addressbook referrals"
        }

        dynamic * "UpdateAddressbook" {
            title "Update Addressbook"
            ads -> localAds "Request Care Services Updates [ITI-91]"
        }

        dynamic * "UpdateAddressbookExample" {
            title "Update Addressbook (Example flow)"
            admin -> adminPortal "Change endpoint address"
            adminPortal -> localAds "Change endpoint address"
            ads -> localAds "Request Care Services Updates [ITI-91]"
        }

        dynamic * "RequestTimeline" {
            title "Request timeline"
            epdUser -> epd "Lookup timeline"
            epd -> lrs "Request timeline"
            lrs -> prs "Request Pseudonym"
            lrs -> nri
            nri -> prs "Lookup nri pseudonym"
            lrs -> ads
            lrs -> lmr
            lmr -> prs "Lookup lmr pseudonym"
        }

        dynamic * "LocalizeInterface" {
            title "Localize health data interface"
            epd -> nri "Localize health data with Pseudonym"
        }
        
        dynamic * "UpdateLocalizationDataInterface" {
            title "Update localization data interface"
            lmr -> nri "Update localization data"
        }

        dynamic * "FetchMetadataInterface" {
            title "Fetch metadata interface"
            epd -> lmr "Fetch metadata [FHIR]"
        }

        systemLandscape "Components" {
            title "Architecture"
            include *
            exclude "* -> *"
            exclude "adminPortal" "admin" "epd" "epdUser"
          }

        styles {
            element Element {
                stroke "#000000"

                properties {
                    plantuml.shadow true
                }
            }
            element "Healthcare Application" {
                background "#c5c5c5"
                color "#000000"
            }

            element "Generic Function Modules" {
                background "#ecc22e"
                color "#000000"
            }

            element "Reference Implementation" {
                background "#7785d1"
                color "#000000"
            }

            element "stub" {
                background "#77d1a6"
                color "#000000"
            }

            element "Bronsystemen" {
                background "#c5c5c5"
                color "#000000"
            }
        }
    }
}
