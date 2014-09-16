#! /bin/sh 
# (C) Stefan Axelsson 2007-09-08
# Remove junk files below a directory

# Check nof args
if [ $# -ne 1 ] ; then echo "Usage: $0 directory-name" ; exit 1; fi

# -type f: just sum the regular files, not directories etc.
find $1 -maxdepth 1 -type f -and \( -name '*.o' -or -name '#*#' -or -name 'core' \) -exec echo removing: '{}' ';' -exec echo rm -f '{}' ';'

# Could have skipped the \(\) and -or as that's the default.

# -ok instead of the last -exec would ask the user if it's OK to
# -perform the command, that might be nice here.

# Note that we need to do some heavy escaping here as otherwise the
# shell would eat the characters that we need for 'find' to interpret
# such as () {} and ;, but we can't escape all of it, exec needs its
# command and argument split up by the shell. Note that to execute
# more commands we can just pile on the -exec directives.  Note also
# that there are security considerations with using 'exec', execdir is
# better. Note finally that we've "escaped" 'rm' by echoing the
# command instead of executing it to make sure that we're not doing
# anything dangerous before we know what's going to happen.