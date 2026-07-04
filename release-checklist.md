# Release Checklist

## GitHub

- Confirm package metadata in `DESCRIPTION`.
- Confirm `README.md` install instructions use the final GitHub repo path.
- Run local tests.
- Run `R CMD build respawnr`.
- Run `R CMD check --no-manual --no-build-vignettes respawnr_0.1.0.tar.gz`.
- Initialize git and commit the package source.
- Create the GitHub repository.
- Push the local repository to GitHub.
- Confirm GitHub Actions checks pass.
- Create a GitHub release tagged `v0.1.0`.

## CRAN Later

- Replace placeholder maintainer email.
- Run `R CMD check --as-cran`.
- Check the package on all major operating systems.
- Submit the built source tarball through CRAN's web form.
