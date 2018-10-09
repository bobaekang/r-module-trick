# This is the "module" script to create module object
# and define functions to use.

(function() {
  # create an environment object to hold functions
  e <- new.env()
  
  # define functions to use
  e$hello_world <- function() {
    print("Hello world!")
  }

  e$greet_to <- function(name) {
    print(paste0("Hi, ", name, ". Using modules in R is easy!"))
  }
  
  # return the environment
  e
})()
