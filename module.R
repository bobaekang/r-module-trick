# This is the "module" script to create module object
# and define functions to use.

(function() {
  # define functions to use
  list(
    hello_world = function() {
      print("Hello world!")
    },
    
    greet_to = function(name) {
      print(paste0("Hi, ", name, ". Using modules in R is easy!"))
    }
  )
})()
