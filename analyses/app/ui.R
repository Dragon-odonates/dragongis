shinyUI(fluidPage(

  # Application title
  titlePanel("Exploration of odonates dataset"),

  sidebarLayout(

    # Sidebar with a slider input
    sidebarPanel(
      selectInput("spe", "Species:",
                  choices = names(sp),
                  selected = 10)
    ),

  mainPanel(
    tabsetPanel(
    tabPanel("N Observations",
           withSpinner(tmapOutput('mapsp'), type=4)),
    tabPanel("Perc Observation",
           withSpinner(tmapOutput('mappo'), type=4)),
    tabPanel("Perc Year",
           withSpinner(tmapOutput('mappy'), type=4))
    ),
    tabsetPanel(
      tabPanel("N Observations",
             plotlyOutput('obsts')),
      tabPanel("N Cells",
             plotlyOutput('gridts'))
      )
  )
)
)
)