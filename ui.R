#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shinydashboard)
library(shiny)

# Define UI for application that draws a histogram
shinyUI(
    dashboardPage(
        dashboardHeader(title = 'Forensics Dashboard'),
        dashboardSidebar(
            sidebarMenu(
                menuItem("LOG", tabName = "LOG", icon = icon("dashboard")),
                menuItem("NETWORK", tabName = "NETWORK", icon = icon("th"))
            )
        ),
        dashboardBody(
            tabItems(tabItem(
                tabName = "LOG",
                fluidRow(
                    box(solidHeader = T, collapsible = T ,status = "primary",title = 'Logs in Use',column(tableOutput('plot1'),collapsed = T, width = 12,style= "height:500px; overflow-y: scroll;overflow-x: scroll;")),
                    box(
                        fileInput("file_csv", buttonLabel = "browse",label = "Enter a log file")
                    ),
                    box(textInput('Query',label = "query"),),
                    box(textInput('Start Date',label = "sdate"),width = 2),
                    box(textInput('Start Time',label = "stime"),width = 2),
                    box(textInput('End Date',label = "edate"), width = 2),
                    box(textInput('End Time',label = "etime"),width = 2),
                    box(textInput('IP',label = "IP"),width = 5),
                    box(plotOutput('IP Table'), collapsible = T, title = 'Types of Requests Made'),
                    box(plotOutput('plot'), collapsible = T, title = 'No. Of Requests based on the Above "Logs in Use" table')
                )    ),
                tabItem(
                    tabName = "NETWORK",
                    fluidPage(
                        box(
                            fileInput("file_idx_un_enc", buttonLabel = "browse",label = "Enter a .PCAP file of Unencrypted Traffic")
                        ),box(
                            fileInput("file_idx_enc", buttonLabel = "browse",label = "Enter a .PCAP file of Encrypted Traffic")
                        ),
                        box(solidHeader = T, collapsible = T ,status = "primary",title = 'Unencrypted Packet',column(tableOutput('plotunc'),collapsed = T, width = 12,style= "height:500px; overflow-y: scroll;overflow-x: scroll;")),
                        box(solidHeader = T, collapsible = T ,status = "primary",title = 'Encrypted Packet',column(tableOutput('plotenc'),collapsed = T, width = 12,style= "height:500px; overflow-y: scroll;overflow-x: scroll;"))
                    )
                    
                )
            ) )
    )
)



