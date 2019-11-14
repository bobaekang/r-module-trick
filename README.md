# R module trick

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

*Note: This module trick originally used environment rather than list, but I came to a conclusion that the list syntax is simpler, more beginner friendly, and easier to take a peak into the `source()` output. The current README is much more expanded, too. If you are curious about the original trick, go to [`/old`](./old).*

## Table of contents

* [Summary](#summary)
* [Main](#summary)
  * [Motivation](#motivation)
  * [The trick](#the-trick)
  * [Tips for using modules](#tips-for-using-modules)
  * [A caveat](#a-caveat)
  * (NEW) [TinyURL for using files in this repository](#tinyurl-for-using-files-in-this-repository)
  * (NEW) [`import_module` function](#import_module-function)
  * [TL;DR](#tldr)
  * [Resources](#resources)
* [License](#license)

## Summary
A simple trick to mimic using modules in R like in Python or JavaScript.

## Main
### Motivation
R is a powerful and versatile tool that is great for most data analysis and data science projects. However, one of the weaknesses of R language is its lack of native support for the module pattern.

Yes, R has packages. And yes again, creating one is by no means a Herculean task, especially with the fantastic `devtools` package. Hadley Wickham, best known as the creator of popular `tidyverse`, also has written a free book, [*R Packages*](http://r-pkgs.had.co.nz/), to teach us everything about creating one! Nonetheless, in my personal experience, the convenience of quickly putting together some oft-used functionalities into a small reusable unit is still much to be desired.

To tackle this issue, a few fellow R users who are much skilled than I have already put together packages. One such package is [`modules` by Sebastian Warnholz](https://github.com/wahani/modules), which is available on CRAN. See the package vignette page [here](https://cran.r-project.org/web/packages/modules/vignettes/modulesInR.html). Another package is available at ["klmr/modules" Github repository](https://github.com/klmr/modules). The later is a rather strict translation of Python modules in R.

Here, I sought for a simple "base R" solution for implementing the module pattern. My solution is not as robust or elegant as the aforementioned alternatives. However, I am convinced that my little trick still merits any R user's consideration when it comes to simplicity and convenience.

### The trick
The key idea here is using immediately invoked function expression (IIFE) to return a list of utility functions and objects. In R, IIFE can be created by wrapping an anonymous function in parentheses, `()`, followed by another `()` to call, or invoke, the function. In code, the IIFE pattern looks like the following:

```r
(function() {  

  # function body

})()
```

So how can we create a module? We write an R script like the following:

```r
# module.R

(function() {
  foo <- function() print("foo")

  # export
  list(
    foo = foo,
    bar = function() print("bar")
  )
})()
```

**And that's it!**

The IIFE in "module.R" returns a list object, created by a `list()` call at the end of the function body, which contains your utility functions and objects as its elements. The example also demonstrates that it is possible to both 1) create a function or an object beforehand and then pass it to the `list()` call and 2) create a function or an object within the `list` call. This allows for implementing some operations that are "private", i.e. not exposed to module users. 

Now we are ready to use the module by `source()`-ing it within another script, say, "main.R". When we `source()` "module.R", the IIFE is evaluated and returns the list containing custom utilities. However, simply `source()`-ing the "module.R" will not preserve its return value in the "main.R" global environment.

To make the list object and its contents easily accessible in "main.R", we must assign the `value` of the `source()` output to a name. This is possible because the `source()` call in fact returns a list with two elements: 1) `value`, which is the content of the `source()`-d script (what the IIFE returns in our case), and 2) `visible`, a boolean (logical) value for the "visibility" of the `value`.

```r
typeof(source("module.R"))
#> [1] "list"

print(source("module.R"))           
#> $value
#> $value$foo
#> function () 
#> print("foo")
#> <environment: 0x000000000c5d9ce8>
#> 
#> $value$bar
#> function () 
#> print("bar")
#> <environment: 0x000000000c5d9ce8>
#> 
#> 
#> $visible
#> [1] TRUE
```

Then, "importing" the module in "main.R" and using its contents would look like the following:

```r
# main.R

module <- source("module.R")$value

module$foo()
#> [1] "foo"
                        
module$bar()
#> [1] "bar"
```
:tada: **Congratulations!** Now you know how to use modules in R! 

### Tips for using modules
####  Tip 1
Sometimes you might want to use utilities in your module without the `module$` prefix. In fact, that is what a traditional use of `source()` without IIFE would do. But if you already have a module script with IIFE *and* only want to use a specific function in the module, there is nothing stopping you from getting what you want:
```r
module <- source("module.R")$value
foo <- module$foo

# Or get the function directly:
# foo <- source("module.R")$value$foo

foo()
#> [1] "foo"
```
####  Tip 2
What if you want to use all utilities in the module without the prefix? There is an easy solution to this: `attach()`. When you `attach()` your module, R adds it to the search path to make its elements accessible by their names alone. Use `?attach` to read its documentation for more details. You can verify this by using `search()`, which prints out the search path R uses to find names.
```r
module <- source("module.R")$value
attach(module)

# Use without `module$`
foo()
#> [1] "foo"

bar()
#> [1] "bar"

search()
#>  [1] ".GlobalEnv"        "module"            "package:stats"    
#>  [4] "package:graphics"  "package:grDevices" "package:utils"    
#>  [7] "package:datasets"  "package:methods"   "Autoloads"        
#> [10] "package:base"

# detach(module)
```

Generally, using `attach()` is discouraged since it can lead to errors and confusions, especially when used with data objects. In our case, however, using `attach()` makes perfect sense since we want to use our module in the same way we would use R packages.

Regardless, it is still a good practice to first assign the `source()` value to a name and then `attach()` it to keep the search path clean and understandable. Giving your module a meaningful name also helps if you need to later `detach()` it from the search path.

Also, do NOT use the `magrittr/dplyr` pipe, `%>%` , to `attach()` a module. `%>%` uses `.` as a replacement name for piped object and will result in adding `.` to the search path. This is not only confusing but also error-prone if you are using multiple modules with `attach()`.
```r
# Avoid this!
attach(source("module.R")$value)

search()
#>  [1] ".GlobalEnv"                          
#>  [2] "source(\"module.R\")$value"
#>  [3] "package:stats"                       
#>  [4] "package:graphics"                    
#>  [5] "package:grDevices"                   
#>  [6] "package:utils"                       
#>  [7] "package:datasets"                    
#>  [8] "package:methods"                     
#>  [9] "Autoloads"                           
#> [10] "package:base"

# Or this!
library(dplyr)
source("module.R")$value %>% attach()

search()
#>  [1] ".GlobalEnv"        "."                 "package:dplyr"    
#>  [4] "package:stats"     "package:graphics"  "package:grDevices"
#>  [7] "package:utils"     "package:datasets"  "package:methods"  
#> [10] "Autoloads"         "package:base"
```
####  Tip 3
Did you know that `source()` can also take a URL for the `file` argument? This means that you can `source()` a module script from an online location, say, a GitHub repository:
```r
url <- "https://tinyurl.com/r-module-trick/module.R"
module <- source(url)$value
attach(module)

hello_world()
#> [1] "Hello world!"

greet_to("friend")
#> [1] "Hi, friend. Using modules in R is easy!"
```

Of course, it will never be as simple as using `install.packages("package")`or `devtools::install_github("username/package")`. Nonetheless, this ability to use a module script stored remotely opens up whole new possibilities!

### A caveat
If you are importing external packages within your module script, please note that the package will be also attached in the main script's global environment as you `source()` the module script. Consider the implications of this behavior and revise your module script accordingly as needed.

Again, the trick introduced here is just that: a *trick*. Use it as you deem fit. However, if you are looking for a more robust and elaborate solution, please try existing packages designed to support the module pattern in R or simply create your own package. 

### TinyURL for using files in this repository

`https://tinyurl.com/r-module-trick/*` is now redirected to `https://raw.githubusercontent.com/bobaekang/r-module-trick/master/*`.


### `import_module` function

To make it easier to use custom R modules, a new `import_module()` is added to this repository. To use `import_module()`, first `source()` the `./import_module.R` file in this repository.

```r
source("https://tinyurl.com/r-module-trick/import_module.R")
```

Running `./import_module.R` adds to your global environment the following two functions:

* `import_module()` to import an R module
* `import_module_help()` to display documentation for `import_module()`

In essense, `import_module()` is a thin wrapper over `source()` but with the following convenience features:

* Setting `attached = TRUE` (default) will automatically attach the module to the search path. Alternatively, `attached = FALSE` will automatically create an R object in the global environment.
* If `name` is missing (default), `import_module()` will use the R file name as the module name when attaching it to the search path or creating an object in the global environment. If `name` is provided, its value will be used.

Please use the documentation for quick reference.

```r
# see documentation for import_module
import_module_help()
```

### TL;DR
* Use IIFE that returns a list to quickly create your custom R module!

### Resources
* ["klmr/modules" package Github repository](https://github.com/klmr/modules)
* [*R Packages*](http://r-pkgs.had.co.nz/) by Hadley Wickham
* ["wahani/modules" package Github repository](https://github.com/wahani/modules)

## License

[MIT](http://opensource.org/licenses/MIT)

Copyright (c) 2019 Bobae Kang