*** Settings ***
Resource    ../Resource/App.resource
Library    SeleniumLibrary
Variables    ../Variables/customers.py

*** Keywords ***

Open Create Modal
    Click Element    //a[text()="Create"]
    Wait Until Element Is Visible    //h6[//span[contains(text(),"Create Customer")]]

Open Update Modal
    [Arguments]    ${user_row}
    Wait Until Element Is Visible    ((//tbody//tr)[${user_row}]//td)[2]
    Click Element    ((//tbody//tr)[${user_row}]//td)[2]
    Wait Until Element Is Visible    ${cust_txt_first_name}

Add A Customer
    [Arguments]    ${user}
    Navigate    Customers
    Open Create Modal

    ${locators}    Create List    ${cust_txt_first_name}     ${cust_txt_last_name}    ${cust_txt_email}    ${cust_txt_birthday}    ${cust_txt_address}    ${cust_txt_city}    ${cust_txt_state}    ${cust_txt_zip}    ${cust_txt_password}    ${cust_txt_confirm_password}
    ${input_values}    Create List    ${user['first_name']}    ${user['last_name']}    ${user['email']}    ${user['birthday']}    ${user['address']['street']} ${user['address']['suite']}    ${user['address']['city']}    ${user['address']['stateAbbr']}    ${user['address']['zipcode']}    ${user['password']}    ${user['password']}

    FOR    ${i}    ${locator}    IN ENUMERATE   @{locators} 
        Input Text    ${locator}    ${input_values[${i}]}
    END
    Click Button    ${cust_btn_save}

    Wait Until Element Is Visible    //div[text()="Customer created"]

Update A Customer
    [Arguments]    ${user}    ${user_row}
    Navigate    Customers
    Open Update Modal    ${user_row}
    ${locators}    Create List    ${cust_txt_first_name}     ${cust_txt_last_name}    ${cust_txt_email}    ${cust_txt_birthday}    ${cust_txt_address}    ${cust_txt_city}    ${cust_txt_state}    ${cust_txt_zip}    ${cust_txt_password}    ${cust_txt_confirm_password}
    ${input_values}    Create List    ${user['first_name']}    ${user['last_name']}    ${user['email']}    ${user['birthday']}    ${user['address']['street']} ${user['address']['suite']}    ${user['address']['city']}    ${user['address']['stateAbbr']}    ${user['address']['zipcode']}    ${user['password']}    ${user['password']}

    FOR    ${i}    ${locator}    IN ENUMERATE   @{locators} 
        IF    not '${locator}'=='${cust_txt_birthday}'
            Clear Text Field    ${locator}
        END

        Input Text    ${locator}    ${input_values[${i}]}
    END

    Click Button    ${cust_btn_save}

    Wait Until Element Is Visible    //div[text()="Customer updated"]

Format Birthday
    [Arguments]    ${date}
    ${formatted}    Evaluate    "/".join("${date}".split("-")[1:]+["${date}".split("-")[0]])
    RETURN    ${formatted}

Verify Customer Identity Details
    [Arguments]    ${user}
    ${user_row}    Get Customer Row    ${user}
    Wait Until Element Is Visible    ((//tbody//tr)[${user_row}]//td)[2]
    Click Element    ((//tbody//tr)[${user_row}]//td)[2]
    Wait Until Element Is Visible    ${cust_txt_first_name}

    ${locators}    Create List    ${cust_txt_first_name}     ${cust_txt_last_name}    ${cust_txt_email}    ${cust_txt_birthday}    ${cust_txt_address}    ${cust_txt_city}    ${cust_txt_state}    ${cust_txt_zip}    ${cust_txt_password}    ${cust_txt_confirm_password}
    ${expected_values}    Create List    ${user['first_name']}    ${user['last_name']}    ${user['email']}    ${user['birthday']}    ${user['address']['street']} ${user['address']['suite']}    ${user['address']['city']}    ${user['address']['stateAbbr']}    ${user['address']['zipcode']}    ${user['password']}    ${user['password']}

    FOR    ${i}    ${locator}    IN ENUMERATE   @{locators} 
        Mouse Over    ${locator}
        ${value_text}    Get Value    ${locator}

        IF    '${locator}'=='${cust_txt_birthday}'
            ${value_text}    Format Birthday    ${value_text}
        END
        
        Should Be Equal As Strings    ${expected_values[${i}]}    ${value_text}
        
    END
    
Get Customer Row
    [Arguments]    ${user}
    Navigate    Customers
    ${web_elems}    Get WebElements    //tbody//tr

    FOR    ${i}    ${element}    IN ENUMERATE    @{web_elems}
        ${name}    Get Text    ((//tbody//tr)[${i+1}]//td)[2]
        ${name}    Clean Text    ${name}
        Return From Keyword If    "${user['first_name']} ${user['last_name']}"=="${name}"   ${i+1}
    END

    RETURN    None

Verify If Customer Is Added In The Table
    [Arguments]    ${user}
    ${user_row}    Get Customer Row    ${user}
    Should Not Be Equal As Strings    None    ${user_row}
    
Display Customer Data
    Navigate    Customers
    ${web_elems}    Get WebElements    //tbody//tr
    ${headers}    Create List    Name:     Last Seen:     Orders:     Total spent: $    Latest purchase:     News.:     Segments: 
   
    FOR    ${i}    ${element}    IN ENUMERATE    @{web_elems}
        Log To Console    \n====== User ${i+1} ======
        FOR    ${j}    IN RANGE    ${7}
            ${user_data}    Get Data    ${i+1}    ${2+${j}}
            
            IF    "${user_data}"!='0' and "${user_data}"!='' and "${user_data}"!='0.00'
                Log To Console    ${headers[${j}]} ${user_data}
            END  
        END
    END

Get Data
    [Arguments]    ${row_num}    ${col_num}

    IF    ${col_num}==5
        ${user_data}    Get Text    ((//tbody//tr)[${row_num}]//td)[${col_num}]
        ${user_data}    Get Total Spent    ${user_data}
    ELSE IF     ${col_num}==7
        ${user_data}    Get Element Attribute    ((//tbody//tr)[${row_num}]//*[name()="svg"])[2]    aria-label
    ELSE IF     ${col_num}==8
        ${segments}    Get WebElements    ((//tbody//tr)[${row_num}]//td)[${col_num}]//span
        ${user_data}    Get Segments    ${segments}
    ELSE IF    ${col_num}!=7
        ${user_data}    Get Text    ((//tbody//tr)[${row_num}]//td)[${col_num}]
        ${user_data}    Clean Text    ${user_data}
    END
    
    RETURN    ${user_data}

Get Total Spent
    [Arguments]    ${total_spent}
    ${formatted}    Evaluate    "${total_spent}[1:]".replace(",","")
    RETURN    ${formatted}

Get Segments
    [Arguments]    ${segments}
    ${segments_length}    Get Length    ${segments}

        IF    ${segments_length} > 0
            ${user_data}    Set Variable   
            FOR    ${segment}    IN    @{segments}
                ${word}    Get Text    ${segment}                
                ${user_data}    Evaluate    "${user_data}" + ", " + "${word}"
            END

            RETURN    ${user_data}[2:]
        END
    RETURN    0

Display Total Spending
    [Arguments]    ${sum}
    ${sum}    Evaluate    f"{${sum}:,.2f}"
    Log To Console    \n========================
    Log To Console    Total Customer Spending: $${sum}
    Log To Console    ========================

Calculate and Display User Spending
    Navigate    Customers
    ${web_elems}    Get WebElements    //tbody//tr
    ${sum}    Set Variable    ${0}
    ${list_num}    Set Variable   ${1}
    Log To Console    \n
    FOR    ${i}    ${element}    IN ENUMERATE    @{web_elems}
        ${name}    Get Data    ${i+1}    ${2}
        ${total_spending}    Get Data    ${i+1}    ${5}
        IF    ${total_spending} > 0
            ${total_spending}    Evaluate    f"{${total_spending}:,.2f}"
            Log To Console    ${list_num}. ${name}: $${total_spending}
            ${list_num}    Evaluate    ${list_num} + ${1} 
        END
        ${sum}    Evaluate    ${sum} + ${total_spending}
    END
    Display Total Spending    ${sum}
    Validate Total Spending    ${sum}

Validate Total Spending
    [Arguments]    ${sum}
    ${sum}    Evaluate    f"{${sum}:,.2f}"
    IF    ${sum} < ${3500}
        Fail    FAIL: Total spending ($${sum}) is below minimum threshold ($3,500)
    END
        Pass Execution    PASS: Total spending ($${sum}) MEETS minimum threshold ($3,500)
    

Add Customers
    FOR    ${i}   IN RANGE    ${5}
        Add A Customer    ${USERS}[${i}]
        Verify If Customer Is Added In The Table    ${USERS}[${i}]
        Verify Customer Identity Details   ${USERS}[${i}]        
    END

Update Customers
    FOR    ${i}   IN RANGE    ${5}
        Update A Customer    ${USERS}[${5+${i}}]    ${6+${i}}
        Verify If Customer Is Added In The Table    ${USERS}[${5+${i}}]
        Verify Customer Identity Details   ${USERS}[${5+${i}}]
    END   