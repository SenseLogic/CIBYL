# -- IMPORTS

require "ecr"
require "http/server";

# -- MODULES

module Test

    # -- TYPES

    abstract struct Abstract

    end

    # ~~

    struct Position

        # -- ATTRIBUTES

        protected property \
            x : Float64,
            y : Float64,
            z : Float64;
        class_property \
            zero = Position.new( 0.0, 0.0, 0.0 );

        # -- CONSTRUCTORS

        def initialize(
            @x,
            @y,
            @z
            ) : Void

        end

        # -- INQUIRIES

        def is_zero(
            ) : Bool

            return
                x == @@zero.x \
                && y == @@zero.y \
                && z == @@zero.z;
        end
    end

    # ~~

    enum Color

        # -- CONSTANTS

        RED
        GREEN
        BLUE

        # -- INQUIRIES

        def is_red?(
            ) : Bool

            return self == RED;
        end
    end

    # ~~

    struct Point

        # -- CONSTRUCTORS

        def initialize(
            @name : String,
            @position : Position,
            @color : Color
            ) : Void

        end

        # -- INQUIRIES

        def is_blue(
            ) : Bool

            return @color == Color::BLUE;
        end
    end

    # ~~

    struct Person

        # -- ATTRIBUTES

        property \
            name : String,
            age : Int32,
            color : Color;
        class_property \
            minimum_age : Int32 = 25,
            maximum_age : Int32 = 70;

        # -- CONSTRUCTORS

        def initialize(
            @name,
            @age,
            @color
            ) : Void

            if ( @age < @@minimum_age )

                puts( "Studying" );

            elsif ( @age >= @@minimum_age \
                    && @age < @@maximum_age )

                puts( "Working" );

            else

                puts( "Retreated" );
            end
        end

        # -- INQUIRIES

        def is_green?(
            ) : Bool

            return color == Color::GREEN;
        end

        # -- OPERATIONS

        protected def print(
            ) : Void

            puts( "#{age} - #{name}" );
        end
    end

    # ~~

    class Test

        # -- CONSTRUCTORS

        def initialize(
            @hello : String,
            @world : String
            ) : Void

        end

        # -- OPERATIONS

        def test_comment(
            count : Int32
            ) : Int32

            #****************
            # This is
            #  a single-line
            #   comment.
            #****************
            # This is a single-line comment.
            # This is
            #
            # a multi-line
            #
            # comment.
            #
            # This is
            #
            # a multi-line
            #
            # comment.
            #
            # This is
            #
            #  a multi-line
            #
            #   comment.
            # This is
            #
            #a multi-line
            #
            #comment.
            # This
            #
            # is
            #
            #a multi-line
            #
            # comment.
            #   This is
            #
            #   a multi-line
            #
            #   comment.

            if ( count <= 1 )    # This is a comment.

                return 10;    # This is a comment.

            else

                return 20;    # This is a comment.
            end
        end

        # ~~

        def test_if(
            count : Int32
            ) : Int32

            if ( count <= 1 )

                return 10;
            end

            if ( count <= 1 )

                return 10;

            else

                return 20;
            end

            if ( count <= 1 )

                return 10;

            elsif ( count <= 2 )

                return 20;

            elsif ( count <= 3 \
                    && count != 1 \
                    && count != 2 )

                return 30;

            else

                return 40;
            end

            if ( count >= 1 \
                 && count * 2 \
                    < count * 3 - 5 )

                count \
                    += test_unless(
                           count * 3 - 5 \
                           - count * 2
                           );
            end
        end

        # ~~

        def test_unless(
            count : Int32
            ) : Int32

            unless ( count > 1 )

                return 10;
            end

            unless ( count > 1 )

                return 10;

            else

                return 20;
            end
        end

        # ~~

        def test_while(
            count : Int32
            ) : Int32

            index = 0;

            while ( index < count )

                index = index + 1;
            end

            return index;
        end

        # ~~

        def test_until(
            count : Int32
            ) : Int32

            index = 0;

            until ( index >= count )

                index = index + 1;
            end

            return index;
        end

        # ~~

        def test_case(
            count : Int32
            ) : Int32

            case ( count )

                when 1

                    return 10;

            end

            case ( count )

                when 1

                    return 10;

                when 2

                    return 20;

            end

            case ( count )

                when 1

                    return 10;

                when 2

                    return 20;

                else

                    return 30;

            end
        end

        # ~~

        def test_begin(
            ) : Int32

            begin

                result = 10;

            rescue

                result = 20;

            else

                result = 30;

            ensure

                result = 40;
            end
        end

        # ~~

        def test_rescue(
            ) : Int32

            result = 10;

        rescue

            result = 20;

        else

            result = 30;

        ensure

            result = 40;
        end

        # ~~

        def test_each(
            ) : Bool

            "0123456789".each_char \
                do | character |

                    print( character );
                end

            print( '\n' );

            [
                { 1, "A" },
                { 2, "B" }
            ].each \
                do | key, value |

                    puts( "#{key} : #{value}" );
                end

            return true;
        end

        # ~~

        def test_type(
            ) : Bool

            data = Array( NamedTuple( id: Int32, name: String ) ).new();
            data.push( { id: 1, name: "Toto" } );
            data.push( { id: 2, name: "Tutu" } );
            data.push( { id: 3, name: "Tata" } );
            data.push( { id: 4, name: "Titi" } );

            puts( data );

            return true;
        end

        # ~~

        def test_character(
            ) : Bool

            puts( '\'' );
            puts( '\\' );
            puts( '\u0041' );
            puts( '\u{41}' );
            puts( 'a' );
            puts( 'あ' );

            return true;
        end

        # ~~

        def test_string(
            ) : Bool

            puts( "Test #{@hello + " Test #{@hello} #{@world} Test " + @world} Test" );
            puts( %(Test #{@hello + %( Test #{@hello} #{@world} Test ) + @world} Test) );
            puts( %[Test #{@hello + %[ Test #{@hello} #{@world} Test ] + @world} Test] );
            puts( %{Test #{@hello + %{ Test #{@hello} #{@world} Test } + @world} Test} );
            puts( %<Test #{@hello + %< Test #{@hello} #{@world} Test > + @world} Test> );
            puts( %|Test #{@hello + %| Test #{@hello} #{@world} Test | + @world} Test| );
            puts( %(Test #{@hello + %[ Test #{@hello} #{@world} Test ] + @world} Test) );
            puts( %Q(Test #{@hello + %Q( Test #{@hello} #{@world} Test ) + @world} Test) );
            puts( %Q[Test #{@hello + %Q[ Test #{@hello} #{@world} Test ] + @world} Test] );
            puts( %Q{Test #{@hello + %Q{ Test #{@hello} #{@world} Test } + @world} Test} );
            puts( %Q<Test #{@hello + %Q< Test #{@hello} #{@world} Test > + @world} Test> );
            puts( %Q|Test #{@hello + %Q| Test #{@hello} #{@world} Test | + @world} Test| );
            puts( %Q(Test #{@hello + %Q[ Test #{@hello} #{@world} Test ] + @world} Test) );

            puts( "Test \#{@Hello + \" Test \#{@Hello} \#{@World} Test \" + @World} Test" );
            puts( %q(Test #{@Hello + %q( Test #{@Hello} #{@World} Test ) + @World} Test) );
            puts( %q[Test #{@Hello + %q[ Test #{@Hello} #{@World} Test ] + @World} Test] );
            puts( %q{Test #{@Hello + %q{ Test #{@Hello} #{@World} Test } + @World} Test} );
            puts( %q<Test #{@Hello + %q< Test #{@Hello} #{@World} Test > + @World} Test> );
            puts( %q(Test #{@Hello + %q[ Test #{@Hello} #{@World} Test ] + @World} Test) );

            [ "", " ", "x", "x x", "  Hello  World !  " ].each \
                do | old_text |

                    part_array = old_text.split( ' ' );
                    new_text = part_array.join( ' ' );
                    puts( "'#{old_text}' => #{part_array} => '#{new_text}'" );
                end

            return true;
        end

        # ~~

        def test_letter_case(
            ) : Bool

            # snake_case PascalCase UPPER_CASE
            # snake_case PascalCase UPPER_CASE
            # snake_case PascalCase UPPER_CASE
            # // \ $snake_case #snake_case UINT32 UInt32

            return true;
        end

        # ~~

        def test_server(
            server_is_run
            ) : Bool

            if ( server_is_run )

                server = HTTP::Server.new \
                    do | context |

                        context.response.content_type = "text/plain";
                        context.response.print( "Hello world! The time is #{Time.now}" );
                    end

                address = server.bind_tcp( 8080 );
                puts( "Listening on http://#{address}" );
                server.listen();
            end

            return true;
        end

        # ~~

        def run(
            ) : Void

            puts( test_comment( 1 ) );
            puts( test_if( 1 ) );
            puts( test_unless( 1 ) );
            puts( test_while( 10 ) );
            puts( test_until( 10 ) );
            puts( test_case( 1 ) );
            puts( test_begin() );
            puts( test_rescue() );
            puts( test_each() );
            puts( test_type() );
            puts( test_character() );
            puts( test_string() );
            puts( test_letter_case() );
            puts( test_server( false ) );
        end
    end

    # -- STATEMENTS

    test = Test.new( "Hello", "World" );
    test.run();

    # ~~

    point \
        = Point.new(
              "point",
              Position.new( 1.0, 2.0, 3.0 ),
              Color::BLUE
              );

    puts(
        point.@position.x,
        point.@position.y,
        point.@position.z,
        Person.minimum_age,
        Person.maximum_age
        );

    # ~~

    person_array = Array( Person ).new();
    person_array.push( Person.new( "Red", 15, Color::RED ) );
    person_array.push( Person.new( "Green", 35, Color::GREEN ) );
    person_array.push( Person.new( "Blue", 75, Color::BLUE ) );

    # ~~

    server = HTTP::Server.new \
        do | context |

            request = context.request;

            response = context.response;
            response.headers[ "Server" ] = "Crystal";
            response.headers[ "Date" ] = HTTP.format_time( Time.now );
            response.headers[ "Content-Type" ] = "text/html; charset=UTF-8";
            response.status_code = 200;

            case ( request.path )

                when "/"

                    ECR.embed "test.ecr", response

                when "/get"

                    response.print( "<p>#{request.path}</p>" );
                    request.query_params.each \
                        do | name, value |

                            response.print( "<p>#{name} : #{value}</p>" );
                        end

                when "/post"

                    response.print( "<p>#{request.path}</p>" );
                    request_body = request.body;

                    if ( request_body )

                        HTTP::Params.parse( request_body.gets_to_end ).each \
                            do | name, value |

                                response.print( "<p>#{name} : #{value}</p>" );
                            end
                    end

                when "/time"

                    response.print( "<p>The time is #{Time.now}</p>" );

                else

                    response.print( "<h1>Oops...</h1><p>#{request.path}</p>" );
                    response.status_code = 404;

            end

            response.print( "<p><a href=\"/\">Back</a></p>" );
        end

    puts( "Listening on http://127.0.0.1:8080" );

    server.listen( "127.0.0.1", 8080, reuse_port: true )
end
