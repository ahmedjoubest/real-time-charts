
ui <- fluidPage(
  shinyjs::useShinyjs(),
  # custom CSS and JS files
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/styles.css"),
    tags$script(src = "js/script.js")
  ),
  # action button to open the panel
  actionButton(
    inputId = "settings-btn",
    label = "",
    class = "settings-btn",
    onclick = "showPanel()",
    icon = icon("cog")
  ),
  # custom panel
  absolutePanel(
    class = "custom-panel",
    id = "panel",
    # header
    div(
      class = "panel-header",
      h2("Live Performance Monitoring", class = "panel-title"),
      span(class = "close-btn", "×", onclick = "togglePanel()")
    ),
    # content
    h5(
      "Visitor Activity Trends - Last 30 seconds",
      class = "chart-title"
    ),
    highchartOutput("hc_plot_1", height = "36vh"),
    h5("Real-Time distribution of", tags$b(id = "active_visits", style = "color: #FFA622;"),
       "active sessions", 
       class = "chart-title",
       style = "margin-top: 0px !important;"),
    highchartOutput("hc_plot_2", height = "39vh")
  )
)
