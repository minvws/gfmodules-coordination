import hashlib
import json
import random
import sys
from typing import Any

from faker import Faker
import requests

_CONFIG = None

fake = Faker('nl_NL')

def config() -> dict[str, Any]:
    global _CONFIG

    if _CONFIG is None:
        with open("config.json") as f:
            _CONFIG = json.load(f)

    return _CONFIG


def do_sanity_check() -> bool:
    """
    Quick check to see if the endpoints are reachable
    """
    for endpoint in ['pseudonym', 'localisation', 'addressing']:
        try:
            r = requests.get(config()['endpoints'][endpoint]['url'])
            print(f"✅ Sanity check: Request to {endpoint} {config()['endpoints'][endpoint]['url']} returned {r.status_code}")
        except requests.exceptions.RequestException as e:
            print(f"⚠️ Sanity check: Request to {endpoint} {config()['endpoints'][endpoint]['url']} failed: {e}")
            return False
    return True


def create_metadata(resource_type: str, resource: dict, pseudonym: str, metadata_url: str) -> bool:
    try:
        url = f"{metadata_url}/resource/{resource_type}/{resource['id']}?pseudonym={pseudonym}"
        r = requests.put(url, json=resource)
        if r.status_code >= 400:
            print(f"⚠️ Request to {metadata_url} failed: {r.status_code}")
            print(f"⚠️ {r.json()}")
            return False

        return True
    except requests.exceptions.RequestException as e:
        print(f"⚠️ Request to {metadata_url} failed: {e}")
        return False


def create_pseudonym(bsn: str, provider_id: str) -> str|bool:
    try:
        r = requests.post(config()['endpoints']['pseudonym']['url'] + '/register', json={'bsn_hash': hash_bsn(bsn), 'provider_id': provider_id})
        if r.status_code >= 400:
            print(f"⚠️ Request to {config()['endpoints']['pseudonym']['url']} failed: {r.status_code}")
            return False
        return r.json()['pseudonym']
    except requests.exceptions.RequestException as e:
        print(f"⚠️ Request to {config()['endpoints']['pseudonym']['url']} failed: {e}")
        return False


def create_localisation(pseudonym: str, data_domain: str, ura_number: str) -> bool:
    try:
        r = requests.post(config()['endpoints']['localisation']['url'] + '/create',
                          json={'pseudonym': pseudonym, 'ura_number': ura_number, 'data_domain': data_domain})
        if r.status_code >= 400:
            print(f"⚠️ Request to {config()['endpoints']['localisation']['url']} failed: {r.status_code}")
            return False

        return True
    except requests.exceptions.RequestException as e:
        print(f"⚠️ Request to {config()['endpoints']['localisation']['url']} failed: {e}")
        return False


def create_address(ura_number: str, data_domain: str, metadata_url: str, request_type: str, params: list) -> bool:
    try:
        r = requests.post(config()['endpoints']['addressing']['url'] + '/metadata_endpoint/add-one', json={
            'ura_number': ura_number,
            'data_domain': data_domain,
            'endpoint': metadata_url,
            'request_type': request_type,
            'parameters': params,
        })
        if r.status_code >= 400:
            print(f"⚠️ Request to {config()['endpoints']['addressing']['url']} failed: {r.status_code}")
            print(f"⚠️ {r.json()}")
            return False

        return True
    except requests.exceptions.RequestException as e:
        print(f"⚠️ Request to {config()['endpoints']['addressing']['url']} failed: {e}")
        return False


def create_organisation():
    organization_names = [
        "Zorgvlinder Kliniek",
        "Geneeskracht Centrum",
        "Eerste Hulp Haven",
        "Vitaal Verband",
        "Herstelhart Polikliniek",
        "GezondheidsGolf",
        "BeterBorg Ziekenhuis",
        "Welzijnswerf",
        "ZorgZaam Station",
        "Pijnvrij Paradijs",
        "Levensloop Kliniek",
        "Snelle Zorg Expres",
        "Rustpunt Geneeskunde",
        "Vitaliteit Vesting",
        "Zorghaven",
        "Genezing aan Zee",
        "Herstel Hoek",
        "BalansBrug Kliniek",
        "Zorgstralen Centrum",
        "Heilzaam Hart",
        "Welzijnswater",
        "FitVeer Kliniek",
        "Herstel Harmonie",
        "VerzorgingsVeste",
        "Pijnverlichter Plek",
        "Groeigenoten",
        "BeterBloei",
        "ZorgZegen",
        "SpoedSpoor",
        "Geneeskrachtige Gaarde",
        "WelzijnsWereld",
        "Heelplein",
        "Zorg en Zekerheid Centrum",
        "Herstel Horizon",
        "GeneesGloed",
        "Zorgzaad Polikliniek",
        "Vitaliteit Vallei",
        "Geneeskrachtige Groei",
        "Spoed en Zorg Station",
        "Herstel Haard",
        "VrijAdem Kliniek",
        "BeterBaan Ziekenhuis",
        "Geneesgeest",
        "ZorgZuil",
        "Herstelhuis",
        "VitaalVenster",
        "Zorgfluisteraar",
        "Heilzaam Heelal",
        "Genezingstuin",
        "Zorgzame Zeehaven"
    ]

    uuid = fake.uuid4()

    return dict(
        id = uuid,
        name = random.choice(organization_names),
        type = [dict(
            coding = [dict(
                system = "http://terminology.hl7.org/CodeSystem/organization-type",
                code = "prov",
                display = "Healthcare Provider"
            )]
        )],
        active = True,
        identifier = [dict(
            system = "http://example.org/organization",
            value = uuid
        )],
        resourceType = "Organization",
    )


def is_valid_bsn(bsn: int) -> bool:
    bsn = str(bsn)
    if len(bsn) != 9:
        return False

    total = sum(int(digit) * (9 - idx) for idx, digit in enumerate(bsn[:-1])) - int(bsn[-1])
    return total % 11 == 0


def hash_bsn(bsn: str) -> str:
    h = hashlib.sha256()
    h.update(bsn.encode())
    return h.hexdigest()


def generate_first_names(gender: str) -> list[str]:
    number_of_names = random.choices(
        population=[1, 2, 3, 4],
        weights=[0.7, 0.2, 0.07, 0.03],  # Adjust weights according to your preference
        k=1
    )[0]

    if gender == "male":
        first_names = [fake.first_name_male() for _ in range(number_of_names)]
    elif gender == "female":
        first_names = [fake.first_name_female() for _ in range(number_of_names)]
    else:
        first_names = [fake.first_name_nonbinary() for _ in range(number_of_names)]

    return first_names


def generate_patient() -> dict[str, Any]:
    uuid = fake.uuid4()
    gender = fake.random_element(elements=("male", "female", "other", "unknown"))

    return dict(
        id = uuid,
        name = [dict(
            given = generate_first_names(gender),
            family = fake.last_name(),
        )],
        active = True,
        gender = gender,
        address =  [dict(
            use = "home",
            city = fake.city(),
            line = [fake.street_address()],
            country = "Netherlands",
            postalCode = fake.postcode(),
        )],
        birthDate = fake.date_of_birth().isoformat(),
        identifier=[dict(
            value=uuid,
            system="http://example.org/patient"
        )],
        resourceType = "Patient",
        deceasedDateTime = fake.past_date().isoformat() if fake.random_number(digits=1) <= 2 else None,
    )


def generate_practitioner():
    uuid = fake.uuid4()
    gender = fake.random_element(elements=("male", "female", "other", "unknown"))

    return dict(
        id = uuid,
        active = True,
        address = [dict(
            use = 'work',
            line = [fake.street_address()],
            city = fake.city(),
            postalCode = fake.postcode(),
            country = 'Netherlands'
        )],
        birthDate = fake.date_of_birth().isoformat(),
        identifier = [dict(
            system = "http://example.org/practitioner",
            value = uuid
        )],
        resourceType = "Practitioner",
        name = [dict(
            family=fake.last_name(),
            given=generate_first_names(gender),
        )]
    )


def generate_imagingstudy(patient: dict[str, Any], organization: dict[str, Any], practitioner: dict[str, Any]) -> dict[str, Any]:
        uuid = fake.uuid4()

        patient_id = patient['id']
        org_id = organization['id']

        series_count = fake.random_number(digits=1) + 1

        study = dict(
            id=uuid,
            identifier=[dict(
                system="http://example.org/study",
                value=uuid
            )],
            resourceType="ImagingStudy",
            subject=dict(
                reference=f"Patient/{patient_id}",
                display=patient['name'][0]['given'][0] + ' ' + patient['name'][0]['family']
            ),
            status=fake.random_element(elements=("registered", "available", "cancelled", "entered-in-error")),
            started=fake.date_time_this_decade().isoformat(),
            numberOfSeries=series_count,
            series=[]
        )

        for idx in range(series_count):
            practitioner_id = practitioner['id']
            body_part = fake.random_element(
                elements=(("head", "Hoofd"), ("chest", "Borst"), ("abdomen", "Buikholte"), ("pelvis", "Bekken")))

            study['series'].append(dict(
                uid=fake.uuid4(),
                number=idx,
                started=fake.date_time_this_decade().isoformat(),
                modality=dict(
                    coding=[dict(
                        system="http://example.org/modality",
                        code=fake.random_element(elements=("CT", "MR", "US", "DX")),
                        display=fake.random_element(
                            elements=("Computed Tomography", "Magnetic Resonance", "Ultrasound", "Digital Radiography"))
                    )]
                ),
                performer=[
                    {
                        "actor": dict(
                            reference=f"Practitioner/{practitioner_id}",
                            type="Practitioner",
                            display=practitioner['name'][0]['given'][0] + " " + practitioner['name'][0]['family']
                        ),
                    },
                    {
                        "actor": dict(
                            reference=f"Organization/{org_id}",
                            type="Organization",
                            display=organization['name']
                        ),
                    }
                ],
                bodySite=dict(
                    concept=dict(
                        coding=[dict(
                            system="http://example.org/body-site",
                            code=body_part[0],
                            display=body_part[1]
                        )]
                    )
                ),
                instance=[dict(
                    uid=fake.uuid4(),
                    number=idx,
                    sopClass=dict(
                        system="http://example.org/sop-class",
                        code=fake.random_element(elements=("CT", "MR", "US", "DX")),
                        display=fake.random_element(
                            elements=("Computed Tomography", "Magnetic Resonance", "Ultrasound", "Digital Radiography"))
                    ),
                    title=fake.sentence(),
                )]
            ))

        return study


def run():
    if config()['uzi_mtls']['enabled']:
        print("⚠️ UZI MTLS enabled. We don't support this yet")
        sys.exit(1)

    if not do_sanity_check():
        print("⚠️ Sanity check failed")
        sys.exit(1)

    # Generate a list of organisations and a list of practitioners that work there. These will
    # be used to generate the imaging studies.
    organizations = {}
    practitioners = {}
    for i in range(1, random.randint(10, 30)):
        org = create_organisation()
        ura_number = str(random.randint(10000000, 99999999))
        organizations[ura_number] = org
        # print(f"Generating organisation {org['name']} with ID {ura_number}")

        # Create a number of practitioners for this organisation
        practitioners[ura_number] = []
        for j in range(1, random.randint(3, 10)):
            practitioner = generate_practitioner()
            practitioners[ura_number].append(practitioner)
            # print(f"  Generating practitioner {practitioner['name']} with ID {practitioner['id']} at organisation {org['name']}")


    # Iterate over the BSN range and for each valid BSN we encounter, register all data needed to retrieve
    # the image studies.
    for bsn in range(config()['bsn']['start'], config()['bsn']['end']):
        if not is_valid_bsn(bsn):
            continue

        # Generate patient info once. This is used for all imaging studies for this bsn
        patient = generate_patient()
        print(f"Generating patient {patient['name']} with BSN {bsn}")

        print("=========================================")
        pseudonym = create_pseudonym(str(bsn), config()['provider_id'])
        if pseudonym is False:
            print(f"⚠️ Failed to register pseudonym for BSN {bsn}")
            continue
        print(f"Registered pseudonym {pseudonym} for BSN {bsn}")

        # Patient has imaging studies at multiple organisations
        uras_done = []
        for i in range(1, random.randint(2, 10)):
            print("----------------------------------")
            # Get a random URA number, and make sure we don't use the same ura twice
            ura_number = random.choice(list(organizations.keys()))
            if ura_number in uras_done:
                continue
            uras_done.append(ura_number)

            # --------------------------------------
            print(f"Registering localisation for pseudonym {pseudonym}")

            data_domain = "beeldbank"
            res = create_localisation(pseudonym, data_domain, ura_number)
            if res is False:
                print(f"⚠️ Failed to register localisation for BSN {bsn}")
                continue
            print(f"Registered localisation for BSN {bsn} with URA number {ura_number} and data domain {data_domain}")

            if random.random() <= config()['unknown_metadata_probability']:
                metadata = dict(
                    url = config()['unknown_metadata_endpoint'],
                    endpoint = config()['unknown_metadata_endpoint']
                )
            else:
                l = list(config()['metadata_endpoints'].keys())
                metadata = config()['metadata_endpoints'][random.choice(l)]

            # --------------------------------------
            res = create_address(ura_number, data_domain, metadata['endpoint'], 'GET', [])
            if res is False:
                print(f"⚠️ Failed to register addressing for URA {ura_number}")
                continue
            print(f"Registered addressing for URA {ura_number} and data domain {data_domain} with metadata URL {metadata['url']}")

            # --------------------------------------
            # If we're using the unknown metadata endpoint, we don't need to store the metadata
            if metadata['url'] == config()['unknown_metadata_endpoint']:
                continue

            # Store patient and organisation in metadata
            create_metadata("Patient", patient, pseudonym, metadata['url'])
            create_metadata("Organization", organizations[ura_number], pseudonym, metadata['url'])

            for j in range(0, fake.random_int(0, 5)):
                # Find a random practitioner that works for this organisation
                practitioner = random.choice(practitioners[ura_number])
                create_metadata("Practitioner", practitioner, pseudonym, metadata['url'])

                # Generate an imaging study
                study = generate_imagingstudy(patient, organizations[ura_number], practitioner)
                print(f"Registering imaging study {study['id']} for BSN {bsn}")
                create_metadata("ImagingStudy", study, pseudonym, metadata['url'])

    print("🥳 Done")


if __name__ == "__main__":
    run()