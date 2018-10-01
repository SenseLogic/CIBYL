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
        return 1;
    }
    else
    {
        return fibonacci( n - 1 ) + fibonacci( n - 2 );
    }
}

puts fibonacci( 5 );
```

Optionally, Cibyl allows to use other case conventions and attribute prefixes :

```ruby
struct POINT
{
    def Initialize(
        .Name : STRING,
        .Position : POSITION,
        .Color : COLOR
        )
    {
    }

    def IsBlue(
        )
    {
        return .Color == COLOR.#Blue;
    }
}

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
*   a comment starts by `//`
*   a block starts by `{` and ends by `}`
*   a `do` block starts its own line

If the `--convert` option is used :

*   `.` prefixes are converted to `@`
*   `^` prefixes are converted to `@@`
*   identifiers prefixed with `#` are converted to `UPPER_CASE`
*   `UPPER_CASE` identifiers are converted to `PascalCase`
*   `PascalCase` identifiers are converted to `snake_case`

## Limitations

*   Blocks must be properly aligned.
*   Dictionaries are not reloaded dynamically.
*   Curly brackets are not available in embedded code.

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
--convert : convert the identifier case
--join : join split statements
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
