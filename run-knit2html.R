.PATH = sprintf('.tmp/%s', OUT)
if(!exists('PARAMS')) PARAMS = NULL
dir.create(.PATH, showWarnings = F, recursive= T)
rmarkdown::render(input=IN, output_dir=dirname(OUT), output_file=basename(OUT), intermediates_dir=.PATH, clean=T, params = PARAMS)

