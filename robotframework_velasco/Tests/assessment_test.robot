*** Settings ***
Resource    ../Resource/App.resource
Resource    ../Resource/Customers.resource

Suite Setup    Suite Init
Suite Teardown    Capture Page Screenshot



*** Test Cases ***
TEST-1
    [Documentation]    Task 1: Add First 5 Users
    Add Customers
    
TEST-2
    [Documentation]    Task 2: Update Existing Customers
    Update Customers 

TEST-3
    [Documentation]    Task 3: Log Table Data
    Display Customer Data

TEST-4
    [Documentation]    Task 4: Analyze User Spending
    Calculate and Display User Spending

*** Keywords ***
Suite Init
    Launch Browser    
    Login User    demo    demo
    ${users}    Get Users
    Set Suite Variable    ${USERS}    ${users}