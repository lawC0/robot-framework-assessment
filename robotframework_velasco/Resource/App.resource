*** Settings ***
Library    SeleniumLibrary
Library    ../Libraries/CommonLibrary.py
Variables    ../Variables/loginpage.py
Variables    ../Variables/common.py

*** Variables ***
${URL}    https://marmelab.com/react-admin-demo
@{sales_submenu}    Orders    Invoices
@{catalog_submenu}    Posters    Categories
@{customers_submenu}    Customers    Segements

&{MENU}    Sales=${sales_submenu}    Catalog=${catalog_submenu}    Customers=${customers_submenu}
@{USERS}

*** Keywords ***
Launch Browser
    [Arguments]    ${url}=${URL}     
    Open Browser    ${url}   chrome    options=add_argument("--start-maximized")

Login User
    [Arguments]    ${username}    ${password}
    Wait Until Element Is Visible    ${login_txt_username}
    Input Text    ${login_txt_username}    ${username}
    Input Text    ${login_txt_password}    ${password}
    Capture Page Screenshot
    Click Button    ${login_btn_submit}
    Wait Until Element Is Visible    ${main_content}

Get Parent Menu
    [Arguments]    ${sub_menu}
    FOR    ${key}    IN    @{MENU.keys()}
        Return From Keyword If    "${sub_menu}" in ${MENU['${key}']}    //li[descendant::p[text()="${key}"]]    
    END
    RETURN    ${None}


Navigate
    [Arguments]    ${sub_menu}    
    ${sub_menu_loc}    Set Variable    //a[descendant::p[text()="${sub_menu}"]]   

    ${status}    Run Keyword And Return Status    Element Should Be Visible    ${sub_menu_loc} 
    IF    not ${status} 
        ${parent_menu}    Get Parent Menu    ${sub_menu}    
        Click Element    ${parent_menu}
        Wait Until Element Is Visible     ${sub_menu_loc} 
    END
        
    Click Element   ${sub_menu_loc} 
    Wait Until Element Is Visible    //h6[//span[contains(text(),"${sub_menu}")]]
    Run Keyword If    "${sub_menu}"=="Customers"
    ...    Sleep    2s


Clean Text
    [Arguments]    ${text}
    IF    "\\n" in """${text}"""
        ${text}    Evaluate    """${text}""".replace("\\n","")[1:]
        
    END
    Return From Keyword    ${text}


Clear Text Field
    [Arguments]    ${locator}
    Press Keys    ${locator}    CTRL+a    BACKSPACE