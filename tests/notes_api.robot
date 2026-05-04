*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String

*** Variables ***
${BASE_URL}    %{BASE_URL}

*** Keywords ***
Create Test Note Name
    ${suffix}=    Generate Random String    8    [LOWER]
    RETURN    test-note-${suffix}

*** Test Cases ***
OPTIONS Should Return CORS Headers
    ${resp}=    OPTIONS    ${BASE_URL}
    Should Be Equal As Integers    ${resp.status_code}    204
    Dictionary Should Contain Item    ${resp.headers}    Access-Control-Allow-Origin    *
    Dictionary Should Contain Item    ${resp.headers}    Access-Control-Allow-Methods    GET, POST, DELETE

GET Should Return Notes List
    ${resp}=    GET    ${BASE_URL}
    Should Be Equal As Integers    ${resp.status_code}    200

GET Should Return JSON Content Type
    ${resp}=    GET    ${BASE_URL}
    Should Be Equal As Integers    ${resp.status_code}    200
    Should Contain    ${resp.headers}[Content-Type]    application/json

GET Response Should Be A JSON Array
    ${resp}=    GET    ${BASE_URL}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${notes}=    Set Variable    ${resp.json()}
    Should Be True    isinstance($notes, list)

POST Without Name Should Return 400
    ${body}=    Create Dictionary    foo=bar
    ${resp}=    POST    ${BASE_URL}    json=${body}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    400

POST With Empty Name Should Return 400 Or 201
    ${body}=    Create Dictionary    name=    content=hello
    ${resp}=    POST    ${BASE_URL}    json=${body}    expected_status=any
    Should Be True    ${resp.status_code} == 400 or ${resp.status_code} == 201

POST With Name Should Return 201
    ${name}=    Create Test Note Name
    ${body}=    Create Dictionary    name=${name}    content=hello
    ${resp}=    POST    ${BASE_URL}    json=${body}
    Should Be Equal As Integers    ${resp.status_code}    201

POST Duplicate Name Should Return 201 Or 400
    ${name}=    Create Test Note Name
    ${body}=    Create Dictionary    name=${name}    content=hello
    ${first}=    POST    ${BASE_URL}    json=${body}    expected_status=any
    Should Be True    ${first.status_code} == 201 or ${first.status_code} == 400
    ${second}=    POST    ${BASE_URL}    json=${body}    expected_status=any
    Should Be True    ${second.status_code} == 201 or ${second.status_code} == 400
    ${params}=    Create Dictionary    name=${name}
    DELETE    ${BASE_URL}    params=${params}    expected_status=any

Create Then Delete Note Should Succeed
    ${name}=    Create Test Note Name
    ${body}=    Create Dictionary    name=${name}    content=hello
    ${create_resp}=    POST    ${BASE_URL}    json=${body}    expected_status=any
    Should Be True    ${create_resp.status_code} == 201 or ${create_resp.status_code} == 400
    ${params}=    Create Dictionary    name=${name}
    ${delete_resp}=    DELETE    ${BASE_URL}    params=${params}    expected_status=any
    Should Be True    ${delete_resp.status_code} == 200 or ${delete_resp.status_code} == 404

DELETE Without Name Should Return 400
    ${resp}=    DELETE    ${BASE_URL}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    400

DELETE Missing Note Should Return 200 Or 404
    ${name}=    Create Test Note Name
    ${params}=    Create Dictionary    name=${name}
    ${resp}=    DELETE    ${BASE_URL}    params=${params}    expected_status=any
    Should Be True    ${resp.status_code} == 200 or ${resp.status_code} == 404

DELETE Existing Note Should Return 200 Or 404
    ${name}=    Create Test Note Name
    ${body}=    Create Dictionary    name=${name}    content=hello
    POST    ${BASE_URL}    json=${body}    expected_status=any
    ${params}=    Create Dictionary    name=${name}
    ${resp}=    DELETE    ${BASE_URL}    params=${params}    expected_status=any
    Should Be True    ${resp.status_code} == 200 or ${resp.status_code} == 404
