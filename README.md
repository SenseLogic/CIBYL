![](https://github.com/senselogic/CIBYL/blob/master/LOGO/cibyl.png)

# Cibyl

Lightweight curly-bracket language which compiles to Ruby and Crystal.

# Description

Cibyl is a lightweight language which allows to develop Ruby and Crystal applications with a C-like syntax.

## Syntax

Most of the Ruby/Crystal syntax is kept unchanged, except that :

*   `.cb` files contain Cibyl code
*   a comment starts by `//`
*   a block starts by `{` and ends by `}`
*   a `do` block starts its own line

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

## Naming convention

Additionally, if the `--case` option is enabled, `PascalCase` identifiers will :

*   automatically be converted to `snake_case` if they are :
    *   prefixed with `@` or `.`
    *   suffixed with `(`
*   remain unchanged if they are prefixed with `#`

```ruby
require "http/server";

server = HTTP::Server.New
    do |context|
    {
        context.Response.ContentType = "text/plain";
        context.Response.Print( "Hello world! The time is #{Time.now}" );
    }

address = server.BindTcp( 8080 );
Puts( "Listening on http://#{address}" );
server.Listen();
```

## Limitations

*   Blocks must be properly aligned.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html).

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
--case : convert PascalCase attributes and methods to snake_case
--parse INPUT_FOLDER/ : find PascalCase attributes and methods in the Cibyl files of this folder
--compact : remove unused lines
--create : create the output folders if needed
--watch : watch the Cibyl files for modifications
--pause 500 : time to wait before checking the Cibyl files again
```

### Examples

```bash
cibyl --ruby --compact CB/ RB/
```

Converts the Cibyl files of the input folder into matching Ruby files in the output folder.

```bash
cibyl --crystal --create --watch CB/ CR/
```

Converts the Cibyl files of the input folder into matching Crystal files in the output folder, creating the Crystal folders if needed, and watches the Cibyl files for modifications.

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
