*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot orders website
    ${orders}=  Get orders
    Start an order
    FOR  ${order}  IN  @{orders}
        Close the "Constitional Rights" modal
        Fill in the form  ${order}
        Preview the robot
        Submit the order
        Verify order was submitted succesfully
        ${screenshot}=    Take a screenshot of the robot    ${order}[Order number]
        # ${pdf}=    Store the receipt as a PDF file    ${order}[Order number]
        ${pdf}=    Store the receipt as a PDF file with preview    ${order}[Order number]
        # Note there is a logic error here in that on the last one it will go to ordering another robot.
        # Not resolving this now :) 
        Order another robot
    END
    Archive Output PDFs
    [Teardown]  Close RobotSpareBin Browser


*** Keywords ***
Open the robot orders website
    Open Available Browser   https://robotsparebinindustries.com/
    
Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${table}=  Read table from CSV    orders.csv    header=${True}
    [Return]  ${table}

Start an order
    Click Link    \#/robot-order

Close the "Constitional Rights" modal
    Run Keyword And Ignore Error  Click Button    Yep

Fill in the form
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    css:form div.form-group:nth-of-type(3) input    ${order}[Legs]
    Input Text    address    ${order}[Address]

Preview the robot
    Click Button    Preview

Submit the order
    Click Button    Order

Verify order was submitted succesfully
    [Documentation]     As this is just an exercise and not some production software that will
    ...                 keep me up at night, call me at all hours, put my job at risk, etc. I
    ...                 will very narrowly verify the app is ready. For the same reasons I may
    ...                 somewhere in this solution handle timing issues in an non optimal nor
    ...                 ideal way. (Yes, that means I might even use Sleeps). For anyone
    ...                 reviewing this please keep this in mind. This is just an exercise ... :)

    # ToDo: Probably better to check for receipt instead
    ${failed}=   Does Page Contain Element    css:div.alert-danger
    IF  ${failed}
        Sleep  0.5 seconds
        # Noted: There is a possible coding logic error here in that if the alert takes time to
        # appear then we may try sumitting without checking. There reverse would be try if
        # checking for receip and we expect the receipt to just be there. We might try a second
        # time to submit the order (which I suspect would cause an error because that button
        # will no longer be there). ... just some thoughts on timing issues ..
        Submit the order
        Verify order was submitted succesfully
    END

Order another robot
    # ToDo: Could also verify to make sure this button is there. Otherwise start another order
    # (using `Start an order` keyword)
    Click Button  Order another robot

Store the receipt as a PDF file
    [Arguments]  ${order_number}
    Wait Until Element Is Visible    id:receipt
    ${sales_results_html}=    Get Element Attribute    id:receipt    outerHTML
    # If I wanted to go fancy I would add back the css here :)
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}receipts${/}order\#${order_number}_receipt.pdf

Store the receipt as a PDF file with preview
    [Arguments]  ${order_number}
    Store the receipt as a PDF file    ${order_number}
    ${images}=  Create List    ${OUTPUT_DIR}${/}images${/}robot\#${order_number}.png
    Add Files To Pdf    ${images}
    ...  ${OUTPUT_DIR}${/}receipts${/}order\#${order_number}_receipt.pdf
    ...  append=${True}


Take a screenshot of the robot
    [Arguments]  ${order_number}
    # ToDo: Check and make sure the preview is shown. If not show it via `Preview the robot`
    # keyword.
    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}images${/}robot\#${order_number}.png

Archive Output PDFs
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${OUTPUT_DIR}${/}receipts.zip

Close RobotSpareBin Browser
    Close Browser
