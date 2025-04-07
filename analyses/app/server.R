shinyServer(function(input, output, session) {

  # 1 Map -----------------------------------
  output$mapsp <- renderTmap({
    tm_shape(sp) +
      tm_raster("All", interpolate=FALSE, zindex = 401, group.control = "none") +
        tm_view(basemap.server = "OpenStreetMap",
                set_view = c(7, 55, 4))
  })

  output$mappo <- renderTmap({
    tm_shape(po) +
      tm_raster("All", interpolate=FALSE, zindex = 501, group.control = "none") +
      tm_view(basemap.server = "OpenStreetMap",
              set_view = c(7, 55, 4))
  })

  output$mappy <- renderTmap({
    tm_shape(py) +
      tm_raster("All", interpolate=FALSE, zindex = 601, group.control = "none") +
      tm_view(basemap.server = "OpenStreetMap",
              set_view = c(7, 55, 4))
  })

  spleg <- reactive({
    if(input$spe=="All"){
      spbk <- (0:8)*10
      splab <- "Richness"
    } else {
      spbk <- c(0,0.5,5,10,50,100,500,10000)
      splab <- "N observations"
    }
    return(list("bk"=spbk, "lab"=splab))
  })

  poleg <- reactive({
    if(input$spe=="All"){
      pobk <- c(0, 0.9, 5, 10, 50, 100, 500, 1000, 15000)
      polab <- "N Observations"
    } else {
      pobk <- c(0,0.5,5,10,25,50,100)
      polab <- "% observations"
    }
    return(list("bk"=pobk, "lab"=polab))
  })

  pyleg <- reactive({
    if(input$spe=="All"){
      pybk <- c(0, 0.9, 5, 10, 15, 20, 25, 35)
      pylab <- "N Year"
    } else {
      pybk <- c(0,0.5,5,10,25,50,100)
      pylab <- "% year observed"
    }
    return(list("bk"=pybk, "lab"=pylab))
  })

  occsp <- reactive({
    if(input$spe=="All"){
      return(dt)
    } else {
      return(dt[dt$species%in%input$spe,])
    }
  })

  observe({
    tmapProxy("mapsp", session, {
      tm_remove_layer(401) +
      tm_shape(sp) +
      tm_raster(input$spe, interpolate=FALSE, zindex = 401,
                breaks=spleg()$bk, title=spleg()$lab, group.control = "none")
    })  
  })

  observe({
    tmapProxy("mappo", session, {
      tm_remove_layer(501) +
      tm_shape(po) +
      tm_raster(input$spe, interpolate=FALSE, zindex = 501,
                breaks=poleg()$bk, title=poleg()$lab, group.control = "none")
    })  
  })

  observe({
    tmapProxy("mappy", session, {
      tm_remove_layer(601) +
      tm_shape(py) +
      tm_raster(input$spe, interpolate=FALSE, zindex = 601,
                breaks=pyleg()$bk, title=pyleg()$lab, group.control = "none")
    })  
  })

  output$obsts <- renderPlotly({
    dbi <- occsp()
    nobs_year <- aggregate(dbi$observationID, list(dbi$dbID, dbi$Year), nodup)
    plot_ly(nobs_year, x = ~Group.2, y = ~x, color = ~Group.1) %>% 
            layout(xaxis = list(title = 'Year'),
               yaxis = list(title = 'Number of observations'), 
               barmode = 'stack')
  })

  output$gridts <- renderPlotly({
    dbi <- occsp()
    nobs_year <- aggregate(dbi$grid10kmID, list(dbi$Country, dbi$Year), nodup)
    plot_ly(nobs_year, x = ~Group.2, y = ~x, color = ~Group.1) %>% 
            layout(xaxis = list(title = 'Year'),
               yaxis = list(title = 'Number of grid cells'), 
               barmode = 'stack')
  })
  
})