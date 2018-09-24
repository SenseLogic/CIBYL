/*
    This file is part of the Cibyl distribution.

    https://github.com/senselogic/CIBYL

    Copyright (C) 2017 Eric Pelzer (ecstatic.coder@gmail.com)

    Cibyl is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Cibyl is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Cibyl.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import core.stdc.stdlib : exit;
import core.thread;
import std.conv : to;
import std.datetime : Clock, SysTime;
import std.file : dirEntries, exists, mkdirRecurse, readText, timeLastModified, write, FileException, SpanMode;
import std.path : dirName;
import std.stdio : writeln;
import std.string : endsWith, indexOf, replace, split, startsWith, stripLeft, stripRight;

// -- TYPES

// .. INT

version ( X86 )
{
    alias INT = int;
}
else
{
    alias INT = long;
}

// .. CODE

enum LANGUAGE
{
    Ruby = 1,
    Crystal = 2,
    Any = Ruby | Crystal
}

// ~~

class LINE
{
    // -- ATTRIBUTES

    INT
        SpaceCount;
    string
        Text;
    bool
        IsRemoved;

    // -- CONSTRUCTORS

    this(
        string text
        )
    {
        text = text.stripRight();

        SpaceCount = 0;

        while ( SpaceCount < text.length
                && text[ SpaceCount ] == ' ' )
        {
            ++SpaceCount;
        }

        Text = text[ SpaceCount .. $ ];
    }

    // -- INQUIRIES

    bool IsEmpty(
        )
    {
        return Text == "";
    }

    // ~~

    bool HasCommand(
        string command,
        string[] command_prefix_array = null
        )
    {
        string
            text;

        text = Text.RemoveCommandPrefix( command_prefix_array );

        return
            text == command
            || ( text.startsWith( command )
                 && text[ command.length ] == ' ' );
    }

    // ~~

    bool HasCommand(
        string[] command_array
        )
    {
        foreach ( command; command_array )
        {
            if ( HasCommand( command ) )
            {
                return true;
            }
        }

        return false;
    }

    // ~~

    string GetIndentedText(
        )
    {
        string
            indented_text;

        if ( IsRemoved )
        {
            if ( CompactOptionIsEnabled )
            {
                return "";
            }
            else
            {
                return "\n";
            }
        }
        else
        {
            indented_text = GetSpaceText( SpaceCount );
            indented_text ~= Text;
            indented_text ~= '\n';

            return indented_text;
        }
    }

    // -- OPERATIONS

    void Remove(
        )
    {
        Text = "";
        IsRemoved = true;
    }
}

// ~~

class CODE
{
    // -- ATTRIBUTES

    string
        FilePath;
    LINE[]
        LineArray;
    INT
        LineIndex;

    // -- CONSTRUCTORS

    this(
        string file_path
        )
    {
        FilePath = file_path;
    }

    // -- INQUIRIES

    bool HasPriorCommand(
        string command,
        INT last_line_index,
        INT space_count
        )
    {
        INT
            line_index;
        LINE
            line;

        for ( line_index = last_line_index;
              line_index >= 0;
              --line_index )
        {
            line = LineArray[ line_index ];

            if ( line.SpaceCount < space_count
                 && line.Text != "" )
            {
                return false;
            }
            else if ( line.SpaceCount == space_count
                      && line.HasCommand( command ) )
            {
                return true;
            }
        }

        return false;
    }

    // ~~

    bool FindBrace(
        ref INT line_index,
        string brace,
        INT first_line_index,
        INT space_count
        )
    {
        LINE
            line;

        for ( line_index = first_line_index;
              line_index < LineArray.length;
              ++line_index )
        {
            line = LineArray[ line_index ];

            if ( line.SpaceCount < space_count
                 && line.Text != "" )
            {
                return false;
            }
            else if ( line.SpaceCount == space_count
                      && line.Text == brace )
            {
                return true;
            }
        }

        return false;
    }

    // ~~

    string GetText(
        )
    {
        string
            file_text;

        foreach ( line; LineArray )
        {
            file_text ~= line.GetIndentedText();
        }

        return file_text;
    }

    // -- OPERATIONS

    void SetLineArray(
        string file_text
        )
    {
        string[]
            line_array;

        line_array = file_text.replace( "\r", "" ).replace( "\t", "    " ).split( "\n" );

        foreach ( line_index; 0 .. line_array.length )
        {
            LineArray ~= new LINE( line_array[ line_index ] );
        }
    }

    // ~~

    bool ProcessComment(
        )
    {
        LINE
            line;

        line = LineArray[ LineIndex ];

        if ( line.HasCommand( "//" ) )
        {
            line.Text = "#" ~ line.Text[ 2 .. $ ];

            return true;
        }
        else
        {
            return false;
        }
    }

    // ~~

    bool ProcessBlock(
        string command,
        string[] closing_command_array,
        string[] command_prefix_array,
        LANGUAGE language
        )
    {
        INT
            closing_line_index,
            opening_line_index;
        LINE
            line;

        line = LineArray[ LineIndex ];

        if ( ( Language & language ) != 0
             && line.HasCommand( command, command_prefix_array ) )
        {
            if ( FindBrace( opening_line_index, "{", LineIndex + 1, line.SpaceCount )
                 && FindBrace( closing_line_index, "}", opening_line_index + 1, line.SpaceCount ) )
            {
                LineArray[ opening_line_index ].Remove();

                if ( ( closing_command_array.length > 0
                       && closing_line_index + 1 < LineArray.length
                       && LineArray[ closing_line_index + 1 ].HasCommand( closing_command_array ) )
                     || command == "when"
                     || ( command == "else"
                          && HasPriorCommand( "when", LineIndex - 1, line.SpaceCount ) ) )
                {
                    LineArray[ closing_line_index ].Remove();
                }
                else
                {
                    LineArray[ closing_line_index ].Text = "end";
                }

                if ( line.HasCommand( "do" )
                     && LineIndex > 0
                     && !LineArray[ LineIndex - 1 ].IsEmpty() )
                {
                    LineArray[ LineIndex - 1 ].Text ~= " \\";
                }

                return true;
            }
            else
            {
                PrintError( FilePath ~ "(" ~ ( LineIndex + 1 ).to!string() ~ ") : invalid block" );
            }
        }

        return false;
    }

    // ~~

    void Process(
        )
    {
        string[]
            command_prefix_array = [ "private ", "protected ", "abstract " ];

        for ( LineIndex = 0;
              LineIndex < LineArray.length;
              ++LineIndex )
        {
            if ( ProcessComment()
                 || ProcessBlock( "module", null, command_prefix_array, LANGUAGE.Any )
                 || ProcessBlock( "lib", null, command_prefix_array, LANGUAGE.Crystal )
                 || ProcessBlock( "enum", null, command_prefix_array, LANGUAGE.Any )
                 || ProcessBlock( "struct", null, command_prefix_array, LANGUAGE.Any )
                 || ProcessBlock( "class", null, command_prefix_array, LANGUAGE.Any )
                 || ProcessBlock( "def", [ "rescue", "else", "ensure" ], command_prefix_array, LANGUAGE.Any )
                 || ProcessBlock( "if", [ "elsif", "else" ], null, LANGUAGE.Any )
                 || ProcessBlock( "elsif", [ "else" ], null, LANGUAGE.Any )
                 || ProcessBlock( "else", [ "ensure" ], null, LANGUAGE.Any )
                 || ProcessBlock( "unless", [ "else" ], null, LANGUAGE.Any )
                 || ProcessBlock( "case", [ "when", "else" ], null, LANGUAGE.Any )
                 || ProcessBlock( "when", [ "when", "else" ], null, LANGUAGE.Any )
                 || ProcessBlock( "while", null, null, LANGUAGE.Any )
                 || ProcessBlock( "until", null, null, LANGUAGE.Any )
                 || ProcessBlock( "for", null, null, LANGUAGE.Ruby )
                 || ProcessBlock( "begin", [ "rescue", "else", "ensure" ], null, LANGUAGE.Any )
                 || ProcessBlock( "rescue", [ "else", "ensure" ], null, LANGUAGE.Any )
                 || ProcessBlock( "ensure", null, null, LANGUAGE.Any )
                 || ProcessBlock( "do", null, null, LANGUAGE.Any ) )
            {
            }
        }
    }
}

// ~~

class FILE
{
    string
        InputPath,
        OutputPath;
    bool
        Exists;
    SysTime
        ModificationSystemTime;

    // ~~

    this(
        string input_file_path,
        string output_file_path
        )
    {
        InputPath = input_file_path;
        OutputPath = output_file_path;
        Exists = true;
    }

    // ~~

    string ReadInputFile(
        )
    {
        string
            input_file_text;

        writeln( "Reading file : ", InputPath );

        try
        {
            input_file_text = InputPath.readText();
        }
        catch ( FileException file_exception )
        {
            Abort( "Can't read file : " ~ InputPath, file_exception );
        }

        return input_file_text;
    }

    // ~~

    void CreateOutputFolder(
        )
    {
        string
            output_folder_path;

        output_folder_path = OutputPath.dirName();

        if ( !output_folder_path.exists() )
        {
            writeln( "Creating folder : ", output_folder_path );

            try
            {
                if ( output_folder_path != ""
                     && output_folder_path != "/"
                     && !output_folder_path.exists() )
                {
                    output_folder_path.mkdirRecurse();
                }
            }
            catch ( FileException file_exception )
            {
                Abort( "Can't create folder : " ~ output_folder_path, file_exception );
            }
        }
    }

    // ~~

    void WriteOutputFile(
        string output_file_text
        )
    {
        writeln( "Writing file : ", OutputPath );

        try
        {
            OutputPath.write( output_file_text );
        }
        catch ( FileException file_exception )
        {
            Abort( "Can't write file : " ~ OutputPath, file_exception );
        }
    }

    // ~~

    string ProcessIdentifiers(
        string text,
        bool text_is_fixed
        )
    {
        bool
            it_is_attribute_access,
            it_is_function_call,
            it_is_inside_comment,
            it_is_inside_string,
            it_is_member_access;
        char
            character;
        string
            fixed_identifier;
        INT
            character_index,
            next_character_index;

        for ( character_index = 0;
              character_index < text.length;
              ++character_index )
        {
            character = text[ character_index ];

            if ( it_is_inside_comment )
            {
                if ( character == '\n' )
                {
                    it_is_inside_comment = false;
                }
            }
            else if ( it_is_inside_string )
            {
                if ( character == '\\' )
                {
                    ++character_index;
                }
                else if ( character == '"' )
                {
                    it_is_inside_string = false;
                }
            }
            else if ( character == '/'
                      && character + 1 < text.length
                      && text[ character_index + 1 ] == '/' )
            {
                it_is_inside_comment = true;

                ++character_index;
            }
            else if ( character == '"' )
            {
                it_is_inside_string = true;
            }
            else
            {
                if ( character >= 'A'
                     && character <= 'Z'
                     && ( character_index == 0
                          || !text[ character_index - 1 ].IsAlphaNumericCharacter() ) )
                {
                    next_character_index = character_index + 1;

                    while ( next_character_index < text.length
                            && text[ next_character_index ].IsAlphaNumericCharacter() )
                    {
                        ++next_character_index;
                    }

                    if ( next_character_index < text.length
                         && ( text[ next_character_index ] == '!'
                              || text[ next_character_index ] == '?' ) )
                    {
                        ++next_character_index;
                    }

                    if ( ( character_index >= 1
                           && text[ character_index - 1 ] == '#' ) )
                    {
                        if ( text_is_fixed )
                        {
                            text = text[ 0 .. character_index - 1 ] ~ text [ character_index .. $ ];

                            character_index = next_character_index;
                        }
                    }
                    else
                    {
                        fixed_identifier = text[ character_index .. next_character_index ];

                        it_is_member_access = ( character_index >= 1 && text[ character_index - 1 ] == '.' );
                        it_is_attribute_access = ( character_index >= 1 && text[ character_index - 1 ] == '@' );
                        it_is_function_call = ( next_character_index < text.length && text[ next_character_index ] == '(' );

                        if ( it_is_member_access
                             || it_is_attribute_access
                             || it_is_function_call
                             || ( text_is_fixed
                                  && ( fixed_identifier in IsFixedIdentifierMap ) !is null ) )
                        {
                            if ( text_is_fixed )
                            {
                                fixed_identifier = fixed_identifier.GetSnakeCaseIdentifier();

                                text = text[ 0 .. character_index ] ~ fixed_identifier ~ text [ next_character_index .. $ ];

                                character_index = character_index + fixed_identifier.length - 1;
                            }
                            else
                            {
                                if ( it_is_attribute_access
                                     || it_is_function_call )
                                {
                                    IsFixedIdentifierMap[ fixed_identifier ] = true;
                                }
                            }
                        }
                        else
                        {
                            character_index = next_character_index - 1;
                        }
                    }
                }
            }
        }

        return text;
    }

    // ~~

    void Parse(
        bool modification_time_is_checked
        )
    {
        string
            input_file_text;
        SysTime
            modification_system_time;

        modification_system_time = InputPath.timeLastModified();

        if ( !modification_time_is_checked
             || modification_system_time > ModificationSystemTime )
        {
            ModificationSystemTime = modification_system_time;

            writeln( "Parsing file : ", InputPath );

            try
            {
                input_file_text = InputPath.readText();
            }
            catch ( FileException file_exception )
            {
                Abort( "Can't parse file : " ~ InputPath, file_exception );
            }

            ProcessIdentifiers( input_file_text, false );
        }
    }

    // ~~

    void Process(
        bool modification_time_is_used
        )
    {
        string
            input_file_text,
            output_file_text;
        CODE
            code;

        if ( Exists
             && ( !OutputPath.exists()
                  || !modification_time_is_used
                  || InputPath.timeLastModified() > OutputPath.timeLastModified() ) )
        {
            input_file_text = ReadInputFile();

            if ( CaseOptionIsEnabled )
            {
                input_file_text = ProcessIdentifiers( input_file_text, true );
            }

            code = new CODE( InputPath );
            code.SetLineArray( input_file_text );
            code.Process();

            output_file_text = code.GetText();

            if ( CreateOptionIsEnabled )
            {
                CreateOutputFolder();
            }

            WriteOutputFile( output_file_text );
        }
    }
}

// -- VARIABLES

bool
    CaseOptionIsEnabled,
    CompactOptionIsEnabled,
    CreateOptionIsEnabled,
    WatchOptionIsEnabled;
bool[ string ]
    IsFixedIdentifierMap;
string
    InputFolderPath,
    OutputFolderPath,
    SpaceText;
string[]
    ParsedFolderPathArray;
FILE[ string ]
    FileMap,
    ParsedFileMap;
INT
    PauseDuration;
LANGUAGE
    Language;

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void Abort(
    string message,
    FileException file_exception
    )
{
    PrintError( message );
    PrintError( file_exception.msg );

    exit( -1 );
}

// ~~

string GetSpaceText(
    INT space_count
    )
{
    if ( space_count <= 0 )
    {
        return "";
    }
    else
    {
        while ( SpaceText.length < space_count )
        {
            SpaceText ~= SpaceText;
        }

        return SpaceText[ 0 .. space_count ];
    }
}

// ~~

string GetLogicalPath(
    string path
    )
{
    return path.replace( "\\", "/" );
}

// ~~

string RemoveCommandPrefix(
    string text,
    string[] command_prefix_array
    )
{
    text = text.stripLeft();

    foreach ( command_prefix; command_prefix_array )
    {
        if ( text.startsWith( command_prefix ) )
        {
            text = text[ command_prefix.length .. $ ].stripLeft();
        }
    }

    return text;
}

// ~~

bool IsAlphaNumericCharacter(
    char character
    )
{
    return
        ( character >= 'A' && character <= 'Z' )
        || ( character >= 'a' && character <= 'z' )
        || ( character >= '0' && character <= '9' )
        || character == '_';
}

// ~~

string GetSnakeCaseIdentifier(
    string text
    )
{
    string
        snake_case_identifier;

    foreach ( character_index, character; text )
    {
        if ( character >= 'A'
             && character <= 'Z' )
        {
            if ( character_index > 0 )
            {
                snake_case_identifier ~= '_';
            }

            snake_case_identifier ~= ( character - 'A' ) + 'a';
        }
        else
        {
            snake_case_identifier ~= character;
        }
    }

    return snake_case_identifier;
}

// ~~

string GetOutputExtension(
    )
{
    if ( Language == LANGUAGE.Ruby )
    {
        return ".rb";
    }
    else if ( Language == LANGUAGE.Crystal )
    {
        return ".cr";
    }

    Abort( "Unknown language" );

    return "";
}

// ~~

void ParseFiles(
    string parsed_folder_path
    )
{
    string
        parsed_file_path;
    FILE
        parsed_file;
    FILE *
        found_parsed_file;

    foreach ( parsed_folder_entry; dirEntries( parsed_folder_path, "*.cb", SpanMode.depth ) )
    {
        if ( parsed_folder_entry.isFile() )
        {
            parsed_file_path = parsed_folder_entry.name();

            found_parsed_file = parsed_file_path in ParsedFileMap;

            if ( found_parsed_file is null )
            {
                parsed_file = new FILE( parsed_file_path, "" );
                parsed_file.Parse( false );

                ParsedFileMap[ parsed_file_path ] = parsed_file;
            }
            else
            {
                found_parsed_file.Parse( true );
            }
        }
    }
}

// ~~

void FindFiles(
    string input_folder_path,
    string output_folder_path
    )
{
    string
        input_file_path,
        output_file_path;
    FILE *
        found_file;

    foreach ( ref old_file; FileMap )
    {
        old_file.Exists = false;
    }

    foreach ( input_folder_entry; dirEntries( input_folder_path, "*.cb", SpanMode.depth ) )
    {
        if ( input_folder_entry.isFile() )
        {
            input_file_path = input_folder_entry.name();

            if ( input_file_path.startsWith( input_folder_path )
                 && input_file_path.endsWith( ".cb" ) )
            {
                output_file_path
                    = output_folder_path
                      ~ input_file_path[ input_folder_path.length .. $ - 3 ]
                      ~ GetOutputExtension();

                found_file = input_file_path in FileMap;

                if ( found_file is null )
                {
                    FileMap[ input_file_path ] = new FILE( input_file_path, output_file_path );
                }
                else
                {
                    found_file.Exists = true;
                }
            }
        }
    }
}

// ~~

void ProcessFiles(
    string input_folder_path,
    string output_folder_path,
    bool modification_time_is_used
    )
{
    foreach ( parsed_folder_path; ParsedFolderPathArray )
    {
        ParseFiles( parsed_folder_path );
    }

    FindFiles( input_folder_path, output_folder_path );

    foreach ( ref file; FileMap )
    {
        file.Process( modification_time_is_used );
    }
}

// ~~

void WatchFiles(
    string input_folder_path,
    string output_folder_path
    )
{
    ProcessFiles( input_folder_path, output_folder_path, false );

    writeln( "Watching files..." );

    while ( true )
    {
        Thread.sleep( dur!( "msecs" )( PauseDuration ) );

        ProcessFiles( input_folder_path, output_folder_path, true );
    }
}

// ~~

void main(
    string[] argument_array
    )
{
    string
        input_folder_path,
        option,
        output_folder_path;

    argument_array = argument_array[ 1 .. $ ];

    SpaceText = " ";

    Language = LANGUAGE.Ruby;
    CompactOptionIsEnabled = false;
    CaseOptionIsEnabled = false;
    ParsedFolderPathArray = [];
    CreateOptionIsEnabled = false;
    WatchOptionIsEnabled = false;
    PauseDuration = 500;

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];

        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--ruby" )
        {
            Language = LANGUAGE.Ruby;
        }
        else if ( option == "--crystal" )
        {
            Language = LANGUAGE.Crystal;
        }
        else if ( option == "--compact" )
        {
            CompactOptionIsEnabled = true;
        }
        else if ( option == "--case" )
        {
            CaseOptionIsEnabled = true;
        }
        else if ( option == "--parse"
                  && argument_array.length >= 1
                  && argument_array[ 0 ].GetLogicalPath().endsWith( '/' ) )
        {
            ParsedFolderPathArray ~= argument_array[ 0 ].GetLogicalPath();

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--create" )
        {
            CreateOptionIsEnabled = true;
        }
        else if ( option == "--watch" )
        {
            WatchOptionIsEnabled = true;
        }
        else if ( option == "--pause"
                  && argument_array.length >= 1 )
        {
            PauseDuration = argument_array[ 0 ].to!INT();

            argument_array = argument_array[ 1 .. $ ];
        }
        else
        {
            PrintError( "Invalid option : " ~ option );
        }
    }

    if ( argument_array.length == 2
         && argument_array[ 0 ].GetLogicalPath().endsWith( '/' )
         && argument_array[ 1 ].GetLogicalPath().endsWith( '/' ) )
    {
        input_folder_path = argument_array[ 0 ].GetLogicalPath();
        output_folder_path = argument_array[ 1 ].GetLogicalPath();

        if ( WatchOptionIsEnabled )
        {
            WatchFiles( input_folder_path, output_folder_path );
        }
        else
        {
            ProcessFiles( input_folder_path, output_folder_path, false );
        }
    }
    else
    {
        writeln( "Usage :" );
        writeln( "    cibyl [options] INPUT_FOLDER/ OUTPUT_FOLDER/" );
        writeln( "Options :" );
        writeln( "    --ruby" );
        writeln( "    --crystal" );
        writeln( "    --case" );
        writeln( "    --parse INPUT_FOLDER/" );
        writeln( "    --compact" );
        writeln( "    --create" );
        writeln( "    --watch" );
        writeln( "    --pause 500" );
        writeln( "Examples :" );
        writeln( "    cibyl --crystal CB/ CR/" );
        writeln( "    cibyl --crystal --create CB/ CR/" );
        writeln( "    cibyl --crystal --create --watch CB/ CR/" );

        PrintError( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
