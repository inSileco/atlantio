# potential value:
# - "any"    => any don't test, use this for character as well
# - "int"    => integer
# - "[n,p]"  => integer range
# - "double" => "double"
# Using latest version of Atlantis model
# Run file validation template

## Version based on a prm we used

run_file <- read_atlantis_files("inst/examples/lakeErie_run.prm")

assign_catgory <- function(x) {
  if (grepl("^flag", x)) {
    return(list(category = "flag", value = "[0-1]", required = TRUE))
  }
  if (grepl("^check", x)) {
    return(list(category = "check", value = "int", required = TRUE))
  }
  if (grepl("^K_num", x)) {
    return(list(category = "K_num", value = "int", required = TRUE))
  }
  return(list(category = "other", value = "any", required = TRUE))
}


# Initial version of the validation template using this code
run_file[[1]]$object |>
  lapply(\(x) list(name = x$name, description = x$comment)) |>
  lapply(\(x) c(x, assign_catgory(x$name))) |>
  yaml::write_yaml(file = "inst/parameters/run.yaml")
# Then edit by hand

# Based on a trunk xml

format_attributes <- function(x) {
  attributes(x) |> as.data.frame(x)
}

run_file <- xml2::read_xml("inst/parameters/VMPA_setas_run_fishing_F_Trunk.xml")

ls_run <- run_file |> xml2::as_list()

out <- list()
for (i in seq_along(ls_run[[1]])) {
  for (j in seq_along(ls_run[[1]][[i]])) {
    tmp <- attributes(ls_run[[1]][[i]][[j]])
    names(tmp) <- names(tmp) |> stringr::str_remove("^Attribute")
    out <- append(
      out,
      list(c(
        tmp[!names(tmp) %in% c("Value", "names", "ArrayLength")],
        list(
          Category = attributes(ls_run[[1]][[i]])$AttributeGroupName,
          Version_start = "6698",
          Version_stop = ""
        )
      ))
    )
  }
}
yaml::write_yaml(out, file = "inst/parameters/run.yaml")


out_categ <- list()
for (i in seq_along(ls_run[[1]])) {
  tmp <- attributes(ls_run[[1]][[i]])
  out_categ <- append(
    out_categ,
    list(list(
      Category = tmp$AttributeGroupName,
      Description = tmp$AttributeDescription
    ))
  )
}

yaml::write_yaml(out_categ, file = "inst/parameters/run_categories.yaml")

# check for replicates if needed
#   vc_nm <- tmp |> get_field_as_vector("Name")
#   if (any(duplicated(vc_nm))) {
#       cli::cli_abort("Some Replicates in the templates")
#   }
