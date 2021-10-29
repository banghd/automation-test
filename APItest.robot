*** Settings ***
Documentation       API Test using Ecommerce application
Test Timeout        1 minute
Library             RequestsLibrary
Library             Collections
Library             JsonValidator
Library             Process
Library             OperatingSystem
Suite Setup         Ping Server
*** Variables ***
#ENDPOINTS              ---
${BASE_URL}             https://devat-ecommerce.herokuapp.com
${USER}                 user
${TOKEN}
#Auth
${EMAIL}                cubangso1@gmail.com
${PASSWORD}             123456
#HEADERS                ---
${CONTENT_TYPE}         application/json
#PRODUCTS
${LIMIT}                4
*** Test Cases ***
LOGIN                  ---
Login without information
    [Tags]  Auth
    Login without infomation

Login with only username
    [Tags]  Auth
    Login with only username

Login with only password
    [Tags]   Auth
    Login with only password

Login with right credentials
    [Tags]     Auth
    Login with right credentials

#BUSINESS ACTION
Get list Products
    [Tags]  PRODUCTS
    Get list Products

Get List Products with limit
    [Tags]     PRODUCTS
    Get List Products with limit

Add to cart without login
    [Tags]  PRODUCTS
    Add to cart without login

Add to cart while login
    [Tags]  PRODUCTS
    Login with right credentials
    Add to cart while login
*** Keywords ***
Ping Server
    Create Session      ping        ${BASE_URL}     verify=True
    ${response}=        Get Request     ping        uri=
    Should Be Equal As Strings      ${response.status_code}     200
Login without infomation
    ${HEADERS}=         Create Dictionary
    ...                 Content-Type=${CONTENT_TYPE}
    ...                 User-Agent=RobotFramework
    Create Session      ping        ${BASE_URL}     verify=True
    ${response}=        Post Request     ping        uri=/user/login      headers=${HEADERS}
    Should Be Equal As Strings      ${response.status_code}     400
    log to console      ${response.json()}

Login with only username
    ${HEADERS}=         Create Dictionary
    ...                 Content-Type=${CONTENT_TYPE}
    ...                 User-Agent=RobotFramework
    Create Session      ping        ${BASE_URL}     verify=True
    ${response}=        Post Request     ping        uri=/user/login    data={"email":"${EMAIL}"}     headers=${HEADERS}
    log to console      ${response.json()}
    Should Be Equal As Strings      ${response.status_code}     400

Login with only password
    ${HEADERS}=         Create Dictionary
    ...                 Content-Type=${CONTENT_TYPE}
    ...                 User-Agent=RobotFramework
    Create Session      ping        ${BASE_URL}     verify=True
    ${response}=        Post Request     ping        uri=/user/login    data={"password":"${PASSWORD}"}     headers=${HEADERS}
    Should Be Equal As Strings      ${response.status_code}     400
    log to console      ${response.json()}

Login with right credentials
   ${HEADERS}=         Create Dictionary
    ...                 Content-Type=${CONTENT_TYPE}
    ...                 User-Agent=RobotFramework
    Create Session      ping        ${BASE_URL}     verify=True
    ${response}=        Post Request     ping        uri=/user/login    data={"email":"${EMAIL}","password":"${PASSWORD}"}     headers=${HEADERS}
    Should Be Equal As Strings      ${response.status_code}     200
    Element Should Exist    ${response.content}     .accesstoken
    ${TOKEN}=           Get From Dictionary     ${response.json()}      accesstoken
    Set Suite Variable      ${TOKEN}        ${TOKEN}

#Verify Product
Get list Products
    ${HEADERS}=          Create Dictionary
    ...                  Content-Type=${CONTENT_TYPE}
    ...                  Cookie=Authorization=${TOKEN}
    Create Session      ping        ${BASE_URL}     verify=True
    ${response}=        Get Request     ping    uri=/api/products  headers=${HEADERS}
    Element Should Exist    ${response.content}     .result
    Element Should Exist    ${response.content}     .products

Get List Products with limit
    ${HEADERS}=          Create Dictionary
    ...                  Content-Type=${CONTENT_TYPE}
    ...                  Cookie=Authorization=${TOKEN}
    Create Session      ping        ${BASE_URL}     verify=True
    ${response}=        Get Request     ping    uri=/api/products?limit=${LIMIT}  headers=${HEADERS}
    Element Should Exist    ${response.content}     .result
    Element Should Exist    ${response.content}     .products
    Should Be Equal As Integers  ${response.json()['result']}     ${LIMIT}

Get List Categories
    ${HEADERS}=          Create Dictionary
    ...                  Content-Type=${CONTENT_TYPE}
    ...                  Cookie=Authorization=${TOKEN}
    Create Session      ping        ${BASE_URL}     verify=True
    ${response}=        Get Request     ping    uri=/api/category  headers=${HEADERS}
    Should Be Equal As Strings      ${response.status_code}     200
    Element Should Exist    ${response.content}     .name

Add to cart without login
    ${HEADERS}=          Create Dictionary
    ...                  Content-Type=${CONTENT_TYPE}
    Create Session      ping        ${BASE_URL}     verify=True
    ${response}=        Patch Request     ping    uri=/user/addcart  headers=${HEADERS}
   Should Be Equal As Strings      ${response.status_code}     400

Add to cart while login
    ${HEADERS}=          Create Dictionary
    ...                  Content-Type=${CONTENT_TYPE}
    ...                  Cookie=Authorization=${TOKEN}
    log       ${TOKEN}
    Create Session      ping        ${BASE_URL}     verify=True
    ${response}=        Patch Request     ping    uri=/user/addcart  headers=${HEADERS}  data=[]
    Should Be Equal As Strings      ${response.status_code}     400