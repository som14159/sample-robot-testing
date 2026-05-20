*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Variables ***
${BASE_URL}    %{BASE_URL}

*** Test Cases ***
OPTIONS Should Return CORS Headers
    ${resp}=    OPTIONS    ${BASE_URL}
    Should Be Equal As Integers    ${resp.status_code}    204
    Dictionary Should Contain Item    ${resp.headers}    Access-Control-Allow-Origin    *
    Dictionary Should Contain Item    ${resp.headers}    Access-Control-Allow-Methods    GET, POST, DELETE

GET Should Return Notes List
    ${resp}=    GET    ${BASE_URL}
    Should Be Equal As Integers    ${resp.status_code}    200

GET Should Include Existing Seeded Notes
    ${resp}=    GET    ${BASE_URL}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${notes}=    Set Variable    ${resp.json()}
    ${names}=    Evaluate    [note.get('name') for note in $notes]
    List Should Contain Value    ${names}    Housewarming Tasks
    List Should Contain Value    ${names}    bulk-note-0
    List Should Contain Value    ${names}    bulk-note-9
    List Should Contain Value    ${names}    test-note

GET Response Should Be JSON List
    ${resp}=    GET    ${BASE_URL}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${notes}=    Set Variable    ${resp.json()}
    ${is_list}=    Evaluate    isinstance($notes, list)
    Should Be True    ${is_list}

GET Each Note Should Have Name Field
    ${resp}=    GET    ${BASE_URL}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${notes}=    Set Variable    ${resp.json()}
    FOR    ${note}    IN    @{notes}
        Dictionary Should Contain Key    ${note}    name
    END

POST Without Name Should Return 400
    ${body}=    Create Dictionary    foo=bar
    ${resp}=    POST    ${BASE_URL}    json=${body}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    400

POST With Empty Name Should Return 400
    ${body}=    Create Dictionary    name=    content=hello
    ${resp}=    POST    ${BASE_URL}    json=${body}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    400

POST With Name Should Return 201
    ${body}=    Create Dictionary    name=test-note    content=hello
    ${resp}=    POST    ${BASE_URL}    json=${body}
    Should Be Equal As Integers    ${resp.status_code}    201

POST Then GET Should Include Created Note
    ${unique}=    Evaluate    'robot-note-' + __import__('uuid').uuid4().hex[:8]
    ${body}=    Create Dictionary    name=${unique}    content=hello
    ${create}=    POST    ${BASE_URL}    json=${body}    expected_status=any
    Should Be True    ${create.status_code} == 201 or ${create.status_code} == 409
    ${resp}=    GET    ${BASE_URL}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${notes}=    Set Variable    ${resp.json()}
    ${names}=    Evaluate    [note.get('name') for note in $notes]
    List Should Contain Value    ${names}    ${unique}

DELETE Without Name Should Return 400
    ${resp}=    DELETE    ${BASE_URL}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    400

DELETE Nonexistent Note Should Return 404
    ${params}=    Create Dictionary    name=does-not-exist-robot
    ${resp}=    DELETE    ${BASE_URL}    params=${params}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    404

DELETE Existing Note Should Return 200 Or 404
    ${params}=    Create Dictionary    name=test-note
    ${resp}=    DELETE    ${BASE_URL}    params=${params}    expected_status=any
    Should Be True    ${resp.status_code} == 200 or ${resp.status_code} == 404
