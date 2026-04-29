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

POST Without Name Should Return 400
    ${body}=    Create Dictionary    foo=bar
    ${resp}=    POST    ${BASE_URL}    json=${body}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    400

POST With Name Should Return 201
    ${body}=    Create Dictionary    name=test-note    content=hello
    ${resp}=    POST    ${BASE_URL}    json=${body}
    Should Be Equal As Integers    ${resp.status_code}    201

DELETE Without Name Should Return 400
    ${resp}=    DELETE    ${BASE_URL}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    400

DELETE Existing Note Should Return 200 Or 404
    ${params}=    Create Dictionary    name=test-note
    ${resp}=    DELETE    ${BASE_URL}    params=${params}    expected_status=any
    ${valid_codes}=    Create List    200    404
    List Should Contain Value    ${valid_codes}    ${resp.status_code}
