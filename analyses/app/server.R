shinyServer(function(input, output, session) {

  # Maps --------------------------------------------------------------------
  output$mapsp <- renderTmap({
    tm_shape(sp) +
      tm_raster("All", 
                options = opt_tm_raster(interpolate = FALSE), 
                zindex = 401, group.control = "none") +
        tm_view(basemap.server = "OpenStreetMap",
                set_view = c(7, 55, 4))
  })

  output$mappo <- renderTmap({
    tm_shape(po) +
      tm_raster("All", 
                options = opt_tm_raster(interpolate = FALSE), 
                zindex = 501, group.control = "none") +
      tm_view(basemap.server = "OpenStreetMap",
              set_view = c(7, 55, 4))
  })

  output$mappy <- renderTmap({
    tm_shape(py) +
      tm_raster("All", 
                options = opt_tm_raster(interpolate = FALSE), 
                zindex = 601, group.control = "none") +
      tm_view(basemap.server = "OpenStreetMap",
              set_view = c(7, 55, 4))
  })

  ## Legends ----------
  spleg <- reactive({
    if(input$spe == "All"){
      # spbk <- (0:8)*10
      style <- "pretty"
      splab <- "Richness"
    } else {
      # spbk <- c(0, 0.5, 5, 10, 50, 100, 500, 10000)
      style <- "log10_pretty"
      splab <- "# observations"
    }
    return(list("style" = style, "lab" = splab))
  })

  poleg <- reactive({
    if(input$spe == "All"){
      # pobk <- c(0, 5, 10, 50, 100, 500, 1000, 5000)
      style <- "log10_pretty"
      polab <- "# observations"
    } else {
      # pobk <- c(0, 5, 10, 25, 50, 100)
      style <- "pretty"
      polab <- "% observations"
    }
    return(list("style" = style, "lab" = polab))
  })

  pyleg <- reactive({
    if(input$spe=="All"){
      # pybk <- c(0, 0.9, 5, 10, 15, 20, 25, 35)
      pylab <- "# years"
    } else {
      # pybk <- c(0,0.5,5,10,25,50,100)
      pylab <- "% years species detected"
    }
    return(list("lab" = pylab))
  })

  ## Reactive data subset ----------
  occsp <- reactive({
    if(input$spe == "All"){
      return(dt)
    } else {
      return(dt[dt$species %in% input$spe,])
    }
  })

  ## Reactive map update ----------
  observe({
    tmapProxy("mapsp", session, {
      tm_remove_layer(401) +
      tm_shape(sp) +
      tm_raster(input$spe, 
                options = opt_tm_raster(interpolate = FALSE), 
                zindex = 401,
                col.scale = tm_scale_intervals(style = spleg()$style), 
                col.legend = tm_legend(title = spleg()$lab), 
                group.control = "none")
    })  
  }) |> bindEvent(input$spe)

  observe({
    tmapProxy("mappo", session, {
      tm_remove_layer(501) +
      tm_shape(po) +
      tm_raster(input$spe, 
                options = opt_tm_raster(interpolate = FALSE), 
                zindex = 501,
                col.scale = tm_scale_intervals(style = poleg()$style), 
                col.legend = tm_legend(title = poleg()$lab), 
                group.control = "none")
    })  
  }) |> bindEvent(input$spe)

  observe({
    tmapProxy("mappy", session, {
      tm_remove_layer(601) +
      tm_shape(py) +
      tm_raster(input$spe, 
                options = opt_tm_raster(interpolate = FALSE), 
                zindex = 601,
                col.scale = tm_scale_continuous(), 
                col.legend = tm_legend(title = pyleg()$lab),
                group.control = "none")
    })  
  }) |> bindEvent(input$spe)


  # Trends per dataset ------------------------------------------------------
  
  output$obsts <- renderPlotly({
    dbi <- occsp()
    nobs_year <- aggregate(dbi$observationID, list(dbi$dbID, dbi$Year), nodup)
    plot_ly(nobs_year, x = ~Group.2, y = ~x, color = ~Group.1,
            type = "scatter", mode = "lines+markers",
            colors = dataset_color) |>  
      layout(xaxis = list(title = 'Year'),
             yaxis = list(title = 'Number of observations'))
  })

  output$gridts <- renderPlotly({
    dbi <- occsp()
    nobs_year <- aggregate(dbi$grid10kmID, list(dbi$Country, dbi$Year), nodup)
    plot_ly(nobs_year, x = ~Group.2, y = ~x, color = ~Group.1,
            type = "scatter", mode = "lines+markers",
            colors = countries_color) |>  
            layout(xaxis = list(title = 'Year'),
                   yaxis = list(title = 'Number of grid cells'))
  })
  
})