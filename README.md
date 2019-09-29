![](https://github.com/senselogic/CIBYL/blob/master/LOGO/cibyl.png)

# Cibyl

Lightweight curly-bracket language which compiles to Ruby and Crystal.

# Description

Cibyl allows to develop Ruby and Crystal applications with a C-like syntax :

```ruby
// Recursive Fibonacci function

def fibonacci(
    n : Int32
    )
{
    if ( n <= 1 )
    {
        return n;
    }
    else
    {
        return fibonacci( n - 1 ) + fibonacci( n - 2 );
    }
}

puts fibonacci( 8 );
```

Optionally, Cibyl allows to use other case conventions :

```ruby
require "http/server";

server = HTTP::SERVER.New
    do | context |
    {
        context.Response.ContentType = "text/plain";
        context.Response.Print( "Hello world! The time is #{TIME.Now}" );
    }

address = server.BindTcp( 8080 );
Puts( "Listening on http://#{address}" );
server.Listen();
```

## Syntax

Most of the Ruby/Crystal syntax is kept unchanged, except that :

*   `.cb` files contain Cibyl code
*   `.ecb` files contain embedded Cibyl code
*   blocks start by a `{` line and end by a `}` line
*   `do` blocks start their own lines
*   short comments start by `//`
*   long comments start by `/*` and end by `*/`
*   `<%~` `%>` blocks apply `HTML.escape` to their content

If the `--convert` option is used :

*   `$` prefixes are converted to `@@`
*   `PascalCase` identifiers are converted to `snake_case`
*   `UPPER_CASE` identifiers are converted to `PascalCase`
*   `PascalCase` identifiers prefixed with `#` are converted to `UPPER_CASE`
*   `snake_case` identifiers prefixed with `#` are converted to `PascalCase`

Characters and identifiers prefixed with `\` are kept unchanged.

## Limitations

*   Blocks must be properly aligned.
*   Multi-line strings are not supported.
*   Curly bracket blocks can't be used in embedded code.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (choosing the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 cibyl.d
```

## Command line

```
cibyl [options] INPUT_FOLDER/ OUTPUT_FOLDER/
```

### Options

```
--ruby : generate Ruby files
--crystal : generate Crystal files
--replace dictionary.txt : replace identifiers defined in this dictionary
--convert : convert the identifier case
--join : join split statements
--compact : remove unused lines
--create : create the output folders if needed
--watch : watch the Cibyl files for modifications
--pause 500 : time to wait before checking the Cibyl files again
--tabulation 4 : set the tabulation space count
```

### Examples

```bash
cibyl --ruby --compact CB/ RB/
```

Converts the Cibyl files of the input folder into matching Ruby files in the output folder.

```bash
cibyl --crystal --create --watch CB/ CR/
```

Converts the Cibyl files of the input folder into matching Crystal files in the output folder
(creating the Crystal folders if needed),
then watches the Cibyl files for modifications.

```bash
cibyl --crystal --replace dictionary.txt --convert --join --create --watch CB/ CR/
```

Converts the Cibyl files of the input folder into matching Crystal files in the output folder
(replacing the identifiers defined in the dictionary, converting the identifier case,
joining split statements and creating the Crystal folders if needed),
then watches the Cibyl files for modifications.

## Version

1.3

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
