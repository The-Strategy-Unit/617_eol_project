if (!getOption("renv.consent", FALSE) & !any(grepl("renv", .libPaths()))) {
  options(renv.config.mran.enabled = FALSE)
  source("renv/activate.R")
}

if (interactive()) {
  # fix git2r
  invisible({
    if(require(git2r, quietly = TRUE) &
       require(usethis, quietly = TRUE)) {

      local({
        pub <- gsub("\\\\", "\\/", ssh_path("id_rsa.pub"))
        pri <- gsub("\\\\", "\\/", ssh_path("id_rsa"))

        if (file.exists(pub) && file.exists(pri)) {
          use_git_credentials(cred_ssh_key(pub, pri))
        }
      })
    }
  })
}
