# Author: Bobae Kang (@bobaekang)
# License: MIT

#' Import an R "module"
#' 
#' Import a "module" from \code{path} using an optional \code{name}.
#' See \url{https://github.com/bobaekang/r-module-trick} for a detailed explanation.
#' 
#' @param path A character string for the path to a module file.
#' @param name A character string for an optional module name.
#' @param attach A logical value. If \code{TRUE}, attach module to the search
#'   path. If \code{FALSE}, create a module object in the global environment.
#' @seealso \code{\link[base]{attach}} for attaching R object to search path.
#' @seealso \code{\link[base]{assign}} for assigning a value to name.
#' @examples
#' # import a local module file
#' import_module(path = "module.R")
#' 
#' # import a remote module file with an optional name
#' path <- "https://tinyurl.com/r-module-trick/module.R"
#' import_module(path = path, name = "module_example")
import_module <- function(path, name, attach = TRUE) {
  
  if (missing(path))
    stop("argument 'path' missing")
  
  if (!grepl("\\.R$", path))
    stop ("argument 'path' not an R file")
  
  if (!is.logical(attach))
    stop("argument 'attach' not logical")

  if (missing(name)) {
    flatsplit <- function(str, ...) unlist(strsplit(str, ...))
    filename <- tail(flatsplit(path, '/'), 1)
    name <- head(flatsplit(filename, '\\.'), -1)
  }
  
  if (attach) {
    mod_name <- paste0("module:", name)
    
    if (mod_name %in% search())
      stop("'", mod_name, "' already attached")
    
    attach(what = source(path)$value, name = mod_name, pos = 3 )
      
    message(paste0("Note: '", name, "' now attached as '", mod_name, "'\n"))
  } else {
    if (exists(name, envir = globalenv()))
      stop("object '", name, "' already exists")
    
    assign(x = name, value = source(path)$value, envir = globalenv() )
    
    message(paste0("Note: '", name, "' now available in global environment\n"))
  }
}

#' Open documentation for \code{import_module}
#' 
#' Open a rendered HTML page of \code{import_module} documentation.
#' See \url{https://github.com/bobaekang/r-module-trick} for a detailed explanation.
import_module_help <- function() {
  Rd <- url("https://tinyurl.com/r-module-trick/man/import_module.Rd")
  html <- tools::Rd2HTML(Rd, tempfile(fileext = ".html"))
  
  if ("rstudioapi" %in% installed.packages() && rstudioapi::isAvailable()) {
    rstudioapi::viewer(html)
  } else
    browseURL(html)
}
