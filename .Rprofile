source("renv/activate.R")

# fix git2r
invisible({
  local({
    cred <- git2r::cred_ssh_key(
      str_replace_all(git2r::ssh_path("id_rsa.pub"), "\\\\", "\\/"),
      str_replace_all(git2r::ssh_path("id_rsa"), "\\\\", "\\/")
    )
    usethis::use_git_credentials(cred)
  })
})
