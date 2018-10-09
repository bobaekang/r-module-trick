# This is the "main" script to import and use a module.

# First, we need to import the module, stored in "module.R" script
# and bind it to a symbol to create a module object.
m <- source("module.R")$value

# Now we can use any functions in the module with $ operator.
m$hello_world()
m$greet_to("Bobae")
