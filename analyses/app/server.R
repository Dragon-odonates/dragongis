shinyServer(function(input, output, session) {

  ## Reactive data subset ----------
  occsp <- reactive({
    if(input$spe == "All"){
      return(dt)
    } else {
      return(dt[dt$species %in% input$spe,])
    }
  })
  
  # Maps --------------------------------------------------------------------
  output$mapsp <- renderTmap({
    tm_shape(sp) +
      tm_raster("All", 
                col.legend = tm_legend(title = spleg()$lab),
                options = opt_tm_raster(interpolate = FALSE), 
                zindex = 401, group.control = "none") +
        tm_view(basemap.server = "OpenStreetMap",
                set_view = c(7, 55, 4))
  })

  output$mappo <- renderTmap({
    tm_shape(po) +
      tm_raster("All", 
                col.legend = tm_legend(title = poleg()$lab),
                options = opt_tm_raster(interpolate = FALSE), 
                zindex = 501, group.control = "none") +
      tm_view(basemap.server = "OpenStreetMap",
              set_view = c(7, 55, 4))
  })

  output$mappy <- renderTmap({
    tm_shape(py) +
      tm_raster("All", 
                col.legend = tm_legend(title = pyleg()$lab),
                options = opt_tm_raster(interpolate = FALSE), 
                zindex = 601, group.control = "none") +
      tm_view(basemap.server = "OpenStreetMap",
              set_view = c(7, 55, 4))
  })

  ## Legends ----------
  spleg <- reactive({
    if(input$spe == "All"){
      splab <- "Richness"
    } else {
      splab <- "# observations"
    }
    return(list("lab" = splab))
  }) 

  poleg <- reactive({
    if(input$spe == "All"){
      polab <- "# observations"
    } else {
      polab <- "% observations"
    }
    return(list("lab" = polab))
  })

  pyleg <- reactive({
    if(input$spe == "All"){
      pylab <- "# years"
    } else {
      pylab <- "% years species detected"
    }
    return(list("lab" = pylab))
  })

  ## Reactive map update ----------
  observe({
    tmapProxy("mapsp", session, {
      tm_remove_layer(401) +
      tm_shape(sp) +
      tm_raster(input$spe, 
                options = opt_tm_raster(interpolate = FALSE), 
                zindex = 401,
                col.scale = tm_scale_intervals(as.count = TRUE), 
                col.legend = tm_legend(title = spleg()$lab), 
                group.control = "none")
    })  
  }) 

  observe({
    tmapProxy("mappo", session, {
      tm_remove_layer(501) +
      tm_shape(po) +
      tm_raster(isolate(input$spe), 
                options = opt_tm_raster(interpolate = FALSE), 
                zindex = 501,
                col.scale = tm_scale_intervals(as.count = TRUE), 
                col.legend = tm_legend(title = poleg()$lab), 
                group.control = "none")
    })  
  })

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
  })


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
    nobs_year <- aggregate(dbi$grid10kmID, list(dbi$country, dbi$Year), nodup)
    plot_ly(nobs_year, x = ~Group.2, y = ~x, color = ~Group.1,
            type = "scatter", mode = "lines+markers",
            colors = countries_color) |>  
            layout(xaxis = list(title = 'Year'),
                   yaxis = list(title = 'Number of grid cells'))
  })
  
})