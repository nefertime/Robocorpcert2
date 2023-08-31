*** Settings ***
Library     Collections
Library     RPA.Excel.Files
Library     RPA.Robocorp.WorkItems
Library     RPA.Tables
Library    RPA.HTTP
Library    RPA.Browser.Selenium
Library    OperatingSystem
Library    RPA.Desktop
Library    RPA.Archive

*** Variables ***

*** Tasks ***
Produce items
    [Documentation]
    ...    Get source CSV file from work item.
    ...    Read rows from CSV.
    ...    Creates output work items per row.
    ...    
    Download    https://robotsparebinindustries.com/orders.csv
    ${table}=    Read Table From CSV   orders.csv    
    Open Browser    https://robotsparebinindustries.com/#/robot-order
    Sleep    1
    Create Directory    output

    FOR    ${row}    IN    @{table}
        ${variables}=    Create Dictionary
        
        ...    Order number=${row}[Order number]
        ...    Head=${row}[Head]
        ...    Body=${row}[Body]
        ...    Legs=${row}[Legs]
        ...    Address=${row}[Address]
        ${Order number}    Set Variable    ${variables}[Order number]
        ${Head}    Set Variable    ${variables}[Head]
        ${Body}    Set Variable    ${variables}[Body]
        ${Legs}    Set Variable    ${variables}[Legs]
        ${Address}    Set Variable    ${variables}[Address]
        
        # Click ok to remove coockie
        Click Element    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
        Click Element    //*[@id="head"]

        # Conditionally click based on the value of "Head"
        ${Head_Value}=    Set Variable If    '${Head}' == '1'    2
        ...    '${Head}' == '2'    3
        ...    '${Head}' == '3'    4
        ...    '${Head}' == '4'    5
        ...    '${Head}' == '5'    6
        ...    '${Head}' == '6'    7

        Run Keyword If    '${Head_Value}' != ''    Click Element    xpath=//*[@id="head"]/option[${Head_Value}]
        Sleep    0.2
        # Conditionally click based on the value of "Body"
        ${Body_Value}=    Set Variable If    '${Body}' == '1'    1
        ...    '${Body}' == '2'    2
        ...    '${Body}' == '3'    3
        ...    '${Body}' == '4'    4
        ...    '${Body}' == '5'    5
        ...    '${Body}' == '6'    6
        Run Keyword If    '${Body_Value}' != ''    Click Element    xpath=//*[@id="id-body-${Body_Value}"]
        Input Text    css:input[placeholder="Enter the part number for the legs"]    ${Legs}
        input Text    //*[@id="address"]   ${Address}
        Click Element    //*[@id="order"]

        Sleep    0.2
        ${order_another_visible}    Run Keyword And Return Status    Element Should Be Visible    //*[@id="order-another"]
        Run Keyword If    ${order_another_visible}    Screenshot    //*[@id="receipt"]    output/screenshot_${Order number}.png
        ...     ELSE    Reload Page
        Run Keyword If    ${order_another_visible}    Convert PNG to PDF    output/screenshot_${Order number}.png
        Run Keyword If    ${order_another_visible}    Click Element    //*[@id="order-another"]
        Continue For Loop
        Create Output Work Item

        ...    variables=${variables}
        ...    save=True
    END
    Archive Folder With Zip    output    output.zip
    Empty Directory    output
    Remove Directory    output
    Release Input Work Item    DONE
    Close Browser

*** Keywords ***
Convert PNG to PDF
    [Arguments]    ${png_file}
    ${pdf_file}    Set Variable    ${png_file[:-4]}.pdf

    # Log the paths for debugging
    Log    PNG File: ${png_file}
    Log    PDF File: ${pdf_file}

    # Specify the full path to the convert command
    ${convert_command}    Set Variable    output    # Replace with the actual path

    Run    ${convert_command} ${png_file} ${pdf_file}