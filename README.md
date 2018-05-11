# A simple trick to use modules in R
This repository is to illustrate how to mimic using modules in R like in Python or JavaScript.

## Motivation
R is a powerful and versatile language that can meet needs for most data analysis and data science projects. However, one of the weaknesses of R language is its lack of support for creating and using modules.

Yes, R has packages. And yes again, creating one is by no means a Herculean task, especially with the fantastic `devtools` package. Nonetheless, in my personal experience, the convenience of quickly putting together some oft-used functionalities into a reusable unit, like in Python, is still much to be desired.

To tackle this issue, a few fellow R users much skilled than I have already put together packages. One such package is ["modules" by Sebastian Warnholz](https://github.com/wahani/modules), which is available in CRAN. See the package vignette page [here](https://cran.r-project.org/web/packages/modules/vignettes/modulesInR.html). Another package is available at ["klmr/modules" Github repository](https://github.com/klmr/modules). The later is a rather strict translation of Python modules in R.

Here, I sought for a "base R" solution to modular pattern. My solution is not as robust or elegant as the aforementioned ones. However, I am convinced that my solution still merits any R user's consideration when it comes to simplicity and convenience.

## Introduction
The key trick here is combining R environment object with immediately invoked function expression (IIFE). In R, IIFE can be created by wrapping a expression to define a function in parenthesis followed by another parenthesis to call the function.

So how can we create the module? We write an R script like the following:

### module.R
```r
(function() {
  e <- new.env()

  e$foo <- function() print("foo")
  e$bar <- function() print("bar")

  e
})()
```

**And that's it!** The IIFE returns an environment that contains functions (or any other objects) to be made reusable. Here, `e <- new.env()` creates an environment object and binds it to symbol `e`.  To store other objects in the environment `e`, we use the dollar sign symbol `$` with the assignment operator `<-`. R environments behave similarly to R lists albeit with some interesting differences. To learn more about R environments, read [the "Environments" chapter](http://adv-r.had.co.nz/Environments.html) in Hadley Wickham's *Advanced R* .

Now we are ready to use the module by `source()`-ing it within another script, say, "main.R".
When we `source()` the "module.R" script, the IIFE is execuated and returns the environment object. However, simply `source()`-ing the "module.R" will not preserve the environment object in the global environment of "main.R". To make that environment object readily accessible in the "main" script, we must create an object by binding a symbol and the `value` property of the output of the `source()`. 

### main.R
```r
module <- source("module.R")$value

module$foo()  #this will print "foo"
module$bar()  #this will print "bar"
```


## Example
I created two simple R scripts, "R/main.R" and "R/module.R" for you to try out. Clone this repository to your local directory or simply copy and paste the code.