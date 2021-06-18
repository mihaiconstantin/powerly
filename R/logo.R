#' Update package logo displayed at load time.
#'
#' After running this procedure we end up with what is stored in the `LOGO` constant.
#' It is meant for updating the logo.
#'
update.logo <- function(ascii.logo.path = "./inst/assets/logo/logo.txt", version = c(1, 0, 0)) {
    # Load the ASCII logo.
    logo <- readLines(ascii.logo.path)
    logo <- dput(logo)

    # Update versioning.
    logo <- gsub("{{major}}", version[1], logo, perl = TRUE)
    logo <- gsub("{{minor}}", version[2], logo, perl = TRUE)
    logo <- gsub("{{patch}}", version[3], logo, perl = TRUE)

    # Print the logo.
    cat(logo, sep = "\n")

    # Condensed version.
    logo <- paste(logo, collapse = "\n")

    return(logo)
}

# The simple logo.
LOGO = ". . . . . . . . . . . . . . . . . . . . . . . . . . . . . .\n.                                            _     v0.1.0 .\n.                                           | |           .\n.   _ __     ___   __      __   ___   _ __  | |  _   _    .\n.  | '_ \\   / _ \\  \\ \\ /\\ / /  / _ \\ | '__| | | | | | |   .\n.  | |_) | | (_) |  \\ V  V /  |  __/ | |    | | | |_| |   .\n.  | .__/   \\___/    \\_/\\_/    \\___| |_|    |_|  \\__, |   .\n.  | |                                            __/ |   .\n.  |_|                                           |___/    .\n.                                                         .\n. . . . . . . . . . . . . . . . . . . . . . . . . . . . . .\n.                            .                            .\n. Author: Mihai A. Constantin                             .\n. Contact: mihai@mihaiconstantin.com                      .\n. Source: github.com/mihaiconstantin/powerly              .\n.                            .                            .\n. . . . . . . . . . . . . . . . . . . . . . . . . . . . . ."
