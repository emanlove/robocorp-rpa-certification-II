*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Tables


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot orders website
    ${orders}=  Get orders
    FOR  ${order}  IN  @{orders}
         Start an order
         Close the "Constitional Rights" modal
         Fill the form

    END
    Archive Output PDFs
    [Teardown]  Close RobotSpareBin Browser


*** Keywords ***
Open the robot orders website
    Open Available Browser   https://robotsparebinindustries.com/#/robot-order
    
Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${table}=  Read table from CSV    ${OUTPUT_DIR}${/}orders.csv    header=${True}
    [Return]  ${table}

Start an order
    Pass Execution    ToDo: Start an order

Archive Output PDFs
    Pass Execution    ToDo: Archive Output PDFs

Close RobotSpareBin Browser
    Pass Execution    ToDo: Close RobotSpareBin Browser