message("Rendering output to all formats")
## Render to analysis to required output formats

output_formats <- c("html_document", "pdf_document", "md_document", "word_document")

docs_to_render <- c("report.Rmd")

for (format in output_formats) {
  for (doc in docs_to_render) {
    message("Rendering ", doc, " into ", format)
    rmarkdown::render(doc,
                      output_dir = ifelse(format %in% "md_document",
                                          ".", "rendered-report"),
                      knit_root_dir = c("."),
                      output_format = format)
  }
}
