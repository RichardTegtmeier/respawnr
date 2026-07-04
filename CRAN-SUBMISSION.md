# CRAN Submission Notes

This file is a working checklist for eventually submitting `respawnr` to CRAN.
It is ignored during package builds.

## Before Submitting

- Replace `richard@example.com` in `DESCRIPTION` with a real email address that
  CRAN can use for maintainer correspondence.
- Confirm `URL` and `BugReports` match the final GitHub repository.
- Run `R CMD build respawnr`.
- Run `R CMD check --as-cran respawnr_0.1.0.tar.gz`.
- Run checks on macOS, Windows, and Linux. GitHub Actions can cover this.
- Read the CRAN Repository Policy and confirm compliance.
- Confirm the package title and description are written for CRAN, not only for
  local use.
- Confirm examples do not require RStudio, interactive sessions, or unavailable
  services.

## First Submission Message

Use a short submission comment like:

> This is a new submission.

## After Submission

- Monitor the maintainer email address for CRAN messages.
- If CRAN requests changes, update the package, increment the patch version if
  needed, and resubmit with a concise explanation in `cran-comments.md`.
