#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(keras)
library(R.filesets)
library(ggplot2)
library(dplyr)
library(idx2r)
library(chron)
library(httr)
library(shinydashboard)
library(shiny)
options(shiny.maxRequestSize=10000*1024^2)
options(shiny.port = 3838)

class_array_enc=c('Chat','Email','File','P2p','Streaming','Voip','Vpn_Chat','Vpn_Email','Vpn_File','Vpn_P2p','Vpn_Streaming','Vpn_Voip')


class_array=c('BitTorrent','Facetime','FTP','Gmail','MySQL','Outlook','Skype','SMB','Weibo','WorldOfWarcraft','Cridex','Geodo','Htbot','Miuref','Neris','Nsis-ay','Shifu','Tinba','Virut','Zeus')

test.env <- new.env()



predict_class_of_unenc_packets = function(idx_file){
    
    #idx_fil = file(idx_file,'rb')
    dict_resp = POST(url="http://localhost:8888/split", encoding='raw', body=idx_file)
    dict_resp_content = content(dict_resp, type = "application/json")
    
    
    
    idx_file = read_idx(dict_resp_content$path)
    
    temp_idx_file = as.double(idx_file)
    
    dim(temp_idx_file) = c(nrow(idx_file), 28, 28, 1)
    
    
    #model_unc_enc=load_model_hdf5(file.choose())
    
    model_un_enc = load_model_hdf5(paste(getwd(),'models','model_un_encryp_10.h5', sep = '/'))
    pred = model_un_enc %>%
        predict_classes(temp_idx_file)
    ar = pred
    for(i in 1:length(pred)){
        ar[i] = class_array[pred[i] ]
    }
    df = as.data.frame(ar)
    df$seq = seq(1:length(ar))
    colnames(df) = c('Packet data Type', 'Sequence')
    return(df)
}


predict_class_of_enc_packets = function(idx_file){
    
    idx_fil = read_idx(idx_file)
    
    temp_idx_file = as.double(idx_fil)
    
    dim(temp_idx_file) = c(nrow(idx_fil), 28, 28, 1)
    
    model_un_enc = load_model_hdf5(paste(getwd(),'models','model_encryp_30.h5', sep = '/'))
    pred = model_un_enc %>%
        predict_classes(temp_idx_file)
    ar = pred
    for(i in 1:length(pred)){
        ar[i] = class_array_enc[pred[i] ]
    }
    df = as.data.frame(ar)
    df$seq = seq(1:length(ar))
    return(df)
}




get_csv = function(serv_log, sdate, stime, edate, etime, ip){
    
    
    serv_log$Spec = serv_log$V4
    
    serv_log$V3= format(as.POSIXct(serv_log$V4, format="[%d/%b/%Y:%H:%M:%S"),"%Y:%m:%d")
    #serv_log$Time = as.POSIXct(serv_log$Time, format = "%H:%M:%S")
    #serv_log$Time = chron(times=serv_log$Time)
    serv_log$V4 = (format(as.POSIXct(serv_log$V4, format="[%d/%b/%Y:%H:%M:%S"),"%H:%M:%S"))
    #serv_log$V4 =  strptime(serv_log$V4 , format('[%d/%b/%Y:%H:%M:%S'))
    serv_log$V1 = as.factor(serv_log$V1)
    serv_log$Day = format(serv_log$Date, " %A")
    
    colnames(serv_log)[4] = "Time"
    colnames(serv_log)[3] = "Date"
    colnames(serv_log)[1] = "IP"
    colnames(serv_log)[9] = 'URL'
    colnames(serv_log)[6] = "Request"
    colnames(serv_log)[8] = "Bytes"
    colnames(serv_log)[7] = "Response_code"
    colnames(serv_log)[10] = "User Agent"
    
    
    #serv_log$Spec = strptime(serv_log$Spec , format('[%d/%b/%Y:%H:%M:%S'))
    
    serv_log$Request = as.character(serv_log$Request)
    serv_log$IP = as.character(serv_log$IP)
    serv_log$V2=NULL
    serv_log$Day=NULL
    serv_log$V5=NULL
    print('Hello')
    if(!(missing(ip) || ip =="") ){
        if(ip[1]=='!')
            serv_log = serv_log[!which(serv_log$IP==ip[-1]),]
        else
            serv_log = serv_log[which(serv_log$IP==ip),]
    }
    if(!(missing(sdate) || sdate==""))
    {
        serv_log = serv_log[which(serv_log$Date>=sdate),]
        if(!(missing(stime) || stime==""))
        {
            serv_log = serv_log[which(serv_log$Time>=stime),]
        }
    }
    if(!(missing(edate) || edate==""))
    {
        serv_log = serv_log[which(serv_log$Date<=edate),]
        if(!(missing(etime) || etime==""))
        {
            serv_log = serv_log[which(serv_log$Date<=etime),]
        }
    }
    return(serv_log)
    
}
#GRAPH For Traffic to the Site

#Based on Days
get_graph_for_Days = function(serv_log){
    temp = rep('T',nrow(serv_log))
    reqs=as.data.frame(table(serv_log$Date,temp))
    return(ggplot(data = reqs, aes(x=Var1, y = Freq, group=temp)) +
               geom_line() + xlab('Date') + ylab('Requests')+geom_point())
    
}


get_respcode_graph = function(x){
    w = as.data.frame(table(x$Response_code))
    
    return(
        ggplot(w, aes(x=Var1, y=Freq))+
            geom_bar(stat = 'identity')+
            xlab('Response Codes')+
            ylab('No. of Requests')
    )
    
}

#Hack Attempt
get_pattern_data = function(array_of_url, serv_log){
    attempt = NA
    for (i in array_of_url){
        if(is.na(attempt)){
            attempt = subset(serv_log, grepl(i, Request))
        }
        else{
            attempt = rbind(attempt, subset(serv_log, grepl(array_of_url[i], Request)))
        }
    }
    return(attempt)
    
}


# Define server logic required to draw a histogram
server <- function(input, output) {
    
    
    
    
    output$plot1 <- renderTable({
        
        #data <- histdata[seq_len(input$bins)]
        if(is.null(input$file_csv)){
            assign('global_data',NA, envir = test.env)
            data1 <<- NA
            return(iris)
        }
        else{
            data = tryCatch(read.table(input$file_csv$datapath, sep = " ", header = F, fill = T))
            data1 <<- get_csv(data,input$`Start Date`, input$`Start Time`, input$`End Date`, input$`End Time`, input$IP)
            assign('global_data',data1, envir = test.env)
            data1
            
            if(is.null(input$Query))
                return(
                    print('Hello')
                )
            else{
                
                x = get_pattern_data(c(input$Query), data1)
                
                assign('patter_data',x,envir = test.env)
            }
            #print(get('global_data', envir = test.env))
        }
        
        
        
    })
    
    output$plot <- renderPlot({
        
        if(is.null(input$file_csv))
        {
            plot(c(1,2),c(3,5))
        }
        else{
            data = tryCatch(read.table(input$file_csv$datapath, sep = " ", header = F, fill = T))
            data1 <<- get_csv(data,input$`Start Date`, input$`Start Time`, input$`End Date`, input$`End Time`, input$IP)
            assign('global_data',data1, envir = test.env)
            data1
            
            
            if(is.null(input$Query))
                return(
                    print('Hello')
                )
            else{
                
                x = get_pattern_data(c(input$Query), data1)
                return(get_graph_for_Days(x))
                assign('patter_data',x,envir = test.env)
            }
            
            
            get_graph_for_Days(data1)
        }
        
        
    })
    
    output$`IP Table` <- renderPlot({
        
        
        if(is.null(input$file_csv))
        {
            plot(c(1,2),c(3,5))
        }
        else{
            data = tryCatch(read.table(input$file_csv$datapath, sep = " ", header = F, fill = T))
            data1 <<- get_csv(data,input$`Start Date`, input$`Start Time`, input$`End Date`, input$`End Time`, input$IP)
            assign('global_data',data1, envir = test.env)
            data1
            
            
            if(is.null(input$Query))
                return(
                    print('Hello')
                )
            else{
                
                x = get_pattern_data(c(input$Query), data1)
                return(get_respcode_graph(x))
                assign('patter_data',x,envir = test.env)
            }
            
            
            return(get_graph_for_Days(data1))
        }
        
        
        
    })
    
    output$plotunc <- renderTable({
        if(is.null(input$file_idx_un_enc))
        {
            return(iris[1:10,])
        }
        else
        {
            return(
                predict_class_of_unenc_packets(input$file_idx_un_enc$datapath)
            )
        }
    })
    
    
    output$plotenc <- renderTable({
        if(is.null(input$file_idx_enc))
        {
            return(iris[1:10,])
        }
        else
        {
            return(
                predict_class_of_enc_packets(input$file_idx_enc$datapath)
            )
        }
    })
    
    
}


ui <- dashboardPage(
    dashboardHeader(title = 'Forensics Dashboard'),
    dashboardSidebar(
        sidebarMenu(
            menuItem("LOG_", tabName = "LOG", icon = icon("dashboard")),
            menuItem("NETWORK_", tabName = "NETWORK", icon = icon("th"))
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


shinyApp(ui = ui, server = server)

