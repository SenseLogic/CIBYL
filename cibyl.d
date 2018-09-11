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
        string[] prefix_array = null
        )
    {
        string
            text;

        text = Text;

        foreach ( prefix; prefix_array )
        {
            if ( text.startsWith( prefix ) )
            {
                text = text[ prefix.length .. $ ].stripLeft();
            }
        }

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
        string[] prefix_array,
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
             && line.HasCommand( command, prefix_array ) )
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
            prefix_array;

        prefix_array = [ "private ", "protected ", "abstract " ];

        for ( LineIndex = 0;
              LineIndex < LineArray.length;
              ++LineIndex )
        {
            if ( ProcessComment()
                 || ProcessBlock( "module", null, prefix_array, LANGUAGE.Any )
                 || ProcessBlock( "lib", null, prefix_array, LANGUAGE.Crystal )
                 || ProcessBlock( "enum", null, prefix_array, LANGUAGE.Any )
                 || ProcessBlock( "struct", null, prefix_array, LANGUAGE.Any )
                 || ProcessBlock( "class", null, prefix_array, LANGUAGE.Any )
                 || ProcessBlock( "def", [ "rescue", "else", "ensure" ], prefix_array, LANGUAGE.Any )
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
    CompactOptionIsEnabled,
    CreateOptionIsEnabled,
    WatchOptionIsEnabled;
string
    InputFolderPath,
    OutputFolderPath,
    SpaceText;
FILE[ string ]
    FileMap;
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

void FindFiles(
    string input_folder_path,
    string output_folder_path
    )
{
    string
        input_file_path,
        output_file_path;
    FILE *
        file;

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

                file = input_file_path in FileMap;

                if ( file is null )
                {
                    FileMap[ input_file_path ] = new FILE( input_file_path, output_file_path );
                }
                else
                {
                    file.Exists = true;
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
        writeln( "    --compact" );
        writeln( "    --create" );
        writeln( "    --watch" );
        writeln( "    --pause 500" );
        writeln( "Examples :" );
        writeln( "    cibyl CB/ CR/" );
        writeln( "    cibyl --create CB/ CR/" );
        writeln( "    cibyl --create --watch CB/ CR/" );

        PrintError( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
