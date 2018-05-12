# A simple trick to use modules in R
This repository is created to illustrate a simple trick to mimic using modules in R like in Python or JavaScript.

*If you are going to share this trick with others, please be kind to share where you found the trick as well.* Thank you!

## Motivation
R is a powerful and versatile tool that is great for most data analysis and data science projects. However, one of the weaknesses of R language is its lack of native support for the module pattern.

Yes, R has packages. And yes again, creating one is by no means a Herculean task, especially with the fantastic `devtools` package. Our hero Hadley Wickham also has a free book, [*R Packages*](http://r-pkgs.had.co.nz/), to teach us everything about creating one! Nonetheless, in my personal experience, the convenience of quickly putting together some oft-used functionalities into a small reusable unit is still much to be desired.

To tackle this issue, a few fellow R users who are much skilled than I have already put together packages. One such package is [`modules` by Sebastian Warnholz](https://github.com/wahani/modules), which is available on CRAN. See the package vignette page [here](https://cran.r-project.org/web/packages/modules/vignettes/modulesInR.html). Another package is available at ["klmr/modules" Github repository](https://github.com/klmr/modules). The later is a rather strict translation of Python modules in R.

Here, I sought for a simple "base R" solution for implementing the module pattern. My solution is not as robust or elegant as the aforementioned ones. However, I am convinced that my little trick still merits any R user's consideration when it comes to simplicity and convenience.

## Introduction to the trick
The key idea here is combining R environment object with immediately invoked function expression (IIFE). In R, IIFE can be created by wrapping an expression to define a function in parenthesis followed by another parenthesis to call, or invoke, the function. The following code chunk illustrates the IIFE pattern:

```r
(function() {

  # your code here

})()
```

So how can we create a module? We write an R script like the following:

### module.R
```r
(function() {
  e <- new.env()

  e$foo <- function() print("foo")
  e$bar <- function() print("bar")

  e
})()
```

**And that's it!**

The IIFE in "module.R" script returns an environment object containing functions (or any other objects) to be made reusable. Within the IIFE, `e <- new.env()` creates the environment object and binds it to symbol `e`.  To store other objects, such as functions, in the environment `e`, we use the dollar sign symbol `$` with the assignment operator `<-`. The last line inside the IIFE must be the environment object `e`, or `return(e)`, to ensure that the IIFE's final return value is the environment we intend to use as our module.

R environments behave similarly to R lists albeit with some interesting and critical differences. To learn more about R environments, please refer to [the "Environments" chapter](http://adv-r.had.co.nz/Environments.html) in Hadley Wickham's *Advanced R* .

Now we are ready to use the module by `source()`-ing it within another script, say, "main.R".
When we `source()` the "module.R" script, the IIFE is execuated and returns the environment object. However, simply `source()`-ing the "module.R" will not preserve the environment object in the "main.R" workspace (i.e., global environment).

**Now a critical part:**

To make that environment object readily accessible within the "main.R" script, we must create a binding between a symbol and the `value` property of the `source()` output. This is because the IIFE from `source()` returns a list with two elements: `value`, which is the content of the `source()`-d script, and `visible`, a boolean (logical) value for the "visibility" of the `value`.

Look at the following code chunk illustrating how to "import" the module into "main.R" to use:

### main.R
```r
module <- source("module.R")$value

module$foo()  # this will print "foo"
module$bar()  # this will print "bar"
```

Once the module is "imported" into the "main.R" workspace, it is easy to use its functions.

Sometimes you might want to use a function without the `module$` prefix. In fact, that is what a tranditional use of `source()` without IIFE would do. But if you already have a module script with IIFE *and* only want to use a specific function in the module, there is nothing stopping you from getting what you want! Just do the following:

```r
foo <- source("module.R")$value$foo

foo() # this will print "foo"
```

**Now you know how to use modules in R!**

This repository also contains two short R scripts, "R/main.R" and "R/module.R" for you to try out. Clone this repository to your local machine or simply copy and paste the code to practice using modules in R!

## A caveat
If you are importing external packages within your module script, please know that the package will be also loaded in your main workspace as you `source()` the module script. Consider the implications of this behavior and revise your module script accordingly.

Again, the trick introduced here is just that: a trick. Use it as you deem fit, but if you are looking for a more robust and elaborate solution, please go ahead and try existing packages that are designed to support the module pattern in R programming.