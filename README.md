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

## Identifier substitution

If the `--replace` option is used, identifiers defined in the dictionary files are replaced by their definitions.

```ruby
method : def
HTTP
```

When several definitions are provided, only the last provided definition is applied.

If the `--convert` option is used :
*   `UPPER_CASE` identifiers are converted to `PascalCase`
*   `PascalCase` identifiers are converted to `snake_case`

```ruby
require "http/server";

server = HTTP::SERVER.New
    do |context|
    {
        context.Response.ContentType = "text/plain";
        context.Response.Print( "Hello world! The time is #{Time.now}" );
    }

address = server.BindTcp( 8080 );
Puts( "Listening on http://#{address}" );
server.Listen();
```

Identifiers in quoted strings or prefixed with `#` aren't converted.

```ruby
enum COLOR
{
    // -- CONSTANTS

    #Red
    #Green
    #Blue

    // -- INQUIRIES

    method IsRed?(
        )
    {
        return self == #Red;
    }
}
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
--replace dictionary.txt : replace identifiers defined in this dictionary
--convert : convert uppercase and Pascal case identifiers
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

Converts the Cibyl files of the input folder into matching Crystal files in the output folder,
creating the Crystal folders if needed, and then watches the Cibyl files for modifications.

```bash
cibyl --crystal --replace dictionary.txt --convert --create --watch CB/ CR/
```

Converts the Cibyl files of the input folder into matching Crystal files in the output folder,
replacing the identifiers specified in `dictionary.txt`,
converting the case of the `UPPER_CASE` and `PascalCase` identifiers,
creating the Crystal folders if needed, and then watches the Cibyl files for modifications.

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
