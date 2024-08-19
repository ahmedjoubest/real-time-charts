
server <- function(input, output, session) {
  
  # ------ * auto invalidate timer ---------------------------------------------
  auto_invalidate <- reactiveTimer(1350)
  
  # ------ * Initialize reactive data ------------------------------------------
  tables <- reactiveValues(
    active_visits = NULL,
    visits_dist = NULL
  )
  observe({
    # Create random data to simulate traffic data
    dt <- CJ(visit_type = c("New Visitor", "Returning Visitor"))
    dt <- dt[rep(seq_len(.N), each = n_last_secs)]
    dt[, time := rep(1:n_last_secs, times = .N / n_last_secs)]
    dt[, n_active_visits := sample(1500:2500, .N, replace = TRUE)]
    tables$active_visits <- dt
  })
  
  # ------ * Data update (API calls simulation) --------------------------------
  observeEvent(auto_invalidate(), {
    # Update the active visitors data
    tables$visits_dist <- data.table(
      pages = rep(
        c("MainPage", "Products", "Confirmation", "Checkout"),
        each = 2
      ),
      visit_type = rep(c("New Visitor", "Returning Visitor"), 4),
      n_active_visits = sample(200:800, 8, replace = TRUE)
    )
    # update total number of active visitors in the UI
    shinyjs::html(
      "active_visits", sum(tables$visits_dist$n_active_visits)
    )
    # update the reactive data
    tables$active_visits <- rbind(
      tables$active_visits,
      data.table(
        time = rep(
          tables$active_visits$time[nrow(tables$active_visits)] + 1,
          2
        ),
        visit_type = c("New Visitor", "Returning Visitor"),
        n_active_visits = c(
          sum(tables$visits_dist$n_active_visits[
            tables$visits_dist$visit_type == "New Visitor"
          ]),
          sum(tables$visits_dist$n_active_visits[
            tables$visits_dist$visit_type == "Returning Visitor"
          ])
        )
      )
    )
  })
  
  # ------ * Initialize the line chart -----------------------------------------
  output$hc_addpoint <- renderHighchart({
    hc <- highchart() |>
      hc_chart(type = "column") |>
      hc_xAxis(title = list(), labels = list(enabled = FALSE), tickLength = 0) |>
      hc_tooltip(
        headerFormat = "",  # Hides the tooltip title
        shared = TRUE
      ) |>
      hc_title(text = NULL) |> 
      hc_colors(colors) |>
      hc_legend(enabled = FALSE) |> 
      hc_navigator(enabled = TRUE, adaptToUpdatedData = TRUE, height = 0) |>
      hc_plotOptions(
        column = list(
          states = list(
            hover = list(enabled = TRUE, brightness = 0.3) # hover effect
          )
        )
      )
    # Add series for each visitor type
    for (type in c("New Visitor", "Returning Visitor")) {
      hc <- hc |>
        hc_add_series(
          name = type,
          data = list_parse2(
            isolate(
              tables$active_visits[visit_type == type, .(time, n_active_visits)]
            )
          ),
          marker = list(enabled = TRUE, radius = 1.2, symbol = "circle"),
          id = type
        )
    }
    hc    
  })
  
  # ------ * Initialize the bar chart ------------------------------------------
  output$hc_set_data <- renderHighchart({
    hchart(
      isolate(tables$visits_dist), # isolate reactive data: only update through proxy
      "column",
      hcaes(x = pages, y = n_active_visits, group = visit_type)
    ) |>
      hc_xAxis(title = list(text = NULL)) |>
      hc_colors(colors) |>
      hc_yAxis_multiples(
        list(title = list()),
        list(title = list(), opposite = TRUE)
      ) |>
      hc_tooltip(shared = TRUE) |>
      hc_plotOptions(
        column = list(
          states = list(
            hover = list(enabled = TRUE, brightness = 0.3) # hover effect
          )
        )
      )
  })
  
  # ------ * Update the charts -------------------------------------------------
  observeEvent(tables$active_visits, {
    # update the line chart
    highchartProxy("hc_addpoint") |>
      hcpxy_add_point(
        id = "New Visitor",
        point = list(
          x = tables$active_visits$time[nrow(tables$active_visits) - 1],
          y = tables$active_visits$n_active_visits[nrow(tables$active_visits) - 1]
        ),
        shift = TRUE
      ) |>
      hcpxy_add_point(
        id = "Returning Visitor",
        point = list(
          x = tables$active_visits$time[nrow(tables$active_visits)],
          y = tables$active_visits$n_active_visits[nrow(tables$active_visits)]
        ),
        shift = TRUE
      )
    
    # Update the bar chart
    highchartProxy("hc_set_data") |>
      hcpxy_set_data(
        type = "column",
        data = tables$visits_dist,
        mapping = hcaes(pages, n_active_visits, group = visit_type),
        redraw = TRUE
      )
  })
}
