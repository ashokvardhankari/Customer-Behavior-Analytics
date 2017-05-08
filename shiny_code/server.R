library(shiny)
#counties <- readRDS("myShinyData.rds")
#source("helpers.R")
customers = read.csv("/Users/divya/OneDrive/Data Analytics/Spring 2017/DAEN 690/Code/shiny_code/Shiny_Demo.csv", encoding = "utf-8")

shinyServer(
  function(input, output, session) {
    observeEvent(input$do, {
      n <- which(customers$CustomerId == input$cust)
        output$text_output1 = renderText({
          customers$Age[n]
        })
        output$text_output2 = reactive({
          customers$FirstPurchaseDate[n]
        })
        output$text_output3 = reactive({
          customers$LastPurchaseDate[n]
        })
        output$text_output4 = renderText({
          customers$Frequency[n]
        })
        output$text_output5 = reactive({
          customers$Generation[n]
        })
        output$text_output6 = reactive({
          customers$TotalAmount[n]
        })
        output$text_output7 = reactive({
          customers$Items[n]
        })
        output$text_output8 = reactive({
          customers$HasPromotion[n]
        })
        output$text_output9 = reactive({
          customers$CustomerCategory[n]
        })
    })
  }
)


# observeEvent(input$do, {
#   
#   n <- which(customers$CustomerId == input$cust)
#   
#   output$text_output1 = renderText({
#     customers$Age[n]
#   })
#   output$text_output2 = reactive({
#     customers$FirstPurchaseDate[n]
#   })
#   
#   output$text_output3 = reactive({
#     customers$LastPurchaseDate[n]
#   })
#   
#   output$text_output4 = renderText({
#     customers$Frequency[n]
#   })
#   
#   output$text_output5 = reactive({
#     customers$Generation[n]
#   })
#   output$text_output6 = reactive({
#     customers$TotalAmount[n]
#   })
#   output$text_output7 = reactive({
#     customers$Items[n]
#   })
#   output$text_output8 = reactive({
#     customers$HasPromotion[n]
#   })
#   output$text_output9 = reactive({
#     customers$CustomerCategory[n]
#   })
#   
#         
#output$view <- renderTable({
  
# })  