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

        # -- CONSTRUCTORS

        def initialize(
            @x,
            @y,
            @z
            ) : \
            Void
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
            ) : \
            Bool
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
            ) : \
            Void
        end

        # -- INQUIRIES

        def is_blue(
            )
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
            ) : \
            Void
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
            ) : \
            Bool
            return color == Color::GREEN;
        end

        # -- OPERATIONS

        protected def print(
            ) : \
            Void
            puts( "#{age} - #{name}" );
        end
    end

    # ~~

    class Test
        # -- CONSTRUCTORS

        def initialize(
            @hello : String,
            @world : String
            ) : \
            Void
        end

        # -- OPERATIONS

        def test_if(
            count : Int32
            ) : \
            Int32
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
            else
                return 30;
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
            ) : \
            Int32
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
            ) : \
            Void
            index = 0;

            while ( index < count )
                index = index + 1;
            end
        end

        # ~~

        def test_until(
            count : Int32
            ) : \
            Void
            index = 0;

            until ( index >= count )
                index = index + 1;
            end
        end

        # ~~

        def test_case(
            count : Int32
            ) : \
            Int32
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
            ) : \
            Int32
            begin
                result = 1;
            rescue
                result = 2;
            else
                result = 3;
            ensure
                result = 4;
            end
        end

        # ~~

        def test_rescue(
            ) : \
            Int32
            result = 1;
        rescue
            result = 2;
        else
            result = 3;
        ensure
            result = 4;
        end

        # ~~

        def test_each(
            ) : \
            Void
            "0123456789".each_char \
                do | character |
                    print( character );
                end

            print( '\n' );

            [
                {1, "A"},
                {2, "B"}
            ].each \
                do | key, value |
                    puts( "#{key} : #{value}" );
                end
        end

        # ~~

        def test_type(
            ) : \
            Void
            data = Array( NamedTuple( id: Int32, message: String ) ).new();
        end

        # ~~

        def test_interpolation(
            ) : \
            Void
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

            puts( "Test \#{.Hello + \" Test \#{.Hello} \#{.World} Test \" + .World} Test" );
            puts( %q(Test #{.Hello + %q( Test #{.Hello} #{.World} Test ) + .World} Test) );
            puts( %q[Test #{.Hello + %q[ Test #{.Hello} #{.World} Test ] + .World} Test] );
            puts( %q{Test #{.Hello + %q{ Test #{.Hello} #{.World} Test } + .World} Test} );
            puts( %q<Test #{.Hello + %q< Test #{.Hello} #{.World} Test > + .World} Test> );
            puts( %q(Test #{.Hello + %q[ Test #{.Hello} #{.World} Test ] + .World} Test) );
        end

        # ~~

        def test_server(
            ) : \
            Void
            server = HTTP::Server.new \
                do | context |
                    context.response.content_type = "text/plain";
                    context.response.print( "Hello world! The time is #{Time.now}" );
                end

            address = server.bind_tcp( 8080 );
            puts( "Listening on http://#{address}" );
            server.listen();
        end
    end

    # -- STATEMENTS

    test = Test.new( "Hello", "World" );
    test.test_interpolation();

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
            response = context.response;
            request = context.request;

            response.headers[ "Server" ] = "Crystal";
            response.headers[ "Date" ] = HTTP.format_time( Time.now );

            case ( request.path )
                when "/"
                    response.status_code = 200;
                    response.headers[ "Content-Type" ] = "text/html; charset=UTF-8";
                    ECR.embed "test.ecr", response
                when "/time"
                    response.headers[ "Content-Type" ] = "text/html; charset=UTF-8";
                    context.response.print( "The time is #{Time.now}<br/><a href=\"/\">Back</a>" );
                else
                    response.status_code = 404;
            end
        end

    puts( "Listening on http://127.0.0.1:8080" );

    server.listen( "127.0.0.1", 8080, reuse_port: true )
end

