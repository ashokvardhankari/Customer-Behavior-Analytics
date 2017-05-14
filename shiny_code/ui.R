library(shiny)
customers = read.csv("/shiny_code/Shiny_Demo.csv", encoding = "utf-8")

shinyUI(fluidPage(theme = "bootstrap.css",
                  img(src='gmuLogo.png', height = 135, width = 190),
                  img(src='moes.jpg', height = 120, width = 180, align = "right"),
                  img(src='FBlogo.jpg', height = 110, width = 200, align = "right"),
                  
                  titlePanel("Customer Segmentation"),
                  
                    sidebarPanel(   
                      textInput("cust","Customer ID:",customers$CustomerId),
                      p("Some other example Customer ID's are: 3192874, 1468180, 1438925, 4433437, 3294168"),
                      actionButton("do", "Get Customer Segment and Characteristics")
                    ),
                    
                    sidebarPanel ( 
                      h1("Customer Details"),
                      h4("Age:", htmlOutput("text_output1", style = "color:blue")),
                      h4("First Visit Date:", htmlOutput("text_output2", style = "color:blue")),
                      h4("Last Visit Date:", htmlOutput("text_output3", style = "color:blue")),
                      h4("Total Visits:", htmlOutput("text_output4", style = "color:blue")),
                      h4("Generation:", htmlOutput("text_output5", style = "color:blue")),
                      h4("Amount spent:", htmlOutput("text_output6", style = "color:blue")),
                      h4("Items purchased:", htmlOutput("text_output7", sep="," ,style = "color:blue")),
                      h4("Promotions:", htmlOutput("text_output8", style = "color:blue"))
                  ),
                  
                  sidebarPanel(   
                    h2("Segment Name:", htmlOutput("text_output9", style = "color:green"))
                  )
                
))
