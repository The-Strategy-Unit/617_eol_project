source("renv/activate.R")

# fix git2r
invisible({
  if(require(git2r, quietly = TRUE) &
     require(usethis, quietly = TRUE)) {

    local({
      cred <- cred_ssh_key(
        gsub("\\\\", "\\/", ssh_path("id_rsa.pub")),
        gsub("\\\\", "\\/", ssh_path("id_rsa"))
      )
      use_git_credentials(cred)
    })

  }
})
