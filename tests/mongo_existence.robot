*** Settings ***
Library    RequestsLibrary

*** Variables ***
${BASE_URL}    %{BASE_URL}

*** Test Cases ***
Mongo Seeded Notes Endpoint Should Return Existing Notes
    ${resp}=    GET    ${BASE_URL}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${notes}=    Set Variable    ${resp.json()}
    ${names}=    Evaluate    [note.get('name') for note in $notes]
    List Should Contain Value    ${names}    Housewarming Tasks
