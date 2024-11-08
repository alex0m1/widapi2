# Load necessary libraries
library(plumber)
library(wid)  # Ensure the wid package is installed and properly set up

#* @apiTitle WID API
#* @apiDescription API for fetching data from the World Inequality Database (WID.world)

#* @filter logger
function(req) {
  # Log all incoming requests with timestamp
  cat(as.character(Sys.time()), "-", req$REQUEST_METHOD, req$PATH_INFO, "\n")
  forward()
}

#* Default route
#* @get /
function() {
  list(
    message = "Welcome to the WID API!",
    description = "Use /fetch_wid_data to query the World Inequality Database",
    endpoints = list(
      "/fetch_wid_data" = "Fetch WID data using parameters like indicators, areas, years, etc."
    )
  )
}

#* Fetch data from the WID
#* @param indicators Indicator codes (e.g., "sptinc" for pre-tax income shares)
#* @param areas Area codes (e.g., "US" for United States)
#* @param years Comma-separated years (e.g., "2010,2015")
#* @param perc Percentile group (e.g., "p99p100" for top 1%)
#* @param ages Age group codes (default: "999" for all ages)
#* @param pop Population type codes (default: "i" for individuals)
#* @param metadata Include metadata (TRUE or FALSE, default: FALSE)
#* @param include_extrapolations Include extrapolated data (TRUE or FALSE, default: TRUE)
#* @get /fetch_wid_data
function(
  indicators = "",
  areas = "",
  years = "",
  perc = "",
  ages = "999",
  pop = "i",
  metadata = "FALSE",
  include_extrapolations = "TRUE"
) {
  # Parse the input parameters
  years <- if (years != "") as.integer(unlist(strsplit(years, ","))) else NULL
  perc <- if (perc != "") unlist(strsplit(perc, ",")) else NULL
  ages <- if (ages != "") unlist(strsplit(ages, ",")) else "999"
  pop <- if (pop != "") unlist(strsplit(pop, ",")) else "i"
  metadata <- as.logical(metadata)
  include_extrapolations <- as.logical(include_extrapolations)
  
  # Fetch data from the WID using the wid package
  tryCatch(
    {
      data <- download_wid(
        indicators = indicators,
        areas = areas,
        years = years,
        perc = perc,
        ages = ages,
        pop = pop,
        metadata = metadata,
        include_extrapolations = include_extrapolations
      )
      
      # Return the data as JSON
      return(data)
    },
    error = function(e) {
      # Handle any errors gracefully
      list(error = TRUE, message = e$message)
    }
  )
}
