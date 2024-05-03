# ZModules

## Disclaimer

The zModules project is currently under development. The information in this repository is
subject to change. The information in this repository describes the current state of the
various applications.

## Introduction

The zModules project is a collection of applications that have the purpose to improve the
data exchange between healthcare providers. This project is the technical implementation of
the various components of the 'Generieke Functies, lokalisatie en addressering' project of the
Ministry of Health, Welfare and Sport of the Dutch goverment.

See the table below for an overview of the currently identified components.

| Project name                                              | Technical component name                        |
|-----------------------------------------------------------|-------------------------------------------------|
| GF Localisatie, module Lokalisatie Metadataregister (LMR) | [Metadata Register](#metadata-register)         |
| Module Kwalificatieregister                               |                                                 |
| GF Lokalisatie, module Lokalisatie register service (LRS) | [Localisation Register](#localisation-register) |
| GF Lokalisatie, module nationale Verwijsindex (NVI)       | [Timeline Service](#timeline-service)           |
| GF Lokalisatie, module polymorfe pseudonimisering         | [Pseudonym Service](#pseudonym-service)         |
| Module Logging                                            |                                                 |
| GF Addressering                                           | [Addressing Register](#addressing-register)     |

## Architecture

In this project a Timeline Service is exposed for convenience. It should also be possible
for healthcare applications to connect directly to the underlying services.
When step 5 is finished, a healthcare application can request the actual data using the
metadata that is fetched in step 5.

![alt text](assets/system-components.png "system")

## Components

### Timeline Service

The Timeline Service is the aggregate service of the underlying services.

Details about documentation and implementation can be found at the
[Timeline Service repository](https://github.com/minvws/nl-irealisatie-zmodules-timeline-service)

### Pseudonym Service

The Pseudonym Service is responsible for the pseudonymisation of the BSN. Preferably the
BSNk service would be used instead of this service. But because the BSNk is still under
development, the Pseudonym Service is used.

Details about documentation and implementation can be found at the
[Pseudonym Service repository](https://github.com/minvws/nl-irealisatie-zmodules-pseudonym-service)

### Localisation Register

The Localisation Register is responsible for the localisation of the Health Data. The Localisation
Register contains the register that associates Health Provider with pseudonym and data domain.

Details about documentation and implementation can be found at the
[Localisation Register repository](https://github.com/minvws/nl-irealisatie-zmodules-localisation-register)

### Addressing Register

The Addressing Register holds the information about the various Health Data endpoints that are available
for fetching the metadata. The information of the Addressing Register should be enough for the Timeline
Service or the Health application to fetch the actual metadata.

Details about documentation and implementation can be found at the
[Addressing Register repository](https://github.com/minvws/nl-irealisatie-zmodules-addressing-register)

### Metadata Register

The Metadata Register is an addressable register that contains metadata of
all the pseudonyms that it is responsible for. There are multiple metadata registers divided over
the health landscape. In the end, all health data should have corresponding metadata available on one of the available
metadata registers. The Metadata Register endpoints should be described in the Addressing Register.
The Localisation Register should contain entries for all the metadata in the Metadata Register.

The [Metadata Register repository](https://github.com/minvws/nl-irealisatie-zmodules-metadata-register)
is an example implementation of a Metadata Register. Details about the documentation and implementation
can be found at the repository.

## Development

How to setup the applications to run locally is described at the repositories itself.

| Service      | Exposed http url        | Repository link                                                           |
|--------------|-------------------------|---------------------------------------------------------------------------|
| Localisatie  | <http://localhost:8501> | <https://github.com/minvws/nl-irealisatie-zmodules-localisation-register> |
| Addressing   | <http://localhost:8502> | <https://github.com/minvws/nl-irealisatie-zmodules-addressing-register>   |
| Metadata     | <http://localhost:8503> | <https://github.com/minvws/nl-irealisatie-zmodules-metadata-register>     |
| Pseudonym    | <http://localhost:8504> | <https://github.com/minvws/nl-irealisatie-zmodules-pseudonym-service>     |
| Timeline     | <http://localhost:8505> | <https://github.com/minvws/nl-irealisatie-zmodules-timeline-service>      |
| Qualification | <http://localhost:8506> | <https://github.com/minvws/nl-irealisatie-zmodules-qualification-register> |
